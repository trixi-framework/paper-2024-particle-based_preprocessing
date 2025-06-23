using Plots
include(joinpath("..", "..", "auxiliary_functions.jl"))

save_fig = false
tlsph = false
particle_spacings = [0.04, 0.02, 0.01, 0.005, 0.0025]#, 0.00125]

h_factor = 1.0
h_factor_interpolation = 1.0

background_pressure = 1.0

abstol = 1e-7
reltol = 1e-4

L_inf = [Vector{Float64}() for _ in eachindex(particle_spacings)]
L_2 = [Vector{Float64}() for _ in eachindex(particle_spacings)]

for (i, particle_spacing) in enumerate(particle_spacings)
    input_directory = joinpath(OUT_DIR,
                               "aorta", "packing",
                               "dp_$(particle_spacing)_h_factor_$h_factor" *
                               "_h_factor_interpolation_$h_factor_interpolation" *
                               "_pb_$background_pressure" *
                               (tlsph ? "_tlsph" : "") * "_abstol_$abstol" *
                               "_reltol_$reltol")

    data = TrixiParticles.CSV.read(joinpath(input_directory,
                                            "density_error.csv"),
                                   TrixiParticles.DataFrame)
    append!(L_inf[i], copy(Vector(data.var"l_inf_fluid_1")))
    append!(L_2[i], copy(Vector(data.var"l_2_fluid_1")))
end

l_inf_min = minimum.(L_inf)
l_2_min = minimum.(L_2)

l2_iter = findmin.(L_2)

EOC = log.(l_2_min[1:(end - 1)] ./ l_2_min[2:end]) ./
      log.(particle_spacings[1:(end - 1)] ./ particle_spacings[2:end])
