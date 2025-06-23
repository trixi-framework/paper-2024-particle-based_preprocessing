include(joinpath("..", "auxiliary_functions.jl"))

particle_spacing = 0.01

geometry_name = "aorta_corrupted.stl"
file = joinpath(DATA_DIR, "aorta", geometry_name)

geometry = load_geometry(file)

for winding_number_factor in [0.2, 0.4]
    point_in_geometry_algorithm = WindingNumberJacobson(; geometry,
                                                        winding_number_factor,
                                                        hierarchical_winding=true)
    shape_sampled = ComplexShape(geometry; particle_spacing, density=1.0,
                                 point_in_geometry_algorithm)

    trixi2vtk(shape_sampled,
              output_directory=joinpath(OUT_DIR, "aorta", "aorta_corrputed"),
              filename="initial_condition_$(winding_number_factor).vtu")
end
