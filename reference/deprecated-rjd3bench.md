# Deprecated functions

This function is deprecated. You should start using the functions
temporal_disaggregation() or temporal_interpolation() instead.

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
