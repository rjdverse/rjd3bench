# Print function for object of class JD3MBDenton

Print function for object of class JD3MBDenton

## Usage

``` r
# S3 method for class 'JD3MBDenton'
print(x, ...)
```

## Arguments

- x:

  an object of class JD3MBDenton

- ...:

  further arguments passed to or from other methods.

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
x <- rjd3toolkit::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 4)
td <- denton_modelbased(Y, x, outliers = list("2000-01-01" = 100, "2005-07-01" = 100))
print(td)
#> Available estimates:
#> [1] "disagg"   "edisagg"  "biratio"  "ebiratio"
#> 
#> Use summary() for more details. 
#>  Use plot() to see the disaggregated series and BI ratio together  with their respective confidence interval
```
