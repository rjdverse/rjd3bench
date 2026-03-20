#' @include utils.R
NULL

#' @export
print.JD3_TEMPDISAGG_RSLTS <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)

        cat("\n")
        cat("Use summary() for more details. \nUse plot() to see the decomposition of the disaggregated series.")
    }
}

#' @export
print.JD3_TEMPDISAGGRAW_RSLTS <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)
    }
}

#' @export
print.JD3_INTERP_RSLTS <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)

        cat("\n")
        cat("Use summary() for more details. \nUse plot() to see the decomposition of the interpolated series.")
    }
}

#' @export
print.JD3_INTERPRAW_RSLTS <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)
    }
}


#' @export
print.JD3_TEMPDISAGGI_RSLTS <- function(x, ...) {
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

#' @export
print.JD3_MBDENTON_RSLTS <- function(x, ...) {
    if (is.null(x$estimation$disagg)) {
        cat("Invalid estimation")
    } else {
        cat("Available output:\n")
        print.default(names(x$estimation), ...)

        cat("\n")
        cat("Use summary() for more details.\n",
            "Use plot() to see the disaggregated series and BI ratio",
            "with their respective confidence interval.")
    }
}

#' @export
print.JD3_ADLDISAGG_RSLTS <- function(x, ...) {
    if (is.null(x$regression$model)) {
        cat("Invalid estimation")
    } else {
        cat("Model:", x$regression$type, "\n")
        print(x$regression$model)

        cat("\n")
        cat("Use summary() for more details. \nUse plot() to see the decomposition of the disaggregated series.")
    }
    return(invisible(x))
}

#' @export
summary.JD3_TEMPDISAGG_RSLTS <- function(object, ...) {
    summary_disagg(object)
}

#' @export
summary.JD3_TEMPDISAGGRAW_RSLTS <- function(object, ...) {
    summary_disagg(object)
}

#' @export
summary.JD3_INTERP_RSLTS <- function(object, ...) {
    summary_disagg(object)
}

#' @export
summary.JD3_INTERPRAW_RSLTS <- function(object, ...) {
    summary_disagg(object)
}

#' @export
summary.JD3_MBDENTON_RSLTS <- function(object, ...) {
    if (is.null(object)) {
        cat("Invalid estimation")

    } else {
        cat("\n")
        cat("Likelihood statistics", "\n")
        cat("\n")
        cat("Number of observations: ", object$likelihood$nobs, "\n")
        #cat("Number of effective observations: ", object$likelihood$neffective, "\n")
        cat("Number of estimated parameters: ", object$likelihood$nparams, "\n")
        cat("Standard error: ", "\n")
        cat("AIC: ", object$likelihood$aic, "\n")
        cat("BIC: ", object$likelihood$bic, "\n")

        cat("\n")
        cat("\n")
        cat("Available output:\n")
        print.default(names(object$estimation))
    }
}


#' @export
summary.JD3_ADLDISAGG_RSLTS <- function(object, ...) {
    summary_disagg(object)
}

#' @export
summary.JD3_TEMPDISAGGI_RSLTS <- function(object, ...) {
    if (is.null(object)) {
        cat("Invalid estimation")

    } else {
        cat("\n")
        cat("Likelihood statistics", "\n")
        cat("\n")
        cat("Number of observations: ", object$likelihood$nobs, "\n")
        #cat("Number of effective observations: ", object$likelihood$neffective, "\n")
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

#' @export
#' @importFrom stats ts ts.plot start end
#' @importFrom graphics axis legend
plot.JD3_TEMPDISAGG_RSLTS <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        td_series <- x$estimation$disagg
        reg_effect <- x$estimation$regeffect

        if(is.null(reg_effect)){
            reg_effect <- stats::ts(rep(0, length(td_series)), start =  stats::start(td_series), frequency = stats::frequency(td_series))
            smoothing_effect <- td_series
        }else{
            smoothing_effect <- td_series - reg_effect
        }

        stats::ts.plot(
            td_series, reg_effect, smoothing_effect,
            gpars = list(
                main = "Decomposition",
                col = c("orange", "green", "blue"),
                xlab = "",
                xaxt = "n",
                las = 2L,
                ...
            )
        )
        graphics::axis(side = 1L, at = stats::start(td_series)[1L]:stats::end(td_series)[1L])
        graphics::legend("topleft",
                         c("disaggragated series", "regression effect", "smoothing effect"),
                         lty = 1L,
                         col = c("orange", "green", "blue"),
                         bty = "n",
                         cex = 0.8)
    }
}

#' @export
#' @importFrom stats ts ts.plot start end
#' @importFrom graphics axis legend
plot.JD3_INTERP_RSLTS <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        ti_series <- x$estimation$interp
        reg_effect <- x$estimation$regeffect

        if(is.null(reg_effect)){
            reg_effect <- stats::ts(rep(0, length(ti_series)), start =  stats::start(ti_series), frequency = stats::frequency(ti_series))
            smoothing_effect <- ti_series
        }else{
            smoothing_effect <- ti_series - reg_effect
        }

        stats::ts.plot(
            ti_series, reg_effect, smoothing_effect,
            gpars = list(
                main = "Decomposition",
                col = c("orange", "green", "blue"),
                xlab = "",
                xaxt = "n",
                las = 2L,
                ...
            )
        )
        graphics::axis(side = 1L, at = stats::start(ti_series)[1L]:stats::end(ti_series)[1L])
        graphics::legend("topleft",
                         c("interpolated series", "regression effect", "smoothing effect"),
                         lty = 1L,
                         col = c("orange", "green", "blue"),
                         bty = "n",
                         cex = 0.8)
    }
}


#' @export
#' @importFrom stats ts.plot
#' @importFrom graphics par
plot.JD3_MBDENTON_RSLTS <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")
    } else {
        oldpar <- graphics::par(no.readonly = TRUE)
        on.exit(graphics::par(oldpar))

        td <- x$estimation$disagg
        td.sd <- x$estimation$edisagg
        td.lb <- td - 1.96 * td.sd
        td.ub <- td + 1.96 * td.sd

        bi <- x$estimation$biratio
        bi.sd <- x$estimation$ebiratio
        bi.lb <- bi - 1.96 * bi.sd
        bi.ub <- bi + 1.96 * bi.sd

        graphics::par(mfrow = c(2L, 1L))

        stats::ts.plot(
            td, td.lb, td.ub,
            gpars = list(
                main = "Disaggragated series and BI ratio",
                xlab = "",
                ylab = "disaggragated series",
                lty = c(1L, 3L, 3L),
                ...
            )
        )
        stats::ts.plot(
            bi, bi.lb, bi.ub,
            gpars = list(
                xlab = "",
                ylab = "BI ratio",
                lty = c(1L, 3L, 3L),
                ...
            )
        )
    }
}

#' @export
#' @importFrom stats ts.plot start end
#' @importFrom graphics axis legend
plot.JD3_ADLDISAGG_RSLTS <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        td_series <- x$estimation$disagg

        stats::ts.plot(td_series, gpars = list(col = "orange", xlab = "", xaxt = "n", las = 2L, ...))
        graphics::axis(side = 1L, at = stats::start(td_series)[1L]:stats::end(td_series)[1L])
        graphics::legend("topleft", "disaggragated series", lty = 1L, col = "orange", bty = "n", cex = 0.8)
    }
    return(invisible(x))
}

#' @export
#' @importFrom stats ts.plot start end
#' @importFrom graphics axis
plot.JD3_TEMPDISAGGI_RSLTS <- function(x, ...) {
    if (is.null(x)) {
        cat("Invalid estimation")

    } else {
        td_series <- x$estimation$disagg
        stats::ts.plot(td_series, gpars = list(xlab = "", ylab = "disaggragated series", xaxt = "n"))
        graphics::axis(side = 1L, at = stats::start(td_series)[1L]:stats::end(td_series)[1L])
    }
}
