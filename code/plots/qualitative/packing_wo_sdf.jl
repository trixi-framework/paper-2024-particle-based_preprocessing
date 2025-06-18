using Plots, JLD2
include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = true

input_data_dir = joinpath(OUT_DIR, "circle")
output_directory = joinpath(FIG_DIR, "circle")
mkpath(output_directory)

ws_dict = load(joinpath(input_data_dir, "packed_circle_wo_sdf.jld2"))

geometry = ws_dict["geometry"]
shape_sampled = ws_dict["shape_sampled"]
packed_ic = ws_dict["packed_ic"]

shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

xlims = (-1.25, 1.25)
ylims = xlims

p1 = plot(shape_sampled, xlims=xlims, ylims=ylims, markerstrokewidth=1,
          color=color_scheme(3)[2],
          label=nothing, size=0.65 .* (600, 600))
plot!(p1, shape, color=nothing, label=nothing, linewidth=2, linecolor=color_scheme(3)[3])

p2 = plot(packed_ic, label=nothing, xlims=xlims, ylims=ylims, markerstrokewidth=1,
          color=color_scheme(3)[2], size=0.65 .* (600, 600))
plot!(p2, shape, label=nothing, color=nothing, linewidth=2, linecolor=color_scheme(3)[3])

xaxis!(p1, showaxis=false)
xaxis!(p2, showaxis=false)

if save_fig
    savefig(p1,
            joinpath(output_directory, "sampled_circle.pdf"))
    savefig(p2,
            joinpath(output_directory, "packed_circle_wo_sdf.pdf"))
end
