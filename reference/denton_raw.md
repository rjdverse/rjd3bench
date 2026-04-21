# Benchmarking of an Atypical Frequency Series by means of the Denton Method.

Denton method relies on the principle of movement preservation. There
exist a few variants corresponding to different definitions of movement
preservation: additive first difference (AFD), proportional first
difference (PFD), additive second difference (ASD), proportional second
difference (PSD), etc. The default and most widely used is the Denton
PFD method. The `denton_raw()` function extends
[`denton()`](https://rjdverse.github.io/rjd3bench/reference/denton.md)
by allowing benchmarking for any frequency ratio.

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

  A preliminary series. If not `NULL`, it must be a numeric vector.

- t:

  The low-frequency aggregation constraint. It must be a numeric vector.

- freqratio:

  An integer specifying the frequency ratio between the benchmarked
  series and the low-frequency constraint. This argument is mandatory
  and must be a positive integer.

- d:

  An integer specifying the differencing order. The default is `1`.

- mul:

  Boolean. Indicates whether benchmarking is multiplicative (`TRUE`) or
  additive (`FALSE`). The default is multiplicative.

- modified:

  Boolean. Specifies whether the modified Denton method (`TRUE`) or the
  unmodified Denton method (`FALSE`) is applied. The default is `TRUE`.

- conversion:

  A character string specifying the conversion mode, typically `"Sum"`
  (the default) or `"Average"`. Other options are: `"Last"`, `"First"`
  and `"UserDefined"`.

- obsposition:

  An integer specifying the position of the observations of the
  low-frequency constraint within the benchmarked series (e.g. the 7th
  month of the year). This argument is used only when
  `conversion = "UserDefined"`.

- startoffset:

  The number of initial observations in the preliminary series that
  precede the start of the low-frequency constraint. The value must be
  either 0 or a positive integer (default is 0). This argument is
  ignored when no preliminary series is provided.

- nbcsts:

  An integer specifying the number of backcast periods. This argument is
  ignored when a preliminary series is provided. (Not yet implemented.)

- nfcsts:

  An integer specifying the number of forecast periods. This argument is
  ignored when a preliminary series is provided. (Not yet implemented.)

## Value

A numeric vector with the benchmarked series is returned.

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
Y <- c(500,510,525,520)
x <- c(97, 98, 98.5, 99.5, 104,
       99, 100, 100.5, 101, 105.5,
       103, 104.5, 103.5, 104.5, 109,
       104, 107, 103, 108, 113,
       110)

# Denton PFD
# for example, x and Y could be annual and quinquennal series respectively
denton_raw(x, Y, freqratio = 5)
#>  [1]  97.53918  98.55612  99.08195 100.12282 104.69992  99.72518 100.77674
#>  [8] 101.30957 101.82703 106.36148 103.82195 105.14453 103.77995 104.24995
#> [15] 108.00362 102.16847 104.38553  99.95494 104.42926 109.06180 106.16635

# Denton AFD
denton_raw(x, Y, freqratio = 5, mul = FALSE)
#>  [1]  97.55184  98.56388  99.08796 100.12408 104.67224  99.73243 100.77942
#>  [8] 101.31321 101.83378 106.34115 103.83532 105.14857 103.78091 104.23234
#> [15] 108.00286 102.09247 104.36416  99.81792 104.45377 109.27169 106.27169

# Denton PFD without indicator
denton_raw(t = Y, freqratio = 2, conversion = "Average")
#> [1] 498.75 501.25 506.25 513.75 523.75 526.25 521.25 518.75

# Denton PFD with/without an offset and conversion = "Last"
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
