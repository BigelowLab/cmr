#' Retrieve the API base url
#' 
#' @export
#' @param name char, one of 'ops', 'uat' or 'sit'
#' @param segments NULL or character to append to the URL
#' @return character URL
api_base <- function(name = 'ops',
                     segments = list(NULL, "search/granules.umm_json")[[1]]){
  x <- switch(tolower(name[1]),
    "ops" = "https://cmr.earthdata.nasa.gov",
    "uat" = "https://cmr.uat.earthdata.nasa.gov",
    "sit" = "https://cmr.sit.earthdata.nasa.gov",
    stop("name not known:", name))
  if (!is.null(segments)  && !is.na(segments[1])) x <- file.path(x, segments[1])
  x
}

#' Search a collection
#' 
#' @export
#' @param id character, 'collection_concept_id' 
#' @param times 2 element character (or POSIXct) start and stop search bounds or
#'   NULL to skip
#' @param base_url character, the base URL for searching
#' @param verbose logical, if TRUE print the URL
#' @param form character, "response" to return a \code{\link{httr}{response}} object,
#'   "url" to retrieve the charcater URL, or 
#'   "table" to extract a table of links
#' @param ... extra arguments for \code{\link{collection_extract}}
#' @return \code{\link{httr}{response}} object, a tibble as per \code{\link{collection_extract}}
search_collection <- function(id = "C1996881146-POCLOUD",
  times = c("2019-01-01T10:00:00Z","2019-02-01T00:00:00Z"),
  base_url = api_base(name = "ops", segments = "search/granules.umm_json"),
  verbose = FALSE,
  form = c("response", "table", "url")[2],
  ...){
  
  uri <- sprintf("%s?collection_concept_id=%s", base_url, id[1])
  
  if (!is.null(times)){
    if (inherits(times, 'POSIXt')) times <- format(times, "%Y-%m-%dT%H:%M:%SZ")
    uri <- sprintf("%s&temporal=%s,%s", uri, times[1], times[2])
  }
  
  if (verbose[1]){
    cat(sprintf("search_collection URL: %s", uri), "\n")
  }
  
  if (tolower(form[1]) == 'url') return(uri)
  
  x <- httr::GET(uri)
  
  if (tolower(form[1]) == 'table') x <- extract_collection(x, ...)
  
  x
}

#' Extract search results into a table of links
#' 
#' @export
#' @param x \code{\link{httr}{response}} object
#' @param description_pattern character, one or more regular expressions with which
#'   to filter the 'Description' variable.  Or "all" to skip filtering.
#' @param ... extra arguments for \code{\link[base]{grepl}} such as \code{fixed}
#' @return tibble, possibly empty
#' \itemize{
#'   \item{URL, the url}
#'   \item{Type, describes the type of protocol for access}
#'   \item{Description, a verbose description}
#'   \item{Subtype, not really sure what this is}
#' }
extract_collection <- function(x = search_collection(form = "response"),
                           description_pattern = c("all", "^.*OPeNDAP")[1],
                           ...){
  
  dummy <- dplyr::tibble(
    URL = "",
    Type = "",
    Description = "",
    Subtype = "") |>
    dplyr::slice(0)
  
  if (httr::http_error(x)){
    httr::warn_for_status(x)
    return(dummy)
  }
  
  r <- try(httr::content(x, encoding = "utf-8", type = "application/json"))
  if (inherits(x, "try-error")){
    print(x)
    return(dummy)
  }
  
  d <- lapply(r$items,
              function(item){
                lapply(item$umm$RelatedUrls,
                       function(related) {
                         dplyr::as_tibble(related)
                       })
              }) |>
    dplyr::bind_rows()
  
  if (!("all" %in% description_pattern)){
    ix <- mgrepl(description_pattern, d$Description, ...)
    d <- dplyr::filter(d, ix)
  }
  d
}