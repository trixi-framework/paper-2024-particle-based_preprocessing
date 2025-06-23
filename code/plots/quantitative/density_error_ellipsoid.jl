using Plots
include(joinpath("..", "..", "auxiliary_functions.jl"))
my_size = 0.8 .* (500, 300)

save_fig = true
tlsph = false
particle_spacing = 0.1
atols = [1e-4, 5e-5, 2e-5, 1e-5, 5e-6, 2e-6, 1e-6]

h_factor = 1.0
h_factor_interpolation = 1.0

background_pressure = 1.0

L_inf_35 = [Vector{Float64}() for _ in eachindex(atols)]
L_inf_49 = [Vector{Float64}() for _ in eachindex(atols)]

for (i, atol) in enumerate(atols)
    input_directory = joinpath(OUT_DIR,
                               "ellipsoid", "atol_$atol",
                               "dp_$(particle_spacing)_h_factor_$h_factor" *
                               "_h_factor_interpolation_$h_factor_interpolation" *
                               "_pb_$background_pressure" *
                               (tlsph ? "_tlsph" : "") * "_RDPK3SpFSAL35")

    data = TrixiParticles.CSV.read(joinpath(input_directory,
                                            "density_error" * ".csv"),
                                   TrixiParticles.DataFrame)

    append!(L_inf_35[i], copy(Vector(data.var"l_inf_fluid_1")))
end

line_colors = color_scheme(length(atols));

labels = "atol = " .*
         [L"1 \cdot 10^{-4}" L"5 \cdot 10^{-5}" L"2 \cdot 10^{-5}" L"1 \cdot 10^{-5}" L"5 \cdot 10^{-6}" L"2 \cdot 10^{-6}" L"1 \cdot 10^{-6}" L"5 \cdot 10^{-7}"]

L_inf_min_35 = reverse.(findmin.(L_inf_35))

p1 = plot(L_inf_35, size=my_size, label=nothing,
          yaxis=:log, yticks=[1e-2, 1e-1, 1e0], ylims=(1e-2, 1e-1), xlims=(0, 1000),
          palette=line_colors.colors, linestyle=:dash, linewidth=0.8,
          #  legend=:outerright,
          #  bottom_margin=5Plots.mm,
          right_margin=5Plots.mm)
scatter!(p1, L_inf_min_35[1], label=labels[1], size=my_size,
         yaxis=:log, yticks=[1e-2, 1e-1, 1e0], ylims=(1e-2, 1e-1), xlims=(0, 1000),
         palette=line_colors.colors,
         #  legend=:outerright,
         #  bottom_margin=5Plots.mm,
         right_margin=5Plots.mm,
         #title="Density error of the ellipsoid (Δx = 0.1)".
         xlabel="Iterations", ylabel=L"L_\infty")

for i in eachindex(L_inf_min_35)[2:end]
    scatter!(p1, L_inf_min_35[i], label=labels[i], size=my_size,
             yaxis=:log, yticks=[1e-2, 1e-1, 1e0], ylims=(1e-2, 1e-1), xlims=(0, 1000),
             palette=line_colors.colors,
             minorgrid=true,# bottom_margin=5Plots.mm, #
             right_margin=5Plots.mm,
             xlabel="Iterations", ylabel=L"L_\infty")
end

if save_fig
    mkpath(joinpath(FIG_DIR, "ellipsoid"))
    savefig(p1,
            joinpath(FIG_DIR, "ellipsoid",
                     "density_error_ellipsoid_L_inf.pdf"))
end
