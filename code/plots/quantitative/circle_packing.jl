using OrdinaryDiffEq
using Plots
include(joinpath("..", "..", "auxiliary_functions.jl"))

my_size = (900, 400)
my_linewidth = 3
my_tickfont = font(10)
my_guidefont = font(16)
my_legendfont = font(12)

file = joinpath(DATA_DIR, "circle.asc")

input_directory = joinpath(OUT_DIR, "circle")
maxiters = 800

save_fig = true

# ==== Read data

ekins = Vector{Float64}[]
ekins_n = Vector{Float64}[]

for with_boundary in [true, false], h_factor in [1.2, 0.8]
    filename = "kinetic_energy_" * (with_boundary ? "" : "no_") *
               "boundary_h_factor_$h_factor" * ".csv"

    data = TrixiParticles.CSV.read(joinpath(input_directory, filename),
                                   TrixiParticles.DataFrame)

    ekin = copy(data[!, "ekin_fluid_1"])

    push!(ekins, ekin)
end
for i in eachindex(ekins)
    push!(ekins_n, copy(ekins[i] ./ maximum(ekins[i])))
end

# ==== Plot data
line_colors = color_scheme(length(ekins_n))
labels_ = ["with boundary, " * L"h =" * " 1.2" * L"\Delta x" "with boundary, " * L"h = " *
                                                             " 0.8" * L"\Delta x" "without boundary, " *
                                                                                  L"h = " *
                                                                                  " 1.2" *
                                                                                  L"\Delta x" "without boundary, " *
                                                                                              L"h = " *
                                                                                              " 0.8" *
                                                                                              L"\Delta x"]

p1 = plot(ekins_n[1][1:maxiters], label=labels_[1], color=line_colors[1],
          size=my_size, linewidth=my_linewidth, left_margin=10Plots.mm,
          bottom_margin=10Plots.mm,
          tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
          yaxis=:log)

for i in eachindex(ekins_n)[2:end]
    plot!(p1, ekins_n[i][1:maxiters], label=labels_[i], color=line_colors[i],
          minorgrid=true, ylims=(1e-5, 1.0), yaxis=:log, legend_position=:outerright,
          size=my_size, linewidth=my_linewidth,
          tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
          ylabel=L"E_{\mathrm{kin}, \mathrm{n}}", xlabel="Iterations")
end

yticks!(p1, [1e-6, 1e-4, 1e-2, 1e0])

if save_fig
    savefig(p1,
            joinpath(FIG_DIR, "circle", "kinetic_energy.pdf"))
end
