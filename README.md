## Pseudo-Biber Aggregator

The R scipts in this repository aggregate the lexicogrammatical and functonal features described by Biber (1985) and widely used for text-type, register, and genre classification tasks.

The scripts are not really taggers. Rather, they use either [udpipe](https://bnosac.github.io/udpipe/en/) or [spaCy](https://spacy.io/) part-of-speech tagging and dependency parsing to summarize and aggregate patterns.

Because they rely on spaCy, the accuracy of the resulting counts are dependent on the accuracy of tagging produced by spaCy. Thus, texts with irregular spellings, non-normative punctuation, etc. will likely produce unreliable outputs.

## Installing and Running pseudobibeR

Use devtools to install the package.

```r
devtools::install_github("browndw/pseudobibeR")
```

The package documentation is available on [readthedocs](https://cmu-textstat-docs.readthedocs.io/en/latest/pseudobibeR/pseudobibeR.html)
