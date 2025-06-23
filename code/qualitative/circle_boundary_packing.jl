using JLD2
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "circle.asc"
file = joinpath(DATA_DIR, geometry_name)

particle_spacing = 0.1

smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

h_factor = 0.8
smoothing_length = h_factor * particle_spacing
background_pressure = 1e6 * particle_spacing^ndims(smoothing_kernel)

boundary_thickness = 4 * particle_spacing

trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              tlsph=false,
              background_pressure=background_pressure,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=smoothing_length,
              smoothing_length_interpolation=smoothing_length,
              pack_boundary=true,
              boundary_thickness=boundary_thickness,
              boundary_compress_factor=0.8,
              particle_spacing=particle_spacing,
              pp_cb_ekin=nothing,
              steady_state=nothing,
              pp_density_error_cb=nothing,
              save_intervals=false)

output_directory = joinpath(OUT_DIR, "circle")
mkpath(output_directory)

save(joinpath(output_directory, "circle_boundary_packing.jld2"),
     Dict("geometry" => geometry,
          "shape_sampled" => shape_sampled,
          "boundary_sampled" => boundary_sampled,
          "packed_ic" => packed_ic,
          "packed_boundary_ic" => packed_boundary_ic))

trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              tlsph=true,
              output_directory=output_directory,
              background_pressure=background_pressure,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=smoothing_length,
              smoothing_length_interpolation=smoothing_length,
              pack_boundary=true,
              boundary_thickness=boundary_thickness,
              boundary_compress_factor=0.8,
              particle_spacing=particle_spacing,
              pp_cb_ekin=nothing,
              steady_state=nothing,
              pp_density_error_cb=nothing,
              save_intervals=false)

save(joinpath(output_directory, "circle_boundary_packing_tlsph.jld2"),
     Dict("geometry" => geometry,
          "shape_sampled" => shape_sampled,
          "boundary_sampled" => boundary_sampled,
          "packed_ic" => packed_ic,
          "packed_boundary_ic" => packed_boundary_ic))

# smoothing_length = 1.2 * particle_spacing
trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
              file=file,
              tlsph=false,
              output_directory=output_directory,
              background_pressure=background_pressure,
              smoothing_kernel=smoothing_kernel,
              smoothing_length=1.2 * particle_spacing,
              smoothing_length_interpolation=1.2 * particle_spacing,
              pack_boundary=true,
              boundary_thickness=boundary_thickness,
              boundary_compress_factor=0.6,
              particle_spacing=particle_spacing,
              pp_cb_ekin=nothing,
              steady_state=nothing,
              pp_density_error_cb=nothing,
              save_intervals=false)

save(joinpath(output_directory, "circle_boundary_packing_h_1.2.jld2"),
     Dict("geometry" => geometry,
          "shape_sampled" => shape_sampled,
          "boundary_sampled" => boundary_sampled,
          "packed_ic" => packed_ic,
          "packed_boundary_ic" => packed_boundary_ic))
