using TrixiParticles
using BenchmarkTools

function benchmark_load_geometry(geometrty_files, output_filename)
    @info "Creating benchmarks for loading geometry"
    b = BenchmarkGroup()
    for geometrty_file in geometrty_files
        geometry = load_geometry(geometrty_file)

        n_faces = TrixiParticles.nfaces(geometry)

        b["n_faces: $n_faces"] = @benchmarkable load_geometry($geometrty_file)
    end

    @info "Running benchmarks"
    results = run(b, verbose=true, seconds=300, evals=1, samples=10)

    BenchmarkTools.save(output_filename, results)
end

function benchmark_construct_hierarchy(geometrty_files, output_filename)
    @info "Creating benchmarks for constructing hierarchy"
    b = BenchmarkGroup()
    for geometrty_file in geometrty_files
        geometry = load_geometry(geometrty_file)

        n_faces = TrixiParticles.nfaces(geometry)

        b["n_faces: $n_faces"] = @benchmarkable $WindingNumberJacobson(; geometry=$geometry)
    end

    @info "Running benchmarks"
    results = run(b, verbose=true, seconds=300, evals=1, samples=10)

    BenchmarkTools.save(output_filename, results)
end

function benchmark_sample(geometrty_files, n_particles_per_dimensions,
                          min_coord, max_coord, output_filename)
    @info "Creating benchmarks for sampling"
    b = BenchmarkGroup()
    for geometrty_file in geometrty_files
        geometry = load_geometry(geometrty_file)

        n_faces = TrixiParticles.nfaces(geometry)

        key_1 = "n_faces: $n_faces"
        for n_particles_per_dimension in n_particles_per_dimensions
            particle_spacing = (max_coord - min_coord) ./ n_particles_per_dimension
            n_particles = n_particles_per_dimension^3

            key_2 = "n_particles: $n_particles"

            point_in_geometry_algorithm = WindingNumberJacobson(; geometry)

            grid = TrixiParticles.rectangular_shape_coords(particle_spacing,
                                                           (n_particles_per_dimension,
                                                            n_particles_per_dimension,
                                                            n_particles_per_dimension),
                                                           (min_coord, min_coord,
                                                            min_coord))
            grid = reinterpret(reshape, SVector{ndims(geometry), eltype(geometry)}, grid)

            b[key_1][key_2] = @benchmarkable $point_in_geometry_algorithm($geometry, $grid)
        end
    end

    @info "Running benchmarks"
    results = run(b, verbose=true, seconds=300, evals=1, samples=10)

    BenchmarkTools.save(output_filename, results)
end

function benchmark_sdf(geometrty_files,
                       n_particles_per_dimensions, particle_layers_sdf,
                       min_coord, max_coord, output_filename)
    @info "Creating benchmarks for signed distance field"
    b = BenchmarkGroup()
    for geometrty_file in geometrty_files
        geometry = load_geometry(geometrty_file)

        n_faces = TrixiParticles.nfaces(geometry)

        key_1 = "n_faces: $n_faces"

        for n_particles_per_dimension in n_particles_per_dimensions
            particle_spacing = (max_coord - min_coord) ./ n_particles_per_dimension
            n_particles = n_particles_per_dimension^3

            key_2 = "n_particles: $n_particles"

            for particle_layers in particle_layers_sdf
                key_3 = "particle layers: $particle_layers"

                b[key_1][key_2][key_3] = @benchmarkable $SignedDistanceField($geometry,
                                                                             $particle_spacing;
                                                                             max_signed_distance=$(particle_layers *
                                                                                                   particle_spacing))
            end
        end
    end

    @info "Running benchmarks"
    results = run(b, verbose=true, seconds=300, evals=1, samples=10)

    BenchmarkTools.save(output_filename, results)
end

function benchmark_initialize_face_nhs(geometrty_files,
                                       n_particles_per_dimensions, particle_layers_sdf,
                                       min_coord, max_coord, output_filename)
    @info "Creating benchmarks for initializing face neighborhood search"
    b = BenchmarkGroup()
    for geometrty_file in geometrty_files
        geometry = load_geometry(geometrty_file)

        n_faces = TrixiParticles.nfaces(geometry)

        key_1 = "n_faces: $n_faces"

        for n_particles_per_dimension in n_particles_per_dimensions
            particle_spacing = (max_coord - min_coord) ./ n_particles_per_dimension
            n_particles = n_particles_per_dimension^3

            key_2 = "n_particles: $n_particles"

            for particle_layers in particle_layers_sdf
                key_3 = "particle layers: $particle_layers"
                nhs = TrixiParticles.FaceNeighborhoodSearch{ndims(geometry)}(search_radius=particle_layers *
                                                                                           particle_spacing)

                b[key_1][key_2][key_3] = @benchmarkable $TrixiParticles.initialize!($nhs,
                                                                                    $geometry)
            end
        end
    end

    @info "Running benchmarks"
    results = run(b, verbose=true, seconds=300, evals=1, samples=10)

    BenchmarkTools.save(output_filename, results)
end

function benchmark_sdf_no_nhs(geometrty_files, n_particles_per_dimensions,
                              min_coord, max_coord, output_filename)
    @info "Creating benchmarks for signed distance field without neighborhood search"
    b = BenchmarkGroup()
    for geometrty_file in geometrty_files
        geometry = load_geometry(geometrty_file)

        n_faces = TrixiParticles.nfaces(geometry)

        key_1 = "n_faces: $n_faces"

        for n_particles_per_dimension in n_particles_per_dimensions
            particle_spacing = (max_coord - min_coord) ./ n_particles_per_dimension
            n_particles = n_particles_per_dimension^3

            key_2 = "n_particles: $n_particles"

            b[key_1][key_2] = @benchmarkable $SignedDistanceField($geometry,
                                                                  $particle_spacing;
                                                                  neighborhood_search=false)
        end
    end

    @info "Running benchmarks"
    results = run(b, verbose=true, seconds=300, evals=1, samples=10)

    BenchmarkTools.save(output_filename, results)
end
