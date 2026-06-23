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
  var.matrix = NULL
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
  `"fromUnivariate"`, meaning that is is estimated from the residuals of
  the univariate models. Others options include `"allEquals"`, which
  assume a diagonal matrix with identical variances (a strong
  assumption), and `"userDefined"`, where the matrix is supplied by the
  user via the `var.matrix` argument. For additional details, see the
  package vignette.

- var.matrix:

  The variance-covariance matrix of the innovations. This argument is
  only used when `var = "userDefined"` and must be provided in that
  case.

## Value

An object of class "JD3_MULTITEMPDISAGG_RSLTS" is returned. The
following are returned invisibly as a list:

- `regression` `[[1]]` regression coefficients for each series;

- `estimation` `[[2]]` disaggregated Time-Series and standard deviation
  for each series, regression effects, smoothing part, parameter and
  variance-covariance matrix;

## See also

[`multivariatecholette()`](https://rjdverse.github.io/rjd3bench/reference/multivariatecholette.md)
for time series reconciliation.

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
# Low-frequency data
Y1 <- ts(c(30.0, 30.6, 31.2, 31.6), frequency = 1, start = c(2010,1))
Y2 <- ts(c(80.0, 81.2, 82.5, 82.6), frequency = 1, start = c(2010,1))
Y3 <- ts(c(8.0, 8.1, 8.2, 8.2), frequency = 1, start = c(2010,1))
lf_series <- list(y1 = Y1, y2 = Y2, y3 = Y3)

# Contemporaneous constraint
z <- ts(c(27.1,29.8,29.9,31.2,29.4,27.9,30.9,31.7,29.2,30.2,30.6,31.9,29.3,30.4,30.7,32.0), frequency = 4, start = c(2010,1))

# High-frequency indicators
x11 <- ts(c(7,7.2,8.1,7.5,8.5,7.8,8.1,8.4,8.6,7.8,8.0,8.3,8.7,7.9,8.0,8.6), frequency=4, start=c(2010,1))
x12 <- ts(c(18,19.5,19.0,19.7,18.5,19.0,20.3,20.0,18.6,19.5,20.4,20.1,18.7,19.1,20.4,20.8), frequency = 4, start = c(2010,1))
x2 <- NULL
x3 <- ts(c(1.5,1.8,2,2.5,2.0,1.5,1.7,2.1,2.1,1.6,1.6,2.2,2.3,1.7,1.9,2.3), frequency = 4, start = c(2010,1))
indic_series = list(y1 = list(x11, x12),
                    y2 = NULL,
                    y3 = x3)

# Check consistency between temporal and contemporaneous constraints
rowSums(cbind(Y1,Y2,Y3)) - stats::aggregate.ts(z) # ok!
#> Time Series:
#> Start = 2010 
#> End = 2013 
#> Frequency = 1 
#> [1]  0.000000e+00  1.421085e-14  0.000000e+00 -1.421085e-14

# Estimate models and get results

## Mix Chow-Lin - Fernandez
rslt1 <- multivariatechowlin(series = lf_series,
                             constant = c(FALSE, FALSE, TRUE),
                             trend = c(FALSE, FALSE, FALSE),
                             indicators = indic_series,
                             ccseries = list(z = z),
                             ccdefinition = "z=y1+y2+y3",
                             freq = 4L,
                             rhos = c(0.85, 1.0, 0.9),
                             var = "fromUnivariate",
                             var.matrix = NULL)

d1 <- do.call(cbind, rslt1$estimation$disagg)
ed1 <- do.call(cbind, rslt1$estimation$edisagg)

## Fernandez only (Random walk model) with user-defined variance-covariance matrix
rslt2 <- multivariatechowlin(series = lf_series,
                             constant = FALSE,
                             trend = FALSE,
                             indicators = indic_series,
                             ccseries = list(z = z),
                             ccdefinition = "z=y1+y2+y3",
                             freq = 4L,
                             rhos = 1.0,
                             var = "userDefined",
                             var.matrix = diag(c(0.003,0.01,0.001)))

d2 <- do.call(cbind, rslt2$estimation$disagg)
ed2 <- do.call(cbind, rslt2$estimation$edisagg)
```
