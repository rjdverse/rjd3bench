# Plot function for object of class JD3MBDenton

Plot function for object of class JD3MBDenton

## Usage

``` r
# S3 method for class 'JD3MBDenton'
plot(x, ...)
```

## Arguments

- x:

  an object of class JD3MBDenton

- ...:

  further arguments to pass to ts.plot.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- temporaldisaggregationI(Y, indicator = x)
plot(td)

```
