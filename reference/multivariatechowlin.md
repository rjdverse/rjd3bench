# Multivariate Temporal Disaggregaton of a System of Time Series by Regression Models.

Performs simultaneous temporal disaggregation of a system of low
frequency time series into higher frequency series, based on the
multivariate extension of the Chow-Lin model or the Random Walk approach
(Fernandez).

## Usage

``` r
multivariatechowlin(
  series,
  constant = TRUE,
  trend = FALSE,
  indicators = NULL,
  ccseries = NULL,
  ccdefinition = NULL,
  freq = 4L,
  rhos = 1,
  var = c("fromUnivariate", "allEquals", "userDefined"),
  var.includeCov = FALSE,
  var.shrinkCov = FALSE,
  var.matrix = NULL,
  rescale.variance = FALSE
)
```

## Arguments

- series:

  A named list of `ts` objects containing the low frequency time series
  to be disaggregated.

- constant:

  Either a Boolean or a vector of Booleans. If a vector is provided,
  each element specifies whether a constant term is included in the
  model for each series, following the order in which they appear in the
  `series` object. The length of the the vector must match the number of
  series. If a single Boolean is provided (default if `TRUE`), it is
  applied to all series. Note that this argument is used only with
  Chow-Lin model (i.e., when `rhos` values are strictly less than 1).
  For further details, see the package vignette.

- trend:

  Either a Boolean or a vector of Booleans. If a vector is provided,
  each element specifies whether a linear trend is included in the model
  for each series, following the order in which they appear in the
  `series` object. The length of the the vector must match the number of
  series. If a single Boolean is provided (default if `FALSE`), it is
  applied to all series.

- indicators:

  a named list of `ts` objects or a named list of a list of `ts`
  objects. Each element represents one or more high-frequency indicator
  series associated with each series. If an element is `NULL`, no
  indicator is used for the corresponding series. The default value is
  `NULL`, meaning that no indicators are used for any series.

- ccseries:

  A named list of `ts` objects containing the contemporaneous
  constraints. If `NULL` (the default), no contemporaneous constraints
  can be considered.

- ccdefinition:

  A character vector defining each contemporaneous constraints. The
  elements of the vector must be written in the form \\z=w_1
  y_1+\ldots+w_n y_n\\ or \\c=w_1 y_1+\ldots+w_n y_n\\ where:

  - \\z\\ is the name of a contemporaneous constraint,

  - \\(w_1,\ldots,w_n)\\ are optional numeric weights,

  - \\(y_1,\ldots,y_n)\\ are the names of the time series and

  - \\c\\ is a constant. The default is `NULL`, meaning that no
    contemporaneous constraint is considered.

- freq:

  An integer giving the annual frequency of the disaggregated series.
  This argument is ignored when at least one indicator series is
  provided for any series.

- rhos:

  Either a numeric value or a vector of numerics. If a vector is
  provided, each element specifies the value of the `rho` parameter
  associated to each series, following the order in which they appear in
  the `series` object. The length of the the vector must match the
  number of series. If a single numeric value is provided (default if
  `1`, corresponding to the Fernandez model), it is applied to all
  series.

- var:

  A character string specifying the method used to estimate the
  variance-covariance matrix of the innovations. The default is
  `"fromUnivariate"`, meaning that it is estimated empirically from the
  residuals of the univariate models. Others options include
  `"allEquals"`, which assume a diagonal matrix with identical variances
  (a strong assumption), and `"userDefined"`, where the matrix is
  supplied by the user via the `var.matrix` argument. For additional
  details, see the package vignette.

- var.includeCov:

  Boolean. Indicates whether non-diagonal elements of the innovation
  variance-covariance matrix may as well be estimated from the residuals
  of the univariate models. The default is `FALSE`, meaning that only a
  diagonal matrix is estimated. This argument is used only when
  `var = "fromUnivariate"`.

- var.shrinkCov:

  Boolean. Indicates whether a shrinkage estimator should be used for
  covariance. See the package vignette for more details. This argument
  is used only when `var = "fromUnivariate"` and
  `var.includeCov = TRUE`.

- var.matrix:

  The variance-covariance matrix of the innovations. This argument is
  used only when `var = "userDefined"` and must be provided in that
  case.

- rescale.variance:

  Boolean. Indicates whether the variance of the estimates should be
  rescaled based on the model residuals. The default is `FALSE`. This
  option has no impact on the disaggregated series, but affects the
  standard errors of both the disaggregated series and the estimated
  coefficients. See the package vignette for more details.

## Value

An object of class "JD3_MULTITEMPDISAGG_RSLTS" is returned. The
following are returned as a list:

- `regression` `[[1]]` regression coefficients for each series;

- `estimation` `[[2]]` disaggregated time series and standard errors,
  regression effects, smoothing parts, parameters and
  variance-covariance matrix of the innovations;

## Vignette

For more information on the method, its arguments, and the other methods
available in the package, see the package vignette:

- In R: `browseVignettes(package = "rjd3bench")`

- Online: <https://rjdverse.github.io/rjd3bench/articles/rjd3bench.html>

## See also

[`multivariatecholette()`](https://rjdverse.github.io/rjd3bench/reference/multivariatecholette.md)
for time series reconciliation.

## Examples

``` r
# Low-frequency data
Y1 <- ts(c(30.0, 30.6, 31.2, 31.6), frequency = 1, start = c(2010, 1))
Y2 <- ts(c(80.0, 81.2, 82.5, 82.6), frequency = 1, start = c(2010, 1))
Y3 <- ts(c(8.0, 8.1, 8.2, 8.2), frequency = 1, start = c(2010, 1))
lf_series <- list(y1 = Y1, y2 = Y2, y3 = Y3)

# Contemporaneous constraint
z <- ts(c(27.1, 29.8, 29.9, 31.2, 29.4, 27.9, 30.9, 31.7, 29.2, 30.2, 30.6, 31.9, 29.3, 30.4, 30.7, 32.0),
        frequency = 4,
        start = c(2010, 1))

# High-frequency indicators
x11 <- ts(c(7.0, 7.2, 8.1, 7.5, 8.5, 7.8, 8.1, 8.4, 8.6, 7.8, 8.0, 8.3, 8.7, 7.9, 8.0, 8.6),
          frequency = 4,
          start=c(2010, 1))
x12 <- ts(c(18.0, 19.5, 19.0, 19.7, 18.5, 19.0, 20.3, 20.0, 18.6, 19.5, 20.4, 20.1, 18.7, 19.1, 20.4, 20.8),
          frequency = 4,
          start = c(2010, 1))
x2 <- NULL
x3 <- ts(c(1.5, 1.8, 2.0, 2.5, 2.0, 1.5, 1.7, 2.1, 2.1, 1.6, 1.6, 2.2, 2.3, 1.7, 1.9, 2.3),
         frequency = 4,
         start = c(2010, 1))
indic_series <- list(y1 = list(x11, x12),
                     y2 = NULL,
                     y3 = x3)

# Check consistency between temporal and contemporaneous constraints
rowSums(cbind(Y1,Y2,Y3)) - stats::aggregate.ts(z) # should all be 0
#> Time Series:
#> Start = 2010 
#> End = 2013 
#> Frequency = 1 
#> [1]  0.000000e+00  1.421085e-14  0.000000e+00 -1.421085e-14

# Estimate models and get results

## Mix Chow-Lin and Fernandez definitions

### with var-cov matrix estimated from the univariate models, assuming zero covariances
mtd1 <- multivariatechowlin(series = lf_series,
                            constant = c(FALSE, FALSE, TRUE),
                            trend = c(FALSE, FALSE, FALSE),
                            indicators = indic_series,
                            ccseries = list(z = z),
                            ccdefinition = "z=y1+y2+y3",
                            freq = 4L,
                            rhos = c(0.85, 1.0, 0.9),
                            var = "fromUnivariate",
                            var.includeCov = FALSE,
                            var.shrinkCov = FALSE)

mtd1$estimation$var$vcov # variance-covariance matrix of the innovations
#>             [,1]       [,2]         [,3]
#> [1,] 0.001433366 0.00000000 0.0000000000
#> [2,] 0.000000000 0.01248872 0.0000000000
#> [3,] 0.000000000 0.00000000 0.0008793077
do.call(cbind, mtd1$estimation$disagg) # disaggregated series
#>               y1       y2       y3
#> 2010 Q1 6.939861 19.07979 1.080352
#> 2010 Q2 7.943542 20.14422 1.712236
#> 2010 Q3 7.103801 20.64915 2.147051
#> 2010 Q4 8.012796 20.12684 3.060361
#> 2011 Q1 6.722478 20.39456 2.282963
#> 2011 Q2 7.460648 19.08720 1.352157
#> 2011 Q3 8.389319 20.65066 1.860018
#> 2011 Q4 8.027555 21.06758 2.604862
#> 2012 Q1 6.733189 19.97505 2.491760
#> 2012 Q2 7.940522 20.65187 1.607612
#> 2012 Q3 8.411698 20.64922 1.539082
#> 2012 Q4 8.114591 21.22386 2.561545
#> 2013 Q1 6.795370 19.97402 2.530611
#> 2013 Q2 7.800783 21.12535 1.473870
#> 2013 Q3 8.533515 20.43936 1.727128
#> 2013 Q4 8.470332 21.06128 2.468392
do.call(cbind, mtd1$estimation$edisagg) # standard errors of the disaggregated series
#>                 y1         y2         y3
#> 2010 Q1        NaN        NaN        NaN
#> 2010 Q2        NaN        NaN        NaN
#> 2010 Q3        NaN        NaN        NaN
#> 2010 Q4        NaN        NaN        NaN
#> 2011 Q1 0.03913112 0.04196818 0.02434811
#> 2011 Q2 0.02340147 0.03359607 0.02945418
#> 2011 Q3 0.02800451 0.03102548 0.01904528
#> 2011 Q4 0.02767551 0.03865019 0.03038005
#> 2012 Q1 0.03830267 0.04285251 0.02996976
#> 2012 Q2 0.02426885 0.03137846 0.02520939
#> 2012 Q3 0.02668464 0.03353943 0.02737756
#> 2012 Q4 0.02767089 0.03767300 0.02894481
#> 2013 Q1 0.04082766 0.04553842 0.03185251
#> 2013 Q2 0.02391011 0.03567312 0.03129337
#> 2013 Q3 0.02925037 0.03247505 0.02145259
#> 2013 Q4 0.03205933 0.04177237 0.02975162

### with var-cov matrix estimated from the univariate models, using a shrinkage estimator for the covariance
mtd2 <- multivariatechowlin(series = lf_series,
                            constant = c(FALSE, FALSE, TRUE),
                            trend = c(FALSE, FALSE, FALSE),
                            indicators = indic_series,
                            ccseries = list(z = z),
                            ccdefinition = "z=y1+y2+y3",
                            freq = 4L,
                            rhos = c(0.85, 1.0, 0.9),
                            var = "fromUnivariate",
                            var.includeCov = TRUE,
                            var.shrinkCov = TRUE)

mtd2$estimation$var$vcov
#>               [,1]          [,2]          [,3]
#> [1,]  1.295161e-03 -0.0011701081 -8.709044e-05
#> [2,] -1.170108e-03  0.0124887216  3.869829e-04
#> [3,] -8.709044e-05  0.0003869829  5.469873e-05
do.call(cbind, mtd2$estimation$disagg)
#>               y1       y2       y3
#> 2010 Q1 7.032124 18.38361 1.684270
#> 2010 Q2 7.867589 20.02459 1.907825
#> 2010 Q3 7.119255 20.72811 2.052637
#> 2010 Q4 7.981033 20.86370 2.355269
#> 2011 Q1 6.819908 20.48156 2.098528
#> 2011 Q2 7.561817 18.55115 1.787037
#> 2011 Q3 8.271285 20.64734 1.981372
#> 2011 Q4 7.946990 21.51995 2.233063
#> 2012 Q1 6.910851 20.10656 2.182591
#> 2012 Q2 7.892070 20.40384 1.904089
#> 2012 Q3 8.348688 20.36685 1.884465
#> 2012 Q4 8.048390 21.62275 2.228855
#> 2013 Q1 6.989663 20.10942 2.200913
#> 2013 Q2 7.713462 20.82079 1.865750
#> 2013 Q3 8.479224 20.27804 1.942738
#> 2013 Q4 8.417651 21.39175 2.190598
do.call(cbind, mtd2$estimation$edisagg)
#>                 y1         y2          y3
#> 2010 Q1        NaN        NaN         NaN
#> 2010 Q2        NaN        NaN         NaN
#> 2010 Q3        NaN        NaN         NaN
#> 2010 Q4        NaN        NaN         NaN
#> 2011 Q1 0.03864249 0.03703555 0.007587635
#> 2011 Q2 0.02316806 0.02491433 0.013169227
#> 2011 Q3 0.02774779 0.02658016 0.005866159
#> 2011 Q4 0.02773848 0.02863357 0.012295687
#> 2012 Q1 0.03750810 0.03678671 0.011896099
#> 2012 Q2 0.02409236 0.02446696 0.010436899
#> 2012 Q3 0.02617920 0.02674504 0.011862534
#> 2012 Q4 0.02772939 0.02812739 0.011246403
#> 2013 Q1 0.04000515 0.03923857 0.012754946
#> 2013 Q2 0.02372702 0.02587995 0.014001100
#> 2013 Q3 0.02882478 0.02793242 0.007815651
#> 2013 Q4 0.03207397 0.03165254 0.010269251

## Multivariate random walk model (multivariate Fernandez)

### with var-cov matrix provided by the user
mtd3 <- multivariatechowlin(series = lf_series,
                            constant = FALSE,
                            trend = FALSE,
                            indicators = indic_series,
                            ccseries = list(z = z),
                            ccdefinition = "z=y1+y2+y3",
                            freq = 4L,
                            rhos = 1.0,
                            var = "userDefined",
                            var.matrix = matrix(
                                c(0.005, 0.002, 0.001,
                                0.002, 0.010, 0.002,
                                0.001, 0.002, 0.003),
                                nrow = 3,
                                byrow = TRUE
                            ),
                            rescale.variance = TRUE
)

mtd3$estimation$var$vcov
#>       [,1]  [,2]  [,3]
#> [1,] 0.005 0.002 0.001
#> [2,] 0.002 0.010 0.002
#> [3,] 0.001 0.002 0.003
do.call(cbind, mtd3$estimation$disagg)
#>               y1       y2       y3
#> 2010 Q1 6.108983 19.72409 1.266923
#> 2010 Q2 8.107219 19.93250 1.760283
#> 2010 Q3 7.529320 20.21029 2.160388
#> 2010 Q4 8.254477 20.13312 2.812406
#> 2011 Q1 6.686679 20.40719 2.306128
#> 2011 Q2 6.797711 19.73210 1.370185
#> 2011 Q3 8.685776 20.33348 1.880741
#> 2011 Q4 8.429835 20.72722 2.542946
#> 2012 Q1 6.400284 20.43743 2.362291
#> 2012 Q2 7.685207 20.74189 1.772905
#> 2012 Q3 8.618610 20.41449 1.566905
#> 2012 Q4 8.495899 20.90620 2.497900
#> 2013 Q1 6.451413 20.47755 2.371039
#> 2013 Q2 7.378121 21.19157 1.830307
#> 2013 Q3 8.590304 20.39480 1.714896
#> 2013 Q4 9.180162 20.53608 2.283757
do.call(cbind, mtd3$estimation$edisagg)
#>                y1        y2        y3
#> 2010 Q1       NaN       NaN       NaN
#> 2010 Q2       NaN       NaN       NaN
#> 2010 Q3       NaN       NaN       NaN
#> 2010 Q4       NaN       NaN       NaN
#> 2011 Q1 0.1887001 0.1721895 0.1313514
#> 2011 Q2 0.1768384 0.1439582 0.1597332
#> 2011 Q3 0.1474180 0.1386457 0.1005168
#> 2011 Q4 0.1655040 0.1632306 0.1581790
#> 2012 Q1 0.1933443 0.1829683 0.1543762
#> 2012 Q2 0.1515687 0.1332124 0.1353025
#> 2012 Q3 0.1447318 0.1504482 0.1356600
#> 2012 Q4 0.1654931 0.1619985 0.1521338
#> 2013 Q1 0.2062398 0.1935101 0.1669869
#> 2013 Q2 0.1987983 0.1584319 0.1710552
#> 2013 Q3 0.1444905 0.1360310 0.1123450
#> 2013 Q4 0.2397080 0.2060323 0.1679165
```
