include(joinpath("..", "auxiliary_functions.jl"))
using OrdinaryDiffEq

filename = "potato"
file = joinpath(DATA_DIR, filename * ".asc")

output_directory = joinpath(FIG_DIR, "potato")
mkpath(output_directory)

# ==========================================================================================
# ==== Resolution
particle_spacing = 0.08

boundary_thickness = 3 * particle_spacing

# ==========================================================================================
# ==== Load complex geometry
density = 1.0

geometry = load_geometry(file)

# Use a `SignedDistanceField` with `use_for_boundary_packing=false` for clarity.
# Otherwise, the plot becomes too cluttered for a large particle spacing.
signed_distance_field = SignedDistanceField(geometry, particle_spacing;
                                            max_signed_distance=boundary_thickness)

point_in_geometry_algorithm = WindingNumberJacobson(; geometry)

# Returns `InitialCondition`
shape_sampled = ComplexShape(geometry; particle_spacing, density,
                             point_in_geometry_algorithm)

# Create a separate `SignedDistanceField` for the boundary with `use_for_boundary_packing=true`,
# otherwise an error message will occur. Usually, the one generated above can also be used,
# but it was created with `use_for_boundary_packing=false` for visualization purposes.
boundary_sampled = sample_boundary(SignedDistanceField(geometry, particle_spacing,
                                                       use_for_boundary_packing=true,
                                                       max_signed_distance=boundary_thickness);
                                   boundary_density=density, boundary_thickness)

# ==========================================================================================
# ==== Plot
my_size = (700, 400)
my_linewidth = 4
my_linestyle = :dot
my_xlims = (0.0, 2.0) .+ (-1.1, 1.1) .* boundary_thickness
my_ylims = (-1.0, 0.0) .+ (-1.1, 1.1) .* boundary_thickness
my_tickfont = font(10)
my_guidefont = font(16)
my_legendfont = font(14)

boundary_color = "#ff7f00"
inner_color = "#009E73"

vertices = InitialCondition(; coordinates=stack(geometry.vertices),
                            density, particle_spacing=particle_spacing)
shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])
p0 = plot(shape, color=nothing, linewidth=my_linewidth, label=nothing, xlims=my_xlims,
          ylims=my_ylims)
plot!(vertices, color=:black, label=nothing, xlims=my_xlims,
      ylims=my_ylims)
xaxis!(p0, showaxis=false, grid=false, size=my_size)

# For plotting
dummy_ic = InitialCondition(; coordinates=stack(signed_distance_field.positions),
                            density, particle_spacing=particle_spacing)

p1 = plot(dummy_ic, zcolor=signed_distance_field.distances, label=nothing, cbar=nothing,
          #   clims=(-0.1, 0.2),
          color=COLORSCHEME, xlims=my_xlims, ylims=my_ylims)

plot!(p1, shape, color=nothing, linewidth=my_linewidth, linestyle=my_linestyle,
      label=nothing)
xaxis!(p1, showaxis=false, grid=false, size=my_size)

p2 = plot(shape_sampled, color=inner_color, label=nothing, xlims=my_xlims,
          ylims=my_ylims)
plot!(p2, shape, linewidth=my_linewidth, color=nothing, linestyle=my_linestyle,
      label=nothing)
xaxis!(p2, showaxis=false, grid=false, size=my_size)

p2_sub = plot(boundary_sampled, xlims=my_xlims, ylims=my_ylims,
              markerstrokewidth=[0 0], label=nothing, color=boundary_color)
plot!(p2_sub, shape, color=nothing, linewidth=my_linewidth, linestyle=my_linestyle,
      label=nothing)

xaxis!(p2_sub, showaxis=false, grid=false, size=my_size)

p3 = plot(shape_sampled, boundary_sampled, xlims=my_xlims, ylims=my_ylims,
          markerstrokewidth=[0 0], label=nothing,
          color=[inner_color boundary_color])
plot!(p3, shape, color=nothing, linewidth=my_linewidth, label=nothing,
      linestyle=my_linestyle)

xaxis!(p3, showaxis=false, grid=false, size=my_size)

# ==========================================================================================
# ==== Packing

# Large `background_pressure` can cause high accelerations. That is, the adaptive
# time-stepsize will be adjusted properly.
background_pressure = 1.0

smoothing_kernel = SchoenbergQuinticSplineKernel{ndims(geometry)}()
smoothing_length = 0.8 * particle_spacing

packing_system = ParticlePackingSystem(shape_sampled;
                                       smoothing_kernel=smoothing_kernel,
                                       smoothing_length=smoothing_length,
                                       smoothing_length_interpolation=smoothing_length,
                                       signed_distance_field, background_pressure)

# Create a separate `SignedDistanceField` for the boundary with `use_for_boundary_packing=true`,
# otherwise an error message will occur. Usually, the one generated above can also be used,
# but it was created with `use_for_boundary_packing=false` for visualization purposes.
boundary_system = ParticlePackingSystem(boundary_sampled;
                                        smoothing_kernel=smoothing_kernel,
                                        smoothing_length=smoothing_length,
                                        smoothing_length_interpolation=smoothing_length,
                                        boundary_compress_factor=0.7,
                                        is_boundary=true,
                                        signed_distance_field=SignedDistanceField(geometry,
                                                                                  particle_spacing,
                                                                                  use_for_boundary_packing=true,
                                                                                  max_signed_distance=boundary_thickness),
                                        background_pressure)

# ==========================================================================================
# ==== Simulation
semi = Semidiscretization(packing_system, boundary_system)

# Use a high `tspan` to guarantee that the simulation runs at least for `maxiters`
tspan = (0, 10000.0)
ode = semidiscretize(semi, tspan)

callbacks = CallbackSet(UpdateCallback())
maxiters = 4000
time_integrator = RDPK3SpFSAL35()

sol = solve(ode, time_integrator;
            abstol=1e-7, # Default abstol is 1e-6 (may need to be tuned to prevent boundary penetration)
            reltol=1e-4, # Default reltol is 1e-3 (may need to be tuned to prevent boundary penetration)
            save_everystep=false, maxiters=maxiters, callback=callbacks)

packed_ic = InitialCondition(sol, packing_system, semi)
packed_boundary_ic = InitialCondition(sol, boundary_system, semi)

p4 = plot(packed_ic, xlims=my_xlims, ylims=my_ylims,
          markerstrokewidth=[0 0],
          color=[inner_color boundary_color], label=nothing)
plot!(p4, shape, linewidth=my_linewidth, color=nothing, label=nothing,
      linestyle=my_linestyle)

xaxis!(p4, showaxis=false, grid=false, size=my_size)

p5 = plot(packed_ic, packed_boundary_ic, xlims=my_xlims, ylims=my_ylims,
          markerstrokewidth=[0 0],
          color=[inner_color boundary_color],
          label=nothing)
plot!(p5, shape, linewidth=my_linewidth, color=nothing, label=nothing,
      linestyle=my_linestyle)

xaxis!(p5, showaxis=false, grid=false, size=my_size)

p6 = plot(packed_ic, xlims=my_xlims, ylims=my_ylims,
          markerstrokewidth=[0 0],
          color=[inner_color boundary_color], label=nothing)

xaxis!(p6, showaxis=false, grid=false, size=my_size)

p7 = plot(shape_sampled, xlims=my_xlims, ylims=my_ylims,
          markerstrokewidth=[0 0],
          color=[inner_color boundary_color], label=nothing)

xaxis!(p7, showaxis=false, grid=false, size=my_size)

savefig(p0, joinpath(output_directory, "geometry.pdf"))
savefig(p1, joinpath(output_directory, "signed_distance_field.pdf"))
savefig(p2, joinpath(output_directory, "initial_point_grid.pdf"))
savefig(p2_sub, joinpath(output_directory, "initial_point_grid_boundary.pdf"))
savefig(p3, joinpath(output_directory, "initial_point_grid_inner_and_boundary.pdf"))
savefig(p4, joinpath(output_directory, "final_particle_distribution.pdf"))
savefig(p5, joinpath(output_directory, "final_particle_distribution_boundary.pdf"))

savefig(p6, joinpath(output_directory, "packed_particles.pdf"))
savefig(p7, joinpath(output_directory, "point_grid.pdf"))
