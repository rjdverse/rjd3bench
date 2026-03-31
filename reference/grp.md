# Benchmarking following the Growth Rate Preservation Principle.

GRP is a method which explicitly preserves the period-to-period growth
rates of the preliminary series. It corresponds to the method of Cauley
and Trager (1981), using the solution proposed by Di Fonzo and Marini
(2011). BFGS is used as line-search algorithm for the reduced
unconstrained minimization problem.

## Usage

``` r
grp(
  s,
  t,
  objective = c("Forward", "Backward", "Symmetric", "Log"),
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  obsposition = 1L,
  eps = 1e-12,
  iter = 500L,
  dentoninitialization = TRUE
)
```

## Arguments

- s:

  A preliminary series. It must be a `"ts"` object.

- t:

  The low-frequency aggregation constraint. It must be a `"ts"` object.

- objective:

  A character string specifying the objective function. For additional
  information on this, see the package vignette.

- conversion:

  A character string specifying the conversion mode, typically `"Sum"`
  or `"Average"`. The default is `"Sum"`.

- obsposition:

  An integer specifying the position of the observations of the
  low-frequency constraint within the benchmarked series (e.g. the 7th
  month of the year). This argument is used only when
  `conversion = "UserDefined"`.

- eps:

  A numeric value specifying the convergence tolerance. The BFGS
  algorithm proceeds until the reduction in the objective function is
  within this tolerance (default is `1e-12`) or until the maximum number
  of iterations is reached.

- iter:

  An integer giving the maximum number of iterations allowed in the BFGS
  algorithm. The default is `500`.

- dentoninitialization:

  Boolean. Indicates whether the series obtained via the modified Denton
  PFD method is used as the starting values for the GRP optimization
  procedure. The default is `TRUE`. If `FALSE`, the starting values are
  derived directly from the aggregation constraint (e.g. `t/4` for
  quarterly series with annual constraint and `conversion = "Sum"`).

## Value

A `"ts"` object with the benchmarked series

## References

Causey, B., and Trager, M.L. (1981). Derivation of Solution to the
Benchmarking Problem: Trend Revision. Unpublished research notes, U.S.
Census Bureau, Washington D.C. Available as an appendix in Bozik and
Otto (1988).

Di Fonzo, T., and Marini, M. (2011). A Newton's Method for Benchmarking
Time Series according to a Growth Rates Preservation Principle. *IMF
WP/11/179*.

Daalmans, J., Di Fonzo, T., Mushkudiani, N. and Bikker, R. (2018).
Growth Rates Preservation (GRP) temporal benchmarking: Drawbacks and
alternative solutions. *Statistics Canada*.

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
data("qna_data")

Y <- ts(qna_data$B1G_Y_data[, "B1G_FF"], frequency = 1, start = c(2009, 1))
x <- denton(t = Y, nfreq = 4) + rnorm(n = length(Y) * 4, mean = 0, sd = 10)
grp(s = x, t = Y)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 4401.435 4401.478 4368.816 4382.670
#> 2010 4367.369 4394.138 4436.358 4522.235
#> 2011 4624.236 4701.365 4768.325 4762.073
#> 2012 4742.554 4717.748 4698.807 4690.591
#> 2013 4674.068 4677.785 4687.841 4673.805
#> 2014 4716.244 4740.478 4758.178 4793.100
#> 2015 4787.351 4803.442 4830.292 4872.915
#> 2016 4891.612 4926.765 4930.383 4929.640
#> 2017 4944.282 4991.178 5053.669 5160.771
#> 2018 5305.466 5395.682 5505.310 5560.942
#> 2019 5645.579 5639.614 5645.524 5583.483
#> 2020 5470.927 5395.838 5357.786 5341.949
```
