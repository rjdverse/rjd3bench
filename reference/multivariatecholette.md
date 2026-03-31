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
  rho = 1,
  lambda = 0.8
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

  A character vector defining each contemporaneous constraints. Each
  element must be expressed in the form `"z = [w1*]x1 + ... + [wn*]xn"`
  or `"c = [w1*]x1 + ... + [wn*]xn"`, where `"z"` denotes the name of a
  high-frequency contemporaneous constraint, `wj` are optional numeric
  weights, `"x1, ..., xn"` are the names of the high-frequency
  preliminary series, and `c` is a constant. The `"+"` operator may be
  replaced by `"-"`. All series names must correspond to elements in
  `xlist`. A series appearing on the left‑hand side cannot appear on the
  right‑hand side of any other constraint, since left‑hand side
  quantities are fixed while right‑hand side are adjusted to satisfy the
  equality. Contemporaneous constraints must also be consistent with the
  temporal constraints (see the consistency check in the examples). The
  default is `NULL`, indicating that no contemporaneous constraints are
  imposed, which is equivalent to applying the univariate Cholette
  method to each of the preliminary series separately.

- rho:

  Numeric. A smoothing parameter whose value must lie between 0 and 1.
  See the package vignette for more information on the choice of the
  `rho` parameter.

- lambda:

  Numeric. The adjustment model parameter. Typically, `lambda = 0`
  corresponds to additive benchmarking, while values of `lambda` close
  to 1 approximate proportional benchmarking. Setting `lambda = 1` is
  possible but should be used with caution in multivariate model, as it
  may, in some situation, produce benchmarked series whose levels differ
  substantially from the preliminary series. See the package vignette
  for more information on the choice of the `lambda` parameter.

## Value

A named list containing the benchmarked series

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
#> 2010 7.088834 7.358409 8.085514 7.467243
#> 2011 8.051632 7.121157 7.536549 7.890661
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.51861 20.62328 19.76787 21.09024
#> 2011 19.07413 19.10573 21.41986 21.60028
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.492557 1.818311 2.046613 2.642519
#> 2011 2.174241 1.673108 1.943591 2.309060
#> 
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729) # Cholette
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.097866 7.365841 8.087746 7.448548
#> 2011 7.977588 7.066299 7.542584 8.013529
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.50927 20.61878 19.76868 21.10326
#> 2011 19.12059 19.14458 21.41573 21.51911
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.492863 1.815376 2.043571 2.648191
#> 2011 2.201825 1.689122 1.941689 2.267364
#> 

## Run function without temporal constraints
multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 3.099237 3.243449 3.678532 3.276217
#> 2011 3.851349 3.424127 3.766501 3.985738
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 19.21686 20.95378 20.09270 20.49772
#> 2011 19.32383 19.70037 21.79812 21.66938
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 4.783907 5.602769 6.128769 7.426064
#> 2011 6.124823 4.775501 5.335379 6.144883
#> 

## Run function considering non-binding contemporaneous constraint
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc_nb)
#> $x1
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.138104 7.338293 8.114190 7.409413
#> 2011 8.101444 7.227812 7.498480 7.772264
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 18.77401 20.54000 19.87748 20.80852
#> 2011 19.24470 19.54733 21.26834 21.13963
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 1.499392 1.818320 2.050439 2.631850
#> 2011 2.177807 1.681152 1.941392 2.299649
#> 
#> $z
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 27.41150 29.69661 30.04211 30.84978
#> 2011 29.52395 28.45629 30.70822 31.21154
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
#> 2010 7.656913 7.459133 7.691486 7.192468
#> 2011 7.202555 7.844736 7.928212 7.524497
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 2.038004 2.240979 2.542287 3.178730
#> 2011 2.690178 2.243273 2.563886 3.002663
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 20.29245 20.00733 19.93548 19.76474
#> 2011 19.18196 19.81496 20.94547 21.05761
#> 
#> $x4
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 2010  9.694917  9.700111 10.233773 10.371198
#> 2011  9.892733 10.088009 10.492098 10.527160
#> 
#> $x5
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 4.487934 7.914155 6.380138 6.217772
#> 2011 4.043199 4.529957 5.315297 6.111547
#> 
```
