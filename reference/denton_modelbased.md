# Temporal disaggregation & interpolation of a time series by model-based Denton proportional method

Denton proportional method can be expressed as a statistical model in a
State space representation (see documentation for the definition of
states). This approach is interesting as it allows more flexibility in
the model such as the inclusion of outliers (level shift in the
Benchmark to Indicator ratio) that could otherwise induce unintended
wave effects with standard Denton method. Outliers and their intensity
are defined by changing the value of the 'innovation variances'.

## Usage

``` r
denton_modelbased(
  series,
  indicator,
  differencing = 1L,
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  conversion.obsposition = 1L,
  outliers = NULL,
  fixedBIratios = NULL
)
```

## Arguments

- series:

  Aggregation constraint. Mandatory. It must be either an object of
  class ts or a numeric vector.

- indicator:

  High-frequency indicator. Mandatory. It must be of same class as
  series

- differencing:

  Not implemented yet. Keep it equals to 1 (Denton PFD method).

- conversion:

  Conversion rule. Usually "Sum" or "Average". Sum by default.

- conversion.obsposition:

  Position of the observation in the aggregated period (only used with
  "UserDefined" conversion)

- outliers:

  a list of structured definition of the outlier periods and their
  intensity. The period must be submitted first in the format YYYY-MM-DD
  and enclosed in quotation marks. This must be followed by an equal
  sign and the intensity of the outlier, defined as the relative value
  of the 'innovation variances' (1= normal situation)

- fixedBIratios:

  a list of structured definition of the periods where the BI ratios
  must be fixed. The period must be submitted first in the format
  YYYY-MM-DD and enclosed in quotation marks. This must be followed by
  an equal sign and the value of the BI ratio.

## Value

an object of class 'JD3MBDenton'

## Examples

``` r
# Retail data, monthly indicator
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 4)
td <- denton_modelbased(Y, x, outliers = list("2000-01-01" = 100, "2005-07-01" = 100))
y <- td$estimation$edisagg

# qna data, quarterly indicator
data("qna_data")
Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))

td1 <- denton_modelbased(Y, x)
td2 <- denton_modelbased(Y, x, outliers = list("2020-04-01" = 100), fixedBIratios = list("2021-04-01" = 39.0))

bi1 <- td1$estimation$biratio
bi2 <- td2$estimation$biratio
y1 <- td1$estimation$disagg
y2 <- td2$estimation$disagg
if (FALSE) { # \dontrun{
ts.plot(bi1,bi2,gpars = list(col = c("red","blue")))
ts.plot(y1,y2,gpars = list(col = c("red","blue")))
} # }
```
