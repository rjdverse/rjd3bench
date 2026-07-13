#' @include utils.R
#' @importFrom stats is.ts
NULL

#' @title Temporal Disaggregation of a Time Series by ADL Model
#'
#' @description
#' Perform temporal disaggregation of low-frequency to high-frequency time
#' series using an Autoregressive Distributed Lag regression model.
#'
#' @param series A low-frequency time series to be disaggregated. It must be `"ts"` object.
#' @param constant Boolean. Indicates whether a constant term is included in the model. The default is `TRUE`.
#' @param trend Boolean. Indicates whether a linear trend is included in the model. The default is `FALSE`.
#' @param indicators One or more high-frequency indicator series. If not NULL (the default), this must be a `"ts"` object or a list of `"ts"` objects.
#' @param average Boolean. Indicates whether an average conversion should be considered. The default is `FALSE`, corresponding to additive conversion.
#' @param phi A numeric value giving the (initial) value of the phi parameter
#' @param phi.fixed Boolean. Specifies whether the supplied value of `phi` is fixed. The default is `FALSE`, which indicates that `phi` is estimated.
#' @param phi.truncated A numeric value defining the lower bound of the admissible range for `phi`.
#' The evaluation range is `[phi.truncated, 1[`.
#' @param xar A character string specifying the constraints imposed on the coefficients of the lagged regression variables. The default is `"FREE"`, which indicates that no constraints are applied. Other options are: `"SAME"`and `"NONE"`.
#' For additional information, see the package vignette.
#' @param diffuse Boolean. Indicates whether the coefficients of the regression model are treated as diffuse (`TRUE`) or as fixed unknown (`FALSE`, the default).
#'
#' @return An object of class "JD3_ADLDISAGG_RSLTS" is returned. The following are returned
#' invisibly as a list:
#' * `regression` `[[1]]` regression coefficients;
#' * `estimation` `[[2]]` disaggregated Time-Series and standard deviation, parameter and residuals;
#' * `likelihood` `[[3]]` likelihood statistics.
#'
#' @references  Proietti, P. (2005). Temporal Disaggregation by State Space Methods: Dynamic Regression Methods Revisited. Working papers and Studies, European Commission, ISSN 1725-4825.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3jars::check_java_version(silent = TRUE)
#' # ADL model
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#' x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
#' td1 <- adl_disaggregation(Y, indicators = x, xar = "FREE")
#' td1$estimation$disagg
#'
#' # ADL models with constraints
#' td2 <- adl_disaggregation(Y, indicators = x, xar = "SAME") # ~ Chow-Lin
#' td3 <- adl_disaggregation(Y, constant = FALSE, indicators = x,
#'                           xar = "SAME", phi = 1, phi.fixed = TRUE) # ~ Fernandez
#' td4 <- adl_disaggregation(Y, indicators = x, xar = "NONE") # ~ Santos Silva-Cardoso
#'
adl_disaggregation <- function(series,
                               constant = TRUE,
                               trend = FALSE,
                               indicators = NULL,
                               average = FALSE,
                               phi = 0.0,
                               phi.fixed = FALSE,
                               phi.truncated = 0.0,
                               xar = c("FREE", "SAME", "NONE"),
                               diffuse = FALSE) {

    xar <- match.arg(xar)
    conversion <- ifelse(average, "Average", "Sum")

    jseries <- rjd3toolkit::.r2jd_tsdata(series)
    jlist <- list()

    if (!is.null(indicators)) {
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
    } else {
        jindicators <- .jnull("[Ljdplus/toolkit/base/api/timeseries/TsData;")
    }

    jrslt <- .jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/ADLResults;",
                    "processADL", jseries, constant, trend, jindicators, conversion,
                    phi, phi.fixed, phi.truncated, xar, "TRANSITION", diffuse)

    # Build the S3 result
    bcov <- rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars <- rjd3toolkit::.proc_vector(jrslt, "regnames")
    coef <- rjd3toolkit::.proc_vector(jrslt, "coeff")
    se <- sqrt(diag(bcov))
    t <- coef / se
    m <- data.frame(coef, se, t)
    row.names(m) <- vars

    regression <- list(
        type = xar,
        conversion = conversion,
        model = m,
        cov = bcov
    )
    estimation <- list(
        disagg = rjd3toolkit::.proc_ts(jrslt, "disagg"),
        edisagg = rjd3toolkit::.proc_ts(jrslt, "edisagg"),
        parameter = rjd3toolkit::.proc_numeric(jrslt, "parameter"),
        eparameter = rjd3toolkit::.proc_numeric(jrslt, "eparameter"),
        residuals = .proc_residualsADL(jrslt, diffuse)
    )
    likelihood <- .proc_likelihoodADL(jrslt, diffuse)

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3_ADLDISAGG_RSLTS"
    return(output)
}

