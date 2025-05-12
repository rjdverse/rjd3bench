#' @include utils.R
NULL

#' @title Benchmarking by means of the Denton method.
#'
#' @description
#' Denton method relies on the principle of movement preservation. There exist a
#' few variants corresponding to different definitions of movement preservation:
#' additive first difference (AFD), proportional first difference (PFD),
#' additive second difference (ASD), proportional second difference (PSD), etc.
#' The default and most widely used is the Denton PFD method.
#'
#' @param s Preliminary series. If not NULL, it must be the same class as t.
#' @param t Aggregation constraint. Mandatory. it must be either an object of
#'   class ts or a numeric vector.
#' @param d Differencing order. 1 by default.
#' @param mul Multiplicative or additive benchmarking. Multiplicative by
#'   default.
#' @param nfreq Annual frequency of the disaggregated variable. Used if no
#'   disaggregated series is provided.
#' @param modified Modified (TRUE) or unmodified (FALSE) Denton. Modified by
#'   default.
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by
#'   default.
#' @param obsposition Position of the observation in the aggregated period (only
#'   used with "UserDefined" conversion).
#' @param nbcsts Number of backcast periods. Ignored when a preliminary
#'   series is provided. (not yet implemented)
#' @param nfcsts Number of forecast periods. Ignored when a preliminary
#'   series is provided. (not yet implemented)
#'
#' @return The benchmarked series is returned
#'
#' @export
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#'
#' # denton PFD without a preliminary series
#' y1 <- denton(t = Y, nfreq = 4)
#' print(y1)
#'
#' # denton PFD without a preliminary series and conversion = "Average"
#' denton(t = Y, nfreq = 4, conversion = "Average")
#'
#' # denton PFD with a preliminary series
#' x <- y1 + rnorm(n = length(y1), mean = 0, sd = 10000)
#' denton(s = x, t = Y)
#'
#' # denton AFD with a preliminary series
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

#' @title Benchmarking of an atypical frequency series by means of the Denton method.
#'
#' @description
#' Denton method relies on the principle of movement preservation. There exist a
#' few variants corresponding to different definitions of movement preservation:
#' additive first difference (AFD), proportional first difference (PFD),
#' additive second difference (ASD), proportional second difference (PSD), etc.
#' The default and most widely used is the Denton PFD method. This "raw"
#' function extends the denton() function in a way that it can deal with any
#' frequency ratio between the preliminary series and the aggregation
#' constraint.
#'
#' @param s Preliminary series. If not NULL, it must be a numeric vector.
#' @param t Aggregation constraint. Mandatory. It must be a numeric vector.
#' @param freqratio Frequency ratio between the benchmarked series and the
#'   aggregation constraint. Mandatory. It must be a positive integer.
#' @param d Differencing order. 1 by default.
#' @param mul Multiplicative or additive benchmarking. Multiplicative by
#'   default.
#' @param modified Modified (TRUE) or unmodified (FALSE) Denton. Modified by
#'   default.
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by
#'   default.
#' @param obsposition Position of the observation in the aggregated period (only
#'   used with "UserDefined" conversion).
#' @param startoffset Number of initial observations in the indicator(s) series that are prior to
#' the period covered by the low-frequency series.
#' Must be 0 or a positive integer. 0 by default. Ignored when no preliminary series is provided.
#' @param nbcsts Number of backcast periods. Ignored when a preliminary series
#'   is provided. (not yet implemented)
#' @param nfcsts Number of forecast periods. Ignored when a preliminary series
#'   is provided. (not yet implemented)
#'
#' @return Numeric vector. The benchmarked series.
#'
#' @export
#' @examples
#' Y <- c(500,510,525,520)
#' x <- c(97, 98, 98.5, 99.5, 104,
#'        99, 100, 100.5, 101, 105.5,
#'        103, 104.5, 103.5, 104.5, 109,
#'        104, 107, 103, 108, 113,
#'        110)
#'
#' # denton PFD (for example, x and Y could be annual and quiquennal series respectively)
#' denton_raw(x, Y, freqratio = 5)
#'
#' # denton AFD
#' denton_raw(x, Y, freqratio = 5, mul = FALSE)
#'
#' # denton PFD without indicator
#' denton_raw(t = Y, freqratio = 2, conversion = "Average")
#'
#' # denton PFD with/without an offset and conversion = "Last"
#' x2 <- c(485,
#'         490, 492.5, 497.5, 520, 495,
#'         500, 502.5, 505, 527.5, 515,
#'         522.5, 517.5, 522.5, 545, 520,
#'         535, 515, 540, 565, 550)
#' denton_raw(x2, Y, freqratio = 5, conversion = "Last")
#' denton_raw(x2, Y, freqratio = 5, conversion = "Last", startoffset = 1)
#'
#'
denton_raw<-function(s = NULL, t, freqratio, d = 1L, mul = TRUE, modified = TRUE,
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

#' @title Benchmarking following the growth rate preservation principle.
#'
#' @description
#' GRP is a method which explicitly preserves the period-to-period growth rates
#' of the preliminary series. It corresponds to the method of Cauley and Trager
#' (1981), using the solution proposed by Di Fonzo and Marini (2011). BFGS is
#' used as line-search algorithm for the reduced unconstrained minimization
#' problem.
#'
#' @param s Preliminary series. Mandatory. It must be a ts object.
#' @param t Aggregation constraint. Mandatory. It must be a ts object.
#' @param objective Objective function. See vignette and/or Daalmans et al.
#'   (2018) for more information.
#' @param conversion Conversion rule. "Sum" by default.
#' @param obsposition Position of the observation in the aggregated period (only
#'   used with "UserDefined" conversion)
#' @param eps Numeric. Defines the convergence precision. BFGS algorithm is run
#'   until the reduction in the objective is within this eps value (1e-12 is the
#'   default) or until the maximum number of iterations is hit.
#' @param iter Integer. Maximum number of iterations in BFGS algorithm (500 is
#'   the default).
#' @param dentoninitialization indicate whether the series benchmarked via
#'   modified Denton PFD is used as starting values of the GRP optimization
#'   procedure (TRUE/FALSE, TRUE by default). If FALSE, the average benchmark is
#'   used for flow variables (e.g. t/4 for quarterly series with annual
#'   constraints and conversion = 'Sum'), or the benchmark for stock variables.
#'
#' @return The benchmarked series is returned
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
#' @examples
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

#' @title Benchmarking by means of cubic splines
#'
#' @description
#' Cubic splines are piecewise cubic functions that are linked together in
#' a way to guarantee smoothness at data points. Additivity constraints are
#' added for benchmarking purpose and sub-period estimates are derived
#' from each spline. When a sub-period indicator (or a preliminary series) is
#' used, cubic splines are no longer drawn based on the low frequency data
#' but the Benchmark-to-Indicator (BI ratio) is the one being smoothed. Sub-
#' period estimates are then simply the product between the smoothed high
#' frequency BI ratio and the indicator.
#'
#' @param s Preliminary series. If not NULL, it must be the same class as t.
#' @param t Aggregation constraint. Mandatory. it must be either an object of class ts or a numeric vector.
#' @param nfreq Integer. Annual frequency of the benchmarked series. Used if no preliminary series is provided.
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by default.
#' @param obsposition Integer. Postion of the observation in the aggregated period (only used with "UserDefined" conversion)
#'
#' @return The benchmarked series is returned
#' @export
#'
#' @examples
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#'
#' # cubic spline without preliminary series
#' y1 <- cubicspline(t = Y, nfreq = 4L)
#'
#' # cubic spline with preliminary series
#' x1 <- y1 + rnorm(n = length(y1), mean = 0, sd = 10)
#' cubicspline(s = x1, t = Y)
#'
#' # cubic splines used for temporal disaggregation
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


#' @title Benchmarking by means of the Cholette method
#'
#' @description
#' Cholette method is based on a benchmarking methodology developed at
#' Statistics Canada. It is a generalized model relying on the principle of
#' movement preservation that encompasses several other benchmarking methods.
#' The Denton method (both the AFD and PFD variants), as well as the naive
#' pro-rating method, emerge as particular cases of the Cholette method.
#' This method has been widely used for the purpose of benchmarking seasonally
#' adjusted series among others.
#'
#' @param s Preliminary series. Mandatory. It must be the same class as t.
#' @param t Aggregation constraint. Mandatory. It must be either an object of class ts or a numeric vector.
#' @param rho Numeric. Smoothing parameter whose value should be between 0 and 1. See vignette for more information on the choice of the rho parameter.
#' @param lambda Numeric. Adjustment model parameter. Typically, lambda = 1 for proportional benchmarking; lambda = 0 for additive benchmarking; and lambda = 0.5 with rho = 0 for the naive pro-rating method. See vignette for more information on the choice of the lambda parameter.
#' @param bias Character. Bias correction factor. No systematic bias is considered by default. See vignette for more details.
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by default.
#' @param obsposition Position of the observation in the aggregated period (only used with "UserDefined" conversion).
#'
#' @return The benchmarked series is returned
#' @export
#'
#' @examples
#' ym_true <- rjd3toolkit::Retail$RetailSalesTotal
#' yq_true <- rjd3toolkit::aggregate(ym_true, 4)
#' Y_full <- rjd3toolkit::aggregate(ym_true, 1)
#'
#' Y <- window(Y_full, end = c(2009,1)) # say no benchmark yet for the year 2010
#' xm <- ym_true + rnorm(n = length(ym_true), mean = -5000, sd = 10000)
#' xq <- rjd3toolkit::aggregate(xm, 4)
#'
#' # Proportional benchmarking with a bias and some recommended value of rho for
#' # monthly and quarterly series respectively (see vignette)
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

#' @title Multi-variate Cholette
#'
#' @param xlist
#' @param tcvector
#' @param ccvector
#' @param rho
#' @param lambda
#'
#' @return
#' @export
#'
#' @examples
#'
#' s1 <- ts(c(7, 7.2, 8.1, 7.5, 8.5, 7.8, 8.1, 8.4), frequency = 4, start = c(2010, 1))
#' s2 <- ts(c(18, 19.5, 19.0, 19.7, 18.5, 19.0, 20.3, 20.0), frequency = 4, start = c(2010, 1))
#' s3 <- ts(c(1.5, 1.8, 2, 2.5, 2.0, 1.5, 1.7, 2.0), frequency = 4, start = c(2010, 1))
#'
#' a <- ts(c(27.1, 29.8, 29.9, 31.2, 29.3, 27.9, 30.9, 31.8), frequency = 4, start = c(2010, 1))
#'
#' y1 <- ts(c(30.0, 30.6), frequency = 1, start = c(2010, 1))
#' y2 <- ts(c(80.0, 81.2), frequency = 1, start = c(2010, 1))
#' y3 <- ts(c(8.0, 8.1), frequency = 1, start = c(2010, 1))
#'
#' data_list <- list(s1 = s1, s2 = s2, s3 = s3, a = a, y1 = y1, y2 = y2, y3 = y3)
#'
#' cc <- c("a = s1+s2+s3") # contemporaneous constraints
#' tc <- c("y1 = sum(s1)", "y2 = sum(s2)", "y3 = sum(s3)") # temporal constraints
#'
#' output1 <- multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 1, lambda = .5) # = Denton
#' output2 <- multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729, lambda = .5) # = Cholette
#' output3 <- multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc, rho = 1, lambda = .5)
#'
multivariatecholette <- function(xlist, tcvector = NULL, ccvector = NULL, rho = 1., lambda = 1.) {
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
    rnames <- .jcall(jd_rslt, "[S", "names")
    for (i in seq_along(rnames)) {
        jts <- .jcall(jd_rslt, "Ljdplus/toolkit/base/api/timeseries/TsData;", "get", rnames[i])
        if (! is.jnull(jts)) {
            rlist[[rnames[i]]] <- rjd3toolkit::.jd2r_tsdata(jts)
        }
    }
    return(rlist)
}
