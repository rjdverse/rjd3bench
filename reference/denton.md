# Benchmarking by means of the Denton method.

Denton method relies on the principle of movement preservation. There
exist a few variants corresponding to different definitions of movement
preservation: additive first difference (AFD), proportional first
difference (PFD), additive second difference (ASD), proportional second
difference (PSD), etc. The default and most widely used is the Denton
PFD method.

## Usage

``` r
denton(
  s = NULL,
  t,
  d = 1L,
  mul = TRUE,
  nfreq = 4L,
  modified = TRUE,
  conversion = c("Sum", "Average", "Last", "First", "UserDefined"),
  obsposition = 1L,
  nbcsts = 0L,
  nfcsts = 0L
)
```

## Arguments

- s:

  Preliminary series. If not NULL, it must be the same class as t.

- t:

  Aggregation constraint. Mandatory. it must be either an object of
  class ts or a numeric vector.

- d:

  Differencing order. 1 by default.

- mul:

  Multiplicative or additive benchmarking. Multiplicative by default.

- nfreq:

  Annual frequency of the disaggregated variable. Used if no
  disaggregated series is provided.

- modified:

  Modified (TRUE) or unmodified (FALSE) Denton. Modified by default.

- conversion:

  Conversion rule. Usually "Sum" or "Average". Sum by default.

- obsposition:

  Position of the observation in the aggregated period (only used with
  "UserDefined" conversion).

- nbcsts:

  Number of backcast periods. Ignored when a preliminary series is
  provided. (not yet implemented)

- nfcsts:

  Number of forecast periods. Ignored when a preliminary series is
  provided. (not yet implemented)

## Value

The benchmarked series is returned

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)

# denton PFD without a preliminary series
y1 <- denton(t = Y, nfreq = 4)
print(y1)
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 1992  448459.8  450647.5  455022.8  461585.9
#> 1993  470336.7  479927.1  490357.2  501627.0
#> 1994  513736.5  524087.8  532680.9  539515.8
#> 1995  544592.4  551036.5  558848.0  568027.0
#> 1996  578573.3  588029.0  596394.1  603668.5
#> 1997  609852.3  615785.2  621467.2  626898.3
#> 1998  632078.6  640029.7  650751.8  664244.9
#> 1999  680508.8  695666.5  709717.8  722662.8
#> 2000  734501.5  744312.0  752094.2  757848.3
#> 2001  761574.1  765207.3  768747.8  772195.7
#> 2002  775550.9  780104.8  785857.5  792808.8
#> 2003  800958.8  810650.7  821884.4  834660.1
#> 2004  848977.5  863156.5  877197.0  891099.0
#> 2005  904862.4  918091.9  930787.5  942949.2
#> 2006  954576.9  965410.8  975451.0  984697.4
#> 2007  993150.0  999850.8 1004799.9 1007997.3
#> 2008 1009442.9 1001537.3  984280.4  957672.4
#> 2009  921713.2  902491.3  900006.8  914259.6
#> 2010  945249.8  968492.5  983987.6  991735.1

# denton PFD without a preliminary series and conversion = "Average"
denton(t = Y, nfreq = 4, conversion = "Average")
#>         Qtr1    Qtr2    Qtr3    Qtr4
#> 1992 1793839 1802590 1820091 1846344
#> 1993 1881347 1919708 1961429 2006508
#> 1994 2054946 2096351 2130724 2158063
#> 1995 2178370 2204146 2235392 2272108
#> 1996 2314293 2352116 2385576 2414674
#> 1997 2439409 2463141 2485869 2507593
#> 1998 2528314 2560119 2603007 2656980
#> 1999 2722035 2782666 2838871 2890651
#> 2000 2938006 2977248 3008377 3031393
#> 2001 3046297 3060829 3074991 3088783
#> 2002 3102204 3120419 3143430 3171235
#> 2003 3203835 3242603 3287538 3338640
#> 2004 3395910 3452626 3508788 3564396
#> 2005 3619450 3672368 3723150 3771797
#> 2006 3818307 3861643 3901804 3938789
#> 2007 3972600 3999403 4019200 4031989
#> 2008 4037771 4006149 3937122 3830690
#> 2009 3686853 3609965 3600027 3657039
#> 2010 3780999 3873970 3935950 3966940

# denton PFD with a preliminary series
x <- y1 + rnorm(n = length(y1), mean = 0, sd = 10000)
denton(s = x, t = Y)
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 1992  452252.4  431594.5  475592.7  456276.4
#> 1993  464975.1  478932.7  483960.9  514379.3
#> 1994  518589.7  514922.4  544945.1  531563.8
#> 1995  538353.4  550675.2  560070.4  573405.0
#> 1996  578870.7  600143.2  580999.0  606652.1
#> 1997  610164.7  613745.5  629293.1  620799.7
#> 1998  631687.8  639941.5  651952.2  663523.5
#> 1999  667225.9  690848.6  714652.8  735828.8
#> 2000  730899.3  756724.9  745494.5  755637.4
#> 2001  754324.1  760258.1  774506.7  778636.1
#> 2002  769589.6  773817.5  778185.6  812729.3
#> 2003  806202.6  814316.4  813723.1  833911.8
#> 2004  841584.0  874817.2  867352.0  896676.8
#> 2005  908245.6  908998.7  954678.6  924768.0
#> 2006  949567.4  962146.7  972408.7  996013.2
#> 2007  999617.3 1002049.5 1000039.9 1004091.4
#> 2008  999962.4 1002485.6  979654.1  970830.8
#> 2009  913661.4  906649.3  901955.8  916204.5
#> 2010  950510.3  948778.9  990446.3  999729.4

# denton AFD with a preliminary series
denton(s = x, t = Y, mul = FALSE)
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 1992  452254.0  431266.1  475891.5  456304.4
#> 1993  465013.3  478952.1  483988.9  514293.6
#> 1994  518674.6  515075.8  544865.8  531404.8
#> 1995  538073.7  550590.5  560194.9  573644.9
#> 1996  579072.0  599971.4  581257.0  606364.6
#> 1997  610023.9  613739.5  629348.8  620890.8
#> 1998  631716.9  639937.6  651951.8  663498.7
#> 1999  667029.7  690782.8  714741.3  736002.2
#> 2000  730954.2  756758.3  745459.5  755584.0
#> 2001  754293.5  760253.7  774525.6  778652.2
#> 2002  769595.5  773820.9  778201.6  812704.0
#> 2003  806278.0  814376.2  813708.0  833791.8
#> 2004  841352.1  874804.1  867388.8  896885.0
#> 2005  908442.3  909176.7  954340.9  924731.0
#> 2006  949418.2  962111.0  972506.4  996100.4
#> 2007  999651.1 1002037.9 1000031.2 1004077.8
#> 2008 1000109.3 1002713.2  979582.9  970527.6
#> 2009  913319.0  906597.8  902153.1  916401.1
#> 2010  950519.9  948870.0  990394.1  999681.0
```
