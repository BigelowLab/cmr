# https://podaac.jpl.nasa.gov/OPeNDAP-in-the-Cloud
# https://podaac.jpl.nasa.gov/dataset/MUR-JPL-L4-GLOB-v4.1?ids=&values=&search=MUR&provider=POCLOUD

# programmatic cmr
# https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1996881146-POCLOUD&temporal=2019-01-01T10:00:00Z,2019-02-01T00:00:00Z
# 
# https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20190101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1


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

# search
# https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1996881146-POCLOUD&temporal=2019-01-01T10:00:00Z,2019-01-02T00:00:00Z
# opendap
# https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20190101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1



search_collection <- function(
  temporal = c("2019-01-01T10:00:00Z","2019-02-01T00:00:00Z"),
  collection_concept_id = "C1996881146-POCLOUD",
  base_uri = api_base(name = "ops", segments = "search/granules.umm_json")){
  
}

