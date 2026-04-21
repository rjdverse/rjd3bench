# Interpolation of an Atypical Frequency Series by Regression Models.

Perform temporal interpolation of low-frequency to high-frequency time
series by regression models. The implemented models include Chow-Lin,
Fernandez, Litterman and some variants of those algorithms. The
`temporal_interpolation_raw()` function extends
[`temporal_interpolation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation.md)
by allowing temporal interpolation for any frequency ratio.

## Usage

``` r
temporal_interpolation_raw(
  series,
  constant = TRUE,
  trend = FALSE,
  indicators = NULL,
  startoffset = 0L,
  model = c("Ar1", "Rw", "RwAr1"),
  freqratio,
  obsposition = -1L,
  rho = 0,
  rho.fixed = FALSE,
  rho.truncated = 0,
  zeroinitialization = FALSE,
  diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
  diffuse.regressors = FALSE,
  nbcsts = 0L,
  nfcsts = 0L
)
```

## Arguments

- series:

  A low-frequency time series to be interpolated. It must be a numeric
  vector.

- constant:

  Boolean. Indicates whether a constant term is included in the model.
  The default is `TRUE`. Note that this argument is used only with
  `model = "Ar1"` when `zeroinitialization = FALSE`. For additional
  information, see the package vignette.

- trend:

  Boolean. Indicates whether a linear trend is included in the model.
  The default is `FALSE`.

- indicators:

  One or more high‑frequency indicator series used in the interpolation.
  If `NULL` (the default), no indicator is used. When provided, the
  argument must be a numeric vector or a matrix.

- startoffset:

  The number of initial observations in the indicator series that
  precede the start of the low-frequency series. The value must be
  either 0 or a positive integer (default is 0). This argument is
  ignored when no indicator is provided.

- model:

  A character string specifying the model of the error term at the
  disaggregated level. The options are: `"Ar1"` (Chow Lin, the default),
  `"Rw"` (Fernandez), and `"RwAr1"` (Litterman).

- freqratio:

  An integer specifying the frequency ratio between the interpolated
  series and the low-frequency series. This argument is mandatory and
  must be a positive integer.

- obsposition:

  An integer specifying the position of the low-frequency observations
  within the interpolated series (e.g. the 1st month of the year, the 2d
  month, etc.). The value must be a positive integer or `-1` (the
  default).The default value is equivalent to setting the value of the
  parameter equal to the frequency of the series, meaning that the last
  value of the interpolated series is consistent with the low-frequency
  series.

- rho:

  A numeric value giving the (initial) value of the autoregressive
  parameter. This argument is used only for `"Ar1"` and `"RwAr1"`
  models.

- rho.fixed:

  Boolean. Specifies whether the supplied value of `rho` is fixed. The
  default is `FALSE`, which indicates that `rho` is estimated.

- rho.truncated:

  A numeric value defining the lower bound of the admissible range for
  `rho`. The evaluation range is `[rho.truncated, 1]`.

- zeroinitialization:

  Boolean. If `TRUE`, the initial values of the autoregressive model are
  set to zero. The default is `FALSE`.

- diffuse.algorithm:

  A character string specifying the algorithm used for diffuse
  initialization. The default is `"SqrtDiffuse"`. Other options are:
  `"Diffuse"` and `"Augmented"`.

- diffuse.regressors:

  Boolean. Indicates whether the coefficients of the regression model
  are treated as diffuse (`TRUE`) or as fixed unknown (`FALSE`, the
  default).

- nbcsts:

  An integer specifying the number of backcast periods. This argument is
  ignored when one or more indicator series is provided.

- nfcsts:

  An integer specifying the number of forecast periods. This argument is
  ignored when one or more indicator series is provided.

## Value

An object of class "JD3_INTERPRAW_RSLTS" is returned. The following are
returned invisibly as a list:

- `regression` `[[1]]` regression coefficients;

- `estimation` `[[2]]` interpolated values, errors, residuals and other
  parameters;

- `likelihood` `[[3]]` a list of test results.

## See also

[`temporal_disaggregation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation_raw.md)

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
# Use of Chow-lin method to interpolate a biennial series with an annual
# indicator (the low-frequency series is consistent with the last value of the
# interpolated series)
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
ti$estimation$interp
#>  [1] 3757964 4324395 4332525 4655006 4840668 5050272 5395661 5556665 6056481
#> [10] 6155126 6402476 6402063 7177121 7105610 7885934 7936844 7591404 8389142
#> [19] 8654201

# Use of Fernandez method to interpolate a series without indicator
# considering a frequency ratio of 5 (the low-frequency series is consistent
# with the last value of the interpolated series). For example, Y2 could be a
# quinquennial series to interpolate annually.
Y2 <- c(500,510,525,520)
ti2 <- temporal_interpolation_raw(Y2, model = "Rw", freqratio = 5, nbcsts = 1, nfcsts = 2)
ti2$estimation$interp
#>  [1] 500 500 502 504 506 508 510 513 516 519 522 525 524 523 522 521 520 520 520

# Same with an indicator, considering an offset in the latter
Y2 <- c(500,510,525,520)
x2 <- c(485,
        490, 492.5, 497.5, 520, 495,
        500, 502.5, 505, 527.5, 515,
        522.5, 517.5, 522.5, 545, 520,
        535, 515, 540, 565, 550)
ti3 <- temporal_interpolation_raw(Y2, indicators = x2, startoffset = 1, model = "Rw", freqratio = 5)
ti3$estimation$interp
#>  [1] 497.5410 500.0000 502.2459 505.7213 517.8033 506.5246 510.0000 512.0164
#>  [9] 514.0328 525.8852 520.5246 525.0000 520.3115 520.5410 529.3770 514.8525
#> [17] 520.0000 510.1639 522.4590 534.7541 527.3770

# Same considering that the first value of the interpolated series is the one
# consistent with the low-frequency series
ti4 <- temporal_interpolation_raw(Y2, indicators = x2, startoffset = 1,
                                  model = "Rw", freqratio = 5, obsposition = 1)
ti4$estimation$interp
#>  [1] 497.5410 500.0000 502.2459 505.7213 517.8033 506.5246 510.0000 512.0164
#>  [9] 514.0328 525.8852 520.5246 525.0000 520.3115 520.5410 529.3770 514.8525
#> [17] 520.0000 510.1639 522.4590 534.7541 527.3770
```
