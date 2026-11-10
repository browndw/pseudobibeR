# pseudobibeR: Aggregate Counts of Linguistic Features

[![R-CMD-check](https://github.com/browndw/pseudobibeR/workflows/R-CMD-check/badge.svg)](https://github.com/browndw/pseudobibeR/actions)
[![Tests](https://github.com/browndw/pseudobibeR/workflows/Tests/badge.svg)](https://github.com/browndw/pseudobibeR/actions)
[![CRAN status](https://www.r-pkg.org/badges/version/pseudobibeR)](https://CRAN.R-project.org/package=pseudobibeR)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/pseudobibeR)](https://cran.r-project.org/package=pseudobibeR)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The **pseudobibeR** package counts the 67 lexicogrammatical and functional
features described by Biber (1985, 1988) in English texts. These features
(tense, pronouns, passives, relative clauses, modals, negation and many more)
are widely used to compare registers, genres and text types with
multidimensional analysis.

Companion packages apply the same features to Spanish
([pseudobibeR.es](https://github.com/browndw/pseudobibeR.es)) and French
([pseudobibeR.fr](https://github.com/browndw/pseudobibeR.fr)), with the same
interface and the same feature numbers.

## Overview

The package does not tag texts itself. It reads the output of a parser,
[udpipe](https://bnosac.github.io/udpipe/en/) or
[spaCy](https://spacy.io/) (via [spacyr](https://spacyr.quanteda.io/)), and
counts features from the parts of speech and syntactic dependencies it
provides. The counts are only as good as the parse: unusual spelling, informal
punctuation or very specialized language can lower accuracy.

## Installation

Install the released version from CRAN:

```r
install.packages("pseudobibeR")
```

Or the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("browndw/pseudobibeR")
```

## Quick start

A typical workflow has three steps: read and clean the texts, parse them, and
count the features.

```r
library(readtext)
library(quanteda)
library(udpipe)
library(pseudobibeR)

# 1. Read the texts and normalize typographic quotes (’ -> ')
docs <- readtext("corpus/*.txt", encoding = "UTF-8")
docs$text <- utf8::utf8_normalize(docs$text, map_quote = TRUE)
corp <- corpus(docs)

# 2. Parse with udpipe (the model is downloaded once)
model <- udpipe_download_model(language = "english")
ud_model <- udpipe_load_model(model$file_model)
parsed <- udpipe_annotate(ud_model, x = as.character(corp), doc_id = docnames(corp))

# 3. Count the features: one row per document
features <- biber(parsed)
```

`utf8::utf8_normalize()` converts curly apostrophes and quotes to straight
ones, so that contractions such as *don’t* are tokenized like *don't*.
`biber()` only sees the parsed tokens, so this step belongs before parsing.

### Using spaCy instead of udpipe

spaCy needs Python with an English model installed (for example
`en_core_web_sm`):

```r
library(spacyr)
spacy_initialize(model = "en_core_web_sm")
parsed <- spacy_parse(corp, pos = TRUE, tag = TRUE, dependency = TRUE, entity = FALSE)
features <- biber(parsed)
spacy_finalize()
```

Both parsers work with the same detectors, but their accuracy differs on
individual constructions.

### Trying it with sample data

```r
library(pseudobibeR)
biber(udpipe_samples)
biber(spacy_samples)
```

## Understanding the output

`biber()` returns a data frame with one row per document: a `doc_id` column
followed by the feature columns.

- **Rates per 1,000 words.** By default (`normalize = TRUE`) counts are
  divided by the number of words in the document and multiplied by 1,000, so
  documents of different lengths can be compared. Words exclude punctuation
  and numbers written in digits. Use `normalize = FALSE` for raw counts.
- **Two measures are not counts.** f_43 is the type/token ratio (lexical
  diversity) and f_44 is the mean word length in letters; neither is
  normalized. The `measure` argument selects the type/token ratio: `"MATTR"`
  (default), `"TTR"`, `"CTTR"`, `"MSTTR"` or `"none"` (which omits f_43).
  MATTR needs at least 200 words per document; if any document is shorter,
  plain TTR is used for every document and a message is shown.

## Linguistic features

The 67 features are grouped into the 16 categories used by Biber. Brackets in
the examples mark what is counted.

| Category | Features | Description |
|---|---|---|
| A. Tense and aspect | f_01–f_03 | Past tense, perfect aspect, present tense |
| B. Place and time adverbials | f_04–f_05 | Spatial and temporal adverbials |
| C. Pronouns and pro-verbs | f_06–f_12 | Personal, demonstrative and indefinite pronouns; pro-verb *do* |
| D. Questions | f_13 | Direct *wh*-questions |
| E. Nominal forms | f_14–f_16 | Nominalizations, gerunds, other nouns |
| F. Passives | f_17–f_18 | Agentless and *by*-passives |
| G. Stative forms | f_19–f_20 | *be* as main verb, existential *there* |
| H. Subordination | f_21–f_38 | Complement, relative, participial and adverbial clauses |
| I. Prepositional phrases, adjectives and adverbs | f_39–f_42 | |
| J. Lexical specificity | f_43–f_44 | Type/token ratio, word length |
| K. Lexical classes | f_45–f_51 | Conjuncts, downtoners, hedges, amplifiers, emphatics… |
| L. Modals | f_52–f_54 | Possibility, necessity and predictive modals |
| M. Specialized verb classes | f_55–f_58 | Public, private and suasive verbs; *seem/appear* |
| N. Reduced forms and dispreferred structures | f_59–f_63 | Contractions, deletions, split constructions |
| O. Coordination | f_64–f_65 | Phrasal and clausal coordination |
| P. Negation | f_66–f_67 | Synthetic and analytic negation |

### Feature list

| Feature | Description | Examples |
|---|---|---|
| **A. Tense and aspect** | | |
| `f_01_past_tense` | Past tense | *She [walked] home.* |
| `f_02_perfect_aspect` | Perfect aspect | *She [has] finished.* |
| `f_03_present_tense` | Present tense | *She [walks] home.* |
| **B. Place and time adverbials** | | |
| `f_04_place_adverbials` | Place adverbials | *above, beside, outdoors* |
| `f_05_time_adverbials` | Time adverbials | *early, instantly, soon* |
| **C. Pronouns and pro-verbs** | | |
| `f_06_first_person_pronouns` | First-person pronouns | *I, me, we, our* |
| `f_07_second_person_pronouns` | Second-person pronouns | *you, your* |
| `f_08_third_person_pronouns` | Third-person personal pronouns (excluding *it*) | *he, she, they, them* |
| `f_09_pronoun_it` | Pronoun *it* | *[It] is raining.* |
| `f_10_demonstrative_pronoun` | *that, this, these, those* used as pronouns | *[That] is ridiculous.* |
| `f_11_indefinite_pronouns` | Indefinite pronouns | *anybody, nothing, someone* |
| `f_12_proverb_do` | Pro-verb *do* | *She said she would, and she [did].* |
| **D. Questions** | | |
| `f_13_wh_question` | Direct *wh*-questions | *[What] did you see?* |
| **E. Nominal forms** | | |
| `f_14_nominalizations` | Nominalizations (ending in *-tion, -ment, -ness, -ity*) | *the [development] of the [proposition]* |
| `f_15_gerunds` | Gerunds (*-ing* forms used as nouns) | *[Running] is good exercise.* |
| `f_16_other_nouns` | Other nouns | *the [house], [London]* |
| **F. Passives** | | |
| `f_17_agentless_passives` | Passives without an agent | *The task [was done].* |
| `f_18_by_passives` | Passives with a *by*-phrase | *The task was done [by] Steve.* |
| **G. Stative forms** | | |
| `f_19_be_main_verb` | *be* as main verb | *The horse [is] big.* |
| `f_20_existential_there` | Existential *there* | *[There] is a problem.* |
| **H. Subordination** | | |
| `f_21_that_verb_comp` | *that*-clauses after a verb | *I said [that] he went.* |
| `f_22_that_adj_comp` | *that*-clauses after an adjective | *I'm glad [that] you like it.* |
| `f_23_wh_clause` | *wh*-clauses | *I believed [what] he told me.* |
| `f_24_infinitives` | Infinitives | *She wants [to leave].* |
| `f_25_present_participle` | Present participial adverbial clauses | *[Stuffing] his mouth with cookies, Joe ran out the door.* |
| `f_26_past_participle` | Past participial adverbial clauses | *[Built] in a single week, the house would stand for fifty years.* |
| `f_27_past_participle_whiz` | Past participial reduced relatives | *the solution [produced] by this process* |
| `f_28_present_participle_whiz` | Present participial reduced relatives | *the event [causing] this decline* |
| `f_29_that_subj` | *that* relatives in subject position | *the dog [that] bit me* |
| `f_30_that_obj` | *that* relatives in object position | *the dog [that] I saw* |
| `f_31_wh_subj` | *wh*-relatives in subject position | *the man [who] likes popcorn* |
| `f_32_wh_obj` | *wh*-relatives in object position | *the man [who] Sally likes* |
| `f_33_pied_piping` | Pied-piping relatives (preposition + relative) | *the manner [in which] he was told* |
| `f_34_sentence_relatives` | Sentence relatives | *Bob likes fried mangoes, [which] is disgusting.* |
| `f_35_because` | Causal subordinator *because* | *I stayed [because] it rained.* |
| `f_36_though` | Concessive subordinators *although, though* | *[Although] it rained, we went.* |
| `f_37_if` | Conditional subordinators *if, unless* | *[If] it rains, we'll stay.* |
| `f_38_other_adv_sub` | Other adverbial subordinators | *since, while, whereas* |
| **I. Prepositional phrases, adjectives and adverbs** | | |
| `f_39_prepositions` | Prepositional phrases | *[on] the table* |
| `f_40_adj_attr` | Attributive adjectives | *the [big] horse* |
| `f_41_adj_pred` | Predicative adjectives | *The horse is [big].* |
| `f_42_adverbs` | Other adverbs (not counted as place or time adverbials, downtoners, hedges or amplifiers) | *She ran [quickly].* |
| **J. Lexical specificity** | | |
| `f_43_type_token` | Type/token ratio (punctuation and numbers excluded) | — |
| `f_44_mean_word_length` | Mean word length in letters | — |
| **K. Lexical classes** | | |
| `f_45_conjuncts` | Conjuncts | *consequently, furthermore, however* |
| `f_46_downtoners` | Downtoners | *barely, nearly, slightly* |
| `f_47_hedges` | Hedges | *at about, something like, maybe* |
| `f_48_amplifiers` | Amplifiers | *absolutely, extremely, perfectly* |
| `f_49_emphatics` | Emphatics | *a lot, for sure, really* |
| `f_50_discourse_particles` | Discourse particles | sentence-initial *well, now, anyway* |
| `f_51_demonstratives` | Demonstratives before a noun | *[this] book* |
| **L. Modals** | | |
| `f_52_modal_possibility` | Possibility modals | *can, may, might, could* |
| `f_53_modal_necessity` | Necessity modals | *ought, should, must* |
| `f_54_modal_predictive` | Predictive modals | *will, would, shall* |
| **M. Specialized verb classes** | | |
| `f_55_verb_public` | Public verbs | *assert, declare, mention* |
| `f_56_verb_private` | Private verbs | *assume, believe, doubt, know* |
| `f_57_verb_suasive` | Suasive verbs | *command, insist, propose* |
| `f_58_verb_seem` | *seem* and *appear* | *She [seems] tired.* |
| **N. Reduced forms and dispreferred structures** | | |
| `f_59_contractions` | Contractions | *don't, I'll, she's* |
| `f_60_that_deletion` | Subordinator *that* deletion | *I think [he went].* |
| `f_61_stranded_preposition` | Stranded prepositions | *the candidate that I was thinking [of]* |
| `f_62_split_infinitive` | Split infinitives (negation alone is not counted) | *He wants [to convincingly prove] that…* |
| `f_63_split_auxiliary` | Split auxiliaries | *They [were apparently shown] to…* |
| **O. Coordination** | | |
| `f_64_phrasal_coordination` | Phrasal coordination (N and N, Adj and Adj, V and V, Adv and Adv) | *apples [and] pears* |
| `f_65_clausal_coordination` | Independent clause coordination | *It rained, [and] we stayed home.* |
| **P. Negation** | | |
| `f_66_neg_synthetic` | Synthetic negation | *[No] answer is good enough for Jones.* |
| `f_67_neg_analytic` | Analytic negation | *That is[n't] good enough.* |

## Comparing languages

The feature numbers (`f_01` … `f_67`) refer to the same feature in the
English, Spanish and French packages. The Spanish and French packages use
column names that describe what they count in their language; call
`biber(parsed, feature_names = "shared")` there, or set
`options(pseudobibeR.feature_names = "shared")`, to get the English-style names
used here. The
[cross-linguistic feature table](CROSS_LINGUISTIC_FEATURES.md) shows how each
feature is realized in the three languages.

## Further documentation

- [CROSS_LINGUISTIC_FEATURES.md](CROSS_LINGUISTIC_FEATURES.md): the features in
  English, Spanish and French.
- [NEWS.md](NEWS.md): changes between versions.
- [CONTRIBUTING.md](CONTRIBUTING.md): reporting issues, test data and running
  tests.

## Citation

Please cite Biber's original work and this package:

> Biber, D. (1985). Investigating macroscopic textual variation through
> multifeature/multidimensional analyses. *Linguistics*, 23(2), 337–360.
> <https://doi.org/10.1515/ling.1985.23.2.337>

> Biber, D. (1988). *Variation across speech and writing*. Cambridge
> University Press. <https://doi.org/10.1017/CBO9780511621024>

> Brown, D. W., & Reinhart, A. (2024). *pseudobibeR: Aggregate counts of
> linguistic features*. R package. <https://github.com/browndw/pseudobibeR>

## License

MIT © the package authors. See [LICENSE](LICENSE).
