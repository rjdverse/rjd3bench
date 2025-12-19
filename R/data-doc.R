
#' Quarterly National Accounts data for temporal disaggregation
#'
#' List of two datasets. The first data set 'B1G_Y_data' includes three annual
#' benchmark series which are the Belgian annual value added on the period
#' 2009-2020 in chemical industry (CE), construction (FF) and transport
#' services (HH). The second data set 'TURN_Q_data' includes the corresponding
#' quarterly indicators which are (modified) production indicators derived from
#' VAT statistics and covering the period 2009Q1-2021Q4.
#'
#' @format A list with two data frames, including a 'DATE' column and three
#'   columns with the data related to the three industries.
#'
#' @source Belgian Quarterly National Accounts
#'
#' @examples
#' data(qna_data)
#' names(qna_data)
#' head(qna_data$B1G_Y_data)
#' head(qna_data$TURN_Q_data)
"qna_data"


