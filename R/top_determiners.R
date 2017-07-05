#' Get the top determiners for a given taxon
#'
#' @param taxon A character string
#'
#' @example
#'
top_determiners <-
  function(scientific_name = NULL,
           genus = NULL,
           family = NULL) {
    if (is.null(c(scientific_name, genus, family)))
      stop("Please provide at least one taxon.")

    if (!is.null(scientific_name)) {
      specimens <-
        RB:::rb_env$data$data$occurrence.txt[grepl(
          scientific_name,
          RB:::rb_env$data$data$occurrence.txt$scientificName,
          ignore.case = TRUE
        ), ]
    }

    if (!is.null(genus)) {
      specimens <-
        RB:::rb_env$data$data$occurrence.txt[RB:::rb_env$data$data$occurrence.txt$genus == genus, ]
    }

    if (!is.null(family)) {
      specimens <-
        RB:::rb_env$data$data$occurrence.txt[RB:::rb_env$data$data$occurrence.txt$family == toupper(family), ]
    }

    determiners <-
      unlist(strsplit(specimens$identifiedBy, ";|&|\\set\\s|\\se\\s"))

    determiners <- trimws(determiners)
    determiners <- gsub("\\s{2,}", " ", determiners)

    determiners <- gsub("\\.(?=\\w)", ". ", determiners, perl = TRUE)

    determiners <- strsplit(determiners, ",")

     determiners <- lapply(determiners, rev)

    # THERE ARE DETERMINERS THAT ARE SEPARATED BY COMMAS AS WELL.

     binder <- function(x) {
       if (length(x) == 1) {
         return(x)
       }
       if (length(x) == 2) {
         two_authors<- grepl("\\.|[A-Z]\\s", x[2])
         return(paste(x, collapse = ifelse(two_authors, "; ", " ")))
       }
       if (length(x) > 2) {
         return(paste(x, collapse = " "))
       }
     }
     unlist(lapply(determiners, binder))
  }


remove_double_ws <- function(x) {
  gsub("\\s+", " ", x)
}

fix_full_stops <- function(x) {
  gsub("\\.+(?=\\w)", ". ", x, perl = TRUE)
}

standardise_separators <- function(x) {
  x <- gsub("\\s(et|ET|Et|&|e)(?=\\s|\\.)", " ||", x, perl = TRUE)
  gsub("\\|\\|\\.", "||", x)
}

standardise_commas <- function(x) {
  x <- remove_double_ws(x)
  gsub("\\s{0,1}\\,\\s{0,1}", ", ", x)
}

fix_initials <- function(x) {
  regex <- "[A-Z]+"
  x1 <- regexec(regex, x)
  x1 <- regmatches(x, x1)
  x1
}
