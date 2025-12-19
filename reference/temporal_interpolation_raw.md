# Interpolation of an atypical frequency series by regression models.

Perform temporal interpolation of low frequency to high frequency time
series by regression models. Models included are Chow-Lin, Fernandez,
Litterman and some variants of those algorithms. This "raw" function
extends the temporal_interpolation() function in a way that it can deal
with any frequency ratio.

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

  The low frequency series that will be interpolated. Must be a numeric
  vector.

- constant:

  Constant term (T/F). Only used with "Ar1" model when
  zeroinitialization = F.

- trend:

  Linear trend (T/F, F by default)

- indicators:

  High-frequency indicator(s) used in the interpolation. If not NULL, it
  must be either a numeric vector or a matrix.

- startoffset:

  Number of initial observations in the indicator(s) series that are
  prior to the first observation of the low-frequency series. Must be 0
  or a positive integer. 0 by default. Ignored when no indicator is
  provided.

- model:

  Model of the error term (at the higher-frequency level). "Ar1" =
  Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman.

- freqratio:

  Frequency ratio between the interpolated series and the low frequency
  series. Mandatory. Must be a positive integer.

- obsposition:

  Integer. Position of the observations of the low frequency series in
  the interpolated series. (e.g. 1st month of the year, 2d month of the
  year, etc.). It must be a positive integer or -1 (the default). The
  default value is equivalent to setting the value of the parameter
  equal to the frequency of the series, meaning that the last value of
  the interpolated series is consistent with the low frequency series.

- rho:

  (Initial) value of the parameter. Only used with Ar1/RwAr1 models.

- rho.fixed:

  Fixed rho (T/F, F by default)

- rho.truncated:

  Range for Rho evaluation (in \[rho.truncated, 1\[)

- zeroinitialization:

  The initial values of an auto-regressive model are fixed to 0 (T/F, F
  by default)

- diffuse.algorithm:

  Algorithm used for diffuse initialization. "SqrtDiffuse" by default

- diffuse.regressors:

  Indicates if the coefficients of the regression model are diffuse (T)
  or fixed unknown (F, default)

- nbcsts:

  Number of backcast periods. Ignored when an indicator is provided.

- nfcsts:

  Number of forecast periods. Ignored when an indicator is provided.

## Value

An object of class "JD3InterpolationRaw"

## See also

[`temporal_disaggregation_raw`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation_raw.md)

For more information, see the vignette:

[`browseVignettes`](https://rdrr.io/r/utils/browseVignettes.html)
`browseVignettes(package = "rjd3bench")`

## Examples

``` r
# use of chow-lin method to interpolate a biennial series with an annual indicator
# (low frequency series consistent with the last value of the interpolated series)
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
ti$estimation$interp
#>  [1] 3757964 4324395 4332525 4655006 4840668 5050272 5395661 5556665 6056481
#> [10] 6155126 6402476 6402063 7177121 7105610 7885934 7936844 7591404 8389142
#> [19] 8654201

# use of Fernandez method to interpolate a series without indicator considering a frequency ratio of 5 (for example, it could be a quinquennial series to interpolate annually)
# (low frequency series consistent with the last value of the interpolated series)
Y2 <- c(500,510,525,520)
ti2 <- temporal_interpolation_raw(Y2, model = "Rw", freqratio = 5, nbcsts = 1, nfcsts = 2)
ti2$estimation$interp
#>  [1] 500 500 502 504 506 508 510 513 516 519 522 525 524 523 522 521 520 520 520

# same with an indicator, considering an offset in the latter
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

# same considering that the first value of the interpolated series is the one consistent with the low frequency series
ti4 <- temporal_interpolation_raw(Y2, indicators = x2, startoffset = 1, model = "Rw", freqratio = 5, obsposition = 1)
ti4$estimation$interp
#>  [1] 497.5410 500.0000 502.2459 505.7213 517.8033 506.5246 510.0000 512.0164
#>  [9] 514.0328 525.8852 520.5246 525.0000 520.3115 520.5410 529.3770 514.8525
#> [17] 520.0000 510.1639 522.4590 534.7541 527.3770
```
