#' @include utils.R
NULL

#' @title Temporal disaggregation of a time series by regression models.
#'
#' @description
#' Perform temporal disaggregation of low frequency to high frequency time
#' series by regression models. Models included are Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms.
#'
#' @param series The low frequency time series that will be disaggregated. It must be a ts object.
#' @param constant Constant term (T/F). Only used with "Ar1" model when zeroinitialization = F.
#' @param trend Linear trend (T/F, F by default)
#' @param indicators High-frequency indicator(s) used in the temporal disaggregation.
#' It must be a (list of) ts object(s).
#' @param model Model of the error term (at the disaggregated level).
#' "Ar1" = Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman.
#' @param freq Integer. Annual frequency of the disaggregated series.
#' Ignored when an indicator is provided.
#' @param average Average conversion (T/F). Default is F, which means additive conversion.
#' @param rho (Initial) value of the parameter. Only used with Ar1/RwAr1 models.
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for rho evaluation (in [rho.truncated, 1[)
#' @param zeroinitialization The initial values of an auto-regressive model are
#'   fixed to 0 (T/F, F by default)
#' @param diffuse.algorithm Algorithm used for diffuse initialization.
#'   "SqrtDiffuse" by default.
#' @param diffuse.regressors Indicates if the coefficients of the regression
#'   model are diffuse (T) or fixed unknown (F, default)
#' @param nbcsts Number of backcast periods. Ignored when an indicator is provided.
#' @param nfcsts Number of forecast periods. Ignored when an indicator is provided.
#'
#' @return An object of class "JD3TempDisagg"
#' @export
#'
#' @seealso \code{\link{temporal_interpolation}} for interpolation,
#'
#' \code{\link{temporal_disaggregation_raw}} for temporal disaggregation of atypical frequency series,
#'
#' \code{\link{temporal_interpolation_raw}} for interpolation of atypical frequency series
#'
#'
#' For more information, see the vignette:
#'
#' \code{\link[utils]{browseVignettes}} \code{browseVignettes(package = "rjd3bench")}
#'
#' @examples
#' # chow-lin with monthly indicator
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporal_disaggregation(Y, indicators = x)
#' td$estimation$disagg
#'
#' # fernandez with/without quarterly indicator
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#' x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
#' td1 <- temporal_disaggregation(Y, indicators = x, model = "Rw")
#' td1$estimation$disagg
#'
#' td2 <- temporal_disaggregation(Y, model = "Rw", nfcsts = 6)
#' td2$estimation$disagg
#'
#' # chow-lin on index series
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
        } else if (is.ts(indicators)) {
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
        residuals = .proc_residuals(jrslt, stats::frequency(disagg)) # temporary solution (see function below)
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3TempDisagg"
    return(output)
}


#' @title Temporal disaggregation of an atypical frequency series by regression models.
#'
#' @description
#' Perform temporal disaggregation of low frequency to high frequency time
#' series by regression models. Models included are Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms. This "raw" function extends
#' the temporal_disaggregation() function in a way that it can deal with any
#' frequency ratio.
#'
#' @param series The low frequency series that will be disaggregated. Must be a numeric vector.
#' @param constant Constant term (T/F). Only used with "Ar1" model when zeroinitialization = F.
#' @param trend Linear trend (T/F)
#' @param indicators High-frequency indicator(s) used in the temporal disaggregation.
#' If not NULL, it must be either a numeric vector or a matrix.
#' @param startoffset Number of initial observations in the indicator(s) series that are prior to
#' the start of the period covered by the low-frequency series.
#' Must be 0 or a positive integer. 0 by default. Ignored when no indicator is provided.
#' @param model Model of the error term (at the disaggregated level).
#' "Ar1" = Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman.
#' @param freqratio Frequency ratio between the disaggregated series and the low frequency series.
#' Mandatory. Must be a positive integer.
#' @param average Average conversion (T/F). Default is F, which means additive conversion.
#' @param rho (Initial) value of the parameter. Only used with Ar1/RwAr1 models.
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for Rho evaluation (in [rho.truncated, 1[)
#' @param zeroinitialization The initial values of an auto-regressive model are
#'   fixed to 0 (T/F, F by default)
#' @param diffuse.algorithm Algorithm used for diffuse initialization.
#'   "SqrtDiffuse" by default
#' @param diffuse.regressors Indicates if the coefficients of the regression
#'   model are diffuse (T) or fixed unknown (F, default)
#' @param nbcsts Number of backcast periods. Ignored when an indicator is provided.
#' @param nfcsts Number of forecast periods. Ignored when an indicator is provided.
#'
#' @return An object of class "JD3TempDisaggRaw"
#' @export
#'
#' @seealso \code{\link{temporal_interpolation_raw}}
#'
#' For more information, see the vignette:
#'
#' \code{\link[utils]{browseVignettes}} \code{browseVignettes(package = "rjd3bench")}
#'
#' @examples
#' # use of chow-lin method to disaggregate a biennial series with an annual indicator
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' td$estimation$disagg
#'
#' # use of Fernandez method to disaggregate a series without indicator considering a frequency ratio of 5 (for example, it could be a quinquennial series to disaggregate on an annual basis)
#' Y2 <- c(500,510,525,520)
#' td2 <- temporal_disaggregation_raw(Y2, model = "Rw", freqratio = 5, nfcsts = 2)
#' td2$estimation$disagg
#'
#' # same with an indicator, considering an offset in the latter
#' Y2 <- c(500,510,525,520)
#' x2 <- c(97,
#'         98, 98.5, 99.5, 104, 99,
#'         100, 100.5, 101, 105.5, 103,
#'         104.5, 103.5, 104.5, 109, 104,
#'         107, 103, 108, 113, 110)
#' td3 <- temporal_disaggregation_raw(Y2, indicators = x2, startoffset = 1, model = "Rw", freqratio = 5)
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
    row.names(m) <- vars

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
        residuals = .proc_residuals(jrslt, freqratio) # temporary solution (see function below)
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3TempDisaggRaw"
    return(output)
}


#' @title Interpolation of a time series by regression models.
#'
#' @description
#' Perform temporal interpolation of low frequency to high frequency time
#' series by regression models. Models included are Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms.
#'
#' @param series The low frequency time series that will be interpolated. It must be a ts object.
#' @param constant Constant term (T/F). Only used with "Ar1" model when zeroinitialization = F.
#' @param trend Linear trend (T/F, F by default)
#' @param indicators High-frequency indicator(s) used in the interpolation.
#' It must be a (list of) ts object(s).
#' @param model Model of the error term (at the higher-frequency level).
#' "Ar1" = Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman.
#' @param freq Integer. Annual frequency of the interpolated series.
#' Ignored when an indicator is provided.
#' @param obsposition Integer. Position of the observations of the low frequency
#'   series in the interpolated series. (e.g. 1st month of the year, 2d month of
#'   the year, etc.). It must be a positive integer or -1 (the default). The
#'   default value is equivalent to setting the value of the parameter equal to
#'   the frequency of the series, meaning that the last value of the
#'   interpolated series is consistent with the low frequency series.
#' @param rho (Initial) value of the parameter. Only used with Ar1/RwAr1 models.
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for rho evaluation (in [rho.truncated, 1[)
#' @param zeroinitialization The initial values of an auto-regressive model are
#'   fixed to 0 (T/F, F by default)
#' @param diffuse.algorithm Algorithm used for diffuse initialization.
#'   "SqrtDiffuse" by default.
#' @param diffuse.regressors Indicates if the coefficients of the regression
#'   model are diffuse (T) or fixed unknown (F, default)
#' @param nbcsts Number of backcast periods. Ignored when an indicator is provided.
#' @param nfcsts Number of forecast periods. Ignored when an indicator is provided.
#'
#' @return An object of class "JD3Interpolation"
#' @export
#'
#' @seealso \code{\link{temporal_disaggregation}},
#'
#' \code{\link{temporal_interpolation_raw}} for interpolation of atypical frequency series,
#'
#' \code{\link{temporal_disaggregation_raw}} for temporal disaggregation of atypical frequency series
#'
#'
#' For more information, see the vignette:
#'
#' \code{\link[utils]{browseVignettes}} \code{browseVignettes(package = "rjd3bench")}
#'
#' @examples
#' # chow-lin/fernandez when the last value of the interpolated series is
#' # consistent with the low frequency series.
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' ti1 <- temporal_interpolation(Y, indicators = x)
#' ti1$estimation$interp
#'
#' ti2 <- temporal_interpolation(Y, indicators = x, model = "Rw")
#' ti2$estimation$interp
#'
#' # same without indicator
#' ti3 <- temporal_interpolation(Y, model = "Rw", freq = 12, nfcsts = 6)
#' ti3$estimation$interp
#'
#  # chow-lin when the first value of the interpolated series is the one
#' # consistent with the low frequency series.
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
        } else if (is.ts(indicators)) {
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
        residuals = .proc_residuals(jrslt, f) # temporary solution (see function below)
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3Interpolation"
    return(output)
}


#' @title Interpolation of an atypical frequency series by regression models.
#'
#' @description
#' Perform temporal interpolation of low frequency to high frequency time
#' series by regression models. Models included are Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms. This "raw" function extends
#' the temporal_interpolation() function in a way that it can deal with any
#' frequency ratio.
#'
#' @param series The low frequency series that will be interpolated. Must be a numeric vector.
#' @param constant Constant term (T/F). Only used with "Ar1" model when zeroinitialization = F.
#' @param trend Linear trend (T/F, F by default)
#' @param indicators High-frequency indicator(s) used in the interpolation.
#' If not NULL, it must be either a numeric vector or a matrix.
#' @param startoffset Number of initial observations in the indicator(s) series
#'   that are prior to the first observation of the low-frequency series.
#' Must be 0 or a positive integer. 0 by default. Ignored when no indicator is provided.
#' @param model Model of the error term (at the higher-frequency level).
#' "Ar1" = Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman.
#' @param freqratio Frequency ratio between the interpolated series and the low frequency series.
#' Mandatory. Must be a positive integer.
#' @param obsposition Integer. Position of the observations of the low frequency
#'   series in the interpolated series. (e.g. 1st month of the year, 2d month of
#'   the year, etc.). It must be a positive integer or -1 (the default). The
#'   default value is equivalent to setting the value of the parameter equal to
#'   the frequency of the series, meaning that the last value of the
#'   interpolated series is consistent with the low frequency series.
#' @param rho (Initial) value of the parameter. Only used with Ar1/RwAr1 models.
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for Rho evaluation (in [rho.truncated, 1[)
#' @param zeroinitialization The initial values of an auto-regressive model are
#'   fixed to 0 (T/F, F by default)
#' @param diffuse.algorithm Algorithm used for diffuse initialization.
#'   "SqrtDiffuse" by default
#' @param diffuse.regressors Indicates if the coefficients of the regression
#'   model are diffuse (T) or fixed unknown (F, default)
#' @param nbcsts Number of backcast periods. Ignored when an indicator is provided.
#' @param nfcsts Number of forecast periods. Ignored when an indicator is provided.
#'
#' @return An object of class "JD3InterpolationRaw"
#' @export
#' @seealso \code{\link{temporal_disaggregation_raw}}
#'
#' For more information, see the vignette:
#'
#' \code{\link[utils]{browseVignettes}} \code{browseVignettes(package = "rjd3bench")}
#'
#' @examples
#'
#' # use of chow-lin method to interpolate a biennial series with an annual indicator
#' # (low frequency series consistent with the last value of the interpolated series)
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' ti$estimation$interp
#'
#' # use of Fernandez method to interpolate a series without indicator considering a frequency ratio of 5 (for example, it could be a quinquennial series to interpolate annually)
#' # (low frequency series consistent with the last value of the interpolated series)
#' Y2 <- c(500,510,525,520)
#' ti2 <- temporal_interpolation_raw(Y2, model = "Rw", freqratio = 5, nbcsts = 1, nfcsts = 2)
#' ti2$estimation$interp
#'
#' # same with an indicator, considering an offset in the latter
#' Y2 <- c(500,510,525,520)
#' x2 <- c(485,
#'         490, 492.5, 497.5, 520, 495,
#'         500, 502.5, 505, 527.5, 515,
#'         522.5, 517.5, 522.5, 545, 520,
#'         535, 515, 540, 565, 550)
#' ti3 <- temporal_interpolation_raw(Y2, indicators = x2, startoffset = 1, model = "Rw", freqratio = 5)
#' ti3$estimation$interp
#'
#' # same considering that the first value of the interpolated series is the one consistent with the low frequency series
#' ti4 <- temporal_interpolation_raw(Y2, indicators = x2, startoffset = 1, model = "Rw", freqratio = 5, obsposition = 1)
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
    row.names(m) <- vars

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
        residuals = .proc_residuals(jrslt, freqratio) # temporary solution (see function below)
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3InterpolationRaw"
    return(output)
}


#' @title Temporal disaggregation of a time series by means of a reverse regression model.
#'
#' @description
#' Perform temporal disaggregation and interpolation of low frequency to high
#' frequency time series by means of a reverse regression model. Unlike the
#' usual regression-based models, this approach treats a high-frequency
#' indicator as the dependent variable and the unknown target series as the
#' independent variable.
#'
#' @param series The time series that will be disaggregated. It must be a ts object.
#' @param indicator The high-frequency indicator. It must be a ts object.
#' @param conversion Conversion mode (Usually "Sum" or "Average")
#' @param conversion.obsposition Integer. Only used with "UserDefined" mode.
#' Position of the observed indicator in the aggregated periods (for instance
#' 7th month of the year)
#' @param rho (Initial) value of the parameter.
#' @param rho.fixed Fixed rho (T/F, F by default).
#' @param rho.truncated Range for Rho evaluation (in [rho.truncated, 1[)
#' @return An object of class "JD3TempDisaggI"
#'
#' @references  Bournay J., Laroque G. (1979). Reflexions sur la methode
#'   d'elaboration des comptes trimestriels. Annales de l'Insee, n°36, pp.3-30.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' \code{\link[utils]{browseVignettes}} \code{browseVignettes(package = "rjd3bench")}
#'
#' @examples
#' # Retail data, monthly indicator
#'
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
    class(output) <- "JD3TempDisaggI"
    return(output)
}

#' Print function for object of class JD3TempDisagg
#'
#' @param x an object of class JD3TempDisagg
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporaldisaggregation(Y, indicators = x)
#' print(td)
#'
print.JD3TempDisagg <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)

        cat("\n")
        cat("Use summary() for more details. \nUse plot() to see the decomposition of the disaggregated series.")
    }
}

#' Print function for object of class JD3TempDisaggRaw
#'
#' @param x an object of class JD3TempDisaggRaw
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' print(td)
#'
print.JD3TempDisaggRaw <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)
    }
}


#' Print function for object of class JD3Interpolation
#'
#' @param x an object of class JD3Interpolation
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' ti <- temporal_interpolation(Y, indicators = x)
#' print(ti)
#'
print.JD3Interpolation <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)

        cat("\n")
        cat("Use summary() for more details. \nUse plot() to see the decomposition of the interpolated series.")
    }
}

#' Print function for object of class JD3InterpolationRaw
#'
#' @param x an object of class JD3InterpolationRaw
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' print(ti)
#'
print.JD3InterpolationRaw <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)
    }
}


#' Print function for object of class JD3TempDisaggI
#'
#' @param x an object of class JD3TempDisaggI
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporaldisaggregationI(Y, indicator = x)
#' print(td)
#'
print.JD3TempDisaggI <- function(x, ...) {
    if (is.null(x$estimation$parameter)) {
        cat("Invalid estimation")
    } else {
        model <- data.frame(coef = c(round(x$regression$a, 4L), round(x$regression$b, 4L)))
        row.names(model) <- c("a", "b")
        print(model)

        cat("\n")
        cat("Use summary() for more details. \nUse plot() to visualize the disaggregated series.")
    }
}

#' Summary function for object of class JD3TempDisagg
#'
#' @param object an object of class JD3TempDisagg
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporal_disaggregation(Y, indicators = x)
#' summary(td)
#'
summary.JD3TempDisagg <- function(object, ...) {
    summary_disagg(object)
}

#' Summary function for object of class JD3TempDisaggRaw
#'
#' @param object an object of class JD3TempDisaggRaw
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' td <- temporal_disaggregation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' summary(td)
#'
summary.JD3TempDisaggRaw <- function(object, ...) {
    summary_disagg(object)
}

#' Summary function for object of class JD3Interpolation
#'
#' @param object an object of class JD3Interpolation
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' ti <- temporal_interpolation(Y, indicators = x)
#' summary(ti)
#'
summary.JD3Interpolation <- function(object, ...) {
    summary_disagg(object)
}

#' Summary function for object of class JD3InterpolationRaw
#'
#' @param object an object of class JD3InterpolationRaw
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- stats::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 0.5)
#' x <- stats::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 1)
#' ti <- temporal_interpolation_raw(as.numeric(Y), indicators = as.numeric(x), freqratio = 2)
#' summary(ti)
#'
summary.JD3InterpolationRaw <- function(object, ...) {
    summary_disagg(object)
}

#' Summary function for object of class JD3AdlDisagg
#'
#' @param object an object of class JD3AdlDisagg
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- adl_disaggregation(Y, indicators = x)
#' summary(td)
#'
summary.JD3AdlDisagg <- function(object, ...) {
    summary_disagg(object)
}


summary_disagg <- function(object) {
    if (is.null(object)) {
        cat("Invalid estimation")

    } else {
        cat("\n")
        cat("Likelihood statistics", "\n")
        cat("\n")
        cat("Number of observations: ", object$likelihood$nobs, "\n")
        cat("Number of effective observations: ", object$likelihood$neffective, "\n")
        cat("Number of estimated parameters: ", object$likelihood$nparams, "\n")
        cat("LogLikelihood: ", object$likelihood$ll, "\n")
        cat("Standard error: ", "\n")
        cat("AIC: ", object$likelihood$aic, "\n")
        cat("BIC: ", object$likelihood$bic, "\n")

        cat("\n")
        cat("\n")
        cat("Model:", object$regression$type, "\n")
        p <- object$estimation$parameter
        if (! is.nan(p)) {
            cat("Rho :", p, " (", object$estimation$eparameter, ")\n")
            cat("\n")
            cat("\n")
        }
        cat("Regression model", "\n")
        print(object$regression$model)

    }
}

#' @title Summary function for object of class JD3TempDisaggI
#'
#' @param object an object of class JD3TempDisaggI
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporaldisaggregationI(Y, indicator = x)
#' summary(td)
#'
summary.JD3TempDisaggI <- function(object, ...) {
    if (is.null(object)) {
        cat("Invalid estimation")

    } else {
        cat("\n")
        cat("Likelihood statistics", "\n")
        cat("\n")
        cat("Number of observations: ", object$likelihood$nobs, "\n")
        cat("Number of effective observations: ", object$likelihood$neffective, "\n")
        cat("Number of estimated parameters: ", object$likelihood$nparams, "\n")
        cat("LogLikelihood: ", object$likelihood$ll, "\n")
        cat("Standard error: ", "\n")
        cat("AIC: ", object$likelihood$aic, "\n")
        cat("BIC: ", object$likelihood$bic, "\n")

        cat("\n")
        cat("\n")
        cat("Model:", object$regression$type, "\n")
        model <- data.frame(coef = c(round(object$regression$a, 4L), round(object$regression$b, 4L)))
        row.names(model) <- c("a", "b")
        print(model)
    }
}

#' Plot function for object of class JD3TempDisagg
#'
#' @param x an object of class JD3TempDisagg
#' @param \dots further arguments to pass to ts.plot.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporal_disaggregation(Y, indicators = x)
#' plot(td)
#'
plot.JD3TempDisagg <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        td_series <- x$estimation$disagg
        reg_effect <- x$estimation$regeffect

        if(is.null(reg_effect)){
            reg_effect <- ts(rep(0, length(td_series)), start =  stats::start(td_series), frequency = stats::frequency(td_series))
            smoothing_effect <- td_series
        }else{
            smoothing_effect <- td_series - reg_effect
        }

        ts.plot(
            td_series, reg_effect, smoothing_effect,
            gpars = list(
                col = c("orange", "green", "blue"),
                xlab = "",
                xaxt = "n",
                las = 2L,
                ...
            )
        )
        axis(side = 1L, at = start(td_series)[1L]:end(td_series)[1L])
        legend("topleft",
               c("disaggragated series", "regression effect", "smoothing effect"),
               lty = 1L,
               col = c("orange", "green", "blue"),
               bty = "n",
               cex = 0.8)
    }
}

#' Plot function for object of class JD3Interpolation
#'
#' @param x an object of class JD3Interpolation
#' @param \dots further arguments to pass to ts.plot.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' ti <- temporal_interpolation(Y, indicators = x)
#' plot(ti)
#'
plot.JD3Interpolation <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        ti_series <- x$estimation$interp
        reg_effect <- x$estimation$regeffect

        if(is.null(reg_effect)){
            reg_effect <- ts(rep(0, length(ti_series)), start =  stats::start(ti_series), frequency = stats::frequency(ti_series))
            smoothing_effect <- ti_series
        }else{
            smoothing_effect <- ti_series - reg_effect
        }

        ts.plot(
            ti_series, reg_effect, smoothing_effect,
            gpars = list(
                col = c("orange", "green", "blue"),
                xlab = "",
                xaxt = "n",
                las = 2L,
                ...
            )
        )
        axis(side = 1L, at = start(ti_series)[1L]:end(ti_series)[1L])
        legend("topleft",
               c("interpolated series", "regression effect", "smoothing effect"),
               lty = 1L,
               col = c("orange", "green", "blue"),
               bty = "n",
               cex = 0.8)
    }
}


#' Plot function for object of class JD3TempDisaggI
#'
#' @param x an object of class JD3TempDisaggI
#' @param \dots further arguments to pass to ts.plot.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- temporaldisaggregationI(Y, indicator = x)
#' plot(td)
#'
plot.JD3TempDisaggI <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        td_series <- x$estimation$disagg
        ts.plot(td_series, gpars = list(xlab = "", ylab = "disaggragated series", xaxt = "n"))
        axis(side = 1L, at = start(td_series)[1L]:end(td_series)[1L])
    }
}

# TEMPORARY SOLUTION (later, we should use proto and move the functions to rjd3toolkit)
.proc_residuals <- function (jrslt, f){

    z <- rjd3toolkit::.jd3_object(jrslt, "TD", TRUE)

    full_residuals <- get_result_item(z, "residuals.fullresiduals")

    extr_normality <- list(get_result_item(z, "residuals.mean"),
                           get_result_item(z, "residuals.skewness"),
                           get_result_item(z, "residuals.kurtosis"),
                           get_result_item(z, "residuals.doornikhansen"))
    extr_independence <- get_result_item(z, "residuals.ljungbox")
    extr_randomness <- list(get_result_item(z, "residuals.nruns"),
                            get_result_item(z, "residuals.lruns"),
                            get_result_item(z, "residuals.nudruns"),
                            get_result_item(z, "residuals.ludruns"))

    nk <- ifelse(get_result_item(z, "likelihood.nobs") > 2*f+1, 2*f, f)
    linearity_test <- tryCatch(rjd3toolkit::ljungbox(full_residuals^2L, k = nk, lag = 1L, mean = TRUE), error = function(err) NaN)

    normality <- matrix(
        data = unlist(extr_normality),
        nrow = 4L,
        ncol = 2L,
        byrow = TRUE,
        dimnames = list(c("mean", "skewness", "kurtosis",
                          "normality(doornikhansen)"),
                        c("value", "p-value"))
    )
    independence <- matrix(unlist(extr_independence), nrow = 1L, ncol = 2L, byrow = TRUE,
                           dimnames = list("ljung_box", c("value", "p-value")))
    randomness <- matrix(
        data = unlist(extr_randomness),
        nrow = 4L,
        ncol = 2L,
        byrow = TRUE,
        dimnames = list(c("Runs around the mean: number",
                          "Runs around the mean: length",
                          "Up and Down runs: number",
                          "Up and Down runs: length"),
                        c("value", "p-value"))
    )
    linearity <- matrix(
        data = unlist(linearity_test),
        nrow = 1L,
        ncol = 2L,
        byrow = TRUE,
        dimnames = list("ljung_box on squared residuals", c("value", "p-value"))
    )

    return(list(full_residuals = full_residuals,
                tests = list(normality = round(normality, 4L),
                             independence = round(independence, 4L),
                             randomness = round(randomness, 4L),
                             linearity = round(linearity, 4L))))
}

get_result_item <- function(jd3_obj, item) {
    rslt_item <- tryCatch(rjd3toolkit::result(jd3_obj, item),
                          error = function(err) list(value = NaN, pvalue = NaN))
    if (is.null(rslt_item)) {
        rslt_item <- list(value = NA, pvalue = NA)
    }
    return(rslt_item)
}
