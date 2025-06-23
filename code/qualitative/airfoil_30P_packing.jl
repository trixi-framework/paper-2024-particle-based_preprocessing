# This script shows the comparison of different initial configurations.
using JLD2
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "30P-30N.asc"
file = joinpath(DATA_DIR, "airfoil", geometry_name)

particle_spacing = 0.002
boundary_thickness = 5 * particle_spacing

maxiters = 500
save_fig = true

smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

h_factor = 0.8
smoothing_length = h_factor * particle_spacing
background_pressure = 1

# ==========================================================================================
# ==== First configuration: detached particles
grid_offset = particle_spacing / 6

# `tlsph = true`
trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              tlsph=true,
              grid_offset=grid_offset,
              pack_boundary=true,
              boundary_thickness=boundary_thickness,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=smoothing_length,
              smoothing_length_interpolation=smoothing_length,
              maxiters=maxiters,
              steady_state=nothing,
              background_pressure=background_pressure,
              particle_spacing=particle_spacing,
              save_intervals=false)

packed_ic_tlsph_config_1 = deepcopy(packed_ic)
shape_sampled_config_1 = deepcopy(shape_sampled)

# `tlsph = false`
trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              tlsph=false,
              grid_offset=grid_offset,
              pack_boundary=true,
              boundary_thickness=boundary_thickness,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=smoothing_length,
              smoothing_length_interpolation=smoothing_length,
              maxiters=maxiters,
              steady_state=nothing,
              background_pressure=background_pressure,
              particle_spacing=particle_spacing,
              save_intervals=false)

packed_ic_config_1 = deepcopy(packed_ic)

# ==========================================================================================
# ==== Second configuration
grid_offset = particle_spacing / 1.1

# `tlsph = true`
trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              tlsph=true,
              grid_offset=grid_offset,
              pack_boundary=true,
              boundary_thickness=boundary_thickness,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=smoothing_length,
              smoothing_length_interpolation=smoothing_length,
              maxiters=maxiters,
              steady_state=nothing,
              background_pressure=background_pressure,
              particle_spacing=particle_spacing,
              save_intervals=false)

packed_ic_tlsph_config_2 = deepcopy(packed_ic)
shape_sampled_config_2 = deepcopy(shape_sampled)

# `tlsph = false`
trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              tlsph=false,
              grid_offset=grid_offset,
              pack_boundary=true,
              boundary_thickness=boundary_thickness,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=smoothing_length,
              smoothing_length_interpolation=smoothing_length,
              maxiters=maxiters,
              steady_state=nothing,
              pp_cb_ekin=nothing,
              pp_density_error_cb=nothing,
              background_pressure=background_pressure,
              particle_spacing=particle_spacing,
              save_intervals=false)

packed_ic_config_2 = deepcopy(packed_ic)

output_directory = joinpath(OUT_DIR, "airfoil", "30P-30N")
mkpath(output_directory)

save(joinpath(output_directory, "packing_different_configurations.jld2"),
     Dict("geometry" => geometry,
          "packed_ic_tlsph_config_1" => packed_ic_tlsph_config_1,
          "packed_ic_config_1" => packed_ic_config_1,
          "packed_ic_tlsph_config_2" => packed_ic_tlsph_config_2,
          "packed_ic_config_2" => packed_ic_config_2,
          "shape_sampled_config_1" => shape_sampled_config_1,
          "shape_sampled_config_2" => shape_sampled_config_2))
