#' @include AllClasses.R AllGenerics.R operations.R
NULL



#' Merge two sets
#'
#' Given a TidySets merges two sets into the new one.
#' @param object A TidySet object
#' @param sets The name of the sets to be used.
#' @param name The name of the new set.
#' @param FUN A function to be applied when performing the union.
#' The standard union is the "max" function, but you can provide any other
#' function that given a numeric vector returns a single number.
#' @param keep A logical value if you want to keep
#' @param keep_relations A logical value if you wan to keep old relations
#' @param keep_elements A logical value if you wan to keep old elements
#' @param keep_sets A logical value if you wan to keep old sets
#' @param ... Other arguments.
#' @return A \code{TidySet} object.
#' @export
#' @family methods that create new sets
#' @family methods
#' @examples
#' relations <- data.frame(sets = c(rep("a", 5), "b"),
#'                         elements = letters[seq_len(6)],
#'                         fuzzy = runif(6))
#' a <- tidySet(relations)
#' union(a, c("a", "b"), "C")
union <- function(object, ...) {
    UseMethod("union")
}

# #' @export
# union.default <- function(object, ...) {
#     stopifnot(length(list(...)) == 1)
#     base::union(object, ...)
# }

#' @rdname union
#' @export
#' @method union TidySet
union.TidySet <- function(object, sets, name = NULL, FUN = "max", keep = FALSE,
                          keep_relations = keep,
                          keep_elements = keep,
                          keep_sets = keep, ...) {
    if (is.null(name)) {
        name <- naming(sets1 = sets)
    } else if (length(name) != 1) {
        stop("The new union can only have one name", call. = FALSE)
    }
    object <- add_sets(object, name)
    relations <- relations(object)
    union <- relations[relations$sets %in% sets, ]
    if (is.factor(union$sets)) {
        levels(union$sets)[levels(union$sets) %in% sets] <- name
    } else {
        union$sets[union$sets %in% sets] <- name
    }
    union <- fapply(union, FUN)
    object <- replace_interactions(object, union, keep_relations)
    object <- droplevels(object, !keep_elements, !keep_sets, !keep_relations)
    validObject(object)
    object
}
