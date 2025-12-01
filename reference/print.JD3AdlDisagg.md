# Print function for object of class JD3AdlDisagg

Print function for object of class JD3AdlDisagg

## Usage

``` r
# S3 method for class 'JD3AdlDisagg'
print(x, ...)
```

## Arguments

- x:

  an object of class JD3AdlDisagg

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- adl_disaggregation(Y, indicators = x, xar = "FREE")
#> Warning: NaNs produced
print(td)
#> Model: FREE 
#>         coef       se        t
#> 1 1416.32105 991.8115 1.428014
#> 2   13.74219      NaN      NaN
#> 3  -13.88406      NaN      NaN
#> 
#> Use summary() for more details. 
#> Use plot() to see the decomposition of the disaggregated series.
```
