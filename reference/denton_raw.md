# Benchmarking of an atypical frequency series by means of the Denton method.

Denton method relies on the principle of movement preservation. There
exist a few variants corresponding to different definitions of movement
preservation: additive first difference (AFD), proportional first
difference (PFD), additive second difference (ASD), proportional second
difference (PSD), etc. The default and most widely used is the Denton
PFD method. This "raw" function extends the denton() function in a way
that it can deal with any frequency ratio between the preliminary series
and the aggregation constraint.

## Usage

``` r
denton_raw(
  s = NULL,
  t,
  freqratio,
  d = 1L,
  mul = TRUE,
  modified = TRUE,
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  obsposition = 1L,
  startoffset = 0L,
  nbcsts = 0L,
  nfcsts = 0L
)
```

## Arguments

- s:

  Preliminary series. If not NULL, it must be a numeric vector.

- t:

  Aggregation constraint. Mandatory. It must be a numeric vector.

- freqratio:

  Frequency ratio between the benchmarked series and the aggregation
  constraint. Mandatory. It must be a positive integer.

- d:

  Differencing order. 1 by default.

- mul:

  Multiplicative or additive benchmarking. Multiplicative by default.

- modified:

  Modified (TRUE) or unmodified (FALSE) Denton. Modified by default.

- conversion:

  Conversion rule. Usually "Sum" or "Average". Sum by default.

- obsposition:

  Position of the observation in the aggregated period (only used with
  "UserDefined" conversion).

- startoffset:

  Number of initial observations in the indicator(s) series that are
  prior to the period covered by the low-frequency series. Must be 0 or
  a positive integer. 0 by default. Ignored when no preliminary series
  is provided.

- nbcsts:

  Number of backcast periods. Ignored when a preliminary series is
  provided. (not yet implemented)

- nfcsts:

  Number of forecast periods. Ignored when a preliminary series is
  provided. (not yet implemented)

## Value

Numeric vector. The benchmarked series.

## See also

For more information, see the vignette:

[`browseVignettes`](https://rdrr.io/r/utils/browseVignettes.html)
`browseVignettes(package = "rjd3bench")`

## Examples

``` r
Y <- c(500,510,525,520)
x <- c(97, 98, 98.5, 99.5, 104,
       99, 100, 100.5, 101, 105.5,
       103, 104.5, 103.5, 104.5, 109,
       104, 107, 103, 108, 113,
       110)

# denton PFD (for example, x and Y could be annual and quiquennal series respectively)
denton_raw(x, Y, freqratio = 5)
#>  [1]  97.53918  98.55612  99.08195 100.12282 104.69992  99.72518 100.77674
#>  [8] 101.30957 101.82703 106.36148 103.82195 105.14453 103.77995 104.24995
#> [15] 108.00362 102.16847 104.38553  99.95494 104.42926 109.06180 106.16635

# denton AFD
denton_raw(x, Y, freqratio = 5, mul = FALSE)
#>  [1]  97.55184  98.56388  99.08796 100.12408 104.67224  99.73243 100.77942
#>  [8] 101.31321 101.83378 106.34115 103.83532 105.14857 103.78091 104.23234
#> [15] 108.00286 102.09247 104.36416  99.81792 104.45377 109.27169 106.27169

# denton PFD without indicator
denton_raw(t = Y, freqratio = 2, conversion = "Average")
#> [1] 498.75 501.25 506.25 513.75 523.75 526.25 521.25 518.75

# denton PFD with/without an offset and conversion = "Last"
x2 <- c(485,
        490, 492.5, 497.5, 520, 495,
        500, 502.5, 505, 527.5, 515,
        522.5, 517.5, 522.5, 545, 520,
        535, 515, 540, 565, 550)
denton_raw(x2, Y, freqratio = 5, conversion = "Last")
#>  [1] 466.3462 471.1538 473.5577 478.3654 500.0000 476.4849 481.8265 484.7669
#>  [9] 487.7125 510.0000 497.5519 504.4298 499.2382 503.6937 525.0000 496.4508
#> [17] 506.1759 482.8297 501.6296 520.0000 506.1947
denton_raw(x2, Y, freqratio = 5, conversion = "Last", startoffset = 1)
#>  [1] 489.8990 494.9495 497.4747 502.5253 525.2525 500.0000 503.0695 503.5940
#>  [9] 504.0987 524.4686 510.0000 519.4466 516.4758 523.4853 548.1341 525.0000
#> [17] 533.2790 506.7348 524.4042 541.4320 520.0000

```
