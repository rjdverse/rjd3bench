# Summary function for object of class JD3TempDisaggRaw

Summary function for object of class JD3TempDisaggRaw

## Usage

``` r
# S3 method for class 'JD3TempDisaggRaw'
summary(object, ...)
```

## Arguments

- object:

  an object of class JD3TempDisaggRaw

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
summary(td)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  9 
#> Number of effective observations:  -1 
#> Number of estimated parameters:  3 
#> LogLikelihood:  -126.87 
#> Standard error:  
#> AIC:  259.7401 
#> BIC:  260.3317 
#> 
#> 
#> Model: Ar1 
#> Rho : 0.6210373  ( 0.1631022 )
#> 
#> 
#> Regression model 
#>               coef           se         t
#> C    -1.600077e+06 6.974013e+05 -2.294342
#> var1  9.863832e+00 1.493929e+00  6.602609
```
