# Summary function for object of class JD3MBDenton

Summary function for object of class JD3MBDenton

## Usage

``` r
# S3 method for class 'JD3MBDenton'
summary(object, ...)
```

## Arguments

- object:

  an object of class JD3MBDenton

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 4)
td <- denton_modelbased(Y, x, outliers = list("2000-01-01" = 100, "2005-07-01" = 100))
summary(td)
#> 
#> Likelihood statistics 
#> 
#> Number of observations:  19 
#> Number of effective observations:  18 
#> Number of estimated parameters:  1 
#> Standard error:  
#> AIC:  476.7895 
#> BIC:  477.6799 
#> 
#> 
#> Available estimates:
#> [1] "disagg"   "edisagg"  "biratio"  "ebiratio"
```
