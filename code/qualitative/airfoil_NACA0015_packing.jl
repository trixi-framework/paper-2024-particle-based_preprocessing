using JLD2
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "NACA0015.asc"
file = joinpath(DATA_DIR, "airfoil", geometry_name)

particle_spacings = [0.05, 0.02, 0.01]

tlsph = false
maxiters = 500

smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

h_factor = 0.8

packed_ics = InitialCondition[]
shapes_sampled = InitialCondition[]

for particle_spacing in particle_spacings
    boundary_thickness = 5 * particle_spacing

    smoothing_length = h_factor * particle_spacing
    background_pressure = 1.0

    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=file,
                  tlsph=tlsph,
                  pack_boundary=true,
                  boundary_thickness=boundary_thickness,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=smoothing_length,
                  smoothing_length_interpolation=smoothing_length,
                  boundary_compress_factor=0.8,
                  background_pressure=background_pressure,
                  particle_spacing=particle_spacing,
                  maxiters=maxiters,
                  steady_state=nothing,
                  pp_cb_ekin=nothing,
                  pp_density_error_cb=nothing,
                  save_intervals=false)
    push!(packed_ics, deepcopy(packed_ic))
    push!(shapes_sampled, deepcopy(shape_sampled))
end

output_directory = joinpath(OUT_DIR, "airfoil", "NACA0015")
mkpath(output_directory)

save(joinpath(output_directory, "sampled_airfoil_NACA0015_different_resolutions.jld2"),
     Dict("geometry" => geometry,
          "shapes_sampled" => shapes_sampled,
          "packed_ics" => packed_ics))
