#' @include utils.R
NULL

#' Temporal disaggregation of a time series by regression models.
#'
#' Perform temporal disaggregation of low frequency to high frequency time
#' series by regression models. Models included are Chow-Lin, Fernandez,
#' Litterman and some variants of those algorithms.
#'
#' @param series The time series that will be disaggregated. It must be a ts object.
#' @param constant Constant term (T/F). Only used with Ar1 model when zeroinitialization=F
#' @param trend Linear trend (T/F)
#' @param indicators High-frequency indicator(s) used in the temporal disaggregation. It must be a (list of) ts object(s).
#' @param model Model of the error term (at the disaggregated level). "Ar1" = Chow-Lin, "Rw" = Fernandez, "RwAr1" = Litterman
#' @param freq Annual frequency of the disaggregated variable. Used if no indicator is provided
#' @param conversion Conversion mode (Usually "Sum" or "Average")
#' @param conversion.obsposition Only used with "UserDefined" mode. Position of the observed indicator in the aggregated periods (for instance 7th month of the year)
#' @param rho Only used with Ar1/RwAr1 models. (Initial) value of the parameter
#' @param rho.fixed Fixed rho (T/F, F by default)
#' @param rho.truncated Range for Rho evaluation (in [rho.truncated, 1[)
#' @param zeroinitialization The initial values of an auto-regressive model are fixed to 0 (T/F, F by default)
#' @param diffuse.algorithm Algorithm used for diffuse initialization. "SqrtDiffuse" by default
#' @param diffuse.regressors Indicates if the coefficients of the regression model are diffuse (T) or fixed unknown (F, default)
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
#' td2<-rjd3bench::temporaldisaggregation(Y, model = "Rw")
#' mod1<- td1$regression$model
#'
temporaldisaggregation<-function(series, constant=T, trend=F, indicators=NULL,
                         model=c("Ar1", "Rw", "RwAr1"), freq=4,
                         conversion=c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition=1,
                         rho=0, rho.fixed=F, rho.truncated=0,
                         zeroinitialization=F, diffuse.algorithm=c("SqrtDiffuse", "Diffuse", "Augmented"), diffuse.regressors=F){
  model=match.arg(model)
  conversion=match.arg(conversion)
  diffuse.algorithm=match.arg(diffuse.algorithm)
  if (model!="Ar1" && !zeroinitialization){
    constant=F
  }
  jseries<-rjd3toolkit::.r2jd_ts(series)
  jlist<-list()
  if (!is.null(indicators)){
    if (is.list(indicators)){
      for (i in 1:length(indicators)){
        jlist[[i]]<-rjd3toolkit::.r2jd_ts(indicators[[i]])
      }
    }else if (is.ts(indicators)){
      jlist[[1]]<-rjd3toolkit::.r2jd_ts(indicators)
    }else{
      stop("Invalid indicators")
    }
    jindicators<-.jarray(jlist, contents.class = "jdplus/toolkit/base/api/timeseries/TsData")
  }else{
    jindicators<-.jnull("[Ljdplus/toolkit/base/api/timeseries/TsData;")
  }
  jrslt<-.jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationResults;",
                "process", jseries, constant, trend, jindicators, model, as.integer(freq), conversion, as.integer(conversion.obsposition),rho, rho.fixed, rho.truncated,
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
  estimation<-list(
    disagg=rjd3toolkit::.proc_ts(jrslt, "disagg"),
    edisagg=rjd3toolkit::.proc_ts(jrslt, "edisagg"),
    regeffect=rjd3toolkit::.proc_ts(jrslt, "regeffect"),
    smoothingpart=rjd3toolkit::.proc_numeric(jrslt, "smoothingpart"),
    parameter=rjd3toolkit::.proc_numeric(jrslt, "parameter"),
    eparameter=rjd3toolkit::.proc_numeric(jrslt, "eparameter")
    # res= TODO
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
                         rho=0, rho.fixed=F, rho.truncated=0){
  # model=match.arg(model)
  conversion=match.arg(conversion)
  jseries=rjd3toolkit::.r2jd_ts(series)
  jlist<-list()
  jindicator<-rjd3toolkit::.r2jd_ts(indicator)
  jrslt<-.jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/TemporalDisaggregationIResults;",
                "processI", jseries, jindicator, "Ar1", conversion, as.integer(conversion.obsposition),rho, rho.fixed, rho.truncated)
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
#'
#' @return
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
  }else{
    cat("Model:", x$regression$type, "\n")
    print(x$regression$model)

    cat("\n")
    cat("Use summary() for more details. \nUse plot() to see the decomposition of the disaggregated series.")
  }
}

#' Print function for object of class JD3TempDisaggI
#'
#' @param x an object of class JD3TempDisaggI
#'
#' @return
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
  }else{
    model<-data.frame(coef = c(round(x$regression$a,4),round(x$regression$b,4)))
    row.names(model)<-c("a","b")
    print(model)

    cat("\n")
    cat("Use summary() for more details. \nUse plot() to visualize the disaggregated series.")
  }
}

#' Summary function for object of class JD3TempDisagg
#'
#' @param object an object of class JD3TempDisagg
#'
#' @return
#' @export
#'
#' @examples
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::retail$FoodAndBeverageStores
#' td<-rjd3bench::temporaldisaggregation(Y, indicator=x)
#' summary(td)
#'
summary.JD3TempDisagg<-function(object, ...){
  if (is.null(object)){
    cat("Invalid estimation")

  }else{
    cat("\n")
    cat("Likelihood statistics","\n")
    cat("\n")
    cat("Number of observations: ", object$likelihood$nobs, "\n")
    cat("Number of effective observations: ", object$likelihood$neffective, "\n")
    cat("Number of estimated parameters: ", object$likelihood$nparams, "\n")
    cat("Standard error: ", "\n")
    cat("AIC: ", object$likelihood$aic, "\n")
    cat("BIC: ", object$likelihood$bic, "\n")

    cat("\n")
    cat("\n")
    cat("Model:", object$regression$type, "\n")
    p<-object$estimation$parameter
    if (! is.nan(p)){
      cat("Rho :",p," (", object$estimation$eparameter, ")\n")
      cat("\n")
      cat("\n")
    }
    cat("Regression model","\n")
    print(object$regression$model)

  }
}

#' Summary function for object of class JD3TempDisaggI
#'
#' @param object an object of class JD3TempDisaggI
#'
#' @return
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

  }else{
    cat("\n")
    cat("Likelihood statistics","\n")
    cat("\n")
    cat("Number of observations: ", object$likelihood$nobs, "\n")
    cat("Number of effective observations: ", object$likelihood$neffective, "\n")
    cat("Number of estimated parameters: ", object$likelihood$nparams, "\n")
    cat("Standard error: ", "\n")
    cat("AIC: ", object$likelihood$aic, "\n")
    cat("BIC: ", object$likelihood$bic, "\n")

    cat("\n")
    cat("\n")
    cat("Model:", object$regression$type, "\n")
    model<-data.frame(coef = c(round(object$regression$a,4),round(object$regression$b,4)))
    row.names(model)<-c("a","b")
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

  }else{
    td_series <- x$estimation$disagg
    reg_effect <- x$estimation$regeffect
    smoothing_effect <- td_series - reg_effect

    ts.plot(td_series, reg_effect, smoothing_effect, gpars=list(col=c("orange", "green", "blue"), xlab = "", xaxt="n", las=2, ...))
    axis(side=1, at=start(td_series)[1]:end(td_series)[1])
    legend("topleft",c("disaggragated series", "regression effect", "smoothing effect"),lty = c(1,1,1), col=c("orange", "green", "blue"), bty="n", cex=0.8)
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

  }else{
    td_series <- x$estimation$disagg
    ts.plot(td_series, gpars=list(xlab="", ylab="disaggragated series", xaxt="n"))
    axis(side=1, at=start(td_series)[1]:end(td_series)[1])
  }
}
