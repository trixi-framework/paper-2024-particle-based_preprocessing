include(joinpath(@__DIR__, "performance.jl"))

n_layers = 5
i_particle = 4
i_face = 6

label_faces_ = ["25k" "75k" "100k" "125k" "150k" "300k" "500k" "1M" "1.5M"]
label_spacings_ = "L/" .* ["25" "50" "75" "100" "125" "150" "200" "250"]
label_particles_ = ["15.6k" "125k" "422k" "1M" "1.95M" "3.38M" "8M" "15.6M"]

mkpath(joinpath(FIG_DIR, "performance", "times_sdf"))

for n_threads in [8, 128]
    p1 = plot_times_vs_nfaces(nfaces_vec, t_sdf; xlog=true, ylog=true,
                              colorscheme=COLORSCHEME, nlayers=n_layers,
                              nthreads=n_threads, time_meassured=:sdf,
                              ylabels="Δx = " .* label_spacings_)
    ylims!(p1, (1e-1, 1e2))

    p2 = plot_times_vs_nparticles(spacings_vec, t_sdf, xlog=true, ylog=true,
                                  nlayers=n_layers, colorscheme=COLORSCHEME,
                                  nthreads=n_threads,
                                  time_meassured=:sdf, ylabels=label_faces)
    xaxis!(p2, :flip)

    savefig(p1,
            joinpath(FIG_DIR, "performance", "times_sdf",
                     "time_vs_nfaces_nthreads_$n_threads" * ".pdf"))
    savefig(p2,
            joinpath(FIG_DIR, "performance", "times_sdf",
                     "time_vs_nparticles_nthreads_$n_threads" * ".pdf"))
end

p3 = plot_times_vs_nthreads(nthreads_vec, t_sdf, xlog=true, ylog=true, nlayers=n_layers,
                            colorscheme=COLORSCHEME, time_meassured=:sdf,
                            yvalues=:nparticles,
                            nfaces=nfaces_vec[i_face],
                            ylabels="Δx = " .* label_spacings_)

time_vec = view(t_sdf, 1, i_face, i_particle, findfirst(==(n_layers), nlayers_vec))
ideal_scaling = time_vec ./ nthreads_vec
plot!(p3, nthreads_vec, ideal_scaling,
      label="Ideal scaling", color=:black, linestyle=:dash, linewidth=1)

ylims!(p3, (1e-1, 1e2))

p4 = plot_times_vs_nthreads(nthreads_vec, t_sdf, xlog=true, ylog=true, nlayers=n_layers,
                            colorscheme=COLORSCHEME, time_meassured=:sdf,
                            yvalues=:nfaces,
                            nparticles=nparticles_vec[i_particle], ylabels=label_faces)
plot!(p4, nthreads_vec, ideal_scaling,
      label="Ideal scaling", color=:black, linestyle=:dash, linewidth=1)
ylims!(p4, (1e-1, 1e2))

savefig(p3,
        joinpath(FIG_DIR, "performance", "times_sdf",
                 "time_vs_nthreads_nfaces_$(label_faces_[i_face])" * ".pdf"))
savefig(p4,
        joinpath(FIG_DIR, "performance", "times_sdf",
                 "time_vs_nthreads_nparticles_$(label_particles_[i_particle])" * ".pdf"))
