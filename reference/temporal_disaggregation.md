# Temporal disaggregation of a time series by regression models.

Perform temporal disaggregation of low frequency to high frequency time
series by regression models. Models included are Chow-Lin, Fernandez,
Litterman and some variants of those algorithms.

## Usage

``` r
temporal_disaggregation(
  series,
  constant = TRUE,
  trend = FALSE,
  indicators = NULL,
  model = c("Ar1", "Rw", "RwAr1"),
  freq = 4L,
  average = FALSE,
  rho = 0,
  rho.fixed = FALSE,
  rho.truncated = 0,
  zeroinitialization = FALSE,
  diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
  diffuse.regressors = FALSE,
  nbcsts = 0L,
  nfcsts = 0L
)
```

## Arguments

- series:

  The low frequency time series that will be disaggregated. It must be a
  ts object.

- constant:

  Constant term (T/F). Only used with "Ar1" model when
  zeroinitialization = F.

- trend:

  Linear trend (T/F, F by default)

- indicators:

  High-frequency indicator(s) used in the temporal disaggregation. It
  must be a (list of) ts object(s).

- model:

  Model of the error term (at the disaggregated level). "Ar1" =
  Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman.

- freq:

  Integer. Annual frequency of the disaggregated series. Ignored when an
  indicator is provided.

- average:

  Average conversion (T/F). Default is F, which means additive
  conversion.

- rho:

  (Initial) value of the parameter. Only used with Ar1/RwAr1 models.

- rho.fixed:

  Fixed rho (T/F, F by default)

- rho.truncated:

  Range for rho evaluation (in \[rho.truncated, 1\[)

- zeroinitialization:

  The initial values of an auto-regressive model are fixed to 0 (T/F, F
  by default)

- diffuse.algorithm:

  Algorithm used for diffuse initialization. "SqrtDiffuse" by default.

- diffuse.regressors:

  Indicates if the coefficients of the regression model are diffuse (T)
  or fixed unknown (F, default)

- nbcsts:

  Number of backcast periods. Ignored when an indicator is provided.

- nfcsts:

  Number of forecast periods. Ignored when an indicator is provided.

## Value

An object of class "JD3TempDisagg"

## See also

[`temporal_interpolation`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation.md)
for interpolation,

[`temporal_disaggregation_raw`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation_raw.md)
for temporal disaggregation of atypical frequency series,

[`temporal_interpolation_raw`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation_raw.md)
for interpolation of atypical frequency series

For more information, see the vignette:

[`browseVignettes`](https://rdrr.io/r/utils/browseVignettes.html)
`browseVignettes(package = "rjd3bench")`

## Examples

``` r
# chow-lin with monthly indicator
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporal_disaggregation(Y, indicators = x)
td$estimation$disagg
#>           Jan      Feb      Mar      Apr      May      Jun      Jul      Aug
#> 1992 137916.6 127636.7 138517.9 143927.8 158328.5 149506.3 165994.3 157105.9
#> 1993 146290.8 128255.9 152066.6 156486.5 167812.5 163176.0 180412.0 163065.2
#> 1994 155985.0 139247.5 173398.9 166717.7 177111.7 180704.9 188521.6 182227.7
#> 1995 168520.9 149989.8 182344.2 177053.4 191096.5 190264.4 195173.8 193101.2
#> 1996 179435.3 170227.9 193110.6 184407.0 206647.8 197638.4 207403.2 211601.9
#> 1997 195237.9 169237.7 207992.6 190264.2 219075.3 200135.7 218598.0 217058.6
#> 1998 202353.7 174820.7 202058.5 207469.2 225420.4 211913.4 232254.9 222452.2
#> 1999 212635.3 191944.3 225220.7 221938.2 241654.4 229761.2 252098.9 234332.2
#> 2000 220459.3 214640.6 244542.4 243574.2 256653.5 254895.8 261298.1 256676.4
#> 2001 234869.1 217233.2 253501.6 241471.0 267666.8 259748.6 261438.3 266512.4
#> 2002 248121.9 224394.8 267193.4 239316.0 276996.6 260785.1 271586.4 273492.2
#> 2003 261953.1 232128.8 263355.1 261124.8 286605.5 266429.9 287538.4 283834.3
#> 2004 279072.3 251916.1 276322.0 279278.5 300072.3 285913.0 306671.3 288229.1
#> 2005 289075.7 261988.0 305037.9 292996.1 313415.5 308576.3 321094.4 312769.7
#> 2006 297912.6 279466.4 315389.8 311076.6 334737.8 326677.8 334816.9 333352.5
#> 2007 318771.0 293740.0 334611.7 316630.6 349743.6 340016.0 341018.3 341834.3
#> 2008 325379.4 306804.6 334155.8 315345.2 355478.9 328328.8 346321.1 341955.1
#> 2009 307285.8 260043.2 288734.1 293851.9 320224.2 297357.7 315867.3 305260.0
#> 2010 302650.0 276723.7 316851.1 308077.1 335228.9 318399.8 338574.3 326435.3
#>           Sep      Oct      Nov      Dec
#> 1992 144593.9 157550.5 148144.3 186493.1
#> 1993 157732.5 164226.6 160607.5 202115.8
#> 1994 175159.2 175396.9 176480.3 219069.5
#> 1995 182535.4 179420.3 186502.3 226501.9
#> 1996 185666.8 198697.8 203890.8 227937.5
#> 1997 196337.4 210469.8 208483.0 241112.9
#> 1998 209207.0 223073.5 214748.3 261333.0
#> 1999 231533.7 236719.8 234519.8 296197.4
#> 2000 245772.2 243067.1 251544.1 295632.3
#> 2001 248131.0 253908.4 261993.4 301251.2
#> 2002 245738.3 259914.0 270628.0 296155.3
#> 2003 261679.5 276245.4 276055.5 311203.6
#> 2004 285076.1 293043.8 292977.9 341857.6
#> 2005 304841.0 309399.8 312547.0 364949.5
#> 2006 316722.9 321745.1 330795.8 377441.8
#> 2007 321570.6 328295.3 339336.6 380229.9
#> 2008 309490.3 323626.9 320005.4 346041.5
#> 2009 289382.4 306533.3 302747.1 351184.0
#> 2010 318514.0 331406.4 334459.9 382144.6

# fernandez with/without quarterly indicator
data("qna_data")
Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
td1 <- temporal_disaggregation(Y, indicators = x, model = "Rw")
td1$estimation$disagg
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 4054.319 4546.626 4230.812 4722.644
#> 2010 3965.439 4546.603 4200.157 5007.901
#> 2011 4142.939 4873.447 4470.202 5369.411
#> 2012 4364.657 4907.514 4519.913 5057.616
#> 2013 4338.360 4796.134 4474.717 5104.289
#> 2014 4485.847 4841.382 4510.477 5170.294
#> 2015 4415.320 4996.023 4612.936 5269.721
#> 2016 4513.425 5095.867 4714.789 5354.319
#> 2017 4692.663 5195.768 4717.649 5543.821
#> 2018 4925.526 5552.812 5207.136 6081.925
#> 2019 5249.821 5784.822 5326.067 6153.489
#> 2020 5228.107 5044.753 5176.463 6117.177
#> 2021 5355.338 6047.411 5450.219 6546.932

td2 <- temporal_disaggregation(Y, model = "Rw", nfcsts = 6)
td2$estimation$disagg
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 4394.912 4392.387 4387.338 4379.763
#> 2010 4369.663 4389.768 4440.077 4520.592
#> 2011 4631.312 4708.675 4752.682 4763.331
#> 2012 4740.623 4720.261 4702.244 4686.572
#> 2013 4673.246 4669.967 4676.736 4693.552
#> 2014 4720.416 4743.795 4763.690 4780.100
#> 2015 4793.025 4810.385 4832.180 4858.410
#> 2016 4889.074 4913.550 4931.838 4943.938
#> 2017 4949.849 4987.264 5056.182 5156.604
#> 2018 5288.529 5402.627 5498.899 5577.345
#> 2019 5637.965 5658.447 5638.791 5578.997
#> 2020 5479.065 5404.116 5354.151 5329.168
#> 2021 5329.168 5329.168 5329.168 5329.168
#> 2022 5329.168 5329.168                  

# chow-lin on index series
Y_index <- 100 * Y / Y[1]
x_index <- 100 * x / x[1]
td3 <- temporal_disaggregation(Y, indicators = x, average = TRUE)
td3$estimation$disagg
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2009 16328.55 18098.49 17036.42 18754.14
#> 2010 16074.89 18100.48 16925.50 19779.53
#> 2011 16842.84 19414.67 18022.13 21144.36
#> 2012 17640.81 19526.21 18182.77 20049.00
#> 2013 17508.95 19107.93 18013.75 20223.37
#> 2014 18079.35 19318.66 18167.70 20466.30
#> 2015 17874.01 19895.30 18559.96 20846.74
#> 2016 18234.19 20279.41 18977.63 21222.38
#> 2017 18931.73 20688.01 19034.39 21945.48
#> 2018 19929.86 22152.34 20964.98 24022.42
#> 2019 21151.75 23057.83 21500.42 24346.80
#> 2020 20922.72 20273.19 20818.86 24251.23
#> 2021 21872.07 24423.57 22425.88 26281.08
```
