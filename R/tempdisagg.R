#' @include utils.R
#' @importFrom stats frequency is.ts setNames
NULL

#' @title Temporal Disaggregation of a Time Series by Regression Models.
#'
#' @description
#' Perform temporal disaggregation of low-frequency to high-frequency time
#' series by regression models. The implemented models include Chow-Lin,
#' Fernandez, Litterman and some variants of those algorithms.
#'
#' @param series A low-frequency time series to be disaggregated. It must be a `"ts"` object.
#' @param constant Boolean. Indicates whether a constant term is included in the model. The default is `TRUE`.
#' Note that this argument is used only with `model = "Ar1"` when `zeroinitialization = FALSE`. For additional information, see the package vignette.
#' @param trend Boolean. Indicates whether a linear trend is included in the model. The default is `FALSE`.
#' @param indicators One or more high-frequency indicator series used in the temporal disaggregation.
#' If `NULL` (the default), no indicator is used. When provided, the argument must be a `"ts"` object or a list of `"ts"` objects.
#' @param model A character string specifying the model of the error term at the disaggregated level.
#' The options are: `"Ar1"` (Chow Lin, the default), `"Rw"` (Fernandez), and `"RwAr1"` (Litterman).
#' @param freq An integer giving the annual frequency of the disaggregated series.
#' This argument is ignored when one or more indicator series is provided.
#' @param average Boolean. Indicates whether an average conversion should be considered. The default is `FALSE`, corresponding to additive conversion.
#' @param rho A numeric value giving the (initial) value of the autoregressive parameter.
#' This argument is used only for `"Ar1"` and `"RwAr1"` models.
#' @param rho.fixed Boolean. Specifies whether the supplied value of `rho` is fixed. The default is `FALSE`, which indicates that `rho` is estimated.
#' @param rho.truncated A numeric value defining the lower bound of the admissible range for `rho`.
#' The evaluation range is `[rho.truncated, 1[`.
#' @param zeroinitialization Boolean. If `TRUE`, the initial values of the autoregressive model are set to zero. The default is `FALSE`.
#' @param diffuse.algorithm A character string specifying the algorithm used for diffuse initialization. The default is `"SqrtDiffuse"`. Other options are: `"Diffuse"` and `"Augmented"`.
#' @param diffuse.regressors Boolean. Indicates whether the coefficients of the regression model are treated as diffuse (`TRUE`) or as fixed unknown (`FALSE`, the default).
#' @param nbcsts An integer specifying the number of backcast periods.
#' This argument is ignored when one or more indicator series is provided.
#' @param nfcsts An integer specifying the number of forecast periods.
#' This argument is ignored when one or more indicator series is provided.
#'
#' @return An object of class "JD3_TEMPDISAGG_RSLTS" is returned. The following are returned
#' invisibly as a list:
#' * `regression` `[[1]]` regression coefficients;
#' * `estimation` `[[2]]` disaggregated Time-Series and standard deviation, regression effects, smoothing part, parameter and residuals;
#' * `likelihood` `[[3]]` likelihood statistics.
#'
#' @export
#'
#' @seealso `temporal_interpolation()` for interpolation,
#'
#' `temporal_disaggregation_raw()` for temporal disaggregation of atypical frequency series,
#'
#' `temporal_interpolation_raw()` for interpolation of atypical frequency series
#'
#'
#' For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' # Chow-lin with a monthly indicator
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporal_disaggregation(Y, indicators = x)
#' td$estimation$disagg
#'
#' # Fernandez with and without a quarterly indicator
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#' x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
#' td1 <- temporal_disaggregation(Y, indicators = x, model = "Rw")
#' td1$estimation$disagg
#'
#' td2 <- temporal_disaggregation(Y, model = "Rw", nfcsts = 6)
#' td2$estimation$disagg
#'
#' # Chow-lin applied to index series
#' Y_index <- 100 * Y / Y[1]
#' x_index <- 100 * x / x[1]
#' td3 <- temporal_disaggregation(Y, indicators = x, average = TRUE)
#' td3$estimation$disagg
#'
temporal_disaggregation <- function(
        series,
        constant = TRUE,
        trend = FALSE,
        indicators = NULL,
        model = c("Ar1", "Rw", "RwAr1"),
        freq = 4L,
        average = FALSE,
        rho = 0.0,
        rho.fixed = FALSE,
        rho.truncated = 0.0,
        zeroinitialization = FALSE,
        diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
        diffuse.regressors = FALSE,
        nbcsts = 0L,
        nfcsts = 0L) {

	model <- match.arg(model)
    diffuse.algorithm <- match.arg(diffuse.algorithm)
    if (model != "Ar1" && !zeroinitialization) {
        constant <- FALSE
    }

    jseries <- rjd3toolkit::.r2jd_tsdata(series)
	if (!is.null(indicators)) {
	    jlist <- list()
        if (is.list(indicators)) {
            for (i in seq_along(indicators)) {
                jlist[[i]] <- rjd3toolkit::.r2jd_tsdata(indicators[[i]])
            }
        } else if (stats::is.ts(indicators)) {
            jlist[[1L]] <- rjd3toolkit::.r2jd_tsdata(indicators)
        } else {
            stop("Invalid indicators")
        }
        jindicators <- .jarray(jlist, contents.class = "jdplus/toolkit/base/api/timeseries/TsData")

        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationResults;",
            method = "processDisaggregation",
            jseries, constant, trend, jindicators, model, average, rho, rho.fixed,
            rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors
        )
    } else {
        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationResults;",
            method = "processDisaggregation",
            jseries, constant, trend, model, as.integer(freq), average, rho, rho.fixed,
            rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors,
            as.integer(nbcsts), as.integer(nfcsts)
        )
    }


    # Build the S3 result
    bcov <- rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars <- rjd3toolkit::.proc_vector(jrslt, "regnames")
    coef <- rjd3toolkit::.proc_vector(jrslt, "coeff")
    se <- sqrt(diag(bcov))
    t <- coef / se
    m <- data.frame(coef, se, t)
    row.names(m) <- vars

    regression <- list(
        type = model,
        conversion = ifelse(average, "Average", "Sum"),
        model = m,
        cov = bcov
    )

    disagg <- rjd3toolkit::.proc_ts(jrslt, "disagg")
    estimation <- list(
        disagg = disagg,
        edisagg = rjd3toolkit::.proc_ts(jrslt, "edisagg"),
        regeffect = rjd3toolkit::.proc_ts(jrslt, "regeffect"),
        smoothingpart = rjd3toolkit::.proc_numeric(jrslt, "smoothingpart"),
        parameter = rjd3toolkit::.proc_numeric(jrslt, "parameter"),
        eparameter = rjd3toolkit::.proc_numeric(jrslt, "eparameter"),
        residuals = .proc_residuals(jrslt, stats::frequency(disagg))
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3_TEMPDISAGG_RSLTS"
    return(output)
}


#' @title Temporal Disaggregation of an Atypical Frequency Series by Regression Models.
#'
#' @description
#' Perform temporal disaggregation of low-frequency to high-frequency time
#' series by regression models. The implemented models include Chow-Lin,
#' Fernandez, Litterman and some variants of those algorithms. The
#' `temporal_disaggregation_raw()` function extends `temporal_disaggregation()`
#' by allowing temporal disaggregation for any frequency ratio.
#'
#' @param series A low-frequency time series to be disaggregated. It must be a numeric vector.
#' @param constant Boolean. Indicates whether a constant term is included in the model. The default is `TRUE`.
#' Note that this argument is used only with `model = "Ar1"` when `zeroinitialization = FALSE`. For additional information on this, see the package vignette.
#' @param trend Boolean. Indicates whether a linear trend is included in the model. The default is `FALSE`.
#' @param indicators One or more high-frequency indicator series used in the temporal disaggregation.
#' If `NULL` (the default), no indicator is used. When provided, the argument must be a numeric vector or a matrix.
#' @param startoffset The number of initial observations in the indicator series that precede the start of the low-frequency series.
#' The value must be either 0 or a positive integer (default is 0). This argument is ignored when no indicator is provided.
#' @param model A character string specifying the model of the error term at the disaggregated level.
#' The options are: `"Ar1"` (Chow Lin, the default), `"Rw"` (Fernandez), and `"RwAr1"` (Litterman).
#' @param freqratio An integer specifying the frequency ratio between the disaggregated series and the low-frequency series.
#' This argument is mandatory and must be a positive integer.
#' @param average Boolean. Indicates whether an average conversion should be considered. The default is `FALSE`, corresponding to additive conversion.
#' @param rho A numeric value giving the (initial) value of the autoregressive parameter.
#' This argument is used only for `"Ar1"` and `"RwAr1"` models.
#' @param rho.fixed Boolean. Specifies whether the supplied value of `rho` is fixed. The default is `FALSE`, which indicates that `rho` is estimated.
#' @param rho.truncated A numeric value defining the lower bound of the admissible range for `rho`.
#' The evaluation range is `[rho.truncated, 1[`.
#' @param zeroinitialization Boolean. If `TRUE`, the initial values of the autoregressive model are set to zero. The default is `FALSE`.
#' @param diffuse.algorithm A character string specifying the algorithm used for diffuse initialization. The default is `"SqrtDiffuse"`. Other options are: `"Diffuse"` and `"Augmented"`.
#' @param diffuse.regressors Boolean. Indicates whether the coefficients of the regression model are treated as diffuse (`TRUE`) or as fixed unknown (`FALSE`, the default).
#' @param nbcsts An integer specifying the number of backcast periods.
#' This argument is ignored when one or more indicator series is provided.
#' @param nfcsts An integer specifying the number of forecast periods.
#' This argument is ignored when one or more indicator series is provided.
#'
#' @return An object of class "JD3_TEMPDISAGGRAW_RSLTS" is returned. The following are returned
#' invisibly as a list:
#' * `regression` `[[1]]` regression coefficients;
#' * `estimation` `[[2]]` disaggregated values and standard deviation, regression effects, smoothing part, parameter and residuals;
#' * `likelihood` `[[3]]` likelihood statistics.
#'
#' @export
#'
#' @seealso `temporal_interpolation_raw()`
#'
#' For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' # Use of Chow-lin method to disaggregate a biennial series with an annual indicator
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' td$estimation$disagg
#'
#' # Use of Fernandez method to disaggregate a series without indicator
#' # considering a frequency ratio of 5 (for example, it could be a quinquennial
#' # series to disaggregate on an annual basis)
#' Y2 <- c(500,510,525,520)
#' td2 <- temporal_disaggregation_raw(Y2, model = "Rw", freqratio = 5, nfcsts = 2)
#' td2$estimation$disagg
#'
#' # Same with an indicator, considering an offset in the latter
#' Y2 <- c(500,510,525,520)
#' x2 <- c(97,
#'         98, 98.5, 99.5, 104, 99,
#'         100, 100.5, 101, 105.5, 103,
#'         104.5, 103.5, 104.5, 109, 104,
#'         107, 103, 108, 113, 110)
#' td3 <- temporal_disaggregation_raw(Y2, indicators = x2, startoffset = 1,
#'                                    model = "Rw", freqratio = 5)
#' td3$estimation$disagg
#'
temporal_disaggregation_raw <- function(
        series,
        constant = TRUE,
        trend = FALSE,
        indicators = NULL,
        startoffset = 0L,
        model = c("Ar1", "Rw", "RwAr1"),
        freqratio,
        average = FALSE,
        rho = 0.0,
        rho.fixed = FALSE,
        rho.truncated = 0.0,
        zeroinitialization = FALSE,
        diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
        diffuse.regressors = FALSE,
        nbcsts = 0L,
        nfcsts = 0L) {

    model <- match.arg(model)
    diffuse.algorithm <- match.arg(diffuse.algorithm)
    if(!is.vector(series, mode = "numeric")){
        stop("The input series must be a numeric vector")
    }
    if (model != "Ar1" && !zeroinitialization) {
        constant <- FALSE
    }

    if (!is.null(indicators)) {
        if (is.matrix(indicators)) {
            jindicators <- rjd3toolkit::.r2jd_matrix(indicators)
        } else if (is.vector(indicators, mode = "numeric")) {
            jindicators <- rjd3toolkit::.r2jd_matrix(as.matrix(indicators))
        } else{
            stop("Indicators must be either a numeric vector or a matrix")
        }
        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/RawTemporalDisaggregationResults;",
            method = "processRawDisaggregation",
            as.numeric(series), constant, trend, jindicators, as.integer(startoffset), model,
            as.integer(freqratio), average, rho, rho.fixed,
            rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors
        )
    } else{
        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/RawTemporalDisaggregationResults;",
            method = "processRawDisaggregation",
            as.numeric(series), constant, trend, model, as.integer(freqratio), average,
            rho, rho.fixed, rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors,
            as.integer(nbcsts), as.integer(nfcsts)
        )
    }

    # Build the S3 result
    bcov <- rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars <- c()
    if(constant) vars <- "C"
    if(trend) vars <- c(vars, "Trend")
    if (!is.null(indicators)) {
        if (is.matrix(indicators)) {
            for (i in 1:ncol(indicators)) {
                vars <- c(vars, paste0("var", i))
            }
        }
        else vars <- c(vars, "var1")
    }
    coef <- rjd3toolkit::.proc_vector(jrslt, "coeff")
    se <- sqrt(diag(bcov))
    t <- coef/se
    m <- data.frame(coef, se, t)
    if(nrow(m) > 0) row.names(m) <- vars

    regression <- list(
        type = model,
        conversion = ifelse(average, "Average", "Sum"),
        model = m,
        cov = bcov
    )

    estimation <- list(
        disagg = rjd3toolkit::.proc_vector(jrslt, "disagg"),
        edisagg = rjd3toolkit::.proc_vector(jrslt, "edisagg"),
        regeffect = rjd3toolkit::.proc_vector(jrslt, "regeffect"),
        smoothingpart = ifelse(!is.null(vars), rjd3toolkit::.proc_numeric(jrslt, "smoothingpart"), NaN),
        parameter = rjd3toolkit::.proc_numeric(jrslt, "parameter"),
        eparameter = rjd3toolkit::.proc_numeric(jrslt, "eparameter"),
        residuals = .proc_residuals(jrslt, freqratio)
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3_TEMPDISAGGRAW_RSLTS"
    return(output)
}


#' @title Interpolation of a Time Series by Regression Models.
#'
#' @description
#' Perform temporal interpolation of low-frequency to high-frequency time
#' series by regression models. The implemented models include Chow-Lin,
#' Fernandez, Litterman and some variants of those algorithms.
#'
#' @param series A low-frequency time series to be interpolated. It must be a `"ts"` object.
#' @param constant Boolean. Indicates whether a constant term is included in the model. The default is `TRUE`.
#' Note that this argument is used only with `model = "Ar1"` when `zeroinitialization = FALSE`. For additional information, see the package vignette.
#' @param trend Boolean. Indicates whether a linear trend is included in the model. The default is `FALSE`.
#' @param indicators One or more high-frequency indicator series used in the temporal interpolation.
#' If `NULL` (the default), no indicator is used. When provided, the argument must be a `"ts"` object or a list of `"ts"` objects.
#' @param model A character string specifying the model of the error term at the interpolated level.
#' The options are: `"Ar1"` (Chow Lin, the default), `"Rw"` (Fernandez), and `"RwAr1"` (Litterman).
#' @param freq An integer giving the annual frequency of the interpolated series.
#' This argument is ignored when one or more indicator series is provided.
#' @param obsposition An integer specifying the position of the low-frequency
#'   observations within the interpolated series (e.g. the 1st month of the
#'   year, the 2d month, etc.). The value must be a positive integer or `-1` (the
#'   default). The default value is equivalent to setting the value of the
#'   parameter equal to the frequency of the series, meaning that the last value
#'   of the interpolated series is consistent with the low-frequency series.
#' @param rho A numeric value giving the (initial) value of the autoregressive parameter.
#' This argument is used only for `"Ar1"` and `"RwAr1"` models.
#' @param rho.fixed Boolean. Specifies whether the supplied value of `rho` is fixed. The default is `FALSE`, which indicates that `rho` is estimated.
#' @param rho.truncated A numeric value defining the lower bound of the admissible range for `rho`.
#' The evaluation range is `[rho.truncated, 1[`.
#' @param zeroinitialization Boolean. If `TRUE`, the initial values of the autoregressive model are set to zero. The default is `FALSE`.
#' @param diffuse.algorithm A character string specifying the algorithm used for diffuse initialization. The default is `"SqrtDiffuse"`. Other options are: `"Diffuse"` and `"Augmented"`.
#' @param diffuse.regressors Boolean. Indicates whether the coefficients of the regression model are treated as diffuse (`TRUE`) or as fixed unknown (`FALSE`, the default).
#' @param nbcsts An integer specifying the number of backcast periods.
#' This argument is ignored when one or more indicator series is provided.
#' @param nfcsts An integer specifying the number of forecast periods.
#' This argument is ignored when one or more indicator series is provided.
#'
#' @return An object of class "JD3_INTERP_RSLTS" is returned. The following are returned
#' invisibly as a list:
#' * `regression` `[[1]]` regression coefficients;
#' * `estimation` `[[2]]` interpolated Time-Series and standard deviation, regression effects and smoothing part, parameter and residuals;
#' * `likelihood` `[[3]]` likelihood statistics.
#'
#' @export
#'
#' @seealso `temporal_disaggregation()`,
#'
#' `temporal_interpolation_raw()` for interpolation of atypical frequency series,
#'
#' `temporal_disaggregation_raw()` for temporal disaggregation of atypical frequency series
#'
#'
#' For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' # Chow-lin / Fernandez when the last value of the interpolated series is
#' # consistent with the low-frequency series
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' ti1 <- temporal_interpolation(Y, indicators = x)
#' ti1$estimation$interp
#'
#' ti2 <- temporal_interpolation(Y, indicators = x, model = "Rw")
#' ti2$estimation$interp
#'
#' # Same without indicator
#' ti3 <- temporal_interpolation(Y, model = "Rw", freq = 12, nfcsts = 6)
#' ti3$estimation$interp
#'
#  # Chow-lin when the first value of the interpolated series is the one
#  # consistent with the low-frequency series
#' ti4 <- temporal_interpolation(Y, indicators = x, obsposition = 1)
#' ti4$estimation$interp
#'
temporal_interpolation <- function(
        series,
        constant = TRUE,
        trend = FALSE,
        indicators = NULL,
        model = c("Ar1", "Rw", "RwAr1"),
        freq = 4L,
        obsposition = -1L,
        rho = 0.0,
        rho.fixed = FALSE,
        rho.truncated = 0.0,
        zeroinitialization = FALSE,
        diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
        diffuse.regressors = FALSE,
        nbcsts = 0L,
        nfcsts = 0L) {

    model <- match.arg(model)
    diffuse.algorithm <- match.arg(diffuse.algorithm)
    if (model != "Ar1" && !zeroinitialization) {
        constant <- FALSE
    }
    if(obsposition > 0){
        obsposition <- obsposition - 1L
    }else if (obsposition != -1){
        stop("obsposition must be set to -1 (default) or a positive integer")
    }

    jseries <- rjd3toolkit::.r2jd_tsdata(series)
    if (!is.null(indicators)) {
        jlist <- list()
        if (is.list(indicators)) {
            for (i in seq_along(indicators)) {
                jlist[[i]] <- rjd3toolkit::.r2jd_tsdata(indicators[[i]])
            }
        } else if (stats::is.ts(indicators)) {
            jlist[[1L]] <- rjd3toolkit::.r2jd_tsdata(indicators)
        } else {
            stop("Invalid indicators")
        }
        jindicators <- .jarray(jlist, contents.class = "jdplus/toolkit/base/api/timeseries/TsData")

        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationResults;",
            method = "processInterpolation",
            jseries, constant, trend, jindicators, model, as.integer(obsposition), rho, rho.fixed,
            rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors
        )
    } else {
        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationResults;",
            method = "processInterpolation",
            jseries, constant, trend, model, as.integer(freq), as.integer(obsposition), rho, rho.fixed,
            rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors,
            as.integer(nbcsts), as.integer(nfcsts)
        )
    }


    # Build the S3 result
    bcov <- rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars <- rjd3toolkit::.proc_vector(jrslt, "regnames")
    coef <- rjd3toolkit::.proc_vector(jrslt, "coeff")
    se <- sqrt(diag(bcov))
    t <- coef / se
    m <- data.frame(coef, se, t)
    row.names(m) <- vars

    interp <- rjd3toolkit::.proc_ts(jrslt, "disagg")
    f <- stats::frequency(interp)

    regression <- list(
        type = model,
        obsposition = ifelse(obsposition == -1L, f, obsposition),
        model = m,
        cov = bcov
    )

    estimation <- list(
        interp = interp,
        einterp = rjd3toolkit::.proc_ts(jrslt, "edisagg"),
        regeffect = rjd3toolkit::.proc_ts(jrslt, "regeffect"),
        smoothingpart = rjd3toolkit::.proc_numeric(jrslt, "smoothingpart"),
        parameter = rjd3toolkit::.proc_numeric(jrslt, "parameter"),
        eparameter = rjd3toolkit::.proc_numeric(jrslt, "eparameter"),
        residuals = .proc_residuals(jrslt, f)
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3_INTERP_RSLTS"
    return(output)
}


#' @title Interpolation of an Atypical Frequency Series by Regression Models.
#'
#' @description
#' Perform temporal interpolation of low-frequency to high-frequency time series
#' by regression models. The implemented models include Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms. The
#' `temporal_interpolation_raw()` function extends `temporal_interpolation()` by
#' allowing temporal interpolation for any frequency ratio.
#'
#' @param series A low-frequency time series to be interpolated. It must be a numeric vector.
#' @param constant Boolean. Indicates whether a constant term is included in the model. The default is `TRUE`.
#' Note that this argument is used only with `model = "Ar1"` when `zeroinitialization = FALSE`. For additional information, see the package vignette.
#' @param trend Boolean. Indicates whether a linear trend is included in the model. The default is `FALSE`.
#' @param indicators One or more high frequency indicator series used in the interpolation.
#' If `NULL` (the default), no indicator is used. When provided, the argument must be a numeric vector or a matrix.
#' @param startoffset The number of initial observations in the indicator series that precede the start of the low-frequency series.
#' The value must be either 0 or a positive integer (default is 0). This argument is ignored when no indicator is provided.
#' @param model A character string specifying the model of the error term at the disaggregated level.
#' The options are: `"Ar1"` (Chow Lin, the default), `"Rw"` (Fernandez), and `"RwAr1"` (Litterman).
#' @param freqratio An integer specifying the frequency ratio between the interpolated series and the low-frequency series.
#' This argument is mandatory and must be a positive integer.
#' @param obsposition An integer specifying the position of the low-frequency
#'   observations within the interpolated series (e.g. the 1st month of the
#'   year, the 2d month, etc.). The value must be a positive integer or `-1`
#'   (the default).The default value is equivalent to setting the value of the
#'   parameter equal to the frequency of the series, meaning that the last value
#'   of the interpolated series is consistent with the low-frequency series.
#' @param rho A numeric value giving the (initial) value of the autoregressive parameter.
#' This argument is used only for `"Ar1"` and `"RwAr1"` models.
#' @param rho.fixed Boolean. Specifies whether the supplied value of `rho` is fixed. The default is `FALSE`, which indicates that `rho` is estimated.
#' @param rho.truncated A numeric value defining the lower bound of the admissible range for `rho`.
#' The evaluation range is `[rho.truncated, 1[`.
#' @param zeroinitialization Boolean. If `TRUE`, the initial values of the autoregressive model are set to zero. The default is `FALSE`.
#' @param diffuse.algorithm A character string specifying the algorithm used for diffuse initialization. The default is `"SqrtDiffuse"`. Other options are: `"Diffuse"` and `"Augmented"`.
#' @param diffuse.regressors Boolean. Indicates whether the coefficients of the regression model are treated as diffuse (`TRUE`) or as fixed unknown (`FALSE`, the default).
#' @param nbcsts An integer specifying the number of backcast periods.
#' This argument is ignored when one or more indicator series is provided.
#' @param nfcsts An integer specifying the number of forecast periods.
#' This argument is ignored when one or more indicator series is provided.
#'
#' @return An object of class "JD3_INTERPRAW_RSLTS" is returned. The following are returned
#' invisibly as a list:
#' * `regression` `[[1]]` regression coefficients;
#' * `estimation` `[[2]]` interpolated values and standard deviation, regression effects, smoothing part, parameter and residuals;
#' * `likelihood` `[[3]]` likelihood statistics.
#'
#' @export
#'
#' @seealso `temporal_disaggregation_raw()`
#'
#' For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' # Use of Chow-lin method to interpolate a biennial series with an annual
#' # indicator (the low-frequency series is consistent with the last value of the
#' # interpolated series)
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' ti$estimation$interp
#'
#' # Use of Fernandez method to interpolate a series without indicator
#' # considering a frequency ratio of 5 (the low-frequency series is consistent
#' # with the last value of the interpolated series). For example, Y2 could be a
#' # quinquennial series to interpolate annually.
#' Y2 <- c(500,510,525,520)
#' ti2 <- temporal_interpolation_raw(Y2, model = "Rw", freqratio = 5, nbcsts = 1, nfcsts = 2)
#' ti2$estimation$interp
#'
#' # Same with an indicator, considering an offset in the latter
#' Y2 <- c(500,510,525,520)
#' x2 <- c(485,
#'         490, 492.5, 497.5, 520, 495,
#'         500, 502.5, 505, 527.5, 515,
#'         522.5, 517.5, 522.5, 545, 520,
#'         535, 515, 540, 565, 550)
#' ti3 <- temporal_interpolation_raw(Y2, indicators = x2, startoffset = 1, model = "Rw", freqratio = 5)
#' ti3$estimation$interp
#'
#' # Same considering that the first value of the interpolated series is the one
#' # consistent with the low-frequency series
#' ti4 <- temporal_interpolation_raw(Y2, indicators = x2, startoffset = 1,
#'                                   model = "Rw", freqratio = 5, obsposition = 1)
#' ti4$estimation$interp
#'
temporal_interpolation_raw <- function(
        series,
        constant = TRUE,
        trend = FALSE,
        indicators = NULL,
        startoffset = 0L,
        model = c("Ar1", "Rw", "RwAr1"),
        freqratio,
        obsposition = -1L,
        rho = 0.0,
        rho.fixed = FALSE,
        rho.truncated = 0.0,
        zeroinitialization = FALSE,
        diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
        diffuse.regressors = FALSE,
        nbcsts = 0L,
        nfcsts = 0L) {

    model <- match.arg(model)
    diffuse.algorithm <- match.arg(diffuse.algorithm)
    if(!is.vector(series, mode = "numeric")){
        stop("The input series must be a numeric vector")
    }
    if (model != "Ar1" && !zeroinitialization) {
        constant <- FALSE
    }
    if(obsposition > 0){
        obsposition <- obsposition - 1L
    }else if (obsposition != -1){
        stop("obsposition must be set to -1 (default) or a positive integer")
    }

    if (!is.null(indicators)) {
        if (is.matrix(indicators)) {
            jindicators <- rjd3toolkit::.r2jd_matrix(indicators)
        } else if (is.vector(indicators, mode = "numeric")) {
            jindicators <- rjd3toolkit::.r2jd_matrix(as.matrix(indicators))
        } else{
            stop("Indicators must be either a numeric vector or a matrix")
        }
        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/RawTemporalDisaggregationResults;",
            method = "processRawInterpolation",
            as.numeric(series), constant, trend, jindicators, as.integer(startoffset), model,
            as.integer(freqratio), as.integer(obsposition), rho, rho.fixed,
            rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors
        )
    } else{
        jrslt <- .jcall(
            obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
            returnSig = "Ljdplus/benchmarking/base/core/univariate/RawTemporalDisaggregationResults;",
            method = "processRawInterpolation",
            as.numeric(series), constant, trend, model, as.integer(freqratio), as.integer(obsposition),
            rho, rho.fixed, rho.truncated, zeroinitialization, diffuse.algorithm, diffuse.regressors,
            as.integer(nbcsts), as.integer(nfcsts)
        )
    }

    # Build the S3 result
    bcov <- rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars <- c()
    if(constant) vars <- "C"
    if(trend) vars <- c(vars, "Trend")
    if (!is.null(indicators)) {
        if (is.matrix(indicators)) {
            for (i in 1:ncol(indicators)) {
                vars <- c(vars, paste0("var", i))
            }
        }
        else vars <- c(vars, "var1")
    }
    coef <- rjd3toolkit::.proc_vector(jrslt, "coeff")
    se <- sqrt(diag(bcov))
    t <- coef/se
    m <- data.frame(coef, se, t)
    if(nrow(m) > 0) row.names(m) <- vars

    regression <- list(
        type = model,
        obsposition = ifelse(obsposition == -1L, freqratio, obsposition),
        model = m,
        cov = bcov
    )

    estimation <- list(
        interp = rjd3toolkit::.proc_vector(jrslt, "disagg"),
        einterp = rjd3toolkit::.proc_vector(jrslt, "edisagg"),
        regeffect = rjd3toolkit::.proc_vector(jrslt, "regeffect"),
        smoothingpart = ifelse(!is.null(vars), rjd3toolkit::.proc_numeric(jrslt, "smoothingpart"), NaN),
        parameter = rjd3toolkit::.proc_numeric(jrslt, "parameter"),
        eparameter = rjd3toolkit::.proc_numeric(jrslt, "eparameter"),
        residuals = .proc_residuals(jrslt, freqratio)
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3_INTERPRAW_RSLTS"
    return(output)
}


#' @title Temporal Disaggregation and Interpolation of a Time Series by means of a Reverse Regression Model.
#'
#' @description
#' Perform temporal disaggregation and interpolation of low-frequency to high
#' frequency time series by means of a reverse regression model. Unlike the
#' usual regression-based models, this approach treats a high-frequency
#' indicator as the dependent variable and the unknown target series as the
#' independent variable.
#'
#' @param series A low-frequency time series to be disaggregated or interpolated. It must be a `"ts"` object.
#' @param indicator A high-frequency indicator series. It must be a `"ts"` object.
#' @param conversion A character string specifying the conversion mode, typically `"Sum"`(the default) or `"Average"`. Other options are: `"Last"`, `"First"` and `"UserDefined"`.
#' @param conversion.obsposition An integer specifying the position of the low-frequency observations within the interpolated series (e.g. the 7th month of the year).
#' This argument is used only for interpolation when `conversion = "UserDefined"`.
#' @param rho A numeric value giving the (initial) value of the autoregressive parameter.
#' @param rho.fixed Boolean. Specifies whether the supplied value of `rho` is fixed. The default is `FALSE`, which indicates that `rho` is estimated.
#' @param rho.truncated A numeric value defining the lower bound of the admissible range for `rho`.
#' The evaluation range is `[rho.truncated, 1[`.
#'
#' @return An object of class "JD3_TEMPDISAGGI_RSLTS" is returned. The following are returned
#' invisibly as a list:
#' * `regression` `[[1]]` regression coefficients;
#' * `estimation` `[[2]]` disaggregated Time-Series and parameter;
#' * `likelihood` `[[3]]` likelihood statistics.
#'
#' @references  Bournay J., Laroque G. (1979). Reflexions sur la methode
#'   d'elaboration des comptes trimestriels. Annales de l'Insee, n. 36, pp.3-30.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' # Retail data, monthly indicator
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporaldisaggregationI(Y, indicator = x)
#' td$estimation$disagg
#'
#' # qna data, quarterly indicator
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_CE"], frequency = 1, start = c(2009,1))
#' x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_CE"], frequency = 4, start = c(2009,1))
#' td <- temporaldisaggregationI(Y, indicator = x)
#' td$regression$a
#' td$regression$b
#'
temporaldisaggregationI <- function(series, indicator,
                                    conversion = c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition = 1L,
                                    rho = 0., rho.fixed = FALSE,  rho.truncated = 0.) {
    conversion <- match.arg(conversion)
    jseries <- rjd3toolkit::.r2jd_tsdata(series)
    jlist <- list()
    jindicator <- rjd3toolkit::.r2jd_tsdata(indicator)
    jrslt <- .jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationIResults;",
                    "processI", jseries, jindicator, "Ar1", conversion, as.integer(conversion.obsposition), rho, rho.fixed, rho.truncated)
    # Build the S3 result
    a <- rjd3toolkit::.proc_numeric(jrslt, "a")
    b <- rjd3toolkit::.proc_numeric(jrslt, "b")

    regression <- list(
        conversion = conversion,
        a = a,
        b = b
    )
    estimation <- list(
        disagg = rjd3toolkit::.proc_ts(jrslt, "disagg"),
        parameter = rjd3toolkit::.proc_numeric(jrslt, "parameter")
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3_TEMPDISAGGI_RSLTS"
    return(output)
}


#' @title Multivariate Temporal Disaggregaton of a System of Time Series by Regression Models.
#'
#' @description
#' Performs simultaneous temporal disaggregation of a system of low frequency
#' time series into higher frequency series, based on the multivariate
#' extension of the Chow-Lin model or the Random Walk approach (Fernandez).
#'
#' @param series A named list of `ts` objects containing the low frequency time series to be disaggregated.
#' @param constant Either a Boolean or a vector of Booleans. If a vector is provided, each element specifies whether a constant term is included in the model for each series, following the order in which they appear in the `series` object.
#' The length of the the vector must match the number of series.
#' If a single Boolean is provided (default if `TRUE`), it is applied to all series.
#' Note that this argument is used only with Chow-Lin model (i.e., when `rhos` values are strictly less than 1). For further details, see the package vignette.
#' @param trend Either a Boolean or a vector of Booleans. If a vector is provided, each element specifies whether a linear trend is included in the model for each series, following the order in which they appear in the `series` object.
#' The length of the the vector must match the number of series.
#' If a single Boolean is provided (default if `FALSE`), it is applied to all series.
#' @param indicators a named list of `ts` objects or a named list of a list of `ts` objects. Each element represents one or more high-frequency indicator series associated with each series.
#' If an element is `NULL`, no indicator is used for the corresponding series. The default value is `NULL`, meaning that no indicators are used for any series.
#' @param ccseries A named list of `ts` objects containing the contemporaneous constraints. If `NULL` (the default), no contemporaneous constraints can be considered.
#' @param ccdefinition A character vector defining each contemporaneous constraints. The elements of the vector must be written in the form \eqn{z=w_1 y_1+\ldots+w_n y_n} or \eqn{c=w_1 y_1+\ldots+w_n y_n} where:
#' * \eqn{z} is the name of a contemporaneous constraint,
#' * \eqn{(w_1,\ldots,w_n)} are optional numeric weights,
#' * \eqn{(y_1,\ldots,y_n)} are the names of the time series and
#' * \eqn{c} is a constant.
#' The default is `NULL`, meaning that no contemporaneous constraint is considered.
#' @param freq An integer giving the annual frequency of the disaggregated series.
#' This argument is ignored when at least one indicator series is provided for any series.
#' @param rhos Either a numeric value or a vector of numerics. If a vector is provided, each element specifies the value of the `rho` parameter associated to each series, following the order in which they appear in the `series` object.
#' The length of the the vector must match the number of series.
#' If a single numeric value is provided (default if `1`, corresponding to the Fernandez model), it is applied to all series.
#' @param var A character string specifying the method used to estimate the variance-covariance matrix of the innovations.
#' The default is `"fromUnivariate"`, meaning that is is estimated from the residuals of the univariate models. Others options include `"allEquals"`, which assume a diagonal matrix with identical variances (a strong assumption), and `"userDefined"`, where the matrix is supplied by the user via the `var.matrix` argument. For additional details, see the package vignette.
#' @param var.matrix The variance-covariance matrix of the innovations.
#' This argument is only used when `var = "userDefined"` and must be provided in that case.
#'
#' @return An object of class "JD3_MULTITEMPDISAGG_RSLTS" is returned. The following are returned
#' invisibly as a list:
#' * `regression` `[[1]]` regression coefficients for each series;
#' * `estimation` `[[2]]` disaggregated Time-Series and standard deviation for each series, regression effects, smoothing part, parameter and variance-covariance matrix;
#'
#' @export
#'
#' @seealso `multivariatecholette()` for time series reconciliation.
#'
#' For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version
#' # Low-frequency data
#' Y1 <- ts(c(30.0, 30.6, 31.2, 31.6), frequency = 1, start = c(2010,1))
#' Y2 <- ts(c(80.0, 81.2, 82.5, 82.6), frequency = 1, start = c(2010,1))
#' Y3 <- ts(c(8.0, 8.1, 8.2, 8.2), frequency = 1, start = c(2010,1))
#' lf_series <- list(y1 = Y1, y2 = Y2, y3 = Y3)
#'
#' # Contemporaneous constraint
#' z <- ts(c(27.1,29.8,29.9,31.2,29.4,27.9,30.9,31.7,29.2,30.2,30.6,31.9,29.3,30.4,30.7,32.0), frequency = 4, start = c(2010,1))
#'
#' # High-frequency indicators
#' x11 <- ts(c(7,7.2,8.1,7.5,8.5,7.8,8.1,8.4,8.6,7.8,8.0,8.3,8.7,7.9,8.0,8.6), frequency=4, start=c(2010,1))
#' x12 <- ts(c(18,19.5,19.0,19.7,18.5,19.0,20.3,20.0,18.6,19.5,20.4,20.1,18.7,19.1,20.4,20.8), frequency = 4, start = c(2010,1))
#' x2 <- NULL
#' x3 <- ts(c(1.5,1.8,2,2.5,2.0,1.5,1.7,2.1,2.1,1.6,1.6,2.2,2.3,1.7,1.9,2.3), frequency = 4, start = c(2010,1))
#' indic_series = list(y1 = list(x11, x12),
#'                     y2 = NULL,
#'                     y3 = x3)
#'
#' # Check consistency between temporal and contemporaneous constraints
#' rowSums(cbind(Y1,Y2,Y3)) - stats::aggregate.ts(z) # ok!
#'
#' # Estimate models and get results
#'
#' ## Mix Chow-Lin - Fernandez
#' rslt1 <- multivariatechowlin(series = lf_series,
#'                              constant = c(FALSE, FALSE, TRUE),
#'                              trend = c(FALSE, FALSE, FALSE),
#'                              indicators = indic_series,
#'                              ccseries = list(z = z),
#'                              ccdefinition = "z=y1+y2+y3",
#'                              freq = 4L,
#'                              rhos = c(0.85, 1.0, 0.9),
#'                              var = "fromUnivariate",
#'                              var.matrix = NULL)
#'
#' d1 <- do.call(cbind, rslt1$estimation$disagg)
#' ed1 <- do.call(cbind, rslt1$estimation$edisagg)
#'
#' ## Fernandez only (Random walk model) with user-defined variance-covariance matrix
#' rslt2 <- multivariatechowlin(series = lf_series,
#'                              constant = FALSE,
#'                              trend = FALSE,
#'                              indicators = indic_series,
#'                              ccseries = list(z = z),
#'                              ccdefinition = "z=y1+y2+y3",
#'                              freq = 4L,
#'                              rhos = 1.0,
#'                              var = "userDefined",
#'                              var.matrix = diag(c(0.003,0.01,0.001)))
#'
#' d2 <- do.call(cbind, rslt2$estimation$disagg)
#' ed2 <- do.call(cbind, rslt2$estimation$edisagg)
#'
multivariatechowlin <- function(series,
                                constant = TRUE,
                                trend = FALSE,
                                indicators = NULL,
                                ccseries = NULL,
                                ccdefinition = NULL,
                                freq = 4L,
                                rhos = 1,
                                var = c("fromUnivariate", "allEquals", "userDefined"),
                                var.matrix = NULL) {

    var <- match.arg(var)

    if(!is.null(var.matrix)) {
        if (!is.matrix(var.matrix) || any(var.matrix[!diag(nrow(var.matrix), ncol(var.matrix))] != 0)) {
            stop("Only diagonal variance covariance matrix of the innovations is currently supported.")
        }
    }

    n <- length(series)
    snames <- names(series)
    are_lists <- is.list(series) && is.list(indicators)
    same_size <- length(indicators) == n
    same_names <- setequal(snames, names(indicators))
    if (!are_lists || !same_size || !same_names) {
        stop("The 'series' and 'indicators' arguments must be lists with matching size and names.")
    }

    # create the input
    jdic_series <- .jnew("jdplus/toolkit/base/r/util/Dictionary")
    for (i in seq_along(series)){
        .jcall(jdic_series, "V", "add",
               snames[i],
               rjd3toolkit::.r2jd_tsdata(series[[i]]))
    }

    ncst <- length(constant)
    if (ncst == 1) {
        constant <- rep(constant, n)
    } else if (ncst != n) {
        stop("Size of 'constant' must be 1 or match number of series.")
    }
    jcst <- .jarray(as.logical(constant), contents.class = "Z")

    ntrend <- length(trend)
    if (ntrend == 1) {
        trend <- rep(trend, n)
    } else if (ntrend != n) {
        stop("Size of 'trend' must be 1 or match number of series.")
    }
    jtrend <- .jarray(as.logical(trend), contents.class = "Z")

    jarrdic_indic <- .jnew("jdplus/benchmarking/base/r/util/DictionaryGroups")
    for (i in seq_along(indicators)){
        if(!is.list(indicators[[i]])) indicators[[i]] <- list(x = indicators[[i]])

        for(j in seq_along(indicators[[i]])){
            indic <- indicators[[i]][[j]]

            if (stats::is.ts(indic)) {
               .jcall(jarrdic_indic, "V", "add",
                      names(indicators)[i],
                      rjd3toolkit::.r2jd_tsdata(indic))
            } else if (is.null(indic)) {
               .jcall(jarrdic_indic, "V", "add",
                      names(indicators)[i],
                      .jnull("jdplus/toolkit/base/api/timeseries/TsData"))
            }
        }
    }

    if (!is.null(ccseries)) {
        if(!is.list(ccseries)) stop("'ccseries' must be a list.")
        jdic_ccseries <- .jnew("jdplus/toolkit/base/r/util/Dictionary")
        for (i in seq_along(ccseries)) {
            .jcall(jdic_ccseries, "V", "add",
                   names(ccseries)[i],
                   rjd3toolkit::.r2jd_tsdata(ccseries[[i]]))
        }
    } else {
        jdic_ccseries <- .jnull("jdplus/toolkit/base/r/util/Dictionary")
    }

    if (is.null(ccdefinition)) {
        jccdef <- .jnull("[Ljava/lang/String;")
    } else if (is.character(ccdefinition)) {
        jccdef <- .jarray(as.character(ccdefinition), contents.class = "java/lang/String")
    } else {
        stop("'ccdefinition' must be NULL or a character vector.")
    }

    nrhos <- length(rhos)
    if (nrhos == 1) {
        rhos <- rep(rhos, n)
    } else if (nrhos != n) {
        stop("Size of 'rhos' must be 1 or match number of series.")
    }
    jrhos <- .jarray(as.numeric(rhos), contents.class = "D")

    # fix constant if rho = 1 (diffuse initialization)
    constant[rhos == 1] <- FALSE
    jcst <- .jarray(as.logical(constant), contents.class = "Z")

    jvar_mat <- rjd3toolkit::.r2jd_matrix(var.matrix)
    jrslt <- .jcall(obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
                    returnSig = "Ljdplus/benchmarking/base/api/multivariate/MultivariateChowLinResults;",
                    method = "multiChowLin",
                    jdic_series,
                    jcst,
                    jtrend,
                    jarrdic_indic,
                    jdic_ccseries,
                    jccdef,
                    as.integer(freq),
                    jrhos,
                    var,
                    jvar_mat)

    .jd2r_lhmap <- function(result, method, key, key.class = c("String"), value.class = c("TsData", "Matrix", "DoubleSeq", "List<String>")) {
        key.class <- match.arg(key.class)
        value.class <- match.arg(value.class)

        jmap <- .jcall(result, "Ljava/util/Map;", method)

        jkey <- .jnew("java/lang/String", key)
        jobject <- .jcall(jmap, "Ljava/lang/Object;", "get", .jcast(jkey, "java/lang/Object"))

        if(is.null(jobject)) return(NULL)

        if (value.class == "TsData") {
            out <- rjd3toolkit::.jd2r_tsdata(.jcast(jobject, "jdplus/toolkit/base/api/timeseries/TsData"))
        } else if (value.class == "Matrix") {
            out <- rjd3toolkit::.jd2r_matrix(jobject)
        } else if (value.class == "DoubleSeq") {
            out <- .jcall(jobject, "[D", "toArray")
        } else if (value.class == "List<String>") {
            jarr <- .jcall(jobject, "[Ljava/lang/Object;", "toArray")
            out <- sapply(jarr, .jcall, "S", "toString")
        }
        return(out)
    }

    disagg <- edisagg <- regeffect <- reg <- regnames <- list()
    model <- vector("list", length = n) |> setNames(snames)

    for (i in seq_along(series)) {
        sname <- snames[i]
        disagg[[sname]] <- .jd2r_lhmap(jrslt,
                                       "getDisaggregatedSeries",
                                       sname,
                                       value.class = "TsData")
        edisagg[[sname]] <- .jd2r_lhmap(jrslt,
                                        "getStdevDisaggregatedSeries",
                                        sname,
                                        value.class = "TsData")
        regeffect[[sname]] <- .jd2r_lhmap(jrslt,
                                          "getRegressionEffects",
                                          sname,
                                          value.class = "TsData")
        reg[[sname]] <- .jd2r_lhmap(jrslt,
                                    "getRegressors",
                                    sname,
                                    value.class = "Matrix")
        coef <- .jd2r_lhmap(jrslt,
                            "getCoefficients",
                            sname,
                            value.class = "DoubleSeq")

        coef_var <- .jd2r_lhmap(jrslt,
                                "getCoefficientsVariance",
                                sname,
                                value.class = "DoubleSeq")

        reg_names <- .jd2r_lhmap(jrslt,
                                 "getRegressorsNames",
                                 sname,
                                 value.class = "List<String>")

        if(!is.null(coef)) {
            se <- sqrt(coef_var)
            t <- coef / se
            model[[sname]] <- data.frame(coef, se, t, row.names = reg_names)
        }
    }

    regression <- list(
        type = ifelse(rhos == 1, "Rw", "Ar1"),
        conversion = "Sum",
        model = model
    )

    estimation <- list(
        disagg = disagg,
        edisagg = edisagg,
        regeffect = regeffect,
        smoothingpart =
            rjd3toolkit::.jd3_object(jrslt,"MTD", TRUE) |>
            rjd3toolkit::result("smoothingpart"),
        parameters = rhos,
        # residuals -> TODO
        vcov = rjd3toolkit::.proc_matrix(jrslt, "innovationsvarcov")
    )

    output <- list(
        regression = regression,
        estimation = estimation
    )
    class(output) <- "JD3_MULTITEMPDISAGG_RSLTS"

    return(output)
}
