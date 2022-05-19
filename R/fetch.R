#https://cmr.earthdata.nasa.gov/search/granules.umm_json?collection_concept_id=C1625128926-GHRC_CLOUD&temporal=2019-01-01T10:00:00Z,2019-12-31T23:59:59Z

# manual copy of https://cmr.earthdata.nasa.gov/virtual-directory/collections/C1996881146-POCLOUD/temporal/2002/12/01
# https://archive.podaac.earthdata.nasa.gov/podaac-ops-cumulus-protected/MUR-JPL-L4-GLOB-v4.1/20021202090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc

# Opendap link gets to 
# https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20190101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1

# see tutorial
# https://github.com/podaac/tutorials/blob/master/notebooks/opendap/MUR-OPeNDAP.ipynb

fetch <- function(uri = search_collection() |> 
                    dplyr::filter(grepl("OPENDAP", .data$Subtype, fixed = TRUE)) |>
                    dplyr::slice(1) |>
                    dplyr::pull(.data$URL),
  extras = c('analysed_sst[0:1:0][000:1:9000][000:1:9000]',
  'analysis_error[0:1:0][000:1:9000][000:1:9000]',
  'lat[000:1:9000]',
  'lon[000:1:9000]',
  'time[0:1:0]'),
  cred = get_token()){
  
  if (FALSE){
    uri = search_collection() |> 
      dplyr::filter(grepl("OPENDAP", .data$Subtype, fixed = TRUE)) |>
      dplyr::slice(1) |>
      dplyr::pull(.data$URL)
    cred = get_token()
    extras = c('analysed_sst[0:1:0][000:1:900][000:1:900]',
               'analysis_error[0:1:0][000:1:900][000:1:900]',
               'lat[000:1:900]',
               'lon[000:1:900]',
               'time[0:1:0]')
  }
  
  require(curl)
  
  base_url <- paste0(uri, ".dap.nc4")
  data_url <- base_url |>
    paste(paste(extras, collapse = ";"), sep = ";")
  
  
  
  tmpfile <- basename(base_url)
  
  h <- curl::new_handle() |>
    curl::handle_setopt(
      followlocation = TRUE,
      netrc_file = "/Users/ben/.netrc",
      cookiefile = "/Users/ben/.cookies",
      username = cred$username,
      password = cred$password)
  
  ok <- curl::curl_download(data_url, tmpfile, handle = h)
  
}