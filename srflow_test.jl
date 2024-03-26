import MLJ: machine, fit!, predict, report
push!(LOAD_PATH, "./lib")
using SymbolicRegression: SRRegressor

# Dataset with two named features:
X = (Opop = Float64[], Dpop = Float64[], dist = Float64[])
y = Float64[]
ori = Int[]
dest = Int[]
n_places = 100
adjmat = zeros(n_places, n_places)

open("../data/synthetic/alloc-c100-b1.3-e0.01.txt","r") do file
    for ln in eachline(file)     # 逐行读取文件内容
        substr = split(ln, " ")
        @assert length(substr)==6
    ori, dest = parse(Int, substr[1])+1, parse(Int, substr[2])+1
    adjmat[ori,dest] = 1.0
    push!(X.Opop, parse(Float64, substr[3]))
    push!(X.Dpop, parse(Float64, substr[4]))
    push!(X.dist, parse(Float64, substr[5]))
    push!(y, parse(Float64, substr[6]))
    end
end

model = SRRegressor(
    niterations=50,
    binary_operators=[+, -, *, /, ^],
    unary_operators=[exp, log],
    complexity_of_operators=[exp => 2, log => 2],
    constraints=[(^)=>(-1, 1), exp => 1, log => 1],
    allocation=true,
    adjmatrix=adjmat,
)


mach = machine(model, X, y)
fit!(mach)

report(mach)

yp = predict(mach, X)
# yp = predict(mach, (data=X, idx=2))