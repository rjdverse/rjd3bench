# Print function for object of class JD3TempDisaggI

Print function for object of class JD3TempDisaggI

## Usage

``` r
# S3 method for class 'JD3TempDisaggI'
print(x, ...)
```

## Arguments

- x:

  an object of class JD3TempDisaggI

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporaldisaggregationI(Y, indicator = x)
print(td)
#>         coef
#> a 26898.3587
#> b     0.0542
#> 
#> Use summary() for more details. 
#> Use plot() to visualize the disaggregated series.
```
