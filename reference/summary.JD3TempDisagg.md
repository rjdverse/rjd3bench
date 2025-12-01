# Summary function for object of class JD3TempDisagg

Summary function for object of class JD3TempDisagg

## Usage

``` r
# S3 method for class 'JD3TempDisagg'
summary(object, ...)
```

## Arguments

- object:

  an object of class JD3TempDisagg

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporal_disaggregation(Y, indicators = x)
summary(td)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  19 
#> Number of effective observations:  -1 
#> Number of estimated parameters:  3 
#> LogLikelihood:  -246.6472 
#> Standard error:  
#> AIC:  499.2945 
#> BIC:  502.1278 
#> 
#> 
#> Model: Ar1 
#> Rho : 0.9808345  ( 0.004525153 )
#> 
#> 
#> Regression model 
#>                coef           se         t
#> const -1.381786e+05 53211.306685 -2.596790
#> var-1  9.878479e+00     1.332486  7.413571
```
