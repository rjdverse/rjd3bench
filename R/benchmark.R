#' @include utils.R
NULL

#' @title Benchmarking by means of the Denton Method.
#'
#' @description
#' Denton method relies on the principle of movement preservation. There exist a
#' few variants corresponding to different definitions of movement preservation:
#' additive first difference (AFD), proportional first difference (PFD),
#' additive second difference (ASD), proportional second difference (PSD), etc.
#' The default and most widely used is the Denton PFD method.
#'
#' @param s A preliminary series. If not `NULL`, it must be of the same class as `t`.
#' @param t The low-frequency aggregation constraint. It must be either a `"ts"` object or a numeric vector.
#' @param d An integer specifying the differencing order. The default is `1`.
#' @param mul Boolean. Indicates whether benchmarking is multiplicative (`TRUE`) or additive (`FALSE`). The default is multiplicative.
#' @param nfreq An integer giving the annual frequency of the benchmarked series.
#' This argument is used only when no preliminary series is provided.
#' @param modified Boolean. Specifies whether the modified Denton method (`TRUE`) or the unmodified Denton method (`FALSE`) is applied. The default is `TRUE`.
#' @param conversion A character string specifying the conversion mode, typically `"Sum"` (the default) or `"Average"`. Other options are: `"Last"`, `"First"` and `"UserDefined"`.
#' @param obsposition An integer specifying the position of the observations of the low-frequency constraint within the benchmarked series (e.g. the 7th month of the year).
#' This argument is used only when `conversion = "UserDefined"`.
#' @param nbcsts An integer specifying the number of backcast periods.
#' This argument is ignored when a preliminary series is provided.
#' (Not yet implemented.)
#' @param nfcsts An integer specifying the number of forecast periods.
#' This argument is ignored when a preliminary series is provided.
#' (Not yet implemented.)
#'
#' @return A `"ts"` object with the benchmarked series is returned.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#'
#' # Denton PFD without a preliminary series
#' y1 <- denton(t = Y, nfreq = 4)
#' print(y1)
#'
#' # Denton PFD without a preliminary series and conversion = "Average"
#' denton(t = Y, nfreq = 4, conversion = "Average")
#'
#' # Denton PFD with a preliminary series
#' x <- y1 + rnorm(n = length(y1), mean = 0, sd = 10000)
#' denton(s = x, t = Y)
#'
#' # Denton AFD with a preliminary series
#' denton(s = x, t = Y, mul = FALSE)
#'
denton <- function(s = NULL, t, d = 1L, mul = TRUE, nfreq = 4L, modified = TRUE,
                   conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
                   obsposition = 1L, nbcsts = 0L, nfcsts = 0L) {

    conversion <- match.arg(conversion)

    jd_t <- rjd3toolkit::.r2jd_tsdata(t)

    if (!is.null(s)) {
        jd_s <- rjd3toolkit::.r2jd_tsdata(s)
    } else {
        jd_s <- as.integer(nfreq)
    }
    jd_rslt <- .jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "denton",
                      jd_s, jd_t, as.integer(d), mul, modified, conversion, as.integer(obsposition))
    rjd3toolkit::.jd2r_tsdata(jd_rslt)
}

#' @title Benchmarking of an Atypical Frequency Series by means of the Denton Method.
#'
#' @description
#' Denton method relies on the principle of movement preservation. There exist a
#' few variants corresponding to different definitions of movement preservation:
#' additive first difference (AFD), proportional first difference (PFD),
#' additive second difference (ASD), proportional second difference (PSD), etc.
#' The default and most widely used is the Denton PFD method. The `denton_raw()`
#' function extends `denton()` by allowing benchmarking for any frequency ratio.
#'
#' @param s A preliminary series. If not `NULL`, it must be a numeric vector.
#' @param t The low-frequency aggregation constraint. It must be a numeric vector.
#' @param freqratio An integer specifying the frequency ratio between the benchmarked series and the low-frequency constraint.
#' This argument is mandatory and must be a positive integer.
#' @param d An integer specifying the differencing order. The default is `1`.
#' @param mul Boolean. Indicates whether benchmarking is multiplicative (`TRUE`) or additive (`FALSE`). The default is multiplicative.
#' @param modified Boolean. Specifies whether the modified Denton method (`TRUE`) or the unmodified Denton method (`FALSE`) is applied. The default is `TRUE`.
#' @param conversion  A character string specifying the conversion mode, typically `"Sum"` (the default) or `"Average"`. Other options are: `"Last"`, `"First"` and `"UserDefined"`.
#' @param obsposition An integer specifying the position of the observations of the low-frequency constraint within the benchmarked series (e.g. the 7th month of the year).
#' This argument is used only when `conversion = "UserDefined"`.
#' @param startoffset The number of initial observations in the preliminary series that precede the start of the low-frequency constraint.
#' The value must be either 0 or a positive integer (default is 0).
#' This argument is ignored when no preliminary series is provided.
#' @param nbcsts An integer specifying the number of backcast periods.
#' This argument is ignored when a preliminary series is provided.
#' (Not yet implemented.)
#' @param nfcsts An integer specifying the number of forecast periods.
#' This argument is ignored when a preliminary series is provided.
#' (Not yet implemented.)
#'
#' @return A numeric vector with the benchmarked series is returned.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' Y <- c(500,510,525,520)
#' x <- c(97, 98, 98.5, 99.5, 104,
#'        99, 100, 100.5, 101, 105.5,
#'        103, 104.5, 103.5, 104.5, 109,
#'        104, 107, 103, 108, 113,
#'        110)
#'
#' # Denton PFD
#' # for example, x and Y could be annual and quinquennal series respectively
#' denton_raw(x, Y, freqratio = 5)
#'
#' # Denton AFD
#' denton_raw(x, Y, freqratio = 5, mul = FALSE)
#'
#' # Denton PFD without indicator
#' denton_raw(t = Y, freqratio = 2, conversion = "Average")
#'
#' # Denton PFD with/without an offset and conversion = "Last"
#' x2 <- c(485,
#'         490, 492.5, 497.5, 520, 495,
#'         500, 502.5, 505, 527.5, 515,
#'         522.5, 517.5, 522.5, 545, 520,
#'         535, 515, 540, 565, 550)
#' denton_raw(x2, Y, freqratio = 5, conversion = "Last")
#' denton_raw(x2, Y, freqratio = 5, conversion = "Last", startoffset = 1)
#'
#'
denton_raw <- function(s = NULL, t, freqratio, d = 1L, mul = TRUE, modified = TRUE,
					   conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
					   obsposition = 1L, startoffset = 0L, nbcsts = 0L, nfcsts = 0L){

    conversion <- match.arg(conversion)

    if(!(freqratio > 0L && freqratio %% 1L == 0.0)){
        stop("'freqratio' must be a positive integer")
    }
    if(!is.vector(t, mode = "numeric")){
        stop("Aggregation constraint must be a numeric vector")
    }
    if(!(is.vector(s, mode = "numeric") || is.null(s))){
        stop("Preliminary series must be a numeric vector (or NULL)")
    }

    if (!is.null(s)){
        rslt <- .jcall("jdplus/benchmarking/base/r/Benchmarking",  "[D", "dentonRaw",
						as.numeric(s), as.numeric(t), as.integer(freqratio), as.integer(d), mul,
						modified, conversion, as.integer(obsposition), as.integer(startoffset))
    } else {
        rslt <- .jcall("jdplus/benchmarking/base/r/Benchmarking",  "[D", "dentonRaw",
						as.numeric(t), as.integer(freqratio), as.integer(d), mul,
						modified, conversion, as.integer(obsposition), as.integer(startoffset))
    }
    return(rslt)
}

#' @title Benchmarking following the Growth Rate Preservation Principle.
#'
#' @description
#' GRP is a method which explicitly preserves the period-to-period growth rates
#' of the preliminary series. It corresponds to the method of Cauley and Trager
#' (1981), using the solution proposed by Di Fonzo and Marini (2011). BFGS is
#' used as line-search algorithm for the reduced unconstrained minimization
#' problem.
#'
#' @param s A preliminary series. It must be a `"ts"` object.
#' @param t The low-frequency aggregation constraint. It must be a `"ts"` object.
#' @param objective A character string specifying the objective function. The default is `"Forward"`. Other options are: `"Backward"`, `"Symmetric"` and `"Log"`. For additional information on this, see the package vignette.
#' @param conversion A character string specifying the conversion mode, typically `"Sum"` (the default) or `"Average"`. Other options are: `"Last"`, `"First"` and `"UserDefined"`.
#' @param obsposition An integer specifying the position of the observations of the low-frequency constraint within the benchmarked series (e.g. the 7th month of the year).
#' This argument is used only when `conversion = "UserDefined"`.
#' @param eps A numeric value specifying the convergence tolerance. The BFGS
#'   algorithm proceeds until the reduction in the objective function is within
#'   this tolerance (default is `1e-12`) or until the maximum number of iterations is reached.
#' @param iter An integer giving the maximum number of iterations allowed in the BFGS algorithm.
#' The default is `500`.
#' @param dentoninitialization Boolean. Indicates whether the series obtained
#'   via the modified Denton PFD method is used as the starting values for the
#'   GRP optimization procedure. The default is `TRUE`. If `FALSE`, the starting
#'   values are derived directly from the aggregation constraint (e.g. `t/4` for
#'   quarterly series with annual constraint and `conversion = "Sum"`).
#'
#' @return A `"ts"` object with the benchmarked series is returned.
#'
#' @references  Causey, B., and Trager, M.L. (1981). Derivation of Solution to
#'   the Benchmarking Problem: Trend Revision. Unpublished research notes, U.S.
#'   Census Bureau, Washington D.C. Available as an appendix in Bozik and Otto
#'   (1988).
#'
#'   Di Fonzo, T., and Marini, M. (2011). A Newton's Method for Benchmarking
#'   Time Series according to a Growth Rates Preservation Principle. *IMF
#'   WP/11/179*.
#'
#'   Daalmans, J., Di Fonzo, T., Mushkudiani, N. and Bikker, R. (2018). Growth
#'   Rates Preservation (GRP) temporal benchmarking: Drawbacks and alternative
#'   solutions. *Statistics Canada*.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' data("qna_data")
#'
#' Y <- ts(qna_data$B1G_Y_data[, "B1G_FF"], frequency = 1, start = c(2009, 1))
#' x <- denton(t = Y, nfreq = 4) + rnorm(n = length(Y) * 4, mean = 0, sd = 10)
#' grp(s = x, t = Y)
#'
grp <- function(s, t,
				objective = c("Forward", "Backward", "Symmetric", "Log"),
                conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
                obsposition = 1L, eps = 1e-12, iter = 500L, dentoninitialization = TRUE) {
  objective <- match.arg(objective)
  conversion <- match.arg(conversion)

  jd_s <- rjd3toolkit::.r2jd_tsdata(s)
  jd_t <- rjd3toolkit::.r2jd_tsdata(t)
  jd_rslt <- .jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "grp",
					jd_s, jd_t, objective, conversion, as.integer(obsposition), eps, as.integer(iter), as.logical(dentoninitialization))
  rjd3toolkit::.jd2r_tsdata(jd_rslt)
}

#' @title Benchmarking by means of Cubic Splines
#'
#' @description
#' Cubic splines are piecewise cubic functions that are linked together in a way
#' to guarantee smoothness at data points. Additivity constraints are added for
#' benchmarking purpose and sub-period estimates are derived from each spline.
#' When a preliminary series is used, cubic splines are no longer drawn based on
#' the low-frequency constraint but the Benchmark-to-Indicator (BI ratio) is the
#' one being smoothed. Sub-period estimates are then simply the product between
#' the smoothed high frequency BI ratio and the preliminary series.
#'
#' @param s A preliminary series. If not `NULL`, it must be of the same class as `t`.
#' @param t The low-frequency aggregation constraint. It must be either an object of class `ts` or a numeric vector.
#' @param nfreq An integer giving the annual frequency of the benchmarked series.
#' This argument is used only when no preliminary series is provided.
#' @param conversion A character string specifying the conversion mode, typically `"Sum"` (the default) or `"Average"`. Other options are: `"Last"`, `"First"` and `"UserDefined"`.
#' @param obsposition An integer specifying the position of the observations of the low-frequency constraint within the benchmarked series (e.g. the 7th month of the year).
#' This argument is used only when `conversion = "UserDefined"`.
#'
#' @return A `"ts"` object with the benchmarked series is returned.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#'
#' # Cubic spline without preliminary series
#' y1 <- cubicspline(t = Y, nfreq = 4L)
#'
#' # Cubic spline with preliminary series
#' x1 <- y1 + rnorm(n = length(y1), mean = 0, sd = 10)
#' cubicspline(s = x1, t = Y)
#'
#' # Cubic splines used for temporal disaggregation
#' x2 <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
#' cubicspline(s = x2, t = Y)
#'
cubicspline <- function(s = NULL, t, nfreq = 4L,
                        conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
                        obsposition = 1L) {

    conversion <- match.arg(conversion)

    jd_t <- rjd3toolkit::.r2jd_tsdata(t)

    if (!is.null(s)) {
        jd_s <- rjd3toolkit::.r2jd_tsdata(s)
    } else {
        jd_s <- as.integer(nfreq)
    }
    jd_rslt <- .jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "cubicSpline",
                      jd_s, jd_t, conversion, as.integer(obsposition))
    rjd3toolkit::.jd2r_tsdata(jd_rslt)
}


#' @title Benchmarking by means of the Cholette Method
#'
#' @description
#' Cholette method is based on a benchmarking methodology developed at
#' Statistics Canada. It is a generalized method relying on the principle of
#' movement preservation that encompasses other benchmarking methods.
#' The Denton method (both the AFD and PFD variants), as well as the naive
#' pro-rating method, emerge as particular cases of the Cholette method.
#' This method has been widely used for the purpose of benchmarking seasonally
#' adjusted series among others.
#'
#' @param s A preliminary series. It must be of the same class as `t`.
#' @param t The low-frequency aggregation constraint. It must be either a `"ts"` object or a numeric vector.
#' @param rho Numeric. A smoothing parameter whose value must lie between 0 and 1.
#' See the package vignette for more information on the choice of the `rho` parameter.
#' @param lambda Numeric. The adjustment model parameter. Typical choices include `lambda = 1` for proportional benchmarking, `lambda = 0` for additive benchmarking, and `lambda = 0.5` with `rho = 0` for the naive pro-rating method.
#' See the package vignette for more information on the choice of the `lambda` parameter.
#' @param bias Character. Specifies the bias-correction factor. By default, no systematic bias is considered. Other options are: "Additive" and "Multiplicative". See vignette for more details.
#' See the package vignette for more information on the other alternatives.
#' @param conversion A character string specifying the conversion mode, typically `"Sum"` (the default) or `"Average"`. Other options are: `"Last"`, `"First"` and `"UserDefined"`.
#' @param obsposition An integer specifying the position of the observations of the low-frequency constraint within the benchmarked series (e.g. the 7th month of the year).
#' This argument is used only when `conversion = "UserDefined"`.
#'
#' @return A `"ts"` object with the benchmarked series is returned.
#'
#' @references Quenneville, B., Fortier S., Chen Z.-G., Latendresse E. (2006).
#'   Recent Developments in Benchmarking to Annual Totals in X12-ARIMA and at
#'   Statistics Canada. Statistics Canada, Working paper of the Time Series
#'   Research and Analysis Centre.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' ym_true <- rjd3toolkit::Retail$RetailSalesTotal
#' yq_true <- rjd3toolkit::aggregate(ym_true, 4)
#' Y_full <- rjd3toolkit::aggregate(ym_true, 1)
#'
#' Y <- window(Y_full, end = c(2009,1)) # say no benchmark yet for the year 2010
#' xm <- ym_true + rnorm(n = length(ym_true), mean = -5000, sd = 10000)
#' xq <- rjd3toolkit::aggregate(xm, 4)
#'
#' # Proportional benchmarking with a bias and some recommended value of rho for
#' # monthly and quarterly series respectively
#' cholette(s = xm, t = Y, rho = 0.9, lambda = 1, bias = "Multiplicative")
#' cholette(s = xq, t = Y, rho = 0.729, lambda = 1, bias = "Multiplicative")
#'
#' # Proportional benchmarking with no bias
#' xm_no_bias <- ym_true + rnorm(n = length(ym_true), mean = 0, sd = 10000)
#' cholette(s = xm_no_bias, t = Y, rho = 0.9, lambda = 1)
#'
#' # Additive benchmarking
#' cholette(s = xm, t = Y, rho = 0.9, lambda = 0, bias = "Additive")
#'
#' # Denton PFD
#' cholette(s = xm, t = Y, rho = 1, lambda = 1)
#'
#' # Pro-rating
#' cholette(s = xm, t = Y, rho = 0, lambda = 0.5)
#'
cholette <- function(s, t, rho = 1., lambda = 1.,
                     bias = c("None", "Additive", "Multiplicative"),
                     conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
                     obsposition = 1L) {
    bias <- match.arg(bias)
    conversion <- match.arg(conversion)

    jd_s <- rjd3toolkit::.r2jd_tsdata(s)
    jd_t <- rjd3toolkit::.r2jd_tsdata(t)
    jd_rslt <- .jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "cholette",
                      jd_s, jd_t, rho, lambda, bias, conversion, as.integer(obsposition))
    rjd3toolkit::.jd2r_tsdata(jd_rslt)
}

#' @title Reconciliation by means of the Multivariate Cholette Method
#'
#' @description
#' This is a multivariate extension of the Cholette benchmarking method which
#' can be used for the purpose of reconciliation. While standard benchmarking
#' methods consider one target series at a time, reconciliation techniques aim
#' to restore consistency in a system of time series with regards to both
#' contemporaneous and temporal constraints. Reconciliation techniques are
#' typically needed when the total and its components are estimated
#' independently (the so-called direct approach). The multivariate Cholette
#' method relies on the principle of movement preservation and encompasses other
#' reconciliation methods such as the multivariate Denton method.
#'
#' @param xlist A named list of `ts` objects containing all input. Each element
#'   should correspond to one input series: a preliminary series, a
#'   low-frequency series representing a temporal aggregation constraint, or a
#'   high-frequency series representing a contemporaneous constraint.
#' @param tcvector A character vector defining the temporal constraints. Each
#'   element must be written in the form `"Y = sum(x)"`, where `"Y"` is the name
#'   of a low-frequency temporal constraint and `"x"` is the name of a
#'   high-frequency preliminary series. The names must match those provided in
#'   `xlist`. The default is `NULL`, indicating that no temporal constraints are
#'   considered.
#' @param ccvector NULL (default) or a character vector defining each contemporaneous constraints. If NULL, no contemporaneous constraint is considered.This is equivalent to applying the univariate Cholette method to each of the preliminary series separately. Otherwise, each element of the vector must be written in the form \eqn{z=w_1 x_1+\ldots+w_n x_n} or \eqn{c=w_1 x_1+\ldots+w_n x_n} where:
#' * \eqn{z} is the name of a high-frequency contemporaneous constraint,
#' * \eqn{(w_1,\ldots,w_n)} are optional numeric weights,
#' * \eqn{(x_1,\ldots,x_n)} are the names of the high-frequency preliminary series and
#' * \eqn{c} is a constant.
#'
#' The \eqn{+} operator can be replaced by \eqn{-}. The names of the contemporaneous constraint(s) and the preliminary series are the one given in the `xlist` argument.
#'
#' \strong{Important}: Any series placed on the left-hand side of a constraint cannot appear on the right-hand side of any other constraint. This is because quantities on the left-hand side are fixed, while those on the right-hand side are adjusted to satisfy the equality.
#' @param rho Numeric. The smoothing parameter whose value must lie between 0
#'   and 1. The default is `0.8`. See the package vignette for more information
#'   on the choice of the `rho` parameter.
#' @param lambda Numeric. The adjustment model parameter. Typical values include
#'   `lambda = 0`, `lambda = 0.5` (the default) and `lambda = 1`. See the package
#'   vignette for more information on the choice of the `lambda` parameter.
#'
#' @return A named list containing the benchmarked series is returned.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' # Example 1: one "standard" contemporaneous constraint: z=x1+x2+x3
#'
#' x1 <- ts(c(7, 7.2, 8.1, 7.5, 8.5, 7.8, 8.1, 8.4), frequency = 4, start = c(2010, 1))
#' x2 <- ts(c(18, 19.5, 19.0, 19.7, 18.5, 19.0, 20.3, 20.0), frequency = 4, start = c(2010, 1))
#' x3 <- ts(c(1.5, 1.8, 2, 2.5, 2.0, 1.5, 1.7, 2.0), frequency = 4, start = c(2010, 1))
#'
#' z <- ts(c(27.1, 29.8, 29.9, 31.2, 29.3, 27.9, 30.9, 31.8), frequency = 4, start = c(2010, 1))
#'
#' Y1 <- ts(c(30.0, 30.6), frequency = 1, start = c(2010, 1))
#' Y2 <- ts(c(80.0, 81.2), frequency = 1, start = c(2010, 1))
#' Y3 <- ts(c(8.0, 8.1), frequency = 1, start = c(2010, 1))
#'
#' ## Check consistency between temporal and contemporaneous constraints
#' lfs <- cbind(Y1,Y2,Y3)
#' rowSums(lfs) - stats::aggregate.ts(z) # should all be 0
#'
#' data_list <- list(x1 = x1, x2 = x2, x3 = x3, z = z, Y1 = Y1, Y2 = Y2, Y3 = Y3)
#' tc <- c("Y1 = sum(x1)", "Y2 = sum(x2)", "Y3 = sum(x3)") # temporal constraints
#' cc <- c("z = x1+x2+x3") # (binding) contemporaneous constraint
#' cc_nb <- c("0 = x1+x2+x3-z") # non-binding contemporaneous constraint
#'
#' ## Run function with default values for rho and lambda
#' multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc)
#'
#' ## Run function with some trade-off values for rho and lambda
#' multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = .5, lambda = .5)
#'
#' ## Run function with the value of rho corresponding to Denton or Cholette
#' multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 1) # Denton
#' multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729) # Cholette
#'
#' ## Run function without temporal constraints
#' multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc)
#'
#' ## Run function considering non-binding contemporaneous constraint
#' multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc_nb)
#'
#' # Example 2: two contemporaneous constraints: x1+3*x2+0.5*x3+x4+x5 = z1 and x1+x2 = x4
#'
#' x1 <- ts(c(7.0,7.3,8.1,7.5,8.5,7.8,8.1,8.4), frequency=4, start=c(2010,1))
#' x2 <- ts(c(1.5,1.8,2.0,2.5,2.0,1.5,1.7,2.0), frequency=4, start=c(2010,1))
#' x3 <- ts(c(18.0,19.5,19.0,19.7,18.5,19.0,20.3,20.0), frequency=4, start=c(2010,1))
#' x4 <- ts(c(8,9.5,9.0,10.7,8.5,10.0,10.3,9.0), frequency=4, start=c(2010,1))
#' x5 <- ts(c(5,9.6,7.2,7.1,4.3,4.6,5.3,5.9), frequency=4, start=c(2010,1))
#'
#' z1 <- ts(c(38.1,41.8,41.9,43.2,38.8,39.1,41.9,43.7), frequency=4, start=c(2010,1))
#'
#' Y1 <- ts(c(30.0,30.5), frequency=1, start=c(2010,1))
#' Y2 <- ts(c(10.0,10.5), frequency=1, start=c(2010,1))
#' Y3 <- ts(c(80.0,81.0), frequency=1, start=c(2010,1))
#' Y4 <- ts(c(40.0,41.0), frequency=1, start=c(2010,1))
#' Y5 <- ts(c(25.0,20.0), frequency=1, start=c(2010,1))
#'
#' ### check consistency between temporal and contemporaneous constraints
#' wlfs <- cbind(Y1,3*Y2,0.5*Y3,Y4,Y5)
#' rowSums(wlfs) - stats::aggregate.ts(z1) # cc1: should all be 0
#' Y1 + Y2 - Y4 # cc2: should all be 0
#'
#' data.list <- list(x1=x1,x2=x2,x3=x3,x4=x4,x5=x5,z1=z1,Y1=Y1,Y2=Y2,Y3=Y3,Y4=Y4,Y5=Y5)
#' tc <- c("Y1=sum(x1)", "Y2=sum(x2)", "Y3=sum(x3)", "Y4=sum(x4)", "Y5=sum(x5)")
#' cc <- c("z1=x1+3*x2+0.5*x3+x4+x5", "0=x1+x2-x4")
#'
#' multivariatecholette(xlist = data.list, tcvector = tc, ccvector = cc)
#'
multivariatecholette <- function(xlist, tcvector = NULL, ccvector = NULL, rho = 0.8, lambda = 0.5) {
    if (!is.list(xlist) || length(xlist) < 3L) {
        stop("incorrect argument, first argument should be a list of at least 3 time series")
    }

    #create the input
    jdic <- .jnew("jdplus/toolkit/base/r/util/Dictionary")
    for (i in seq_along(xlist)){
        .jcall(jdic, "V", "add", names(xlist[i]), rjd3toolkit::.r2jd_tsdata(xlist[[i]]))
    }
    if (is.null(tcvector)) {
        ntc <- 0L
        jtc <- .jcast(.jnull(), "[Ljava/lang/String;")
    } else if (is.vector(tcvector)) {
        ntc <- length(tcvector)
        jtc <- .jarray(tcvector, "java/lang/String")
    } else {
        stop("incorrect argument, constraints should be presented within a character vector")
    }
    if (is.null(ccvector)) {
        ncc <- 0L
        jcc <- .jcast(.jnull(), "[Ljava/lang/String;")
    } else if (is.vector(ccvector)) {
        ncc <- length(ccvector)
        jcc <- .jarray(ccvector, "java/lang/String")
    } else {
        stop("incorrect argument, constraints should be presented within a character vector")
    }
    if (ntc + ncc == 0L) {
        stop("both constraint types are empty, include at least one temporal or contemporaneous constraint")
    }

    jd_rslt <- .jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/r/util/Dictionary;", "multiCholette",
                      jdic,  jtc, jcc, rho, lambda)
    if (is.jnull(jd_rslt)) {
        return(NULL)
    }
    rlist <- list()
    rnames <- intersect(names(xlist), .jcall(jd_rslt, "[S", "names"))
    for (i in seq_along(rnames)) {
        jts <- .jcall(jd_rslt, "Ljdplus/toolkit/base/api/timeseries/TsData;", "get", rnames[i])
        if (! is.jnull(jts)) {
            rlist[[rnames[i]]] <- rjd3toolkit::.jd2r_tsdata(jts)
        }
    }
    return(rlist)
}
