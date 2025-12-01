# Temporal disaggregation using the model: x(t) = a + b y(t), where x(t) is the indicator, y(t) is the unknown target series, with low-frequency constraints on y.

Temporal disaggregation using the model: x(t) = a + b y(t), where x(t)
is the indicator, y(t) is the unknown target series, with low-frequency
constraints on y.

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

  The time series that will be disaggregated. It must be a ts object.

- indicator:

  High-frequency indicator used in the temporal disaggregation. It must
  be a ts object.

- conversion:

  Conversion mode (Usually "Sum" or "Average")

- conversion.obsposition:

  Integer. Only used with "UserDefined" mode. Position of the observed
  indicator in the aggregated periods (for instance 7th month of the
  year)

- rho:

  Only used with Ar1/RwAr1 models. (Initial) value of the parameter

- rho.fixed:

  Fixed rho (T/F, F by default)

- rho.truncated:

  Range for Rho evaluation (in \[rho.truncated, 1\[)

## Value

An object of class "JD3TempDisaggI"

## Examples

``` r
# Retail data, monthly indicator

Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporaldisaggregationI(Y, indicator = x)
td$estimation$disagg
#>           Jan      Feb      Mar      Apr      May      Jun      Jul      Aug
#> 1992 126151.4 107410.9 128083.0 138396.0 165377.2 148824.2 179437.6 162492.2
#> 1993 138578.9 103853.3 147321.3 154540.9 174656.3 164929.5 196067.4 162563.4
#> 1994 143711.3 111338.0 174125.7 160660.8 179163.6 185013.2 198812.3 186296.7
#> 1995 157744.7 122590.1 182487.1 171984.8 197568.6 195306.7 203727.9 199054.0
#> 1996 168801.1 150593.4 192395.0 175203.8 215880.4 198191.9 215626.8 222696.2
#> 1997 188775.7 139600.5 211453.1 177757.2 231046.3 195106.7 229075.3 225673.2
#> 1998 195702.9 143675.5 193913.8 203268.2 235965.9 209780.0 246758.5 227308.7
#> 1999 201904.1 161675.4 222343.0 214726.9 250130.7 226500.0 266879.7 232348.2
#> 2000 200329.0 188374.8 243243.7 240487.6 264050.4 259951.0 271167.5 261848.0
#> 2001 218689.3 185385.5 252820.8 229993.8 278607.6 263469.7 266290.1 275438.1
#> 2002 239435.6 194734.5 274322.7 221790.5 291738.3 260931.5 280568.5 283542.4
#> 2003 258443.8 201870.3 259341.4 254237.1 300870.3 262128.4 300489.9 292429.7
#> 2004 277071.5 224932.4 269161.8 273311.7 310803.0 282978.2 320414.4 284596.1
#> 2005 279487.2 227552.6 306711.8 282930.1 319830.6 309543.4 331711.0 314943.2
#> 2006 281369.3 245794.0 311854.9 302747.5 345947.5 329893.0 344140.0 340467.3
#> 2007 308963.2 261435.7 337115.2 302853.0 364124.3 345379.8 346735.5 347791.7
#> 2008 315459.7 280849.6 332383.8 297965.3 374023.1 324658.0 359978.5 353838.4
#> 2009 304064.3 218875.8 275031.9 286571.0 337270.9 295391.4 330278.4 310191.8
#> 2010 295612.1 244320.7 316694.0 297897.3 346458.2 313042.9 348997.5 324778.6
#>           Sep      Oct      Nov      Dec
#> 1992 138640.0 162249.5 143931.0 214723.1
#> 1993 151499.7 162525.5 154638.2 231073.7
#> 1994 172389.3 172191.3 173629.2 252689.8
#> 1995 178460.4 171743.8 184036.5 257799.5
#> 1996 173486.7 197135.6 206172.9 250481.2
#> 1997 186432.7 212337.4 208126.7 268618.2
#> 1998 201331.8 225928.6 208958.5 294512.6
#> 1999 225827.4 234265.3 228935.9 343019.5
#> 2000 240853.8 235249.4 250610.0 332590.7
#> 2001 240754.2 251222.2 266005.5 339048.2
#> 2002 231047.3 256872.8 276188.9 323149.0
#> 2003 249837.0 275818.6 274172.2 338515.4
#> 2004 277356.2 290904.0 289442.8 379457.8
#> 2005 298932.0 306274.0 310994.2 407780.8
#> 2006 308481.4 316987.5 333050.8 419402.9
#> 2007 309502.6 321701.1 342018.5 418177.2
#> 2008 295511.5 324602.7 320836.1 372826.3
#> 2009 279697.2 310369.3 301353.7 389375.3
#> 2010 308656.4 331646.0 336461.7 424899.6

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
