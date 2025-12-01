# Plot function for object of class JD3TempDisagg

Plot function for object of class JD3TempDisagg

## Usage

``` r
# S3 method for class 'JD3TempDisagg'
plot(x, ...)
```

## Arguments

- x:

  an object of class JD3TempDisagg

- ...:

  further arguments to pass to ts.plot.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporal_disaggregation(Y, indicators = x)
plot(td)

```
