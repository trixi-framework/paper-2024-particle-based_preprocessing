using TrixiParticles
using PointNeighbors
using Plots, LaTeXStrings

CODE_DIR = joinpath(@__DIR__)
OUT_DIR = joinpath(@__DIR__, "out")
DATA_DIR = joinpath(@__DIR__, "data")
FIG_DIR = joinpath(@__DIR__, "figures")

COLORSCHEME = :coolwarm
color_scheme(length_cs) = cgrad(COLORSCHEME, length_cs, categorical=true)

function summation_density!(densities::AbstractVector, positions::AbstractVector,
                            masses::AbstractVector, mass_positions::AbstractVector;
                            smoothing_kernel, smoothing_length)
    TrixiParticles.set_zero!(densities)

    search_radius = TrixiParticles.compact_support(smoothing_kernel, smoothing_length)
    search_radius2 = search_radius^2

    coords1 = stack(positions)
    coords2 = stack(mass_positions)
    nhs = GridNeighborhoodSearch{ndims(smoothing_kernel)}(; search_radius,
                                                          n_points=size(coords2, 2))
    PointNeighbors.initialize!(nhs, coords1, coords2)

    TrixiParticles.@threaded default_backend(positions) for point in eachindex(positions)
        point_coords = positions[point]

        for neighbor in PointNeighbors.eachneighbor(point_coords, nhs)
            pos_diff = mass_positions[neighbor] - point_coords
            distance2 = TrixiParticles.dot(pos_diff, pos_diff)
            distance2 > search_radius2 && continue

            distance = sqrt(distance2)
            kernel_weight = TrixiParticles.kernel(smoothing_kernel, distance,
                                                  smoothing_length)

            densities[point] += masses[neighbor] * kernel_weight
        end
    end

    return densities
end

function save_stl(filename, mesh; faces=TrixiParticles.eachface(mesh))
    save_stl(TrixiParticles.FileIO.File{TrixiParticles.FileIO.format"STL_BINARY"}(filename),
             mesh; faces)
end

function save_stl(fn::TrixiParticles.FileIO.File{TrixiParticles.FileIO.format"STL_BINARY"},
                  mesh::TrixiParticles.TriangleMesh; faces=TrixiParticles.eachface(mesh))
    open(fn, "w") do s
        save_stl(s, mesh; faces)
    end
end

function save_stl(f::TrixiParticles.FileIO.Stream{TrixiParticles.FileIO.format"STL_BINARY"},
                  mesh::TrixiParticles.TriangleMesh; faces)
    io = TrixiParticles.FileIO.stream(f)
    points = mesh.face_vertices
    normals = mesh.face_normals

    # Implementation made according to https://en.wikipedia.org/wiki/STL_%28file_format%29#Binary_STL
    for i in 1:80 # Write empty header
        write(io, 0x00)
    end

    write(io, UInt32(length(faces))) # Write triangle count
    for i in faces
        n = SVector{3, Float32}(normals[i])
        triangle = points[i]

        for j in 1:3
            write(io, n[j])
        end

        for point in triangle, p in point
            write(io, Float32(p))
        end
        write(io, 0x0000) # 16 empty bits
    end
end
