# pseudobibeR: Aggregate Counts of Linguistic Features

[![R-CMD-check](https://github.com/browndw/pseudobibeR/workflows/R-CMD-check/badge.svg)](https://github.com/browndw/pseudobibeR/actions)
[![Tests](https://github.com/browndw/pseudobibeR/workflows/Tests/badge.svg)](https://github.com/browndw/pseudobibeR/actions)
[![CRAN status](https://www.r-pkg.org/badges/version/pseudobibeR)](https://CRAN.R-project.org/package=pseudobibeR)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/pseudobibeR)](https://cran.r-project.org/package=pseudobibeR)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The **pseudobibeR** package calculates the lexicogrammatical and functional features described by Biber (1985) and widely used for text-type, register, and genre classification tasks. The package extracts 67 different linguistic features from pre-parsed text data, enabling researchers to analyze linguistic variation across different text types and registers.

## Overview

This package doesn't perform part-of-speech tagging itself. Instead, it leverages existing high-quality taggers from [udpipe](https://bnosac.github.io/udpipe/en/) or [spaCy](https://spacy.io/) (via [spacyr](https://spacyr.quanteda.io/index.html)) to extract and aggregate linguistic patterns. The accuracy of feature extraction depends on the quality of the underlying part-of-speech tagging and dependency parsing.

**Note:** Texts with irregular spellings, non-normative punctuation, or domain-specific language may produce less reliable outputs unless the taggers are specifically tuned for those purposes.

## Installation

Install the stable version from CRAN:

```r
install.packages("pseudobibeR")
```

Or install the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("browndw/pseudobibeR")
```

## Quick Start

The package provides the main function `biber()`, which takes either udpipe- or spacyr-tagged text and produces a data frame of linguistic features for each document.

### Using spaCy (via spacyr)

```r
library(spacyr)
library(pseudobibeR)

# Initialize spaCy (requires Python and spaCy installation)
spacy_initialize(model = "en_core_web_sm")

# Parse text and extract features
features <- biber(
  spacy_parse(
    c("doc_1" = "The task was done by Steve",
      "doc_2" = "I think that you should reconsider your approach"),
    dependency = TRUE,
    tag = TRUE,
    pos = TRUE
  )
)

print(features)
```

### Using udpipe

```r
library(udpipe)
library(pseudobibeR)

# Download and load udpipe model
ud_model <- udpipe_download_model(language = "english")
ud_model <- udpipe_load_model(ud_model$file_model)

# Parse text and extract features
text_data <- data.frame(
  doc_id = c("doc_1", "doc_2"),
  text = c("The task was done by Steve",
           "I think that you should reconsider your approach")
)

parsed_data <- udpipe_annotate(ud_model, 
                              x = text_data$text, 
                              doc_id = text_data$doc_id,
                              tagger = "default",
                              parser = "default")

features <- biber(parsed_data)
print(features)
```

### Using sample data

The package includes sample data to demonstrate functionality:

```r
library(pseudobibeR)

# Extract features from sample spaCy-parsed data
spacy_features <- biber(spacy_samples)
head(spacy_features)

# Extract features from sample udpipe-parsed data  
udpipe_features <- biber(udpipe_samples)
head(udpipe_features)
```

## Key Features

- **67 linguistic features** organized into 16 categories
- **Automatic feature normalization** to counts per 1,000 tokens (optional)
- **Multiple type-token ratio measures** (MATTR, TTR, CTTR, MSTTR)
- **Support for both spaCy and udpipe** parsing pipelines
- **Built-in dictionaries and word lists** for feature detection
- **Comprehensive test suite** with saved parsing examples

## Dependencies and Requirements

### Core Dependencies

- R (>= 3.5.0)
- dplyr, purrr, quanteda, quanteda.textstats, rlang, stringr, tibble, magrittr

### For Text Parsing

Choose one of the following parsing pipelines:

#### Option 1: spaCy + spacyr

- Python with spaCy installed
- spacyr R package
- A spaCy language model (e.g., `en_core_web_sm`)

#### Option 2: udpipe  

- udpipe R package
- A udpipe language model

See the respective package documentation for installation instructions.

## Function Arguments

The `biber()` function accepts the following arguments:

- `tokens`: Pre-parsed text data from `spacyr::spacy_parse()` or `udpipe::udpipe_annotate()`
- `measure`: Type-token ratio measure (`"MATTR"`, `"TTR"`, `"CTTR"`, `"MSTTR"`, or `"none"`)
- `normalize`: Whether to normalize counts to per 1,000 tokens (`TRUE`/`FALSE`)

```r
# Example with custom parameters
features <- biber(parsed_data, 
                  measure = "MATTR", 
                  normalize = TRUE)
```

## Development and Testing

pseudobibeR uses [testthat](https://testthat.r-lib.org/) for comprehensive unit testing. To avoid distributing large language models with the package, tests use pre-saved parsing outputs.

### Test Structure

- `tests/testthat/text-samples/samples.tsv`: Sample sentences for testing
- `tests/testthat/text-samples/parse-samples.R`: Script to generate parsed samples  
- `tests/testthat/text-samples/*.rds`: Saved parsing outputs for tests

### Updating Test Data

If you modify `samples.tsv`, regenerate the parsed samples:

```r
# Navigate to tests/testthat/text-samples/
source("parse-samples.R")
```

### Running Tests

```r
# Run all tests
testthat::test_package("pseudobibeR")

# Run specific test files
testthat::test_file("tests/testthat/test-features.R")
```

## Package Data

The package includes several built-in datasets:

- `dict`: Dictionary patterns for feature detection (e.g., third-person pronouns, conjunctions)
- `word_lists`: Exact word lists for specific features  
- `spacy_samples`: Sample spaCy-parsed text data
- `udpipe_samples`: Sample udpipe-parsed text data

These can be examined to understand feature definitions:

```r
# View available dictionaries
names(dict)

# Examine specific word lists
word_lists$f_06_first_person_pronouns

# Load sample data
data(spacy_samples)
data(udpipe_samples)
```

## Citation

When using pseudobibeR in your research, please cite:

**The original Biber (1985) paper:**
> Biber, D. (1985). Investigating macroscopic textual variation through multifeature/multidimensional analyses. *Linguistics*, 23(2), 337-360. DOI: [10.1515/ling.1985.23.2.337](https://doi.org/10.1515/ling.1985.23.2.337)

**This package:**
> Brown, D. W. (2024). pseudobibeR: Aggregate Counts of Linguistic Features. R package version 1.1. <https://github.com/browndw/pseudobibeR>

## Linguistic Features Extracted

The package extracts 67 linguistic features organized into 16 categories based on Biber (1985). Each feature is identified through a combination of part-of-speech patterns, dependency relations, and lexical matching.

### Feature Categories

| Category | Features | Description |
|----------|----------|-------------|
| **A. Tense and aspect markers** | f_01-f_03 | Past tense, perfect aspect, present tense |
| **B. Place and time adverbials** | f_04-f_05 | Spatial and temporal adverbials |
| **C. Pronouns and pro-verbs** | f_06-f_12 | Personal pronouns, demonstratives, indefinites, pro-verb *do* |
| **D. Questions** | f_13 | Direct *wh*-questions |
| **E. Nominal forms** | f_14-f_16 | Nominalizations, gerunds, other nouns |
| **F. Passives** | f_17-f_18 | Agentless and *by*-passives |
| **G. Stative forms** | f_19-f_20 | *be* as main verb, existential *there* |
| **H. Subordination features** | f_21-f_38 | Various subordinate clause types |
| **I. Prepositional phrases, adjectives and adverbs** | f_39-f_42 | Prepositional phrases, attributive/predicative adjectives, adverbs |
| **J. Lexical specificity** | f_43-f_44 | Type-token ratio, average word length |
| **K. Lexical classes** | f_45-f_51 | Conjuncts, downtoners, hedges, amplifiers, emphatics, etc. |
| **L. Modals** | f_52-f_54 | Possibility, necessity, and predictive modals |
| **M. Specialized verb classes** | f_55-f_58 | Public, private, suasive verbs, *seem/appear* |
| **N. Reduced forms and dispreferred structures** | f_59-f_63 | Contractions, deletions, split constructions |
| **O. Co-ordination** | f_64-f_65 | Phrasal and clausal coordination |
| **P. Negation** | f_66-f_67 | Synthetic and analytic negation |

### Detailed Feature List

| Feature | Description           |
|--------|------------------------|
| - | **A. Tense and aspect markers** |
| f\_01\_past\_tense | Past tense |
| f\_02\_perfect\_aspect | Perfect aspect |
| f\_03\_present\_tense | Present tense |
| - | **B. Place and time adverbials** |
| f\_04\_place\_adverbials | Place adverbials (e.g., *above*, *beside*, *outdoors*) |
| f\_05\_time\_adverbials | Time adverbials (e.g., *early*, *instantly*, *soon*) |
| - | **C. Pronouns and pro-verbs** |
| f\_06\_first\_person\_pronouns | First-person pronouns |
| f\_07\_second\_person\_pronouns | Second-person pronouns |
| f\_08\_third\_person\_pronouns | Third-person personal pronouns (excluding it) |
| f\_09\_pronoun\_it | Pronoun *it* |
| f\_10\_demonstrative\_pronoun | Demonstrative pronouns (*that*, *this*, *these*, *those* as pronouns) |
| f\_11\_indefinite\_pronoun | Indefinite pronounes (e.g., *anybody*, *nothing*, *someone*) |
| f\_12\_proverb\_do | Pro-verb *do* |
| - | **D. Questions** |
| f\_13\_wh\_question | Direct *wh*-questions |
| - | **E. Nominal forms** |
| f\_14\_nominalization | Nominalizations (ending in -*tion*, -*ment*, -*ness*, -*ity*) |
| f\_15\_gerunds | Gerunds (participial forms functioning as nouns) |
| f\_16\_other\_nouns | Total other nouns |
| - | **F. Passives** |
| f\_17\_agentless\_passives | Agentless passives |
| f\_18\_by\_passives | *by*-passives |
| - | **G. Stative forms** |
| f\_19\_be\_main\_verb | *be* as main verb |
| f\_20\_existential\_there | Existential *there* |
| - | **H. Subordination features** |
| f\_21\_that\_verb\_comp | that verb complements (e.g., *I said [that he went]*.) |
| f\_22\_that\_adj\_comp | that adjective complements (e.g., *I'm glad [that you like it]*.) |
| f\_23\_wh\_clause | *wh*-clauses (e.g., *I believed [what he told me]*.) |
| f\_24\_infinitives | Infinitives |
| f\_25\_present\_participle | Present participial adverbial clauses (e.g., *[Stuffing his mouth with cookies], Joe ran out the door*.) |
| f\_26\_past\_participle | Past participial adverbial clauses (e.g., *[Built in a single week], the house would stand for fifty years*.) |
| f\_27\_past\_participle\_whiz | Past participial postnominal (reduced relative) clauses (e.g., *the solution [produced by this process]*) |
| f\_28\_present\_participle\_whiz | Present participial postnominal (reduced relative) clauses (e.g., *the event [causing this decline[*) |
| f\_29\_that\_subj | *that* relative clauses on subject position (e.g., *the dog [that bit me]*) |
| f\_30\_that\_obj | *that* relative clauses on object position (e.g., *the dog [that I saw]*) |
| f\_31\_wh\_subj | *wh*- relatives on subject position (e.g., *the man [who likes popcorn]*) |
| f\_32\_wh\_obj | *wh*- relatives on object position (e.g., *the man [who Sally likes]*) |
| f\_33\_pied\_piping | Pied-piping relative clauses (e.g., *the manner [in which he was told]*) |
| f\_34\_sentence\_relatives | Sentence relatives (e.g., *Bob likes fried mangoes, [which is the most disgusting thing I've ever heard of]*.) |
| f\_35\_because | Causative adverbial subordinator (*because*) |
| f\_36\_though | Concessive adverbial subordinators (*although*, *though*) |
| f\_37\_if | Conditional adverbial subordinators (*if*, *unless*) |
| f\_38\_other\_adv\_sub | Other adverbial subordinators (e.g., *since*, *while*, *whereas*) |
| - | **I. Prepositional phrases, adjectives and adverbs** |
| f\_39\_prepositions | Total prepositional phrases |
| f\_40\_adj\_attr | Attributive adjectives (e.g., *the [big] horse*) |
| f\_41\_adj\_pred | Predicative adjectives (e.g., *The horse is [big]*.) |
| f\_42\_adverbs | Total adverbs |
| - | **J. Lexical specificity** |
| f\_43\_type\_token | Type-token ratio (including punctuation) |
| f\_44\_mean\_word\_length | Average word length (across tokens, excluding punctuation) |
| - | **K. Lexical classes** |
| f\_45\_conjuncts | Conjuncts (e.g., *consequently*, *furthermore*, *however*) |
| f\_46\_downtoners | Downtoners (e.g., *barely*, *nearly*, *slightly*) |
| f\_47\_hedges | Hedges (e.g., *at about*, *something like*, *almost*) |
| f\_48\_amplifiers | Amplifiers (e.g., *absolutely*, *extremely*, *perfectly*) |
| f\_49\_emphatics | Emphatics (e.g., *a lot*, *for sure*, *really*) |
| f\_50\_discourse\_particles | Discourse particles (e.g., sentence-initial *well*, *now*, *anyway*) |
| f\_51\_demonstratives | Demonstratives |
| - | **L. Modals** |
| f\_52\_modal\_possibility | Possibility modals (*can*, *may*, *might*, *could*) |
| f\_53\_modal\_necessity | Necessity modals (*ought*, *should*, *must*) |
| f\_54\_modal\_predictive | Predictive modals (*will*, *would*, *shall*) |
| - | **M. Specialized verb classes** |
| f\_55\_verb\_public | Public verbs (e.g., *assert*, *declare*, *mention*) |
| f\_56\_verb\_private | Private verbs (e.g., *assume*, *believe*, *doubt*, *know*) |
| f\_57\_verb\_suasive | Suasive verbs (e.g., *command*, *insist*, *propose*) |
| f\_58\_verb\_seem | *seem* and *appear* |
| - | **N. Reduced forms and dispreferred structures** |
| f\_59\_contractions | Contractions |
| f\_60\_that\_deletion | Subordinator that deletion (e.g., *I think [he went]*.) |
| f\_61\_stranded\_preposition | Stranded prepositions (e.g., *the candidate that I was thinking [of]*) |
| f\_62\_split\_infinitve | Split infinitives (e.g., *He wants [to convincingly prove] that* …) |
| f\_63\_split\_auxiliary | Split auxiliaries (e.g., *They [were apparently shown] to* …) |
| - | **O. Co-ordination** |
| f\_64\_phrasal\_coordination | Phrasal co-ordination (N and N; Adj and Adj; V and V; Adv and Adv) |
| f\_65\_clausal\_coordination | Independent clause co-ordination (clause-initial *and*) |
| - | **P. Negation** |
| f\_66\_neg\_synthetic | Synthetic negation (e.g., *No answer is good enough for Jones*.) |
| f\_67\_neg\_analytic | Analytic negation (e.g., *That isn't good enough*.) |

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests on [GitHub](https://github.com/browndw/pseudobibeR).

### Reporting Issues

When reporting bugs or requesting features, please include:

- A minimal reproducible example
- Your R version and package versions
- The parsing pipeline used (spaCy/udpipe)

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Related Resources

- [Biber (1985) original paper](https://doi.org/10.1515/ling.1985.23.2.337)
- [quanteda](https://quanteda.io/) - Text analysis framework used internally
- [spaCy](https://spacy.io/) - Industrial-strength NLP library  
- [udpipe](https://bnosac.github.io/udpipe/en/) - NLP toolkit for R
