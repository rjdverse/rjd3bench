# Summary function for object of class JD3InterpolationRaw

Summary function for object of class JD3InterpolationRaw

## Usage

``` r
# S3 method for class 'JD3InterpolationRaw'
summary(object, ...)
```

## Arguments

- object:

  an object of class JD3InterpolationRaw

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
summary(ti)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  9 
#> Number of effective observations:  -1 
#> Number of estimated parameters:  3 
#> LogLikelihood:  -128.9191 
#> Standard error:  
#> AIC:  263.8382 
#> BIC:  264.4299 
#> 
#> 
#> Model: Ar1 
#> Rho : 0  ( 148081.9 )
#> 
#> 
#> Regression model 
#>               coef           se         t
#> C    -3.495942e+06 1.186404e+06 -2.946670
#> var1  2.082979e+01 2.594346e+00  8.028918
```
