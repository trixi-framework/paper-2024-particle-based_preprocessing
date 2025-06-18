# This script saves the neighboring faces of a given cell.
include(joinpath("..", "auxiliary_functions.jl"))

geometry_name = "bunny.stl"
file = joinpath(DATA_DIR, "bunny", geometry_name)

output_directory = joinpath(OUT_DIR, "signed_distance_field")
mkpath(output_directory)

particle_spacing = 10 / 100
boundary_thickness = 4 * particle_spacing

geometry = load_geometry(file)

signed_distance_field = SignedDistanceField(geometry, particle_spacing;
                                            max_signed_distance=boundary_thickness)

nhs = TrixiParticles.FaceNeighborhoodSearch{3}(; search_radius=boundary_thickness)
TrixiParticles.initialize!(nhs, geometry)

position_1 = [4.7, 1.3, 4.85]
position_2 = [0.28, 2.57, 6.97]

cell_1 = TrixiParticles.PointNeighbors.cell_coords(position_1, nhs)
cell_2 = TrixiParticles.PointNeighbors.cell_coords(position_2, nhs)
points_in_cell = Int[]

for point in eachindex(signed_distance_field.positions)
    point_coords = signed_distance_field.positions[point]
    if cell_1 ==
       TrixiParticles.PointNeighbors.cell_coords(point_coords, nhs)
        push!(points_in_cell, point)
    end
    if cell_2 ==
       TrixiParticles.PointNeighbors.cell_coords(point_coords, nhs)
        push!(points_in_cell, point)
    end
end

face_ids = vcat(nhs.neighbors[cell_1], nhs.neighbors[cell_2])

save_stl(joinpath(output_directory, "neighboring_faces.stl"), geometry; faces=face_ids)
save_stl(joinpath(output_directory, "rest_faces.stl"), geometry;
         faces=setdiff(TrixiParticles.eachface(geometry), face_ids))

coords = stack(signed_distance_field.positions[points_in_cell])
trixi2vtk(coords; filename="distances_in_cell", output_directory=output_directory,
          distances=signed_distance_field.distances[points_in_cell])
