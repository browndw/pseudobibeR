# Pseudo-Biber Aggregator

This package aggregates the lexicogrammatical and functional features described
by Biber (1985) and widely used for text-type, register, and genre
classification tasks.

The scripts are not really taggers. Rather, they use either
[udpipe](https://bnosac.github.io/udpipe/en/) or [spaCy](https://spacy.io/) (via
[spacyr](https://spacyr.quanteda.io/index.html)) part-of-speech tagging and
dependency parsing to summarize and aggregate patterns.

Because they rely on existing part-of-speech tagging, the accuracy of the
resulting counts are dependent on the accuracy of tagging. Thus, texts with
irregular spellings, non-normative punctuation, etc. will likely produce
unreliable outputs.

## Basic usage

The package provides one function, `biber()`, which takes either udpipe- or
spacyr-tagged text and produces a data frame of features for each document.

For example,

```r
library(spacyr)
library(pseudobibeR)

spacy_initialize(model = "en_core_web_sm")

features <- biber(
  spacy_parse(
    c("doc_1" = "The task was done by Steve"),
    dependency = TRUE,
    tag = TRUE,
    pos = TRUE
  )
)
```

## Testing

pseudobibR uses [testthat](https://testthat.r-lib.org/) for unit testing. To
avoid having to distribute spacy or updipe models for tests -- as these models
can be many megabytes -- the tests use saved output. Specifically, in the
`tests/testthat/text-samples/` directory,

- `samples.tsv` contains sample sentences for tests. Each line contains a
  document ID and then a sample text, separated by a tab character.
- `parse-samples.R` can be run to parse these sentences and save them to an RDS
  file.
- The unit tests then use the saved parsed sentences, which are distributed as
  part of the package.

If you update `samples.tsv`, you must run `parse-samples.R` to get the new
parsed sentences.
