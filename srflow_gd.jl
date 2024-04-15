import MLJ: machine, fit!, predict, report
push!(LOAD_PATH, "./lib")
using SymbolicRegression: SRRegressor
using CSV
using Pickle
using Dates
using NPZ
using DataFrames
using FileIO


#feat = Dict("area_km2"=>3, "respop"=> 4, "employedpop"=> 5, "workpop"=> 6, "households"=>7, "fb_pct"=> 8, "deprived_pct"=> 9, "nonwhite_pct"=> 10, "bach_pct"=> 11, "highsc_pct"=> 12)
select_feat = ["pop"]

flow_array = npzread(raw"D:\repos\FlowSR\GD_data\flow_matrix_1101-1128_intercounty.npy")
dist_array = npzread(raw"D:\repos\FlowSR\GD_data\dist_matrix_1101-1128_intercounty.npy")
id_dict = Pickle.load(raw"D:\repos\FlowSR\GD_data\ids_mapping_intercounty.pkl")
attr_df = CSV.read(raw"D:\repos\FlowSR\GD_data\GD_county_attr.csv", DataFrame)

logY = false

# 准备空的数组来收集数据
ori = Int[]
dest = Int[]
flow = Float64[]
dist = Float64[]
featarr = [Float64[] for i in 1:2*size(select_feat, 1)]

# 从流数据中获取地区数
num_regions = size(flow_array, 1)

ori_count = [0 for i in 1:num_regions]
# 遍历流数据
for i in 1:num_regions
    for j in 1:num_regions

        # 如果流量为零或者跳过对角线则继续
        if flow_array[i, j] == 0 || i == j
            continue
        end
        
        # 获取起点和终点id
        o_id = id_dict[i-1]
        d_id = id_dict[j-1]

        # 获取起点和终点的属性
        if select_feat !== nothing
            o_attr = attr_df[attr_df.code .== o_id, select_feat]
            d_attr = attr_df[attr_df.code .== d_id, select_feat]
        else
            o_attr = attr_df[attr_df.code .== o_id, 3:end]
            d_attr = attr_df[attr_df.code .== d_id, 3:end]
        end
        @assert size(d_attr, 1) == 1
        @assert size(o_attr, 1) == 1

        # 获取起点和终点之间的距离
        distance = dist_array[i, j]

        if distance < 0
            println(o_id, " ", d_id, " ", distance)
            println(i, " ", j)
        end
        # 将数据添加到数组中
        push!(ori, o_id)
        push!(dest, d_id)
        if logY
            push!(flow, log(flow_array[i, j] + 1))
        else
            push!(flow, flow_array[i, j])
        end
        push!(dist, distance)
        o_attr_vec = Float64.(collect(o_attr[1, :]))
        d_attr_vec = Float64.(collect(d_attr[1, :]))
        for f in 1:size(select_feat, 1)
            push!(featarr[f], o_attr_vec[f])
            push!(featarr[size(select_feat, 1) + f], d_attr_vec[f])
        end
        # println(featarr)
        ori_count[i] += 1
    end
end

# 准备输出数据
y =  flow
dist_matrix = reshape(dist, 1, :)
feat_matrix = hcat(featarr...)
# 将 dist_matrix 和 featarr 垂直叠加
#X = vcat(dist_matrix, feat_matrix')
X = (D=dist, Wo=featarr[1], Wd=featarr[2]) # TO DO: only for this case

ori_sep = [sum(ori_count[1:i]) for i in 1:num_regions]

println(ori_count[1:5])
println(ori_sep[1:5])

save("gd_X_dist_odpop.jld2", "X", X)
save("gd_Y.jld2", "y", y)
save("gd_sep.jld2", "sep", ori_sep)

#=
X = load("eng_supp3_X_dist_odwp.jld2", "X")
y = load("eng_supp3_Y.jld2", "y")
ori_sep = load("eng_supp3_sep.jld2", "sep")
=#

timestamp = Dates.format(Dates.now(),"yyyymmddHHMM")[3:end]
model = SRRegressor(
    niterations=1000,
    binary_operators=[+, -, *, /, ^],
    unary_operators=[exp, log],
    complexity_of_operators=[exp => 2, log => 2],
    constraints=[(^)=>(-1, 1), exp => 1, log => 1],
    allocation=true,
    ori_sep=ori_sep,
    batching=true,
    batch_size=40,
    #optimizer_probability=1.0,
    #optimizer_iterations=20,
    output_file="hall_of_fame_" * timestamp * ".csv",
)


mach = machine(model, X, y)
fit!(mach)
report(mach)

yp = predict(mach, X)
# yp = predict(mach, (data=X, idx=2))