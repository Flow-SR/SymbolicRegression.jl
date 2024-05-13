# Change list of implementation of the allocation function

## Modification

- OptionsModule

--  **Options** : The construction function is in Options.jl and the definition is in Optionstruct.jl. Attributes `allocation`, `eval_probability`, `ori_sep`, `num_places`,  `optimize_hof` are added.  

-- In allocation mode, `ori_sep` is required as n-dim vector, where n is the number of places; dataset entry `ori_sep[i-1]+1:ori_sep[i]` corresponds to flows with origin `i`. Alternatively, you may input n*n `adjmatrix`, which is transformed into `ori_sep`. `num_places` will be calculated automatically.  

- LossFunctionsModule

-- **eval_loss**: Generate partition if `allocation`.  
-- **_eval_loss**: Perform probability normalization if `allocation`. If `eval_probability`, do not multiply total outflow.  
-- **batch_sample**: Sample from `1:num_places` instead of `1:dataset.n` if allocation.

- SymbolicRegressionModule
-- **_equation_search**: if `optimize_hof`, Hall-of-Fame equations will be optimized with entire dataset (even if `batching=true`) after the last `s_r_cycle`.

## Usage

- Copy '/src/' directory into the project, rename it as '/lib/', then use the following to import:  
`push!(LOAD_PATH, "./lib")`  
`using SymbolicRegression: SRRegressor`  
(No need to install the "SymbolicRegression" library)
- Precomilation may fail if dependencies are not installed. Use `add "packageXX"` in Pkg mode to fix.
- Sample Code in `srflow_basictest.jl`
