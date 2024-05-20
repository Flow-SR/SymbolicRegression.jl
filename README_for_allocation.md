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

## Project Configuration 
One of the Julia's Pros is that it affiliates the environment to the projects and the users do not need to install environments mannually. The instruction of configure the project environment is as follows:

在 Julia 中创建项目涉及到设置一个独立的环境，这包括项目所需的所有包和特定的包版本。这样可以确保项目的可复现性。Julia 使用内置的包管理器来处理这些任务。下面是创建 Julia 项目的步骤：

### 1. 安装 Julia
首先，确保你已经安装了 Julia。如果未安装，可以从 [Julia 官方网站](https://julialang.org/downloads/) 下载并安装适合你操作系统的版本。

### 2. 启动 Julia
打开 Julia 的命令行界面（REPL），通常可以通过在终端中输入 `julia` 来启动。

### 3. 创建新项目
在 Julia 的命令行界面中，你可以使用包管理器 (`Pkg`) 来创建一个新项目。以下是具体的命令：

```julia
using Pkg
Pkg.activate("path/to/new/project")
Pkg.add("PackageName")  # 添加你需要的任何包
```
> ! Attention: 有时只有在安装包之后才会成功建立环境.

这里的 `Pkg.activate` 创建并激活了一个新的项目环境。你可以通过指定路径来创建项目在特定位置，如果不指定路径，默认在当前目录。如果你设置了 `shared=true`，这个环境会被保存在全局环境目录中，方便其他项目共享使用。

### 4. 添加依赖
在你的项目环境中，使用 `Pkg.add("PackageName")` 添加你需要的包。你可以一次添加多个包。

### 5. 开发你的项目
现在你可以开始编写代码了。你的项目文件（如 `.jl` 脚本）应该放在项目目录下。由于环境已经激活，你运行的任何 Julia 代码都将使用该环境中指定的包版本。

### 6. 保存和恢复环境
你的项目环境信息会被保存在 `Project.toml` 和 `Manifest.toml` 文件中。这两个文件定义了项目所需的包及其版本，确保了项目的可移植性和可复现性。

- **`Project.toml`** 包含了包的依赖列表和版本。
- **`Manifest.toml`** 包含了所有依赖的精确版本和源信息，这有助于完全复现环境。

当你需要在其他系统或目录中复现项目环境时，只需将这两个文件复制到新项目目录，并在该目录下运行 `Pkg.activate(".")` 和 `Pkg.instantiate()`。

这些步骤概述了在 Julia 中创建和管理项目的基本流程。通过这种方式，你可以确保你的开发环境是独立和可控的，便于管理和分享。

### Install custom packages as a Local Package
考虑将您的代码作为一个本地开发包进行安装。在Julia中，您可以使用以下命令来实现：
```julia
using Pkg
Pkg.develop(path="path/to/your/lib")
```
这将把您的包添加到当前环境的Manifest文件中，并处理所有必要的依赖和预编译步骤。 

