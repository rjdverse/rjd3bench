# Temporal Disaggregation of a Time Series by ADL Model

Perform temporal disaggregation of low-frequency to high-frequency time
series using an Autoregressive Distributed Lag regression model.

## Usage

``` r
adl_disaggregation(
  series,
  constant = TRUE,
  trend = FALSE,
  indicators = NULL,
  average = FALSE,
  phi = 0,
  phi.fixed = FALSE,
  phi.truncated = 0,
  xar = c("FREE", "SAME", "NONE"),
  diffuse = FALSE
)
```

## Arguments

- series:

  A low-frequency time series to be disaggregated. It must be `"ts"`
  object.

- constant:

  Boolean. Indicates whether a constant term is included in the model.
  The default is `TRUE`.

- trend:

  Boolean. Indicates whether a linear trend is included in the model.
  The default is `FALSE`.

- indicators:

  One or more high-frequency indicator series. If not NULL (the
  default), this must be a `"ts"` object or a list of `"ts"` objects.

- average:

  Boolean. Indicates whether an average conversion should be considered.
  The default is `FALSE`, corresponding to additive conversion.

- phi:

  A numeric value giving the (initial) value of the phi parameter

- phi.fixed:

  Boolean. Specifies whether the supplied value of `phi` is fixed. The
  default is `FALSE`, which indicates that `phi` is estimated.

- phi.truncated:

  A numeric value defining the lower bound of the admissible range for
  `phi`. The evaluation range is `[phi.truncated, 1[`.

- xar:

  A character string specifying the constraints imposed on the
  coefficients of the lagged regression variables. The default is
  `"FREE"`, which indicates that no constraints are applied. For
  additional information, see the package vignette.

- diffuse:

  Boolean. Indicates whether the coefficients of the regression model
  are treated as diffuse (`TRUE`) or as fixed unknown (`FALSE`, the
  default).

## Value

An object of class `"JD3_ADLDISAGG_RSLTS"` containing the results of the
temporal disaggregation procedure.

## References

Proietti, P. (2005). Temporal Disaggregation by State Space Methods:
Dynamic Regression Methods Revisited. Working papers and Studies,
European Commission, ISSN 1725-4825.

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
# ADL model
data("qna_data")
Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
td1 <- adl_disaggregation(Y, indicators = x, xar = "FREE")
td1$estimation$disagg
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 3942.777 4634.702 4135.613 4841.308
#> 2010 3741.857 4630.503 4105.827 5241.913
#> 2011 3904.498 4970.769 4345.346 5635.388
#> 2012 4155.180 5008.042 4449.625 5236.853
#> 2013 4163.930 4863.390 4389.478 5296.703
#> 2014 4359.020 4893.089 4403.275 5352.616
#> 2015 4224.764 5095.530 4516.377 5457.329
#> 2016 4320.028 5192.685 4620.448 5545.239
#> 2017 4554.219 5295.261 4566.921 5733.498
#> 2018 4745.362 5633.230 5077.478 6311.329
#> 2019 5045.944 5858.301 5197.201 6412.755
#> 2020 5042.060 4873.840 5147.902 6502.698
#> 2021 5332.868 6337.108 5427.407 6991.385

# ADL models with constraints
td2 <- adl_disaggregation(Y, indicators = x, xar = "SAME") # ~ Chow-Lin
td3 <- adl_disaggregation(Y, constant = FALSE, indicators = x,
                          xar = "SAME", phi = 1, phi.fixed = TRUE) # ~ Fernandez
td4 <- adl_disaggregation(Y, indicators = x, xar = "NONE") # ~ Santos Silva-Cardoso
```
