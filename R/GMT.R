#' @include AllClasses.R
NULL

#' Import GMT files
#'
#' @param con File name of the GMT file.
#' @param sep Separation of the file
#' @param ... Other arguments passed to strsplit
#' @return A TidySet object
#' @family IO functions
#' @export
#' @examples
#' gmtFile <- system.file(package = "BaseSet", "extdata",
#'                                   "hallmark.gene.symbol.gmt")
#' gs <- getGMT(gmtFile)
#' nRelations(gs)
#' nElements(gs)
#' nSets(gs)
getGMT <- function(con, sep = "\t", ...)  {
    lines <- strsplit(readLines(con, ...), sep)
    if (any(lengths(lines) < 2)) {
        stop("all records in the GMT file must have >= 2 fields", call. = FALSE)
    }
    dups <- new.env(parent = emptyenv())
    lines <- lapply(lines, function(elt, dups) {
        if (any(d <- duplicated(elt[-c(1, 2)]))) {
            dups[[elt[[1]]]] <- unique(elt[-c(1, 2)][d])
            elt <- c(elt[c(1, 2)], unique(elt[-c(1, 2)]))
        }
        elt
    }, dups)
    if (length(dups)) {
        stop("The file contain duplicate ids for the same set", call. = FALSE)
    }

    names(lines) <- vapply(lines, '[', i = 1, character(1L))
    links <- vapply(lines, '[', i = 2, character(1L))
    lines <- lapply(lines, function(x) {
        x[seq(from = 3,  to = length(x))]
    })
    TS <- tidySet(lines)
    df <- data.frame(links = links, stringsAsFactors = FALSE)
    TS <- add_column(TS, "sets", df)
    TS
}

