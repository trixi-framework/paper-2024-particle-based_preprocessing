using Plots
include(joinpath("..", "..", "auxiliary_functions.jl"))

data_dir = joinpath(OUT_DIR, "performance", "benchmarks_bunny")

nfaces_labels = ["25k" "75k" "100k" "125k" "150k" "300k" "500k" "1M" "1.5M"]
nfaces = [2500, 7500, 10000, 12500, 15000, 30000, 50000, 100000, 150000]
label_spacings = "L/" .* ["25" "50" "75" "100" "125" "150" "200" "250"]
nlayers = 6


mkpath(joinpath(FIG_DIR, "performance", "face_nhs"))

L = 10.0 # domain length

function data(nfaces)
    nfaces = nfaces == "1.5M" ? nfaces = "1500k" : nfaces
    nfaces = nfaces == "1M" ? nfaces = "1000k" : nfaces
    return TrixiParticles.CSV.read(joinpath(data_dir,
                                            "bunny_" * nfaces * "_meta_data.csv"),
                                   TrixiParticles.DataFrame)
end

n_faces_mean = zeros(length(label_spacings), length(nfaces_labels))
size_face_mean = zeros(length(nfaces_labels))

particle_spacings = data(first(nfaces_labels))[!, "particle spacing"]

for nlayers in [3, 6]
    for (i, nfaces) in enumerate(nfaces_labels)
        n_faces_mean[:, i] .= data(nfaces)[!,
                                           "nhs: mean #faces per cell (#layers $nlayers)"]
        size_face_mean[i] = first(data(nfaces)[!, "mean face size"])
    end

    face_ratio = round.(Int, L ./ size_face_mean)

    line_colors = color_scheme(length(nfaces_labels))

    p1 = plot(particle_spacings, n_faces_mean, yaxis=:log, xaxis=:log, ylims=(1e1, 1e5),
              xticks=(particle_spacings[1:2:end], label_spacings[1:2:end]),
              size=1.2 .* (400, 200),
              palette=line_colors.colors, label="face size ≈ L / " .* string.(face_ratio'),
              legend=:outerright, xlabel=L"\Delta x", ylabel="Mean # faces per cell")

    savefig(p1,
            joinpath(FIG_DIR, "performance", "face_nhs",
                     "analyse_nhs_$nlayers" * ".pdf"))
end
