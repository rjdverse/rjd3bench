# Benchmarking by means of Cubic Splines

Cubic splines are piecewise cubic functions that are linked together in
a way to guarantee smoothness at data points. Additivity constraints are
added for benchmarking purpose and sub-period estimates are derived from
each spline. When a preliminary series is used, cubic splines are no
longer drawn based on the low-frequency constraint but the
Benchmark-to-Indicator (BI ratio) is the one being smoothed. Sub-period
estimates are then simply the product between the smoothed high
frequency BI ratio and the preliminary series.

## Usage

``` r
cubicspline(
  s = NULL,
  t,
  nfreq = 4L,
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  obsposition = 1L
)
```

## Arguments

- s:

  A preliminary series. If not `NULL`, it must be of the same class as
  `t`.

- t:

  The low-frequency aggregation constraint. It must be either an object
  of class `ts` or a numeric vector.

- nfreq:

  An integer giving the annual frequency of the benchmarked series. This
  argument is used only when no preliminary series is provided.

- conversion:

  A character string specifying the conversion mode, typically `"Sum"`
  or `"Average"`. The default is `"Sum"`.

- obsposition:

  An integer specifying the position of the observations of the
  low-frequency constraint within the benchmarked series (e.g. the 7th
  month of the year). This argument is used only when
  `conversion = "UserDefined"`.

## Value

A `"ts"` object with the benchmarked series

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
data("qna_data")
Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))

# Cubic spline without preliminary series
y1 <- cubicspline(t = Y, nfreq = 4L)

# Cubic spline with preliminary series
x1 <- y1 + rnorm(n = length(y1), mean = 0, sd = 10)
cubicspline(s = x1, t = Y)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 4397.063 4389.525 4396.652 4371.160
#> 2010 4374.149 4379.796 4451.688 4514.467
#> 2011 4622.571 4712.685 4754.705 4766.039
#> 2012 4754.643 4723.967 4692.555 4678.535
#> 2013 4672.339 4660.743 4677.626 4702.792
#> 2014 4723.708 4747.876 4770.854 4765.563
#> 2015 4787.211 4811.529 4833.484 4861.776
#> 2016 4898.182 4902.189 4932.420 4945.610
#> 2017 4967.784 4965.589 5057.696 5158.831
#> 2018 5286.200 5394.973 5502.625 5583.602
#> 2019 5630.538 5662.939 5633.391 5587.333
#> 2020 5474.084 5410.108 5354.577 5327.731

# Cubic splines used for temporal disaggregation
x2 <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
cubicspline(s = x2, t = Y)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 3817.265 4655.940 4125.907 4955.289
#> 2010 3700.042 4651.986 4059.082 5308.990
#> 2011 3869.960 4971.484 4311.150 5703.406
#> 2012 4147.811 5013.761 4419.430 5268.698
#> 2013 4159.471 4867.414 4371.355 5315.259
#> 2014 4368.250 4889.973 4383.173 5366.604
#> 2015 4219.172 5090.938 4499.862 5484.029
#> 2016 4323.788 5190.106 4608.648 5555.858
#> 2017 4571.106 5296.208 4556.676 5725.911
#> 2018 4745.996 5623.545 5073.312 6324.547
#> 2019 5083.042 5847.280 5201.402 6382.476
#> 2020 5135.178 4920.197 5120.096 6391.030
#> 2021 5361.533 6291.365 5489.010 6962.494
```
