# Plot function for object of class JD3TempDisaggI

Plot function for object of class JD3TempDisaggI

## Usage

``` r
# S3 method for class 'JD3TempDisaggI'
plot(x, ...)
```

## Arguments

- x:

  an object of class JD3TempDisaggI

- ...:

  further arguments to pass to ts.plot.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporaldisaggregationI(Y, indicator = x)
plot(td)

```
