# This script writes the sampled geometry and the signed distance field from the performance
# benchmarks to `out/geometries_sampled`.
# It also writes meta data (number of cells, mean face size etc.) to `out/performance/`.
using TrixiParticles

function performance_benchmarks_create_data(geometry_names, files,
                                            n_particles_per_dimensions, particle_layers_sdf,
                                            output_dir, min_coord, max_coord)

    # Initialize data arrays
    lengths = length.([geometry_names, n_particles_per_dimensions, particle_layers_sdf])

    mean_face_size_vec = zeros(lengths[1])
    nparticles_sampled_vec = zeros(Int, lengths[1], lengths[2])
    nparticles_sdf_vec = zeros(Int, lengths[1], lengths[2], lengths[3])
    ncells_nhs = zero(nparticles_sdf_vec)
    max_nfaces_per_cell_nhs = zero(nparticles_sdf_vec)
    min_nfaces_per_cell_nhs = zero(nparticles_sdf_vec)
    mean_nfaces_per_cell_nhs = zeros(lengths[1], lengths[2], lengths[3])

    for (i, geometry_name) in enumerate(geometry_names)
        @info "load geometry: " * geometry_name

        geometry = load_geometry(files[i])

        mean_face_size = sum(TrixiParticles.eachface(geometry)) do face
            bbox_size(face, geometry)
        end / TrixiParticles.nfaces(geometry)

        mean_face_size_vec[i] = mean_face_size

        for (j, n_particles_per_dimension) in enumerate(n_particles_per_dimensions)
            @info "         #particles per dimension: " * string(n_particles_per_dimension)

            particle_spacing = (max_coord - min_coord) ./ n_particles_per_dimension
            n_particles = n_particles_per_dimension^3

            for (k, particle_layers) in enumerate(particle_layers_sdf)
                max_signed_distance = particle_layers * particle_spacing

                nhs = TrixiParticles.FaceNeighborhoodSearch{ndims(geometry)}(search_radius=max_signed_distance)
                TrixiParticles.initialize!(nhs, geometry)

                ncells_nhs[i, j, k] = length(nhs.neighbors.hashtable)

                mean_nfaces_per_cell_nhs[i, j, k] = sum(keys(nhs.neighbors.hashtable)) do key
                    length(nhs.neighbors[key])
                end / ncells_nhs[i, j, k]

                max_nfaces_per_cell_nhs[i, j, k] = maximum(values(nhs.neighbors.hashtable)) do cell
                    length(cell)
                end

                min_nfaces_per_cell_nhs[i, j, k] = minimum(values(nhs.neighbors.hashtable)) do cell
                    length(cell)
                end

                signed_distance_field = SignedDistanceField(geometry, particle_spacing;
                                                            max_signed_distance)

                nparticles_sdf_vec[i, j, k] = length(signed_distance_field.positions)

                # Write out signed distance field
                trixi2vtk(signed_distance_field,
                          output_directory=joinpath("out", "geometries_sampled",
                                                    geometry_name),
                          filename="sdf_n_particles_$(n_particles)_layers_$particle_layers")
            end

            point_in_geometry_algorithm = WindingNumberJacobson(; geometry)

            grid = TrixiParticles.rectangular_shape_coords(particle_spacing,
                                                           (n_particles_per_dimension,
                                                            n_particles_per_dimension,
                                                            n_particles_per_dimension),
                                                           (min_coord, min_coord,
                                                            min_coord))
            grid = reinterpret(reshape, SVector{ndims(geometry), eltype(geometry)}, grid)

            inpoly, _ = point_in_geometry_algorithm(geometry, grid)

            nparticles_sampled_vec[i, j] = sum(inpoly)

            # Write out sampled geometry
            trixi2vtk(stack(grid[inpoly]),
                      output_directory=joinpath("out", "geometries_sampled", geometry_name),
                      filename="coords_n_particles_$(n_particles)")
        end
    end

    # Write out meta data
    for (i, geometry_name) in enumerate(geometry_names)
        df = TrixiParticles.DataFrame(nparticles_per_dimension=n_particles_per_dimensions)

        df[!, "particle spacing"] = (max_coord - min_coord) ./ n_particles_per_dimensions
        df[!, "#particles"] = n_particles_per_dimensions .^ 3

        df[!, "mean face size"] = fill(mean_face_size_vec[i], lengths[2])

        df[!, "#particles sampled"] = nparticles_sampled_vec[i, :]

        for (k, particle_layers) in enumerate(particle_layers_sdf)
            col_name_1 = "#particles sdf (#layers $particle_layers)"
            df[!, col_name_1] = nparticles_sdf_vec[i, :, k]

            col_name_2 = "nhs: #cells (#layers $particle_layers)"
            df[!, col_name_2] = ncells_nhs[i, :, k]

            col_name_3 = "nhs: max #faces per cell (#layers $particle_layers)"
            df[!, col_name_3] = max_nfaces_per_cell_nhs[i, :, k]

            col_name_4 = "nhs: min #faces per cell (#layers $particle_layers)"
            df[!, col_name_4] = min_nfaces_per_cell_nhs[i, :, k]

            col_name_5 = "nhs: mean #faces per cell (#layers $particle_layers)"
            df[!, col_name_5] = mean_nfaces_per_cell_nhs[i, :, k]
        end

        isdir(output_dir) || mkdir(output_dir)

        TrixiParticles.CSV.write(joinpath(output_dir, geometry_name * "_meta_data.csv"), df)
    end

    return nothing
end

geometry_names = "bunny_" .*
                 ["25k", "75k", "100k", "125k", "150k", "300k", "500k", "1000k", "1500k"]

files = joinpath.("data", "bunny", geometry_names .* ".stl")

output_dir = joinpath("out", "performance", "benchmarks_bunny")

min_coord = 0.0
max_coord = 10.0

particle_layers_sdf = [3, 4, 5, 6]
n_particles_per_dimensions = [25, 50, 75, 100, 125, 150, 200, 250]

performance_benchmarks_create_data(geometry_names, files,
                                   n_particles_per_dimensions, particle_layers_sdf,
                                   output_dir, min_coord, max_coord)
