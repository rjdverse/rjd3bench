# Temporal disaggregation of a time series with ADL models

Temporal disaggregation of a time series with ADL models

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

  The low frequency time series that will be disaggregated. It must be a
  ts object.

- constant:

  Constant term (T/F, T by default)

- trend:

  Linear trend (T/F, F by default)

- indicators:

  High-frequency indicator(s). It must be a (list of) ts object(s).

- average:

  Average conversion (T/F). Default is F, which means additive
  conversion.

- phi:

  (Initial) value of the phi parameter

- phi.fixed:

  Fixed phi (T/F, F by default)

- phi.truncated:

  Range for phi evaluation (in \[phi.truncated, 1\[)

- xar:

  Constraints on the coefficients of the lagged regression variables.
  See vignette for more information on this.

- diffuse:

  Indicates if the coefficients of the regression model are diffuse (T)
  or fixed unknown (F, default)

## Value

An object of class "JD3AdlDisagg"

## References

Proietti, P. (2005). Temporal Disaggregation by State Space Methods:
Dynamic Regression Methods Revisited. Working papers and Studies,
European Commission, ISSN 1725-4825.

## See also

For more information, see the vignette:

[`browseVignettes`](https://rdrr.io/r/utils/browseVignettes.html)
`browseVignettes(package = "rjd3bench")`

## Examples

``` r
# adl model
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

# adl models with constraints
td2 <- adl_disaggregation(Y, indicators = x, xar = "SAME") # ~ Chow-Lin
td3 <- adl_disaggregation(Y, constant = FALSE, indicators = x, xar = "SAME", phi = 1, phi.fixed = TRUE) # ~ Fernandez
td4 <- adl_disaggregation(Y, indicators = x, xar = "NONE") # ~ Santos Silva-Cardoso
```
