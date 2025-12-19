# Plot function for object of class JD3AdlDisagg

Plot function for object of class JD3AdlDisagg

## Usage

``` r
# S3 method for class 'JD3AdlDisagg'
plot(x, ...)
```

## Arguments

- x:

  an object of class JD3AdlDisagg

- ...:

  further arguments to pass to ts.plot.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::Retail$FoodAndBeverageStores
td <- adl_disaggregation(Y, indicators = x, xar = "FREE")
plot(td)

```
