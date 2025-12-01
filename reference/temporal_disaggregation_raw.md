# Temporal disaggregation of an atypical frequency series by regression models.

Perform temporal disaggregation of low frequency to high frequency time
series by regression models. Models included are Chow-Lin, Fernandez,
Litterman and some variants of those algorithms. This "raw" function
extends the temporal_disaggregation() function in a way that it can deal
with any frequency ratio.

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

  The low frequency series that will be disaggregated. Must be a numeric
  vector.

- constant:

  Constant term (T/F). Only used with "Ar1" model when
  zeroinitialization = F.

- trend:

  Linear trend (T/F)

- indicators:

  High-frequency indicator(s) used in the temporal disaggregation. If
  not NULL, it must be either a numeric vector or a matrix.

- startoffset:

  Number of initial observations in the indicator(s) series that are
  prior to the start of the period covered by the low-frequency series.
  Must be 0 or a positive integer. 0 by default. Ignored when no
  indicator is provided.

- model:

  Model of the error term (at the disaggregated level). "Ar1" =
  Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman.

- freqratio:

  Frequency ratio between the disaggregated series and the low frequency
  series. Mandatory. Must be a positive integer.

- average:

  Average conversion (T/F). Default is F, which means additive
  conversion.

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

An object of class "JD3TempDisaggRaw"

## See also

[`temporal_interpolation_raw`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation_raw.md)

## Examples

``` r
# use of chow-lin method to disaggregate a biennial series with an annual indicator
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
td$estimation$disagg
#>  [1] 1853646 1904318 2106162 2226363 2362164 2478504 2596417 2799244 2935728
#> [10] 3120753 3141809 3260667 3478645 3698476 3902189 3983745 3853109 3738295
#> [19] 3973614

# use of Fernandez method to disaggregate a series without indicator considering a frequency ratio of 5 (for example, it could be a quinquennial series to disaggregate on an annual basis)
Y2 <- c(500,510,525,520)
td2 <- temporal_disaggregation_raw(Y2, model = "Rw", freqratio = 5, nfcsts = 2)
td2$estimation$disagg
#>  [1]  99.70153  99.77615  99.92538 100.14923 100.44770 100.82078 101.30213
#>  [8] 101.89174 102.58961 103.39574 104.31014 104.93980 105.28473 105.34493
#> [15] 105.12039 104.61112 104.20371 103.89815 103.69444 103.59258 103.59258
#> [22] 103.59258

# same with an indicator, considering an offset in the latter
Y2 <- c(500,510,525,520)
x2 <- c(97,
        98, 98.5, 99.5, 104, 99,
        100, 100.5, 101, 105.5, 103,
        104.5, 103.5, 104.5, 109, 104,
        107, 103, 108, 113, 110)
td3 <- temporal_disaggregation_raw(Y2, indicators = x2, startoffset = 1, model = "Rw", freqratio = 5)
td3$estimation$disagg
#>  [1]  98.77697  99.16257  99.39121  99.84848 101.69120  99.90653 100.47131
#>  [8] 100.94308 101.51462 103.72835 103.34265 104.59913 104.59495 105.06531
#> [15] 106.58860 104.15201 104.50357 102.31697 103.76183 105.36774 104.04989
```
