include(joinpath(@__DIR__, "performance.jl"))

my_tickfont = font(10)
my_guidefont = font(14)
my_legendfont = font(12)

save_fig = true
x_values = :nfaces
n_threads = 8
i_particle = 8
i_face = 9

label_faces_ = ["25k" "75k" "100k" "125k" "150k" "300k" "500k" "1M" "1.5M"]
label_particles_ = ["15.6k" "125k" "422k" "1M" "1.95M" "3.38M" "8M" "15.6M"]

for x_values in [:nfaces, :nparticles]
    n_faces = x_values == :nfaces ? nothing : nfaces_vec[i_face]
    n_particles = x_values == :nparticles ? nothing : nparticles_vec[i_particle]

    p = plot_time_ratios(ratios; xvalues=x_values, size=(850, 400),
                         colorscheme=COLORSCHEME,
                         my_tickfont, my_guidefont, my_legendfont,
                         nthreads=n_threads, nfaces=n_faces, nparticles=n_particles,
                         nlayers=3)

    other_value_name = x_values == :nfaces ? :nparticles : :nfaces
    other_value = x_values == :nfaces ? label_particles_[i_particle] : label_faces_[i_face]

    if save_fig
        output_directory = joinpath(FIG_DIR, "performance", "time_ratios")
        mkpath(output_directory)

        savefig(p,
                joinpath(output_directory,
                         "ratio_vs_$(x_values)_$(other_value_name)_$(other_value)_nthreads_$n_threads" *
                         ".pdf"))
    end
end
