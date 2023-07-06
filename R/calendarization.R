#' @include utils.R
NULL

#' Calendarization
#'
#' Based on "Calendarization with splines and state space models" B. Quenneville, F.Picard and S.Fortier Appl. Statistics (2013) 62, part 3, pp 371-399.
#' State space implementation.
#'
#' @param calendarobs Observations (list of {start, end, value}). See the example.
#' @param freq Annual frequency. If 0, only the daily series are computed
#' @param start Starting day of the calendarization. Could be before the calendar obs (extrapolation)
#' @param end Final day of the calendarization. Could be after the calendar obs (extrapolation)
#' @param dailyweights Daily weights. Should have the same length as the requested series
#' @param stde
#'
#' @return
#' @export
#'
#' @examples
#' obs<-list(
#'     list(start="1980-01-01", end="1989-12-31", value=100),
#'     list(start="1990-01-01", end="1999-12-31", value=-10),
#'     list(start="2000-01-01", end="2002-12-31", value=50))
#' cal<-calendarization(obs, 4, end="2003-12-31", stde=TRUE)
#' Q<-cal$rslt
#' eQ<-cal$erslt
calendarization<-function(calendarobs, freq, start=NULL, end=NULL, dailyweights=NULL, stde=F){
  jcal<-rjd3toolkit::r2jd_calendarts(calendarobs)
  if (is.null(dailyweights)){
    jw<-.jnull("[D")
  }else{
    jw<-.jarray(as.numeric(dailyweights))
  }
  if (is.null(start)){
    jstart<-.jnull("java/lang/String")
  }else{
    jstart<-as.character(start)
  }
  if (is.null(end)){
    jend<-.jnull("java/lang/String")
  }else{
    jend<-as.character(end)
  }
  jrslt<-.jcall("jdplus/benchmarking/base/r/Calendarization", "Ljdplus/benchmarking/base/api/calendarization/CalendarizationResults;",
                "process", jcal, as.integer(freq), jstart, jend, jw, as.logical(stde))

  if (stde){
    rslt<-rjd3toolkit::.proc_ts(jrslt, "agg")
    erslt<-rjd3toolkit::.proc_ts(jrslt, "eagg")
    start<-as.Date(rjd3toolkit::.proc_str(jrslt, "start"))
    days<-rjd3toolkit::.proc_vector(jrslt, "days")
    edays<-rjd3toolkit::.proc_vector(jrslt, "edays")
    return (list(rslt=rslt, erslt=erslt, start=start,days=days, edays=edays))
  }else{
    rslt<-rjd3toolkit::.proc_ts(jrslt, "agg")
    start<-as.Date(rjd3toolkit::.proc_str(jrslt, "start"))
    days<-rjd3toolkit::.proc_vector(jrslt, "days")
    return (list(rslt=rslt, start=start,days=days))
  }
}
