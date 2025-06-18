using Plots, JLD2
include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = true
h_factor = 0.8

input_data_dir = joinpath(OUT_DIR, "circle")
output_directory = joinpath(FIG_DIR, "circle")
mkpath(output_directory)

for tlsph in [true, false], h_factor in [1.2, 0.8]
    h_factor == 1.2 && tlsph && continue

    if h_factor == 1.2
        ws_dict = load(joinpath(input_data_dir,
                                "circle_boundary_packing_h_1.2.jld2"))
    else
        ws_dict = load(joinpath(input_data_dir,
                                "circle_boundary_packing" * (tlsph ? "_tlsph" : "") *
                                ".jld2"))
    end
    geometry = ws_dict["geometry"]
    shape_sampled = ws_dict["shape_sampled"]
    boundary_sampled = ws_dict["boundary_sampled"]
    packed_ic = ws_dict["packed_ic"]
    packed_boundary_ic = ws_dict["packed_boundary_ic"]

    particle_spacing = 0.1

    boundary_thickness = 4 * particle_spacing

    shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

    xlims = (-1.0, 1.0) .+
            (-1, 1) .*
            (boundary_thickness + (tlsph ? particle_spacing : particle_spacing / 2))
    ylims = (-1.0, 1.0) .+
            (-1, 1) .*
            (boundary_thickness + (tlsph ? particle_spacing : particle_spacing / 2))

    p1 = plot(shape_sampled, xlims=xlims, ylims=ylims, markerstrokewidth=1,
              label=nothing, size=(600, 600), color=color_scheme(3)[2])
    plot!(p1, boundary_sampled, xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(600, 600), color=color_scheme(3)[1])
    plot!(p1, shape, color=nothing, label=nothing, linewidth=3,
          linecolor=color_scheme(3)[3])

    p2 = plot(packed_ic, xlims=xlims, ylims=ylims, markerstrokewidth=1,
              label=nothing, size=(600, 600), color=color_scheme(3)[2])
    plot!(p2, packed_boundary_ic, xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(600, 600), color=color_scheme(3)[1])
    plot!(p2, shape, color=nothing, label=nothing, linewidth=3,
          linecolor=color_scheme(3)[3])

    xaxis!(p1, showaxis=false)
    xaxis!(p2, showaxis=false)

    if save_fig
        savefig(p1,
                joinpath(output_directory,
                         "sampled_circle_boundary.pdf"))

        savefig(p2,
                joinpath(output_directory,
                         "packed_circle_boundary_h_factor_$h_factor" *
                         (tlsph ? "_tlsph" : "") * ".pdf"))
    end
end
