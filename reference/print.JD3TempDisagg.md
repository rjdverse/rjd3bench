# Print function for object of class JD3TempDisagg

Print function for object of class JD3TempDisagg

## Usage

``` r
# S3 method for class 'JD3TempDisagg'
print(x, ...)
```

## Arguments

- x:

  an object of class JD3TempDisagg

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporaldisaggregation(Y, indicators = x)
#> Warning: temporaldisaggregation() is deprecated. Use temporal_disaggregation() or temporal_interpolation() instead.
print(td)
#> Model: Ar1 
#>                coef           se         t
#> const -1.381786e+05 53211.306685 -2.596790
#> var-1  9.878479e+00     1.332486  7.413571
#> 
#> Use summary() for more details. 
#> Use plot() to see the decomposition of the disaggregated series.
```
