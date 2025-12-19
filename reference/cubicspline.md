# Benchmarking by means of cubic splines

Cubic splines are piecewise cubic functions that are linked together in
a way to guarantee smoothness at data points. Additivity constraints are
added for benchmarking purpose and sub-period estimates are derived from
each spline. When a sub-period indicator (or a preliminary series) is
used, cubic splines are no longer drawn based on the low frequency data
but the Benchmark-to-Indicator (BI ratio) is the one being smoothed.
Sub- period estimates are then simply the product between the smoothed
high frequency BI ratio and the indicator.

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

  Preliminary series. If not NULL, it must be the same class as t.

- t:

  Aggregation constraint. Mandatory. it must be either an object of
  class ts or a numeric vector.

- nfreq:

  Integer. Annual frequency of the benchmarked series. Used if no
  preliminary series is provided.

- conversion:

  Conversion rule. Usually "Sum" or "Average". Sum by default.

- obsposition:

  Integer. Postion of the observation in the aggregated period (only
  used with "UserDefined" conversion)

## Value

The benchmarked series is returned

## See also

For more information, see the vignette:

[`browseVignettes`](https://rdrr.io/r/utils/browseVignettes.html)
`browseVignettes(package = "rjd3bench")`

## Examples

``` r
data("qna_data")
Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))

# cubic spline without preliminary series
y1 <- cubicspline(t = Y, nfreq = 4L)

# cubic spline with preliminary series
x1 <- y1 + rnorm(n = length(y1), mean = 0, sd = 10)
cubicspline(s = x1, t = Y)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 4400.337 4385.278 4399.957 4368.828
#> 2010 4363.614 4391.251 4439.493 4525.742
#> 2011 4639.636 4712.704 4745.943 4757.717
#> 2012 4743.745 4711.949 4701.552 4692.454
#> 2013 4675.787 4673.251 4683.889 4680.572
#> 2014 4714.546 4745.824 4765.462 4782.169
#> 2015 4801.393 4797.330 4832.282 4862.994
#> 2016 4906.571 4893.879 4934.591 4943.359
#> 2017 4952.752 4979.728 5057.345 5160.075
#> 2018 5275.700 5404.686 5494.949 5592.064
#> 2019 5630.302 5665.310 5641.002 5577.587
#> 2020 5470.537 5403.901 5358.985 5333.077

# cubic splines used for temporal disaggregation
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
