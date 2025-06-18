include(joinpath("..", "..", "auxiliary_functions.jl"))

my_size = (400, 300)
my_linewidth = 3
my_tickfont = font(10)
my_guidefont = font(12)
my_legendfont = font(12)

particle_spacing = 0.1
h_factor_1 = 0.8
h_factor_2 = 1.0
h_factor_3 = 1.2
n_dims = 2
range_x = TrixiParticles.compact_support(SchoenbergQuinticSplineKernel{n_dims}(),
                                         h_factor_3 * particle_spacing)
x = range(0, range_x, length=500)

smoothing_lengths = particle_spacing .* [h_factor_1, h_factor_2, h_factor_3]

line_colors = color_scheme(length(smoothing_lengths))

labels = L"h = " .* ["$h_factor_1" "$h_factor_2" "$h_factor_3"] .* L" \Delta x"

p1 = plot(x, xlabel=L"r", ylabel=L"\frac{\partial W}{\partial r}", grid=false,
          r -> TrixiParticles.kernel_deriv(SchoenbergQuinticSplineKernel{n_dims}(), abs(r),
                                           h_factor_1 * particle_spacing),
          palette=line_colors.colors, linewidth=my_linewidth,
          label=labels[1])
plot!(p1, x, grid=false,
      r -> TrixiParticles.kernel_deriv(SchoenbergQuinticSplineKernel{n_dims}(), abs(r),
                                       h_factor_2 * particle_spacing),
      palette=line_colors.colors, linewidth=my_linewidth,
      label=labels[2])
plot!(p1, x, grid=false,
      r -> TrixiParticles.kernel_deriv(SchoenbergQuinticSplineKernel{n_dims}(), abs(r),
                                       h_factor_3 * particle_spacing),
      palette=line_colors.colors,
      size=my_size, linewidth=my_linewidth,
      tickfont=my_tickfont, guidefont=my_guidefont, legendfont=my_legendfont,
      label=labels[3])
xaxis!(p1, xticks=([0, 0.1, 0.2, 0.3], [L"0", L"\Delta x", L"2\Delta x", L"3\Delta x"]))
savefig(p1, joinpath(FIG_DIR, "kernel_derivative.pdf"))
