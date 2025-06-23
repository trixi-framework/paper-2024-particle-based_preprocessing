# Generate a Signed Distance Field for different resolutions
using Plots
include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = true

geometry_name = "NACA0015.asc"
file = joinpath(DATA_DIR, "airfoil", geometry_name)

geometry = load_geometry(file)

particle_spacings = [0.015, 0.01]

dummy_ics = InitialCondition[]
distances = Vector{Float64}[]

nlayers = 4

for particle_spacing in particle_spacings
    boundary_thickness = nlayers * particle_spacing

    signed_distance_field = SignedDistanceField(geometry, particle_spacing;
                                                max_signed_distance=boundary_thickness)

    # For plotting
    dummy_ic = InitialCondition(coordinates=stack(signed_distance_field.positions),
                                density=1,
                                particle_spacing=particle_spacing)
    push!(dummy_ics, dummy_ic)
    push!(distances, signed_distance_field.distances)
end

shape = Shape(stack(geometry.vertices)[1, :], stack(geometry.vertices)[2, :])

xlims = (0.0, 1.0) .+ (-1, 1) .* nlayers .* first(particle_spacings)
ylims = (-0.075, 0.075) .+ (-1, 1) .* nlayers .* first(particle_spacings)

p1 = plot(dummy_ics[1],
          size=0.7 .* (800, 450),
          #   right_margin=10Plots.mm, # avoid colorbar cutoff
          xlims=xlims, ylims=ylims,
          #  markersize=3,
          # markerstrokewidth=0.05,
          xlabel="\$x\$", ylabel="\$y\$",
          layout=(length(particle_spacings), 1),
          zcolor=distances[1],
          cbartitle="\$\\phi\$",
          color=COLORSCHEME,
          label=nothing)
plot!(p1, shape, color=nothing, label=nothing,
      linewidth=1, linecolor=:black, subplot=1)

plot!(p1, dummy_ics[2],
      size=0.8 .* (800, 450),
      #   right_margin=4Plots.mm, # avoid colorbar cutoff
      xlims=xlims, ylims=ylims,
      subplot=2,
      #  markersize=3,
      # markerstrokewidth=0.05,
      xlabel="\$x\$", ylabel="\$y\$",
      zcolor=distances[2],
      cbartitle="\$\\phi\$",
      color=COLORSCHEME,
      label=nothing)
plot!(p1, shape, color=nothing, label=nothing,
      linewidth=1, linecolor=:black, subplot=2)

if save_fig
    mkpath(joinpath(FIG_DIR, "signed_distance_field"))
    savefig(p1,
            joinpath(FIG_DIR, "signed_distance_field",
                     "airfoil_2d" * ".pdf"))
end
