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
#> Warning: NaNs produced
summary(td)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  19 
#> Number of effective observations:  -1 
#> Number of estimated parameters:  2 
#> LogLikelihood:  -204.137 
#> Standard error:  
#> AIC:  412.2739 
#> BIC:  413.8191 
#> 
#> 
#> Model: FREE 
#> Rho : 0.999999  ( 1.426621e-08 )
#> 
#> 
#> Regression model 
#>         coef       se        t
#> 1 1416.32105 991.8115 1.428014
#> 2   13.74219      NaN      NaN
#> 3  -13.88406      NaN      NaN
```
