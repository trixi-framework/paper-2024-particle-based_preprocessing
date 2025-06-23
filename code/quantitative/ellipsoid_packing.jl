using OrdinaryDiffEq
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "ellipsoid.stl"
file = joinpath(DATA_DIR, geometry_name)
output_directory_global = joinpath(OUT_DIR, "ellipsoid")

particle_spacing = 0.1

atols = [1e-4, 5e-5, 2e-5, 1e-5, 5e-6, 2e-6, 1e-6, 5e-7]

tlsph = false
maxiters = 5000

h_factor = 1.0
h_factor_interpolation = 1.0
smoothing_kernel = SchoenbergQuinticSplineKernel{3}()

background_pressure = 1.0

for time_integrator in [RDPK3SpFSAL35()], atol in atols
    output_directory = joinpath(output_directory_global,
                                "atol_$atol",
                                "dp_$(particle_spacing)_h_factor_$h_factor" *
                                "_h_factor_interpolation_$h_factor_interpolation" *
                                "_pb_$background_pressure" *
                                (tlsph ? "_tlsph" : "") *
                                "_$(nameof(typeof(time_integrator)))")

    boundary_thickness = 5 * particle_spacing
    smoothing_length_interpolation = h_factor_interpolation * particle_spacing

    # Run with boundary
    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=file, tspan=(0.0, 10000000.0),
                  tlsph=tlsph,
                  steady_state=nothing,
                  pack_boundary=true,
                  info_callback=InfoCallback(interval=200),
                  output_directory=output_directory,
                  abstol=atol,
                  time_integrator=time_integrator,
                  boundary_thickness=boundary_thickness,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=h_factor * particle_spacing,
                  smoothing_length_interpolation=smoothing_length_interpolation,
                  maxiters=maxiters,
                  boundary_compress_factor=0.8,
                  background_pressure=background_pressure,
                  particle_spacing=particle_spacing,
                  save_intervals=false)
end
