# Temporal Disaggregation of an Atypical Frequency Series by Regression Models.

Perform temporal disaggregation of low-frequency to high-frequency time
series by regression models. The implemented models include Chow-Lin,
Fernandez, Litterman and some variants of those algorithms. The
`temporal_disaggregation_raw()` function extends
[`temporal_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation.md)
by allowing temporal disaggregation for any frequency ratio.

## Usage

``` r
temporal_disaggregation_raw(
  series,
  constant = TRUE,
  trend = FALSE,
  indicators = NULL,
  startoffset = 0L,
  model = c("Ar1", "Rw", "RwAr1"),
  freqratio,
  average = FALSE,
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

  A low-frequency time series to be disaggregated. It must be a numeric
  vector.

- constant:

  Boolean. Indicates whether a constant term is included in the model.
  The default is `TRUE`. Note that this argument is used only with
  `model = "Ar1"` when `zeroinitialization = FALSE`. For additional
  information on this, see the package vignette.

- trend:

  Boolean. Indicates whether a linear trend is included in the model.
  The default is `FALSE`.

- indicators:

  One or more high-frequency indicator series used in the temporal
  disaggregation. If `NULL` (the default), no indicator is used. When
  provided, the argument must be a numeric vector or a matrix.

- startoffset:

  The number of initial observations in the indicator series that
  precede the start of the low-frequency series. The value must be
  either 0 or a positive integer (default is 0). This argument is
  ignored when no indicator is provided.

- model:

  A character string specifying the model of the error term at the
  disaggregated level. The options are: `"Ar1"` (Chow Lin), `"Rw"`
  (Fernandez), and `"RwAr1"` (Litterman).

- freqratio:

  An integer specifying the frequency ratio between the disaggregated
  series and the low-frequency series. This argument is mandatory and
  must be a positive integer.

- average:

  Boolean. Indicates whether an average conversion should be considered.
  The default is `FALSE`, corresponding to additive conversion.

- rho:

  A numeric value giving the (initial) value of the autoregressive
  parameter. This argument is used only for `"Ar1"` and `"RwAr1"`
  models.

- rho.fixed:

  Boolean. Specifies whether the supplied value of `rho` is fixed. The
  default is `FALSE`, which indicates that `rho` is estimated.

- rho.truncated:

  A numeric value defining the lower bound of the admissible range for
  `rho`. The evaluation range is `[rho.truncated, 1[`.

- zeroinitialization:

  Boolean. If `TRUE`, the initial values of the autoregressive model are
  set to zero. The default is `FALSE`.

- diffuse.algorithm:

  A character string specifying the algorithm used for diffuse
  initialization. The default is `"SqrtDiffuse"`.

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

An object of class `"JD3_TEMPDISAGGRAW_RSLTS"` containing the results of
the temporal disaggregation procedure.

## See also

[`temporal_interpolation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation_raw.md)

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
# Use of Chow-lin method to disaggregate a biennial series with an annual indicator
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
td$estimation$disagg
#>  [1] 1853646 1904318 2106162 2226363 2362164 2478504 2596417 2799244 2935728
#> [10] 3120753 3141809 3260667 3478645 3698476 3902189 3983745 3853109 3738295
#> [19] 3973614

# Use of Fernandez method to disaggregate a series without indicator
# considering a frequency ratio of 5 (for example, it could be a quinquennial
# series to disaggregate on an annual basis)
Y2 <- c(500,510,525,520)
td2 <- temporal_disaggregation_raw(Y2, model = "Rw", freqratio = 5, nfcsts = 2)
td2$estimation$disagg
#>  [1]  99.70153  99.77615  99.92538 100.14923 100.44770 100.82078 101.30213
#>  [8] 101.89174 102.58961 103.39574 104.31014 104.93980 105.28473 105.34493
#> [15] 105.12039 104.61112 104.20371 103.89815 103.69444 103.59258 103.59258
#> [22] 103.59258

# Same with an indicator, considering an offset in the latter
Y2 <- c(500,510,525,520)
x2 <- c(97,
        98, 98.5, 99.5, 104, 99,
        100, 100.5, 101, 105.5, 103,
        104.5, 103.5, 104.5, 109, 104,
        107, 103, 108, 113, 110)
td3 <- temporal_disaggregation_raw(Y2, indicators = x2, startoffset = 1,
                                   model = "Rw", freqratio = 5)
td3$estimation$disagg
#>  [1]  98.77697  99.16257  99.39121  99.84848 101.69120  99.90653 100.47131
#>  [8] 100.94308 101.51462 103.72835 103.34265 104.59913 104.59495 105.06531
#> [15] 106.58860 104.15201 104.50357 102.31697 103.76183 105.36774 104.04989
```
