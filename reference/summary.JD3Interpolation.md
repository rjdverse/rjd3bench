# Summary function for object of class JD3Interpolation

Summary function for object of class JD3Interpolation

## Usage

``` r
# S3 method for class 'JD3Interpolation'
summary(object, ...)
```

## Arguments

- object:

  an object of class JD3Interpolation

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
ti <- temporal_interpolation(Y, indicators = x)
summary(ti)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  19 
#> Number of effective observations:  -1 
#> Number of estimated parameters:  3 
#> LogLikelihood:  -256.3886 
#> Standard error:  
#> AIC:  518.7773 
#> BIC:  521.6106 
#> 
#> 
#> Model: Ar1 
#> Rho : 0  ( Inf )
#> 
#> 
#> Regression model 
#>                coef           se         t
#> const -1767664.6734 309535.20306 -5.710706
#> var-1      110.8141      7.09604 15.616330
```
