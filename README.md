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

## Searching

The search process has 3 steps… (1) craft the URL, (2) make a request
and capture the response and (3) extract the links to the various
datasets.

#### Craft the URL

``` r
suppressPackageStartupMessages({
  library(cmr)
  library(dplyr)
})

x <- search_collection(
    id = "C1996881146-POCLOUD",
    times = c("2021-01-01T10:00:00Z","2021-02-01T00:00:00Z"),
    form = 'url')

x
```

    ## [1] "https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1996881146-POCLOUD&temporal=2021-01-01T10:00:00Z,2021-02-01T00:00:00Z"

#### Making the request

With a suitable browser, you can make the request and see the results.
But if your browser doesn’t do pretty renderings of JSON data then is
isn’t worth it.

    # httr::BROWSE(x) - for browsing, pretty nice in Firefox

But without using a browser, we can extract the interesting bits -
namely the links to the data.

``` r
resp <- httr::GET(x)
resp
```

    ## Response [https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1996881146-POCLOUD&temporal=2021-01-01T10:00:00Z,2021-02-01T00:00:00Z]
    ##   Date: 2022-05-05 12:49
    ##   Status: 200
    ##   Content-Type: application/vnd.nasa.cmr.umm_results+json;version=1.6.4; charset=utf-8
    ##   Size: 31.7 kB
    ## <BINARY BODY>

#### Unpack the request

Here we unpack the response.

``` r
links <- extract_collection(resp)
links
```

    ## # A tibble: 60 × 4
    ##    URL                                                 Type  Description Subtype
    ##    <chr>                                               <chr> <chr>       <chr>  
    ##  1 s3://podaac-ops-cumulus-protected/MUR-JPL-L4-GLOB-… GET … This link … <NA>   
    ##  2 https://archive.podaac.earthdata.nasa.gov/podaac-o… EXTE… Download 2… <NA>   
    ##  3 https://archive.podaac.earthdata.nasa.gov/podaac-o… GET … Download 2… <NA>   
    ##  4 https://archive.podaac.earthdata.nasa.gov/podaac-o… EXTE… Download 2… <NA>   
    ##  5 https://archive.podaac.earthdata.nasa.gov/s3creden… VIEW… api endpoi… <NA>   
    ##  6 https://opendap.earthdata.nasa.gov/providers/POCLO… USE … OPeNDAP re… OPENDA…
    ##  7 s3://podaac-ops-cumulus-protected/MUR-JPL-L4-GLOB-… GET … This link … <NA>   
    ##  8 https://archive.podaac.earthdata.nasa.gov/podaac-o… GET … Download 2… <NA>   
    ##  9 https://archive.podaac.earthdata.nasa.gov/podaac-o… EXTE… Download 2… <NA>   
    ## 10 https://archive.podaac.earthdata.nasa.gov/podaac-o… EXTE… Download 2… <NA>   
    ## # … with 50 more rows

#### Combine the three steps into one

An example adapted from the
[examples](https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#general-request-details)

Here I switch the example to MUR-GRHSST data set, so I use the MUR
collection ID. MUR is posted once per day. We are interested in opendap,
so we filter on `^.*OPeNDAP` in the `Description` variable.

``` r
x <- search_collection(
    id = "C1996881146-POCLOUD",
    times = c("2021-01-01T10:00:00Z","2021-02-01T00:00:00Z"),
    description_pattern = "^.*OPeNDAP",
    verbose = TRUE) 
```

    ## search_collection URL: https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1996881146-POCLOUD&temporal=2021-01-01T10:00:00Z,2021-02-01T00:00:00Z

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

## Getting a token

In order to access the data, once you have found it, you need
credentials. CMR provides for a username-password combination to obtain
a temporary token. For each session you can obtain a token, do you
stuff, and then delete the token. Store you username and password in a
text file called `.earthdata` and save it in your home directory. It
should contain two items like this…

    username: htubman
    password: xxxxxxxxxxxxxxxxxxxxxxx

Read the credentails, extra info will be added to your username and
password.

``` r
creds <- read_credentials()
creds
```

    ## $username
    ## [1] "btupper"
    ## 
    ## $password
    ## [1] "..redacted.."
    ## 
    ## $client_id
    ## [1] "btupper"
    ## 
    ## $user_ip_address
    ## [1] "..redacted.."

Now get a token.

``` r
creds <- get_token(creds)
creds
```

    ## $username
    ## [1] "btupper"
    ## 
    ## $password
    ## [1] "..redacted.."
    ## 
    ## $client_id
    ## [1] "btupper"
    ## 
    ## $user_ip_address
    ## [1] "..redacted.."
    ## 
    ## $token
    ## [1] "..redacted.."

After you have done you work, delete the token

``` r
creds <- token_delete(creds)
creds
```

    ## $username
    ## [1] "btupper"
    ## 
    ## $password
    ## [1] "..redacted.."
    ## 
    ## $client_id
    ## [1] "btupper"
    ## 
    ## $user_ip_address
    ## [1] "..redacted.."
    ## 
    ## $token
    ## character(0)

## Open the OPeNDAP resource

And it falls apart because `ncdf4::nc_open()` simply passes the url.
It’s not really a ‘thing’ to pass credentials, too.

``` r
library(ncdf4)
nc <- try(nc_open(x$URL[1]))
```

    ## Error in R_nc4_open: NetCDF: Access failure
    ## Error in nc_open(x$URL[1]) : 
    ##   Error in nc_open trying to open file https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20210101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1 (return_on_error= FALSE )
