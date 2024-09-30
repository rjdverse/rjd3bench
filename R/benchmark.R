#' @include utils.R
NULL

#' Benchmarking by means of the Denton method.
#'
#' Denton method relies on the principle of movement preservation. There exist
#' a few variants corresponding to different definitions of movement
#' preservation: additive first difference (AFD), proportional first difference
#' (PFD), additive second difference (ASD), proportional second difference
#' (PSD), etc. The default and most widely adopted is the Denton PFD method.
#'
#' @param s Disaggregated series. If not NULL, it must be the same class as t.
#' @param t Aggregation constraint. Mandatory. it must be either an object of class ts or a numeric vector.
#' @param d Differencing order. 1 by default
#' @param mul Multiplicative or additive benchmarking. Multiplicative by default
#' @param nfreq Annual frequency of the disaggregated variable. Used if no disaggregated series is provided.
#' @param modified Modified (TRUE) or unmodified (FALSE) Denton. Modified by default
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by default.
#' @param obsposition Position of the observation in the aggregated period (only used with "UserDefined" conversion)
#' @return The benchmarked series is returned
#'
#' @export
#' @examples
#' Y<-ts(qna_data$B1G_Y_data$B1G_FF, frequency=1, start=c(2009,1))
#'
#' # denton PFD without high frequency series
#' y1<-rjd3bench::denton(t=Y, nfreq=4)
#'
#' # denton ASD
#' x1<-y1+rnorm(n=length(y1), mean=0, sd=10)
#' y2<-rjd3bench::denton(s=x1, t=Y, d=2, mul=FALSE)
#'
#' # denton PFD used for temporal disaggregation
#' x2 <- ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency=4, start=c(2009,1))
#' y3<-rjd3bench::denton(s=x2, t=Y)
#'
denton<-function(s=NULL, t, d=1, mul=TRUE, nfreq=4, modified=TRUE,
                 conversion=c("Sum", "Average", "Last", "First", "UserDefined"),
                 obsposition=1){

  conversion <- match.arg(conversion)

  jd_t <- rjd3toolkit::.r2jd_tsdata(t)

  if (!is.null(s)){
    jd_s <- rjd3toolkit::.r2jd_tsdata(s)
  } else {
    jd_s<-as.integer(nfreq)
  }
  jd_rslt<-.jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "denton",
                  jd_s, jd_t, as.integer(d), mul, modified, conversion, as.integer(obsposition))
  rjd3toolkit::.jd2r_tsdata(jd_rslt)
}


#' Benchmarking following the growth rate preservation principle.
#'
#' This method corresponds to the method of Cauley and Trager, using the solution
#' proposed by Di Fonzo and Marini.
#'
#' @param s Disaggregated series. Mandatory. It must be a ts object.
#' @param t Aggregation constraint. Mandatory. It must be a ts object.
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by default.
#' @param obsposition Postion of the observation in the aggregated period (only used with "UserDefined" conversion)
#' @param eps
#' @param iter
#' @param denton
#'
#' @return
#' @export
#'
#' @examples
#' data("qna_data")
#' Y<-ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency=1, start=c(2009,1))
#' x<-ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency=4, start=c(2009,1))
#' y<-rjd3bench::grp(s=x, t=Y)
#'
grp<-function(s, t,
              conversion=c("Sum", "Average", "Last", "First", "UserDefined"),
              obsposition=1, eps=1e-12, iter=500, denton=TRUE){

  conversion <- match.arg(conversion)

  jd_s<-rjd3toolkit::.r2jd_tsdata(s)
  jd_t<-rjd3toolkit::.r2jd_tsdata(t)
  jd_rslt<-.jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "grp",
                  jd_s, jd_t, conversion, as.integer(obsposition), eps, as.integer(iter), as.logical(denton))
  rjd3toolkit::.jd2r_tsdata(jd_rslt)
}

#' Benchmarking by means of cubic splines
#'
#' Cubic splines are piecewise cubic functions that are linked together in
#' a way to guarantee smoothness at data points. Additivity constraints are
#' added for benchmarking purpose and sub-period estimates are derived
#' from each spline. When a sub-period indicator (or disaggregated series) is
#' used, cubic splines are no longer drawn based on the low frequency data
#' but the Benchmark-to-Indicator (BI ratio) is the one being smoothed. Sub-
#' period estimates are then simply the product between the smoothed high
#' frequency BI ratio and the indicator.
#'
#' @param s Disaggregated series. If not NULL, it must be the same class as t.
#' @param t Aggregation constraint. Mandatory. it must be either an object of class ts or a numeric vector.
#' @param nfreq Annual frequency of the disaggregated variable. Used if no disaggregated series is provided.
#' @param conversion Conversion rule. Usually "Sum" or "Average". Sum by default.
#' @param obsposition Postion of the observation in the aggregated period (only used with "UserDefined" conversion)
#'
#' @return
#' @export
#'
#' @examples
#' data("qna_data")
#' Y<-ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency=1, start=c(2009,1))
#'
#' # cubic spline without disaggregated series
#' y1<-rjd3bench::cubicspline(t=Y, nfreq=4)
#'
#' # cubic spline with disaggregated series
#' x1<-y1+rnorm(n=length(y1), mean=0, sd=10)
#' y2<-rjd3bench::cubicspline(s=x1, t=Y)
#'
#' # cubic splines used for temporal disaggregation
#' x2<-ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency=4, start=c(2009,1))
#' y3<-rjd3bench::cubicspline(s=x2, t=Y)
#'
cubicspline<-function(s=NULL, t, nfreq=4,
                      conversion=c("Sum", "Average", "Last", "First", "UserDefined"),
                      obsposition=1){

  conversion <- match.arg(conversion)

  jd_t<-rjd3toolkit::.r2jd_tsdata(t)

  if (!is.null(s)){
    jd_s<-rjd3toolkit::.r2jd_tsdata(s)
  } else {
    jd_s<-as.integer(nfreq)
  }
  jd_rslt<-.jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "cubicSpline",
                  jd_s, jd_t, conversion, as.integer(obsposition))
  rjd3toolkit::.jd2r_tsdata(jd_rslt)
}


#' @title Cholette method
#'
#' @description Benchmarking by means of the Cholette method.
#'
#' @param s Disaggregated series. Mandatory
#' @param t Aggregation constraint. Mandatory
#' @param rho
#' @param lambda
#' @param bias
#' @param conversion
#' @param obsposition Postion of the observation in the aggregated period (only used with "UserDefined" conversion)
#'
#' @details
#' \deqn{\sum_{i,t}\left(\left(\frac{{x_{i,t}-z}_{i,t}}{\left|z_{i,t}\right|^\lambda}\right)-\rho\left(\frac{{x_{i,t-1}-z}_{i,t-1}}{\left|z_{i,t-1}\right|^\lambda}\right)\right)^2}
#'
#' @export
#'
#'
cholette<-function(s, t, rho=1, lambda=1, bias="None", conversion="Sum", obsposition=1){
  jd_s<-rjd3toolkit::.r2jd_tsdata(s)
  jd_t<-rjd3toolkit::.r2jd_tsdata(t)
  jd_rslt<-.jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/api/timeseries/TsData;", "cholette",
                  jd_s, jd_t, rho, lambda, bias, conversion, as.integer(obsposition))
  rjd3toolkit::.jd2r_tsdata(jd_rslt)
}

#' Multi-variate Cholette
#'
#' @param xlist
#' @param tcvector
#' @param ccvector
#' @param rho
#' @param lambda
#'
#' @return
#' @export
#'
#' @examples
#'
#' s1 <- ts(c(7, 7.2, 8.1, 7.5, 8.5, 7.8, 8.1, 8.4), frequency = 4, start = c(2010, 1))
#' s2 <- ts(c(18, 19.5, 19.0, 19.7, 18.5, 19.0, 20.3, 20.0), frequency = 4, start = c(2010, 1))
#' s3 <- ts(c(1.5, 1.8, 2, 2.5, 2.0, 1.5, 1.7, 2.0), frequency = 4, start = c(2010, 1))
#'
#' a <- ts(c(27.1, 29.8, 29.9, 31.2, 29.3, 27.9, 30.9, 31.8), frequency = 4, start = c(2010, 1))
#'
#' y1 <- ts(c(30.0, 30.6), frequency = 1, start = c(2010, 1))
#' y2 <- ts(c(80.0, 81.2), frequency = 1, start = c(2010, 1))
#' y3 <- ts(c(8.0, 8.1), frequency = 1, start = c(2010, 1))
#'
#' data_list <- list(s1 = s1, s2 = s2, s3 = s3, a = a, y1 = y1, y2 = y2, y3 = y3)
#'
#' cc <- c("a=s1+s2+s3") # contemporaneous constraints
#' tc <- c("y1=sum(s1)", "y2=sum(s2)", "y3=sum(s3)") # temporal constraints
#'
#' output1 <- multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 1, lambda = .5) # = Denton
#' output2 <- multivariatecholette(xlist = data_list, tcvector = tc, ccvector = cc, rho = 0.729, lambda = .5) # = Cholette
#' output3 <- multivariatecholette(xlist = data_list, tcvector = NULL, ccvector = cc, rho = 1, lambda = .5)
#'
multivariatecholette<-function(xlist, tcvector=NULL, ccvector=NULL, rho=1, lambda=1) {
  if (!is.list(xlist) || length(xlist) < 3) {
    stop("incorrect argument, first argument should be a list of at least 3 time series")}

  #create the input
  jdic <- .jnew("jdplus/toolkit/base/r/util/Dictionary")
  for(i in seq_along(xlist)){
    .jcall(jdic, "V", "add", names(xlist[i]), rjd3toolkit::.r2jd_tsdata(xlist[[i]]))
  }
  if (is.null(tcvector)){
    ntc <- 0
    jtc<-.jcast(.jnull(), "[Ljava/lang/String;")
  } else if (! is.vector(tcvector)){
    stop("incorrect argument, constraints should be presented within a character vector")
  } else {
    ntc<-length(tcvector)
    jtc<-.jarray(tcvector, "java/lang/String")
  }
  if (is.null(ccvector)){
    ncc <- 0
    jcc<-.jcast(.jnull(), "[Ljava/lang/String;")
  } else if (! is.vector(ccvector)){
    stop("incorrect argument, constraints should be presented within a character vector")
  } else {
    ncc<-length(ccvector)
    jcc<-.jarray(ccvector, "java/lang/String")
  }
  if (ntc+ncc==0) {
    stop("both constraint types are empty, include at least one temporal or contemporaneous constraint")}

  jd_rslt<-.jcall("jdplus/benchmarking/base/r/Benchmarking", "Ljdplus/toolkit/base/r/util/Dictionary;", "multiCholette",
                  jdic,  jtc, jcc, rho, lambda)
  if (is.jnull(jd_rslt))
    return(NULL)
  rlist <- list()
  rnames <- .jcall(jd_rslt, "[S", "names")
  for(i in seq_along(rnames)){
    jts<-.jcall(jd_rslt, "Ljdplus/toolkit/base/api/timeseries/TsData;", "get", rnames[i])
    if (! is.jnull(jts)){
      rlist[[rnames[i]]]<-rjd3toolkit::.jd2r_tsdata(jts)
    }
  }
  return(rlist)
}
