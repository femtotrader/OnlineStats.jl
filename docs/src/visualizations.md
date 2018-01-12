```@setup setup
Pkg.add("GR")
Pkg.add("Plots")
ENV["GKSwstype"] = "100"
using OnlineStats
using Plots
srand(1234)
gr()
```

# Visualizations

## Plotting a Series plots the contained OnlineStats

```@example setup
s = Series(randn(10^6), Hist(25), Hist(-5:5))
plot(s)
savefig("plot_series.png"); nothing # hide
```

![](plot_series.png)


## Partitions

The [`Partition`](@ref) type summarizes sections of a data stream using any `OnlineStat`, 
and is therefore extremely useful in visualizing huge datasets, as summaries are plotted
rather than every single observation.  

![](https://user-images.githubusercontent.com/8075494/34622053-9a69f9b2-f219-11e7-8ed7-f203a47f64f1.gif)

#### Continuous Data

```@example setup
y = cumsum(randn(10^6)) + 100randn(10^6)

o = Partition(Hist(50))

s = Series(y, o)

plot(s)
savefig("partition_hist.png"); nothing # hide
```
![](partition_hist.png)


```@example setup
o = Partition(Mean())
o2 = Partition(Extrema())

s = Series(y, o, o2)

plot(s, layout=1)
savefig("partition_mean_ex.png"); nothing # hide
```
![](partition_mean_ex.png)


#### Plot a custom function of the `OnlineStat`s (default is `value`)

```@example setup
o = Partition(Variance())

s = Series(y, o)

# μ ± σ
plot(o, x -> [mean(x) - std(x), mean(x), mean(x) + std(x)])

savefig("partition_ci.png"); nothing # hide  
```
![](partition_ci.png)


#### Categorical Data

```@example setup
y = rand(["a", "a", "b", "c"], 10^6)

o = Partition(CountMap(String), 75)

s = Series(y, o)

plot(o)
savefig("partition_countmap.png"); nothing # hide
```
![](partition_countmap.png)


## Indexed Partitions

The `Partition` type can only track the number of observations in the x-axis.  If you wish
to plot one variable against another, you can use an `IndexedPartition`.  

```@example setup
x = rand(Date(2000):Date(2020), 10^5)
y = Dates.year.(x) + randn(10^5)

s = Series([x y], IndexedPartition(Date, Hist(20)))

plot(s)
savefig("indexpart1.png"); nothing # hide
```
![](indexpart1.png)


```@example setup
x = randn(10^5)
y = x + randn(10^5)

s = Series([x y], IndexedPartition(Float64, Hist(20)))

plot(s, xlab = "X")
savefig("indexpart2.png"); nothing # hide
```
![](indexpart2.png)

```@example setup
x = rand('a':'z', 10^5)
y = Float64.(x) + randn(10^5)

s = Series([x y], IndexedPartition(Char, Extrema()))

plot(s)
savefig("indexpart3.png"); nothing # hide
```
![](indexpart3.png)

```@example setup
x = rand(1:5, 10^5)
y = rand(1:5, 10^5)

s = Series([x y], IndexedPartition(Int, CountMap(Int)))

plot(s, xlab = "X")
savefig("indexpart4.png"); nothing # hide
```
![](indexpart4.png)