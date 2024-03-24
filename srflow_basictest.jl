import MLJ: machine, fit!, predict, report
push!(LOAD_PATH, "./lib")
using SymbolicRegression: SRRegressor

# Dataset with two named features:
X = (a = rand(500), b = rand(500))

# and one target:
y = @. 2 * cos(X.a * 23.5) - X.b ^ 2 # @__dot__ 每个运算加dot, 广播到所有维

# with some noise:
y = y .+ randn(500) .* 1e-3

model = SRRegressor(
    niterations=50,
    binary_operators=[+, -, *],
    unary_operators=[cos],
)

mach = machine(model, X, y)
fit!(mach)

report(mach)

yp = predict(mach, X)
# yp = predict(mach, (data=X, idx=2))
