using JLD2
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "30P-30N.asc"
file = joinpath(DATA_DIR, "airfoil", geometry_name)

particle_spacings = [0.002, 0.001, 0.0005]
packed_ics = InitialCondition[]

maxiters = 500
save_fig = true

h_factor = 0.8
h_factor_interpolation = 0.8

for particle_spacing in particle_spacings
    boundary_thickness = 4 * particle_spacing

    smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

    smoothing_length = h_factor * particle_spacing

    grid_offset = 0.0

    background_pressure = 1

    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=file,
                  tlsph=false,
                  grid_offset=grid_offset,
                  pack_boundary=true,
                  boundary_thickness=boundary_thickness,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=h_factor * particle_spacing,
                  smoothing_length_interpolation=h_factor_interpolation * particle_spacing,
                  maxiters=maxiters,
                  steady_state=nothing,
                  pp_cb_ekin=nothing,
                  pp_density_error_cb=nothing,
                  background_pressure=background_pressure,
                  particle_spacing=particle_spacing,
                  save_intervals=false)
    push!(packed_ics, packed_ic)
end

reverse!(packed_ics)

output_directory = joinpath(OUT_DIR, "airfoil", "30P-30N")
mkpath(output_directory)

save(joinpath(output_directory, "sampled_airfoil_30P_different_resolutions.jld2"),
     Dict("geometry" => geometry, "packed_ics" => packed_ics))
