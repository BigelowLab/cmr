#https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1625128926-GHRC_CLOUD&temporal=2019-01-01T10:00:00Z,2019-12-31T23:59:59Z

fetch <- function(
    collection_concept_id = "C1996881146-POCLOUD",
    temporal = NULL,
    
    
  cred = get_token())