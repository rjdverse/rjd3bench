# Print function for object of class JD3Interpolation

Print function for object of class JD3Interpolation

## Usage

``` r
# S3 method for class 'JD3Interpolation'
print(x, ...)
```

## Arguments

- x:

  an object of class JD3Interpolation

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
ti <- temporal_interpolation(Y, indicators = x)
print(ti)
#> Model: Ar1 
#>                coef           se         t
#> const -1767664.6734 309535.20306 -5.710706
#> var-1      110.8141      7.09604 15.616330
#> 
#> Use summary() for more details. 
#> Use plot() to see the decomposition of the interpolated series.
```
