# Change list of implementation of the allocation function

## Modification

- OptionsModule

-- **Options** : The construction function is in Options.jl and the definition is in Optionstruct.jl. Attributes `allocation`, `eval_probability`, `adjmatrix`, `num_places` are added. To upload `adjmatrix`, I implement a function in Options.jl, `set_adjmatrix` (Remember to import when using!).

- LossFunctionsModule

-- **eval_loss**: Generate partition if `allocation`.
-- **_eval_loss**: Perform probability normalization if `allocation`. If `eval_probability`, do not multiply total outflow.  
-- **batch_sample**: Sample from `1:num_places` instead of `1:dataset.n` if allocation.

## Usage

- Copy '/src/' directory into the project, rename it as '/lib/', then use the following to import:  
`push!(LOAD_PATH, "./lib")`  
`using SymbolicRegression: SRRegressor`  
(No need to install the "SymbolicRegression" library)
- Precomilation may fail if dependencies are not installed. Use `add "packageXX"` in Pkg mode to fix.
- Sample Code in `srflow_basictest.jl`

## TODO

- Migrate the dataset processing codes to Julia (Maybe random data first).
- Debug.
