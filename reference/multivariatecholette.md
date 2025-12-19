# Reconciliation by means of the Multivariate Cholette method

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

  a named list of ts objects including all input. Each element of the
  list should correspond to one input series (a preliminary series, a
  low-frequency series corresponding to one of the temporal aggregation
  constraints or a high-frequency series corresponding to one of the
  contemporaneous constraints).

- tcvector:

  a character vector defining each temporal constraints. Each element of
  the vector must be written as "Y = sum(x)" where "Y" is the name of a
  low frequency temporal constraint and "x" is the name of a
  high-frequency preliminary series. The names are the one given in the
  'xlist' argument. Default is NULL, which means that no temporal
  constraint is considered.

- ccvector:

  a character vector defining each contemporaneous constraints. Each
  element of the vector must be written in the form
  "z=\[w1\*\]x1+...+\[wn\*\]xn" or "c=\[w1\*\]x1+...+\[wn\*\]xn" where
  "z" is the name of a high frequency contemporaneous constraint, wj are
  optional numeric weights, "x1,...,xn" are the names of the
  high-frequency preliminary series and c is a constant. The "+"
  operator can be replaced by "-". The names of the contemporaneous
  constraint(s) and the preliminary series are the one given in the
  'xlist' argument. Note that any series put on the left hand side
  cannot appear on the right hand side of any other constraint. This is
  because left hand side quantities are fixed while right hand side
  quantities are adjusted so the equality holds. Default is NULL, which
  means that no contemporaneous constraint is considered. This is
  equivalent to applying the univariate Cholette method to each of the
  preliminary series separately.

- rho:

  Numeric. Smoothing parameter whose value should be between 0 and 1.
  See vignette for more information on the choice of the rho parameter.

- lambda:

  Numeric. Adjustment model parameter. Typically, lambda = 0 for
  additive benchmarking and lambda close to 1 to approach proportional
  benchmarking. Setting lambda = 1 is also an option but it should be
  used with caution as, in the case of a multivariate model, it may
  sometimes result in benchmarked series whose level differs strongly
  from the preliminary series. See vignette for more information on the
  choice of the lambda parameter.

## Value

a named list with the benchmarked series is returned

## See also

For more information, see the vignette:

[`browseVignettes`](https://rdrr.io/r/utils/browseVignettes.html)
`browseVignettes(package = "rjd3bench")`

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

### check consistency between temporal and contemporaneous constraints
lfs <- cbind(Y1,Y2,Y3)
rowSums(lfs) - stats::aggregate.ts(z) # should all be 0
#> Time Series:
#> Start = 2010 
#> End = 2011 
#> Frequency = 1 
#> [1] 0 0

data_list <- list(x1 = x1, x2 = x2, x3 = x3, z = z, Y1 = Y1, Y2 = Y2, Y3 = Y3)
tc <- c("Y1 = sum(x1)", "Y2 = sum(x2)", "Y3 = sum(x3)") # temporal constraints
cc <- c("z = x1+x2+x3") # contemporaneous constraints

multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 1, lambda = .5) # Denton
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
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729, lambda = .5) # Cholette
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
multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc, rho = 1, lambda = .5) # no temporal constraints
#> $x1
#>            Qtr1       Qtr2       Qtr3       Qtr4
#> 2010 0.09471188 0.24191380 0.61537179 0.19776270
#> 2011 0.75425553 0.33620487 0.74406548 0.97135123
#> 
#> $x2
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 19.70581 21.39462 20.60378 21.06272
#> 2011 19.88066 20.29720 22.26361 22.09731
#> 
#> $x3
#>          Qtr1     Qtr2     Qtr3     Qtr4
#> 2010 7.299482 8.163465 8.680845 9.939513
#> 2011 8.665084 7.266593 7.892321 8.731341
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
lfs <- cbind(Y1,3*Y2,0.5*Y3,Y4,Y5)
rowSums(lfs) - stats::aggregate.ts(z1) # should all be 0
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
