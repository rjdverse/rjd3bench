# Temporal disaggregation & interpolation of a time series with ADL models

Temporal disaggregation & interpolation of a time series with ADL models

## Usage

``` r
adl_disaggregation(
  series,
  constant = TRUE,
  trend = FALSE,
  indicators = NULL,
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  conversion.obsposition = 1L,
  phi = 0,
  phi.fixed = FALSE,
  phi.truncated = 0,
  xar = c("FREE", "SAME", "NONE"),
  ssf.type = c("TRANSITION", "CUMUL")
)
```

## Arguments

- ssf.type:

## Examples

``` r
data("qna_data")
Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
td1 <- adl_disaggregation(Y, indicators = x, xar = "FREE")
td2 <- adl_disaggregation(Y, indicators = x, xar = "SAME")
```
