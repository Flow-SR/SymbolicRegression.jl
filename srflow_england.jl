import MLJ: machine, fit!, predict, report
push!(LOAD_PATH, "./lib")
using SymbolicRegression: SRRegressor
using XLSX
using Pickle
using Dates
using FileIO


feat = Dict("area_km2"=>3, "respop"=> 4, "employedpop"=> 5, "workpop"=> 6, "households"=>7, "fb_pct"=> 8, "deprived_pct"=> 9, "nonwhite_pct"=> 10, "bach_pct"=> 11, "highsc_pct"=> 12)
select_feat = ["workpop"]

flow_dict = Pickle.load("../data/England/England_msoa_census11_supp3.pkl")
dist_dict = Pickle.load("../data/England/England_msoa_dist.pkl")
msoa_units = sort(collect(keys(dist_dict)))
attrfile = XLSX.readxlsx("../data/England/England_Census11_Attr_Selected.xlsx")
attrtab = attrfile["attr"]

ori = Int[]
dest = Int[]
flow = Float64[]
dist = Float64[]
geoid2row = Dict{Int,Int}()
nrows = size(attrtab[:], 1)
nfeat = size(select_feat,1)
nplaces = size(msoa_units,1)

featarr = [Float64[] for i in 1:2*nfeat]
ori_count = [0 for i in 1:nplaces]
println(nrows-1)
@assert nplaces==nrows-1

for r in 2:nrows
    geoid2row[parse(Int,attrtab[r, 1][end-5:end])] = r
end

for o in msoa_units
    for d in sort(collect(keys(flow_dict[o])))
        vol, dis = flow_dict[o][d], dist_dict[o][d]
        oattr = [attrtab[geoid2row[o], feat[f]] for f in select_feat]
        dattr = [attrtab[geoid2row[d], feat[f]] for f in select_feat]
        ori_count[geoid2row[o]-1] += 1
        push!(ori, o)
        push!(dest, d)
        push!(flow, vol)
        push!(dist, dis)
        for f in 1:nfeat
            push!(featarr[f], oattr[f])
            push!(featarr[nfeat+f], dattr[f])
        end
    end
    if geoid2row[o]%100==0
        println("$(geoid2row[o])/$(nrows-1)")
    end
end
y = flow
X = (D=dist, Wo=featarr[1], Wd=featarr[2]) # TO DO: only for this case
ori_sep = [sum(ori_count[1:i]) for i in 1:nplaces]
println(ori_count[1:5])
println(ori_sep[1:5])

save("eng_supp3_X_dist_odwp.jld2", "X", X)
save("eng_supp3_Y.jld2", "y", y)
save("eng_supp3_sep.jld2", "sep", ori_sep)

#=
X = load("eng_supp3_X_dist_odwp.jld2", "X")
y = load("eng_supp3_Y.jld2", "y")
ori_sep = load("eng_supp3_sep.jld2", "sep")
=#

timestamp = Dates.format(Dates.now(),"yyyymmddHHMM")[3:end]
model = SRRegressor(
    niterations=100,
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