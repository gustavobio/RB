#' Get specimen image URLs, open them in a browser or download and store them
#' locally.
#'
#' These functions provide functionality to handle images from the RB herbarium. The
#' easiest way to use them is to get the object returned by \code{\link{search_rb}} and
#' pass it to these functions. Alternatively, you can search by scientific name, family, and barcode.
#'
#' @param specimens A data frame returned by \code{\link{search_rb}}.
#' @param scientific_name A character vector of names to be searched.
#' @param family A character vector of families.
#' @param barcode A character vector of barcodes.
#' @param max Maximum number of results to display or download.
#' @param random Logical indicating if random images should be downloaded or open when \code{max} is
#' lower than the number of search results. The default is to display the first \code{max} results.
#' @param width The width of the downloaded or open images in pixels.
#'
#' @export
#'
get_image_urls <- function(specimens = NULL,
                           scientific_name = NULL,
                           family = NULL,
                           barcode = NULL,
                           max = 5,
                           random = FALSE,
                           width = 600) {
  if (is.null(specimens)) {
    specimens <-
      search_rb(scientific_name = scientific_name,
                family = family,
                barcode = barcode)
  } else {
    if (is.null(attr(specimens, "specimens"))) {
      stop("The argument `specimens` should be a data frame as returned by search_rb()")
    }
  }
  specimens <- specimens[specimens$associatedMedia != "", ]
  if (nrow(specimens) == 0) {
    message("No records found.")
    return(NULL)
  }
  if (nrow(specimens) > max) {
    if (random) {
      specimens <- specimens[sample(nrow(specimens), max), ]
    } else {
      specimens <- specimens[seq_len(max), ]
    }
  }
  images <-
    paste0("http://", specimens$associatedMedia, "&width=", width)
  return(images)
}

#' @rdname get_image_urls
open_rb_images <- function(specimens = NULL,
                           scientific_name = NULL,
                           family = NULL,
                           barcode = NULL,
                           max = 5,
                           random = FALSE,
                           width = 600) {
  image_urls <- get_image_urls(
    specimens = specimens,
    scientific_name = scientific_name,
    family = family,
    barcode = barcode,
    max = max,
    random = random,
    width = width
  )
  if (!is.null(image_urls)) {
    invisible(sapply(image_urls, browseURL))
  } else {
    message("No images found.")
    return(NULL)
  }
}

#' @rdname get_image_urls
download_rb_images <- function(specimens = NULL,
                               scientific_name = NULL,
                               family = NULL,
                               barcode = NULL,
                               width = 3000,
                               random = FALSE,
                               max = 50) {
  image_urls <- get_image_urls(
    specimens = specimens,
    scientific_name = scientific_name,
    family = family,
    barcode = barcode,
    max = max,
    random = random,
    width = width
  )
  if (!is.null(image_urls)) {
    image_names <-
      regmatches(image_urls,
                 regexpr("[^/\\&\\?]+\\.\\w{3,4}(?=([\\?&].*$|$))", image_urls, perl = T))
    path <- paste("RB_images_", format(Sys.time(), "%d_%b_%H_%M_%S"), sep = "_")
    if (!dir.exists(path))
      dir.create(path)
    cat("Downloading", length(image_urls), "images to", paste0(getwd(), "/", path, "/:\n"))
    pb <- txtProgressBar(min = 0, max = length(image_urls), style = 3)
    for (i in seq_along(image_urls)) {
      # print(i)
      tries <- 1
      repeat {
        if (tries >= 3) Sys.sleep(30)
        if (tries > 5) stop("Can't reach the website. Please try again later.")
        success <- try({
          # print(temp)
          setTxtProgressBar(pb, i)
          download.file(image_urls[i],
                        destfile = paste0(paste0(path, "/"), image_names[i], ".jpg"),
                        mode = "wb", quiet = TRUE)
        })
        if (!inherits(success, "try-error")) break
        tries <- tries + 1
      }
    }
    close(pb)
  } else {
    message("No images found.")
    return(NULL)
  }

}
