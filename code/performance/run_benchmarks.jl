include(joinpath(@__DIR__, "benchmarks.jl"))

geometry_names = "bunny_" .*
                 ["25k", "75k", "100k", "125k", "150k", "300k", "500k", "1000k", "1500k"]

output_names = ["load", "constr_hier", "sample", "sdf", "nhs"]

input_filenames = joinpath.("data", "bunny", geometry_names .* ".stl")

output_directory = joinpath("out", "performance", "benchmarks_bunny")

mkpath(output_directory)

function output_filenames(benchmark_name)
    joinpath(output_directory,
             benchmark_name * "_nthreads_$(Threads.nthreads()).json")
end

min_coord = 0.0
max_coord = 10.0

particle_layers_sdf = [3, 4, 5, 6]
n_particles_per_dimensions = [25, 50, 75, 100, 125, 150, 200, 250]

if Threads.nthreads() < 4
    n_particles_per_dimensions = n_particles_per_dimensions[1:4]
    input_filenames = input_filenames[1:6]
end

benchmark_load_geometry(input_filenames, output_filenames("load_geometry"))
benchmark_construct_hierarchy(input_filenames, output_filenames("constr_hier"))
benchmark_sample(input_filenames, n_particles_per_dimensions,
                 min_coord, max_coord, output_filenames("sample"))
benchmark_sdf(input_filenames, n_particles_per_dimensions, particle_layers_sdf,
              min_coord, max_coord, output_filenames("sdf"))
benchmark_initialize_face_nhs(input_filenames, n_particles_per_dimensions,
                              particle_layers_sdf, min_coord, max_coord,
                              output_filenames("initialize_nhs"))
benchmark_sdf_no_nhs(input_filenames[1:4], n_particles_per_dimensions[1:4],
                     min_coord, max_coord, output_filenames("sdf_no_nhs"))
