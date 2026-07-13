#' @include utils.R
NULL

#' @title Temporal Disaggregation and Interpolation of a Time Series using the Model-Based Denton Proportional Method
#'
#' @description
#' The Denton proportional first difference (PFD) method can be expressed as a
#' statistical model in a state-space representation. This formulation provides
#' increased flexibility, including the ability to incorporate outliers, which
#' correspond to level shifts in the Benchmark‑to‑Indicator (BI) ratio, that
#' would otherwise induce unintended wave effects under the standard Denton PFD
#' method. In addition, the approach allows the disaggregated series to be
#' constrained (or 'frozen') at specific periods or prior to a given date by
#' fixing the corresponding high‑frequency BI ratios.
#'
#' @param series A low-frequency time series to be disaggregated or interpolated. It must be either a `"ts"` object or a numeric vector.
#' @param indicator A high-frequency indicator series. It must be of the same class as `series`.
#' @param differencing Not yet implemented. This should be left equal to `1` (corresponding to the Denton PFD method).
#' @param conversion A character string specifying the conversion mode, typically `"Sum"` (the default) or `"Average"`. Other options are: `"Last"`, `"First"` and `"UserDefined"`.
#' @param conversion.obsposition An integer specifying the position of the low-frequency observations within the interpolated series (e.g. the 7th month of the year).
#' This argument is used only for interpolation when `conversion = "UserDefined"`.
#' @param outliers A list specifying the outlier periods and their magnitude.
#'   Each element must be provided as `"YYYY-MM-DD" = value`, where the date
#'   identifies the period. The numeric value specifies the intensity of the
#'   outlier and corresponds to the relative value of the innovation variance
#'   (with `1` indicating the normal situation).
#' @param fixedBIratios A list specifying the periods for which the
#'   Benchmark‑to‑Indicator (BI) ratios should be fixed. Each element must be
#'   provided as `"YYYY-MM-DD" = value`, where the date identifies the period
#'   and the numeric value specifies the fixed BI ratio.
#'
#' @return An object of class "JD3_MBDENTON_RSLTS" is returned. The following are returned invisibly as a list:
#' * `estimation` `[[1]]` disaggregated Time-Series, BI ratios and standard deviations;
#' * `likelihood` `[[2]]` likelihood statistics.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3jars::check_java_version(silent = TRUE)
#' # Retail data, monthly indicator
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::aggregate(rjd3toolkit::Retail$FoodAndBeverageStores, 4)
#' td <- denton_modelbased(Y, x, outliers = list("2000-01-01" = 100, "2005-07-01" = 100))
#' y <- td$estimation$edisagg
#'
#' # qna data, quarterly indicator
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#' x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
#'
#' td1 <- denton_modelbased(Y, x)
#' td2 <- denton_modelbased(Y, x, outliers = list("2020-04-01" = 100),
#'                          fixedBIratios = list("2021-04-01" = 39.0))
#' bi1 <- td1$estimation$biratio
#' bi2 <- td2$estimation$biratio
#' y1 <- td1$estimation$disagg
#' y2 <- td2$estimation$disagg
#'
#' stats::ts.plot(bi2, bi1, main = "BI ratios",
#'                gpars = list(col = c("red", "black")))
#' graphics::legend("topright", lty = 1, col = c("black", "red"),
#'                  legend = c("td1", "td2"))
#' stats::ts.plot(y2, y1, main = "Disaggregated series",
#'                gpars = list(col = c("red", "black")))
#' graphics::legend("topleft", lty = 1, col = c("black", "red"),
#'                  legend = c("td1", "td2"))
#'
denton_modelbased <- function(
        series,
        indicator,
        differencing = 1L,
        conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
        conversion.obsposition = 1L,
        outliers = NULL,
        fixedBIratios = NULL) {

    conversion <- match.arg(conversion)

    jseries <- rjd3toolkit::.r2jd_tsdata(series)
    jindicator <- rjd3toolkit::.r2jd_tsdata(indicator)
    if (is.null(outliers)) {
        odates <- .jcast(.jnull(), "[Ljava/lang/String;")
        ovars <- .jnull("[D")
    } else {
        odates <- .jarray(names(outliers))
        ovars <- .jarray(as.numeric(outliers))
    }
    if (is.null(fixedBIratios)) {
        fdates <- .jcast(.jnull(), "[Ljava/lang/String;")
        fvars <- .jnull("[D")
    } else {
        fdates <- .jarray(names(fixedBIratios))
        fvars <- .jarray(as.numeric(fixedBIratios))
    }
    jrslt <- .jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/ModelBasedDentonResults;",
                    "processModelBasedDenton", jseries, jindicator, 1L, conversion, as.integer(conversion.obsposition), odates, ovars,
                    fdates, fvars)
    # Build the S3 result
    estimation <- list(
        disagg = rjd3toolkit::.proc_ts(jrslt, "disagg"),
        edisagg = rjd3toolkit::.proc_ts(jrslt, "edisagg"),
        biratio = rjd3toolkit::.proc_ts(jrslt, "biratio"),
        ebiratio = rjd3toolkit::.proc_ts(jrslt, "ebiratio")
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    output <- list(
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3_MBDENTON_RSLTS"

    return(output)
}



