# Benchmarking by means of the Denton Method.

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

  A preliminary series. If not `NULL`, it must be of the same class as
  `t`.

- t:

  The low-frequency aggregation constraint. It must be either a `"ts"`
  object or a numeric vector.

- d:

  An integer specifying the differencing order. The default is `1`.

- mul:

  Boolean. Indicates whether benchmarking is multiplicative (`TRUE`) or
  additive (`FALSE`). The default is multiplicative.

- nfreq:

  An integer giving the annual frequency of the benchmarked series. This
  argument is used only when no preliminary series is provided.

- modified:

  Boolean. Specifies whether the modified Denton method (`TRUE`) or the
  unmodified Denton method (`FALSE`) is applied. The default is `TRUE`.

- conversion:

  A character string specifying the conversion mode, typically `"Sum"`
  (the default) or `"Average"`. Other options are: `"Last"`, `"First"`
  and `"UserDefined"`.

- obsposition:

  An integer specifying the position of the observations of the
  low-frequency constraint within the benchmarked series (e.g. the 7th
  month of the year). This argument is used only when
  `conversion = "UserDefined"`.

- nbcsts:

  An integer specifying the number of backcast periods. This argument is
  ignored when a preliminary series is provided. (Not yet implemented.)

- nfcsts:

  An integer specifying the number of forecast periods. This argument is
  ignored when a preliminary series is provided. (Not yet implemented.)

## Value

A `"ts"` object with the benchmarked series is returned.

## See also

For more information, see the vignette:

[`utils::browseVignettes()`](https://rdrr.io/r/utils/browseVignettes.html),
e.g. `browseVignettes(package = "rjd3bench")`

## Examples

``` r
Y <- rjd3toolkit::aggregate(rjd3toolkit::Retail$RetailSalesTotal, 1)

# Denton PFD without a preliminary series
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

# Denton PFD without a preliminary series and conversion = "Average"
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

# Denton PFD with a preliminary series
x <- y1 + rnorm(n = length(y1), mean = 0, sd = 10000)
denton(s = x, t = Y)
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 1992  438596.9  451485.7  461066.2  464567.2
#> 1993  471614.7  480671.3  468443.1  521518.9
#> 1994  512564.8  524549.3  537115.1  535791.8
#> 1995  554904.6  550191.1  543000.6  574407.6
#> 1996  568378.9  584555.6  601940.8  611789.6
#> 1997  620849.5  616436.7  630245.2  606471.6
#> 1998  629644.3  637489.0  647741.2  672230.5
#> 1999  674855.9  696106.3  711147.8  726446.0
#> 2000  737826.0  735409.7  750978.8  764541.4
#> 2001  773175.0  757352.9  775858.3  761338.9
#> 2002  771849.9  774304.4  784530.0  803637.6
#> 2003  813043.7  809390.9  818533.2  827186.2
#> 2004  865185.8  862483.1  874536.8  878224.3
#> 2005  902974.8  913019.6  945874.7  934821.9
#> 2006  957489.5  961460.0  958176.9 1003009.7
#> 2007  976438.1 1003018.3 1012315.8 1014025.9
#> 2008 1023771.3 1003964.1  979149.9  946047.7
#> 2009  915040.2  897219.6  908797.0  917414.2
#> 2010  962864.6  958656.3  982300.7  985643.4

# Denton AFD with a preliminary series
denton(s = x, t = Y, mul = FALSE)
#>           Qtr1      Qtr2      Qtr3      Qtr4
#> 1992  438935.0  451607.0  460943.9  464230.2
#> 1993  471229.8  480560.0  468194.8  522263.4
#> 1994  512940.1  524664.3  536900.3  535516.3
#> 1995  554682.3  550150.0  543017.7  574653.9
#> 1996  568418.9  584574.8  601934.3  611737.0
#> 1997  620740.9  616415.4  630109.5  606737.2
#> 1998  629734.3  637549.1  647724.3  672097.3
#> 1999  674707.0  696050.4  711211.0  726587.6
#> 2000  737919.5  735394.4  750930.7  764511.4
#> 2001  773233.9  757270.8  775938.4  761281.9
#> 2002  771827.4  774304.8  784554.0  803635.9
#> 2003  813093.6  809492.5  818519.6  827048.3
#> 2004  865044.9  862423.4  874619.5  878342.2
#> 2005  903110.2  913056.0  945835.4  934689.4
#> 2006  957396.7  961427.9  958236.4 1003075.0
#> 2007  976739.9 1003027.1 1012168.9 1013862.1
#> 2008 1023603.0 1003980.0  979229.1  946120.9
#> 2009  915102.1  897246.0  908766.4  917356.4
#> 2010  962825.6  958634.1  982323.2  985682.2
```
