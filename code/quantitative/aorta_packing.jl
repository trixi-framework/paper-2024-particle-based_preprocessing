using OrdinaryDiffEq
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "aorta.stl"
file = joinpath(DATA_DIR, "aorta", geometry_name)

output_directory_global = joinpath(OUT_DIR, "aorta", "packing")

particle_spacings = [0.04, 0.02, 0.01, 0.005, 0.0025] #, 0.00125]

tlsph = false
maxiters_ = [15000, 20000, 2000, 2000, 2000] #, 5000]
abstol = 1e-7
reltol = 1e-4

h_factor = 1.0
h_factor_interpolation = 1.0
smoothing_kernel = SchoenbergQuinticSplineKernel{3}()

background_pressure = 1.0

for (i, particle_spacing) in enumerate(particle_spacings)
    output_directory = joinpath(output_directory_global,
                                "dp_$(particle_spacing)_h_factor_$h_factor" *
                                "_h_factor_interpolation_$h_factor_interpolation" *
                                "_pb_$background_pressure" * (tlsph ? "_tlsph" : "") *
                                "_abstol_$abstol" * "_reltol_$reltol")

    boundary_thickness = 6 * particle_spacing
    smoothing_length_interpolation = h_factor_interpolation * particle_spacing

    # Run with boundary
    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=file, tspan=(0.0, 10000000.0),
                  tlsph=tlsph,
                  output_directory=output_directory,
                  steady_state=nothing,
                  pack_boundary=true,
                  abstol=abstol,
                  reltol=reltol,
                  boundary_thickness=boundary_thickness,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=h_factor * particle_spacing,
                  smoothing_length_interpolation=smoothing_length_interpolation,
                  maxiters=maxiters_[i],
                  boundary_compress_factor=0.8,
                  background_pressure=background_pressure,
                  particle_spacing=particle_spacing,
                  save_intervals=false)
end
