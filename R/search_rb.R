#' Search specimens in the RB collection.
#'
#' This function filters a local copy of the RB collection according to
#' user-defined arguments. The returned object can them be used to visualize or download
#' register images.
#'
#' @param scientific_name A character vector with one or more scientific names.
#' @param family A character vector with one or more families.
#' @param genus A character vector with one or more genera.
#' @param collector A character vector to be matched against collectors in the database.
#' @param county A character vector with one or more counties.
#' @param state A character vector with one or more Brazilian states (full names only).
#' @param barcode A character vector with one or more catalog numbers.
#' @param with_images A logical indicating whether to return only specimens with images.
#' @param with_coordinates A logical indicating whether to return only specimens with geographical
#' coordinates.
#' @param year A numerical or character vector indicating years to refine the search.
#' @export
#' @examples
#' \dontrun{
#' search_rb("Miconia albicans")
#' search_rb(family = "Melastomataceae", county = "Itirapina")
#' search_rb(genus = "Myrcia", state = "Rio de Janeiro")
#' search_rb("Miconia rubiginosa", years = 2001:2003, with_images = TRUE)
#' }
search_rb <- function(
  scientific_name = NULL,
  family = NULL,
  genus = NULL,
  collector = NULL,
  county = NULL,
  state = NULL,
  barcode = NULL,
  with_images = FALSE,
  with_coordinates = FALSE,
  year = NULL) {

  if (is.null(c(scientific_name, family, genus, collector, county, barcode, state, year))) {
    stop("Please provide at least one search field.")
  }

  if (!exists("data", envir = rb_env, inherits = FALSE)) {
    download_rb_data()
  }

  specimens <- rb_env$data$data$occurrence.txt
  images <- rb_env$data$data$multimedia.txt

  if (!is.null(scientific_name)) {
    specimens <- specimens[grepl(scientific_name, specimens$scientificName), ]
  }
  if (!is.null(family)) {
    family <- toupper(family)
    specimens <- specimens[specimens$family %in% family, ]
  }
  if (!is.null(genus)) {
    specimens <- specimens[specimens$genus %in% genus, ]
  }
  if (!is.null(collector)) {
    specimens <- specimens[grep(collector, specimens$recordedBy, ignore.case = TRUE), ]
  }
  if (!is.null(county)) {
    specimens <- specimens[specimens$county %in% county, ]
  }
  if (!is.null(state)) {
    specimens <- specimens[specimens$stateProvince %in% state, ]
  }
  if (!is.null(barcode)) {
    barcode <- gsub("RB|rb", "", barcode)
    barcode <- sprintf("%08s", barcode)
    barcode <- paste0("RB", barcode)
    specimens <- specimens[specimens$catalogNumber %in% barcode, ]
  }
  if (with_images) {
    specimens <- specimens[specimens$associatedMedia != "", ]
  }
  if (with_coordinates) {
    specimens <- specimens[!is.na(specimens$decimalLatitude), ]
  }
  if (!is.null(year)) {
    specimens <- specimens[specimens$year %in% year, ]
  }
  structure(specimens, specimens = TRUE)
}

