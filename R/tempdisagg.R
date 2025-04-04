#' @include utils.R
NULL

#' Temporal disaggregation of a time series by regression models.
#'
#' Perform temporal disaggregation of low frequency to high frequency time
#' series by regression models. Models included are Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms.
#'
#' @param series The time series that will be disaggregated. It must be a ts
#'   object.
#' @param constant Constant term (T/F). Only used with Ar1 model when
#'   zeroinitialization=F
#' @param trend Linear trend (T/F)
#' @param indicators High-frequency indicator(s) used in the temporal
#'   disaggregation. It must be a (list of) ts object(s).
#' @param model Model of the error term (at the disaggregated level). "Ar1" =
#'   Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman
#' @param freq Annual frequency of the disaggregated variable. Used if no
#'   indicator is provided.
#' @param nextrapolation Number of extrapolation periods. Only used when no
#'   indicator is provided.
#' @param conversion Conversion mode (Usually "Sum" or "Average")
#' @param conversion.obsposition Only used with "UserDefined" mode. Position of
#'   the observed indicator in the aggregated periods (for instance 7th month of
#'   the year)
#' @param rho Only used with Ar1/RwAr1 models. (Initial) value of the parameter
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for Rho evaluation (in [rho.truncated, 1[)
#' @param zeroinitialization The initial values of an auto-regressive model are
#'   fixed to 0 (T/F, F by default)
#' @param diffuse.algorithm Algorithm used for diffuse initialization.
#'   "SqrtDiffuse" by default
#' @param diffuse.regressors Indicates if the coefficients of the regression
#'   model are diffuse (T) or fixed unknown (F, default)
#'
#' @return An object of class "JD3TempDisagg"
#' @export
#'
#' @examples
#' # retail data, chow-lin with monthly indicator
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregation(Y, indicators=x)
#' y<-td$estimation$disagg
#'
#' # qna data, fernandez with/without quarterly indicator
#' data("qna_data")
#' Y<-ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency=1, start=c(2009,1))
#' x<-ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency=4, start=c(2009,1))
#' td1<-rjd3bench::temporaldisaggregation(Y, indicators=x, model = "Rw")
#' td2<-rjd3bench::temporaldisaggregation(Y, model = "Rw", nextrapolation = 6)
#' y2<-td2$estimation$disagg
#'
temporaldisaggregation<-function(series, constant = TRUE,  trend = FALSE,  indicators=NULL,
                                 model=c("Ar1", "Rw", "RwAr1"), freq=4, nextrapolation = 0,
                                 conversion=c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition=1,
                                 rho=0, rho.fixed = FALSE,  rho.truncated=0,
                                 zeroinitialization = FALSE,  diffuse.algorithm=c("SqrtDiffuse", "Diffuse", "Augmented"), diffuse.regressors=FALSE){
    model <- match.arg(model)
    conversion <- match.arg(conversion)
    diffuse.algorithm <- match.arg(diffuse.algorithm)
    if (model!="Ar1" && !zeroinitialization){
        constant <- FALSE
    }
    jseries<-rjd3toolkit::.r2jd_tsdata(series)
    jlist<-list()
    if (!is.null(indicators)){
        if (is.list(indicators)){
            for (i in seq_along(indicators)){
                jlist[[i]]<-rjd3toolkit::.r2jd_tsdata(indicators[[i]])
            }
        } else if (is.ts(indicators)){
            jlist[[1]]<-rjd3toolkit::.r2jd_tsdata(indicators)
        } else{
            stop("Invalid indicators")
        }
        jindicators<-.jarray(jlist, contents.class = "jdplus/toolkit/base/api/timeseries/TsData")
    } else{
        jindicators<-.jnull("[Ljdplus/toolkit/base/api/timeseries/TsData;")
    }
    jrslt<-.jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationResults;",
                  "process", jseries, constant, trend, jindicators, model, as.integer(freq), as.integer(nextrapolation), conversion, as.integer(conversion.obsposition), rho, rho.fixed, rho.truncated,
                  zeroinitialization, diffuse.algorithm, diffuse.regressors)

    # Build the S3 result
    bcov<-rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars<-rjd3toolkit::.proc_vector(jrslt, "regnames")
    coef<-rjd3toolkit::.proc_vector(jrslt, "coeff")
    se<-sqrt(diag(bcov))
    t<-coef/se
    m<-data.frame(coef, se, t)
    m<-`row.names<-`(m, vars)

    regression<-list(
        type=model,
        conversion=conversion,
        model=m,
        cov=bcov
    )

    disagg <- rjd3toolkit::.proc_ts(jrslt, "disagg")
    estimation<-list(
        disagg=disagg,
        edisagg=rjd3toolkit::.proc_ts(jrslt, "edisagg"),
        regeffect=rjd3toolkit::.proc_ts(jrslt, "regeffect"),
        smoothingpart=rjd3toolkit::.proc_numeric(jrslt, "smoothingpart"),
        parameter=rjd3toolkit::.proc_numeric(jrslt, "parameter"),
        eparameter=rjd3toolkit::.proc_numeric(jrslt, "eparameter"),
        residuals= .proc_residuals(jrslt, frequency(disagg)) # temporary solution (see function below)
    )
    likelihood<-rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    return(structure(list(
        regression=regression,
        estimation=estimation,
        likelihood=likelihood),
        class="JD3TempDisagg"))
}


#' Temporal disaggregation of a time series by regression models for atypical
#' frequencies.
#'
#' Perform temporal disaggregation of low frequency to high frequency time
#' series by regression models. Models included are Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms.This "raw" function extends
#' the temporaldisaggregation() function so that it can deal with any
#' disaggregation ratio.
#'
#' @param series The time series that will be disaggregated. it must be either
#'   an object of class ts or a numeric vector.
#' @param constant Constant term (T/F). Only used with Ar1 model when
#'   zeroinitialization=F
#' @param trend Linear trend (T/F)
#' @param indicators High-frequency indicator(s) used in the temporal
#'   disaggregation. It must be either a (list of) ts object(s) or a matrix.
#' @param model Model of the error term (at the disaggregated level). "Ar1" =
#'   Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman
#' @param disagratio Disaggregation ratio. Must be a positive integer. Used when
#'   no indicator is provided or when either or both the series and the
#'   indicator(s) are not a (list of) ts object(s).
#' @param nextrapolation Number of extrapolation periods. Only used when no
#'   indicator is provided.
#' @param conversion Conversion mode (Usually "Sum" or "Average")
#' @param conversion.obsposition Only used with "UserDefined" mode. Position of
#'   the observed indicator in the aggregated periods (for instance 7th month of
#'   the year)
#' @param rho Only used with Ar1/RwAr1 models. (Initial) value of the parameter
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for Rho evaluation (in [rho.truncated, 1[)
#' @param zeroinitialization The initial values of an auto-regressive model are
#'   fixed to 0 (T/F, F by default)
#' @param diffuse.algorithm Algorithm used for diffuse initialization.
#'   "SqrtDiffuse" by default
#' @param diffuse.regressors Indicates if the coefficients of the regression
#'   model are diffuse (T) or fixed unknown (F, default)
#'
#' @return An object of class "JD3TempDisagg"
#' @export
#'
#' @examples
#'
#' # use of chow-lin method to disaggregate a biennial series with an annual indicator
#' Y<-stats::aggregate(rjd3toolkit::retail$RetailSalesTotal, 0.5)
#' x<-stats::aggregate(rjd3toolkit::retail$FoodAndBeverageStores, 1)
#' td<-rjd3bench::temporaldisaggregationRaw(Y, indicators=x)
#' y<-td$estimation$disagg
#'
#' # use of Fernandez method to disaggregate a series considering a disaggregation ratio of 5 (for example, it could be a quinquennial series to disaggregate on an annual basis)
#' Y2<-c(500,510,525,520)
#' td2<-rjd3bench::temporaldisaggregationRaw(Y2, model = "Rw", disagratio=5, nextrapolation = 2)
#'
temporaldisaggregationRaw<-function(series, constant = TRUE,  trend = FALSE,  indicators=NULL,
                                 model=c("Ar1", "Rw", "RwAr1"), disagratio=4, nextrapolation = 0,
                                 conversion=c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition=1,
                                 rho=0, rho.fixed = FALSE, rho.truncated=0,
                                 zeroinitialization = FALSE, diffuse.algorithm=c("SqrtDiffuse", "Diffuse", "Augmented"), diffuse.regressors=FALSE){
    model <- match.arg(model)
    conversion <- match.arg(conversion)
    diffuse.algorithm <- match.arg(diffuse.algorithm)
    if (model!="Ar1" && !zeroinitialization){
        constant <- FALSE
    }
    if (!is.null(indicators)){
        if (is.list(indicators)){
            jindicators<-rjd3toolkit::.r2jd_matrix(matrix(unlist(indicators), ncol=length(indicators)))
        } else if (is.ts(indicators) || is.numeric(indicators)){
            jindicators<-rjd3toolkit::.r2jd_matrix(as.matrix(indicators))
        } else{
            stop("Invalid indicators")
        }
    } else{
        jindicators<-.jnull("jdplus/toolkit/base/api/math/matrices/Matrix")
    }
    disagratio <- ifelse(is.ts(series) && is.ts(indicators), frequency(indicators)/frequency(series), disagratio)
    jrslt<-.jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/RawTemporalDisaggregationResults;",
                  "processRaw", as.numeric(series), constant, trend, jindicators, model, as.integer(disagratio), as.integer(nextrapolation), conversion, as.integer(conversion.obsposition), rho, rho.fixed, rho.truncated,
                  zeroinitialization, diffuse.algorithm, diffuse.regressors)

    # Build the S3 result
    bcov<-rjd3toolkit::.proc_matrix(jrslt, "covar")
    vars<-c()
    if(constant) vars <- "C"
    if(trend) vars <- c(vars, "Trend")
    if (!is.null(indicators)){
        if (is.list(indicators)){
            for (i in 1:length(indicators)) {
                vars <- c(vars, paste0("var", i))
            }
        }
        else vars <- c(vars, "var1")
    }
    coef<-rjd3toolkit::.proc_vector(jrslt, "coeff")
    se<-sqrt(diag(bcov))
    t<-coef/se
    m<-data.frame(coef, se, t)
    m<-`row.names<-`(m, vars)

    regression<-list(
        type=model,
        conversion=conversion,
        model=m,
        cov=bcov
    )

    estimation<-list(
        disagg=.proc_vector_ts(jrslt, "disagg", series, indicators, disagratio),
        edisagg=.proc_vector_ts(jrslt, "edisagg", series, indicators, disagratio),
        regeffect=.proc_vector_ts(jrslt, "regeffect", series, indicators, disagratio),
        smoothingpart=ifelse(!is.null(vars), rjd3toolkit::.proc_numeric(jrslt, "smoothingpart"), NaN),
        parameter=rjd3toolkit::.proc_numeric(jrslt, "parameter"),
        eparameter=rjd3toolkit::.proc_numeric(jrslt, "eparameter"),
        residuals= .proc_residuals(jrslt, disagratio) # temporary solution (see function below)
    )
    likelihood<-rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

    return(structure(list(
        regression=regression,
        estimation=estimation,
        likelihood=likelihood),
        class="JD3TempDisagg"))
}



#' Temporal disaggregation using the model: x(t) = a + b y(t), where x(t) is the indicator,
#' y(t) is the unknown target series, with low-frequency constraints on y.
#'
#' @param series The time series that will be disaggregated. It must be a ts object.
#' @param indicator High-frequency indicator used in the temporal disaggregation. It must be a ts object.
#' @param conversion Conversion mode (Usually "Sum" or "Average")
#' @param conversion.obsposition Only used with "UserDefined" mode. Position of the observed indicator in the aggregated periods (for instance 7th month of the year)
#' @param rho Only used with Ar1/RwAr1 models. (Initial) value of the parameter
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for Rho evaluation (in [rho.truncated, 1[)
#' @return An object of class "JD3TempDisaggI"
#' @export
#'
#' @examples
#' # retail data, monthly indicator
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregationI(Y, indicator=x)
#' y<-td$estimation$disagg
#'
#' # qna data, quarterly indicator
#' data("qna_data")
#' Y<-ts(qna_data$B1G_Y_data[,"B1G_CE"], frequency=1, start=c(2009,1))
#' x<-ts(qna_data$TURN_Q_data[,"TURN_INDEX_CE"], frequency=4, start=c(2009,1))
#' td<-rjd3bench::temporaldisaggregationI(Y, indicator=x)
#' a<-td$regression$a
#' b<-td$regression$b
#'
temporaldisaggregationI<-function(series, indicator,
                         conversion=c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition=1,
                         rho=0, rho.fixed = FALSE,  rho.truncated=0){
  # model=match.arg(model)
  conversion <- match.arg(conversion)
  jseries <- rjd3toolkit::.r2jd_tsdata(series)
  jlist<-list()
  jindicator<-rjd3toolkit::.r2jd_tsdata(indicator)
  jrslt<-.jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationIResults;",
                "processI", jseries, jindicator, "Ar1", conversion, as.integer(conversion.obsposition), rho, rho.fixed, rho.truncated)
  # Build the S3 result
  a<-rjd3toolkit::.proc_numeric(jrslt, "a")
  b<-rjd3toolkit::.proc_numeric(jrslt, "b")

  regression<-list(
    conversion=conversion,
    a=a,
    b=b
  )
  estimation<-list(
    disagg=rjd3toolkit::.proc_ts(jrslt, "disagg"),
    parameter=rjd3toolkit::.proc_numeric(jrslt, "parameter")
  )
  likelihood<-rjd3toolkit::.proc_likelihood(jrslt, "likelihood.")

  return(structure(list(
    regression=regression,
    estimation=estimation,
    likelihood=likelihood),
    class="JD3TempDisaggI"))
}

#' Print function for object of class JD3TempDisagg
#'
#' @param x an object of class JD3TempDisagg
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregation(Y, indicator=x)
#' print(td)
#'
print.JD3TempDisagg<-function(x, ...){
  if (is.null(x$regression$model)){
    cat("Invalid estimation")
  } else{
    cat("Model:", x$regression$type, "\n")
    print(x$regression$model)

    cat("\n")
    cat("Use summary() for more details. \nUse plot() to see the decomposition of the disaggregated series.")
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
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregationI(Y, indicator=x)
#' print(td)
#'
print.JD3TempDisaggI<-function(x, ...){
  if (is.null(x$estimation$parameter)){
    cat("Invalid estimation")
  } else{
    model<-data.frame(coef = c(round(x$regression$a, 4), round(x$regression$b, 4)))
    row.names(model)<-c("a", "b")
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
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregation(Y, indicator=x)
#' summary(td)
#'
summary.JD3TempDisagg<-function(object, ...){
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
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::adl_disaggregation(Y, indicator=x)
#' summary(td)
#'
summary.JD3AdlDisagg<-function(object, ...){
  summary_disagg(object)
}


summary_disagg<-function(object){
    if (is.null(object)){
      cat("Invalid estimation")

    } else{
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
      p<-object$estimation$parameter
      if (! is.nan(p)){
        cat("Rho :", p, " (", object$estimation$eparameter, ")\n")
        cat("\n")
        cat("\n")
      }
      cat("Regression model", "\n")
      print(object$regression$model)

    }
}

#' Summary function for object of class JD3TempDisaggI
#'
#' @param object an object of class JD3TempDisaggI
#' @param \dots further arguments passed to or from other methods.
#'
#' @export
#'
#' @examples
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregationI(Y, indicator=x)
#' summary(td)
#'
summary.JD3TempDisaggI<-function(object, ...){
  if (is.null(object)){
    cat("Invalid estimation")

  } else{
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
    model<-data.frame(coef = c(round(object$regression$a, 4), round(object$regression$b, 4)))
    row.names(model)<-c("a", "b")
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
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregation(Y, indicator=x)
#' plot(td)
#'
plot.JD3TempDisagg<-function(x, ...){
  if (is.null(x)){
    cat("Invalid estimation")

  } else{
    td_series <- x$estimation$disagg
    reg_effect <- x$estimation$regeffect
    smoothing_effect <- td_series - reg_effect

    ts.plot(td_series, reg_effect, smoothing_effect, gpars=list(col=c("orange", "green", "blue"), xlab = "", xaxt="n", las=2, ...))
    axis(side=1, at=start(td_series)[1]:end(td_series)[1])
    legend("topleft", c("disaggragated series", "regression effect", "smoothing effect"), lty = c(1, 1, 1), col=c("orange", "green", "blue"), bty="n", cex=0.8)
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
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregationI(Y, indicator=x)
#' plot(td)
#'
plot.JD3TempDisaggI<-function(x, ...){
  if (is.null(x)){
    cat("Invalid estimation")

  } else{
    td_series <- x$estimation$disagg
    ts.plot(td_series, gpars=list(xlab="", ylab="disaggragated series", xaxt="n"))
    axis(side=1, at=start(td_series)[1]:end(td_series)[1])
  }
}

# TEMPORARY SOLUTION
# For the next release, we should use proto and move the functions to rjd3toolkit
.proc_residuals <- function (jrslt, f){

    z<-rjd3toolkit::.jd3_object(jrslt, "TD", TRUE)

    full_residuals <- get_result_item(z,"residuals.fullresiduals")

    extr_normality <- list(get_result_item(z,"residuals.mean"),
                           get_result_item(z,"residuals.skewness"),
                           get_result_item(z,"residuals.kurtosis"),
                           get_result_item(z,"residuals.doornikhansen"))
    extr_independence <- get_result_item(z,"residuals.ljungbox")
    extr_randomness <- list(get_result_item(z,"residuals.nruns"),
                            get_result_item(z,"residuals.lruns"),
                            get_result_item(z,"residuals.nudruns"),
                            get_result_item(z,"residuals.ludruns"))

    nk <- ifelse(get_result_item(z,"likelihood.nobs") > 2*f, 2*f, f)
    linearity_test <- tryCatch(rjd3toolkit::ljungbox(full_residuals^2, k = nk, lag = 1, mean = TRUE), error=function(err) NaN)


    normality <- matrix(unlist(extr_normality), nrow = 4, ncol = 2, byrow = TRUE,
                        dimnames = list(c("mean", "skewness", "kurtosis", "normality(doornikhansen)"), c("value", "p-value")))
    independence <- matrix(unlist(extr_independence), nrow = 1, ncol = 2, byrow = TRUE,
                           dimnames = list(c("ljung_box"), c("value", "p-value")))
    randomness <- matrix(unlist(extr_randomness), nrow = 4, ncol = 2, byrow = TRUE,
                         dimnames = list(c("Runs around the mean: number", "Runs around the mean: length", "Up and Down runs: number", "Up and Down runs: length"), c("value", "p-value")))
    linearity <- matrix(unlist(linearity_test), nrow = 1, ncol = 2, byrow = TRUE,
                        dimnames = list(c("ljung_box on squared residuals"), c("value", "p-value")))

    return(list(full_residuals=full_residuals,
                tests=list(normality=round(normality,4),
                           independence=round(independence,4),
                           randomness=round(randomness,4),
                           linearity=round(linearity,4))))

}

get_result_item <- function(jd3_obj, item){
    rslt_item <- tryCatch(rjd3toolkit::result(jd3_obj, item),
                          error = function(err) list(value = NaN, pvalue = NaN))
    if(is.null(rslt_item)){
        rslt_item <- list(value = NA, pvalue = NA)
    }
    return(rslt_item)
}

.proc_vector_ts <- function(jrslt, name, series, indicators, disagratio){

    rslt <- rjd3toolkit::.proc_vector(jrslt, name)

    if(length(rslt) == 0){
        rslt <- NULL
    }else{
        if(!is.null(indicators)){
            if(is.ts(indicators)){
                rslt <- ts(rslt, start = start(indicators), frequency = frequency(indicators))
            }else if(is.list(indicators)){
                if(is.ts(indicators[[1]])){
                    rslt <- ts(rslt, start = start(indicators[[1]]), frequency = frequency(indicators[[1]]))
                }
            }
        }else{
            if(is.ts(series)){
                rslt <- ts(rslt, start = start(series), frequency = frequency(series) * disagratio)
            }
        }
    }
    return(rslt)
}
