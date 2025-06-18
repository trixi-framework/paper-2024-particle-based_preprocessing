# This script shows the comparison of different initial configurations.
using Plots, JLD2
include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = true

input_data_dir = joinpath(OUT_DIR, "airfoil", "30P-30N")
output_directory = joinpath(FIG_DIR, "airfoil")
mkpath(output_directory)

ws_dict = load(joinpath(input_data_dir, "packing_different_configurations.jld2"))

geometry = ws_dict["geometry"]
packed_ic_tlsph_config_1 = ws_dict["packed_ic_tlsph_config_1"]
packed_ic_config_1 = ws_dict["packed_ic_config_1"]
packed_ic_tlsph_config_2 = ws_dict["packed_ic_tlsph_config_2"]
packed_ic_config_2 = ws_dict["packed_ic_config_2"]
shape_sampled_config_1 = ws_dict["shape_sampled_config_1"]
shape_sampled_config_2 = ws_dict["shape_sampled_config_2"]

shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

xlims = (0.823, 0.88)# (0.8, 0.88) #(-0.01, 1.0) .+ (-1, 1) .* ((tlsph ? particle_spacing / 2 : 0))
ylims = (0.025, 0.045) #(-0.08, 0.08) .+ (-1, 1) .* ((tlsph ? particle_spacing / 2 : 0))

p1 = plot(shape_sampled_config_2, xlims=xlims, ylims=ylims, markerstrokewidth=0.5,
          label=nothing, size=(450, 400), layout=(2, 1), color=color_scheme(3)[2])
plot!(p1, shape, color=nothing, label=nothing, size=(450, 400),
      linewidth=2, linecolor=color_scheme(3)[3], subplot=1)
plot!(p1, shape_sampled_config_1, xlims=xlims, ylims=ylims, markerstrokewidth=0.5,
      label=nothing, size=(450, 400), subplot=2, color=color_scheme(3)[2])
plot!(p1, shape, color=nothing, label=nothing, size=(450, 400),
      linewidth=2, linecolor=color_scheme(3)[3], subplot=2)
yticks!(p1, [0.025, 0.035, 0.045])
xaxis!(p1, font(12))
yaxis!(p1, font(12))

p2 = plot(packed_ic_config_2, xlims=xlims, ylims=ylims, markerstrokewidth=0.5,
          label=nothing, size=(450, 400), layout=(2, 1), color=color_scheme(3)[2])
plot!(p2, shape, color=nothing, label=nothing, size=(450, 400),
      linewidth=2, linecolor=color_scheme(3)[3], subplot=1)
plot!(p2, packed_ic_config_1, xlims=xlims, ylims=ylims, markerstrokewidth=0.5, subplot=2,
      size=(450, 400), label=nothing, color=color_scheme(3)[2])
plot!(p2, shape, color=nothing, label=nothing, size=(450, 400),
      linewidth=2, linecolor=color_scheme(3)[3], subplot=2)

yticks!(p2, [0.025, 0.035, 0.045])
xaxis!(p2, font(12))
yaxis!(p2, font(12))

if save_fig
    savefig(p1,
            joinpath(output_directory, "sampled_airfoil_30P_config_1_and_2" * ".pdf"))
    savefig(p2,
            joinpath(output_directory, "packed_airfoil_30P_config_1_and_2" * ".pdf"))
end
