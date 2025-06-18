include(joinpath(@__DIR__, "performance.jl"))

i_particle = 4
i_face = 5

time_meassured = :sample

label_faces_ = ["25k" "75k" "100k" "125k" "150k" "300k" "500k" "1M" "1.5M"]
label_particles_ = ["15.6k" "125k" "422k" "1M" "1.95M" "3.38M" "8M" "15.6M"]

mkpath(joinpath(FIG_DIR, "performance", "times_sampling"))

for n_threads in [8, 128]
    p1 = plot_times_vs_nfaces(nfaces_vec, t_sample; xlog=true, ylog=true,
                              colorscheme=COLORSCHEME,
                              nthreads=n_threads, time_meassured=:sample,
                              ylabels=label_particles)

    p2 = plot_times_vs_nparticles(nparticles_vec, t_sample, xlog=true, ylog=true,
                                  nlayers=3, colorscheme=COLORSCHEME, nthreads=n_threads,
                                  time_meassured=:sample, ylabels=label_faces)

    savefig(p2,
            joinpath(FIG_DIR, "performance", "times_sampling",
                     "time_vs_nparticles_nthreads_$n_threads" * ".pdf"))
end

p3 = plot_times_vs_nthreads(nthreads_vec, t_sample, xlog=true, ylog=true, nlayers=3,
                            colorscheme=COLORSCHEME, time_meassured=:sample,
                            yvalues=:nparticles,
                            nfaces=nfaces_vec[i_face], ylabels=label_particles)

time_vec = view(t_sample, 1, i_face, i_particle)
ideal_scaling = time_vec ./ nthreads_vec
plot!(p3, nthreads_vec, ideal_scaling,
      label="Ideal scaling", color=:black, linestyle=:dash, linewidth=1)

p4 = plot_times_vs_nthreads(nthreads_vec, t_sample, xlog=true, ylog=true, nlayers=3,
                            colorscheme=COLORSCHEME, time_meassured=:sample,
                            yvalues=:nfaces,
                            nparticles=nparticles_vec[i_particle], ylabels=label_faces)

plot!(p4, nthreads_vec, ideal_scaling,
      label="Ideal scaling", color=:black, linestyle=:dash, linewidth=1)

savefig(p3,
        joinpath(FIG_DIR, "performance", "times_sampling",
                 "time_vs_nthreads_nfaces_$(label_faces_[i_face])" * ".pdf"))
savefig(p4,
        joinpath(FIG_DIR, "performance", "times_sampling",
                 "time_vs_nthreads_nparticles_$(label_particles_[i_particle])" * ".pdf"))
