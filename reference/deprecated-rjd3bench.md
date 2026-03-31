# Deprecated Functions

This function is deprecated. Use the function
[`temporal_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation.md)
or
[`temporal_interpolation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation.md)
instead.

## Usage

``` r
temporaldisaggregation(
  series,
  constant = TRUE,
  trend = FALSE,
  indicators = NULL,
  model = c("Ar1", "Rw", "RwAr1"),
  freq = 4L,
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  conversion.obsposition = 1L,
  rho = 0,
  rho.fixed = FALSE,
  rho.truncated = 0,
  zeroinitialization = FALSE,
  diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
  diffuse.regressors = FALSE
)
```

## Arguments

- series, constant, trend, indicators, model, freq, conversion,
  conversion.obsposition, rho, rho.fixed, rho.truncated,
  zeroinitialization, diffuse.algorithm, diffuse.regressors:

  Parameters.

## Value

Return the same value as either function that replaces it.
