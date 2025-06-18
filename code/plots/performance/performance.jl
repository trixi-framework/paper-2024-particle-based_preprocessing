using Plots, StatsPlots
using BenchmarkTools
include(joinpath("..", "..", "auxiliary_functions.jl"))

# if isdefined(Main, :Infiltrator)
#     Main.infiltrate(@__MODULE__, Base.@locals, @__FILE__, @__LINE__)
# end

# ==========================================================================================
# ==== create data
include(joinpath(@__DIR__, "extract_times.jl"))

# ==========================================================================================
# ==== plot data
label_faces = "# faces  ≈ " .*
              ["25k" "75k" "100k" "125k" "150k" "300k" "500k" "1M" "1.5M"]
label_threads = "# threads = " .* ["1" "2" "4" "8" "16" "32" "64" "128"]
label_particles = "# particles  ≈ " .*
                  ["15.6k" "125k" "422k" "1M" "1.95M" "3.38M" "8M" "15.6M"]
label_spacings = "particle_spacing  ≈ " .*
                 ["0.4" "0.2" "0.1333" "0.1" "0.08" "0.0667" "0.05" "0.04"]
label_layers = "# layers = " .* ["3" "4" "5" "6"]

function plot_times_vs_nparticles(nparticles, times; xlog=false, ylog=false, ylabels,
                                  colorscheme=COLORSCHEME,
                                  nthreads=1, nlayers=nothing, time_meassured=:sample)
    line_colors = cgrad(colorscheme, length(ylabels), categorical=true)
    i = findfirst(==(nthreads), nthreads_vec)

    if time_meassured == :sample
        time_vec = view(times, i, :, :)'
        xlabel_ = "Number of particles"
        xticklabel_ = label_particles_
    elseif time_meassured == :sdf
        j = findfirst(==(nlayers), nlayers_vec)
        time_vec = view(times, i, :, :, j)'
        xlabel_ = "Δx"
        xticklabel_ = label_spacings_
    end

    return plot(nparticles, time_vec, labels=ylabels, legend=:outerright,
                xlabel=xlabel_, size=0.75 .* (600, 400),
                ylabel="Time [s]",
                palette=line_colors.colors,
                xticks=(nparticles[1:2:end], xticklabel_[1:2:end]),
                xaxis=xlog ? :log : :linear,
                yaxis=ylog ? :log : :linear)
end

function plot_times_vs_nfaces(nfaces, values; xlog=false, ylog=false, ylabels,
                              colorscheme=COLORSCHEME,
                              nthreads=1, nlayers=nothing, time_meassured=:sample)
    line_colors = cgrad(colorscheme, length(ylabels), categorical=true)
    i = findfirst(==(nthreads), nthreads_vec)

    if time_meassured == :sample
        time_vec = view(values, i, :, :)
    elseif time_meassured == :sdf
        j = findfirst(==(nlayers), nlayers_vec)
        time_vec = view(values, i, :, :, j)
    elseif time_meassured == :load
        time_vec = t_load[i, :]
    elseif time_meassured == :constr_hier
        time_vec = t_hier[i, :]
    end

    return plot(nfaces, time_vec, labels=ylabels, legend=:outerright,
                xlabel="Number of faces",
                ylabel="Time [s]", size=0.75 .* (600, 400),
                xticks=(nfaces[1:4:end], label_faces_[1:4:end]),
                palette=line_colors.colors,
                xaxis=xlog ? :log : :linear,
                yaxis=ylog ? :log : :linear)
end

function plot_times_vs_nthreads(nthreads, values; xlog=false, ylog=false, ylabels,
                                colorscheme=COLORSCHEME, yvalues=:nparticles,
                                nfaces=nothing, nparticles=nothing, nlayers=nothing,
                                time_meassured=:sample)
    line_colors = cgrad(colorscheme, length(ylabels), categorical=true)

    if time_meassured == :sample
        if yvalues == :nparticles
            time_vec = view(values, :, findfirst(==(nfaces), nfaces_vec), :)
        elseif yvalues == :nfaces
            time_vec = view(values, :, :, findfirst(==(nparticles), nparticles_vec))
        end
    elseif time_meassured == :sdf
        if yvalues == :nparticles
            time_vec = view(values, :, findfirst(==(nfaces), nfaces_vec), :,
                            findfirst(==(nlayers), nlayers_vec))
        elseif yvalues == :nfaces
            time_vec = view(values, :, :, findfirst(==(nparticles), nparticles_vec),
                            findfirst(==(nlayers), nlayers_vec))
        end
    elseif time_meassured == :load
        time_vec = view(t_load, :, :)
    elseif time_meassured == :constr_hier
        time_vec = view(t_hier, :, :)
    end

    return plot(nthreads, time_vec, labels=ylabels, legend=:outerright,
                xlabel="Number of threads", xticks=(nthreads_vec, nthreads_vec),
                ylabel="Time [s]", size=0.75 .* (600, 400),
                palette=line_colors.colors,
                xaxis=xlog ? :log : :linear,
                yaxis=ylog ? :log : :linear)
end

function plot_time_ratios(ratio_dict; xvalues=:nfaces, size=(600, 600),
                          colorscheme=COLORSCHEME, my_tickfont, my_guidefont,
                          my_legendfont,
                          nthreads=nothing, nfaces=nothing, nparticles=nothing,
                          nlayers=nothing)
    values_1 = ratio_dict["load geometry"]
    values_2 = ratio_dict["construct hierarchy"]
    values_3 = ratio_dict["sample geometry"]
    values_4 = ratio_dict["create sdf"]

    if xvalues == :nfaces
        i = findfirst(==(nthreads), nthreads_vec)
        j = findfirst(==(nparticles), nparticles_vec)
        k = findfirst(==(nlayers), nlayers_vec)
        values = stack([view(values_1, i, :, j, k),
                           view(values_2, i, :, j, k),
                           view(values_3, i, :, j, k),
                           view(values_4, i, :, j, k)])

        x_ticks_ = (1:length(nfaces_vec),
                    ["25k" "75k" "100k" "125k" "150k" "300k" "500k" "1M" "1.5M"])
        xlabel_ = "# faces"
    elseif xvalues == :nparticles
        i = findfirst(==(nthreads), nthreads_vec)
        j = findfirst(==(nfaces), nfaces_vec)
        k = findfirst(==(nlayers), nlayers_vec)
        values = stack([view(values_1, i, j, :, k),
                           view(values_2, i, j, :, k),
                           view(values_3, i, j, :, k),
                           view(values_4, i, j, :, k)])

        x_ticks_ = (1:length(nparticles_vec),
                    ["15.6k" "125k" "422k" "1M" "1.95M" "3.38M" "8M" "15.6M"])
        i = findfirst(==(nfaces), nfaces_vec)
        xlabel_ = "# particles"
    end

    bar_colors = cgrad(colorscheme, 4, categorical=true)
    return groupedbar(values, xticks=x_ticks_, size=size,
                      xlabel=xlabel_, ylabel="Time ratio",
                      palette=bar_colors.colors,
                      bar_position=:stack,
                      tickfont=my_tickfont, guidefont=my_guidefont,
                      legendfont=my_legendfont, left_margin=5Plots.mm,
                      bottom_margin=3Plots.mm,
                      top_margin=5Plots.mm,
                      label=["load geometry" "constr. hierarchy" "sample geometry" "create sdf (layers = $nlayers)"],
                      legend=:outerright)
end
