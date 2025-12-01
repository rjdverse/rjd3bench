# Benchmarking following the growth rate preservation principle.

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

  Preliminary series. Mandatory. It must be a ts object.

- t:

  Aggregation constraint. Mandatory. It must be a ts object.

- objective:

  Objective function. See vignette and/or Daalmans et al. (2018) for
  more information.

- conversion:

  Conversion rule. "Sum" by default.

- obsposition:

  Position of the observation in the aggregated period (only used with
  "UserDefined" conversion)

- eps:

  Numeric. Defines the convergence precision. BFGS algorithm is run
  until the reduction in the objective is within this eps value (1e-12
  is the default) or until the maximum number of iterations is hit.

- iter:

  Integer. Maximum number of iterations in BFGS algorithm (500 is the
  default).

- dentoninitialization:

  indicate whether the series benchmarked via modified Denton PFD is
  used as starting values of the GRP optimization procedure (TRUE/FALSE,
  TRUE by default). If FALSE, the average benchmark is used for flow
  variables (e.g. t/4 for quarterly series with annual constraints and
  conversion = 'Sum'), or the benchmark for stock variables.

## Value

The benchmarked series is returned

## References

Causey, B., and Trager, M.L. (1981). Derivation of Solution to the
Benchmarking Problem: Trend Revision. Unpublished research notes, U.S.
Census Bureau, Washington D.C. Available as an appendix in Bozik and
Otto (1988).

Di Fonzo, T., and Marini, M. (2011). A Newton's Method for Benchmarking
Time Series according to a Growth Rates Preservation Principle. \*IMF
WP/11/179\*.

Daalmans, J., Di Fonzo, T., Mushkudiani, N. and Bikker, R. (2018).
Growth Rates Preservation (GRP) temporal benchmarking: Drawbacks and
alternative solutions. \*Statistics Canada\*.

## Examples

``` r
data("qna_data")

Y <- ts(qna_data$B1G_Y_data[, "B1G_FF"], frequency = 1, start = c(2009, 1))
x <- denton(t = Y, nfreq = 4) + rnorm(n = length(Y) * 4, mean = 0, sd = 10)
grp(s = x, t = Y)
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 4391.190 4385.290 4401.376 4376.544
#> 2010 4370.800 4387.240 4437.022 4525.038
#> 2011 4632.272 4716.528 4763.753 4743.448
#> 2012 4736.253 4716.864 4696.824 4699.759
#> 2013 4667.696 4663.047 4674.790 4707.966
#> 2014 4722.907 4757.000 4762.253 4765.840
#> 2015 4787.509 4814.325 4829.647 4862.519
#> 2016 4905.966 4906.591 4938.273 4927.570
#> 2017 4957.467 4968.445 5062.909 5161.079
#> 2018 5280.554 5394.618 5502.633 5589.595
#> 2019 5635.901 5670.028 5638.706 5569.565
#> 2020 5471.618 5409.293 5365.378 5320.211
```
