include(joinpath(@__DIR__, "performance.jl"))

my_size = (750, 450)
my_linewidth = 1
my_tickfont = font(12)
my_guidefont = font(14)
my_legendfont = font(14)

n_threads = 8
n_layers = 3
i_particle = 4
i_face = 5
xlog = true
ylog = true

nthreads_vec = [1, 2, 4, 8, 16, 32, 64, 128]
nfaces_vec = [24776, 74576, 99300]#, 124736]
nparticles_vec = [25, 50, 75, 100] .^ 3

label_faces = ["25k" "75k" "100k"]#"150k"]# "125k" "150k" "300k" "500k" "1M" "1.5M"]
label_spacings = L"\Delta x = L/" .* ["25" "50" "75" "100"]# "125" "150" "200" "250"]

i = findfirst(==(n_threads), nthreads_vec)
j = findfirst(==(n_layers), nlayers_vec)

# [nthreads, nfaces, nparticles, nlayers]
time_vec = view(t_sdf, i, eachindex(nfaces_vec), eachindex(nparticles_vec), j)

line_colors = color_scheme(length(label_spacings))

p1 = plot(nfaces_vec, time_vec, labels=(label_spacings .* ", with NHS"),
          legend=:outerright,
          xlabel="# faces",
          ylabel="Time [s]",
          xticks=(nfaces_vec, label_faces),
          size=my_size,
          linewidth=my_linewidth,
          tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
          left_margin=5Plots.mm,
          palette=line_colors.colors,
          xaxis=xlog ? :log : :linear,
          yaxis=ylog ? :log : :linear)

plot!(p1, nfaces_vec,
      view(t_sdf_no_nhs, i, eachindex(nfaces_vec), eachindex(nparticles_vec)),
      labels=label_spacings, line=:dash,
      legend=:outerright,
      xlabel="# faces",
      ylabel="Time [s]",
      size=my_size,
      linewidth=my_linewidth,
      tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
      xticks=(nfaces_vec, label_faces),
      palette=line_colors.colors,
      xaxis=xlog ? :log : :linear,
      yaxis=ylog ? :log : :linear)

savefig(p1,
        joinpath(FIG_DIR, "performance", "times_sdf",
                 "create_sdf_without_vs_with_nhs" * ".pdf"))
