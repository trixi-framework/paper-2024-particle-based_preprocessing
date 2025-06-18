using BenchmarkTools
include(joinpath("..", "..", "auxiliary_functions.jl"))

data_dir = joinpath(OUT_DIR, "performance", "benchmarks_bunny")

# Vector of benchmark parameters:
nthreads_vec = [1, 2, 4, 8, 16, 32, 64, 128]
nfaces_vec = [24776, 74576, 99300, 124736, 149828, 299504, 498764, 1007748, 1486152]
nparticles_vec = [25, 50, 75, 100, 125, 150, 200, 250] .^ 3
spacings_vec = 10.0 ./ nparticles_vec .^ (1 / 3)
nlayers_vec = [3, 4, 5, 6]

# [nthreads, nfaces, nparticles, nlayers]
lengths = length.([nthreads_vec, nfaces_vec, nparticles_vec, nlayers_vec])

# ==== Load geometry:
# times = [nthreads, nfaces]
t_load = NaN * ones(lengths[1], lengths[2])

# ==== Construct hierarchy:
# times = [nthreads, nfaces]
t_hier = NaN * ones(lengths[1], lengths[2])

# ==== Sample geometry:
# times = [nthreads, nfaces, nparticles]
t_sample = NaN * ones(lengths[1], lengths[2], lengths[3])

# ==== Create signed distance field:
# times = [nthreads, nfaces, spacings, nlayers]
t_sdf = NaN * ones(lengths[1], lengths[2], lengths[3], lengths[4])

t_sdf_no_nhs = NaN * ones(lengths[1], lengths[2], lengths[3])

# Fill benchmark time arrays:
for (i, nthreads) in enumerate(nthreads_vec)
    benchmark_load = BenchmarkTools.load(data_dir *
                                         "/load_geometry_nthreads_$nthreads.json")[1]
    benchmark_hier = BenchmarkTools.load(data_dir *
                                         "/constr_hier_nthreads_$nthreads.json")[1]
    benchmark_sample = BenchmarkTools.load(data_dir *
                                           "/sample_nthreads_$nthreads.json")[1]
    benchmark_sdf = BenchmarkTools.load(data_dir *
                                        "/sdf_nthreads_$nthreads.json")[1]
    benchmark_sdf_no_nhs = BenchmarkTools.load(data_dir *
                                               "/sdf_no_nhs_nthreads_$nthreads.json")[1]

    for (j, nfaces) in enumerate(nfaces_vec)
        key_1 = "n_faces: $(nfaces)"

        # Load geometry
        if haskey(benchmark_load, key_1)
            t_load[i, j] = minimum(benchmark_load[key_1]).time
        end

        # Construct hierarchy
        if haskey(benchmark_hier, key_1)
            t_hier[i, j] = minimum(benchmark_hier[key_1]).time
        end

        for (k, nparticles) in enumerate(nparticles_vec)
            key_2 = "n_particles: $(nparticles)"

            # Sample geometry
            if haskey(benchmark_sample, key_1) && haskey(benchmark_sample[key_1], key_2)
                t_sample[i, j, k] = minimum(benchmark_sample[key_1][key_2]).time
            end

            # Create signed distance field
            if haskey(benchmark_sdf, key_1) && haskey(benchmark_sdf[key_1], key_2)
                for (l, nlayers) in enumerate(nlayers_vec)
                    key_3 = "particle layers: $(nlayers)"
                    if haskey(benchmark_sdf[key_1][key_2], key_3)
                        t_sdf[i, j, k, l] = minimum(benchmark_sdf[key_1][key_2][key_3]).time
                    end
                end
            end

            # Create signed distance field without neighborhood search
            if haskey(benchmark_sdf_no_nhs, key_1) &&
               haskey(benchmark_sdf_no_nhs[key_1]["signed distance field"], key_2)
                t_sdf_no_nhs[i, j, k] = minimum(benchmark_sdf_no_nhs[key_1]["signed distance field"][key_2]).time
            end
        end
    end
end

# Convert to seconds
t_load .*= 1e-9
t_hier .*= 1e-9
t_sample .*= 1e-9
t_sdf .*= 1e-9
t_sdf_no_nhs .*= 1e-9

ratio_load = zeros(lengths[1], lengths[2], lengths[3], lengths[4])
ratio_hier = zeros(lengths[1], lengths[2], lengths[3], lengths[4])
ratio_sample = zeros(lengths[1], lengths[2], lengths[3], lengths[4])
ratio_sdf = zeros(lengths[1], lengths[2], lengths[3], lengths[4])

for i in eachindex(nthreads_vec), j in eachindex(nfaces_vec),
    k in eachindex(nparticles_vec), l in eachindex(nlayers_vec)

    sum_times = t_load[i, j] + t_hier[i, j] + t_sample[i, j, k] + t_sdf[i, j, k, l]

    ratio_load[i, j, k, l] = t_load[i, j] / sum_times
    ratio_hier[i, j, k, l] = t_hier[i, j] / sum_times
    ratio_sample[i, j, k, l] = t_sample[i, j, k] / sum_times
    ratio_sdf[i, j, k, l] = t_sdf[i, j, k, l] / sum_times
end

ratios = Dict(
    "load geometry" => ratio_load,
    "construct hierarchy" => ratio_hier,
    "sample geometry" => ratio_sample,
    "create sdf" => ratio_sdf
)
