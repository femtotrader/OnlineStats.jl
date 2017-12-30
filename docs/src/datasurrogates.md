```@setup setup
Pkg.add("Plots")
Pkg.add("GR")
ENV["GKSwstype"] = "100"
using OnlineStats
using Plots
srand(123)
gr()
```

# Data Surrogates

Some `OnlineStat`s are especially useful for out-of-core computations.  After they've been fit, they act as a data stand-in to get summaries, quantiles, regressions, etc, without the need to revisit the entire dataset again.

## Summarize Partitioned Data

The [`Partition`](@ref) type summarizes sections of a data stream using any `OnlineStat`. 
`Partition` has a fallback plot recipe that works for most `OnlineStat`s and specific plot
recipes for [`Variance`](@ref) (summarizes with mean and 95% CI) and [`CountMap`](@ref) (see below).

```@example setup
using OnlineStats, Plots

y = rand(["a", "a", "b", "c"], 10^6)

o = Partition(CountMap(String))

s = Series(y, o)

plot(s)
savefig("partition.png"); nothing # hide
```

![](partition.png)

```@example setup
using OnlineStats, Plots

y = cumsum(randn(10^6))

o = Partition(Mean())
o2 = Partition(Extrema())

s = Series(y, o, o2)

plot(s)
savefig("partition2.png"); nothing # hide
```

![](partition2.png)

## Linear Regressions

See [`LinRegBuilder`](@ref)

## Histograms

The [`Hist`](@ref) type for online histograms has a 
[Plots.jl](https://github.com/JuliaPlots/Plots.jl) recipe and can also be used to calculate 
approximate summary statistics, without the need to revisit the actual data.

```@example setup
o = Hist(100)
s = Series(o)

fit!(s, randexp(100_000))

quantile(o, .5)
quantile(o, [.2, .8])
mean(o)
var(o)
std(o)

using Plots
plot(o)
savefig("hist.png"); nothing # hide
```

![](hist.png)
