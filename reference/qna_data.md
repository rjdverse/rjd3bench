# Quarterly National Accounts data for temporal disaggregation

List of two datasets. The first data set 'B1G_Y_data' includes three
annual benchmark series which are the Belgian annual value added on the
period 2009-2020 in chemical industry (CE), construction (FF) and
transport services (HH). The second data set 'TURN_Q_data' includes the
corresponding quarterly indicators which are (modified) production
indicators derived from VAT statistics and covering the period
2009Q1-2021Q4.

## Usage

``` r
qna_data
```

## Format

A list with two data frames, including a 'DATE' column and three columns
with the data related to the three industries.

## Source

Belgian Quarterly National Accounts

## Examples

``` r
data(qna_data)
names(qna_data)
#> [1] "B1G_Y_data"  "TURN_Q_data"
head(qna_data$B1G_Y_data)
#>         DATE B1G_CE  B1G_FF  B1G_HH
#> 1 2009-01-01 6784.5 17554.4 19069.3
#> 2 2010-01-01 7499.9 17720.1 19380.9
#> 3 2011-01-01 7811.4 18856.0 19805.7
#> 4 2012-01-01 7565.7 18849.7 19808.8
#> 5 2013-01-01 7625.0 18713.5 19557.1
#> 6 2014-01-01 8179.9 19008.0 20237.9
head(qna_data$TURN_Q_data)
#>         DATE TURN_INDEX_CE TURN_INDEX_FF TURN_INDEX_HH
#> 1 2009-03-01          71.1          80.5          90.6
#> 2 2009-06-01          74.7          98.4          93.6
#> 3 2009-09-01          81.2          87.6          90.4
#> 4 2009-12-01          81.3         106.0          99.5
#> 5 2010-03-01          86.8          79.9          91.7
#> 6 2010-06-01          95.9         101.5         100.3
```
