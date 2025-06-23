using OrdinaryDiffEq
using Plots
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "30P-30N.asc"
file = joinpath(DATA_DIR, "airfoil", geometry_name)

output_directory = joinpath(OUT_DIR, "airfoil", "30P-30N",
                            "kinetic_energy")

geometry = load_geometry(file)

length_airfoil = first(geometry.max_corner - geometry.min_corner)

ratios = [200, 300, 500, 800, 1000]

maxiters = 2050
smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

h_factor = 1.0
h_factor_interpolation = 1.0

background_pressure = 1

for with_boundary in [true, false], ratio in ratios
    particle_spacing = length_airfoil / ratio

    boundary_thickness = 8 * particle_spacing

    pp_cb_ekin = PostprocessCallback(; ekin=kinetic_energy, interval=1,
                                     output_directory=output_directory,
                                     filename="kinetic_energy_dp_$(ratio)_h_factor_$h_factor" *
                                              "_h_factor_interpolation_$h_factor_interpolation" *
                                              "_pb_$background_pressure" *
                                              (with_boundary ? "_boundary" : ""),
                                     write_file_interval=1)

    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=file,
                  tlsph=true,
                  maxiters=maxiters,
                  pp_cb_ekin=pp_cb_ekin,
                  output_directory=output_directory,
                  pp_density_error_cb=nothing,
                  pack_boundary=with_boundary,
                  time_integrator=RK4(),
                  boundary_thickness=boundary_thickness,
                  boundary_compress_factor=0.8,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=h_factor * particle_spacing,
                  smoothing_length_interpolation=h_factor_interpolation * particle_spacing,
                  steady_state=nothing,
                  background_pressure=background_pressure,
                  particle_spacing=particle_spacing,
                  save_intervals=false)
end
