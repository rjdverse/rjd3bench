# Summary function for object of class JD3AdlDisagg

Summary function for object of class JD3AdlDisagg

## Usage

``` r
# S3 method for class 'JD3AdlDisagg'
summary(object, ...)
```

## Arguments

- object:

  an object of class JD3AdlDisagg

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- adl_disaggregation(Y, indicators = x)
summary(td)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  19 
#> Number of effective observations:  
#> Number of estimated parameters:  2 
#> LogLikelihood:  -245.4468 
#> Standard error:  
#> AIC:  494.8937 
#> BIC:  496.4389 
#> 
#> 
#> Model: FREE 
#> Rho : 0.9796543  ( 0.3012567 )
#> 
#> 
#> Regression model 
#>          coef         se         t
#> 1 -1744.00681 1125.54344 -1.549480
#> 2    15.85902    3.89625  4.070329
#> 3   -15.69828    3.91388 -4.010927
```
