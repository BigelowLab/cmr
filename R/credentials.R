#' Create a token
#' 
#' @export
#' @param x credentials list
#' @param uri character, the URL
#' @return token or NULL if fails
token_create <- function(x = read_credentials(),
                         uri = api_base("ops", segments = "api/users/token")){
  # curl -X POST --header "Content-Type: application/xml" -d "<token><username>sample_username</username><password>sample-password</password><client_id>client_name_of_your_choosing</client_id><user_ip_address>your_origin_ip_address</user_ip_address> </token>" https://cmr.earthdata.nasa.gov/legacy-services/rest/tokens
  #
  # OR save mytokengenerator.xml
  # 
  # <token>
  #   <username>sample_username</username>
  #   <password>sample-password</password>
  #   <client_id>client_name_of_your_choosing</client_id>
  #   <user_ip_address>your_origin_ip_address</user_ip_address>
  # </token>
  #
  # curl -X POST --header "Content-Type: application/xml" -d @mytokengenerator.xml https://cmr.uat.earthdata.nasa.gov/legacy-services/rest/tokens
  
  if (is.null(x[['client_id']])) x[['client_id']] <- x[['username']]
  if (is.null(x[['user_ip_address']])) x[['user_ip_address']] <- pingr::my_ip()
  if (!is.null(x[['token']])) x[['token']] <- NULL

  r <- httr::POST(uri, config = list(httr::add_headers(unlist(x))))
  
  r
}


#' Delete a token
#' @export
#' @param x credentials list 
token_delete <- function(x){
  # nothing yet
}



#' Read a credentials for EarthData
#' 
#' Credential files should have three lines
#' username: <user_name>
#' password: <password>
#' token: <token_value>
#' 
#' @export
#' @param filename char, the name of the credentials file
#' @return named list of credentials
read_credentials <- function(filename = "~/.earthdata"){
  yaml::read_yaml(filename[1])
}

#' Write a credentials for EarthData
#' 
#' Credential files should have three lines
#' username: <user_name>
#' password: <password>
#' token: <token_value>
#' 
#' @export
#' @param x named list of credentials
#' @param filename char, the name of the credentials file
#' @return the input list
write_credentials <- function(x, filename = "~/.earthdata"){
  yaml::write_yaml(x, filename[1])
  x
}





