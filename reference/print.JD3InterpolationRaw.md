# Print function for object of class JD3InterpolationRaw

Print function for object of class JD3InterpolationRaw

## Usage

``` r
# S3 method for class 'JD3InterpolationRaw'
print(x, ...)
```

## Arguments

- x:

  an object of class JD3InterpolationRaw

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
print(ti)
#> Model: Ar1 
#>               coef           se         t
#> C    -3.495942e+06 1.186404e+06 -2.946670
#> var1  2.082979e+01 2.594346e+00  8.028918
```
