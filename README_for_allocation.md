# Change list of implementation of the allocation function
## Functions added
- **eval_loss_allocation**: aims to pass the partition parameter to eval_loss.
- **score_func_allocation**: generates partition and passes to eval_loss_allocation.

## Functions modified
- **score_func**: adds allocation judgement.
- **update_baseline_loss** : adds allocation judgement.
- **s_r_cycle**: in SingleIteration.jl, the main loop of the program. In it, I adds an allocation conditional statement. If yes, call eval_loss_allocation function. 
- **_eval_loss**: add allocation judgement and eval_probability judgement. if eval_probability, do not multiply total outflow. 

## Struct modified
- **Options** : The construction function is in Options.jl and the definition is in Optionstruct.jl. Atrributes allocation, eval_probability and adjmatrix are added. To upload adjmatrix, I implement a function in Options.jl, set_adjmatrix (Remember to import when using!).

## TODO
- Migrate the dataset processing codes to Julia (Maybe random data first).
- Debug.
