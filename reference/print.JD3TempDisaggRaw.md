# Print function for object of class JD3TempDisaggRaw

Print function for object of class JD3TempDisaggRaw

## Usage

``` r
# S3 method for class 'JD3TempDisaggRaw'
print(x, ...)
```

## Arguments

- x:

  an object of class JD3TempDisaggRaw

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
print(td)
#> Model: Ar1 
#>               coef           se         t
#> C    -1.600077e+06 6.974013e+05 -2.294342
#> var1  9.863832e+00 1.493929e+00  6.602609
```
