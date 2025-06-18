using Plots, JLD2
include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = true

particle_spacings = [0.05, 0.02, 0.01]
tlsph = false

input_data_dir = joinpath(OUT_DIR, "airfoil", "NACA0015")
output_directory = joinpath(FIG_DIR, "airfoil")
mkpath(output_directory)

ws_dict = load(joinpath(input_data_dir,
                        "sampled_airfoil_NACA0015_different_resolutions.jld2"))

geometry = ws_dict["geometry"]
shapes_sampled = ws_dict["shapes_sampled"]
packed_ics = ws_dict["packed_ics"]

shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

xlims = (-0.005, 1.0) .+ (-1, 1) .* (tlsph ? particle_spacings[1] / 2 : 0)
ylims = (-0.078, 0.078) .+ (-1, 1) .* (tlsph ? particle_spacings[1] / 2 : 0)

p1 = plot(shapes_sampled[1], xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(800, 160), yticks=ylims[1]:0.04:ylims[2],
          color=color_scheme(3)[2])
plot!(p1, shape, color=nothing, label=nothing,
      linewidth=2, linecolor=color_scheme(3)[3])

p2 = plot(packed_ics[1], xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(800, 160), yticks=ylims[1]:0.04:ylims[2],
          color=color_scheme(3)[2])
plot!(p2, shape, color=nothing, label=nothing,
      linewidth=2, linecolor=color_scheme(3)[3])

p3 = plot(shapes_sampled[2], xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(800, 160), yticks=ylims[1]:0.04:ylims[2],
          color=color_scheme(3)[2])
plot!(p3, shape, color=nothing, label=nothing,
      linewidth=2, linecolor=color_scheme(3)[3])

p4 = plot(packed_ics[2], xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(800, 160), yticks=ylims[1]:0.04:ylims[2],
          color=color_scheme(3)[2])
plot!(p4, shape, color=nothing, label=nothing,
      linewidth=2, linecolor=color_scheme(3)[3])

p5 = plot(shapes_sampled[3], xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(800, 160), yticks=ylims[1]:0.04:ylims[2],
          color=color_scheme(3)[2])
plot!(p5, shape, color=nothing, label=nothing,
      linewidth=2, linecolor=color_scheme(3)[3])

p6 = plot(packed_ics[3], xlims=xlims, ylims=ylims, markerstrokewidth=1,
          label=nothing, size=(800, 160), yticks=ylims[1]:0.04:ylims[2],
          color=color_scheme(3)[2])
plot!(p6, shape, color=nothing, label=nothing,
      linewidth=2, linecolor=color_scheme(3)[3])

xaxis!(p1, showaxis=false)
xaxis!(p2, showaxis=false)
xaxis!(p3, showaxis=false)
xaxis!(p4, showaxis=false)
xaxis!(p5, showaxis=false)
xaxis!(p6, showaxis=false)

if save_fig
    savefig(p1,
            joinpath(output_directory,
                     "sampled_airfoil_dp_$(particle_spacings[1])" *
                     (tlsph ? "_tlsph" : "") * ".pdf"))
    savefig(p2,
            joinpath(output_directory,
                     "packed_airfoil_dp_$(particle_spacings[1])" *
                     (tlsph ? "_tlsph" : "") * ".pdf"))
    savefig(p3,
            joinpath(output_directory,
                     "sampled_airfoil_dp_$(particle_spacings[2])" *
                     (tlsph ? "_tlsph" : "") * ".pdf"))
    savefig(p4,
            joinpath(output_directory,
                     "packed_airfoil_dp_$(particle_spacings[2])" *
                     (tlsph ? "_tlsph" : "") * ".pdf"))
    savefig(p5,
            joinpath(output_directory,
                     "sampled_airfoil_dp_$(particle_spacings[3])" *
                     (tlsph ? "_tlsph" : "") * ".pdf"))
    savefig(p6,
            joinpath(output_directory,
                     "packed_airfoil_dp_$(particle_spacings[3])" *
                     (tlsph ? "_tlsph" : "") * ".pdf"))
end
