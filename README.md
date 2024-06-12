
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `rjd3bench` <a href="https://rjdverse.github.io/rjd3bench/"><img src="man/figures/logo.png" align="right" height="150" style="float:right; height:150px;"/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rjd3bench)](https://CRAN.R-project.org/package=rjd3bench)

[![R-CMD-check](https://github.com/rjdverse/rjd3bench/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rjdverse/rjd3bench/actions/workflows/R-CMD-check.yaml)
[![lint](https://github.com/rjdverse/rjd3bench/actions/workflows/lint.yaml/badge.svg)](https://github.com/rjdverse/rjd3bench/actions/workflows/lint.yaml)

[![GH Pages
built](https://github.com/rjdverse/rjd3bench/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/rjdverse/rjd3bench/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

Temporal disaggregation and benchmarking with JDemetra+ v3.x algorithms.

Benchmarking:

- Denton
- Cholette (incl. multi-variate)
- Cubic Splines
- GRP (Growth Rate Preservation)
- Calendarization

Temporal disaggregation

- Chow-Lin
- Fernandez
- Litterman
- Model Based Denton
- ADL (Autoregressive Distributed Lag Models)

## Installation

Running rjd3 packages requires **Java 17 or higher**. How to set up such
a configuration in R is explained
[here](https://jdemetra-new-documentation.netlify.app/#Rconfig)

To get the current stable version (from the latest release):

``` r
# install.packages("remotes")
remotes::install_github("rjdverse/rjd3toolkit@*release")
remotes::install_github("rjdverse/rjd3bench@*release")
```

To get the current development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("rjdverse/rjd3bench")
```

## Package Maintenance and contributing

Any contribution is welcome and should be done through pull requests
and/or issues. pull requests should include **updated tests** and
**updated documentation**. If functionality is changed, docstrings
should be added or updated.

## Licensing

The code of this project is licensed under the [European Union Public
Licence
(EUPL)](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12).
