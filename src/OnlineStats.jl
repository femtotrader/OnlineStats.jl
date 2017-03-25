module OnlineStats

import StatsBase
importall StatsBase
using LearnBase
importall LearnBase

# Reexport LearnBase
for pkg in [:LearnBase]
    eval(Expr(:toplevel, Expr(:export, setdiff(names(eval(pkg)), [pkg])...)))
end

export
    Series, Stats,
    # Weight
    EqualWeight, BoundedEqualWeight, ExponentialWeight, LearningRate, LearningRate2,
    # functions
    maprows, nups,
    # <: OnlineStat
    Mean, Variance, Extrema, OrderStatistics, Moments, QuantileSGD, QuantileMM,
    MV

#-----------------------------------------------------------------------------# types
abstract type Input end
abstract type ScalarInput    <: Input end  # observation = scalar
abstract type VectorInput    <: Input end  # observation = vector
Base.show(io::IO, o::Input) = print(io, replace(string(o), "OnlineStats.", ""))

abstract type OnlineStat{I <: Input} end

"AbstractSeries: Subtypes have fields: stats, weight, nobs, nups, id"
abstract type AbstractSeries end

const AA        = AbstractArray
const VecF      = Vector{Float64}
const MatF      = Matrix{Float64}
const AVec{T}   = AbstractVector{T}
const AMat{T}   = AbstractMatrix{T}
const AVecF     = AVec{Float64}
const AMatF     = AMat{Float64}

include("show.jl")


#---------------------------------------------------------------------------# helpers
input_type{I <: Input}(o::OnlineStat{I}) = I
value(o::OnlineStat) = getfield(o, fieldnames(o)[1])



smooth(m::Float64, v::Real, γ::Float64) = m + γ * (v - m)
function smooth!(m::AbstractArray, v::AbstractArray, γ::Float64)
    length(m) == length(v) || throw(DimensionMismatch())
    for i in eachindex(v)
        @inbounds m[i] = smooth(m[i], v[i], γ)
    end
end
subgrad(m::Float64, γ::Float64, g::Real) = m - γ * g
function smooth_syr!(A::AMat, x::AVec, γ::Float64)
    @assert size(A, 1) == length(x)
    for j in 1:size(A, 2), i in 1:j
        @inbounds A[i, j] = (1.0 - γ) * A[i, j] + γ * x[i] * x[j]
    end
end
function smooth_syrk!(A::MatF, x::AMat, γ::Float64)
    BLAS.syrk!('U', 'T', γ / size(x, 1), x, 1.0 - γ, A)
end



Base.copy(o::OnlineStat) = deepcopy(o)

# #-----------------------------------------------------------------------------# merge
# function Base.merge(o::OnlineStat, o2::OnlineStat, method::Symbol = :append)
#     merge!(copy(o), o2, method)
# end
# function Base.merge(o::OnlineStat, o2::OnlineStat, wt::Float64)
#     merge!(copy(o), o2, wt)
# end
#
# function Base.merge!(o::OnlineStat, o2::OnlineStat, method::Symbol = :append)
#     @assert typeof(o) == typeof(o2)
#     if nobs(o2) == 0
#         return o
#     end
#     updatecounter!(o, nobs(o2))
#     if method == :append
#         _merge!(o, o2, weight(o, nobs(o2)))
#     elseif method == :mean
#         _merge!(o, o2, 0.5 * (weight(o) + weight(o2)))
#     elseif method == :singleton
#         _merge!(o, o2, weight(o))
#     end
#     o
# end

# function Base.merge!(o::OnlineStat, o2::OnlineStat, wt::Float64)
#     @assert typeof(o) == typeof(o2)
#     updatecounter!(o, nobs(o2))
#     _merge!(o, o2, wt)
#     o
# end




# epsilon used in special cases to avoid dividing by 0, etc.
const ϵ = 1e-8

#---------------------------------------------------------------------------# maprows
"""
Perform operations on data in blocks.

`maprows(f::Function, b::Integer, data...)`

This function iteratively feeds `data` in blocks of `b` observations to the
function `f`.  The most common usage is with `do` blocks:

```julia
# Example 1
y = randn(50)
o = Variance()
maprows(10, y) do yi
    fit!(o, yi)
    println("Updated with another batch!")
end
```
"""
function maprows(f::Function, b::Integer, data...)
    n = size(data[1], 1)
    i = 1
    while i <= n
        rng = i:min(i + b - 1, n)
        batch_data = map(x -> rows(x, rng), data)
        f(batch_data...)
        i += b
    end
end


#----------------------------------------------------------------------# source files
include("weight.jl")
include("series.jl")
include("scalarinput/summary.jl")
include("vectorinput/mv.jl")


end # module
