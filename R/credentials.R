#' Get a token
#' 
#' @seealso \href{https://wiki.earthdata.nasa.gov/display/CMR/CMR+Client+Partner+User+Guide#CMRClientPartnerUserGuide-Chapter2:GettingStarted}{CMR guide}
#'
#' @export
#' @param x credentials list
#' @param delete logical if TRUE delete exisiting token (if it exists) first
#' @param ... other arguments for \code{\link{token_create}}
#' @return updated credentials list
get_token <- function(x = read_credentials(), delete = has_token(x), ...){
  if (delete && has_token(x)) x <- token_delete(x)
  x$token <- token_create(x, ...)
  x
}

#' Determine is credentials has a non-empty token
#' 
#' @export
#' @param x credentials list
#' @return logical, TRUE is non-empty token exists in credentials
has_token <- function(x = read_credentials()){
  all(!is.null(x$token) && inherits(x$token, 'character') && (length(x$token) > 0))
}

#' Create a token
#' 
#' @seealso \href{https://wiki.earthdata.nasa.gov/display/CMR/CMR+Client+Partner+User+Guide#CMRClientPartnerUserGuide-Chapter2:GettingStarted}{CMR guide}
#' @export
#' @param x credentials list
#' @param uri character, the URL
#' @param verbose logical, if TRUE echo the command string
#' @return character token or NULL if fails
token_create <- function(x = read_credentials(),
                         verbose = FALSE,
                         uri = api_base("ops", segments = "legacy-services/rest/tokens")){

  y <- x[!(names(x) %in% "token")]
  resp <- httr::POST(uri,  
               body = as_xml_string(y),
               httr::content_type_xml())
  
  if (httr::http_error(resp)) {
    print(resp)
    warning(sprintf("error POSTing for token: %s"), uri)
    return(NULL)
  }
  
  r <- httr::content(resp)$token[['id']]  
  return(r)
}


#' Delete a token
#' 
#' @seealso \href{https://wiki.earthdata.nasa.gov/display/CMR/CMR+Client+Partner+User+Guide#CMRClientPartnerUserGuide-Chapter2:GettingStarted}{CMR guide}
#' @export
#' @param x credentials list
#' @param uri character, the URL
#' @param verbose logical, if TRUE echo the command string
#' @param x credentials list 
token_delete <- function(x = read_credentials(),
                         uri = api_base("ops", segments = "legacy-services/rest/tokens"),
                         verbose = FALSE){
  
  
  
  if (is.null(x$token)){
    stop("token must be not be NULL")
  }
  if (!inherits(x$token, 'character')){
    stop("token must be a character string")
  }
  if (length(x$token) == 0){
    stop("token must be a non-zero length character string")
  }

  y <- x[!(names(x) %in% "token")]
  resp <- httr::DELETE(file.path(uri,x$token), httr::content_type_xml())
  
  if (httr::http_error(resp)) {
    print(resp)
    warning(sprintf("error DELETEing token: %s"), uri)
    return(NULL)
  }
  x[['token']] <- character()
  
  x
}

#' Print credentials by default redacted (for README)
#' 
#' @export
#' @param x credentials object
#' @param redact logical, by default redact sensitive information
#' @param ... other arguments for the print method
print.cmr_credentials <- function(x, redact = TRUE, ...){
  if (redact){
    x$password <- "..redacted.."
    if ("user_ip_address" %in% names(x)) x$user_ip_address <- "..redacted.."
    if ("token" %in% names(x) && length(x$token > 0)) x$token <- "..redacted.."
  }
  class(x) <- "list"
  print(x)
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
#' @param client_id character, can be anyhting, defaults to user name
#' @param user_ip_address character, defaults to that provided by 
#'   \code{\link[pingr]{my_ip}}
#' @param form character, one of 'list', "xml" or "xml-string"
#' @return named list of credentials
read_credentials <- function(filename = "~/.earthdata",
                             client_id = system2("whoami", stdout = TRUE),
                             user_ip_address = pingr::my_ip(),
                             form = c('list', "xml", "xml-string")[1]){
  x <- c(yaml::read_yaml(filename[1]), 
         client_id = client_id, 
         user_ip_address = user_ip_address)
  class(x) <- c("cmr_credentials", class(x))
  switch(tolower(form[1]),
         "xml" = as_xml(x),
         "xml-string" = as_xml_string(x),
         x)
}

save_credentials <- function(x, filename = "~/.earthdata"){
  must_have <- c("username", "password", "token")
  y <- x[names(x) %in% must_have]
  if (!all(names(y) %in% must_have)){
    stop("credentials must have", paste(must_have, collapse = ", "))
  }
  yaml::write_yaml(y, filename)
  x
}

#' Given a credentials list, convert to an xml node
#' 
#' @export
#' @param x list of credentials from \code{\link{read_credentials}}
#' @return xml node
as_xml <- function(x = read_credentials()){
  node <- xml2::xml_new_root("token") |> xml2::xml_root()
  for (nm in names(x))  xml2::xml_add_child(node, nm, x[[nm]])
  node
}

#' Given a credentials list, convert to an xml string
#' 
#' @export
#' @param x list of credentials from \code{\link{read_credentials}}
#' @return character, single element of XML
as_xml_string <- function(x = read_credentials()){
  node <- as_xml(x)
  tmp <- tempfile(fileext = ".xml")
  xml2::write_xml(node, tmp, options = "format")
  readLines(tmp)[-1] |> trimws(which = "both") |> paste(collapse = "")
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





