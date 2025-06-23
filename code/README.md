# Numerical experiments
In this folder and its subfolders, all code to reproduce the numerical experiments in the paper is
located.  Furthermore, it also contains the raw data for the results reported in the paper.

## Set up Julia
Install Julia following the instructions at https://julialang.org/downloads/. We have used Julia
v1.11.5 for all our results.

To install all necessary Julia packages, execute the following statement from within the folder that
contains the `README.md` file you are currently reading:
```shell
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```
This will recreate the exact Julia environment we used to obtain our results for full
reproducibility.


## Run the experiments
To re-create the results, run one of the following commands.
Make sure the [`data/`](data) folder with all required input data is present.

*Note:* Running all scripts may take more than 30 hours, depending on your system.
Our tests were conducted on a single node with two AMD EPYC 7742 CPUs,
each of which has 64 cores, and with a clock speed of 2.25 GHz.


### Run all qualitative experiments
```bash
julia --project=. --threads=64 qualitative/run_all_create_data.jl
```

### Run all quantitative experiments
```bash
julia --project=. --threads=64 quantitative/run_all_create_data.jl
```

### Run multi-body experiment
```bash
julia --project=. --threads=64 multi_body_packing/aorta_joined.jl
```

### Run all experiments together
```bash
julia --project=. --threads=64 run_all_create_data.jl
```

### Run performance benchmarks
```bash
julia --project=. --threads=1 performance/run_benchmarks.jl
julia --project=. --threads=2 performance/run_benchmarks.jl
julia --project=. --threads=4 performance/run_benchmarks.jl
julia --project=. --threads=8 performance/run_benchmarks.jl
julia --project=. --threads=16 performance/run_benchmarks.jl
julia --project=. --threads=32 performance/run_benchmarks.jl
julia --project=. --threads=64 performance/run_benchmarks.jl
julia --project=. --threads=128 performance/run_benchmarks.jl
# Create and write the sampled geometries, signed distance field and other data
# (number of cells, mean face size etc.) from the performance benchmarks
julia --project=. --threads=8 performance/create_meta_data.jl
```

## Plot generation
To generate the plots after running the experiments, execute the following line:
```bash
julia --project=. run_all_plot.jl
```
All plots will be generated in the corresponding subfolder within the [`figures`](figures) directory.

## Results
The results we obtained from running the experiments on our machine can be found in the folder
[`out/`](out).
