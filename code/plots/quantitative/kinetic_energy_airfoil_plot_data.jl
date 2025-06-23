using Plots
include(joinpath("..", "..", "auxiliary_functions.jl"))

my_linewidth = 3
my_tickfont = font(10)
my_guidefont = font(12)
my_legendfont = font(12)

save_fig = true

geometry_name = "30P-30N.asc"

input_directory = joinpath(OUT_DIR, "airfoil", "30P-30N",
                           "kinetic_energy")

ratios = [200, 300, 500, 800, 1000]

maxiters = 2000
smoothing_kernel = SchoenbergQuinticSplineKernel{2}()

h_factor = 1.0
h_factor_interpolation = 1.0

background_pressure = 1

for with_boundary in [true, false]

    # ==== Read data

    ekins = Vector{Float64}[]
    ekins_n = Vector{Float64}[]

    for ratio in ratios
        filename = "kinetic_energy_dp_$(ratio)_h_factor_$h_factor" *
                   "_h_factor_interpolation_$h_factor_interpolation" *
                   "_pb_$background_pressure" *
                   (with_boundary ? "_boundary" : "") * ".csv"

        data = TrixiParticles.CSV.read(joinpath(input_directory, filename),
                                       TrixiParticles.DataFrame)

        ekin = copy(data[!, "ekin_fluid_1"])

        push!(ekins, ekin)
    end

    for i in eachindex(ratios)
        push!(ekins_n, copy(ekins[i] ./ maximum(ekins[i])))
    end

    # ==== Plot data

    line_colors = color_scheme(length(ekins_n))
    labels_ = L"\Delta x = " .* [L"C/200", L"C/300", L"C/500", L"C/800", L"C/1000"]

    p2 = plot(ekins_n[1][1:maxiters], label=labels_[1], color=line_colors[1])
    for i in eachindex(ekins_n)[2:end]
        plot!(p2, ekins_n[i][1:maxiters], label=labels_[i], color=line_colors[i],
              legend_position=:outerright,
              minorgrid=true, size=0.6 .* (800, 400), ylims=(5e-5, 1.0), yaxis=:log,
              line_width=my_linewidth,
              tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
              ylabel=L"E_{\mathrm{kin}, \mathrm{n}}", xlabel="Iterations")
    end

    if save_fig

        mkpath(joinpath(FIG_DIR, "airfoil", "kinetic_energy"))
        savefig(p2,
                joinpath(FIG_DIR, "airfoil", "kinetic_energy",
                         "airfoil_30P_pb_$background_pressure" *
                         (with_boundary ? "_boundary" : "") * ".pdf"))
    end
end
