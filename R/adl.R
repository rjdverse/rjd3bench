#' Temporal disaggregation of a time series with ADL models
#'
#' @param series The low frequency time series that will be disaggregated. It must be a ts object.
#' @param constant Constant term (T/F, T by default)
#' @param trend Linear trend (T/F, F by default)
#' @param indicators High-frequency indicator(s). It must be a (list of) ts object(s).
#' @param average Average conversion (T/F). Default is F, which means additive conversion.
#' @param phi (Initial) value of the phi parameter
#' @param phi.fixed Fixed phi (T/F, F by default)
#' @param phi.truncated Range for phi evaluation (in [phi.truncated, 1[)
#' @param xar Constraints on the coefficients of the lagged regression variables. See vignette for more information on this.
#' @param diffuse Indicates if the coefficients of the regression model are diffuse (T) or fixed unknown (F, default)
#'
#' @return An object of class "JD3AdlDisagg"
#'
#' @references  Proietti, P. (2005). Temporal Disaggregation by State Space
#'   Methods: Dynamic Regression Methods Revisited. Working papers and Studies,
#'   European Commission, ISSN 1725-4825.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' \code{\link[utils]{browseVignettes}} \code{browseVignettes(package = "rjd3bench")}
#'
#' @examples
#' # adl model
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#' x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
#' td1 <- adl_disaggregation(Y, indicators = x, xar = "FREE")
#' td1$estimation$disagg
#'
#' # adl models with constraints
#' td2 <- adl_disaggregation(Y, indicators = x, xar = "SAME") # ~ Chow-Lin
#' td3 <- adl_disaggregation(Y, constant = FALSE, indicators = x, xar = "SAME", phi = 1, phi.fixed = TRUE) # ~ Fernandez
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
        } else if (is.ts(indicators)) {
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
        residuals = .proc_residualsADL(jrslt, diffuse) # (tests yet to add)
    )
    likelihood <- .proc_likelihoodADL(jrslt, diffuse)

    output <- list(
        regression = regression,
        estimation = estimation,
        likelihood = likelihood
    )
    class(output) <- "JD3AdlDisagg"
    return(output)
}

#' Print function for object of class JD3AdlDisagg
#'
#' @param x an object of class JD3AdlDisagg
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- adl_disaggregation(Y, indicators = x, xar = "FREE")
#' print(td)
#'
print.JD3AdlDisagg <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)

        cat("\n")
        cat("Use summary() for more details. \nUse plot() to see the decomposition of the disaggregated series.")
    }
}

#' Plot function for object of class JD3AdlDisagg
#'
#' @param x an object of class JD3AdlDisagg
#' @param \dots further arguments to pass to ts.plot.
#'
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- adl_disaggregation(Y, indicators = x, xar = "FREE")
#' plot(td)
#'
plot.JD3AdlDisagg <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        td_series <- x$estimation$disagg

        ts.plot(td_series, gpars = list(col = "orange", xlab = "", xaxt = "n", las = 2L, ...))
        axis(side = 1L, at = start(td_series)[1L]:end(td_series)[1L])
        legend("topleft", "disaggragated series", lty = 1L, col = "orange", bty = "n", cex = 0.8)
    }
}

# TEMPORARY SOLUTIONS

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

get_ll_item_adl <- function(jobj, return_sig, method) {
    rslt_item <- tryCatch(.jcall(jobj, return_sig, method),
                          error = function(err) NA)
    if (is.null(rslt_item)) {
        rslt_item <- NA
    }
    return(rslt_item)
}
