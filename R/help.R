#' Package RB
#'
#' Query the RB herbarium dataset and download specimens images
#'
#' This packages contain a set of tools for querying and downloading images
#' from the RB herbarium dataset.
#' @docType package
#' @import rvest finch
#' @importFrom utils browseURL download.file setTxtProgressBar txtProgressBar
#' @importFrom xml2 read_html
#' @name RB
#' @aliases RB RB-package

rb_env <- new.env(parent = emptyenv())
