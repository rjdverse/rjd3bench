# Summary function for object of class JD3TempDisaggI

Summary function for object of class JD3TempDisaggI

## Usage

``` r
# S3 method for class 'JD3TempDisaggI'
summary(object, ...)
```

## Arguments

- object:

  an object of class JD3TempDisaggI

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporaldisaggregationI(Y, indicator = x)
summary(td)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  19 
#> Number of effective observations:  18 
#> Number of estimated parameters:  4 
#> LogLikelihood:  -189.6422 
#> Standard error:  
#> AIC:  387.2844 
#> BIC:  390.8459 
#> 
#> 
#> Model: 
#>         coef
#> a 26898.3587
#> b     0.0542
```
