#' Download the Darwin Core Archive file from http://ipt.jbrj.gov.br/jbrj/
#'
#' These functions are used mainly internally to manage the DWC-A files from
#' the RB IPT repository. All files are downloaded to a local cache and will be
#' reused as long as the cache isn't purged.
#'
#' @param ... further arguments passed on to \code{fread}
#' @export

rb_latest_data <- function() {
  base_url <- "http://ipt.jbrj.gov.br/jbrj/resource?r=jbrj_rb"
  read_html(base_url) %>%
    html_nodes("tr:nth-child(1) a") %>%
    html_attr("href")
}

#' @export
#' @rdname rb_latest_data
download_rb_data <- function(...) {
  if (!exists("data", envir = rb_env, inherits = FALSE)) {
    assign("data", dwca_read(rb_latest_data(), read = T), envir = rb_env)
  } else {
    message("Data already downloaded.")
  }
}
