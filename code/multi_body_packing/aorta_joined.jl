using OrdinaryDiffEq
include(joinpath("..", "auxiliary_functions.jl"))

geometry_names = [
    "aorta_joined.stl",
    "aorta.stl",
    "inflow_region.stl",
    "outlet_left_carotid.stl",
    "outlet_left_subclavian.stl",
    "outlet_right_carotid.stl",
    "outlet_thoracic.stl"
]

files = joinpath.(DATA_DIR, "aorta", geometry_names)

# ==========================================================================================
# ==== Packing parameters
tlsph = false
pack_boundary = true

h_factor = 1.0
h_factor_interpolation = 1.0
smoothing_kernel = SchoenbergQuinticSplineKernel{3}()

background_pressure = 1.0

# ==========================================================================================
# ==== Load complex geometry
density = 1.0

geometries = load_geometry.(files)

# ==========================================================================================
# ==== Resolution
particle_spacings = [0.01, 0.005, 0.0025]
maxiters_ = [1821, 1269, 1238]
abstol = 1e-7
reltol = 1e-4

for (i, particle_spacing) in enumerate(particle_spacings)
    output_directory = joinpath(OUT_DIR, "multi_body_packing",
                                "aorta_joined",
                                "dp_$(particle_spacing)" *
                                (tlsph ? "_tlsph" : ""))

    boundary_thickness = 8 * particle_spacing
    smoothing_length_interpolation = h_factor_interpolation * particle_spacing

    # Run with boundary
    trixi_include(joinpath(CODE_DIR, "example_particle_packing.jl"),
                  file=first(files), tspan=(0.0, 10000000.0),
                  tlsph=tlsph,
                  output_directory=output_directory,
                  steady_state=nothing,
                  pp_density_error_cb=nothing,
                  pp_cb_ekin=nothing,
                  pack_boundary=true,
                  abstol=abstol,
                  reltol=reltol,
                  boundary_compress_factor=0.8,
                  boundary_thickness=boundary_thickness,
                  smoothing_kernel=smoothing_kernel,
                  smoothing_length=h_factor * particle_spacing,
                  smoothing_length_interpolation=smoothing_length_interpolation,
                  maxiters=maxiters_[i],
                  background_pressure=background_pressure,
                  particle_spacing=particle_spacing,
                  save_intervals=false)

    v_ode, u_ode = sol.u[end].x

    # Write summation density in `packed_ic`
    u = TrixiParticles.wrap_u(u_ode, packing_system, semi)
    TrixiParticles.summation_density!(packing_system, semi, u, u_ode, packed_ic.density)

    trixi2vtk(shape_sampled,
              output_directory=output_directory,
              filename="sampled_" * first(first.(splitext.(geometry_names))))

    trixi2vtk(packed_ic,
              output_directory=output_directory,
              filename="packed_" * first(first.(splitext.(geometry_names))),
              signed_distance=packing_system.signed_distances)

    # Write summation density in `packed_boundary_ic`
    u_bnd = TrixiParticles.wrap_u(u_ode, boundary_system, semi)
    TrixiParticles.summation_density!(boundary_system, semi, u_bnd, u_ode,
                                      packed_boundary_ic.density)

    trixi2vtk(boundary_sampled,
              output_directory=output_directory,
              filename="sampled_" * first(first.(splitext.(geometry_names))) * "_boundary")

    trixi2vtk(packed_boundary_ic,
              output_directory=output_directory,
              filename="packed_" * first(first.(splitext.(geometry_names))) * "_boundary",
              signed_distance=boundary_system.signed_distances)

    # Extract the other `InitialCondition`s
    for (i, geometry) in enumerate(geometries)
        i == 1 && continue
        ic = intersect(packed_ic, geometry)

        trixi2vtk(ic,
                  output_directory=output_directory,
                  filename="packed_" * first.(splitext.(geometry_names))[i],
                  signed_distance=packing_system.signed_distances)
    end
end
