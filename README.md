## Pseudo-Biber Aggregator

The R scipts in this repository aggregate the lexicogrammatical and functonal features described by Biber (1985) and widely used for text-type, register, and genre classification tasks.

The scripts are not really taggers. Rather, they use [spaCy](https://spacy.io/) part-of-speech tagging and dependency parsing to summarize and aggregate patterns.

Because they rely on spaCy, the accuracy of the resulting counts are dependent on the accuracy of tagging produced by spaCy. Thus, texts with irregular spellings, non-normative punctuation, etc. will likely produce unreliable outputs.

## Installing and Running pseudobibeR

Use devtools to install the package.

```r
devtools::install_github("browndw/pseudobibeR")
```

The main parsing function requires text processed using spacyr.

```r
library(spacyr)
library(pseudobibeR)

spacy_initialize()

# The package comes loaded with a small corpus, micusp_mini
# Here will take the first 10 texts and create a quanteda corpus object
micusp_corpus <- quanteda::corpus(micusp_mini[1:10,])

# Parse using spacyr; that that we need dependency set to TRUE
micusp_prsd <- spacy_parse(micusp_corpus, pos = T, tag = T, dependency = T, entity = F)

# Aggregate the features into a data.frame
df_biber <- biber_parse(micusp_prsd)
```



The following table is adapted from one created by [Stefan Evert](https://www.rdocumentation.org/packages/corpora/versions/0.5/topics/BNCbiber).

<table><tbody><tr><td>
     </td>
<td> <b>A. Tense and aspect markers</b> </td>
</tr><tr><td>
     <code>f_01_past_tense</code> </td>
<td> Past tense </td>
</tr><tr><td>
     <code>f_02_perfect_aspect</code> </td>
<td> Perfect aspect </td>
</tr><tr><td>
     <code>f_03_present_tense</code> </td>
<td> Present tense </td>
</tr><tr><td>
     </td>
<td> <b>B. Place and time adverbials</b> </td>
</tr><tr><td>
     <code>f_04_place_adverbials</code> </td>
<td> Place adverbials (e.g., <em>above, beside, outdoors</em>) </td>
</tr><tr><td>
     <code>f_05_time_adverbials</code> </td>
<td> Time adverbials (e.g., <em>early, instantly, soon</em>) </td>
</tr><tr><td>
     </td>
<td> <b>C. Pronouns and pro-verbs</b> </td>
</tr><tr><td>
     <code>f_06_first_person_pronouns</code> </td>
<td> First-person pronouns </td>
</tr><tr><td>
     <code>f_07_second_person_pronouns</code> </td>
<td> Second-person pronouns </td>
</tr><tr><td>
     <code>f_08_third_person_pronouns</code> </td>
<td> Third-person personal pronouns (excluding <em>it</em>) </td>
</tr><tr><td>
     <code>f_09_pronoun_it</code> </td>
<td> Pronoun <em>it</em> </td>
</tr><tr><td>
     <code>f_10_demonstrative_pronoun</code> </td>
<td> Demonstrative pronouns (<em>that, this, these, those</em> as pronouns) </td>
</tr><tr><td>
     <code>f_11_indefinite_pronoun</code> </td>
<td> Indefinite pronounes (e.g., <em>anybody, nothing, someone</em>) </td>
</tr><tr><td>
     <code>f_12_proverb_do</code> </td>
<td> Pro-verb <em>do</em> </td>
</tr><tr><td>
     </td>
<td> <b>D. Questions</b> </td>
</tr><tr><td>
     <code>f_13_wh_question</code> </td>
<td> Direct <em>wh</em>-questions </td>
</tr><tr><td>
     </td>
<td> <b>E. Nominal forms</b> </td>
</tr><tr><td>
     <code>f_14_nominalization</code> </td>
<td> Nominalizations (ending in <em>-tion, -ment, -ness, -ity</em>) </td>
</tr><tr><td>
     <code>f_15_gerunds</code> </td>
<td> Gerunds (participial forms functioning as nouns) </td>
</tr><tr><td>
     <code>f_16_other_nouns</code> </td>
<td> Total other nouns </td>
</tr><tr><td>
     </td>
<td> <b>F. Passives</b> </td>
</tr><tr><td>
     <code>f_17_agentless_passives</code> </td>
<td> Agentless passives </td>
</tr><tr><td>
     <code>f_18_by_passives</code> </td>
<td> <em>by</em>-passives </td>
</tr><tr><td>
     </td>
<td> <b>G. Stative forms</b> </td>
</tr><tr><td>
     <code>f_19_be_main_verb</code> </td>
<td> <em>be</em> as main verb </td>
</tr><tr><td>
     <code>f_20_existential_there</code> </td>
<td> Existential <em>there</em> </td>
</tr><tr><td>
     </td>
<td> <b>H. Subordination features</b> </td>
</tr><tr><td>
     <code>f_21_that_verb_comp</code> </td>
<td> <em>that</em> verb complements (e.g., <em>I said that he went.</em>) </td>
</tr><tr><td>
     <code>f_22_that_adj_comp</code> </td>
<td> <em>that</em> adjective complements (e.g., <em>I'm glad that you like it.</em>) </td>
</tr><tr><td>
     <code>f_23_wh_clause</code> </td>
<td> <em>wh</em>-clauses (e.g., <em>I believed what he told me.</em>) </td>
</tr><tr><td>
     <code>f_24_infinitives</code> </td>
<td> Infinitives </td>
</tr><tr><td>
     <code>f_25_present_participle</code> </td>
<td> Present participial adverbial clauses (e.g., <em>Stuffing his mouth with cookies, Joe ran out the door.</em>) </td>
</tr><tr><td>
     <code>f_26_past_participle</code> </td>
<td> Past participial adverbial clauses (e.g., <em>Built in a single week, the house would stand for fifty years.</em>) </td>
</tr><tr><td>
     <code>f_27_past_participle_whiz</code> </td>
<td> Past participial postnominal (reduced relative) clauses (e.g., <em>the solution produced by this process</em>) </td>
</tr><tr><td>
     <code>f_28_present_participle_whiz</code> </td>
<td> Present participial postnominal (reduced relative) clauses (e.g., <em>the event causing this decline</em>) </td>
</tr><tr><td>
     <code>f_29_that_subj</code> </td>
<td> <em>that</em> relative clauses on subject position (e.g., <em>the dog that bit me</em>) </td>
</tr><tr><td>
     <code>f_30_that_obj</code> </td>
<td> <em>that</em> relative clauses on object position (e.g., <em>the dog that I saw</em>) </td>
</tr><tr><td>
     <code>f_31_wh_subj</code> </td>
<td> <em>wh</em> relatives on subject position (e.g., <em>the man who likes popcorn</em>) </td>
</tr><tr><td>
     <code>f_32_wh_obj</code> </td>
<td> <em>wh</em> relatives on object position (e.g., <em>the man who Sally likes</em>) </td>
</tr><tr><td>
     <code>f_33_pied_piping</code> </td>
<td> Pied-piping relative clauses (e.g., <em>the manner in which he was told</em>) </td>
</tr><tr><td>
     <code>f_34_sentence_relatives</code> </td>
<td> Sentence relatives (e.g., <em>Bob likes fried mangoes, which is the most disgusting thing I've ever heard of.</em>) </td>
</tr><tr><td>
     <code>f_35_because</code> </td>
<td> Causative adverbial subordinator (<em>because</em>) </td>
</tr><tr><td>
     <code>f_36_though</code> </td>
<td> Concessive adverbial subordinators (<em>although, though</em>) </td>
</tr><tr><td>
     <code>f_37_if</code> </td>
<td> Conditional adverbial subordinators (<em>if, unless</em>) </td>
</tr><tr><td>
     <code>f_38_other_adv_sub</code> </td>
<td> Other adverbial subordinators (e.g., <em>since, while, whereas</em>) </td>
</tr><tr><td>
     </td>
<td> <b>I. Prepositional phrases, adjectives and adverbs</b> </td>
</tr><tr><td>
     <code>f_39_prepositions</code> </td>
<td> Total prepositional phrases </td>
</tr><tr><td>
     <code>f_40_adj_attr</code> </td>
<td> Attributive adjectives (e.g., <em>the big horse</em>) </td>
</tr><tr><td>
     <code>f_41_adj_pred</code> </td>
<td> Predicative adjectives (e.g., <em>The horse is big.</em>) </td>
</tr><tr><td>
     <code>f_42_adverbs</code> </td>
<td> Total adverbs </td>
</tr><tr><td>
     </td>
<td> <b>J. Lexical specificity</b> </td>
</tr><tr><td>
     <code>f_43_type_token</code> </td>
<td> Type-token ratio (including punctuation)</td>
</tr><tr><td>
     <code>f_44_mean_word_length</code> </td>
<td> Average word length (across tokens, excluding punctuation) </td>
</tr><tr><td>
     </td>
<td> <b>K. Lexical classes</b> </td>
</tr><tr><td>
     <code>f_45_conjuncts</code> </td>
<td> Conjuncts (e.g., <em>consequently, furthermore, however</em>) </td>
</tr><tr><td>
     <code>f_46_downtoners</code> </td>
<td> Downtoners (e.g., <em>barely, nearly, slightly</em>) </td>
</tr><tr><td>
     <code>f_47_hedges</code> </td>
<td> Hedges (e.g., <em>at about, something like, almost</em>) </td>
</tr><tr><td>
     <code>f_48_amplifiers</code> </td>
<td> Amplifiers (e.g., <em>absolutely, extremely, perfectly</em>) </td>
</tr><tr><td>
     <code>f_49_emphatics</code> </td>
<td> Emphatics (e.g., <em>a lot, for sure, really</em>) </td>
</tr><tr><td>
     <code>f_50_discourse_particles</code> </td>
<td> Discourse particles (e.g., sentence-initial <em>well, now, anyway</em>) </td>
</tr><tr><td>
     <code>f_51_demonstratives</code> </td>
<td> Demonstratives </td>
</tr><tr><td>
     </td>
<td> <b>L. Modals</b> </td>
</tr><tr><td>
     <code>f_52_modal_possibility</code> </td>
<td> Possibility modals (<em>can, may, might, could</em>) </td>
</tr><tr><td>
     <code>f_53_modal_necessity</code> </td>
<td> Necessity modals (<em>ought, should, must</em>) </td>
</tr><tr><td>
     <code>f_54_modal_predictive</code> </td>
<td> Predictive modals (<em>will, would, shall</em>) </td>
</tr><tr><td>
     </td>
<td> <b>M. Specialized verb classes</b> </td>
</tr><tr><td>
     <code>f_55_verb_public</code> </td>
<td> Public verbs (e.g., <em>assert, declare, mention</em>) </td>
</tr><tr><td>
     <code>f_56_verb_private</code> </td>
<td> Private verbs (e.g., <em>assume, believe, doubt, know</em>) </td>
</tr><tr><td>
     <code>f_57_verb_suasive</code> </td>
<td> Suasive verbs (e.g., <em>command, insist, propose</em>) </td>
</tr><tr><td>
     <code>f_58_verb_seem</code> </td>
<td> <em>seem</em> and <em>appear</em> </td>
</tr><tr><td>
     </td>
<td> <b>N. Reduced forms and dispreferred structures</b> </td>
</tr><tr><td>
     <code>f_59_contractions</code> </td>
<td> Contractions </td>
</tr><tr><td>               
     <code>f_60_that_deletion</code> </td>
<td> Subordinator <em>that</em> deletion (e.g., <em>I think [that] he went.</em>) </td>
</tr><tr><td>
     <code>f_61_stranded_preposition</code> </td>
<td> Stranded prepositions (e.g., <em>the candidate that I was thinking of</em>) </td>
</tr><tr><td>
     <code>f_62_split_infinitve</code> </td>
<td> Split infinitives (e.g., <em>He wants to convincingly prove that …</em>) </td>
</tr><tr><td>
     <code>f_63_split_auxiliary</code> </td>
<td> Split auxiliaries (e.g., <em>They were apparently shown to …</em>) </td>
</tr><tr><td>
     </td>
<td> <b>O. Co-ordination</b> </td>
</tr><tr><td>
     <code>f_64_phrasal_coordination</code> </td>
<td> Phrasal co-ordination (N <em>and</em> N; Adj <em>and</em> Adj; V <em>and</em> V; Adv <em>and</em> Adv) </td>
</tr><tr><td>
     <code>f_65_clausal_coordination</code> </td>
<td> Independent clause co-ordination (clause-initial <em>and</em>) </td>
</tr><tr><td>
     </td>
<td> <b>P. Negation</b> </td>
</tr><tr><td>
     <code>f_66_neg_synthetic</code> </td>
<td> Synthetic negation (e.g., <em>No answer is good enough for Jones.</em>) </td>
</tr></tbody></table>

**References**

Biber, Douglas (1988). Variations Across Speech and Writing. Cambridge University Press, Cambridge.

Biber, Douglas (1995). Dimensions of Register Variation: A cross-linguistic comparison. Cambridge University Press, Cambridge.

Gasthaus, Jan (2007). Prototype-Based Relevance Learning for Genre Classification. B.Sc.\ thesis, Institute of Cognitive Science, University of Osnabr<U+00FC>ck. Data sets and software available from [http://cogsci.uni-osnabrueck.de/~CL/download/BSc_Gasthaus2007/](http://cogsci.uni-osnabrueck.de/~CL/download/BSc_Gasthaus2007/).
