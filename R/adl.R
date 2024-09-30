#' Temporal disaggregation of a time series with ADL models
#'
#' @param series
#' @param constant
#' @param trend
#' @param indicators
#' @param conversion
#' @param conversion.obsposition
#' @param phi
#' @param phi.fixed
#' @param phi.truncated
#' @param xar
#'
#' @return
#' @export
#'
#' @examples
#' # qna data, fernandez with/without quarterly indicator
#' data("qna_data")
#' Y <- ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency = 1, start = c(2009,1))
#' x <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency = 4, start = c(2009,1))
#' td1 <- rjd3bench::adl_disaggregation(Y, indicators = x, xar = "FREE")
#' td2 <- rjd3bench::adl_disaggregation(Y, indicators = x, xar = "SAME")
adl_disaggregation <- function(series, constant = TRUE, trend = FALSE, indicators = NULL,
                               conversion = c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition = 1L,
                               phi = 0L, phi.fixed = FALSE, phi.truncated = 0L, xar = c("FREE", "SAME", "NONE")) {
    conversion <- match.arg(conversion)
    xar <- match.arg(xar)
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
                    phi, phi.fixed, phi.truncated, xar)

    # Build the S3 result
    bcov <- rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars <- rjd3toolkit::.proc_vector(jrslt, "regnames")
    coef <- rjd3toolkit::.proc_vector(jrslt, "coeff")
    se <- sqrt(diag(bcov))
    t <- coef / se
    m <- data.frame(coef, se, t)
    m <- `row.names <- `(m, vars)

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
        eparameter = rjd3toolkit::.proc_numeric(jrslt, "eparameter")
        # res = TODO
    )
    likelihood <- rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

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
#'
#' @return
#' @export
#'
#' @examples
#' Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)
#' x <- rjd3toolkit::Retail$FoodAndBeverageStores
#' td <- rjd3bench::adl_disaggregation(Y, indicator = x, xar = "FREE")
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
#' td <- rjd3bench::adl_disaggregation(Y, indicator = x, xar = "FREE")
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
