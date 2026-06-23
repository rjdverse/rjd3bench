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
  lambda = 0.5
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
  The default is `0.8`. See the package vignette for more information on
  the choice of the `rho` parameter.

- lambda:

  Numeric. The adjustment model parameter. Typical values include
  `lambda = 0`, `lambda = 0.5` (the default) and `lambda = 1`. See the
  package vignette for more information on the choice of the `lambda`
  parameter.

## Value

A named list containing the benchmarked series is returned.

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
# Example 1: one "standard" contemporaneous constraint: z=x1+x2+x3

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

## Run function with default values for rho and lambda
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.069397 7.385899 8.058519 7.486185
#> 2011 7.961343 6.987044 7.570753 8.080860
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.55572 20.58942 19.80927 21.04559
#> 2011 19.16716 19.25396 21.37039 21.40849
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.474880 1.824683 2.032208 2.668230
#> 2011 2.171499 1.658994 1.958861 2.310646
#> 

## Run function with some trade-off values for rho and lambda
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
#> 2010 7.045542 7.376876 8.064691 7.512891
#> 2011 8.023645 7.033308 7.564454 7.978594
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.58604 20.59697 19.79830 21.01869
#> 2011 19.12180 19.22024 21.37601 21.48195
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.468420 1.826157 2.037007 2.668416
#> 2011 2.154551 1.646451 1.959538 2.339460
#> 
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729) # Cholette
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.070672 7.385807 8.059196 7.484325
#> 2011 7.945589 6.975158 7.571946 8.107307
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.55121 20.58910 19.81051 21.04918
#> 2011 19.17769 19.26249 21.36970 21.39013
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.478117 1.825096 2.030295 2.666492
#> 2011 2.176725 1.662357 1.958353 2.302565
#> 

## Run function without temporal constraints
multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.113659 7.478203 8.248726 7.816905
#> 2011 8.516160 7.636314 8.272427 8.749182
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.42655 20.40889 19.55929 20.71713
#> 2011 18.71800 18.74819 20.84794 20.93202
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.559789 1.912911 2.091986 2.665970
#> 2011 2.065836 1.515500 1.779636 2.118795
#> 

## Run function considering non-binding contemporaneous constraint
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc_nb)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.115859 7.359053 8.100144 7.424944
#> 2011 8.025433 7.118789 7.522649 7.933128
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.68742 20.52354 19.90744 20.88160
#> 2011 19.30812 19.57491 21.25568 21.06129
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.488415 1.821166 2.043697 2.646722
#> 2011 2.184895 1.685557 1.950390 2.279159
#> 
#> $z
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 27.29169 29.70376 30.05128 30.95327
#> 2011 29.51845 28.37926 30.72871 31.27357
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
#> 2010 7.474738 7.463946 7.725598 7.335718
#> 2011 7.277376 7.707087 7.882331 7.633207
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 2.187694 2.182714 2.536362 3.093230
#> 2011 2.650051 2.340300 2.585344 2.924305
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 19.59898 20.17348 20.02703 20.20051
#> 2011 19.33206 19.71691 20.95828 20.99275
#> 
#> $x4
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 2010  9.662432  9.646660 10.261960 10.428948
#> 2011  9.927427 10.047387 10.467675 10.557512
#> 
#> $x5
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 4.600257 8.054511 6.289842 6.055390
#> 2011 3.979014 4.466173 5.314820 6.239993
#> 
```
