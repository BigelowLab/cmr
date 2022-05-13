#https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1625128926-GHRC_CLOUD&temporal=2019-01-01T10:00:00Z,2019-12-31T23:59:59Z

fetch <- function(uri = search_collection() |> 
                    dplyr::filter(grepl("OPENDAP", .data$Subtype, fixed = TRUE)) |>
                    dplyr::slice(1) |>
                    dplyr::pull(.data$URL),
  times = c("2019-01-01T10:00:00Z","2019-02-01T00:00:00Z"),
  bbox = c(-180, -90, 180, 90),
  cred = get_token()){
  
  
  
}