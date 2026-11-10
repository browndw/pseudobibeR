# Contributing to pseudobibeR

Thank you for helping improve the package. Please report problems and
suggestions on [GitHub](https://github.com/browndw/pseudobibeR/issues).

## Reporting issues

Please include:

- a short text that shows the problem and the counts you expected;
- the parser and model used (for example udpipe `english-ewt-ud-2.5-191206`
  or spaCy `en_core_web_sm`), with their versions;
- your R and package versions.

Proposals to change what a feature counts are welcome. Please explain the
linguistic reasoning; accepted changes are recorded in the family decision
log ([CROSS_LANGUAGE_ALIGNMENT.md](CROSS_LANGUAGE_ALIGNMENT.md)) so that the English, Spanish and French
packages stay parallel.

## Package layout

- `R/parse_functions.R`: `biber()` and all feature detectors.
- `data/`: the `dict` and `word_lists` resources and the sample parses.
- `tests/testthat/`: tests on saved parses of the sample sentences, snapshot
  tests of the full output, and tests on controlled annotations
  (`test-family-alignment.R`).
- `CROSS_LINGUISTIC_FEATURES.md`: how each feature is realized in English,
  Spanish and French. Update it when a feature's definition changes.

## Test data

Tests use saved parses so that language models are not distributed with the
package. The sample sentences are in `tests/testthat/text-samples/samples.tsv`.
After changing them, regenerate the parses:

```r
# from tests/testthat/text-samples/
source("parse-samples.R")
```

## Running tests and checks

```r
devtools::document()
devtools::test()
devtools::check()
```

If a change alters counts on the sample texts, review the snapshot differences
with `testthat::snapshot_review()` before accepting them.
