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
#' @param description_pattern character, one or more regular expressions with which
#'   to filter the 'Description' variable.  Or "all" to skip filtering.
#' @param verbose logical, if TRUE print the URL
#' @param ... extra arguments for \code{\link[base]{grepl}} such as \code{fixed}
#' @return tibble of related URLs and descriptions
#' \itemize{
#' \item{URL, the url}
#' \item{Type, describes the type of protocol for access}
#' \item{Description, a verbose description}
#' \item{Subtype, not really sure what this is}
#' }
search_collection <- function(id = "C1996881146-POCLOUD",
  times = c("2019-01-01T10:00:00Z","2019-02-01T00:00:00Z"),
  base_url = api_base(name = "ops", segments = "search/granules.umm_json"),
  description_pattern = "^.*OPeNDAP",
  verbose = FALSE,
  ...){
  uri <- sprintf("%s?collection_concept_id=%s", base_url, id[1])
  if (!is.null(times)){
    if (inherits(times, 'POSIXt')) times <- format(times, "%Y-%m-%dT%H:%M:%SZ")
    uri <- sprintf("%s&temporal=%s,%s", uri, times[1], times[2])
  }
  if (verbose[1]){
    cat(sprintf("search_collection url = %s", uri), "\n")
  }
  
  x <- try(httr::GET(uri))
  if (inherits(x, "try-error")){
    print(x)
    return(
      dplyr::tibble(
        URL = "",
        Type = "",
        Description = "",
        Subtype = "") |>
      dplyr::slice(0))
  }
  
  r <- try(httr::content(x, encoding = "utf-8", type = "application/json"))
  if (inherits(x, "try-error")){
    print(x)
    return(
      dplyr::tibble(
        URL = "",
        Type = "",
        Description = "",
        Subtype = "") |>
      dplyr::slice(0))
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
    ix <- mgrepl(description_pattern, x$Description, ...)
    d <- dplyr::filter(d,ix)
  }
  d
}

