% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{dict}
\alias{dict}
\title{Dictionaries defining text features}
\format{
A named list with one entry per feature. The name is the feature
name, such as \code{f_33_pied_piping}; values give a list of terms or patterns.
Patterns are matched to spaCy tokens using \code{quanteda::tokens_lookup()}
using the \code{glob} valuetype.
}
\usage{
dict
}
\description{
For Biber features defined by matching text against dictionaries of word
patterns (such as third-person pronouns or conjunctions), or features that
can be found by matching patterns against text, this gives the dictionary of
patterns for each feature. These are primarily used internally by \code{biber()},
but are exported so users can examine the feature definitions.
}
\keyword{datasets}
