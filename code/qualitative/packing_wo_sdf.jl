using JLD2
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "circle.asc"
file = joinpath(DATA_DIR, geometry_name)

particle_spacing = 0.1

maxiters = 45
save_fig = true

smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

h_factor = 0.8
smoothing_length = h_factor * particle_spacing
background_pressure = 1

trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              signed_distance_field=nothing,
              background_pressure=background_pressure,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=smoothing_length,
              pack_boundary=false,
              pp_cb_ekin=nothing,
              pp_density_error_cb=nothing,
              steady_state=nothing,
              maxiters=maxiters,
              particle_spacing=particle_spacing,
              save_intervals=false)

output_directory = joinpath(OUT_DIR, "circle")
mkpath(output_directory)

save(joinpath(output_directory,
              "packed_circle_wo_sdf.jld2"),
     Dict("geometry" => geometry,
          "shape_sampled" => shape_sampled,
          "packed_ic" => packed_ic))
