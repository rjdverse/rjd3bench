#' @importFrom rJava .jpackage .jcall .jnull .jarray .jevalArray .jcast .jcastToArray .jinstanceof is.jnull .jnew .jclass
#' @import RProtoBuf
NULL

#' @title Quarterly National Accounts data for temporal disaggregation
#'
#' @description
#' This dataset contains two data frames used for temporal disaggregation and
#' benchmarking exercises. The first data frame, `B1G_Y_data`, includes three
#' annual benchmark series corresponding to Belgian annual value added for the
#' period 2009–2020 in three industries: chemical industry (CE), construction
#' (FF), and transport services (HH). The second data frame, `TURN_Q_data`,
#' contains the corresponding quarterly indicator series derived from VAT-based
#' production indicators, covering the period 2009Q1–2021Q4.
#'
#' @format A named list with two elements:
#' \describe{
#'   \item{`B1G_Y_data`}{A data frame with columns:
#'     \describe{
#'       \item{`DATE`}{Annual periods.}
#'       \item{`B1G_CE`}{Value added for chemical industry.}
#'       \item{`B1G_FF`}{Value added for construction.}
#'       \item{`B1G_HH`}{Value added for transport services.}
#'     }
#'   }
#'   \item{`TURN_Q_data`}{A data frame with columns:
#'     \describe{
#'       \item{`DATE`}{Quarterly periods.}
#'       \item{`TURN_INDEX_CE`}{Quarterly indicator for chemical industry.}
#'       \item{`TURN_INDEX_FF`}{Quarterly indicator for construction.}
#'       \item{`TURN_INDEX_HH`}{Quarterly indicator for transport services.}
#'     }
#'   }
#' }
#'
#' @source Belgian Quarterly National Accounts
#'
#' @examples
#' data(qna_data)
#' names(qna_data)
#' head(qna_data$B1G_Y_data)
#' head(qna_data$TURN_Q_data)
"qna_data"

get_result_item <- function(jd3_obj, item) {
    rslt_item <- tryCatch(rjd3toolkit::result(jd3_obj, item),
                          error = function(err) list(value = NaN, pvalue = NaN))
    if (is.null(rslt_item)) {
        rslt_item <- list(value = NA, pvalue = NA)
    }
    return(rslt_item)
}

get_ll_item_adl <- function(jobj, return_sig, method) {
    rslt_item <- tryCatch(.jcall(jobj, return_sig, method),
                          error = function(err) NA)
    if (is.null(rslt_item)) {
        rslt_item <- NA
    }
    return(rslt_item)
}

### alternatively, we could use proto and move the functions to `rjd3toolkit`
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

.proc_residualsADL <- function (jrslt, diffuse = FALSE){
    z <- rjd3toolkit::.jd3_object(jrslt, "ADL", TRUE)

    return_sig <- if(diffuse) {
        "Ljdplus/benchmarking/base/core/benchmarking/extractors/MarginalLikelihoodStatistics;"
    } else {
        "Ljdplus/benchmarking/base/core/benchmarking/extractors/ProfileLikelihoodStatistics;"
    }
    method <- if(diffuse) "getMarginalLikelihood" else "getProfileLikelihood"

    jll <- tryCatch(.jcall(z$internal, return_sig, method), error = function(e) NULL)

    return(tryCatch(.jcall(jll, "Ljdplus/toolkit/base/api/data/DoubleSeq;", "getResiduals") |>
                        .jcall("[D", "toArray", simplify = TRUE),
                    error = function(e) NULL))
}

.proc_likelihoodADL <- function (jrslt, diffuse = FALSE){
    z <- rjd3toolkit::.jd3_object(jrslt, "ADL", TRUE)

    return_sig <- if(diffuse) {
        "Ljdplus/benchmarking/base/core/benchmarking/extractors/MarginalLikelihoodStatistics;"
    } else {
        "Ljdplus/benchmarking/base/core/benchmarking/extractors/ProfileLikelihoodStatistics;"
    }
    method <- if(diffuse) "getMarginalLikelihood" else "getProfileLikelihood"

    jll <- tryCatch(.jcall(z$internal, return_sig, method),
                    error = function(e) NULL)

    nparams <- get_ll_item_adl(jll, "I", "getEstimatedParametersCount")
    nobs <- get_ll_item_adl(jll, "I", "getObservationsCount")
    ndiffuse <- get_ll_item_adl(jll, "I", "getDiffuseCount")

    return(list(ll = get_ll_item_adl(jll, "D", "getLogLikelihood"),
                llc = get_ll_item_adl(jll, "D", "getAdjustedLogLikelihood"),
                ssq = get_ll_item_adl(jll, "D", "getSsqErr"),
                nparams = nparams,
                nobs = nobs,
                ndiffuse = ndiffuse,
                df = nobs - nparams - ndiffuse,
                aic = get_ll_item_adl(jll, "D", "aic"),
                aicc = get_ll_item_adl(jll, "D", "aicc"),
                bic = get_ll_item_adl(jll, "D", "bic"),
                hannanquinn = get_ll_item_adl(jll, "D", "hannanQuinn")))
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
