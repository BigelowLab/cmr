cmr
================

Programmatic access to [Common Metadata
Repositories](https://wiki.earthdata.nasa.gov/display/CMR/Common+Metadata+Repository+Home)
from R

## Requirements

-   [R v4.1+](https://www.r-project.org/)

-   [httr](https://CRAN.R-project.org/package=httr)

-   [base64enc](https://CRAN.R-project.org/package=base64enc)

-   [yaml](https://CRAN.R-project.org/package=yaml)

-   [rlang](https://CRAN.R-project.org/package=rlang)

-   [dplyr](https://CRAN.R-project.org/package=dplyr)

-   [pingr](https://CRAN.R-project.org/package=pingr)

## Installation

    remotes::install_github("BigelowLab/cmr")

## And example searching for MUR GHRSST

An example adapted from the
[examples](https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#general-request-details)

Here I switch the example to MUR-GRHSST data set, so I use the MUR
collection ID. MUR is posted once per day. We are interested in opendap,
so we filter on `^.*OPeNDAP` in the `Description` variable.

``` r
suppressPackageStartupMessages({
  library(cmr)
  library(dplyr)
})

x <- search_collection(
    id = "C1996881146-POCLOUD",
    times = c("2021-01-01T10:00:00Z","2021-02-01T00:00:00Z"),
    description_pattern = "all",
    verbose = TRUE) |>
  dplyr::filter(grepl("^.*OPeNDAP", Description))
```

    ## search_collection url = https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1996881146-POCLOUD&temporal=2021-01-01T10:00:00Z,2021-02-01T00:00:00Z

``` r
x
```

    ## # A tibble: 10 × 4
    ##    URL                                                 Type  Description Subtype
    ##    <chr>                                               <chr> <chr>       <chr>  
    ##  1 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  2 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  3 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  4 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  5 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  6 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  7 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  8 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  9 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ## 10 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…

Whoopsie! It seems like there should be about a month’s worth of hits
(30 or so). Instead we get only the 10 days (pagination defaults to 10)
But where is the pagination information in the response? The header says
32 hits, but that doesn’t inform which page. We could increase the
`page-size` from 10 to some higher number, but one would have to know
what that is apriori. Fooey.

And it falls apart because `ncdf4::nc_open()` simply passes the url.
It’s not really a ‘thing’ to pass credentials, too.

``` r
library(ncdf4)
nc <- try(nc_open(x$URL[1]))
```

    ## Error in R_nc4_open: NetCDF: Authorization failure
    ## Error in nc_open(x$URL[1]) : 
    ##   Error in nc_open trying to open file https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20210101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1 (return_on_error= FALSE )
