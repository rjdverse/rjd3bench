# `rjd3bench`

[![R-CMD-check](https://github.com/rjdverse/rjd3bench/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rjdverse/rjd3bench/actions/workflows/R-CMD-check.yaml)
[![lint](https://github.com/rjdverse/rjd3bench/actions/workflows/lint.yaml/badge.svg)](https://github.com/rjdverse/rjd3bench/actions/workflows/lint.yaml)

[![GH Pages
built](https://github.com/rjdverse/rjd3bench/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/rjdverse/rjd3bench/actions/workflows/pkgdown.yaml)

## Overview

rjd3bench provides a variety of methods for temporal disaggregation &
interpolation, benchmarking, reconciliation and calendarization.

Temporal disaggregation & interpolation:

- Chow-Lin, Fernandez and Litterman
- Model-Based Denton
- Autoregressive Distributed Lag (ADL) models
- Reverse regression

Benchmarking:

- Denton
- GRP (Growth Rate Preservation)
- Cubic Splines
- Cholette

Reconciliation and multivariate temporal disaggregation:

- Multivariate Cholette

Calendarization

## Installation

Running rjd3 packages requires **Java 17 or higher**. How to set up such
a configuration in R is explained
[here](https://jdemetra-new-documentation.netlify.app/#Rconfig)

### Latest release

To get the current stable version (from the latest release):

- From GitHub:

``` r
# install.packages("remotes")
remotes::install_github("rjdverse/rjd3bench@*release")
```

- From [r-universe](https://rjdverse.r-universe.dev/rjd3bench):

``` r
install.packages("rjd3bench", repos = c("https://rjdverse.r-universe.dev", "https://cloud.r-project.org"))
```

### Development version

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
(EUPL)](https://interoperable-europe.ec.europa.eu:443/collection/eupl/eupl-text-eupl-12).
