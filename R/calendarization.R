#' @include utils.R
NULL

#' @title Calendarization
#'
#' @description
#' Time series data do not always coincide with calendar periods (e.g., fiscal
#' years starting in March-April or retail data collected in non-monthly
#' intervals). Calendarization is the process of transforming the values of a
#' flow time series observed over varying time intervals into values that cover
#' given calendar intervals such as month, quarter or year. The process involves
#' two steps. At first, a state-space representation of the Denton proportional
#' first difference (PFD) method is considered to perform a temporal
#' disaggregation of the observed data into daily values. After that, the
#' resulting daily values are aggregated into the desired calendar reference
#' periods.
#'
#' @param calendarobs A named list containing the observed data. The list must
#'   consist of three elements: `start`, `end` and `value`, where the first two
#'   indicate the starting and ending dates of the observation. See the example.
#' @param freq An integer specifying the annual frequency. If set to `0`, only the daily series is computed.
#' @param start The starting day of the calendarization. This date may precede the first observed data (retropolation).
#' @param end The ending day of the calendarization. This date may exceed the last observed data (extrapolation).
#' @param dailyweights A numeric vector of daily indicator values (or weights).
#'   The vector must have the same length as the requested daily series. When
#'   available, these weights typically reflects daily levels of activity, which
#'   may vary due to seasonality, trading day effects, or other calendar effects
#'   such as public holidays.
#' @param stde Boolean. If `TRUE`, the function also returns the standard errors associated with the results.
#' The default is `FALSE`.
#'
#' @return A list containing the disaggregated daily values, the final aggregated series, and their associated standard errors if requested.
#'
#' @references  Quenneville, B., Picard F., Fortier S. (2012). Calendarization
#'   with interpolating splines and state space models. Statistics Canada, Appl.
#'   Statistics (2013) 62, part 3, pp 371-399.
#'
#' @export
#'
#' @seealso For more information, see the vignette:
#'
#' `utils::browseVignettes()`, e.g. `browseVignettes(package = "rjd3bench")`
#'
#' @examplesIf rjd3jars::check_java_version(silent = TRUE)
#'
#' # Example 1 (from Quenneville et al (2012))
#'
#' ## Observed data
#' obs_1 <- list(
#'     list(start = "2009-02-18", end = "2009-03-17", value = 9000),
#'     list(start = "2009-03-18", end = "2009-04-14", value = 5000),
#'     list(start = "2009-04-15", end = "2009-05-12", value = 9500),
#'     list(start = "2009-05-13", end = "2009-06-09", value = 7000))
#'
#' ## a) calendarization in absence of daily indicator values (or weights)
#' cal_1a <- calendarization(obs_1, 12, end = "2009-06-30", dailyweights = NULL, stde = TRUE)
#'
#' ym_1a <- cal_1a$rslt
#' eym_1a <- cal_1a$erslt
#' yd_1a <- cal_1a$days
#' eyd_1a <- cal_1a$edays
#'
#' ## b) calendarization in presence of daily indicator values (or weights)
#' x <- rep(c(1.0, 1.2, 1.8 , 1.6, 0.0, 0.6, 0.8), 19)
#' cal_1b <- calendarization(obs_1, 12, end = "2009-06-30", dailyweights = x, stde = TRUE)
#'
#' ym_1b <- cal_1b$rslt
#' eym_1b <- cal_1b$erslt
#' yd_1b <- cal_1b$days
#' eyd_1b <- cal_1b$edays
#'
#' # Example 2 (incl. negative value)
#'
#' obs_2 <- list(
#'     list(start = "1980-01-01", end = "1989-12-31", value = 100),
#'     list(start = "1990-01-01", end = "1999-12-31", value = -10),
#'     list(start = "2000-01-01", end = "2002-12-31", value = 50))
#'
#' cal_2 <- calendarization(obs_2, 4, end = "2003-12-31")
#'
#' yq_2 <- cal_2$rslt
#'
calendarization <- function(calendarobs, freq, start = NULL, end = NULL, dailyweights = NULL, stde = FALSE) {
    jcal <- rjd3toolkit::r2jd_calendarts(calendarobs)
    if (is.null(dailyweights)) {
        jw <- .jnull("[D")
    } else {
        jw <- .jarray(as.numeric(dailyweights))
    }
    if (is.null(start)) {
        jstart <- .jnull("java/lang/String")
    } else {
        jstart <- as.character(start)
    }
    if (is.null(end)) {
        jend <- .jnull("java/lang/String")
    } else {
        jend <- as.character(end)
    }
    jrslt <- .jcall("jdplus/benchmarking/base/r/Calendarization", "Ljdplus/benchmarking/base/api/calendarization/CalendarizationResults;",
                    "process", jcal, as.integer(freq), jstart, jend, jw, as.logical(stde))

    if (stde) {
        rslt <- rjd3toolkit::.proc_ts(jrslt, "agg")
        erslt <- rjd3toolkit::.proc_ts(jrslt, "eagg")
        start <- as.Date(rjd3toolkit::.proc_str(jrslt, "start"))
        days <- rjd3toolkit::.proc_vector(jrslt, "days")
        edays <- rjd3toolkit::.proc_vector(jrslt, "edays")
        return(list(rslt = rslt, erslt = erslt, start = start, days = days, edays = edays))
    } else {
        rslt <- rjd3toolkit::.proc_ts(jrslt, "agg")
        start <- as.Date(rjd3toolkit::.proc_str(jrslt, "start"))
        days <- rjd3toolkit::.proc_vector(jrslt, "days")
        return(list(rslt = rslt, start = start, days = days))
    }
}
