#' Title
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
#' Y<-ts(qna_data$B1G_Y_data[,"B1G_FF"], frequency=1, start=c(2009,1))
#' x<-ts(qna_data$TURN_Q_data[,"TURN_INDEX_FF"], frequency=4, start=c(2009,1))
#' td1<-rjd3bench::adl_disaggregation(Y, indicators=x, xar="FREE")
#' td2<-rjd3bench::adl_disaggregation(Y, indicators=x, xar="SAME")
adl_disaggregation<-function(series, constant=T, trend=F, indicators=NULL,
                                 conversion=c("Sum", "Average", "Last", "First", "UserDefined"), conversion.obsposition=1,
                                 phi=0, phi.fixed=F, phi.truncated=0, xar=c("FREE", "SAME", "NONE")){
  conversion=match.arg(conversion)
  jseries<-rjd3toolkit::.r2jd_tsdata(series)
  jlist<-list()
  if (!is.null(indicators)){
    if (is.list(indicators)){
      for (i in 1:length(indicators)){
        jlist[[i]]<-rjd3toolkit::.r2jd_tsdata(indicators[[i]])
      }
    }else if (is.ts(indicators)){
      jlist[[1]]<-rjd3toolkit::.r2jd_tsdata(indicators)
    }else{
      stop("Invalid indicators")
    }
    jindicators<-.jarray(jlist, contents.class = "jdplus/toolkit/base/api/timeseries/TsData")
  }else{
    jindicators<-.jnull("[Ljdplus/toolkit/base/api/timeseries/TsData;")
  }
  jrslt<-.jcall("jdplus/benchmarking/base/r/TemporalDisaggregation", "Ljdplus/benchmarking/base/core/univariate/ADLResults;",
                "processADL", jseries, constant, trend, jindicators, conversion,
                phi, phi.fixed, phi.truncated, xar)
  
  # Build the S3 result
  bcov<-rjd3toolkit::.proc_matrix(jrslt, "covar")
  vars<-rjd3toolkit::.proc_vector(jrslt, "regnames")
  coef<-rjd3toolkit::.proc_vector(jrslt, "coeff")
  se<-sqrt(diag(bcov))
  t<-coef/se
  m<-data.frame(coef, se, t)
  m<-`row.names<-`(m, vars)
  
  regression<-list(
    type=xar,
    conversion=conversion,
    model=m,
    cov=bcov
  )
  estimation<-list(
    disagg=rjd3toolkit::.proc_ts(jrslt, "disagg"),
    edisagg=rjd3toolkit::.proc_ts(jrslt, "edisagg"),
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
