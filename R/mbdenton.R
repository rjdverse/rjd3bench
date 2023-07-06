#' @include utils.R
NULL

#' Temporal disaggregation of a time series by model-based Denton proportional method
#'
#' Denton proportional method can be expressed as a statistical model in a State
#' space representation (see documentation for the definition of states). This
#' approach is interesting as it allows more flexibility in the model such as
#' the inclusion of outliers (level shift in the Benchmark to Indicator ratio)
#' that could otherwise induce unintended wave effects with standard Denton method.
#' Outliers and their intensity are defined by changing the value of the
#' 'innovation variances'.
#'
#' @param series Aggregation constraint. Mandatory. It must be either an object of class ts or a numeric vector.
#' @param indicator High-frequency indicator. Mandatory. It must be of same class as series
#' @param differencing Not implemented yet. Keep it equals to 1 (Denton PFD method).
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by default.
#' @param conversion.obsposition Position of the observation in the aggregated period (only used with "UserDefined" conversion)
#' @param outliers a list of structured definition of the outlier periods and their intensity. The period must be submitted
#'                 first in the format YYYY-MM-DD and enclosed in quotation marks. This must be followed by an equal sign and
#'                 the intensity of the outlier, defined as the relative value of the 'innovation variances' (1= normal situation)
#' @return an object of class 'JD3MBDenton'
#' @export
#'
#' @examples
#' # retail data, monthly indicator
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::aggregate(rjd3toolkit::retail$FoodAndBeverageStores, 4)
#' td<-rjd3bench::denton_modelbased(Y, x, outliers = list("2000-01-01"=100, "2005-07-01"=100))
#' y<-td$estimation$edisagg
#'
#' # qna data, quarterly indicator
#' data("qna_data")
#' Y<-ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency=1, start=c(2009,1))
#' x<-ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency=4, start=c(2009,1))
#'
#' td1<-rjd3bench::denton_modelbased(Y,x)
#' td2<-rjd3bench::denton_modelbased(Y, x, outliers = list("2020-04-01"=100))
#'
#' bi1<-td1$estimation$biratio
#' bi2<-td2$estimation$biratio
#' y1<-td1$estimation$disagg
#' y2<-td2$estimation$disagg
#' \dontrun{
#' ts.plot(bi1,bi2,gpars=list(col=c("red","blue")))
#' ts.plot(y1,y2,gpars=list(col=c("red","blue")))
#' }
#'
denton_modelbased<-function(series, indicator, differencing=1, conversion=c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition=1,
                            outliers=NULL){

  conversion=match.arg(conversion)

  jseries=rjd3toolkit::.r2jd_ts(series)
  if (is.null(outliers)){
    odates=.jcast(.jnull(), "[Ljava/lang/String;")
    ovars=.jnull("[D")
  }else{
    odates=.jarray(names(outliers))
    ovars=.jarray(as.numeric(outliers))
  }
  jindicator<-rjd3toolkit::.r2jd_ts(indicator)
  jrslt<-.jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/ModelBasedDentonResults;",
                "processModelBasedDenton", jseries, jindicator, as.integer(1), conversion, as.integer(conversion.obsposition), odates, ovars, 
                .jcast(.jnull(), "[Ljava/lang/String;"), .jnull("[D"))
  # Build the S3 result
  estimation<-list(
    disagg=rjd3toolkit::.proc_ts(jrslt, "disagg"),
    edisagg=rjd3toolkit::.proc_ts(jrslt, "edisagg"),
    biratio=rjd3toolkit::.proc_ts(jrslt, "biratio"),
    ebiratio=rjd3toolkit::.proc_ts(jrslt, "ebiratio")
  )
  likelihood<-rjd3toolkit::.proc_likelihood (jrslt, "ll")

  return(structure(list(
    estimation=estimation,
    likelihood=likelihood),
    class="JD3MBDenton"))
}

#' Print function for object of class JD3MBDenton
#'
#' @param x an object of class JD3MBDenton
#'
#' @return
#' @export
#'
#' @examples
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::aggregate(rjd3toolkit::retail$FoodAndBeverageStores, 4)
#' td<-rjd3bench::denton_modelbased(Y, x, outliers = list("2000-01-01"=100, "2005-07-01"=100))
#' print(td)
#'
print.JD3MBDenton<-function(x, ...){
  if (is.null(x$estimation$disagg)){
    cat("Invalid estimation")
  }else{
    cat("Available estimates:\n")
    print.default(names(x$estimation), ...)

    cat("\n")
    cat("Use summary() for more details. \nUse plot() to see the disaggregated series and BI ratio together with their respective confidence interval")
  }
}

#' Summary function for object of class JD3MBDenton
#'
#' @param object an object of class JD3MBDenton
#'
#' @return
#' @export
#'
#' @examples
#' Y<-rjd3toolkit::aggregate(rjd3toolkit::retail$RetailSalesTotal, 1)
#' x<-rjd3toolkit::aggregate(rjd3toolkit::retail$FoodAndBeverageStores, 4)
#' td<-rjd3bench::denton_modelbased(Y, x, outliers = list("2000-01-01"=100, "2005-07-01"=100))
#' summary(td)
#'
summary.JD3MBDenton<-function(object, ...){
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
    cat("Available estimates:\n")
    print.default(names(object$estimation))
  }
}

#' Plot function for object of class JD3MBDenton
#'
#' @param x an object of class JD3MBDenton
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
plot.JD3MBDenton<-function(x, ...){
  if (is.null(x)){
    cat("Invalid estimation")

  }else{
    td<-x$estimation$disagg
    td.sd<-x$estimation$edisagg
    td.lb<-td - 1.96 * td.sd
    td.ub<-td + 1.96 * td.sd
    bi<-x$estimation$biratio
    bi.sd<-x$estimation$ebiratio
    bi.lb<-bi - 1.96 * bi.sd
    bi.ub<-bi + 1.96 * bi.sd

    par(mfrow=c(2,1))
    ts.plot(td, td.lb, td.ub, gpars=list(main = "Disaggragated series and BI ratio with confidence interval", xlab="", ylab="disaggragated series", lty=c(1, 3, 3), ...))
    ts.plot(bi, bi.lb, bi.ub, gpars=list(xlab="", ylab="BI ratio", lty=c(1, 3, 3), ...))
  }
}

