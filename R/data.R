#' Dictionaries defining text features
#'
#' For Biber features defined by matching text against dictionaries of word
#' patterns (such as third-person pronouns or conjunctions), or features that
#' can be found by matching patterns against text, this gives the dictionary of
#' patterns for each feature. These are primarily used internally by `biber()`,
#' but are exported so users can examine the feature definitions.
#'
#' @format A named list with one entry per feature. The name is the feature
#'   name, such as `f_33_pied_piping`; values give a list of terms or patterns.
#'   Patterns are matched to spaCy tokens using `quanteda::tokens_lookup()`
#'   using the `glob` valuetype.
"dict"

#' Lists of words defining text features
#'
#' For Biber features defined by matching texts against certain exact words,
#' rather than patterns, this list defines the exact words defining the
#' features. These lists are primarily used internally by `biber()`, but are
#' exported so users can examine the feature definitions.
#'
#' @format A named list with one entry per word list. Each entry is a vector of
#'   words.
"word_lists"
