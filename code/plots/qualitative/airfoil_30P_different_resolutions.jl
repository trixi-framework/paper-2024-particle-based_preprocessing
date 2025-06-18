using Plots, JLD2
include(joinpath("..", "..", "auxiliary_functions.jl"))

my_linewidth = 3
my_tickfont = font(8)
my_guidefont = font(10)
my_legendfont = font(8)

save_fig = true

input_data_dir = joinpath(OUT_DIR, "airfoil", "30P-30N")
output_directory = joinpath(FIG_DIR, "airfoil")
mkpath(output_directory)

ws_dict = load(joinpath(input_data_dir, "sampled_airfoil_30P_different_resolutions.jld2"))

geometry = ws_dict["geometry"]
packed_ics = ws_dict["packed_ics"]

shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

xlims = (0.84, 0.875)
ylims = (0.03, 0.038)

line_colors = color_scheme(length(packed_ics))

labels = L"\Delta x = " .* ["0.0005", "0.001", "0.002"]

p1 = plot(first(packed_ics), xlims=xlims, ylims=ylims, label=labels[1], markerstrokewidth=1,
          tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
          size=0.6 .* (800, 200), color=first(line_colors), opacity=1)

for i in eachindex(packed_ics)[2:end]
    plot!(p1, packed_ics[i], xlims=xlims, ylims=ylims,
          markerstrokewidth=1, label=labels[i],
          tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
          size=0.6 .* (800, 200), color=line_colors[i], opacity=0.75)
end

plot!(p1, shape, color=nothing, label=nothing, yticks=[0.03, 0.034, 0.038],
      size=0.6 .* (800, 200), linewidth=2, linecolor=:black, aspect_ratio=:equal)

p2 = plot(shape, color=nothing, label=nothing, ylims=(-0.065, 0.065),
          xlims=(0.04, 0.88), grid=false, size=(800, 200),
          linewidth=1, linecolor=:black, aspect_ratio=:equal)
plot!(p2, size=0.6 .* (800, 200), yticks=[-0.05, 0, 0.05],
      Shape([xlims[1], xlims[2], xlims[2], xlims[1]],
            [0.02, 0.02, 0.05, 0.05]), color=nothing, label=nothing,
      tickfont=font(12),
      minorgrid=false, linewidth=2, linecolor=:red, aspect_ratio=:equal)

if save_fig
    savefig(p1,
            joinpath(output_directory,
                     "sampled_airfoil_30P_different_resolutions" * ".pdf"))
    savefig(p2,
            joinpath(output_directory,
                     "airfoirl_30P_shape" * ".pdf"))
end
