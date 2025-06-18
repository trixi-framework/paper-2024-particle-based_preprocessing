using TrixiParticles
using OrdinaryDiffEq

filename = "circle"
file = joinpath(@__DIR__, "..", "data", filename * ".asc")

# ==========================================================================================
# ==== Packing parameters
save_intervals = false
tlsph = false
pack_boundary = true

# ==========================================================================================
# ==== Resolution
particle_spacing = 0.03

# The following depends on the sampling of the particles. In this case `boundary_thickness`
# means literally the thickness of the boundary packed with boundary particles and *not*
# how many rows of boundary particles will be sampled.
boundary_thickness = 8 * particle_spacing

# ==========================================================================================
# ==== Load complex geometry
density = 1.0

geometry = load_geometry(file)

signed_distance_field = SignedDistanceField(geometry, particle_spacing;
                                            use_for_boundary_packing=true,
                                            max_signed_distance=boundary_thickness)

point_in_geometry_algorithm = WindingNumberJacobson(; geometry,
                                                    winding_number_factor=sqrt(eps()),
                                                    hierarchical_winding=true)
# Returns `InitialCondition`
shape_sampled = ComplexShape(geometry; particle_spacing, density, grid_offset=0.0,
                             max_nparticles=10^10,
                             point_in_geometry_algorithm)

shape_sampled.mass .= density * TrixiParticles.volume(geometry) /
                      nparticles(shape_sampled)

if pack_boundary
    # Returns `InitialCondition`
    boundary_sampled = sample_boundary(signed_distance_field; boundary_density=density,
                                       boundary_thickness, tlsph)
end

# ==========================================================================================
# ==== Packing

# Large `background_pressure` can cause high accelerations. That is, the adaptive
# time-stepsize will be adjusted properly.
background_pressure = 1.0

smoothing_kernel = SchoenbergQuinticSplineKernel{ndims(geometry)}()
smoothing_length = 1.0 * particle_spacing

packing_system = ParticlePackingSystem(shape_sampled;
                                       smoothing_kernel=smoothing_kernel,
                                       smoothing_length=smoothing_length,
                                       smoothing_length_interpolation=smoothing_length,
                                       signed_distance_field, tlsph=tlsph,
                                       background_pressure)
if pack_boundary
    boundary_system = ParticlePackingSystem(boundary_sampled;
                                            smoothing_kernel=smoothing_kernel,
                                            smoothing_length=smoothing_length,
                                            smoothing_length_interpolation=smoothing_length,
                                            boundary_compress_factor=1.0,
                                            is_boundary=true, signed_distance_field,
                                            tlsph=tlsph, background_pressure)
end

# ==========================================================================================
# ==== Simulation
semi = pack_boundary ? Semidiscretization(packing_system, boundary_system) :
       Semidiscretization(packing_system)

# Use a high `tspan` to guarantee that the simulation runs at least for `maxiters`
tspan = (0, 10000.0)
ode = semidiscretize(semi, tspan)

output_directory = joinpath(OUT_DIR, "example")

# Use this callback to stop the simulation when it is sufficiently close to a steady state
steady_state = SteadyStateReachedCallback(; interval=10, interval_size=10,
                                          abstol=1.0e-5, reltol=1.0e-3)

info_callback = InfoCallback(interval=50)

saving_callback = save_intervals ?
                  SolutionSavingCallback(interval=10, prefix="", ekin=kinetic_energy,
                                         output_directory=output_directory) :
                  nothing

function l_2(system, v_ode, u_ode, semi, t)
    u = TrixiParticles.wrap_u(u_ode, system, semi)

    density = zeros(nparticles(system))
    TrixiParticles.summation_density!(system, semi, u, u_ode, density)

    return sqrt(sum((density - system.initial_condition.density) .^ 2) /
                nparticles(system))
end

function l_inf(system, v_ode, u_ode, semi, t)
    u = TrixiParticles.wrap_u(u_ode, system, semi)

    density = zeros(nparticles(system))
    TrixiParticles.summation_density!(system, semi, u, u_ode, density)

    return maximum(abs.(density - system.initial_condition.density))
end

pp_density_error_cb = PostprocessCallback(; l_2=l_2, l_inf=l_inf,
                                          interval=1, output_directory=output_directory,
                                          filename="density_error", write_file_interval=50)

pp_cb_ekin = PostprocessCallback(; ekin=kinetic_energy,
                                 interval=1, output_directory=output_directory,
                                 filename="kinetic_energy", write_file_interval=50)

callbacks = CallbackSet(UpdateCallback(), saving_callback, info_callback, steady_state,
                        pp_cb_ekin, pp_density_error_cb)
maxiters = 1000
time_integrator = RDPK3SpFSAL35()

sol = solve(ode, time_integrator;
            abstol=1e-6, # Default abstol is 1e-6
            reltol=1e-3, # Default reltol is 1e-3
            save_everystep=false, maxiters=maxiters, callback=callbacks)

packed_ic = InitialCondition(sol, packing_system, semi)
packed_boundary_ic = pack_boundary ? InitialCondition(sol, boundary_system, semi) : nothing
