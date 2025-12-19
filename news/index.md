# Changelog

## rjd3bench 3.1.0.9000

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### [Unreleased](https://github.com/rjdverse/rjd3bench/compare/v3.1.0...HEAD)

### [3.1.0](https://github.com/rjdverse/rjd3bench/compare/v3.0.0...v3.1.0) - 2025-12-19

#### Added

- Add function documentation and vignette for MultivariateCholette, ADL
  models, Reverse regression and Calendarization

#### Changed

- Default value of lambda is changed to 0.8 in multivariate Cholette
- Re-ordering of the returned benchmarked series in multivariate
  Cholette
- Change/add parameters in adl_disaggregation() function

#### Fixed

- Solve bugs and instability issues in adl_disaggregation()

### [3.0.0](https://github.com/rjdverse/rjd3bench/compare/v2.1.0...v3.0.0) - 2025-05-12

#### Added

- Add function temporal_disaggregation_raw() for TD of atypical
  frequency data
- Add function denton_raw() for benchmarking of atypical frequency data
- Add alternative objective functions (backwards, symmetric and
  logarithmic) for GRP method
- Additional content in functions documentation and/or vignette for
  temporal disaggregation (Chow-Lin) and benchmarking (Denton, GRP,
  Cholette)

#### Changed

- Split TD and interpolation. The main function temporaldisaggregation()
  was deprecated and replaced by the two functions
  temporal_disaggregation() and temporal_interpolation()
- Some arguments in the temporal_disaggregation(),
  temporal_interpolation() and denton() functions were added to extend
  possibilities for the user.
- Refactoring vignette

#### Fixed

- Solve issue in residual output when tests fail
- Solve some instability issue in multivariatecholette()

### [2.1.0](https://github.com/rjdverse/rjd3bench/compare/v2.0.1...v2.1.0) - 2024-07-18

#### Added

- Add output on residuals in temporaldisaggregation() function

### [2.0.1](https://github.com/rjdverse/rjd3bench/compare/v2.0.0...v2.0.1) - 2024-07-12

#### Changed

- new jars related to version
  [1.2.1](https://github.com/jdemetra/jdplus-benchmarking/releases/tag/v1.2.1)\*

### [2.0.0](https://github.com/rjdverse/rjd3bench/compare/v1.0.0...2.0.0) - 2023-12-12

#### Added

- v2.0.0

### [1.0.0](https://github.com/rjdverse/rjd3bench/releases/tag/v1.0.0) - 2023-07-06

#### Added

- Initial commit
