# Plot function for object of class JD3Interpolation

Plot function for object of class JD3Interpolation

## Usage

``` r
# S3 method for class 'JD3Interpolation'
plot(x, ...)
```

## Arguments

- x:

  an object of class JD3Interpolation

- ...:

  further arguments to pass to ts.plot.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
ti <- temporal_interpolation(Y, indicators = x)
plot(ti)

```
