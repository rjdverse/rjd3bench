# Temporal disaggregation and Benchmarking methods based on JDemetra+ v3.x

Abstract

The package rjd3bench provides a variety of methods for temporal
disaggregation, interpolation, benchmarking, reconciliation and
calendarization. It is part of the interface to ‘JDemetra+ 3.x’
software. Methods of temporal disaggregation, interpolation and
benchmarking are used to derive high frequency time series from low
frequency time series with or without the help of high frequency
information. For temporal disaggregation, consistency of the high
frequency series with the low frequency series can be achieved either by
sum or average. For interpolation, the low frequency series can be the
first or last value of the high frequency series, or any other value. In
addition to temporal constraints, reconciliation methods deals with
contemporaneous consistency while adjusting multiple time series.
Finally, calendarization method can be used when time series data do not
coincide with calendar periods.

## Introduction

The methods implemented in the package rjd3bench intend to bridge the
gap when there is a lack of high frequency time series or when there are
temporal and/or contemporaneous inconsistencies between the high
frequency series and the corresponding low frequency series. Although
this can be an issue in any fields of research dealing with time series,
methods of temporal disaggregation, interpolation, benchmarking,
reconciliation and calendarization are often encountered in the
production of official statistics. For example, National Accounts are
often compiled according to two frequencies of production: annual
series, the low frequency data, based on precise and detailed sources
and quarterly series, the high frequency data, which usually rely on
less accurate sources but give information on a timelier basis. In such
case, the use of temporal disaggregation, benchmarking, and
reconciliation methods can be used to achieve consistency between annual
and quarterly national accounts over time.

The package rjd3bench is an R interface to the highly efficient
algorithms and modeling developed in the official ‘JDemetra+ 3.x’
software. It provides a wide variety of methods, included those
suggested in the *ESS guidelines on temporal disaggregation,
benchmarking and reconciliation (Eurostat, 2018)*.

## Set-up & Data

We illustrate the various methods using two datasets:

- The *Retail* dataset contains monthly figures over retail activity of
  various categories of goods and services from 1992 to 2010.
- The *qna_data* is a list of two datasets. The first data set
  ‘B1G_Y_data’ includes three annual benchmark series which are the
  Belgian annual value added on the period 2009-2020 in chemical
  industry (CE), construction (FF) and transport services (HH). The
  second data set ‘TURN_Q_data’ includes the corresponding quarterly
  indicators which are (modified) production indicators derived from VAT
  statistics and covering the period 2009Q1-2021Q4.

``` r
library("rjd3bench")
Retail <- rjd3toolkit::Retail
qna_data <- rjd3bench::qna_data
```

## Temporal disaggregation and interpolation methods

Temporal disaggregation and interpolation are related to each other (and
to benchmarking). They share similar properties and methods but they
differ in their purpose.

Temporal disaggregation is usually associated with flow series. The
purpose is to break down a low frequency time series into a higher
frequency time series, where the low frequency series correspond to the
sum or average of the corresponding higher frequency series.

Interpolation usually arises in the context of stock series. The purpose
is to estimate missing values at time points between the known data
points given by the low frequency series. For example, an annual series
can typically corresponds to the fourth quarter or twelfth month of a
quarterly or a monthly series and the purpose would be to obtain
estimates for the other quarters or months.

For the Chow-Lin method and its variants, a separate function is
considered for temporal disaggregation and interpolation. This is not
the case of the other methods where the two are integrated in a single
function.

Furthermore, there are *raw* version available for the functions
[`temporal_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation.md)
and
[`temporal_interpolation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation.md)
related to Chow-Lin method and its variants. The functions
[`temporal_disaggregation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation_raw.md)
and
[`temporal_interpolation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation_raw.md)
enable the user to deal with atypical frequency data and with any
frequency ratio. Note that for benchmarking, a function
[`denton_raw()`](https://rjdverse.github.io/rjd3bench/reference/denton_raw.md)
is also available.

### Chow-Lin, Fernandez and Litterman

Eurostat (2018) recommends the use of regression-based models for the
purpose of temporal disaggregation. Among them, we retrieve the Chow-Lin
method and its variants Fernandez and Litterman.

Let $Y_{T}$, $T = 1,...,m$, and $x_{t}$, $t = 1,...,n$, be, respectively
the observed low frequency benchmark and the high-frequency indicator of
an unknown high frequency variable $y_{t}$. Chow-Lin, Fernandez and
Litterman can be all expressed with the same equation, but with
different models for the error term: $$y_{t} = x_{t}\beta + u_{t}$$
where

$u_{t} = \phi u_{t - 1} + \epsilon_{t}$, with $|\phi| < 1$ (Chow-Lin),

$u_{t} = u_{t - 1} + \epsilon_{t}$ (Fernandez),

$u_{t} = u_{t - 1} + \phi\left( \Delta u_{t - 1} \right) + \epsilon_{t}$,
with $|\phi| < 1$ (Litterman)

The temporal constraint is: $$Y = Cy,$$ where $C = I_{m} \otimes c$, $c$
is a row vector of size $s$ which is the frequency ratio between the
disaggregated/interpolated series and the low frequency benchmark. The
distinction between temporal disaggregation and interpolation lies in
the definition of this vector c:

- Temporal disaggregation: $c = \lbrack 1,1,...,1\rbrack$ for
  aggregation (e.g., flow variables) and
  $c = \lbrack 1/s,1/s,...,1/s\rbrack$ for average conversion (e.g.,
  indexes)
- Interpolation: $c = \lbrack 0,0,...,1\rbrack$ when the low frequency
  series corresponds to the last value of the interpolated series,
  $c = \lbrack 1,0,...,0\rbrack$ when it’s the first value, etc. (e.g.,
  stock variables)

While $x_{t}$ is observed in high frequency, $y_{t}$ is only observed in
low frequency, and therefore the number of effective observations to
estimate the parameters are the number of observations in the
low-frequency benchmark.

The regression-based Chow-Lin method and its variants Fernandez and
Litterman can be called with the functions
[`temporal_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation.md)
or
[`temporal_interpolation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation.md).
Those two functions require a ts object as input series and only deal
with usual frequency conversion (i.e. annual to quarterly, annual to
monthly or quarterly to monthly). Alternatively, the functions
[`temporal_disaggregation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation_raw.md)
and
[`temporal_interpolation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation_raw.md)
require a numeric vector as input series and extend the previous
functions in a way that they can deal with atypical frequency series and
with any frequency ratio.

``` r
# Example 1: TD using Chow-Lin to disaggregate annual value added in construction sector using a quarterly indicator
Y <- ts(qna_data$B1G_Y_data[, "B1G_FF"], frequency = 1, start = c(2009, 1))
x <- ts(qna_data$TURN_Q_data[, "TURN_INDEX_FF"], frequency = 4, start = c(2009, 1))
td <- rjd3bench::temporal_disaggregation(Y, indicators = x)

y <- td$estimation$disagg # the disaggregated series
print(td)
summary(td)
plot(td)

# Example 2: interpolation using Fernandez without indicator when the last value (default) of the interpolated series is the one consistent with the low frequency series.
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
ti <- temporal_interpolation(Y, indicators = NULL, model = "Rw", freq = 4, nfcsts = 2)
y <- ti$estimation$interp # the interpolated series

# Example 3: TD of atypical frequency data using Fernandez with an offset of 1 period
Y <- c(500,510,525,520)
x <- c(97,
       98, 98.5, 99.5, 104, 99,
       100, 100.5, 101, 105.5, 103,
       104.5, 103.5, 104.5, 109, 104,
       107, 103, 108, 113, 110)
td_raw <- temporal_disaggregation_raw(Y, indicators = x, startoffset = 1,  model = "Rw", freqratio = 5)
y <- td_raw$estimation$disagg # the disaggregated series

# Example 4: interpolation of atypical frequency data using Fernandez without offset, when the first value of the interpolated  series is the one consistent with the low frequency series.
Y <- c(500,510,525,520)
x <- c(490, 492.5, 497.5, 520, 495,
       500, 502.5, 505, 527.5, 515,
       522.5, 517.5, 522.5, 545, 520,
       535, 515, 540, 565, 550,
       560)
ti_raw <- temporal_interpolation_raw(Y, indicators = x,  model = "Rw", freqratio = 5, obsposition = 1)
y <- ti_raw$estimation$interp
```

The output of the functions
[`temporal_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation.md),
[`temporal_interpolation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation.md),
[`temporal_disaggregation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation_raw.md)
and
[`temporal_interpolation_raw()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation_raw.md)
contains the most important information about the regression including
the estimates of model coefficients and their covariance matrix, the
decomposition of the disaggregated/interpolated series and information
about the residuals. A print() and summary() functions can be applied on
the output object. The plot() function, which displays the decomposition
of the disaggregated/interpolated series between regression and
smoothing effect, can be applied on the output object of the functions
[`temporal_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_disaggregation.md)
and
[`temporal_interpolation()`](https://rjdverse.github.io/rjd3bench/reference/temporal_interpolation.md).

In practice, Chow-Lin and its variants Fernandez and Litterman are
estimated based on an equivalent state space representation of the
model, which makes it possible to obtain estimates in a very efficient
way. Note that, by default, for Fernandez and Litterman, a diffuse
initialization is considered for the estimation of the initial values of
the states so that those integrate the constant estimates. The latter is
thus ‘hidden’ and does not appear in the results. To make the estimates
of the constant visible (and therefore finding back the usual output
from the classic formulation of the model), one option is to change the
argument`zeroinitialization = TRUE` with `constant=TRUE` before running
the function.

### Model-based Denton

Denton method and variants are usually expressed in mathematical terms
as a constrained minimization problem. For example, the widely used
Denton proportional first difference (PFD) method is usually expressed
as follows:
$$min_{y_{t}}\sum\limits_{t = 2}^{n}\lbrack\frac{y_{t}}{x_{t}} - \frac{y_{t - 1}}{x_{t - 1}}\rbrack^{2}$$
subject to the temporal constraint (flow variables)
$$\sum\limits_{t}y_{t} = Y_{T}$$ where $y_{t}$ is the value of the
estimate of the high frequency series at period t, $x_{t}$ is the value
of the high frequency indicator at period t and $Y_{T}$ is the value of
the low frequency series (i.e. the benchmark series) at period T.

Equivalently, the Denton PFD method can also be expressed as a
statistical model considering the following state space representation

\$\$ \begin{aligned} y_t &= \beta_t x_t \\ \beta\_{t+1} &= \beta_t +
\varepsilon_t \qquad \varepsilon_t \sim {\sf NID}(0,
\sigma^2\_{\varepsilon}) \end{aligned} \$\$

where the temporal constraints are taken care of by considering a
cumulated series $y_{t}^{c}$ instead of the original series $y_{t}$.
Hence, the last high frequency period (for example, the last quarter of
the year) is observed and corresponds to the value of the benchmark. The
value of the other periods are initially defined as missing and
estimated by maximum likelihood.

This alternative representation of Denton PFD method is interesting as
it allows more flexibility. We might now include outliers - namely,
level shift(s) in the Benchmark to Indicator ratio - that could
otherwise induce undesirable wave effects. Outliers and their intensity
are defined by changing the value of the innovation variances. There is
also the possibility to freeze the disaggregated series at some specific
period(s) or prior a certain date by fixing the high-frequency BI
ratio(s). Following the principle of movement preservation inherent to
Denton, the model-based Denton PFD method constitutes an interesting
alternative for temporal disaggregation, interpolation and benchmarking.
Here is a [link](https://www.youtube.com/watch?v=PC0tj2jMcuU) to a
presentation on the subject which include some comparison with the
regression-based methods for temporal disaggregation.

The model-base Denton method can be applied with the
[`denton_modelbased()`](https://rjdverse.github.io/rjd3bench/reference/denton_modelbased.md)
function.

``` r
# Example: Use of model-based Denton for temporal disaggregation
Y <- ts(qna_data$B1G_Y_data[, "B1G_FF"], frequency = 1, start = c(2009, 1))
x <- ts(qna_data$TURN_Q_data[, "TURN_INDEX_FF"], frequency = 4, start = c(2009, 1))
td_mbd <- rjd3bench::denton_modelbased(Y, x, outliers = list("2020-01-01" = 100, "2020-04-01" = 100))

y_mbd <- td_mbd$estimation$disagg
plot(td_mbd)
```

The output of the
[`denton_modelbased()`](https://rjdverse.github.io/rjd3bench/reference/denton_modelbased.md)
function contains information about the disaggregated/interpolated
series and the BI ratio as well as their respecting errors making it
possible to construct confidence intervals. The print(), summary() and
plot() functions can also be applied on the output object.The plot()
function displays the disaggregated series and the BI ratio together
with their respective 95% confidence interval.

### Autoregressive Distributed Lag (ADL) Models

Based on Proietti (2005), we consider a first order Autoregressive
Distributed Lag model, or ADL(1,1), which takes the form:

\$\$ y_t = \phi y\_{t-1} + m + gt + x_t'\beta_0 + x\_{t-1}'\beta_1 +
\varepsilon_t \qquad \varepsilon_t \sim {\sf NID}(0, \sigma^2) \qquad
(1) \$\$ subject to the temporal constraint (flow variables)
$$\sum\limits_{t}y_{t} = Y_{T}$$ where $y_{t}$ is the value of the
estimate of the high frequency series at period t, $x_{t}$ is the value
of the high frequency indicator at period t and $Y_{T}$ is the value of
the low frequency series (i.e. the benchmark series) at period T.

The ADL model nests the Chow-Lin model and its variants Fernandez and
Litterman (for Litterman, the ADL model must be formulated in the first
differences of the dependent and explanatory variables).

Recall the Chow-Lin model \$\$ y_t = x_t\beta + u_t \\ u_t = \phi
u\_{t-1} + \varepsilon_t \$\$ Combine it into a single equation and
substitute for
$u_{t - 1}$$$y_{t} = x_{t}\beta + \phi\left( y_{t - 1} - x_{t - 1}\beta \right) + \varepsilon_{t}$$
So, the ADL model corresponds to the Chow-Lin model if
$$\beta_{1} = - \phi\beta_{0}\qquad(2)$$ and to the Fernandez model if
we further assumes that $\phi = 1$.

Recall that the Chow-Lin model relies on the strong assumption of that
the disaggragated series $y_{t}$ and the indicator(s) $x_{t}$ are fully
co-integrated (if not stationary). The main benefit of the ADL model
over Chow-Lin is that it offers an extended modelling framework which
accounts for the uncertainty about the existence of co-integration
between $y_{t}$ and $x_{t}$. Hence, by nesting both the Chow-Lin and the
Fernandez model, it prevents potential spurious regressions between
$y_{t}$ and $x_{t}$.

Moreover, as explained in Proietti (2005, section 6.2), the ADL model
can be an interesting option when the indicator is affected by a
measurement error, since it can be showed that the model assumes that
$y_{t}$ is explained by a *filtered* version of $x_{t}$, where the
weights associated to $x_{t}$ decline geometrically over time. Hence, in
such case, the indicator’s excessive volatility won’t be reflected in
the disaggregated series as it is with Chow-Lin; rather, it will be
smoothed.

The ADL disaggregation method can be called with the
[`adl_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/adl_disaggregation.md)
function. The ‘xar’ parameter allows you to set constraints on the
coefficients of the lagged regression variables. As an alternative to
the default value “FREE” (no constraint), setting the parameter to
“SAME” corresponds to imposing the constraint (2). Note that those
constraints, and therefore also the relevance of switching from an ADL
model to a simpler Chow-Lin or Fernandez model, can be assessed by
computing the Likelihood Ratio (LR) statistic (cfr. example below).
Finally, you can set the parameter to “NONE”, which means an ADL(1,0)
model is considered (no lag on $x_{t}$) which corresponds to the method
suggested by Santos Silva and Cardoso (2001).

``` r
# Example: Use of ADL models for temporal disaggregation

Y <- ts(qna_data$B1G_Y_data[, "B1G_FF"], frequency = 1, start = c(2009, 1))
x <- ts(qna_data$TURN_Q_data[, "TURN_INDEX_FF"], frequency = 4, start = c(2009, 1))

## 1. without constraints

td_adl <- rjd3bench::adl_disaggregation(Y, indicators = x, xar = "FREE")
y <- td_adl$estimation$disagg # the disaggregated series
summary(td_adl)

## 2. with constraints

### b1 = -phi * b0 (~ Chow-Lin)
td_adl_constr_1 <- rjd3bench::adl_disaggregation(Y, indicators = x, xar = "SAME")

### phi = 1 and b1 = -b0 (~ Fernandez)
td_adl_constr_2 <- rjd3bench::adl_disaggregation(Y, constant = FALSE, indicators = x, xar = "SAME", phi = 1, phi.fixed = TRUE)

### b1 = 0 (~ Santos Silva-Cardoso)
td_adl_constr_3 <- rjd3bench::adl_disaggregation(Y, indicators = x, xar = "NONE")

## LR test for assessing constraint(s)
LR_stat <- -2 * (td_adl_constr_1$likelihood$ll - td_adl$likelihood$ll) # -> H0 not rejected. Chow-Lin specification is supported here.
```

The output of the function
[`adl_disaggregation()`](https://rjdverse.github.io/rjd3bench/reference/adl_disaggregation.md)
contains the most important information about the regression including
the estimates of model coefficients and their covariance matrix, the
disaggregated series and information about the residuals. A print(),
summary() and plot() functions can be applied on the output object.

In practice, ADL are estimated based on an equivalent state space
representation of the model, which makes it possible to obtain estimates
in a very efficient way.

### Reverse regression

Bournay and Laroque (1979) proposed an alternative regression-based
approach for temporal disaggregation. Unlike previous models, where the
target series (the disaggregated or interpolated series) was defined as
the dependent variable, this approach flips the regression and treats
the high-frequency indicator as the dependent variable and the target
series as the independent variable.

Let $Y_{T}$, $T = 1,...,m$, and $x_{t}$, $t = 1,...,n$, be, respectively
the observed low frequency benchmark and a single high-frequency
indicator of the unknown high frequency target variable $y_{t}$. The
model is defined as:

\$\$ x_t = a + by_t + u_t \\ u_t = \phi u\_{t-1} + \varepsilon_t \$\$
subject to the temporal constraint (flow variables)
$$\sum\limits_{t}y_{t} = Y_{T}$$ The choice of which variable is
dependent and which is independent is far from arbitrary. It changes the
assumptions and the interpretation of the model, and the outcome may be
very different too. In particular, if the fit between the benchmark and
the indicator is globally poor, the smoothing part of the Chow-Lin model
usually becomes more influential (if constant \> 0), resulting in a
disaggregated series that is smoother, meaning that the indicator’s
movements are dampened. Conversely, under the reverse model above, we
can have a high estimate for parameter $a$ and a low estimate for $b$,
which may result in a disaggregated series being more volatile,
effectively amplifying the indicator’s movements.

The reverse regression method can be called with the
[`temporaldisaggregationI()`](https://rjdverse.github.io/rjd3bench/reference/temporaldisaggregationI.md)
function.

``` r
Y <- ts(qna_data$B1G_Y_data[, "B1G_FF"], frequency = 1, start = c(2009, 1))
x <- ts(qna_data$TURN_Q_data[, "TURN_INDEX_FF"], frequency = 4, start = c(2009, 1))
td_rv <- rjd3bench::temporaldisaggregationI(Y, indicator = x)

y_rv <- td_rv$estimation$disagg # the disaggregated series
print(td_rv)
summary(td_rv)
plot(td_rv)

# comparison with Chow-Lin
td_cl <- rjd3bench::temporal_disaggregation(Y, indicators = x)
y_cl <- td_cl$estimation$disagg
stats::ts.plot(y_rv, y_cl, gpars=list(col=c("red", "blue"), xaxt="n", main="Reverse regression vs Chow-Lin"))
legend("topleft",c("Reverse regression", "Chow-Lin"), lty = c(1,1), col=c("red", "blue"))
```

The output of the function
[`temporaldisaggregationI()`](https://rjdverse.github.io/rjd3bench/reference/temporaldisaggregationI.md)
contains the disaggregated series as well as the estimates of the model
coefficients. A print(), summary() and plot() functions can be applied
on the output object.

## Benchmarking methods

The benchmarking problem arises when time series data for the same
target variable are measured at two different frequencies with different
levels of accuracy. Typically, the high frequency series is less
reliable than the low frequency series, referred to as the benchmark.
Thus, benchmarking is the process of adjusting the high frequency series
to make it consistent with the more reliable low frequency series.

As for the temporal disaggregation/interpolation method Chow-Lin and its
variants, a *raw* version of the
[`denton()`](https://rjdverse.github.io/rjd3bench/reference/denton.md)
benchamrking method is made available to the user. The function
[`denton_raw()`](https://rjdverse.github.io/rjd3bench/reference/denton_raw.md)
enables the user to deal with atypical frequency data and with any
frequency ratio.

### Denton

Denton methods relies on the principle of movement preservation. There
exist several variants corresponding to different definitions of
movement preservation: additive first difference (AFD), proportional
first difference (PFD), additive second difference (ASD), proportional
second difference (PSD).

The most widely used is the Denton PFD variant. Let $Y_{T}$,
$T = 1,...,m$, and $x_{t}$, $t = 1,...,n$, be, respectively the temporal
benchmarks and the high-frequency preliminary values of an unknown
target variable $y_{t}$. The objective function of the Denton PFD method
is as follows (considering the small modification suggested by Cholette
to deal with the starting conditions of the problem):
$$min_{y_{t}}\sum\limits_{t = 2}^{n}\lbrack\frac{y_{t}}{x_{t}} - \frac{y_{t - 1}}{x_{t - 1}}\rbrack^{2}$$
This objective function is minimized subject to the temporal aggregation
constraints $\sum_{t\epsilon T}y_{t} = Y_{T}$, $T = 1,...,m$ (flows
variables). In other words, the benchmarked series is estimated in such
a way that the “Benchmark-to-Indicator” ratio $\frac{y_{t}}{x_{t}}$
remains as smooth as possible, which is often of key interest in
benchmarking.

In the literature (see for example Di Fonzo and Marini, 2011), Denton
PFD is generally considered as a good approximation of the [GRP
method](#grp), meaning that it preserves the period-to-period growth
rates of the preliminary series. It is also argued that in many
applications, Denton PFD is more appropriate than GRP method as it deals
with a linear problem which is computationally easier, and does not
suffer from the issues related to time irreversibility and singular
objective function when $y_{t}$ approaches 0 (see Daalmans et al, 2018).

Denton methods can be called with the
[`denton()`](https://rjdverse.github.io/rjd3bench/reference/denton.md)
function which can deal with usual frequency conversion (i.e. annual to
quarterly, annual to monthly or quarterly to monthly). Alternatively,
the
[`denton_raw()`](https://rjdverse.github.io/rjd3bench/reference/denton_raw.md)
function requires a numeric vector as input series, but extends the
[`denton()`](https://rjdverse.github.io/rjd3bench/reference/denton.md)
function in a way that it can deal with atypical frequency series and
with any frequency ratio.

``` r
# Example 1: use of Denton method for benchmarking
Y <- ts(qna_data$B1G_Y_data[, "B1G_HH"], frequency = 1, start = c(2009, 1))

y_den0 <- rjd3bench::denton(t = Y, nfreq = 4) # denton PFD without high frequency series

x <- y_den0 + rnorm(n = length(y_den0), mean = 0, sd = 10)
y_den1 <- rjd3bench::denton(s = x, t = Y) # denton PFD (= the default)
y_den2 <- rjd3bench::denton(s = x, t = Y, d = 2, mul = FALSE) # denton ASD

# Example 2: use of of Denton method for benchmarking atypical frequency data
Y <- c(500,510,525,520)
x <- c(97, 98, 98.5, 99.5, 104,
       99, 100, 100.5, 101, 105.5,
       103, 104.5, 103.5, 104.5, 109,
       104, 107, 103, 108, 113,
       110)

y_denraw <- denton_raw(x, Y, freqratio = 5) # for example, x and Y could be annual and quiquennal series respectively
```

The
[`denton()`](https://rjdverse.github.io/rjd3bench/reference/denton.md)
and
[`denton_raw()`](https://rjdverse.github.io/rjd3bench/reference/denton_raw.md)
functions return the high frequency series benchmarked with the Denton
method.

### Growth rate preservation (GRP)

GRP explicitly preserves the period-to-period growth rates of the
preliminary series.

Let $Y_{T}$, $T = 1,...,m$, and $x_{t}$, $t = 1,...,n$, be, respectively
the temporal benchmarks and the high-frequency preliminary values of an
unknown target variable $y_{t}$. Cauley and Trager(1981) consider the
following objective function:

$$f(x) = \sum\limits_{t = 2}^{n}\left( \frac{y_{t}}{y_{t - 1}} - \frac{x_{t}}{x_{t - 1}} \right)^{2}$$
and look for values $y_{t}^{*}$, $t = 1,...,n$, which minimize it
subject to the temporal aggregation constraints
$\sum_{t\epsilon T}y_{t} = Y_{T}$, $T = 1,...,m$ (flows variables). In
other words, the benchmarked series is estimated in such a way that its
temporal dynamics; as expressed by the growth rates
$\frac{y_{t}^{*}}{y_{t - 1}^{*}}$, $t = 2,...,n$, be “as close as
possible” to the temporal dynamics of the preliminary series, where the
“distance” from the preliminary growth rates $\frac{x_{t}}{x_{t - 1}}$
is given by the sum of the squared differences. (Di Fonzo, Marini, 2011)

The objective function considered by Cauley and Trager is a natural
measure of the movement of a time series and as one would expect, it is
usually slightly better than the Denton PFD method at preserving the
movement of the series (Di Fonzo, Marini, 2011). However, unlike the
Denton PFD method which deals with a linear problem, GRP solves a more
difficult nonlinear problem. Furthermore, the GRP method suffers from a
couple of drawbacks, which are time irreversibility and potential
singularities in the objective function when $y_{t - 1}$ approaches to
0, which could lead to undesirable results (see Daalmans et al, 2018).

The standard objective function for GRP considered by Cauley and Trager
and defined above means that we apply the benchmarking forward.
Alternatively, we could apply it backward, which means performing the
benchmarking on the reversed time series. As previsouly mentionned, this
is not equivalent when using GRP method. As altenatives, Daalmans et al
(2018) proposed two other objective functions for GRP (symmetric GRP and
logarithmic GRP) which are “time symmetric”.

Backward GRP:
$$f(x) = \sum\limits_{t = 2}^{n}\left( \frac{y_{t - 1}}{y_{t}} - \frac{x_{t - 1}}{x_{t}} \right)^{2}$$
Symmetric GRP:
$$f(x) = \frac{1}{2}\sum\limits_{t = 2}^{n}\left( \frac{y_{t}}{y_{t - 1}} - \frac{x_{t}}{x_{t - 1}} \right)^{2} + \frac{1}{2}\sum\limits_{t = 2}^{n}\left( \frac{y_{t - 1}}{y_{t}} - \frac{x_{t - 1}}{x_{t}} \right)^{2}$$
Logarithmic GRP:
$$f(x) = \sum\limits_{t = 2}^{n}\left( log\left( \frac{y_{t}}{y_{t - 1}} \right) - log\left( \frac{x_{t}}{x_{t - 1}} \right) \right)^{2}$$

The GRP method, corresponding to the method of Cauley and Trager, using
the solution proposed by Di Fonzo and Marini (2011), can be called with
the [`grp()`](https://rjdverse.github.io/rjd3bench/reference/grp.md)
function. An alternative objective function as those suggested by
Daalmans et al (2018) can also be considered.

``` r
# Example: use GRP method for benchmarking
Y <- ts(qna_data$B1G_Y_data[, "B1G_HH"], frequency = 1, start = c(2009, 1))
y_den0 <- rjd3bench::denton(t = Y, nfreq = 4)
x <- y_den0 + rnorm(n = length(y_den0), mean = 0, sd = 10)

y_grpf <- rjd3bench::grp(s = x, t = Y)
y_grpl <- rjd3bench::grp(s = x, t = Y, objective = "Log")
```

The [`grp()`](https://rjdverse.github.io/rjd3bench/reference/grp.md)
function returns the high frequency series benchmarked with the GRP
method.

### Cubic splines

Cubic splines are piecewise cubic functions that are linked together in
a way to guarantee smoothness at data points. Additivity constraints are
added for benchmarking purpose and sub-period estimates are derived from
each spline. When a sub-period indicator (or a preliminary series) is
used, cubic splines are no longer drawn based on the low frequency data
but the Benchmark-to-Indicator (BI ratio) is the one being smoothed.
Sub-period estimates are then simply the product between the smoothed
high frequency BI ratio and the indicator.

The method can be called through the
[`cubicspline()`](https://rjdverse.github.io/rjd3bench/reference/cubicspline.md)
function. Here are a few examples on how to use it:

``` r
# Example: use cubic splines for benchmarking
y_cs1 <- rjd3bench::cubicspline(t = Y, nfreq = 4) # without high frequency series (smoothing)

x <- y_cs1 + rnorm(n = length(y_cs1), mean = 0, sd = 10)
y_cs2 <- rjd3bench::cubicspline(s = x, t = Y) # with a high frequency preliminary series to benchmark
```

The
[`cubicspline()`](https://rjdverse.github.io/rjd3bench/reference/cubicspline.md)
function returns the high frequency series benchmarked with cubic spline
method.

### Cholette method

Cholette method is based on a benchmarking methodology developed at
Statistics Canada. It is a generalized method relying on the principle
of movement preservation that encompasses other benchmarking methods.
The Denton method (both the AFD and PFD variants), as well as the naive
pro-rating method, emerge as particular cases of the Cholette method.

Let $Y_{T}$, $T = 1,...,m$, and $x_{t}$, $t = 1,...,n$, be, respectively
the temporal benchmarks and the high-frequency preliminary values of an
unknown target variable $y_{t}$. The objective function of the Cholette
method is as follows (Quenneville et al, 2006):

$$f(x) = \left( 1 - \rho^{2} \right)\left( \frac{x_{1} - y_{1}}{\left| x_{1} \right|^{\lambda}} \right)^{2} + \sum\limits_{t = 2}^{n}\left\lbrack \left( \frac{x_{t} - y_{t}}{\left| x_{t} \right|^{\lambda}} \right) - \rho\left( \frac{x_{t - 1} - y_{t - 1}}{\left| x_{t - 1} \right|^{\lambda}} \right) \right\rbrack^{2}$$
This objective function is minimized subject to the temporal aggregation
constraints $\sum_{t\epsilon T}y_{t} = Y_{T}$, $T = 1,...,m$ (flows
variables). The method is driven by a couple of parameters:

- The adjustment model parameter $\lambda$, $\lambda \in {\mathbb{R}}$.
  Set $\lambda = 0$ for an additive benchmarking model and $\lambda = 1$
  for a proportional benchmarking model. Finally, set $\lambda = 0.5$
  with $\rho = 0$, for the naive pro-rating method.  
- The smoothing parameter $\rho$, $0 \leq \rho \leq 1$. $\rho$
  determines the degree of movement preservation. When $\lambda = 1$,
  the closer $\rho$ is to 1, the smoother will be the ratios of the
  benchmarks to the corresponding totals in the preliminary series and
  the better the movement of the latter will be preserved.

Cholette method also provides for the possibility of considering a bias
correction factor, which is the expected discrepancy between the
benchmarks and the high-frequency preliminary series. The additive and
multiplicative bias correction factor are estimated respectively as:

$$\begin{aligned}
b_{a} & {= \frac{\sum\limits_{T = 1}^{m}Y_{T} - \sum\limits_{T = 1}^{m}{\sum\limits_{t\epsilon T}x_{t}}}{m}} \\
b_{m} & {= \frac{\sum\limits_{T = 1}^{m}Y_{T}}{\sum\limits_{T = 1}^{m}{\sum\limits_{t\epsilon T}x_{t}}}}
\end{aligned}$$ If a bias correction factor is considered, the
preliminary series is re-scaled in the objective function above:
$x_{t}^{*}$ replaces $x_{t}$, where $x_{t}^{*} = b_{a} + x_{t}$ in the
additive case and $x_{t}^{*} = b_{m} \times x_{t}$ in the multiplicative
case. The rationale for considering a bias correction factor with this
method is provided in Dagum and Cholette (2006, Ch. 6). It mainly
impacts the observations at the end of the series that are not covered
by a benchmark. In particular, when $\rho < 1$, the
Benchmark-to-Indicator ratios (BI ratios) at the end of the series
converge to the bias correction factor. By default, no bias is
considered, meaning that we do not expected a systematic bias between
the benchmarks and the preliminary series ($b_{a} = 0$ or $b_{m} = 1$).

Cholette method has been widely used to benchmark seasonally adjusted
series to annual totals derived from the raw series. For this purpose,
Quenneville et al (2006) argues that an undesirable feature of the
Denton PFD method is that it repeats the last BI ratio for the
observations at the end of the series that are not covered by a
benchmark. For observations without a benchmark, the best estimate of
the BI-ratio is the estimated value of the bias; so, repeating the last
value is not appropriate. Instead, to obtain a smooth transition from
this last BI-ratio to the bias, one can set $\rho < 1$. For observations
with a benchmark, the BI-ratios are closer to those obtained with the
Denton PFD method ($\rho = 1$) and smoother when
$\left. \rho\rightarrow 1 \right.$. As a pragmatic benchmarking method
routinely applicable to large numbers of seasonal time series Dagum and
Cholette (2006) recommend the proportional benchmarking method
($\lambda = 1$) with a value of $\rho = 0.90$ for monthly series and
$\rho = 0.90^{3} = 0.729$ for quarterly series. An alternative would be
to estimate the autocorrelation structure of the error instead of using
those default values.

Cholette method can be called with the
[`cholette()`](https://rjdverse.github.io/rjd3bench/reference/cholette.md)
function.

``` r
# Example: use Cholette method for benchmarking
Y <- ts(qna_data$B1G_Y_data[, "B1G_HH"], frequency = 1, start = c(2009, 1))
xn <- c(rjd3bench::denton(t = Y, nfreq = 4) + rnorm(n = length(Y)*4, mean = 0, sd = 10), 5750, 5800)
x <- ts(xn, start = start(Y), frequency = 4)

rjd3bench::cholette(s = x, t = Y, rho = 0.729, lambda = 1, bias = "Multiplicative")  # proportional benchmarking
rjd3bench::cholette(s = x, t = Y, rho = 0.729, lambda = 1) # proportional benchmarking with no bias (assuming bm=1)
rjd3bench::cholette(s = x, t = Y, rho = 0.729, lambda = 0, bias = "Additive")  # additive benchmarking 
rjd3bench::cholette(s = x, t = Y, rho = 1, lambda = 1) # Denton PFD
rjd3bench::cholette(s = x, t = Y, rho = 0, lambda = 0.5) # pro-rating
```

The
[`cholette()`](https://rjdverse.github.io/rjd3bench/reference/cholette.md)
function returns the high frequency series benchmarked with the Cholette
method.

In practice, the benchmarked series is estimated based on an equivalent
state space representation of the Cholette method described above, which
makes it possible to obtain estimates in a very efficient way.

## Reconciliation and multivariate temporal disaggregation

### Multivariate Cholette

This is a multivariate extension of the [Cholette benchmarking
method](#cholette) which can be used for the purpose of reconciliation.
While standard benchmarking methods consider one target series at a
time, reconciliation techniques aim to restore consistency in a system
of time series with regards to both contemporaneous and temporal
constraints. Reconciliation techniques are typically needed when the
total and its components are estimated independently (the so-called
direct approach). The multivariate Cholette method relies on the
principle of movement preservation and encompasses other reconciliation
methods such as the multivariate Denton method.

Let

- $Y_{i,T}$, $T = 1,...,m$, $i = 1,...,I$, be the set of temporal
  benchmarks
- $z_{k,t}$, $t = 1,...,n$, $k = 1,...,K$, be the set of contemporaneous
  constraints
- $x_{i,t}$ be the high-frequency preliminary values of the set of the
  unknown target variables $y_{i,t}$.

The objective function of the multivariate Cholette method is:
$$f(x) = \left( 1 - \rho^{2} \right)\sum\limits_{i = 1}^{I}\left( \frac{x_{i,1} - y_{i,1}}{\left| x_{i,1} \right|^{\lambda}} \right)^{2} + \sum\limits_{i = 1}^{I}\sum\limits_{t = 2}^{n}\left\lbrack \left( \frac{x_{i,t} - y_{i,t}}{\left| x_{i,t} \right|^{\lambda}} \right) - \rho\left( \frac{x_{i,t - 1} - y_{i,t - 1}}{\left| x_{i,t - 1} \right|^{\lambda}} \right) \right\rbrack^{2}$$
This objective function is minimized subject to

- the temporal aggregation constraints
  $\sum_{t\epsilon T}y_{i,t} = Y_{i,T}$, and
- the contemporaneous constraints given by
  $\sum_{j\epsilon J_{k}}\omega_{k,j}x_{j,t} = z_{k,t}$.

The method may also be considered in absence of temporal aggregation
constraints. The contemporaneous constraints are then imposed by
altering the dynamic movements of the series as little as possible. On
the other hand, the absence of contemporaneous constraint is less
relevant, as this is just equivalent to applying the univariate Cholette
method to each of the preliminary series separately.

As in the univariate case, the multivariate Cholette method is driven by
a couple of parameters:

- The adjustment model parameter $\lambda$, $\lambda \in {\mathbb{R}}$.
  Set $\lambda = 0$ for an additive model and $\lambda$ close to 1 to
  approximate a proportional model; while $\lambda = 1$ is also
  possible, it should be used cautiously in a multivariate context. This
  is because contemporaneous constraints combined with the fact that
  pure movement preservation specifies nothing about the level of the
  individual reconciled series may sometimes produce substantial
  differences in level between the preliminary and the benchmarked
  series. This is especially true in the absence of temporal constraints
  where strong movement preservation should not be pursued during
  reconciliation. Finally, as in the univariate case, the naive
  pro-rating method corresponds to setting $\lambda = 0.5$ with
  $\rho = 0$.

- The smoothing parameter $\rho$, $0 \leq \rho \leq 1$. $\rho$
  determines the degree of movement preservation. When $\lambda = 1$,
  the closer $\rho$ is to 1, the smoother will be the ratios of the
  benchmarks to the corresponding totals in the preliminary series and
  the better the movement of the latter will be preserved.

The multivariate Cholette method can be called with the
[`multivariatecholette()`](https://rjdverse.github.io/rjd3bench/reference/multivariatecholette.md)
function.

``` r
# Example: use the multivariate Cholette method for reconciliation
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

data_list <- list(x1 = x1, x2 = x2, x3 = x3, z = z, Y1 = Y1, Y2 = Y2, Y3 = Y3)
tc <- c("Y1 = sum(x1)", "Y2 = sum(x2)", "Y3 = sum(x3)") # temporal constraints
cc <- c("z = x1+x2+x3") # contemporaneous constraints

multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 1, lambda = .5) # Denton
multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729, lambda = .5) # Cholette
multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc, rho = 1, lambda = .5) # no temporal constraints
```

The
[`multivariatecholette()`](https://rjdverse.github.io/rjd3bench/reference/multivariatecholette.md)
function returns a list of benchmarked series, fulfilling both the
contemporary and the temporal constraints (if any).

In practice, the benchmarked series are estimated based on an equivalent
state space representation of the multivariate Cholette method described
above, which makes it possible to obtain estimates in a very efficient
way.

## Calendarization

Time series data do not always coincide with calendar periods (e.g.,
fiscal years starting in March-April or retail data collected in
non-monthly intervals). Calendarization is the process of transforming
the values of a flow time series observed over varying time intervals
into values that cover given calendar intervals such as month, quarter
or year.

The calendarization process involves two steps:

- Temporal disaggregation of the observed data into daily values using
  or not an indicator
- Aggregation of the resulting daily values into the desired calendar
  reference periods.

Based on the paper from Quenneville et al (2012), the temporal
disaggregation step is performed by considering a state-space
representation of the Denton proportional first difference (PFD) method.
Recall the objective function of the (modified) Denton PFD method  
$$min_{y_{t}}\sum\limits_{t = 2}^{n}\lbrack\frac{y_{t}}{x_{t}} - \frac{y_{t - 1}}{x_{t - 1}}\rbrack^{2}$$
which is minimized under the temporal aggregation constraints
$$\sum\limits_{t\epsilon l}y_{t} = Y_{l}$$$Y_{l}$, $l = 1,...,q$, are
the observed values to be distributed and $x_{t}$, $t = 1,...,n$ are the
daily indicator values that represent the daily movement of the unknown
target variable $y_{t}$. In the absence of such information, a constant
indicator (say, a vector of 1) is used instead.

The calendarization process can be called with the
[`calendarization()`](https://rjdverse.github.io/rjd3bench/reference/calendarization.md)
function. By default, a constant indicator is considered which means
that the daily level of activity is assumed to be constant. To include
an indicator into the disaggregation process, the function parameter
`dailyweights` has to be filled. If provided, the daily indicator values
(or weights) should reflect the daily level of activity that may be
varying in function for instance of seasonality, trading day or other
calendar effects such as public holidays.

``` r
# Example of calendarization (from Quenneville et al (2012))

## Observed data 
obs <- list(
    list(start = "2009-02-18", end = "2009-03-17", value = 9000),
    list(start = "2009-03-18", end = "2009-04-14", value = 5000),
    list(start = "2009-04-15", end = "2009-05-12", value = 9500),
    list(start = "2009-05-13", end = "2009-06-09", value = 7000))

## calendarization in absence of daily indicator values (or weights)
cal_1 <- calendarization(obs, 12, end = "2009-06-30", dailyweights = NULL, stde = TRUE)

ym_1 <- cal_1$rslt
eym_1 <- cal_1$erslt
yd_1 <- cal_1$days
eyd_1 <- cal_1$edays

## calendarization in presence of daily indicator values (or weights)
x <- rep(c(1.0, 1.2, 1.8 , 1.6, 0.0, 0.6, 0.8), 19)
cal_2 <- calendarization(obs, 12, end = "2009-06-30", dailyweights = x, stde = TRUE)

ym_2 <- cal_2$rslt
eym_2 <- cal_2$erslt
yd_2 <- cal_2$days
eyd_2 <- cal_2$edays
```

The
[`calendarization()`](https://rjdverse.github.io/rjd3bench/reference/calendarization.md)
function returns a list with the final aggregated results (after running
the two steps process described above) and their associated errors, as
well as the disaggregated daily values (after running the first step
only) and their associated errors.

## References

Bournay J., Laroque G. (1979). Reflexions sur la methode d’elaboration
des comptes trimestriels. *Annales de l’Insee, n°36, pp.3-30.*

Causey, B., and Trager, M.L. (1981). Derivation of Solution to the
Benchmarking Problem: Trend Revision. *Unpublished research notes, U.S.
Census Bureau, Washington D.C. Available as an appendix in Bozik and
Otto (1988).*

Chamberlin, G. (2010). Temporal disaggregation. *ONS Economic & Labour
Market Review*.

Di Fonzo, T., and Marini, M. (2011). A Newton’s Method for Benchmarking
Time Series according to a Growth Rates Preservation Principle. *IMF
WP/11/179*.

Daalmans, J., Di Fonzo, T., Mushkudiani, N., Bikker, R. (2018). Growth
Rates Preservation (GRP) temporal benchmarking: Drawbacks and
alternative solutions. *Survey Methodology, June 2018 Vol.44, No.1,
pp. 43-60 Statistics Canada, Catalogue No. 12-001-X*.

Dagum, E. B., and Cholette, P. A. (2006): Benchmarking, Temporal
Distribution and Reconciliation Methods of Time Series.
*Springer-Verlag, New York, Lecture notes in Statistics*.

Proietti, P. (2005). Temporal Disaggregation by State Space Methods:
Dynamic Regression Methods Revisited. *Working papers and Studies,
European Commission, ISSN 1725-4825*.

Quenneville, B., Fortier S., Chen Z.-G., Latendresse E. (2006). Recent
Developments in Benchmarking to Annual Totals in X12-ARIMA and at
Statistics Canada. *Statistics Canada, Working paper of the Time Series
Research and Analysis Centre*.

Quenneville, B., Picard F., Fortier S. (2012). Calendarization with
interpolating splines and state space models. *Statistics Canada, Appl.
Statistics (2013) 62, part 3, pp 371-399*.

Quilis, EM. (2018). Temporal disaggregation of economic time series -
The view from the trenches. *Statistica Neerlandica, Wiley*.

Santos Silva, J., Cardoso, F.N. (2001). The Chow-Lin method using
dynamic models. *Economic Modelling, 18 (2). pp. 269-280*.
