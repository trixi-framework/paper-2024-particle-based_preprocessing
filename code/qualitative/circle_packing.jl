# This script show the circle packed with and without boundary.
using JLD2
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "circle.asc"
file = joinpath(DATA_DIR, geometry_name)

particle_spacing = 0.1

tlsph = false
maxiters = 1000
save_fig = true

smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

for h_factor in [0.8, 1.2]
    smoothing_length = h_factor * particle_spacing
    background_pressure = 1

    output_directory = joinpath(OUT_DIR, "circle")
    mkpath(output_directory)

    pp_cb_ekin_1 = PostprocessCallback(; ekin=kinetic_energy, interval=1,
                                       output_directory=output_directory,
                                       filename="kinetic_energy_no_boundary_h_factor_$h_factor" *
                                                (tlsph ? "_tlsph" : ""),
                                       write_file_interval=1)

    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=file,
                  tlsph=tlsph,
                  background_pressure=background_pressure,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=smoothing_length,
                  smoothing_length_interpolation=smoothing_length,
                  pack_boundary=false,
                  steady_state=nothing,
                  pp_cb_ekin=pp_cb_ekin_1,
                  pp_density_error_cb=nothing,
                  maxiters=maxiters,
                  save_intervals=false,
                  particle_spacing=particle_spacing)

    packed_ic_no_boundary = deepcopy(packed_ic)

    pp_cb_ekin_2 = PostprocessCallback(; ekin=kinetic_energy, interval=1,
                                       output_directory=output_directory,
                                       filename="kinetic_energy_boundary_h_factor_$h_factor" *
                                                (tlsph ? "_tlsph" : ""),
                                       write_file_interval=1)

    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=file,
                  tlsph=tlsph,
                  pack_boundary=true,
                  boundary_thickness=8 * particle_spacing,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=smoothing_length,
                  smoothing_length_interpolation=smoothing_length,
                  boundary_compress_factor=0.8,
                  maxiters=maxiters,
                  steady_state=nothing,
                  pp_cb_ekin=pp_cb_ekin_2,
                  pp_density_error_cb=nothing,
                  background_pressure=background_pressure,
                  save_intervals=false,
                  particle_spacing=particle_spacing)

    packed_ic_boundary = deepcopy(packed_ic)

    save(joinpath(output_directory,
                  "packed_circle_h_factor_$h_factor" * (tlsph ? "_tlsph" : "") * ".jld2"),
         Dict("geometry" => geometry,
              "packed_ic_no_boundary" => packed_ic_no_boundary,
              "packed_ic_boundary" => packed_ic_boundary))
end
