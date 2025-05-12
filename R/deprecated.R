#' Deprecated functions
#'
#' @description
#' This function is deprecated. You should start using the functions
#' temporal_disaggregation() or temporal_interpolation() instead.
#'
#' @param series,constant,trend,indicators,model,freq,conversion,conversion.obsposition,rho,rho.fixed,rho.truncated,zeroinitialization,diffuse.algorithm,diffuse.regressors Parameters.
#' @name deprecated-rjd3bench
#' @export
#'
temporaldisaggregation <- function(
        series,
        constant = TRUE,
        trend = FALSE,
        indicators = NULL,
        model = c("Ar1", "Rw", "RwAr1"),
        freq = 4L,
        conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
        conversion.obsposition = 1L,
        rho = 0.0,
        rho.fixed = FALSE,
        rho.truncated = 0.0,
        zeroinitialization = FALSE,
        diffuse.algorithm = c("SqrtDiffuse", "Diffuse", "Augmented"),
        diffuse.regressors = FALSE) {

    .Deprecated(new = NULL,
                msg = "temporaldisaggregation() is deprecated. Use temporal_disaggregation() or temporal_interpolation() instead.")

    model <- match.arg(model)
    conversion <- match.arg(conversion)
    diffuse.algorithm <- match.arg(diffuse.algorithm)
    if (model != "Ar1" && !zeroinitialization) {
        constant <- FALSE
    }
    jseries <- rjd3toolkit::.r2jd_tsdata(series)
    jlist <- list()
    if (!is.null(indicators)) {
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
        n_ext <- 0L
    } else {
        jindicators <- .jnull("[Ljdplus/toolkit/base/api/timeseries/TsData;")
        n_ext <- 2 * freq
    }
    jrslt <- .jcall(
        obj = "jdplus/benchmarking/base/r/TemporalDisaggregation",
        returnSig = "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationResults;",
        method = "process",
        jseries, constant, trend, jindicators, model, as.integer(freq), as.integer(n_ext),
        conversion, as.integer(conversion.obsposition), rho, rho.fixed, rho.truncated,
        zeroinitialization, diffuse.algorithm, diffuse.regressors
    )

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
        conversion = conversion,
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
