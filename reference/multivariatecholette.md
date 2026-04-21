# Reconciliation by means of the Multivariate Cholette Method

This is a multivariate extension of the Cholette benchmarking method
which can be used for the purpose of reconciliation. While standard
benchmarking methods consider one target series at a time,
reconciliation techniques aim to restore consistency in a system of time
series with regards to both contemporaneous and temporal constraints.
Reconciliation techniques are typically needed when the total and its
components are estimated independently (the so-called direct approach).
The multivariate Cholette method relies on the principle of movement
preservation and encompasses other reconciliation methods such as the
multivariate Denton method.

## Usage

``` r
multivariatecholette(
  xlist,
  tcvector = NULL,
  ccvector = NULL,
  rho = 0.8,
  lambda = 1
)
```

## Arguments

- xlist:

  A named list of `ts` objects containing all input. Each element should
  correspond to one input series: a preliminary series, a low-frequency
  series representing a temporal aggregation constraint, or a
  high-frequency series representing a contemporaneous constraint.

- tcvector:

  A character vector defining the temporal constraints. Each element
  must be written in the form `"Y = sum(x)"`, where `"Y"` is the name of
  a low-frequency temporal constraint and `"x"` is the name of a
  high-frequency preliminary series. The names must match those provided
  in `xlist`. The default is `NULL`, indicating that no temporal
  constraints are considered.

- ccvector:

  NULL (default) or a character vector defining each contemporaneous
  constraints. If NULL, no contemporaneous constraint is considered.This
  is equivalent to applying the univariate Cholette method to each of
  the preliminary series separately. Otherwise, each element of the
  vector must be written in the form \\z=w_1 x_1+\ldots+w_n x_n\\ or
  \\c=w_1 x_1+\ldots+w_n x_n\\ where:

  - \\z\\ is the name of a high-frequency contemporaneous constraint,

  - \\(w_1,\ldots,w_n)\\ are optional numeric weights,

  - \\(x_1,\ldots,x_n)\\ are the names of the high-frequency preliminary
    series and

  - \\c\\ is a constant.

  The \\+\\ operator can be replaced by \\-\\. The names of the
  contemporaneous constraint(s) and the preliminary series are the one
  given in the `xlist` argument.

  **Important**: Any series placed on the left-hand side of a constraint
  cannot appear on the right-hand side of any other constraint. This is
  because quantities on the left-hand side are fixed, while those on the
  right-hand side are adjusted to satisfy the equality.

- rho:

  Numeric. The smoothing parameter whose value must lie between 0 and 1.
  See the package vignette for more information on the choice of the
  `rho` parameter.

- lambda:

  Numeric. The adjustment model parameter. Typically, setting
  `lambda = 0` yields a purely additive model, while `lambda = 1`
  corresponds to a proportional model. See the package vignette for more
  information on the choice of the `lambda` parameter.

## Value

A named list containing the benchmarked series is returned.

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
# Example 1: one "standard" contemporaneous constraint: x1+x2+x3 = z

x1 <- ts(c(7, 7.2, 8.1, 7.5, 8.5, 7.8, 8.1, 8.4), frequency = 4, start = c(2010, 1))
x2 <- ts(c(18, 19.5, 19.0, 19.7, 18.5, 19.0, 20.3, 20.0), frequency = 4, start = c(2010, 1))
x3 <- ts(c(1.5, 1.8, 2, 2.5, 2.0, 1.5, 1.7, 2.0), frequency = 4, start = c(2010, 1))

z <- ts(c(27.1, 29.8, 29.9, 31.2, 29.3, 27.9, 30.9, 31.8), frequency = 4, start = c(2010, 1))

Y1 <- ts(c(30.0, 30.6), frequency = 1, start = c(2010, 1))
Y2 <- ts(c(80.0, 81.2), frequency = 1, start = c(2010, 1))
Y3 <- ts(c(8.0, 8.1), frequency = 1, start = c(2010, 1))

## Check consistency between temporal and contemporaneous constraints
lfs <- cbind(Y1,Y2,Y3)
rowSums(lfs) - stats::aggregate.ts(z) # should all be 0
#> Time Series:
#> Start = 2010 
#> End = 2011 
#> Frequency = 1 
#> [1] 0 0

data_list <- list(x1 = x1, x2 = x2, x3 = x3, z = z, Y1 = Y1, Y2 = Y2, Y3 = Y3)
tc <- c("Y1 = sum(x1)", "Y2 = sum(x2)", "Y3 = sum(x3)") # temporal constraints
cc <- c("z = x1+x2+x3") # (binding) contemporaneous constraint
cc_nb <- c("0 = x1+x2+x3-z") # non-binding contemporaneous constraint

## Run function with trade-off values for rho and lambda
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = .5, lambda = .5)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.051902 7.371871 8.069296 7.506931
#> 2011 7.916967 6.956146 7.572586 8.154301
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.55737 20.59774 19.80615 21.03874
#> 2011 19.19172 19.27605 21.37229 21.35994
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.490728 1.830389 2.024550 2.654333
#> 2011 2.191317 1.667802 1.955124 2.285758
#> 

## Run function with the value of rho corresponding to Denton or Cholette
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 1) # Denton
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.109788 7.348007 8.098412 7.443793
#> 2011 8.068169 7.171383 7.521261 7.839187
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.49262 20.63609 19.75331 21.11798
#> 2011 19.05164 19.05459 21.44008 21.65369
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.497594 1.815902 2.048278 2.638227
#> 2011 2.180191 1.674030 1.938655 2.307125
#> 
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729) # Cholette
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.110119 7.354400 8.104941 7.430540
#> 2011 7.996154 7.118404 7.526617 7.958825
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.49427 20.63342 19.74918 21.12313
#> 2011 19.09391 19.09204 21.43681 21.57723
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.495609 1.812181 2.045881 2.646328
#> 2011 2.209936 1.689551 1.936570 2.263943
#> 

## Run function without temporal constraints
multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.035015 7.305950 8.142694 7.625994
#> 2011 8.476264 7.689833 8.167650 8.569816
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.55560 20.67671 19.74027 21.04165
#> 2011 18.80902 18.70399 21.01921 21.21138
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.509381 1.817336 2.017032 2.532351
#> 2011 2.014717 1.506181 1.713135 2.018808
#> 

## Run function considering non-binding contemporaneous constraint
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc_nb)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.137892 7.337006 8.132007 7.393095
#> 2011 8.058743 7.218032 7.493719 7.829506
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.69127 20.52611 19.92074 20.86188
#> 2011 19.31437 19.60965 21.25741 21.01857
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.497120 1.812273 2.049118 2.641490
#> 2011 2.205157 1.690150 1.936369 2.268324
#> 
#> $z
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 27.32628 29.67539 30.10186 30.89647
#> 2011 29.57827 28.51784 30.68750 31.11640
#> 

# Example 2: two contemporaneous constraints: x1+3*x2+0.5*x3+x4+x5 = z1 and x1+x2 = x4

x1 <- ts(c(7.0,7.3,8.1,7.5,8.5,7.8,8.1,8.4), frequency=4, start=c(2010,1))
x2 <- ts(c(1.5,1.8,2.0,2.5,2.0,1.5,1.7,2.0), frequency=4, start=c(2010,1))
x3 <- ts(c(18.0,19.5,19.0,19.7,18.5,19.0,20.3,20.0), frequency=4, start=c(2010,1))
x4 <- ts(c(8,9.5,9.0,10.7,8.5,10.0,10.3,9.0), frequency=4, start=c(2010,1))
x5 <- ts(c(5,9.6,7.2,7.1,4.3,4.6,5.3,5.9), frequency=4, start=c(2010,1))

z1 <- ts(c(38.1,41.8,41.9,43.2,38.8,39.1,41.9,43.7), frequency=4, start=c(2010,1))

Y1 <- ts(c(30.0,30.5), frequency=1, start=c(2010,1))
Y2 <- ts(c(10.0,10.5), frequency=1, start=c(2010,1))
Y3 <- ts(c(80.0,81.0), frequency=1, start=c(2010,1))
Y4 <- ts(c(40.0,41.0), frequency=1, start=c(2010,1))
Y5 <- ts(c(25.0,20.0), frequency=1, start=c(2010,1))

### check consistency between temporal and contemporaneous constraints
wlfs <- cbind(Y1,3*Y2,0.5*Y3,Y4,Y5)
rowSums(wlfs) - stats::aggregate.ts(z1) # cc1: should all be 0
#> Time Series:
#> Start = 2010 
#> End = 2011 
#> Frequency = 1 
#> [1] 0 0
Y1 + Y2 - Y4 # cc2: should all be 0
#> Time Series:
#> Start = 2010 
#> End = 2011 
#> Frequency = 1 
#> [1] 0 0

data.list <- list(x1=x1,x2=x2,x3=x3,x4=x4,x5=x5,z1=z1,Y1=Y1,Y2=Y2,Y3=Y3,Y4=Y4,Y5=Y5)
tc <- c("Y1=sum(x1)", "Y2=sum(x2)", "Y3=sum(x3)", "Y4=sum(x4)", "Y5=sum(x5)")
cc <- c("z1=x1+3*x2+0.5*x3+x4+x5", "0=x1+x2-x4")

multivariatecholette(xlist = data.list, tcvector = tc, ccvector = cc)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.732899 7.514571 7.684436 7.068094
#> 2011 7.032284 7.840724 7.971234 7.655758
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.881409 2.224601 2.571501 3.322489
#> 2011 2.816953 2.239080 2.536850 2.907117
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 20.90075 19.94897 19.87199 19.27828
#> 2011 18.89146 19.86125 20.96279 21.28449
#> 
#> $x4
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 2010  9.614307  9.739172 10.255937 10.390583
#> 2011  9.849236 10.079804 10.508084 10.562875
#> 
#> $x5
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 4.658191 7.897966 6.309128 6.134714
#> 2011 4.021890 4.531604 5.328738 6.117769
#> 
```
