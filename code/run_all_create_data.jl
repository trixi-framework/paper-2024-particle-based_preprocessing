# Create data for the qualitative plots
include(joinpath(@__DIR__, "code", "qualitative", "create_data.jl"))

# Create data for the quantitative plots
include(joinpath(@__DIR__, "code", "quantitative", "create_data.jl"))

# Create data for the multi-body packing plots
include(joinpath(@__DIR__, "code", "multi_body_packing", "aorta_joined.jl"))
