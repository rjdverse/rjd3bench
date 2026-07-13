# Temporal Disaggregation and Interpolation of a Time Series by means of a Reverse Regression Model.

Perform temporal disaggregation and interpolation of low-frequency to
high frequency time series by means of a reverse regression model.
Unlike the usual regression-based models, this approach treats a
high-frequency indicator as the dependent variable and the unknown
target series as the independent variable.

## Usage

``` r
temporaldisaggregationI(
  series,
  indicator,
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  conversion.obsposition = 1L,
  rho = 0,
  rho.fixed = FALSE,
  rho.truncated = 0
)
```

## Arguments

- series:

  A low-frequency time series to be disaggregated or interpolated. It
  must be a `"ts"` object.

- indicator:

  A high-frequency indicator series. It must be a `"ts"` object.

- conversion:

  A character string specifying the conversion mode, typically
  `"Sum"`(the default) or `"Average"`. Other options are: `"Last"`,
  `"First"` and `"UserDefined"`.

- conversion.obsposition:

  An integer specifying the position of the low-frequency observations
  within the interpolated series (e.g. the 7th month of the year). This
  argument is used only for interpolation when
  `conversion = "UserDefined"`.

- rho:

  A numeric value giving the (initial) value of the autoregressive
  parameter.

- rho.fixed:

  Boolean. Specifies whether the supplied value of `rho` is fixed. The
  default is `FALSE`, which indicates that `rho` is estimated.

- rho.truncated:

  A numeric value defining the lower bound of the admissible range for
  `rho`. The evaluation range is `[rho.truncated, 1[`.

## Value

An object of class "JD3_TEMPDISAGGI_RSLTS" is returned. The following
are returned invisibly as a list:

- `regression` `[[1]]` regression coefficients;

- `estimation` `[[2]]` disaggregated Time-Series and parameter;

- `likelihood` `[[3]]` likelihood statistics.

## References

Bournay J., Laroque G. (1979). Reflexions sur la methode d'elaboration
des comptes trimestriels. Annales de l'Insee, n. 36, pp.3-30.

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
# Retail data, monthly indicator
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporaldisaggregationI(Y, indicator = x)
td$estimation$disagg
#>           Jan      Feb      Mar      Apr      May      Jun      Jul      Aug
#> 1992 125854.1 106872.6 127807.3 138249.2 165571.7 148801.5 179800.7 162631.1
#> 1993 138359.5 103176.4 147187.6 154486.0 174844.8 164978.8 196500.4 162552.0
#> 1994 143375.1 110570.7 174146.6 160494.4 179220.2 185131.6 199095.2 186408.1
#> 1995 157447.5 121835.2 182490.8 171845.2 197746.9 195445.6 203963.6 199218.1
#> 1996 168508.3 150052.8 192375.3 174950.4 216134.7 198207.2 215853.3 223001.7
#> 1997 188597.7 138784.3 211548.5 177412.8 231376.0 194968.2 229363.9 225910.5
#> 1998 195519.7 142817.8 193689.5 203152.5 236256.3 209721.2 247157.9 227442.5
#> 1999 201608.6 160841.9 222263.9 214528.4 250364.2 226410.2 267286.8 232293.5
#> 2000 199774.5 187651.4 243207.8 240402.6 264254.1 260090.2 271439.4 261990.5
#> 2001 218243.6 184508.3 252801.9 229677.6 278908.9 263572.2 266423.8 275684.0
#> 2002 239196.5 193917.8 274519.2 221307.9 292144.3 260935.5 280815.9 283819.1
#> 2003 258347.1 201037.0 259230.9 254047.5 301263.2 262010.0 300846.5 292666.4
#> 2004 277016.5 224189.4 268964.7 273147.4 311098.6 282897.3 320792.9 284496.0
#> 2005 279223.1 226604.3 306758.0 282653.0 320007.3 309570.1 332003.4 315003.1
#> 2006 280913.6 244866.6 311757.5 302518.1 346256.2 329981.5 344396.7 340663.3
#> 2007 308693.1 260546.1 337184.2 302473.7 364520.4 345527.6 346893.2 347956.0
#> 2008 315185.6 280133.7 332333.8 297485.6 374533.0 324556.4 360354.5 354166.0
#> 2009 303977.6 217744.3 274656.7 286372.5 337742.2 295338.6 330676.0 310327.5
#> 2010 295411.5 243420.4 316681.4 297609.0 346760.5 312890.0 349281.5 324733.1
#>           Sep      Oct      Nov      Dec
#> 1992 138465.1 162367.6 143804.1 215491.1
#> 1993 151330.8 162481.5 154476.6 231873.6
#> 1994 172312.2 172102.2 173549.8 253615.0
#> 1995 178348.3 171532.6 183968.7 258661.5
#> 1996 173151.2 197092.5 206235.7 251102.0
#> 1997 186159.9 212388.8 208116.9 269375.7
#> 1998 201114.9 226007.2 208799.1 295426.4
#> 1999 225670.2 234197.5 228782.0 344308.9
#> 2000 240718.4 235034.2 250584.4 333608.6
#> 2001 240551.2 251148.3 266116.1 340089.2
#> 2002 230642.6 256788.9 276341.9 323892.3
#> 2003 249510.9 275806.8 274120.3 339267.5
#> 2004 277143.6 290845.0 289345.4 380493.3
#> 2005 298769.2 306187.9 310951.4 408960.4
#> 2006 308254.4 316856.6 333113.0 420558.6
#> 2007 309170.3 321519.5 342092.1 419221.8
#> 2008 295127.3 324630.7 320860.5 373565.8
#> 2009 279429.3 310472.6 301311.7 390421.9
#> 2010 308388.9 331661.1 336530.7 426097.0

# qna data, quarterly indicator
data("qna_data")
Y <- ts(qna_data$B1G_Y_data[,"B1G_CE"], frequency = 1, start = c(2009,1))
x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_CE"], frequency = 4, start = c(2009,1))
td <- temporaldisaggregationI(Y, indicator = x)
td$regression$a
#> [1] 28.43446
td$regression$b
#> [1] 0.0303505
```
