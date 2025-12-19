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
print(td)
#> Model: FREE 
#>          coef         se         t
#> 1 -1744.00681 1125.54344 -1.549480
#> 2    15.85902    3.89625  4.070329
#> 3   -15.69828    3.91388 -4.010927
#> 
#> Use summary() for more details. 
#> Use plot() to see the decomposition of the disaggregated series.
```
