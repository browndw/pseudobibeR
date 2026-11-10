# Cross-language alignment: findings and decision log

Review date: 2026-11-03  
Status: Spanish resource isolation implemented and verified.
Corpus-wide lexical-diversity selection implemented and verified.
Tagged, filtered lexical-diversity input implemented and verified.
Other alignment decisions and implementations remain open.

## Purpose and scope

Make `pseudobibeR.es`, `pseudobibeR.fr`, and English `pseudobibeR`
comparable in their APIs, pipelines, feature definitions, counting units,
normalization, and audit behavior, allowing genuine linguistic differences.

Comparable measurement does not require identical vectors for translations.
For example, Spanish subject omission can legitimately change pronoun counts.
Loading order, duplicate counting, punctuation denominators, and unrelated
documents changing a metric are not linguistic differences.

This review compared the Spanish 0.1.0 working tree with the then-included French
reference, version 0.0.0.94. It does not establish the state of the latest French
upstream. Selected English normalization and lexical-metric code was also
inspected, but English did not receive a full feature-by-feature review.

Controlled annotation probes were run in separate R processes to isolate
measurement behavior from parser errors and package-resource interference.
Package coexistence was then tested separately using installed local copies
in both loading orders and with namespace-only calls.

No package source was changed during the comparison. Existing Spanish spaCy
work predates this alignment record.

## How to maintain this document

- Keep finding IDs and decision IDs stable.
- Append dated decisions; do not silently overwrite earlier reasoning.
- Only decisions marked **Accepted** represent agreed choices.
- Distinguish current behavior, a proposed target, implementation, and validation.
- Do not mark an issue resolved until its specific regression is tested.
- Copy this document to the French repository after the Spanish work, preserving
  IDs and recording the subsequent French changes here.

Source locations below are repository-qualified identifiers, not machine-local
paths. The French reference was nested under `pseudobibeR.fr/` during review
and has since been removed from the Spanish project. Interpret each location
relative to its named repository. Line numbers refer to the reviewed snapshot
and may move.

## Findings

### F-01. Package resources depend on attachment order

**Priority:** blocker for reliable cross-language use.  
**Affected:** Spanish and French; English coexistence was not tested.
**Resolution:** Spanish fixed and verified on 2026-11-03; French remains open.
The results below describe the original review, before the Spanish fix.

Installed-package probes gave these raw private-verb counts:

| Probe | Before loading the other language | After loading the other language |
|---|---:|---:|
| French `penser`, using `pseudobibeR.fr::biber()` | 2 | 0 |
| Spanish `pensar`, using `pseudobibeR.es::biber()` | 1 | 0 |

The French count of 2 before interference is a separate defect, F-03.
Loading Spanish first and French second also produced missing Spanish
word-list warnings.

Namespace-only calls, without attaching either package, failed:

- Spanish: `object 'word_lists' not found`.
- French: `object 'dict' not found`.

The pipelines refer to package datasets without reliably binding the resources
to their owning package. Explicitly namespacing the public function is therefore
insufficient. Ordinary masking of bare function names is expected in R;
namespaced functions silently using another language's resources is not.

Sources: `pseudobibeR.es/R/parse_functions.R:10`;
`pseudobibeR.fr/R/parse_functions.R:379`;
`pseudobibeR.fr/R/audit_features.R:1895`.

Required outcome: each package consistently uses its own resources, independent
of attachment order, including through `biber()` and `audit_features()`.
Search every resource consumer, not just the first failing lookup.

### F-02. Normalization denominators differ

One preposition in an annotation containing three word rows and punctuation
produced the same raw count, 1, but different rates:

| French | Spanish |
|---:|---:|
| 250 per 1,000 | 333.3333 per 1,000 |

French reconstructs and re-tokenizes text, compounds dictionary expressions, and
uses the resulting token count. Punctuation remained in this controlled probe.
Spanish uses the supplied word-token rows, excluding punctuation, symbols,
spaces, multiword-token containers, and empty nodes; function words remain.

This makes French rates sensitive to punctuation and dictionary compounding.
English instead counts a tagged surface-token stream after its own punctuation
and numeric filtering. It does not use the French reconstruction/compounding
path. The English denominator must be assessed separately rather than inferred
from the French behavior; see the appended English token-preparation finding.

Sources: `pseudobibeR.fr/R/parse_functions.R:470-484,912-918`;
`pseudobibeR.es/R/parse_functions.R:87`;
`pseudobibeR.es/R/features_lexical_complexity.R`.

### F-03. Dictionary and grammatical paths can count one occurrence twice

A single infinitive private verb yielded:

| French `penser` | Spanish `pensar` |
|---:|---:|
| 2 | 1 |

French adds dictionary and structural results for several specialized
verb/modal features without occurrence-level reconciliation. Spanish reconciles
the evidence before counting. French auditing does not turn the duplicate into
two independently justified occurrences.

Sources: `pseudobibeR.fr/R/parse_functions.R:769-795`;
`pseudobibeR.es/R/parse_functions.R:63-82`.

### F-04. Sentence-local IDs can collapse distinct constructions

Two perfect constructions in separate sentences, with token IDs restarting,
yielded French f_02 = 1 and Spanish f_02 = 2.

French perfect deduplication omits sentence ID from its key. A similar omission
exists in passive detection and requires a dedicated passive regression.
For the perfect probe, the French audit summed to 2 while `biber()` reported 1.

Sources: `pseudobibeR.fr/R/features_tense_pronouns.R:46`;
`pseudobibeR.fr/R/features_passive.R:26,36`.

Required invariant: token and construction identity must respect document and
sentence boundaries.

### F-05. Lexical diversity can depend on unrelated documents

**Decision clarification (2026-11-03):** document independence is not the accepted
requirement for measure selection. The original package deliberately uses a
corpus-wide fallback so that the output does not mix different statistics.
The user rejected the earlier per-document proposal. The table below preserves
the initial review results, not the current Spanish behavior.
Spanish now follows D-06, verified on 2026-11-03. French/English explicit
alternative-measure handling remains a handoff item.

French uses the shortest document to decide whether to replace the requested
measure with TTR for the entire corpus, including a CTTR request.

| Measure for the same long document | French alone | French with a short document | Spanish before alignment, either corpus |
|---|---:|---:|---:|
| MATTR | 0.01702128 | 0.008333333 | 0.01702128 |
| CTTR | 0.09128709 | 0.008333333 | 0.09128709 |

At review time, Spanish applied the under-200-token fallback per document, only
for MATTR and MSTTR. French also computes diversity over re-tokenized/compounded text rather
than the original supplied surface tokens. Selected English code shares the
global fallback.

Sources: `pseudobibeR.fr/R/parse_functions.R:923`;
`pseudobibeR.es/R/parse_functions.R:96-110`.

### F-06. Mean word length excludes accented French words

For `un café`, French returned 2 and Spanish returned 3. French's ASCII-only word filter
excluded `café`; Spanish included both words using Unicode character lengths.
Rounding and the eligible word population also need a common specification.
Selected English code uses the same ASCII-only filter.

Sources: `pseudobibeR.fr/R/parse_functions.R:934-940`;
`pseudobibeR.es/R/features_lexical_complexity.R:5-11`.

### F-07. Shared feature identifiers do not ensure shared definitions

These are scientific mapping decisions as well as implementation issues.
The French reference must not automatically be treated as the correct oracle.

| Feature | French reference | Spanish | Alignment question |
|---|---|---|---|
| f_01 / f_03 tense | VERB-based; present includes subjunctive and excludes AUX | Finite VERB/AUX; present indicative | Which finite verbs, auxiliaries, and moods belong? |
| f_39 prepositions | Counts qualifying ADP constituents | Recognized compound preposition counts once | ADP tokens or prepositional constructions? |
| f_42 adverbs | Excludes several specialized adverb classes | At review: all ADV. D-15 now implements the five specified exclusions | Accepted Biber definition; companion exclusions still need alignment |
| f_54 prediction | Selected periphrases/forms; ordinary future coverage incomplete | Finite future, conditional, and validated `ir a` | Which functional predictive constructions belong? |
| f_29-f_32 relatives | Separate marker-family bins | f_31/f_32 merged into f_29/f_30 | Shared bins, aggregation, or explicit language-specific mapping? |
| f_35 causals | Broad inventory, including `car`, `puisque`, `comme`, `parce que` | Narrow `porque` target | Narrow lexical equivalent or broad causal function? |
| f_21 / f_22 complements | POS adjacency plays a central role | Dependency/clause structure | Common grammatical target and attachment rules? |
| f_40 / f_41 adjectives | More adjacency-based | Dependency roles and coordination inheritance | Align grammatical coverage, not just surface position |
| f_64 / f_65 coordination | Excludes verbal/AUX coordination from phrasal bin | Includes shared-subject verbal/copular predicates | Phrase/clause boundary and explicit-subject criteria |
| Stance and lexical classes | Positional disambiguation for some ambiguous forms | More surface-inventory overlap | Shared disambiguation and cross-feature overlap policy |
| f_66 / f_67 negation | Analytic detector requires configured negative adverb plus `ne` sharing a head | Markers counted independently; D-17 repairs constituent scope and clear f_67 exclusions | Preserve noun counts; lexical inventories and negative concord remain pending |

Additional controlled results:

- `vienne` / `venga`: present-tense count 1 / 0.
- AUX copula `est` / `es`: present-tense count 0 / 1.
- ADV `très` / `muy`: adverb count 0 / 1.
- `à cause de` / `a causa de`: preposition count 2 / 1.
- `viendra` / `vendrá`: predictive count 0 / 1.
- Postnominal `livre utile` / `libro util`, with `amod`: attributive adjective
  count 0 / 1.
- Hyphenated NOUN: other-noun count 0 / 1.

The postnominal adjective result is a detection gap in a construction both
languages possess, not evidence that French lacks that grammatical category.

Sources: each repository's `R/features_tense_pronouns.R`,
`R/features_modals_verbs.R`, `R/features_subordination.R`,
`R/features_coordination_negation.R`, and French `R/features_stance.R`.
Spanish clause/relative detectors are in `R/features_subordination.R`.

### F-08. Compatibility zeros mix different meanings

At the initial review, Spanish forced these ten features to zero:

`f_09`, `f_12`, `f_15`, `f_28`, `f_31`, `f_32`, `f_59`, `f_60`,
`f_61`, `f_62`.

Accepted D-21 activates f_09 with predicate-based impersonal/expletive coverage;
D-22 activates f_12 for anaphoric hacer; D-23 activates f_15 for clear noun-like
nominal infinitives. D-25 separates f_31/f_32 from que relatives with exclusive
f_33 precedence under D-24. D-26 activates colloquial reductions in f_59,
and D-27 activates bounded complement reduction in f_60. D-28 activates
adverb-interrupted preposition-infinitive units in f_62. D-31 activates bounded
resumptive prepositional relatives in f_61. Only f_28 remains a compatibility zero.
See the implementation entries below.

They must not all be interpreted as observed absence or linguistic impossibility.
In particular:

- f_31/f_32 are merged elsewhere, not independently measured absences.
- French f_15 counts verbal gerunds/present participles, whereas the Spanish
  zero rests on a nominal-gerund interpretation.
- French `faire` pro-verbs and possible Spanish `hacer` counterparts require an
  explicit functional mapping for f_12.
- Complementizer omission, f_60, needs a language-sensitive definition rather
  than an unconditional inference of impossibility.
- French f_61 appears to count prepositions before relative pronouns, not true
  preposition stranding. Do not copy that rule into Spanish to populate a column.
- French f_62 counts preposition + adverb + infinitive; whether this is an
  appropriate counterpart of an English split infinitive remains unresolved.

Create a feature-by-language mapping that distinguishes measured zero,
structural non-applicability, merged coverage, and unsupported detection.
Changing output values or missingness representation requires a separate
compatibility decision.

Sources: `pseudobibeR.es/R/feature_categories.R:95-125`;
French `R/features_tense_pronouns.R`,
`R/features_coordination_negation.R`, and `R/features_subordination.R`.

### F-09. API, output, audit, and sample-data contracts differ

Aligned: both export `biber()` and `audit_features()`, have the same main
`biber()` arguments/measure choices, support native spaCy and UDPipe inputs,
and share feature identifiers and feature-column order.

Remaining differences:

| Surface | French | Spanish |
|---|---|---|
| Ordinary data frame input | No matching `biber()` method | Accepted with a recognized schema |
| Document order | Sorted IDs | First appearance |
| Output metadata | No Spanish-style token-count columns | Adds `n_tokens`, `n_lex_tokens` |
| Audit category aliases | Includes English aliases such as `Modals` | Category letters/full Spanish labels |
| Audit granularity | Exact matches mixed with sentence-level fallback | One exact evidence row per occurrence, `count = 1` |
| Public parser samples | Includes `spacy_samples` | No parallel public spaCy dataset yet |

For two first-person pronouns in one sentence, French returned one audit row
with count 2; Spanish returned two exact rows with count 1 each. Counts can agree
while audit meanings differ. F-04 additionally demonstrates actual count/audit
disagreement.

With `measure = "none"`, the probes returned 67 French columns and 69 Spanish
columns: `doc_id`, the same 66 feature columns, and the two Spanish metadata
columns. The lexical-diversity column is omitted in both.

Sources: both `R/audit_features.R` files; French
`R/audit_features.R:85-105,1883-1968`; Spanish `R/parse_functions.R`.

### F-10. Parser equivalence has methodological limits

Both Spanish parser routes work, but model errors and tokenization differences
remain. For example, spaCy may retain contractions or enclitics as single words
where UDPipe supplies expanded word rows. The extractor does not invent a
decomposition.

Record parser/model versions and distinguish:

1. identical intended measurement rules;
2. equivalent extraction on controlled annotations;
3. model-dependent results on real text.

Neither passing package checks nor matching translated examples establishes
corpus-level precision/recall, factor equivalence, or complete scientific
comparability. Release automation is not a measurement-validity certification.

## Decision register

| ID | Status | Decision or open question |
|---|---|---|
| D-01 | Accepted | Use equivalent APIs, pipelines, counting rules, and functional definitions across the package family, allowing genuine linguistic differences. |
| D-02 | Accepted | Normalize per 1,000 supplied UD word tokens, including function words and excluding punctuation, symbols, spaces, MWT containers, and empty nodes. This was agreed during the earlier Spanish refactor; do not change it merely to mimic legacy code. |
| D-03 | Accepted | Keep a portable, appendable decision record; implement agreed Spanish changes first, then transfer this document to the French repository for its fixes. |
| D-04 | Accepted | Require resource isolation, namespace-only operation, and attachment-order invariance across all resource consumers. Resolve F-01 first. Accepted on 2026-11-03; see appended implementation entry. |
| D-05 | Proposed | Count one occurrence once within a feature, even when dictionary and grammatical paths overlap; use document/sentence-aware identity and reconcile audits with raw counts. Cross-feature overlap is a separate decision. |
| D-06 | Accepted | Use one lexical-diversity measure per supplied corpus. Default MATTR falls back to TTR for all documents if any document has fewer than 200 diversity tokens. Honor an explicitly selected alternative (TTR, CTTR, MSTTR) for every document; never mix measures. Accepted on 2026-11-03; supersedes the earlier per-document proposal. The retained input definition is now specified by D-13; application in the companion packages remains a handoff item. |
| D-07 | Proposed | Use Unicode-aware mean word length; standardize eligible tokens and rounding. |
| D-08 | Pending | Resolve F-07 feature definitions, inventories, and allowed cross-feature overlaps before changing their scientific meanings. |
| D-09 | Partially resolved | Relative marker/role mapping and exclusive pied-piping are accepted under D-24/D-25. Classification of other compatibility zeros and further scientific refinements remain pending. |
| D-10 | Pending | Standardize document order, metadata columns, data-frame support, category aliases, audit schema, and public sample-data expectations. |
| D-11 | Proposed | Preserve original supplied word-row denominators across parser routes, disclose tokenization/model differences, and test controlled annotations separately from live models. |
| D-12 | Accepted | Keep French language data and the temporary French reference checkout out of the Spanish repository. Remove the intentional reference too, as confirmed on 2026-11-03. Do not remove valid Spanish resources or comparison documentation merely because they mention French. |
| D-13 | Accepted | Adopt the English lower-case surface-plus-tag type definition for Spanish lexical diversity, not lemmas or untagged surfaces. Exclude punctuation/symbol/space inputs and English-style numeric matches before calculation and the 200-token test. Do not compound dictionary expressions. Preserve corpus-wide selection and explicit alternatives. Accepted on 2026-11-03; French follows later. See the implementation entry for native tag fallback and filtered-empty documents. |
| D-14 | Accepted | Treat the older, more-tested English implementation as a baseline, not an unquestionable specification. Investigate suspected errors, agree the best-supported rule, and document evidence and rationale. Implement accepted Spanish fixes first; record English and French follow-up for later work in their repositories. Accepted on 2026-11-05. |
| D-15 | Accepted | Define f_42 as a residual category. The count for total adverbs excludes those adverbs counted as instances of hedges, amplifiers, downtoners, amplifiers, place adverbials, and time adverbials. |
| D-16 | Pending | Decide how f_42 maps negative particles across parser tag schemes. English counts an RB-tagged negative even when UPOS is PART; Spanish currently excludes PART from f_42 while accepting valid analytic negation in f_67. Proposed adaptation: include only validated analytic-negative PART occurrences, not arbitrary PART tokens or nonadverbial uses of `no`. |
| D-17 | Accepted | Fix f_67 scope and clear exclusions; leave f_66 and f_42 unchanged pending separate decisions. Count scoped ADV/PART `no` on ordinary constituents, preserving nouns, and exclude identifiable replies, nominalized/quoted standalone `no`, and `no obstante`. Do not guess expletive `no` or non-negative `no más` readings. Accepted on 2026-11-07. |
| D-18 | Accepted | Preserve the user-specified Tottie-based distinction in Spanish and French: analytic negation is expressed by a standalone grammatical negative particle; synthetic negation incorporates negative meaning into a lexical item, including negative determiners, pronouns, adverbs, or coordinators. Classify language-specific functions, not English translations or preverbal/postverbal position. Exact inventories and concord counting still require agreement. Accepted on 2026-11-07. |
| D-19 | Accepted | Prioritize theoretical linguistic alignment, parallel coverage, and closing obvious gaps/errors, in that order. Complete a reasonably reliable Spanish baseline first; apply discovered fixes to French and English next; revisit idiomatic negation, linguistic ambiguities, and other edge cases afterwards. Record limitations without making exhaustive disambiguation a completion prerequisite. Scientific definition/counting changes still require agreement. Accepted on 2026-11-07. |
| D-20 | Accepted | Retain the Spanish synthetic inventory (ninguno/forms, nadie, nada, nunca/jamás, tampoco, negative ni) and analytic grammatical no. Count word occurrences including concord: No vino nadie gives f_66 = 1/f_67 = 1; ni...ni gives f_66 = 2. Repair demonstrated ordinary f_66 coverage/nominal-use errors without retagging tokens or changing other features. Defer idioms, ambiguous cases, and additional classes such as sin; leave f_42 unchanged. Explicitly approved on 2026-11-07. |
| D-21 | Accepted | Implement Spanish f_09 with the French impersonal/expletive scope, counting one occurrence per identified impersonal predicate anchored on an existing word. Cover ordinary weather and clearly impersonal clausal constructions; exclude personal pro-drop, generic missing-subject/complement heuristics, and existential haber (f_20). Do not invent null tokens or count UD empty nodes. Defer ambiguous se; leave neuter lo, existing pronoun features, denominators, and French code unchanged. Explicitly approved before implementation. |
| D-22 | Accepted | Activate Spanish f_12 for anaphoric lexical hacer with action-proform lo (including enclitics) or lo mismo, once per supplied predicate word. Exclude auxiliary/copular, causative verbal-complement, identifiable reflexive and overt nominal-object contexts. Bare lo remains a structural candidate without semantic antecedent resolution. Preserve clitic/noun counts, source annotations, tokenization, denominators, other features and French code. The user explicitly approved this bounded baseline on 2026-11-07. |
| D-23 | Accepted | Activate Spanish f_15 for clear noun-like nominal infinitives only, not all infinitival clauses functioning as subjects. Exclude qualifying word occurrences from f_24 and residual noun counts; keep derived, infinitival and residual noun categories disjoint by identity, not scalar subtraction. Preserve verbal infinitival clauses, supplied annotations, tokenization, denominators and metrics. The user explicitly selected this scope on 2026-11-07. |
| D-24 | Accepted | Pied-piping f_33 must be exclusive of the other relative categories, not an overlapping structural dimension. Preserve existing Spanish f_33 precedence over f_29/f_30 and require occurrence-level exclusions when activating f_31/f_32. The user selected no overlap on 2026-11-08. This settles the overlap policy only; the marker-family partition and role-disambiguation rules still require agreement under D-09. |
| D-25 | Accepted | Implement the proposed four-way nominal-relative partition: que subject/object in f_29/f_30, quien/cual forms subject/object in f_31/f_32. Retain exclusive f_33 precedence, separate questions/free/sentential relatives, and use explicit roles with bounded conflict checks rather than defaulting roleless gaps to subjects. Preserve source annotations, denominators, metrics and identifiers. The user authorized the remaining plan on 2026-11-08. |
| D-26 | Accepted | Activate f_59 for a bounded inventory of colloquial contractions/written reductions: pa forms, onde/nde/onde's/ontas and reduced estar spellings. Count one longest recognized expression across apostrophe variants/native splits; exclude standard al/del, obvious nominal uses and short nominal acronyms. Preserve source annotations, denominators, metrics and other features. The user approved proceeding on 2026-11-08. Review f_60/f_62 separately; do not copy pied-piping into f_61. |
| D-27 | Accepted | Treat Spanish f_60 as a functional complement-reduction analogue rather than strictly literal zero que: bounded infinitival and unmarked finite complements, with intentional f_24 overlap. The user accepted this starting definition on 2026-11-08. Implementation starts with the three illustrated predicates creer/pensar/esperar; unrelated infinitives, overt/wh introducers and nominal infinitives are excluded. Preserve source annotations, other features and word populations. |
| D-28 | Accepted | Activate f_62 for linked preposition-adverb-verbal-infinitive interruptions, one full span per match, without an arbitrary three-token cap. The user approved the scope on 2026-11-08, then explicitly corrected the negation choice: exclude negation-only cases. Require a non-negative adverb; negative ADV/PART may accompany it. Exclude subjects, punctuation and nominal infinitives; retain independent f_24/f_63 behavior and all supplied annotations/word populations. |
| D-29 | Accepted; bounded implementation D-31 | Use resumptive prepositional relatives as the French/Spanish functional f_61 counterpart of English preposition stranding, preserving pied-piping f_33 in all three packages. The user endorsed the competing-form rationale on 2026-11-08 despite register/licensing differences. Spanish operationalization follows D-31; the requested French revision remains a separate follow-up. |
| D-30 | Accepted | Reduced/discontinuous features must represent competing structural realizations, oriented toward less formal, less standardized or marked alternatives. Align that competition across languages rather than requiring identical mechanisms or grammatical status. Register is a grouping rationale, not a guarantee about every occurrence. The user explicitly stated this guardrail on 2026-11-08. |
| D-31 | Accepted | Implement a bounded Spanish f_61 resumptive-prepositional baseline under D-29/D-30, as authorized on 2026-11-08. Initial hablar-de/depender-de/confiar-en frames require finite/subject evidence, a compatible postverbal third-person tonic PP and no ordinary subject/object-gap explanation. Count once per relative clause; detected que markers leave f_29/f_30. Preserve f_33 and other relative bins, supplied annotations, denominators and metrics. Record local hablé/confié lookup and other remaining parser/coreference limits; do not modify French here. |
| D-32 | Accepted | Scope rule: changing the full scope of a feature requires a stated linguistic/theoretical rationale and the user's explicit confirmation before implementation. Bug fixes within an agreed definition do not. Do not activate a compatibility zero merely to fill a column. Stated by the user on 2026-11-08. |
| D-33 | Accepted | Tense features count finite VERB/AUX in every mood in Spanish and French, parallel to English VBD/VBZ/VBP: f_03 includes the present subjunctive as f_01 includes the imperfect subjunctive. French passé composé counts as f_02 plus its present auxiliary, as Spanish ha comido and English has eaten. User-confirmed 2026-11-08. |
| D-34 | Accepted | Accent policy for lexical inventories in both languages: data builders add unaccented twins of accented entries (aquí -> aqui), except contrastive grammatical words in `accent_contrastive_forms` and inflected-form lists where the accent is morphological. Only accent marks (acute, grave, circumflex, diaeresis, cedilla) are removed; Spanish ñ is preserved. User-confirmed 2026-11-08. |
| D-35 | Accepted | Spanish f_28 remains a linguistic compatibility zero (see 2026-11-08 entry); French f_28 stays active because its adjectival present participle is grammatical. |
| D-36 | Accepted | Documentation for all three packages recommends normalizing text before parsing with `utf8::utf8_normalize(text, map_quote = TRUE)` (curly apostrophes to ASCII, NFC composition, accents preserved), in a shared `readtext` -> pre-process -> `quanteda` corpus -> parser -> `biber()` example. In-package apostrophe tolerance remains a fallback only. Agreed on 2026-11-09; to be applied when the READMEs/vignettes are rewritten. |
| D-37 | Accepted | f_23 includes free relatives that are a verb's argument: French *ce que/ce qui*, Spanish *lo que*, counted once per clause as the two-word span. Exclude sentence relatives after punctuation (f_34), free relatives governed by a copula or preposition, and pseudo-relatives. Supersedes the earlier deferral of free relatives. Basis: Biber's own f_23 example (*I believed what he told me*) and English counting *what* after verbs. User-approved 2026-11-09. |
| D-38 | Accepted | Output is `doc_id` plus feature columns in all three packages; Spanish/French `n_tokens` and `n_lex_tokens` removed. The normalization denominator excludes digit-final numerals in all three (English already did), refining D-02; it now equals the lexical-diversity token set. User-approved 2026-11-09. |
| D-39 | Accepted | `biber()` and `audit_features()` accept UDPipe and spacyr annotations only, as in English; plain data-frame (and Spanish default) methods removed. User-approved 2026-11-09. |
| D-40 | Accepted | Modal features (f_52-f_54) count modal verbs and periphrases grammaticalized as modals in each language (Spanish tener que, haber que/de, ir a + Inf; French aller + Inf), not adjectival or nominal constructions (be obliged/necessary/likely/liable/able to). French avoir la possibilité de, être obligé/nécessaire de, risquer de and être susceptible de were removed: neither English nor Spanish counts their counterparts. User-approved 2026-11-09. |
| D-41 | Accepted | French negation follows D-18 (Tottie): f_66 = each negative word (aucun/nul/personne/rien/jamais/ni/aucunement/nullement) including concord, as Spanish D-20; f_67 = the particle pas (with or without ne), point/plus sharing a head with ne, and constituent non, as Spanish D-17. ne alone is a concord clitic and is not counted. sans deferred (as sin); guère is a downtoner, as English hardly is not negation. User-approved 2026-11-09. |
| D-43 | Accepted | f_15 = non-finite verb forms functioning as nouns (Biber's gerund analogue). In Spanish and French these are infinitives: D-23 nominal infinitives (determiner/possessive/adjective) plus infinitives heading a subject placed before its verb (`Fumar perjudica`, `Fumer tue`, like "Smoking harms"). Postposed subjects, objects and preposition + infinitive remain f_24. Gerunds/gérondifs and participles are adverbial or adjectival and are excluded; the French gérondif moves to f_25. User-approved 2026-11-09. |
| D-44 | Accepted | f_35-f_37 keep only unambiguous subordinators (Biber): FR f_35 parce que; f_36 bien que, quoique; f_37 conditional si, à moins que, sauf si. même si counts through si (EN "even if" → f_37). puisque, comme, encore que, à condition que → f_38; car (coordinator, EN "for") not counted. Indirect-question si is excluded when its clause is ccomp/xcomp of a question/knowledge verb, as in Spanish. User-approved 2026-11-09. |
| D-45 | Accepted | French f_59 = colloquial reductions with an available full form (D-26/D-30): `colloquial_contractions` inventory (p'tit, m'sieur, chuis, j'sais, y'a…) plus bounded rules for subject t' (no preceding subject), subject j' before a consonant, and il-less y a. Obligatory elision is never counted. User-approved 2026-11-09: "reduced forms when there are options". |
| D-46 | Accepted | f_60 in ES and FR = reduced complement competing with a que-clause (D-27), under private creer/pensar/esperar ↔ croire/penser/espérer and public decir/afirmar/asegurar ↔ dire/affirmer/prétendre, following Biber's PUB/PRV governors. French f_60 ported from Spanish (previously any unmarked ccomp/xcomp). User-approved 2026-11-09. |
| D-47 | Accepted | French f_61 = colloquial competitors of pied-piping in que-relatives after a noun (D-29): orphan preposition without complement (avec/pour/sans/contre/dessus/dessous/dedans), resumptive tonic PP in parler de/dépendre de/compter sur/se fier à (parallel to ES D-31 frames), resumptive en with parler/souvenir/rêver/occuper/dépendre (competitor of dont). One per relative; matched que leaves f_30. Pied-piping stays f_33 only. User-approved 2026-11-09. |
| D-48 | Accepted | French f_62 = linked preposition + adverb(s) (+ clitics) + verbal infinitive with at least one adverb that is neither negation nor a light preinfinitival adverb (bien, mal, mieux, trop, peu, assez, beaucoup, tant, tout). toujours/encore/déjà/ensuite count (they alternate). Negation-only excluded (D-28 parity). User-approved 2026-11-09. |
| D-49 | Accepted | f_63 in FR and ES: the analytic negator alone (FR ne/pas/point/plus, ES no), counterpart of English not (tagged PART, not counted in English), does not split an auxiliary; negative adverbs count (n'a jamais vu, like has never seen). French f_63 rewritten: avoir/être or modal pouvoir/devoir + adverb(s) + own participle/infinitive, linked by dependency; inverted subjects intervening are excluded, as in EN/ES. User-approved 2026-11-09 (option A, Spanish included). |
| D-50 | Accepted | French ce/c'/ça/cela/ceci: f_10 for pronominal ce/c' (c'est vrai ≈ that's, Biber 10b), ça/cela/ceci, celui family (those who); f_09 for c'est + ADJ + clausal complement (it is important to), excluded from f_10; ce of ce que/ce qui/ce dont relatives excluded (f_23/f_34, like what/which). Clefts stay f_10 (not reliably separable from presentational relatives). f_08 restricted to PronType=Prs: ce/ça, partitive en and generic on (≈ one) counted nowhere. User-approved 2026-11-10. |
| D-51 | Accepted | f_44 = mean length in letters of purely alphabetic word tokens (\\p{L}+), unrounded, NA when a document has none, in ES and FR (Biber: orthographic letters). Spanish no longer counts numerals/hyphenated/apostrophe forms or rounds to 3 decimals; French no longer returns 0. English to adopt Unicode letters (currently ^[a-z]+$) with the deferred English items. User-approved 2026-11-10. |
| D-52 | Accepted | French f_11 gated to pronoun use, porting the Spanish rule: phrases (quelque chose, tout le monde, n'importe qui/quoi, quelques-uns) once; always-pronoun forms (quelqu'un, chacun, quiconque, autrui) any tag; personne as PRON or determinerless NOUN in a ne sentence; rien without article; tout/aucun/nul as PRON (tout also as ADV on a verb). Added aucun/nul (≈ ninguno, none) and quelques-uns (≈ alguno). Overlap with f_66 (personne/rien/aucun/nul) is intended, as for Spanish nadie/nada/ninguno and English nothing/nobody. User-approved 2026-11-10. |
| D-53 | Accepted | English alignment pass: f_42 residual per Biber (D-15) by occurrence, excluding RB/WRB tokens inside f_04/f_05/f_46/f_47/f_48 matches; f_44 on Unicode letters (D-51); f_62 excludes negation-only (to not/never VB; D-28/D-48). Kept as language-specific: English f_09 counts all it; f_12 counts all main-verb do (Biber's algorithm). User-approved 2026-11-10. |
| D-54 | Accepted | Language-specific display names are a presentation layer: data-raw/feature_names.yaml (shared ID: display name) per package, applied as the last step of biber()/audit_features(); detectors, evidence, tests and this log keep shared IDs. Display names keep the f_NN_ number (build-checked). feature_names = "language" (default) or "shared", default overridable with options(pseudobibeR.feature_names). audit_features() accepts either name. Spanish and French only for now; English uses the shared names. User-approved 2026-11-10. |
| D-55 | Accepted | Defect repairs found while drafting the French technical reference: dictionary phrases match UDPipe-split contracted articles (FR du/des/au/aux, ES al/del) as well as the contracted form; FR f_20 surface-based il y a (n'y, y en, y a; locative y excluded); FR f_38 excludes ADP marking non-finite clauses; FR possessives complete in f_06–f_08 with POS gates; FR multiword verb-class entries matched on the verb; FR weather faire as copula; FR f_37 requires à moins. Stale docs, dictionary comments and examples corrected. |
| D-56 | Accepted | f_50 clause-initial only (sentence-initial or after punctuation) in ES and FR, per Biber and English. FR f_39 counts listed compound prepositions once (prepositions_compound), as ES. FR f_65 counts sentence-initial et attached to a finite predicate, as ES, and finite clauses headed by a participle or copular predicate. User-approved 2026-11-10. |
| D-42 | Accepted | French f_42 excludes the concord clitic ne, so analytic negation contributes one adverb in all three languages (not, no, pas). User-approved 2026-11-09. |

Proposals are recommendations, not authorization to change every listed behavior.
Where Spanish already meets an agreed target, preserve it and add cross-package
contract coverage rather than changing it to match a legacy defect.

## Implementation and validation sequence

### 1. Spanish package

- [x] Confirm and append the resource-isolation and French-reference removal
      decisions (D-04 and D-12). Scientific mapping decisions remain open.
- [x] Fix F-01 in every Spanish resource consumer, including auditing and helpers.
- [x] Test installed namespace-only calls and both package attachment orders in
      fresh R processes. Prove Spanish results remain stable even before French
      is repaired; record the remaining French failure separately.
- [x] Apply the accepted corpus-wide lexical-diversity policy (D-06).
- [x] Apply the accepted tagged, filtered lexical input definition (D-13);
      package validation is complete.
- [ ] Implement remaining Spanish definition/API changes only after their
      decisions are accepted.
- [x] Preserve correct Spanish normalization, sentence identity, evidence
      reconciliation, and metric definitions under the accepted corpus-wide
      selection policy (D-06).
- [x] Add targeted regressions for the adopted resource-isolation contract; update directly related
      user documentation and change notes.
- [x] Run focused tests, then appropriate package-level validation.
- [x] Record fixes and verification here before copying this document to French.

### 2. French package

- [ ] Copy this document with finding/decision IDs intact.
- [ ] Reproduce findings against the actual French working tree; record reference
      version differences rather than assuming this snapshot is current.
- [ ] Isolate French resources and repeat installed coexistence tests.
- [ ] Correct counting, sentence-key, normalization, lexical-metric, and audit
      defects under the accepted contract.
- [ ] Apply agreed linguistic mappings and API/output changes.
- [ ] Run the shared contract cases and language-specific regressions.

### 3. Family-wide validation

- [ ] Assess English against the same accepted contract; do not assume unchanged
      legacy behavior is the target.
- [ ] Verify raw occurrence counts equal summed audit counts for auditable count
      features. Metrics and compatibility placeholders need separate assertions.
- [ ] Verify normalization exactly, including compound expressions and punctuation.
- [ ] Verify document isolation, sentence boundaries, output shape, and row order.
- [ ] Test equivalent parser schemas using controlled annotations.
- [ ] Validate real spaCy/UDPipe output independently, preserving known model-error
      distinctions. Use the `r-spacyr` environment for Python checks in this work.
- [ ] Review compatibility/migration implications before publishing changed
      scientific definitions or output schemas.

This does not require introducing a new shared R package or copying entire
implementations. Start with one explicit contract and parallel regression cases.

## Appended decisions and implementation notes

### 2026-11-03: review recorded

- Recorded F-01 through F-10.
- Distinguished prior accepted requirements from new proposals and unresolved
  scientific definitions.
- Confirmed Spanish-first implementation and subsequent French handoff.
- No alignment code changes or resolutions are claimed by this entry.

### 2026-11-03: Spanish resource isolation and reference removal

- Decision IDs: D-04 and D-12, accepted.
- Finding ID: F-01; Spanish implementation complete, validation in progress.
- The user confirmed that the French reference checkout should be removed, not
  retained as an intentional exception. Its absence from the Spanish repository
  was verified during cleanup.
- The packaged dictionary matched the Spanish YAML source, and the packaged
  examples and UDPipe sample texts were Spanish. No packaged French dataset
  was identified for deletion. F-01 is a lookup bug, not evidence that these
  Spanish datasets should be discarded or rebuilt.
- Spanish extraction now binds `pseudobibeR.es::dict` and
  `pseudobibeR.es::word_lists` explicitly. The independent dictionary-evidence
  helper also binds its own package dictionary, covering both counting and
  auditing routes. No new resource loader, cache, or dependency was introduced.
- Removed obsolete declarations treating the datasets as unresolved globals.
- Added synthetic resource-masking tests for raw counts, normalized counts,
  and complete audit rows through both parser schemas. These tests contain no
  French language dataset and do not require the French package.
- Added an installed-package subprocess regression for namespace-only calls and
  both attachment orders of conflicting resources.
- Before the fix, the masking regression failed six comparisons: private verbs,
  time adverbials, compound prepositions, conjuncts, normalized values, and audit
  evidence changed under masking.
- No feature definitions, normalization rules, output schemas, or French source
  were changed. French F-01 remains a separate handoff item.
- Validation results and final resolution status will be appended after checks.

### 2026-11-03: Spanish F-01 verified

- Decision IDs: D-04 and D-12.
- Finding ID: F-01, resolved for Spanish only.
- Implementation references: `pseudobibeR.es/R/parse_functions.R`,
  `pseudobibeR.es/R/dictionary_evidence.R`, `pseudobibeR.es/R/globals.R`,
  and `pseudobibeR.es/tests/testthat/test-resource-isolation.R`.
- Focused resource, pipeline, correctness, and count/audit regression tests
  passed. The subprocess test intentionally skips source-only development
  loading and runs against the installed package during package checking.
- Built-package `R CMD check --no-manual`: zero errors, warnings, and notes.
  Tests: 1,336 passing expectations and five existing expected skips.
  The installed subprocess regression ran, rather than skipping. Live Spanish
  spaCy coverage ran using Python from `r-spacyr`.
- Separate fresh-process probes with installed French 0.0.0.94 confirmed both
  attachment orders. Spanish `pensar` remained one raw occurrence and one audit
  occurrence. All raw and normalized Spanish sample results and the selected
  private-verb, passive-agent, and first-person-pronoun audit rows were unchanged.
- The unmodified French `penser` result still changed between 0 and 2 with
  attachment order. This remains a French F-01/F-03 handoff issue; it does not
  invalidate the now-independent Spanish results.
- The packaged dictionary and complete word lists match the Spanish YAML
  resources and builder-derived phrase inventory. All 72 packaged Spanish
  examples match their YAML source. Native UDPipe sample texts are Spanish.
  The remaining binary data/model inventory contains only Spanish resources.
- Confirmed that the French reference checkout is absent from the repository.
  The built tarball contains neither that reference nor this development log.
- Compatibility impact: namespace-only calls now work, and conflicting attached
  resources no longer alter Spanish results. Intended Spanish definitions,
  output shape, normalization, and parser-specific behavior are unchanged.
- Remaining work: approve the unresolved scientific/API decisions before
  implementing additional alignment changes; carry the French defects forward
  when this record is copied into the French repository.

### 2026-11-03: corpus-wide lexical-diversity policy accepted

- Decision ID: D-06, accepted; implementation complete, validation in progress.
- Finding ID: F-05, reframed as a compatibility difference rather than an
  unconditional defect in the original/French corpus-wide fallback.
- The user specified MATTR with TTR fallback unless another measure is selected,
  one measure for the corpus, and one value per document for subsequent scaled
  multivariate analysis. A column mixing document-level MATTR and TTR is rejected.
- This supersedes the earlier proposal to make fallback document-independent.
  Adding a short document can intentionally switch the whole corpus from MATTR
  to TTR; that is selection policy, not an arithmetic error.
- Spanish now selects the effective measure once and computes all documents in
  one `textstat_lexdiv()` call. Fallback emits one message. Exactly 200 tokens
  qualifies for MATTR; the threshold uses the supplied diversity token stream,
  including punctuation, not the word-count normalization denominator.
- Explicit TTR, CTTR, and MSTTR are retained; `none` still omits f_43.
  Shared library adjustments, such as shortening the MSTTR segment for short
  documents, remain visible through the library's warning rather than silently
  substituting a different measure or using per-document segment settings.
- Compatibility note for French/English: their reviewed implementations override
  even explicit alternative requests when any document is short. The newly
  accepted policy matches their default corpus-wide fallback but requires
  preserving explicit alternatives in those packages during handoff.
- Token preparation, type definitions, and the library's internal punctuation
  handling are separate cross-package comparison questions. This change does
  not claim to resolve them or change Spanish input-token preparation.
- Regression coverage includes mixed-length corpora, default/explicit MATTR,
  both parser schemas, normalized/raw output, threshold boundaries, punctuation
  in the threshold, explicit alternatives, shared MSTTR settings, and document
  ordering beyond nine documents.
- Documentation and the obsolete document-independence test were updated.
  Validation results will be appended after checks.

### 2026-11-03: corpus-wide lexical diversity verified

- Decision ID: D-06, implemented and verified for Spanish.
- Finding ID: F-05.
- Implementation: `pseudobibeR.es/R/parse_functions.R`.
  Regressions: `pseudobibeR.es/tests/testthat/test-lexical-diversity-contract.R`
  and `pseudobibeR.es/tests/testthat/test-pipeline-contract.R`.
- Mixed-length regression: a 240-token document alone receives MATTR
  0.01702128; alongside a two-token document, both receive TTR, with values
  0.008333333 and 1. No column mixes the two statistics.
- Focused corpus-selection, parser-schema, normalization, explicit-measure,
  ordering, count/audit, and resource-isolation checks passed.
- Generated help was synchronized with the roxygen source.
- Built-package `R CMD check --no-manual`: zero errors, warnings, and notes.
  Tests: 1,365 passing expectations and five existing expected skips.
  Live Spanish spaCy coverage ran using `r-spacyr`.
- Existing metric column naming, document order, normalization, token input,
  and occurrence-count/audit behavior are preserved. Intended changes affect
  corpus-level MATTR fallback and shared settings for explicit MSTTR.
- French/English handoff: keep their default corpus-wide selection, but honor
  explicitly selected alternatives under D-06. Do not describe their default
  global fallback as a defect. Token-preparation equivalence is still unresolved.

### 2026-11-03: original English lexical-diversity input verified

- Finding IDs: F-02 and F-05; additional evidence, not a new accepted mapping.
- Source: original `pseudobibeR/R/parse_functions.R:263-269,278,748-750,774`,
  inspected on public upstream `main`.
- English converts native parser annotations directly with
  `quanteda::as.tokens(tokens, include_pos = "tag", concatenator = "_")`,
  then lowercases the resulting tokens. The lexical-diversity basis is the
  surface form, not the lemma, but fine-grained POS tags remain appended.
- Its subsequent filtering removes punctuation placeholders and numeric
  matches; it also maps `&_cc` to `and_cc`. The resulting tagged stream is passed
  directly to `textstat_lexdiv()` without stripping tags.
- Replaying the original preparation on controlled annotations for `Dogs`
  (NNS), `dogs` (VBZ), `42` (CD), and `.` left `dogs_nns` and `dogs_vbz`.
  TTR was 1: two distinct tagged types in two retained tokens. The same two
  untagged, lower-case word tokens would have TTR 0.5.
- No `tokens_compound()` or tag-stripping step occurs in the reviewed English
  metric path. Dictionary lookup creates feature counts separately and does
  not replace the tokens used for lexical diversity. Earlier explanations
  incorrectly generalized the French reconstruction/compounding path to English.
- English calls `textstat_lexdiv()` without overriding its filtering arguments.
  Installed-library defaults are removal of punctuation, numbers, and symbols,
  a 100-token MATTR window, and a 100-token MSTTR segment. Filtering operates
  on already-tagged input; do not equate it with plain-word filtering.
- Spanish currently uses lower-case surface tokens without appended tags and
  explicitly sets the three removal arguments to `FALSE`. These are remaining
  input/type-definition differences even after corpus-wide selection is aligned.
- No R code, dataset, or accepted decision was changed by this investigation.
  Matching the tagged English type definition versus using ordinary surface-word
  types remains a scientific compatibility decision; do not silently change it.

### 2026-11-03: tagged, filtered lexical-diversity input accepted and implemented

- Decision ID: D-13, accepted; implementation complete, validation in progress.
- Finding IDs: F-02 and F-05, specifically the f_43 token/type definition.
- The user approved implementing the original English behavior in Spanish
  now, documenting the changes, and aligning French later. Since Spanish is
  unreleased, no compatibility flag or preservation of the old metric was
  requested.
- Types are lower-case surface-plus-tag strings. Fine-grained native tags are
  retained; existing missing-tag fallback uses UPOS, and the standard UD `_`
  placeholder also falls back to UPOS for this metric. This adapts the original
  tagged definition to Spanish parsers without changing their grammatical
  feature detectors. Lemmas do not determine lexical-diversity types.
- Filter PUNCT/SYM/SPACE using canonical UD POS, rather than relying on English
  punctuation tag conventions. This excludes native Spanish punctuation and
  symbol rows before tags can make them look word-like. Apply the original
  numeric regex `\d_` to the tagged stream: digit-final numeric surfaces such
  as `42` are removed; spelled-out numeral words such as `dos` remain.
- Dictionary matching and compounding for feature detection do not alter this
  metric stream. French must stop feeding its compounded dictionary stream
  into f_43 when porting this decision.
- The original library filtering defaults are restored. The 200-token test
  now uses the retained, filtered diversity stream. This supersedes the
  preliminary inclusion of punctuation in the threshold, but does not change
  D-06's corpus-wide measure choice or honoring explicit alternatives.
- Documents empty after this filtering remain output rows. Their f_43 is
  `NA`, with an identifying warning. They still participate in the default
  short-document fallback; calculation for nonempty documents uses one shared
  call. Explicit MSTTR excludes empty input rows from segment calculation
  rather than allowing a zero-length segment or fabricating a value.
- Word-count normalization still includes number words; f_44 still measures
  untagged word lengths. Raw feature counts and audit evidence retain their
  existing populations. Only the lexical-diversity stream is changed.
- Controlled Spanish annotation checks match the original English preparation:
  `canto_noun`, `canto_verb`, and `cantó_verb` are three distinct types.
  Adding correctly annotated punctuation, numeric literals, or symbol rows
  does not affect f_43 or its measure-selection threshold.
- Regressions cover both parser schemas, case folding, fine-grained tags,
  missing tags, numeric filtering, uncompounded dictionary phrases, threshold
  boundaries, padding invariance for every supported measure, filtered-empty
  documents, and unchanged word-length/normalization definitions.
- Implementation references: `pseudobibeR.es/R/features_lexical_complexity.R`
  and `pseudobibeR.es/R/parse_functions.R`.
  Regressions: `pseudobibeR.es/tests/testthat/test-lexical-input-contract.R`
  and the existing lexical-diversity/correctness contract tests.
- Remaining work: finish package validation, then carry this input definition
  into the French repository alongside the other accepted fixes.

### 2026-11-03: tagged lexical-diversity input verified

- Decision ID: D-13, implemented and verified for Spanish.
- Built-package `R CMD check --no-manual`: zero errors, warnings, and notes.
  Tests: 1,423 passing expectations and five existing expected skips.
  Live Spanish spaCy coverage ran using `r-spacyr`; native UDPipe and frozen
  parser cases also passed.
- Controlled tagged-surface cases match the original English preparation.
  Fine-grained and UPOS-fallback tags distinguish grammatical types; lemmas
  and letter-case differences do not substitute a different type definition.
- Punctuation/numeric/symbol padding leaves f_43 unchanged across MATTR,
  TTR, CTTR, and MSTTR. Exactly 200 retained tokens preserves MATTR;
  199 word tokens plus punctuation or a numeric literal uses corpus-wide TTR.
- Filtered-empty documents retain their original positions, including when
  the empty document appears first. They receive an identifying warning and
  `NA`; nonempty documents receive the selected shared statistic.
- Word-count normalization still includes number words, and word lengths do
  not include appended tag characters. Existing feature counts, audit
  evidence, output schema, and dataset resources are unchanged.
- Help was regenerated from the roxygen contract. README, vignette, feature
  table, change notes, and this decision log document the adjustment.
- French handoff remains open: adopt the same tagged/uncompounded metric input,
  canonical exclusions, numeric filtering, and shared corpus measure policy
  without altering dictionary phrase counting for grammatical features.

### 2026-11-05: English is a baseline, not an oracle

- Decision ID: D-14, accepted.
- Applies to F-07 and subsequent cross-language comparisons; English's greater
  age and testing history are useful evidence, not proof that every rule is
  linguistically or computationally correct.
- For each feature, distinguish intended linguistic construct, actual behavior,
  counting unit, and parser-specific implementation. Compare these with the
  evidence rather than copying the English rule automatically.
- When a discrepancy looks like an error, establish a controlled example,
  discuss the best-supported correction, and record the accepted decision and
  rationale before changing scientific definitions.
- Implement agreed corrections in Spanish first and add appropriate regression
  coverage. Record separate English and French follow-up, including reproductions
  and whether the change is a bug fix, a shared definition change, or a genuine
  language-specific adaptation.
- Finish the Spanish work before debugging the companion repositories. Do not
  preserve a suspected defect merely to claim identical behavior, and do not
  label a documented policy a defect without examining its rationale.
- This establishes the review method; it does not automatically reopen or
  supersede previously accepted feature decisions.
- No package behavior changed in this documentation update.

### 2026-11-05: f_42 baseline and overlap probes

- Finding ID: F-07; proposed decisions D-15 and D-16.
- Inspected the actual upstream English `data/dict.rda`, not just the feature
  description. Its f_42 patterns are `*_rb*` and `*_wrb`: ordinary, comparative,
  superlative, and wh-adverb tags. Source: public `browndw/pseudobibeR` main.
- Executed the original dictionary-lookup path on controlled tagged tokens.
  Tokens can match f_42 and a specialized feature independently:

  | English controlled case | f_42 | Additional counts |
  |---|---:|---|
  | `quickly_rb` | 1 | None in the inspected specialized columns |
  | `today_rb very_rb maybe_rb not_rb` | 4 | f_05 = 1, f_48 = 1, f_47 = 1, f_67 = 1 |
  | `more_rbr most_rbs` | 2 | f_49 = 2 |
  | `when_wrb` | 1 | Wh-adverb is included |
  | `more_rbr or_cc less_rbr` | 2 | f_47 = 1; the phrase does not suppress its two adverb occurrences |
  | `_punct_ well_uh that_dt inside_in` | 0 | f_50 = 1 and f_04 = 1; discourse/adverbial membership does not automatically make a token an adverb |

- Spanish currently counts each UPOS ADV once, without subtracting specialized
  memberships. Controlled annotations confirmed f_42 = 1 for `rápidamente`,
  `hoy`, `muy`, `aproximadamente`, and `dónde`; the relevant time/amplifier/hedge
  counts remain present. VERB `mira` and INTJ `bueno` contribute zero to f_42.
  Each counted ADV also produced one exact f_42 audit row.
- A valid `No vino` annotation exposed a separate parser-mapping boundary:

  | Source annotation for `no` | Spanish f_42 | Spanish f_67 | f_42 audit rows |
  |---|---:|---:|---:|
  | ADV / advmod, attached to VERB | 1 | 1 | 1 |
  | PART / neg, attached to VERB | 0 | 1 | 0 |

  The original English lookup counts synthetic `not` with UPOS PART and
  fine-grained tag RB in both f_42 and f_67. This is a controlled annotation
  probe, not a claim about a newly tested live English model.
- Recommendation: retain total rather than residual adverbs. Specialized
  overlap is not within-feature double counting; f_42 counts adverb tokens,
  whereas a specialized multiword feature can count a whole phrase once.
- Resolve D-16 explicitly before making a PART exception. Do not include
  every particle or every surface occurrence of `no` automatically.
- The Spanish detector comment claiming equivalent French behavior is outdated:
  the reviewed French detector excludes several specialized categories. Actual
  source and probes, not that comment, establish the comparison.
- No Spanish detector or scientific definition changed during this review.

### 2026-11-05: Biber's f_42 exclusion definition accepted

- Finding ID: F-07; accepted decision D-15.
- Biber's controlling definition:
  > The count for total adverbs excludes those adverbs counted as instances of
  > hedges, amplifiers, downtoners, amplifiers, place adverbials, and time
  > adverbials.
- The repeated "amplifiers" names the same category twice. The five unique
  exclusions are f_04 place adverbials, f_05 time adverbials, f_46 downtoners,
  f_47 hedges, and f_48 amplifiers. Do not substitute emphatics for the repetition.
- This supersedes the unrestricted-total recommendation in the preceding
  baseline entry. English behavior is evidence of an implementation difference,
  not authorization to depart from the supplied Biber definition (D-14).
- Spanish implements the exclusion on actual reconciled occurrence evidence:
  remove ADV candidates sharing document/sentence/token identity with counted
  specialized detections, and ADV members covered by their dictionary phrase
  spans. Use the union of exclusions, not subtraction of feature totals or
  blanket removal of every word found in a resource inventory.
- The non-ADV anchor in `un poco` does not prevent exclusion of ADV `poco`.
  `más o menos` can cover two ADV words while counting as one phrase per
  specialized feature. A phrase with no ADV words removes nothing from f_42.
- Conjuncts (f_45), emphatics (f_49), discourse particles (f_50), and negation
  (f_66/f_67) are not additional exclusion categories. An ADV occurrence in
  one of them is removed only if also covered by one of the five exclusions.
- D-16 remains pending: this change does not add PART tokens to f_42 or decide
  the cross-parser negative-particle boundary.
- Specialized counts, the original word-row denominator, and lexical metrics
  remain unchanged. Counts and audits share the filtered evidence. Spanish is
  unreleased, so this correction requires documentation, not a compatibility flag.
- Implementation references: `R/features_modals_verbs.R`,
  `R/parse_functions.R`, and `tests/testthat/test-adverb-exclusions.R`; updated
  the previous place/time overlap expectations and the Spanish-GSD f_42 case.
- Regression-first validation reproduced 15 failures in the previous unrestricted
  implementation, including both parser schemas, normalized counts, audit rows,
  phrase membership, lemma-only detection, and sentence/document isolation.
- Verification: 211 focused expectations passed with no failures, warnings, or
  skips. Installed-package `R CMD check --no-manual` passed 1,464 expectations
  with five existing expected skips and zero errors, warnings, or notes.
  Live Spanish-GSD and spaCy were enabled, with Python in `r-spacyr`.
  Regenerated the feature help and verified `git diff --check`.
- English follow-up: replace the verified unrestricted RB/WRB lookup with these
  five occurrence-based exclusions. French follow-up: check its exclusions and
  phrase handling against this exact list, rather than retaining extra categories
  or assuming the existing residual implementation is already equivalent.

### 2026-11-05: Negation marker units and nominal-scope coverage reviewed

- Finding ID: F-07. D-16 remains pending.
- Status: Verified current behaviour; no detector changes or new scientific
  mappings approved.
- The user supplied Biber's definitions:

  ```text
  66. synthetic negation
  (a) no + QUANT/ADJ/N
  (b) neither, nor
  (excludes no as a response)
  67. analytic negation: not
  (also contracted forms)
  ```

- The user's interpretation is supported by the examined English and Spanish
  behaviour: a qualifying negator triggers a count without consuming the noun
  or removing its independent noun-category occurrence. Context used to
  identify negation is not an instruction to compound the noun input.
- English dictionary lookup can match `no` plus an adjective or noun, but noun
  categories are computed separately from the original annotations. Spanish
  f_66/f_67 evidence is anchored on individual markers; noun evidence is produced
  independently. No noun-pipeline change is needed for this counting-unit concern.
- Validation used installed English `pseudobibeR` 1.3 with live
  `en_core_web_sm`, and Spanish development source with both Spanish-GSD and live
  `es_core_news_sm`. Python ran in `r-spacyr`; language-package comparisons used
  separate R processes. Spanish negation/noun audit keywords were also inspected.

  | Current example | f_66 | f_67 | Independently retained nouns |
  |---|---:|---:|---|
  | English: `No books were available.` | 1 | 0 | f_16 = 1 (`books`) |
  | English: `No explanation was given.` | 1 | 0 | f_14 = 1 (`explanation`), f_16 = 0 |
  | English: `It isn't a book.` | 0 | 1 | f_16 = 1 (`book`) |
  | Spanish: `No leyó ningún libro.` | 1 | 1 | f_16 = 1 (`libro`) |
  | Spanish: `No dio ninguna explicación.` | 1 | 1 | f_14 = 1 (`explicación`), f_16 = 0 |

- The Spanish results above agree across both tested parsers. f_66 audit
  keywords are `ningún`/`ninguna`; f_67 keywords are `No`, not the negated
  noun phrases. These are observed counts, not approval of every current
  Spanish inventory or negative-concord mapping.
- Paired markers currently count separately: English `Neither Mary nor John
  came.` gives f_66 = 2; Spanish `Ni Juan ni Ana vinieron.` also gives f_66 = 2.
  Both retain two proper-noun occurrences. The implementations do not count
  one semantic negation per whole clause.
- Confirmed English coverage gaps under the supplied definition:
  `No two books are alike.` and `No more books were available.` both give
  f_66 = 0 while retaining f_16 = 1. Live tags identify `two` as CD and `more`
  as JJR. The inspected dictionary patterns are `no_* *_jj`, `no_* *_n*`,
  `neither_*`, and `nor_*`: they lack a separate QUANT branch and do not cover
  comparative/superlative adjective tags through the exact JJ pattern.
  Controlled dictionary probes reproduced the misses. Track these for English
  work; do not treat them as the Spanish target.
- Confirmed Spanish nominal-scope gap:
  `Necesitamos un técnico, no un médico.` gives f_67 = 0 and f_16 = 2 in both
  Spanish parsers. Both annotate `no` as ADV/advmod attached to NOUN `médico`.
  The English equivalent, `We need a technician, not a doctor.`, gives f_67 = 1
  and f_16 = 2. Spanish currently accepts only VERB/AUX/ADJ/ADV heads; its missing
  count is caused by this head-POS restriction, not noun-phrase compounding.
- Decide the Spanish analytic-negation scope before changing that restriction.
  Merely admitting every NOUN head risks new false positives: Spanish-GSD
  mis-tags nominalized `no` in `El no del comité fue claro.` as ADV/advmod with
  a NOUN head. That nominalized use is not a negator. spaCy also mis-tags this
  word as ADV, but gives it nsubj, which the current detector rejects.
- Further inventory decisions remain open. Current Spanish f_66 includes
  `nadie`, `nada`, `nunca`, `jamás`, `tampoco`, and `ni`. English `Nobody read
  books.` and `He never read books.` give f_66 = 0 in the tested implementation;
  Spanish `Nadie leyó libros.` and `Nunca leyó libros.` give f_66 = 1.
  The supplied English definition alone does not establish the appropriate
  Spanish adaptations. Do not approve the existing inventory solely because
  its legacy comment attributes it to Biber.
- Reply `No.` gives f_66 = f_67 = 0 in English and both Spanish parsers.
  Ordinary analytic `not`/`n't` are PART with fine tag RB in English; the tested
  Spanish preverbal `no` is ADV in both parsers. Both language implementations
  count ordinary analytic negation in f_67 and f_42. Spanish PART handling
  remains a separate D-16 decision; it was not observed in these live Spanish
  examples.
- Another observed f_42 boundary: reply `No.` is INTJ/UH in the English model
  and ADV in both Spanish models, giving f_42 = 0 versus 1 respectively.
  Negation counts remain zero. Do not add an adverb exclusion or reclassify the
  reply without an explicit linguistic decision.
- Source references: English `R/parse_functions.R:263-281,326-371`;
  Spanish `R/features_coordination_negation.R` (`block_negation_es` and
  `block_lexical_membership_es`) and `data-raw/word_lists.yaml:675-707`.
- Next: agree the Spanish f_66/f_67 functional mappings, including nominal scope
  and negative concord, then address any f_42 tag adaptation. Record English
  fixes for later; apply the same noun-preservation checks in French rather
  than assuming its current pipeline already satisfies them.

### 2026-11-07: approved Spanish analytic-negation scope repair

- Decision ID: D-17; finding F-07. D-16 remains pending.
- User-approved scope:
  > Fix f_67 scope and clear exclusions; leave f_66 and f_42 unchanged pending separate decisions
- Rationale and sources: RAE/ASALE distinguishes ordinary constituent negation,
  response uses, nominalized `no`, and non-negative uses in
  [DPD: no](https://www.rae.es/dpd/no). The connective
  [DPD: obstante](https://www.rae.es/dpd/obstante) means however/despite, not
  analytic negation. [DPD: ninguno](https://www.rae.es/dpd/ninguno) informs the
  still-pending lexical-negative review; its consultation does not approve an
  f_66 inventory change.
- Implemented rule: select configured ADV/PART `no` with `advmod`/`neg` and
  a real, nonself, non-punctuation word head. Ordinary nominal, proper-noun,
  pronoun, numeral, determiner/preposition/subordinator scopes now count
  alongside verbal/adjectival/adverbial scope. Evidence stays anchored on the
  original `no` row; no phrase compounding or token retagging occurs.
- Guarded exclusions:
  - Exact sentence-local `no obstante` matches.
  - Noun readings signaled by a preceding article plus a following PP, a direct
    article dependent of `no`, or a non-attributive rejection-descriptor head.
    The descriptor resource contains `rotundo`, `tajante`, `categórico`,
    `contundente`, and `terminante`; article and dependency cues are required.
    `la no violencia`, `un no fumador`, and negated attributive descriptors
    remain eligible.
  - Directly paired quotes around standalone `no`, not a whole negative clause.
  - Comma-followed reply prefixes with a single comma before their scoped head,
    or preceding another valid `no` sharing that head. A comma-delimited aside
    such as `No, en ningún caso, iremos` retains its genuine negator.
- Context and joins respect document/sentence identity and actual word order,
  including token-ID gaps. The filters are conservative annotation/context
  rules, not a general semantic classifier. Ambiguous reply/nominal readings,
  expletive `no`, and non-negative `no más` remain limitations/open decisions.
- Expanded native-model evidence: both models previously missed nominal,
  proper-noun, pronoun, numeral, and `la no violencia` negation and counted
  `no obstante`, `un no rotundo`, and both occurrences in `No, no iré`.
  All 19 approved examples now meet the same contract in both models.
  spaCy tags the connective's `No` as PART: this observation does not approve
  adding negative PART to f_42, especially since this occurrence is not a negator.
- Preservation verification: all non-f_67 output columns are exactly identical
  before/after for the expanded 21-document corpus in each parser, using raw
  counts and explicit TTR. This includes nouns, f_66, f_42, denominators, lexical
  diversity, and mean word length. The two unresolved semantic examples retain
  their previous counts. All pre-existing word-list fields are also identical;
  only the contextual nominal-No modifier resource was added.
- Implementation: `R/features_coordination_negation.R`,
  `R/parse_functions.R`, `data-raw/word_lists.yaml`, `data/word_lists.rda`;
  regression contract in `tests/testthat/test-negation-scope-contract.R`.
- Status: implemented and verified. Regression-first tests reproduced the
  existing scope omissions and false positives before production changes.
  The combined negation/adverb/lexical contract suite passes 240 expectations
  with no failures, warnings, or skips. The installed build passes
  `R CMD check --no-manual` with both Spanish-GSD and live `es_core_news_sm`
  enabled: **1,512 passing expectations, five expected skips, zero failures
  or test warnings; zero package-check errors, warnings, or notes**.
  Skips remain the absent installed development YAML, On-CRAN example test,
  accepted f_50 baseline noise, and two documented UDPipe limitations.
- Remaining work: decide the f_66 inventory/concord mapping and D-16 separately;
  transfer the marker/noun-preservation contract to French and track the
  already-documented English QUANT/JJR/JJS gaps. No companion code changed.

### 2026-11-07: theoretical negation standard and implementation provenance

- Decision ID: D-18; finding F-07. Status: theoretical criterion accepted;
  inventory and counting changes not yet approved.
- User's guiding principle, attributed to Gunnel Tottie: preserve analytic
  (*not*-negation) versus synthetic (*no*-negation) across Spanish and French.
  Analytic negation uses a standalone grammatical negative particle; synthetic
  negation incorporates negative meaning into a negative lexical item.
  The English illustration explicitly includes negative determiners, pronouns,
  adverbs, and coordinators. This entry records the user's theoretical
  specification, not a newly verified quotation from a Tottie publication.
- Consequences for the review:
  - Preverbal/postverbal position is not the defining distinction. A separate
    surface word is not automatically analytic: English determiner `no` is
    explicitly a synthetic example in the supplied criterion.
  - Negative alternation and concord inform scope but do not, on their own,
    determine feature membership or the occurrence-counting unit.
  - Retire the unapproved proposal that `Nadie vino` must be f_66 = 1/f_67 = 0
    while `No vino nadie` must be f_66 = 0/f_67 = 1 solely on position/concord
    grounds. No detector implemented that proposal.
  - Evaluate lexical negativity and grammatical-particle function in each
    language. Do not approve or reject an inventory merely from its English
    translation or the companion implementation.
- Spanish provenance: the archived application used lexical negative lists,
  and the earliest tracked detector (`a7f001e`) explicitly retained f_66
  markers alongside `no`. It attributed synthetic `nunca/jamás/tampoco` and
  independent concord counts to Biber and `biber_espanol_completo.md`.
  The cited specification was not found in available history/archive searches;
  the comments establish operational intent, not verified theoretical support.
  The retained analytic-adverb resource does not drive current f_67, which
  uses the configured `no` particle and dependency/context guards.
- French reference verified against current upstream `main` at
  `7fc79f4e22ce78f6bbb69edf31a0a379e0959cf8`, package version 0.0.0.94:
  - [Detector](https://github.com/browndw/pseudobibeR.fr/blob/7fc79f4e22ce78f6bbb69edf31a0a379e0959cf8/R/features_coordination_negation.R#L343):
    f_66 counts lexical matches without position/concord suppression; f_67
    counts configured negative expressions sharing a dependency head with
    `ne/n'`. Multiple configured expressions can yield multiple f_67 counts.
  - [Lists](https://github.com/browndw/pseudobibeR.fr/blob/7fc79f4e22ce78f6bbb69edf31a0a379e0959cf8/data-raw/word_lists.yaml#L409):
    f_66 includes `aucun/nul/ni/sans`; f_67 includes `personne/rien/jamais`
    as well as `pas/plus` and other expressions. Shipped R data agree with
    these negation lists.
  - Controlled direct-detector tests, not live parser results: preverbal and
    postverbal `aucun` with `ne` both yield f_66 = 1/f_67 = 0; preverbal and
    postverbal `personne` with `ne` both yield f_66 = 0/f_67 = 1;
    `Personne ne vient jamais` yields f_67 = 2. Negative `jamais/personne`
    without `ne` yield zero in both features: the advertised omitted-ne
    (Ø) case is not supported by this detector.
- Remaining work: assess both inventories and the treatment of concord against
  D-18, then obtain agreement on operational rules and exact expected counts.
  French grouping and omitted-ne behavior are review findings, not an
  approved replacement specification. D-16 and semantic exclusions remain
  separate decisions.
- Implementation impact: documentation only. No detector, resource, test
  expectation, or feature count changed in this theoretical-standard update.

### 2026-11-07: baseline completion guardrails

- Decision ID: D-19; status: accepted development scope.
- User priorities, in order: theoretical linguistic alignment across languages,
  parallel coverage, and closing obvious gaps and errors.
- Sequence: complete a reasonably reliable Spanish implementation; then use
  discovered gaps to fix French and English; finally return to refinements.
  Do not make perfection or exhaustive semantic disambiguation a prerequisite
  for the baseline.
- Immediate negation review: concentrate on the agreed D-18 distinction,
  ordinary lexical/particle coverage, and clear implementation defects.
  Keep idiom-dependent judgments and ambiguous linguistic readings on a
  documented follow-up list rather than implementing speculative classifiers.
- Deferred examples include negative-looking words in idiomatic expressions,
  expletive `no`, ambiguous `no más`, and other sense-dependent exceptions.
  Deferral is not a claim that their current counts are correct.
- This scope decision does not override accepted definitions, authorize
  unreviewed inventory changes, or resolve concord counting automatically.
  Preserve agreed behavior and confirm scientific decisions before changing it.
- Implementation impact: documentation only; no feature counts changed.

### 2026-11-07: approved synthetic-negation baseline contract and repairs

- Decision ID: D-20; finding F-07. The user explicitly approved the concrete
  inventory, per-word concord counts, feature-local ordinary parser repairs,
  and deferred edge-case scope before implementation.
- Baseline synthetic inventory: `ninguno` and forms, `nadie`, `nada`,
  `nunca/jamás`, `tampoco`, and negative `ni`. Analytic negation remains
  grammatical `no` under the previously approved detector.
- Counting unit: occurrences of forms, not independent semantic negations.
  `No vino nadie` has f_66 = 1 and f_67 = 1; `ni...ni` has f_66 = 2.
  Negative concord does not reassign lexical forms by position. This resolves
  the previously pending Spanish baseline inventory/concord decision, without
  approving the existing French or English implementation.
- Repairs:
  - Exclude synthetic candidates with a preceding, directly dependent article
    (article lemma or `PronType=Art`, with a determiner dependency). This
    handles ordinary nominal `la nada` and `un nadie`, even when tagged PRON.
    An article on the surrounding noun does not suppress a negative
    determiner: `la ninguna importancia` retains `ninguna`.
  - Recover the observed PROPN-tagged `nadie` only when it is an `nsubj` or
    subtype with a real VERB/AUX head. Do not extend the fallback to other
    proper-name words, objects, missing heads, or nonverbal heads.
  - Preserve original token annotations and input occurrence order.
    Recovery is feature-local: it does not silently repair f_11, noun counts,
    or other measurements influenced by incorrect parser POS.
  - Reuse determiner-dependency extraction with analytic negation, preserving
    the existing f_67 criteria and output.
- Scope kept narrow: idiomatic/non-negative readings (`nada más`, `antes que
  nada`, `más...que nunca`, temporal `ni bien`), additional classes such as
  `sin`, and ambiguous readings remain deferred under D-19. Regression tests
  explicitly preserve those existing baseline outputs for this pass; they
  are not assertions that the deferred measurements are linguistically correct.
- Implementation: `R/features_coordination_negation.R`; regression contract
  in `tests/testthat/test-synthetic-negation-contract.R`. No runtime word-list
  fields or inventory values changed.
- Validation: regression-first tests reproduced the nominal false
  positives and PROPN-subject miss. The combined synthetic/analytic/adverb/
  lexical contract suite passes **271 expectations, zero failures, warnings,
  or skips**, including both native Spanish models.
  Across 24 documents in each parser, every non-f_66 output column and every
  f_67 audit row is exactly identical before/after, including f_42, nouns,
  normalization populations, lexical diversity, and mean word length.
- Status: implemented and verified. The installed build passes
  `R CMD check --no-manual` with Spanish-GSD and live `es_core_news_sm`
  enabled: **1,543 passing expectations, five expected skips, zero failures
  or test warnings; zero package-check errors, warnings, or notes**.
  The unchanged skips cover absent installed development YAML, the On-CRAN
  example test, accepted f_50 baseline noise, and two documented UDPipe
  limitations.

### Spanish f_09: approved impersonal/expletive predicate coverage

- Decision ID: D-21; finding F-08.
- French scope was established from the actual detector and live parser output,
  not the advertised translation of English *it*. Its PRON candidates are
  `il/ce/cela/ça`, selected by expletive dependencies or impersonal/raising
  context; neuter `le/l'` is not a candidate. `Il l'est` counts `Il`, not `l'`.
  Some French heuristics also count personal examples (`Il veut partir`,
  `Il fait du pain`); this is evidence for later review, not a rule to copy.
  French pronoun tokens and Spanish predicates are deliberately different
  counting units for parallel impersonal/expletive function.
- The user approved one occurrence per identified Spanish predicate on an
  existing word, without inventing null subjects or counting empty nodes.
  `Llueve`, `Es importante descansar`, and `Parece que vendrá` each count once.
  Their audit anchors are `Llueve`, `importante`, and `Parece`.
- The bounded baseline covers five weather verbs, meteorological `hacer`
  with linked `frío/calor`, copular adjectives with postposed clausal subjects,
  and selected impersonal clausal verbs. Finite clauses require a linked `que`;
  `bastar/convenir` also permit infinitival `csubj/xcomp`. Generic personal
  complement rules are not used. Known non-third-singular agreement, nominal
  subjects, and predicate-associated `se` exclude candidates.
  Subject/agreement exclusions follow auxiliary support and nested `xcomp`
  controllers, but do not spill into independent finite `ccomp` clauses.
- Both Spanish-GSD and spaCy tag isolated `Llueve` and `Nieva` as root PROPN.
  A closed list of third-singular root weather forms recovers these ordinary
  examples without changing their original annotations. Dependent determiners
  exclude nominal root uses. This is not a general POS or lemma repair.
- Existential `haber` remains in f_20; personal pro-drop, fronted clausal
  subjects, generic raising/control complements, temporal verbs, ambiguous
  `se`, and neuter `lo` are outside the baseline. French code, f_06-f_08,
  f_42, other features, normalization populations, and metrics are unchanged.
- A known model limit remains: spaCy parses isolated `Basta descansar` with
  PROPN `Basta` as an object of `descansar`, rather than an impersonal predicate.
  No speculative general repair was added. Longer/other constructions still
  depend on the supplied parser's POS, morphology, and dependency accuracy.
- Implementation: `R/features_tense_pronouns.R`, `R/parse_functions.R`,
  `R/feature_categories.R`, four narrow inventories in
  `data-raw/word_lists.yaml`, and `tests/testthat/test-impersonal-predicates.R`.
  Only `data/word_lists.rda` was regenerated; every preexisting field is
  identical. After this step there were nine compatibility zeros, 58 detectable features,
  56 occurrence-evidence features, and 48 strict-evidence features.
- Regression-first tests reproduced zero counts and missing audits before
  implementation. Additional regressions exposed and repaired missed personal
  controller/auxiliary agreement guards. Canonical lower-case E1 text and valid
  document-local fixture keys follow the existing preparation contract.
- Verification: the coupled coverage/output/pronoun suite passed 514 expectations
  with three expected skips before the final guard extensions; the completed
  f_09 contract passed 43 expectations with no failures, warnings, or skips,
  including both native Spanish models. Across 21 captured documents per parser,
  all non-f_09 columns and output column ordering are exactly unchanged.
- Status: implemented and verified. The installed build passes
  `R CMD check --no-manual` with Spanish-GSD and live `es_core_news_sm` enabled:
  **1,590 passing expectations, five expected skips, zero failures or test
  warnings; zero package-check errors, warnings, or notes**. The unchanged skips
  cover absent installed development YAML, the On-CRAN example, accepted f_50
  baseline noise, and two documented UDPipe limitations. Help was regenerated
  and `git diff --check` passed. No French changes or commits were made.

### 2026-11-07: Spanish anaphoric hacer baseline approved and implemented

- Decision ID: D-22; finding F-08.
- The user confirmed that f_12 must capture pro-verbs, not all auxiliary forms,
  and approved the bounded baseline before detector/resource changes.
- Installed French 0.0.0.94 selects non-auxiliary VERB/AUX `faire` with a
  directly attached PRON object from its configured inventory. This is a
  structural heuristic, not action-antecedent resolution; the Spanish detector
  does not copy every clitic or every lexical use of faire/hacer.
- Spanish recognizes lexical hacer with direct-object action `lo`, integrated
  enclitic `lo`, or dependency-linked `lo mismo`. Counts identify the supplied
  verb word once, even when multiple structural paths match. Bare `lo hizo`
  is eligible without requiring a local action antecedent, as explicitly
  approved. Object morphology cannot distinguish neuter action `lo` from
  masculine noun-referential `lo`; distant antecedents remain unresolved.
- Explicit nominal objects/dislocated noun phrases, causal verbal complements,
  auxiliary/copular dependencies and identifiable reflexive contexts exclude
  candidates. Infinitival, progressive and perfect lexical pro-verbs remain
  eligible; their supporting auxiliaries are not extra f_12 occurrences.
- Native probes reproduced ordinary anaphoric `lo hizo`, nominal `El barco lo
  hizo Luis`, causative `Lo hizo llorar`, and `hacer lo mismo` structures in both
  models. Spanish-GSD splits `hacerlo` and `haciéndolo`; its latter lexical
  token/lemma is `haciéndo`, tagged Ger. spaCy keeps each enclitic word and
  supplies compound lemma `hacer él`. Narrow feature-local support preserves
  these supplied words/annotations rather than retagging or inventing clitics.
- The previously unused pro-verb pronoun inventory is narrowed to action `lo`.
  Other clitics/proforms and semantic refinements remain deferred. Existing
  noun/pronoun categories, f_09, f_15, all other features, word populations,
  metrics and French code are unchanged. The nominalized-looking parser noun
  `mismo` retains its preexisting noun-category routing.
- Implementation: `R/features_tense_pronouns.R`, `R/parse_functions.R`,
  `R/feature_categories.R`, the narrow `proverb_object_pronouns` resource,
  and `tests/testthat/test-proverb-contract.R`. Spanish example data now include
  a positive pro-verb and a negative causative. All preexisting word-list fields
  except the approved pro-verb inventory, and all preexisting example rows, are
  preserved. After this step there were eight compatibility zeros, 59 detectable features,
  57 occurrence-evidence features and 49 strict-evidence features.
- Regression-first tests reproduced missing f_12 counts/audits. The coupled
  feature/category/output/tense/f_09 suite passed with three expected skips;
  the completed pro-verb contract and shipped examples passed 33 expectations
  with no failures, warnings or skips, including both native Spanish parsers.
- Against the previously checked installed f_09 package, all non-f_12 output
  columns and column ordering are exactly identical across 33 documents per
  parser (12 pro-verb contrasts and 21 impersonal contrasts), including noun
  and pronoun counts, f_09/f_15, denominators and lexical metrics.
- Status: implemented and verified. `R CMD check --no-manual`, with Spanish-GSD
  and live `es_core_news_sm` enabled, passes **1,627 expectations, five expected
  skips, zero failures or test warnings; zero package-check errors, warnings
  or notes**. The unchanged skips cover installed development YAML absence,
  the On-CRAN example, accepted f_50 baseline noise and two documented UDPipe
  limitations. Help was regenerated and `git diff --check` passed. No French
  changes or commits were made.

### 2026-11-07: Clear noun-like Spanish nominal infinitives

- Decision ID: D-23; finding F-08. The user required no overlap/double-counting
  and explicitly selected clear noun-like nominalized infinitives, rather than
  all infinitival clauses functioning as subjects.
- Spanish f_15 now measures noun-like infinitives, retaining the shared feature
  identifier. `El saber`, `el buen comer`, and `su dormir` qualify under nominal
  structural evidence; ordinary `Fumar perjudica la salud`, verb complements
  and `Es importante descansar` retain their existing verbal-infinitive route.
  This supersedes blanket-zero and historical csubj-only interpretations.
- A shared selector requires an infinitive-shaped word (including accented
  `-ír`), compatible Inf/missing morphology, verb identity, and noun-like
  determiner/possessive or attributive-adjective evidence. Internal verbal
  arguments, directly attached ADV modifiers, auxiliaries/complements and
  noncopular verbal subjects reject nominal classification. Genitive modifiers
  and nominal copular predicates remain eligible. Nominal coordination can
  share context; a verbal coordinand keeps its connected group verbal.
- Endings alone do not classify `mujer`, `taller`, or other ordinary nouns.
  NOUN/PROPN annotations lacking Inf morphology need a known verb identity
  from Spanish inventories or the common `nominal_infinitive_lemmas` list.
  These are static resources, not lexical inference from unrelated documents.
  Unfamiliar noun-tagged forms can be missed pending validated extensions.
  Plural lexical nouns and homographic/lexicalized readings are not
  exhaustively disambiguated under D-19.
- Native probes show `el fumar` as GSD PROPN/Inf versus spaCy NOUN, `su dormir`
  as spaCy VERB/Inf, and GSD `el buen comer` with NOUN lemma `comero`.
  Selection can use the known surface infinitive without changing its source
  lemma/POS/morphology. The same word is excluded from f_14 suffix classification
  (important for `comero`), residual f_16 and verbal f_24, including their audits.
  Other nouns in the phrase are not consumed. Word populations and lexical
  metrics retain the original annotations.
- Recovered nominal subjects tagged csubj do not license f_09's impersonal
  clausal-subject rule; this implements its already-agreed nominal-subject
  exclusion, rather than allowing the new nominal classification to conflict
  with impersonal coverage. Other f_09 behavior is unchanged.
- Model limits remain visible: bare `Fumar` can be PROPN without Inf in spaCy;
  some genuine nominal examples receive finite-verb or erroneous attachment
  analyses. Compatible noun-like evidence is required rather than broad retagging.
  Adverb/argument attachment ambiguity cannot be solved reliably from endings.
- Implementation: shared `nominal_infinitive_rows()` and noun-category routing
  in `R/features_coordination_negation.R`, exclusions in
  `R/features_subordination.R`, nominal-subject support in
  `R/features_tense_pronouns.R`, and registry/pipeline wiring. Added the common
  identity list and two public examples while preserving all prior resource
  fields/example rows. There are seven compatibility zeros, 60 detectable
  features, 58 occurrence-evidence features and 50 strict-evidence features.
- French's inspected f_15 currently counts verbal Ger/Part-Pres forms without
  requiring nominal use, plus an en/-ant fallback. That is not copied as a
  nominal definition; French alignment remains a separate follow-up.
- Regression-first tests reproduced missing nominal detections and unresolved
  noun/infinitive routing. The nominal-infinitive contract now passes 48
  expectations, including both native models and shipped positive/negative
  examples. Registry, occurrence coverage and output-contract tests also pass.
- Exact comparison with the installed D-22 package covers 46 documents per
  parser (92 document/parser results), including earlier f_09/f_12 corpora.
  Every column outside f_14/f_15/f_16/f_24, its raw and normalized values,
  occurrence evidence, lexical metrics and column ordering are unchanged.
  Source inputs are unchanged and no f_15 identity appears in competing noun
  or verbal-infinitive evidence. The intended recovered-nominal-subject f_09
  exclusion is covered separately by the gold regression.
- Installed-package validation with Spanish-GSD and es_core_news_sm:
  **1,679 passing expectations, five expected skips, zero failures/warnings**.
  `R CMD check --no-manual` completed with **Status: OK**, including documentation,
  installed examples and rebuilt vignettes; no errors, warnings or notes.
  The five skips remain the development-only YAML source, On-CRAN example suite,
  accepted f_50 noise, and two documented UDPipe limitations. No commits were made.

### 2026-11-08: Exclusive pied-piping policy

- Decision ID: D-24; related pending decision D-09.
- The user selected pied-piping as a separate category without overlap with
  other relative categories. A nominal relative such as `las razones de las
  cuales habla` belongs to f_33 only, not additionally f_32.
- Spanish already excludes f_33 occurrence identities from f_29/f_30.
  Proposed f_31/f_32 activation must preserve that precedence and test the
  same occurrence-level exclusions. Sentential relatives remain a distinct
  scope; recognition must not duplicate an occurrence across relative bins.
- The inspected French implementation can count the same `dont` in both
  f_32 and f_33. That is a companion alignment follow-up, not a policy to copy
  into Spanish or authorization to modify French now.
- No detector changes were made at this step. D-09 remains pending for the
  proposed que versus quien/cual family partition and reliable role assignment.
  Parser probes already show subject/object conflicts and missed clause
  attachments, so splitting marker inventories alone is not a complete repair.

### 2026-11-08: Four-way Spanish relative partition

- Decision IDs: D-25 and D-24. The user authorized the remaining proposed
  family/role plan after choosing exclusive pied-piping.
- f_29/f_30 now count only que relatives; f_31/f_32 count quien/quienes and
  cual/cuales in subject/object-complement roles. Articles before que stay
  in its family. Commas do not select a category, and these bins are not
  translations of English that/wh or a restrictive/nonrestrictive contrast.
  Family frequencies remain language-sensitive; pooled non-pied subject/object
  totals offer a more functional comparison, subject to parser coverage.
- A shared classifier requires a nominal NOUN/PROPN antecedent and relative
  attachment. Native finite appos attachments receive narrow recovery with
  an explicit PRON relative and Rel morphology; appos alone or interrogative
  morphology is insufficient. Free relatives and indirect questions are not
  moved into nominal bins; sentential f_34 retains its distinct scope.
- Explicit subject/object roles are preserved except bounded contradictions.
  A separate uncoordinated nsubj repairs the native cual/Maria double-subject
  error. Singular relative and singular antecedent morphology against a finite
  first/second-person plural predicate supports an object reading; person
  alone does not. Coordinated subjects block these repairs, including legitimate
  plural first-person relative subjects. No source annotations are rewritten.
- Roleless SCONJ/mark que no longer defaults to subject merely because another
  subject is absent. Positive finite intransitive support comes from the bounded
  relative_subject_intransitives list, or locative estar with an en-marked
  oblique; another subject supports an object reading. Unresolved gaps are
  unclassified. This intentionally reduces prior guessed f_29 counts, including
  GSD's La novela que lei example (lei is ADV, relative head larga is ADJ).
  The small positive-support list is not a comprehensive valency lexicon.
- f_33 takes precedence over f_34 and all four nominal bins by occurrence
  exclusions; f_34 also precedes nominal bins. Each selected relative word
  belongs to one relative feature. Counts/audits use the same rows.
- Changed the shared relative block, registry and pipeline argument, added
  positive intransitive support and four public examples, preserving prior
  resource fields/example rows. There are five compatibility zeros, 62
  detectable features, 60 occurrence-evidence features and 52 strict-evidence
  features. French's overlapping dont policy remains a separate follow-up.
- Regression-first tests reproduced merged-family counts, incorrect subject
  assignments, guessed roleless gaps and missed native appos attachments.
  The relative-partition contract passes 55 expectations, including controlled
  role/coordination/boundary cases, both native parsers and shipped examples.
  Registry, clause, historical, occurrence-coverage and output tests also pass;
  existing f_09/f_12/f_15 contracts remain green.
- Exact comparison with the installed D-23 package covers 62 documents per
  parser (124 document/parser results), including earlier f_09/f_12/f_15 corpora.
  All columns outside f_29/f_30/f_31/f_32, their raw and normalized values,
  occurrence evidence, lexical metrics, column order and original inputs
  are unchanged. No selected identity occurs in more than one f_29-f_34 bin.
- Installed-package validation with Spanish-GSD and es_core_news_sm:
  **1,744 passing expectations, five expected skips, zero failures/warnings**.
  `R CMD check --no-manual` completed with **Status: OK**, including installed
  examples, documentation and rebuilt vignettes; no errors, warnings or notes.
  The five skips remain development-only YAML, the On-CRAN example suite,
  accepted f_50 noise and two documented UDPipe limitations. No commits were made.

### 2026-11-08: Spanish colloquial contraction/reduction baseline

- Decision ID: D-26. The user approved implementing f_59 first under the
  proposed bounded colloquial-reduction contract, then settling f_60/f_62
  separately. Genuine f_61 stranding remains distinct from exclusive f_33.
- f_59 now recognizes the static colloquial_contractions inventory: pa and
  apostrophized/joined forms, onde/nde/onde's/ontas, and ta/tas/toy/tábamos.
  This measures the colloquial written
  reduction function, including single-word elisions like French p'tit,
  rather than requiring every contraction to fuse two grammatical words.
  It does not generate an entire estar paradigm or arbitrary vowel deletion.
- One longest recognized expression counts once. Ontas contributes one and
  pa'ca'rriba one, giving two for the user's sentence. A lookup-only apostrophe
  normalization and compiled boundary variants support straight/curly marks
  and native fragments. Shared surface_matches() supplies maximal spans;
  E1 and audits retain the original supplied surfaces, first-token annotations
  and positional spans. Pa prefixes are not counted again inside longer matches.
- Native probes show GSD pa' tagged PUNCT plus rriba, pa'ca' plus rriba,
  pa'cá as ADV, and incorrect estar lemmas; spaCy retains some joined forms
  but can tag an apostrophe PROPN. Surface recognition is therefore not gated
  on VERB or lemma estar. No token is retagged, expanded or invented.
  Source denominator differences remain visible; a zero-word document retains
  the established undefined-rate warning and NA.
- Standard al/del, unreduced words, generic apostrophes/proper names, reductions
  in preceding directly attached determiner contexts such as un toy, and short
  uppercase nominal/acronym-tagged forms are excluded. Uppercase VERB/AUX
  reductions remain eligible. This is bounded lexical/structural evidence,
  not exhaustive semantic disambiguation of homographs or all-caps chat.
- Implementation: contraction block and pattern compiler in
  R/features_coordination_negation.R, existing determiner/surface-match/evidence
  helpers, pipeline wiring, registry activation and one added resource field.
  Added three public examples while preserving all prior word-list fields and
  example rows. There are four compatibility zeros, 63 detectable features,
  61 occurrence-evidence features and 53 strict-evidence features.
- Corrected reduced-form documentation: finite que omission is not generally
  impossible, and interrupted preposition–infinitive phrases may offer a
  functional f_62 counterpart. Neither detector was activated here. French
  contraction/POS shortcomings and mislabelled f_61 remain separate follow-ups.
- Regression-first tests reproduced zero counts and absent span evidence.
  The contraction contract now passes 43 expectations, including both native
  parsers, public positive/negative examples, apostrophe variants, fragmented
  spans, count/audit agreement, nominal/acronym guards and zero-word rates.
- Exact comparison with the checked pre-contraction package across 142
  document/parser results preserves every raw/normalized column except f_59,
  all other evidence, column/document order, denominators, lexical metrics
  and inputs. No duplicate f_59 anchors were produced. Existing resource
  fields and public example rows were preserved exactly.
- Combined contraction/registry/coverage/output tests pass. Model-enabled
  installed validation reports 1,791 passing expectations, five expected skips
  (development YAML, on-CRAN example suite, accepted f_50 baseline noise and
  two UDPipe limitations), zero failures and zero warnings.
  R CMD check --no-manual finishes Status: OK without notes/warnings/errors;
  help files and examples are rebuilt, and git diff --check passes.

### 2026-11-08: Bounded Spanish complement reduction

- Decision ID: D-27. The user corrected the initially proposed finite-only
  definition: the category should capture reduced constructions functionally,
  not enforce one-to-one literal complementizer deletion. They accepted a
  bounded complement-reduction starting point, including Pienso ir and
  Creo haber entendido. This does not claim equivalent meanings, informality,
  actual deletion or resolved subject coreference.
- The implementation begins with reduced_complement_predicates containing
  creer, pensar and esperar. Direct ccomp/xcomp clauses under lexical VERB
  governors qualify when their head or attached aux/cop projects Fin/Inf.
  Participial/nonverbal heads can therefore represent compound/copular clauses.
  Clear conj chains inherit the governor and introducer context. Each identified
  clause head contributes one occurrence; shared-auxiliary participial conjuncts
  without their own licensed form are not recovered at this stage.
- Overt mark/SCONJ introducers and accented interrogative introducers exclude
  their clause. Coordinated clauses inherit an introducer from their parent,
  but an inner clause's que does not suppress a qualifying outer complement.
  Nominal infinitives use the shared f_15 selector and are excluded, as are
  unrelated infinitives, adjuncts, subjects, relatives and unlicensed forms.
  Other lexical governors and adjectival complements remain outside this
  starting inventory. Reduced participial relatives remain in their own features.
- f_24 counts infinitive form independently. Its overlap with infinitival f_60
  is intentional, unlike the mutually exclusive noun/verbal-infinitive partition
  or the exclusive relative bins. Puedo ir does not qualify, while the outer
  lexical complement in Creo poder ir may qualify as a single reduced complement.
- Native probes establish Pienso ir, Creo haber entendido, Pienso estar listo,
  coordination, mixed overt/unmarked clauses and Nosotros esperamos lleguen
  mañana in both models. Both misanalyse isolated Espero estén bien and Espero
  hayan llegado, losing the qualifying governor. spaCy additionally loses some
  finite complement attachments (obj/advmod/root), while GSD retains them.
  Tests explicitly preserve these misses rather than fabricate attachments.
- spaCy tags cómo in Pienso cómo resolverlo as PRON/PronType=Ind. Shared
  interrogative inventory supports a surface-based f_60 exclusion, while f_23
  retains its existing strict POS/morphology contract. No source tag is rewritten.
- Implementation: block_reduced_complements_es and the extracted shared
  interrogative_clause_tokens helper in R/features_subordination.R; pipeline,
  registry and one added lexical resource field. E1/audits anchor the original
  supplied clause head. Three compatibility zeros, 64 detectable features,
  62 evidence features and 54 strict-evidence features remain.
- Gold tests reproduce the former zero counts and missing audits, then cover
  both reduction forms, auxiliary/copular projection, overt/wh exclusions,
  intentional f_24 overlap, nominal exclusion, coordination, nested clauses
  and sentence/document/noncontiguous-ID boundaries. Added five public examples
  and native model coverage; existing data fields/rows are preserved.
- The reduced-complement contract passes 37 expectations, including gold
  structures, both native models, five public examples, count/audit agreement,
  normalized rates and source-annotation preservation. Overt que/relative
  introducers remain excluded even with mistagged dependencies.
- Exact comparison with the checked pre-f_60 package preserves every
  raw/normalized column except f_60 across 182 document/parser results, plus
  all other evidence, column/document order, denominators, lexical metrics
  and inputs. No duplicate reduction anchors were produced. Existing word-list
  fields and public example rows were preserved exactly.
- Combined reduction/registry/coverage/output tests pass. Model-enabled installed
  validation reports 1,832 passing expectations, five expected skips
  (development YAML, on-CRAN example suite, accepted f_50 baseline noise and
  two UDPipe limitations), zero failures and zero warnings.
  R CMD check --no-manual finishes Status: OK without notes/warnings/errors;
  generated help, examples and vignettes pass, and git diff --check is clean.

### 2026-11-08: Adverb-interrupted Spanish infinitive units

- Decision ID: D-28. The user approved the proposed linked preposition-adverb-
  infinitive scope, then corrected the form's initial negation selection:
  "I'm sorry. I think we should exclude negation-only cases?" The later
  instruction governs: para no volver and para nunca volver are excluded;
  para no realmente volver qualifies because a non-negative adverb intervenes.
- This is a functional discontinuity analogue, not splitting the Spanish
  infinitive word or inferring deleted material/informal register. French uses
  selected ADP + one to three fillers with at least one ADV + Inf; English uses
  to + adverb(s) + infinitive. Their negation-inclusive heuristics and French's
  broad PRON/DET filler allowance are not copied. Companion alignment of the
  approved negation-only exclusion remains a later task.
- Require a verbal Inf with an introductory ADP and a contiguous adverbial
  interruption. At least one adverb must not be in the existing negation
  inventories. Negative ADV/PART may accompany it. No arbitrary token cap;
  other POS, subjects and punctuation break the pattern. Shared nominal-
  infinitive rows are excluded. Multiword adverbials with other POS and shared
  coordination without a repeated matching unit remain outside this baseline.
- Preposition mark/case must link to the infinitive or its auxiliary/copular
  clause head. An intervening advmod chain to that head can mediate case;
  bounded fixed introductory marker links are supported. No proximity-only
  repair is used when attachments point to unrelated/matrix predicates.
- Native probes show GSD mejor tagged ADJ/fixed and spaCy siquiera NOUN/fixed
  in clear linked contexts. A two-form split_infinitive_adverb_fallbacks field
  supplies lookup-only recovery, retaining source POS and all other features.
  spaCy also attaches de/para case to intervening adverbs, and GSD can put a
  under vamos/PART/mark as fixed. Both models support compound/copular heads.
- Gold/native tests capture Trato de realmente comprender, sin siquiera mirar,
  a finalmente resolver and mixed negation/adverb spans. spaCy loses the
  infinitive link in para mejor entender and de muy lentamente comprender,
  attaching the adverb to the matrix predicate. Those documented misses are
  retained rather than fabricating a marker link. Correctly linked long
  advmod chains are supported, with cyclic paths safely left unmatched.
- Implementation: block_interrupted_infinitives_es in
  R/features_coordination_negation.R, pipeline/registry wiring and one new
  lexical resource field. E1/audits retain the original full matched
  preposition-through-infinitive span anchored at its first supplied token.
  Infinitival auxiliaries/copulas end the span at their own Inf word, not a
  following participle/adjective. Each expression counts once even with
  multiple adverbs. f_24 and legitimate f_63 overlap remain independent.
- There are two compatibility zeros (f_28/f_61), 65 detectable features,
  63 evidence features and 55 strict-evidence features. Added five public
  examples while preserving existing resource fields and example rows.
- The interrupted-infinitive contract passes 39 expectations, covering both
  annotation interfaces, native models, full-span evidence/audit agreement,
  exact normalized rates, long adverb runs, negation-only exclusion, mixed
  negation/adverbs, marker paths, compound/copular forms, nominal exclusion,
  sentence/document/noncontiguous-ID boundaries and five public examples.
- Exact comparison with the checked pre-f_62 package preserves every
  raw/normalized column except f_62 across 212 document/parser results, plus
  all other evidence, column/document order, denominators, lexical metrics
  and inputs. No duplicate span anchors were produced. Existing word-list
  fields and public example rows were preserved exactly.
- Combined interruption/registry/coverage/output tests pass. Model-enabled
  installed validation reports 1,875 passing expectations, five expected skips
  (development YAML, on-CRAN example suite, accepted f_50 baseline noise and
  two UDPipe limitations), zero failures and zero warnings.
  R CMD check --no-manual finishes Status: OK without notes/warnings/errors;
  generated help, examples and vignettes pass, and git diff --check is clean.

### 2026-11-08: Resumptive prepositional-relative functional counterpart

- Decision ID: D-29, functional mapping accepted in principle under D-30,
  bounded detection rules pending, not implemented. The user suggested English
  the guy I was talking about, French le mec que j'ai parlé de lui, and
  Spanish el chico que hablé de él as functional counterparts, with
  pied-piping unchanged in all three languages.
- The French/Spanish examples are resumptive prepositional relatives, not
  literal stranding: the postverbal PP has an overt pronoun understood to
  resume the nominal antecedent. English stranding instead leaves the
  preposition without an overt object at that position. This offers a
  non-fronted relative-complement contrast with pied-piping, not identical
  grammatical licensing/register. The resumptive examples are colloquial or
  marked in standard writing; English stranding is not inherently informal.
- A future Spanish scope must require evidence that the PP/pronoun resumes
  the antecedent. El chico que habló de él may be an ordinary subject relative
  about a boy who talked about somebody else. An ordinary object relative
  can also contain an unrelated PP/pronoun. Unrestricted que plus PP matching
  would therefore inflate f_61. Investigate clause roles, bounded predicate-
  preposition frames and compatible pronoun/antecedent morphology; do not
  claim unrestricted semantic coreference resolution.
- Keep f_33 unchanged and do not relabel fronted preposition-relative forms
  as resumption. Before implementation, settle interaction with the four
  nominal-relative bins so a parser-assigned que role does not turn a
  resumptive construction into an ordinary gap-relative count.
- French follow-up requested: revise/review f_61 independently of pied-piping.
  The inspected block_stranded_split_fr currently selects ADP immediately
  before relative/interrogative qui/quoi, not a later resumptive PP/pronoun.
  That heuristic is not the functional counterpart proposed here. Preserve
  French f_33; do not change French code in the Spanish baseline task.
- Added the proposed mapping and explicit French follow-up to README.
  Spanish f_61 remains a compatibility zero. No detector, resource, example
  count or package output was changed; this step is documentation only.

### 2026-11-08: Competing-form guardrail for reduced constructions

- Decision ID: D-30. The user stated: "With all features in this group, I think
  the idea is there MUST be competing forms." They identified less formal or
  less standardized forms as the group's orientation. This is the functional
  alignment anchor, not a requirement for identical morphology, syntax or
  grammatical licensing in every language.
- Working contrasts: unreduced versus colloquially reduced spellings (f_59);
  fuller versus reduced complement constructions (f_60); fronted prepositional
  relativization versus non-fronted stranding/resumption (f_61); adjacent
  versus adverb-interrupted preposition-infinitive units (f_62).
- These contrasts motivate the grouping without claiming that every reduced
  or interrupted occurrence is informal, nonstandard, semantically identical
  to its alternative, or produced by literal deletion. Standard English
  stranding and marked French/Spanish resumption can serve corresponding
  sides of a structural competition without identical register distributions.
- This supports D-29's resumptive counterpart in principle. Keep f_33 unchanged
  and distinguish true resumption from ordinary relatives with unrelated
  PP/pronouns. Scientific scope acceptance does not activate a detector before
  those operational boundaries are settled.
- Updated README and the decision record only; no package output changed.

### 2026-11-08: Bounded Spanish resumptive prepositional relatives

- Decision ID: D-31, implementing the functional mapping and competing-form
  guardrail in D-29/D-30. The user authorized proceeding after discussion of
  ordinary relatives with unrelated PP/pronouns. English stranding and marked
  French/Spanish resumption are functional competitors to pied-piping, not
  claims of identical grammar/register.
- Initial resumptive_prepositional_frames: hablar_de, depender_de, confiar_en.
  Require a nominal antecedent and unaccented que in the shared relative
  classifier, with a finite lexical predicate or finite auxiliary projection.
  First/second-person morphology or an external subject must rule out an
  ordinary que-subject interpretation. Coordinated relative subjects and
  overt bare objects are excluded. Hablar con is deliberately outside the
  scope because el idioma que hablé con él can be an ordinary object relative.
- Require a postverbal, directly linked case-marked PP with tonic
  él/ella/ellos/ellas; source obl/nmod/obj/iobj labels are accepted only with
  that overt prepositional link. Known gender/number conflicts exclude a match.
  This is bounded structural evidence, not unrestricted coreference resolution:
  unknown metadata, natural versus grammatical gender, and other lexical/
  semantic ambiguities remain limitations.
- Count one occurrence per identified relative clause, selecting its first
  matching PP even if pronouns repeat. E1/audits preserve the original two-token
  PP span anchored at its preposition. Detected resumptive que occurrences leave
  f_29/f_30 gap-relative bins. Existing f_33/f_34 precedence and f_31/f_32
  behavior remain unchanged; a fronted PP with a later pronoun stays in f_33.
- Native probes establish the user's sentence and plural, feminine, external-
  subject, compound and repeated-PP cases. GSD tags confié with wrong lemma/
  person, while spaCy can tag hablé NOUN or use lemma habler. Exact
  resumptive_first_person_forms pairs hablé_hablar and confié_confiar recover
  these unambiguous first-person preterites for f_61 only. Source POS, lemma
  and morphology, noun/verb counts, token populations and lexical metrics are
  not rewritten. Both models misanalyse hablaste as hablastir/person 3; that
  unlisted error remains a documented miss rather than broad paradigm repair.
- Implementation: resumptive_relative_rows and shared pair lookup in
  R/features_subordination.R, integrated into block_relatives_es after existing
  exclusions; pipeline/registry wiring and two new lexical resource fields.
  Added six public examples, preserving prior resource fields/example rows.
  The sole compatibility zero is f_28; 66 detectable features, 64 evidence
  features and 56 strict-evidence features remain.
- Regression-first gold tests reproduced zero f_61 counts, absent PP audits
  and inappropriate ordinary-relative membership. Tests cover both interfaces,
  competing/ordinary relatives, known agreement conflicts, finite auxiliary
  projection, overt objects, relative-subject coordination, lookup-only recovery,
  repeated PP counting and supplied document/sentence/noncontiguous-ID boundaries.
  French revision remains recorded but no companion detector is changed.
- Validation: all 45 resumptive-relative contract expectations pass, including
  both native parsers. Preservation checks cover 252 document/parser results:
  only f_61 and its required f_29/f_30 exclusions change; other counts/evidence,
  pied-piping, word populations, metrics and supplied annotations remain exact.
  The installed suite passes 1,924 expectations with five expected skips and
  no failures or warnings. `R CMD check --no-manual` reports `Status: OK`;
  `git diff --check` is clean.

### 2026-11-08: Spanish resource repairs, tense mood and f_28 retention

- Decision IDs: D-32, D-33, D-34, D-35.
- Status: Implemented and verified for Spanish.
- Resource defects (bug fixes, no definition change): the builder read YAML 1.1
  booleans, storing `no` as `false` in `neg_analytic_adverbs`, and flattened the
  nested `coordinating_conjunctions` map into deparsed strings. It now preserves
  boolean words and flattens nested lists. Unused lists were removed:
  `verb_matchlist`, the five subordinator lists, `coordinating_conjunctions`,
  `prepositions_simple`, `gerund_stoplist`, `adverb_mente_stoplist`. Unused
  `negation_adverbs` arguments were removed. No count changed: `no` was already
  supplied by `negation_particles`. The f_11 dictionary key is now plural.
- f_20 (coverage fix within the existing existential-haber definition): replaced
  platform-dependent `iconv(ASCII//TRANSLIT)` with stringi; added perfect
  `ha habido` and infinitival `puede haber` (GSD `csubj`). Auxiliary haber stays
  excluded by its dependency relation.
- f_03 (D-33): the present subjunctive now counts.
- Accent twins (D-34): generated in `data-raw/build_spanish_data.R`.
- f_28 (D-35): briefly activated as Ger + acl with a nominal head, then reverted.
  The specifying postnominal gerund (`una caja conteniendo libros`) is
  normatively incorrect in standard Spanish (RAE/ASALE, NGLE) and mostly a calque;
  accepted uses (lexicalized hirviendo/ardiendo, captions, predicative gerunds
  after perception/representation verbs) are not reduced relatives, and the
  relative function is already counted in f_29-f_32. The activation lacked a
  sufficient rationale and confirmation, which motivated D-32.
- Corrected the public f_42 example to 2 under D-15.
- Validation: full suite with Spanish-GSD and live es_core_news_sm passes with
  four expected skips; `R CMD check --no-manual` reports `Status: OK`.
- Remaining: README restructuring deferred until after the French refactor.

### 2026-11-09: French evidence-based refactor and defect repairs (review group A)

- Decision IDs: D-01, D-02, D-04, D-05, D-06, D-13 (ported); D-32 respected.
- Finding IDs: F-01, F-02, F-03, F-04, F-05, F-06, F-09 (French).
- Status: Implemented and verified in French. No feature scope changes from
  review groups B/C; those await the user's decisions.
- Architecture: French now follows the Spanish design. `prepare_parsed_tokens()`
  produces one row per UD word; every block emits evidence rows; counts are
  tabulated from evidence; `audit_features()` returns those rows. The 2,000-line
  separate audit implementation was removed. Neighbour checks are sentence-local.
- Defects fixed within existing definitions: see `pseudobibeR.fr/NEWS.md`. Notable
  French-specific findings:
  - UDPipe French-GSD 2.5 lemmatizes je/tu/nous/elle as `il`, so the old
    lemma-based f_09 counted most subject pronouns as impersonal, and its
    "any clausal dependent" condition accepted referential `il dit que`.
    f_09 now matches surface forms and requires an impersonal predicate;
    meteorological faire requires a weather complement, parallel to Spanish D-21.
  - UDPipe marks `où` as `PronType=Rel` even in questions, so relative
    exclusion for f_13/f_23 uses the clause relation (`acl`), not morphology.
  - UDPipe French-GSD 2.5 cannot parse typographic apostrophes (`L’ami` becomes
    one proper name); still to be documented for users.
- Spanish defect found during the port: f_21 required the complement clause to
  be headed by a verb, missing copular clauses (`Creo que es una buena idea`).
  Fixed and tested in Spanish.
- Validation: old/new comparison on 260 edge-case and example documents; every
  changed count was inspected. Public example accuracy is unchanged (160/181);
  four newly correct, four newly missed: two UDPipe misparses previously masked
  by heuristics (`Elle était partie`, `La maison construite`) and two `ce que/ce
  qui` indirect questions (see open question). Edge-case fixture regenerated.
  New contract tests cover count/audit equality, sentence identity, resource
  masking, YAML integrity, denominator, f_43/f_44 and UDPipe probes. French
  `R CMD check --no-manual`: Status OK. Spanish suite with live spaCy passes.
- Open question for the user: French expresses indirect "what"-questions with
  `ce que/ce qui` (`Je ne sais pas ce qui s'est passé`), formally free relatives.
  Under the deferral of free relatives (decision 9) they no longer count in f_23.
- Remaining: review groups B and C; README restructuring for all packages.

### 2026-11-09: Recommended pre-processing pipeline (documentation note)

- Decision ID: D-36, accepted; documentation to be written later.
- Rationale: UDPipe French-GSD 2.5 cannot parse typographic apostrophes.
  `L’ami d’Anne arrive` is parsed as one proper name; `Il s’est levé` is
  parsed as a passive. With ASCII apostrophes both parse correctly (`L'` DET,
  `d'` ADP; `est` aux:tense). `biber()` receives parsed tokens and cannot repair
  the text before tagging, so normalization belongs in the user's pipeline.
- Tool: `utf8::utf8_normalize(text, map_quote = TRUE)`. `utf8` has no
  dependencies and is already required by `readtext`, `tibble` and `dplyr`.
  Verified: maps ’ and ‘ to ', applies NFC (composed accents), preserves
  accents and ñ, and leaves double quotes and « » unchanged. Not recommended:
  `textclean` (heavy dependencies; `replace_non_ascii()` strips accents) and
  `stringi::stri_trans_general(x, "Latin-ASCII")` (strips accents).
- Sample pipeline for the READMEs/vignettes (all three languages):

  ```r
  library(readtext)
  library(quanteda)

  docs <- readtext("corpus/*.txt", encoding = "UTF-8")
  docs$text <- utf8::utf8_normalize(docs$text, map_quote = TRUE)
  corp <- corpus(docs)

  # Parse with udpipe or spacyr, then:
  # features <- pseudobibeR.fr::biber(parsed)
  ```

- The in-package apostrophe tolerance (matching both ' and ’) is retained as a
  fallback for unnormalized input, notably spaCy output.

### 2026-11-09: Free relatives, output schema, denominator, input types

- Decision IDs: D-37, D-38, D-39.
- Status: Implemented and verified in Spanish and French; English already conforms
  to D-38/D-39.
- f_23 (D-37): French `ce` + que/qui and Spanish `lo` + que, not sentence-initial,
  not after punctuation, as an argument (obj/nsubj/ccomp/xcomp/csubj) of a lexical
  verb. Spanish-GSD also attaches such clauses as a que-marked ccomp of the verb;
  that path is accepted and the que leaves f_21 (previously miscounted as a
  complementizer). Prepositional free relatives (`pris dans ce qui...`) are excluded,
  matching English verb adjacency. French pseudo-relatives (`je les ai vus qui
  arrivaient`) are excluded from f_23 by relative morphology on pronouns; adverbs
  keep their morphology-independent treatment because UDPipe marks interrogative
  `où` as Rel. French f_34 now requires preceding punctuation, as in Spanish.
- D-38: denominator `document_word_counts()` = word rows minus PUNCT/SYM/SPACE and
  tokens ending in a digit (the English `\d_` rule). Expectations changed only
  where fixtures contained numerals.
- D-39: tests now construct parser annotations (spacyr-class tables or genuine
  `udpipe_connlu` objects via `udpipe::as_conllu()`), or call explicit fixture
  helpers that use the internal extractor; exported functions reject plain data
  frames, with a regression test.
- Validation: full Spanish suite with Spanish-GSD and live es_core_news_sm and full
  French suite pass; French edge-case snapshot changes are limited to the
  reviewed f_23/f_34 cases.

### 2026-11-09: French port of accepted decisions (review group B)

- Decision IDs: D-15, D-22, D-24, D-25, D-33, D-34 applied to French.
- Status: Implemented and verified in French; Spanish received two parity
  safeguards (below).
- D-33 clarification: "every mood" means indicative and subjunctive. UDPipe French
  marks the conditional `Tense=Pres|Mood=Cnd`, which would otherwise count as
  present tense; English `would` is not VBZ/VBP and conditionals belong in f_54.
  Conditional and imperative are excluded from f_03 in French and Spanish.
- f_54: finite Tense=Fut or Mood=Cnd, plus aller (Pres/Imp) with an `xcomp`
  infinitive, matching Spanish future/conditional/ir a. `risquer de` and `être
  susceptible de` remain pending a scope decision (they express likelihood, which
  English f_54 does not include).
- f_42 (D-15): residual after removing words inside f_04/f_05/f_46/f_47/f_48
  occurrences, after the donc/ensuite/vraiment reassignment. Negation now counts,
  so `ne ... pas` contributes two adverbs (open question C3).
- Relatives (D-24/D-25): nominal relative = `acl` clause attached to NOUN/PROPN.
  Exclusive precedence f_33 > f_34 > nominal bins. French marks qui/que role by
  form. Consequence: French f_32 (lequel-family, non-subject, no preposition) is
  close to empty, because French object/oblique relatives use que, dont or a
  preposition; Spanish f_32 is likewise limited because personal objects take
  `a` (pied-piping). The three dont examples moved to f_33; dont's genitive use
  remains part of question C7.
- D-34: French twins generated by the builder with a French contrastive list
  (a, la, ou, du, des, sur, mur, cote, cite); nominalization suffixes stay exact
  (-ité must not yield -ite). Both builders now check contrastive collisions word
  by word inside phrases (tout_à must not yield tout_a); Spanish data unchanged.
- Validation: old/new snapshot changes limited to f_01 (+6), f_03 (+51), f_54
  (+8) and f_42 (8 up, 8 down), each inspected. French and Spanish suites pass.

### 2026-11-09: Modal scope rule (D-40)

- Status: Implemented and verified in French; English and Spanish already conform.
- Rationale: semantically, risquer de / être susceptible de express likelihood
  (epistemic possibility, closer to f_52 than to prediction), but neither the
  English (be likely/liable to) nor the Spanish counterparts are counted, so
  keeping them in any modal feature would add a French-only class. The user chose
  parallelism. risquer de remains a candidate French-specific addition to f_52 if
  revisited later.
- Validation: edge-case snapshot changes limited to the five periphrastic
  necessity/possibility cases; French suite passes; examples replaced with modal
  verb examples (Vous devez signer..., Elle partirait si...).

### 2026-11-09: French negation (D-41, D-42)

- Basis: biber_definitions.md (66: no + QUANT/ADJ/N, neither, nor, excluding reply no;
  67: not) and the user's D-18 reading of Tottie (negative word versus particle).
- Language-specific consequence: Spanish `No veo a nadie` gives f_66 = 1 and
  f_67 = 1, while French `Je ne vois personne` gives f_66 = 1 and f_67 = 0,
  because Spanish no is a full negator whereas French ne is a concord clitic.
  French ne-drop speech (`c'est pas grave`) is counted through pas.
- UDPipe evidence: `Je ne vois personne` tags personne NOUN; a determinerless
  personne in a sentence with ne is recovered for f_66 only (as Spanish PROPN
  nadie). `Si jamais tu viens` (ever) is excluded after si/à/que.
- Remaining limitations: ne-drop with plus/point (`j'en veux plus`) is not
  detected, since plus without ne is usually comparative; literary ne alone
  (`je ne sais`) is not counted; restrictive `ne ... que` adds ADV que to f_42.
- Validation: 16 UDPipe negation probes in the contract tests; snapshot changes
  limited to the intended negation and f_42 cases; examples updated (jamais moved
  to f_66).

### 2026-11-09: f_15 as nominal non-finite verbs (D-43)

- Decision and rationale: the user's principle is function, not form: f_15
  counts non-finite verb forms used as nouns. English uses -ing (`Running is
  good exercise`); Spanish and French use the infinitive (`Correr es un buen
  ejercicio`, `Courir est un bon exercice`). The Spanish gerund and the French
  gérondif/participe présent are not nominal, so they are excluded.
- Boundary: a preposed subject is unambiguously nominal; a postposed
  infinitival subject (`Es importante descansar`, `Il est important de se
  reposer`) is the extraposed-clause pattern that English counts as to-clause
  (f_24), so it stays f_24 in both languages.
- Language-specific detail: UDPipe French tags sentence-initial infinitives as
  PROPN nsubj (`Lire`, `Fumer`); identity comes from the verb inventories and
  `nominal_infinitive_lemmas`. UDPipe French also tags `en chantant` as NOUN obl
  about as often as VERB advcl; `gerondif_noun_rows_fr()` recovers those for
  f_25 (and removes them from f_16), guarded by `gerondif_noun_stoplist`
  (`en enfant`, `en tant que`, `en passant`).
- Compatibility impact: French f_15 no longer counts gérondifs; f_25 gains
  NOUN-tagged gérondifs. Spanish f_15 gains preverbal subject infinitives with a
  matching f_24 decrease.
- Validation: UDPipe probes in both languages; French edge fixture unchanged;
  both suites pass.

### 2026-11-09: French adverbial subordinators (D-44)

- Decision and rationale: Biber 35-37 list only subordinators that
  unambiguously mark cause, concession and condition; multifunctional ones
  are f_38. The French inventory now matches English (because; although,
  though; if, unless) and Spanish (porque; aunque; si, a menos que, salvo que).
- Indirect-question si: the user first approved a dependency-only rule (any
  ccomp/xcomp si-clause), also to be applied to Spanish. UDPipe probes showed
  that French-GSD attaches postposed conditionals as ccomp (`Je serais venu si
  tu m'avais appelé`, `Te serais-tu levé si…`), so dependency alone loses real
  conditionals. French therefore uses the Spanish rule (ccomp/xcomp + a listed
  question/knowledge governor), and Spanish was not changed. Accepted miss in
  both languages: indirect questions parsed as advcl (`Il ignore si elle est
  partie`).
- Coupled fix: f_60 no longer counts si-marked clauses as que-deletion; the
  broader f_60 scope (infinitival de/à complements) is left to C6.
- Validation: 15 UDPipe contract probes; edge fixture changes limited to one
  f_60 removal.

### 2026-11-09: French f_59 colloquial reductions (D-45)

- Decision and rationale: English contractions compete with full forms
  (won't / will not); f_59 measures that optional, informal choice. French
  standard elision is obligatory, so it is excluded; only reductions with an
  available full form count. Spanish (D-26) uses an inventory only because
  its reductions are lexically closed; French subject-clitic reductions (t',
  j') are productive, hence bounded rules.
- UDPipe evidence: `T'es` may split as T + ' + es; 1sg/2sg-ambiguous forms
  (avais, étais) are tagged Person=1, so the t' rule accepts 1/2sg finite
  hosts and relies on the absence of a preceding subject to exclude object or
  reflexive te (je t'avais dit, tu t'es trompé, ça t'a plu). `-t-il`
  splits as -t + -il.
- Not included: ne-drop (negation, D-41), phonetic spellings (ouais, ben),
  open-ended schwa drop (d'la, c'te).
- Validation: 38 UDPipe probes; 18 contract cases.

### 2026-11-09: f_60 reduced complements, French port and public verbs (D-46)

- Decision and rationale: f_60 captures a slice of competing realizations: a
  reduced complement where a que-clause is available with the same subject
  (je crois avoir compris / je crois que j'ai compris). Biber's governors are
  public, private and suasive verbs; the D-27 set was private only, so public
  verbs are added in both languages. Suasive dire de / decir de + infinitive
  is a command, keeps its preposition and is excluded.
- Pairing: dire/decir, affirmer/afirmar, prétendre/asegurar (closest, not
  exact). Spanish pretender is a false friend (intend, control) and excluded.
- Register: in English the reduced form is informal; Romance infinitival
  reduction after public verbs is typical of formal reporting. The user's
  view: this difference is what the cross-language comparison should reveal,
  not a reason to drop the analogue.
- French before: every unmarked ccomp/xcomp (vouloir, falloir, savoir,
  sembler, commencer à...) counted, duplicating f_24; the edge corpus lost all
  32 such rows and contains no in-scope governor.
- UDPipe limits: Spanish subjectless short sentences can misparse (`Afirma
  ser inocente` lemma afirma; `Asegura haberlo visto` parataxis); with an overt
  subject the parse is correct.
- Validation: French and Spanish probes; examples in both languages.

### 2026-11-09: French f_61 resumptive and orphan-preposition relatives (D-47)

- Defect fixed: French f_61 counted a preposition before qui/quoi (avec qui,
  sur qui), i.e. pied-piping, double-counted with f_33, contrary to D-29.
- Decision and rationale: f_61 counts the colloquial realization competing
  with pied-piping. French has three: the orphan preposition (genuine
  stranding, closer to English than any Spanish form), the resumptive PP
  (the Spanish D-31 analogue) and resumptive en with que (the competitor of
  dont). Spanish has no orphan prepositions or en clitic, so the French
  inventory is larger by language, not by choice.
- UDPipe evidence: colloquial relatives are parsed as object relatives (que
  obj) or misparsed (`sors` NOUN), so detection is surface-based within the
  relative (que after a noun, up to punctuation or the next relative marker).
  The frame or en verb must be the relative's first lexical verb, excluding
  main-clause verbs (`La femme que j'ai vue parlait d'elle`).
- Accepted limits: a main-clause orphan after a medial relative can be a false
  positive; questions (`Tu viens avec ?`) and the bare all-purpose que
  (`un truc que je me souviens plus`) are not counted.
- Validation: 25 UDPipe probes; edge fixture unchanged.

### 2026-11-09: French f_62 split infinitive (D-48)

- Question: is the English split infinitive a competing form in French, or a
  compatibility zero like Spanish f_28? Light adverbs normally precede the
  French infinitive, so their position cannot be the marked alternative.
- Corpus evidence (UD French-GSD, all splits, preposition-introduced
  infinitives, adverb attached to the infinitive, negation excluded): -ment
  adverbs 9 interrupted vs 70 postposed; mieux 8:1, bien 4:1, trop 1:0;
  manner adverbs never interrupt in the corpus (rapidement 0:4, directement
  0:4, facilement 0:3) but can (de rapidement partir). Interruptions found:
  de fortement augmenter, sans vraiment obtenir, de parfaitement connaître,
  pour finalement dépasser. Written news/wiki text, about 140 cases.
- Decision: count interruption by adverbs whose default position follows the
  infinitive; exclude light preinfinitival adverbs and negation-only. The
  mixed adverbs toujours/encore/déjà/ensuite count. Any linked preposition
  (sans, par, afin de) qualifies, as in Spanish.
- Defects fixed: negation-only (de ne pas venir) and light adverbs (pour
  mieux comprendre) were counted; sans/par were missed.
- Validation: 22 UDPipe probes; edge fixture unchanged.

### 2026-11-09: f_63 split auxiliary and negation (D-49)

- Decision and rationale: the 2026-11-08 default "French f_63 excludes
  negation-only" was refined against English: English f_63 counts ADV
  interveners, so never counts and not (PART) does not. Under the D-41
  partition, the French counterparts of not are ne/pas/point/plus (f_67)
  and of never is jamais (f_66). Exclude only the analytic negator as sole
  intervener, in French and Spanish (no).
- Light adverbs count (a bien mangé): unlike f_62, Biber's English pattern
  counts default mid-position adverbs, so no competing-order test applies.
- French defects fixed: negation-only counted (n'a pas mangé, a pas mangé);
  modal + adverb + infinitive missed (peut facilement résoudre).
- Accepted limits: UDPipe tags `partie` in `Elle est rapidement partie` as
  NOUN; Spanish-GSD tags the participle ADJ in the unusual `ha nunca mentido`.
- Validation: 14 French and 8 Spanish UDPipe probes; French edge fixture lost
  four f_63 rows (three negation-only, one inverted subject).

### 2026-11-10: French ce/ça and personal pronouns (D-50)

- Defects fixed: f_08 used any PRON with Person=3, so ce/c', ça, partitive en
  and generic on were third-person pronouns (C'est vrai -> f_08); f_10 listed
  ce but not c', so Ce n'est pas grave counted f_10 but C'est vrai did not;
  the ce of ce que/ce qui was counted in f_10 and in f_23/f_34.
- Decision: English f_10 includes "that's" and "those who"; French c'est and
  celui/ceux qui are their counterparts. c'est + ADJ + de/que clause is the
  colloquial form of il est ADJ de (anticipatory it), so it is f_09 only.
  Clefts are left in f_10: c'est X qui is ambiguous between cleft (it's X
  who) and presentational relative (that's the X who).
- on: generic on is counted nowhere, like English generic one; colloquial
  on = nous ("we") is lost, as it cannot be separated automatically.
- Validation: 19 UDPipe probes; edge fixture changes reviewed (sentence and
  free relative ce removed from f_10, presentational c'est added, on removed
  from f_08).

### 2026-11-10: English alignment pass (D-53)

- Verified against English code: denominator (digit-final and punctuation
  excluded), corpus-wide MATTR fallback, parser-object input, f_23 wh after a
  verb (covers what free relatives), f_63 ADV-only (never counts, not = PART
  does not) and output schema already match family decisions.
- Changed (en_core_web_sm probes): f_42 `very kind of him, maybe` 3 -> 0
  (amplifier, hedge phrase, hedge); f_44 now includes café/naïvely; f_62
  `to not go`/`to never go` 1 -> 0, `to not really go` stays 1.
- Not a defect: f_16 scalar subtraction with hyphenated nouns, since spaCy
  splits hyphens.
- Language-specific, documented: f_09 all it (French/Spanish restrict to
  impersonal subjects because il/elle are also he/she); f_12 all main-verb do,
  following Biber's algorithm (Spanish D-22 is narrower).
- Validation: sample-corpus outputs unchanged (no affected constructions);
  new test-family-alignment.R with spaCy-equivalent annotations; R CMD check
  OK. NEWS.md added (heading 1.3.9000; DESCRIPTION version not changed).

### 2026-11-10: Defect repairs from the French technical reference (D-55)

- Source: drafting `pseudobibeR.fr/FEATURES_TECHNICAL.md` against the code
  found 14 discrepancies; defects were fixed, documentation corrected.
- Family-wide: UDPipe splits contracted articles into words (FR du → de le,
  ES al → a el), so every dictionary phrase containing one could never match
  UDPipe output (FR au loin, du coup; ES al lado de, al final, del mismo
  modo). Phrases now compile both forms; spaCy keeps contractions as one word.
- French: f_20 (il n'y a, il y en a, y a; elle y a excluded), f_38 (de/à/pour
  + infinitive and en + gérondif excluded; ~25 edge-corpus rows), possessives
  in f_06–f_08 (English counts my/his/their), multiword verb entries, weather
  faire parsed as copula, f_37 à moins.
- Open, pending decisions: f_50 clause-initial position (ES and FR, Biber and
  English count clause-initial only); FR f_39 compound prepositions counted
  once (as ES); FR f_65 sentence-initial et (as ES).
- Validation: probes per fix; French and Spanish suites pass; edge fixture
  changes limited to f_38 infinitival markers and one possessive.

Use this structure for subsequent entries:

```text
### YYYY-MM-DD: short decision or implementation title

- Decision ID(s):
- Finding ID(s):
- Status: Accepted / Proposed / Superseded / Implemented / Verified
- Decision and rationale:
- Language-specific exceptions:
- Compatibility or migration impact:
- Implementation references:
- Validation performed and observed results:
- Remaining work / supersedes:
```
