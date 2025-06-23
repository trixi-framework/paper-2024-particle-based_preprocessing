# Generate a example Signed Distance Fields
using Plots

include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = true

geometry_name = "NACA0015.asc"
file = joinpath(DATA_DIR, "airfoil", geometry_name)

geometry = load_geometry(file)

particle_spacing = 0.006

nlayers = 4

signed_distance_field = SignedDistanceField(geometry, particle_spacing;
                                            max_signed_distance=nlayers * particle_spacing)

# For plotting
dummy_ic = InitialCondition(coordinates=stack(signed_distance_field.positions),
                            density=1,
                            particle_spacing=particle_spacing)

shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

xlims = (0.0, 0.15) .+ (-1, 1) .* nlayers .* particle_spacing
ylims = (-0.075, 0.075) .+ (-1, 1) .* nlayers .* particle_spacing

p1 = plot(dummy_ic, size=0.6 .* (800, 600),
          #   right_margin=4Plots.mm, # avoid colorbar cutoff
          xlims=xlims, ylims=ylims,
          #   markersize=6,
          zcolor=signed_distance_field.distances,
          clim=(-0.02002, 0.02),
          cbartitle="\$\\phi\$",
          #   zticks=[-0.02, 0.0, 0.02],
          color=COLORSCHEME,
          label=nothing)
plot!(p1, shape, color=nothing, label=nothing,
      linewidth=3, linecolor=:black, subplot=1)

xaxis!(showaxis=false)

if save_fig
    savefig(p1,
            joinpath(FIG_DIR, "signed_distance_field",
                     "sdf_interpolation_airfoil" * ".pdf"))
end
