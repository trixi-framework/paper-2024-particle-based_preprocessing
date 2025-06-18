# This script show the circle packed with and without boundary.
using Plots, JLD2
include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = true

tlsph = false
for h_factor in [0.8, 1.2]
    input_data_dir = joinpath(OUT_DIR, "circle")
    output_directory = joinpath(FIG_DIR, "circle")
    mkpath(output_directory)

    ws_dict = load(joinpath(input_data_dir,
                            "packed_circle_h_factor_$h_factor" * (tlsph ? "_tlsph" : "") *
                            ".jld2"))

    geometry = ws_dict["geometry"]
    packed_ic_no_boundary = ws_dict["packed_ic_no_boundary"]
    packed_ic_boundary = ws_dict["packed_ic_boundary"]

    shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

    xlims = (-1.0, 1.0)
    ylims = (-1.0, 1.0)

    p1 = plot(packed_ic_no_boundary, xlims=xlims, ylims=ylims, markerstrokewidth=1,
              label=nothing, size=(600, 600), color=color_scheme(3)[2])
    plot!(p1, shape, color=nothing, label=nothing, linewidth=2,
          linecolor=color_scheme(3)[3])

    p2 = plot(packed_ic_boundary, xlims=xlims, ylims=ylims, markerstrokewidth=1,
              label=nothing, size=(600, 600), color=color_scheme(3)[2])
    plot!(p2, shape, color=nothing, label=nothing, linewidth=2,
          linecolor=color_scheme(3)[3])

    xaxis!(p1, showaxis=false)
    xaxis!(p2, showaxis=false)

    if save_fig
        savefig(p1,
                joinpath(output_directory,
                         "packed_circle_no_boundary_h_factor_$h_factor" *
                         (tlsph ? "_tlsph" : "") * ".pdf"))

        savefig(p2,
                joinpath(output_directory,
                         "packed_circle_h_factor_$h_factor" * (tlsph ? "_tlsph" : "") *
                         ".pdf"))
    end
end
