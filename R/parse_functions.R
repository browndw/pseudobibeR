#' Extract Biber features from a document parsed and annotated by spacyr or udpipe
#'
#' Takes data that has been part-of-speech tagged and dependency parsed and
#' extracts counts of features that have been used in Douglas Biber's research
#' since the late 1980s.
#'
#' This relies on a feature dictionary (included as `dict`) and word lists
#' (`word_lists`) to match specific features; see their documentation and values
#' for details on the exact patterns and words matched by each. The function
#' identifies other features based on local cues, which are approximations.
#' Because they rely on pobablistic taggers provided by spaCy or udpipe, the
#' accuracy of the resulting counts are dependent on the accuracy of those
#' models. Thus, texts with irregular spellings, non-normative punctuation, etc.
#' will likely produce unreliable outputs, unless taggers are tuned specifically
#' for those purposes.
#'
#' The following features are detected. Square brackets in example sentences
#' indicate the location of the feature.
#'
#' ## Tense and aspect markers
#'
#' \describe{
#' \item{f_01_past_tense}{Verbs in the past tense.}
#' \item{f_02_perfect_aspect}{Verbs in the perfect aspect, indicated by "have" as an auxiliary verb (e.g. *I \[have\] written this sentence.*)"}
#' \item{f_03_present_tense}{Verbs in the present tense.}
#' }
#'
#' ## Place and time adverbials
#'
#' \describe{
#' \item{f_04_place_adverbials}{Place adverbials (e.g., *above*, *beside*, *outdoors*)}
#' \item{f_05_time_adverbials}{Time adverbials (e.g., *early*, *instantly*, *soon*)}
#' }
#'
#' ## Pronouns and pro-verbs
#'
#' \describe{
#' \item{f_06_first_person_pronouns}{First-person pronouns}
#' \item{f_07_second_person_pronouns}{Second-person pronouns}
#' \item{f_08_third_person_pronouns}{Third-person personal pronouns (excluding *it*)}
#' \item{f_09_pronoun_it}{Pronoun *it*}
#' \item{f_10_demonstrative_pronoun}{Pronouns being used to replace a noun (e.g. *\[That\] is an example sentence.*)}
#' \item{f_11_indefinite_pronouns}{Indefinite pronouns (e.g., *anybody*, *nothing*, *someone*)}
#' \item{f_12_proverb_do}{Pro-verb *do*}
#' }
#'
#' ## Questions
#'
#' \describe{
#' \item{f_13_wh_question}{Direct *wh-* questions (e.g., TODO)}
#' }
#'
#' ## Nominal forms
#'
#' \describe{
#' \item{f_14_nominalizations}{Nominalizations (nouns ending in *-tion*, *-ment*, *-ness*, *-ity*)}
#' \item{f_15_gerunds}{Gerunds (participial forms functioning as nouns)}
#' \item{f_16_other_nouns}{Total other nouns}
#' }
#'
#' ## Passives
#'
#' \describe{
#' \item{f_17_agentless_passives}{Agentless passives (e.g., TODO)}
#' \item{f_18_by_passives}{*by-* passives (e.g., TODO)}
#' }
#'
#' ## Stative forms
#'
#' \describe{
#' \item{f_19_be_main_verb}{*be* as main verb}
#' \item{f_20_existential_there}{Existential *there* (e.g., TODO)}
#' }
#'
#' ## Subordination features
#'
#' \describe{
#' \item{f_21_that_verb_comp}{*that* verb complements (e.g., *I said \[that he went\].*)}
#' \item{f_22_that_adj_comp}{*that* adjective complements (e.g., *I'm glad \[that you like it\].*)}
#' \item{f_23_wh_clause}{*wh-* clauses (e.g., *I believed \[what he told me\].*)}
#' \item{f_24_infinitives}{Infinitives}
#' \item{f_25_present_participle}{Present participial adverbial clauses (e.g., *\[Stuffing his mouth with cookies\], Joe ran out the door.*)}
#' \item{f_26_past_participle}{Past participial adverbial clauses (e.g., *\[Built in a single week\], the house would stand for fifty years.*)}
#' \item{f_27_past_participle_whiz}{Past participial postnominal (reduced relative) clauses (e.g., *the solution \[produced by this process\]*)}
#' \item{f_28_present_participle_whiz}{Present participial postnominal (reduced relative) clauses (e.g., *the event \[causing this decline\]*)}
#' \item{f_29_that_subj}{*that* relative clauses on subject position (e.g., *the dog \[that bit me\]*)}
#' \item{f_30_that_obj}{*that* relative clauses on object position (e.g., *the dog \[that I saw\]*)}
#' \item{f_31_wh_subj}{*wh-* relatives on subject position (e.g., *the man \[who likes popcorn\]*)}
#' \item{f_32_wh_obj}{*wh-* relatives on object position (e.g., *the man \[who Sally likes\]*)}
#' \item{f_33_pied_piping}{Pied-piping relative clauses (e.g., *the manner \[in which he was told\]*)}
#' \item{f_34_sentence_relatives}{Sentence relatives (e.g., *Bob likes fried mangoes, \[which is the most disgusting thing I've ever heard of\].*)}
#' \item{f_35_because}{Causative adverbial subordinator (*because*)}
#' \item{f_36_though}{Concessive adverbial subordinators (*although*, *though*)}
#' \item{f_37_if}{Conditional adverbial subordinators (*if*, *unless*)}
#' \item{f_38_other_adv_sub}{Other adverbial subordinators (e.g., *since*, *while*, *whereas*)}
#' }
#'
#' ## Prepositional phrases, adjectives, and adverbs
#'
#' \describe{
#' \item{f_39_prepositions}{Total prepositional phrases}
#' \item{f_40_adj_attr}{Attributive adjectives (e.g., *the \[big\] horse*)}
#' \item{f_41_adj_pred}{Predicative adjectives (e.g., *The horse is \[big\].*)}
#' \item{f_42_adverbs}{Total adverbs}
#' }
#'
#' ## Lexical specificity
#'
#' \describe{
#' \item{f_43_type_token}{Type-token ratio (including punctuation), using the moving-average type-token ratio (MATTR).}
#' \item{f_44_mean_word_length}{Average word length (across tokens, excluding punctuation)}
#' }
#'
#' ## Lexical classes
#'
#' \describe{
#' \item{f_45_conjuncts}{Conjuncts (e.g., *consequently*, *furthermore*, *however*)}
#' \item{f_46_downtoners}{Downtoners (e.g., *barely*, *nearly*, *slightly*)}
#' \item{f_47_hedges}{Hedges (e.g., *at about*, *something like*, *almost*)}
#' \item{f_48_amplifiers}{Amplifiers (e.g., *absolutely*, *extremely*, *perfectly*)}
#' \item{f_49_emphatics}{Emphatics (e.g., *a lot*, *for sure*, *really*)}
#' \item{f_50_discourse_particles}{Discourse particles (e.g., sentence-initial *well*, *now*, *anyway*)}
#' \item{f_51_demonstratives}{Demonstratives (e.g., TODO)}
#' }
#'
#' ## Modals
#'
#' \describe{
#' \item{f_52_modal_possibility}{Possibility modals (*can*, *may*, *might*, *could*)}
#' \item{f_53_modal_necessity}{Necessity modals (*ought*, *should*, *must*)}
#' \item{f_54_modal_predictive}{Predictive modals (*will*, *would*, *shall*)}
#' }
#'
#' ## Specialized verb classes
#'
#' \describe{
#' \item{f_55_verb_public}{Public verbs (e.g., *assert*, *declare*, *mention*)}
#' \item{f_56_verb_private}{Private verbs (e.g., *assume*, *believe*, *doubt*, *know*)}
#' \item{f_57_verb_suasive}{Suasive verbs (e.g., *command*, *insist*, *propose*)}
#' \item{f_58_verb_seem}{*seem* and *appear*}
#' }
#'
#' ## Reduced forms and dispreferred structures
#'
#' \describe{
#' \item{f_59_contractions}{Contractions}
#' \item{f_60_that_deletion}{Subordinator *that* deletion (e.g., *I think \[he went\].*)}
#' \item{f_61_stranded_preposition}{Stranded prepositions (e.g., *the candidate that I was thinking \[of\]*)}
#' \item{f_62_split_infinitve}{Split infinitives (e.g., *He wants \[to convincingly prove\] that ...*)}
#' \item{f_63_split_auxiliary}{Split auxiliaries (e.g., *They \[were apparently shown\] to ...*)}
#' }
#'
#' ## Co-ordination
#'
#' \describe{
#' \item{f_64_phrasal_coordination}{Phrasal co-ordination (N and N; Adj and Adj; V and V; Adv and Adv)}
#' \item{f_65_clausal_coordination}{Independent clause co-ordination (clause-initial *and*)}
#' }
#'
#' ## Negation
#'
#' \describe{
#' \item{f_66_neg_synthetic}{Synthetic negation (e.g., *No answer is good enough for Jones.*)}
#' \item{f_67_neg_analytic}{Analytic negation (e.g., *That isn't good enough.*)}
#' }
#'
#' @param spacy_tks A `data.frame` of tokens created by `spacyr::spacy_parse()`
#' @param normalize If `TRUE`, count features are normalized to the rate per
#'   1,000 tokens.
#' @return A `data.frame` of features containing one row per document and one
#'   column per feature. If `normalize` is `TRUE`, count features are normalized
#'   to the rate per 1,000 tokens.
#' @references Biber, Douglas (1988). *Variation across Speech and Writing*.
#'   Cambridge University Press.
#'
#' Biber, Douglas (1995). *Dimensions of Register Variation: A Cross-Linguistic
#' Comparison.* Cambridge University Press.
#'
#' Covington, M. A., & McFall, J. D. (2010). Cutting the Gordian Knot: The
#' Moving-Average Type–Token Ratio (MATTR). *Journal of Quantitative
#' Linguistics*, 17(2), 94–100. \doi{10.1080/09296171003643098}
#' @importFrom magrittr %>%
#' @export
biber_spacy <- function(spacy_tks, normalize = TRUE) {

  if (!inherits(spacy_tks, "spacyr_parsed")) stop("biber_parse only works on spacyr parsed objects")
  if ("dep_rel" %in% colnames(spacy_tks) == F) stop("be sure to set 'dependency = T' when using spacy_parse")
  if ("tag" %in% colnames(spacy_tks) == F) stop("be sure to set 'tag = T' when using spacy_parse")
  if ("pos" %in% colnames(spacy_tks) == F) stop("be sure to set 'pos = T' when using spacy_parse")

  dict <- quanteda::dictionary(pseudobibeR::dict)

  df <- NULL

  biber_tks <- quanteda::as.tokens(spacy_tks, include_pos = "tag", concatenator = "_") %>%
    quanteda::tokens_remove(" __SP") %>% quanteda::tokens_tolower() %>%
    quanteda::tokens_replace("[[:punct:]]_[[:punct:]]", "_punct_", valuetype = "regex") %>%
    quanteda::tokens_replace("\n__sp", "_punct_", valuetype = "fixed") %>%
    quanteda::tokens_replace("&_cc", "and_cc", valuetype = "fixed") %>%
    quanteda::tokens_remove("^\\W_", valuetype = "regex")


  spacy_tks <- spacy_tks %>% dplyr::as_tibble() %>%
    dplyr::mutate(token = tolower(token)) %>%
    dplyr::mutate(pos = ifelse(token == "\n", "PUNCT", pos)) %>%
    dplyr::filter(pos != "SPACE")

  biber_1 <- quanteda::tokens_lookup(biber_tks, dictionary = dict) %>%
    quanteda::dfm() %>%
    quanteda::convert(to = "data.frame") %>%
    dplyr::as_tibble()

  df[["f_02_perfect_aspect"]] <- spacy_tks %>%
    dplyr::filter(
      lemma == "have",
      stringr::str_detect(dep_rel, "aux") == T
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_02_perfect_aspect = n)


  df[["f_10_demonstrative_pronoun"]] <- spacy_tks %>%
    dplyr::group_by(doc_id) %>%
    dplyr::filter(
      stringr::str_detect(tag, "DT") == T,
      dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == F, default = TRUE),
      stringr::str_detect(dep_rel, "nsub|dobj|pobj") == T
    ) %>%
    dplyr::filter(token %in% pseudobibeR::word_lists$pronoun_matchlist) %>%
    dplyr::tally() %>%
    dplyr::rename(f_10_demonstrative_pronoun = n)

  df[["f_12_proverb_do"]] <- spacy_tks %>%
    dplyr::filter(
      lemma == "do",
      stringr::str_detect(dep_rel, "aux") == F
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_12_proverb_do = n)

  df[["f_13_wh_question"]] <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      pos != "DET" & dplyr::lead(dep_rel == "aux"),
      (
        dplyr::lag(pos == "PUNCT", default = T) |
          dplyr::lag(pos == "PUNCT", 2, default = T)
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_13_wh_question = n)

  df[["f_14_nominalizations"]] <- spacy_tks %>%
    dplyr::filter(
      pos == "NOUN",
      stringr::str_detect(token, "tion$|tions$|ment$|ments$|ness$|nesses$|ity$|ities") == TRUE
    ) %>%
    dplyr::filter(
      !token %in% pseudobibeR::word_lists$nominalization_stoplist
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_14_nominalizations = n)

  f_15_gerunds <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(token, "ing$|ings$") == TRUE,
      stringr::str_detect(dep_rel, "nsub|dobj|pobj") == T
    ) %>%
    dplyr::filter(!token %in% pseudobibeR::word_lists$gerund_stoplist)

  gerunds_n <- f_15_gerunds %>% dplyr::filter(pos == "NOUN") %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(gerunds_n = n)

  df[["f_15_gerunds"]] <- f_15_gerunds %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_15_gerunds = n)

  df[["f_16_other_nouns"]] <- spacy_tks %>%
    dplyr::filter(
      pos == "NOUN" |
        pos == "PROPN"
    ) %>%
    dplyr::filter(
      stringr::str_detect(token, "-") == F
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::left_join(df[["f_14_nominalizations"]], by = "doc_id") %>%
    dplyr::left_join(gerunds_n, by = "doc_id") %>%
    replace(is.na(.), 0) %>%
    dplyr::mutate(n = n - f_14_nominalizations - gerunds_n) %>%
    dplyr::select(doc_id, n) %>%
    dplyr::rename(f_16_other_nouns = n)

  df[["f_17_agentless_passives"]] <- spacy_tks %>%
    dplyr::filter(
      dep_rel == "auxpass",
      dplyr::lead(token != "by", 2, default = T),
      dplyr::lead(token != "by", 3, default = T)
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_17_agentless_passives = n)

  df[["f_18_by_passives"]] <- spacy_tks %>%
    dplyr::filter(
      dep_rel == "auxpass",
      (
        dplyr::lead(token == "by", 2) |
          dplyr::lead(token == "by", 3)
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_18_by_passives = n)

  df[["f_19_be_main_verb"]] <- spacy_tks %>%
    dplyr::filter(
      lemma == "be",
      stringr::str_detect(dep_rel, "aux") == F
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_19_be_main_verb = n)

  df[["f_21_that_verb_comp"]] <- spacy_tks %>%
    dplyr::filter(
      token == "that",
      pos == "SCONJ",
      dplyr::lag(pos == "VERB")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_21_that_verb_comp = n)

  df[["f_22_that_adj_comp"]] <- spacy_tks %>%
    dplyr::filter(
      token == "that",
      pos == "SCONJ",
      dplyr::lag(pos == "ADJ")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_22_that_adj_comp = n)

  df[["f_23_wh_clause"]] <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      token != "which",
      dplyr::lag(pos == "VERB")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_23_wh_clause = n)

  df[["f_25_present_participle"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "VBG",
      (
        dep_rel == "advcl" |
          dep_rel == "ccomp"
      ),
      dplyr::lag(dep_rel == "punct")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_25_present_participle = n)

  df[["f_26_past_participle"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "VBN",
      (
        dep_rel == "advcl" |
          dep_rel == "ccomp"
      ),
      dplyr::lag(dep_rel == "punct")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_26_past_participle = n)

  df[["f_27_past_participle_whiz"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "VBN",
      dplyr::lag(pos == "NOUN"),
      dep_rel == "acl"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_27_past_participle_whiz = n)

  df[["f_28_present_participle_whiz"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "VBG",
      dplyr::lag(pos == "NOUN"),
      dep_rel == "acl"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_28_present_participle_whiz = n)

  df[["f_29_that_subj"]] <- spacy_tks %>%
    dplyr::filter(
      token == "that",
      dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T),
      stringr::str_detect(dep_rel, "nsubj") == T
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_29_that_subj = n)

  df[["f_30_that_obj"]] <- spacy_tks %>%
    dplyr::filter(
      token == "that",
      dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T),
      dep_rel == "dobj"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_30_that_obj = n)

  df[["f_31_wh_subj"]] <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      dplyr::lag(lemma != "ask", 2),
      dplyr::lag(lemma != "tell", 2),
      (
        dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T) |
          (
            dplyr::lag(pos == "PUNCT") &
              dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T, 2) &
              token == "who"
          )
      )
    ) %>%
    dplyr::filter(token != "that" & stringr::str_detect(dep_rel, "nsubj")) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_31_wh_subj = n)

  df[["f_32_wh_obj"]] <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      dplyr::lag(lemma != "ask", 2),
      dplyr::lag(lemma != "tell", 2),
      (
        dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T)  |
          (
            dplyr::lag(pos == "PUNCT") &
              dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T, 2) &
              stringr::str_detect(token, "^who") == T
          )
      )
    ) %>%
    dplyr::filter(
      token != "that",
      stringr::str_detect(dep_rel, "obj") == T
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_32_wh_obj = n)

  df[["f_34_sentence_relatives"]] <- spacy_tks %>%
    dplyr::filter(
      token == "which",
      dplyr::lag(pos == "PUNCT")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_34_sentence_relatives = n)

  df[["f_35_because"]] <- spacy_tks %>%
    dplyr::filter(
      token == "because",
      dplyr::lead(token != "of")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_35_because = n)

  df[["f_38_other_adv_sub"]]<- spacy_tks %>%
    dplyr::mutate(pre_token = dplyr::lag(pos)) %>%
    dplyr::filter(
      pos == "SCONJ",
      dep_rel == "mark",
      token != "because",
      token != "if",
      token != "unless",
      token != "though",
      token != "although",
      token != "tho"
    )  %>%
    dplyr::filter(
      !(token == "that" &
          pre_token != "ADV"
      )
    ) %>%
    dplyr::filter(
      !(token == "as" &
          pre_token == "AUX"
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_38_other_adv_sub = n)

  df[["f_39_prepositions"]] <- spacy_tks %>%
    dplyr::filter(dep_rel == "prep") %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_39_prepositions = n)

  df[["f_40_adj_attr"]] <- spacy_tks %>%
    dplyr::filter(
      pos == "ADJ",
      (
        dplyr::lead(pos == "NOUN") |
          dplyr::lead(pos == "ADJ")  |
          (
            dplyr::lead(token == ",") &
              dplyr::lead(pos == "ADJ", 2)
          )
      )
    ) %>%
    dplyr::filter(stringr::str_detect(token, "-") == F) %>%
    dplyr::group_by(doc_id) %>% dplyr::tally() %>%
    dplyr::rename(f_40_adj_attr = n)

  df[["f_41_adj_pred"]] <- spacy_tks %>%
    dplyr::filter(
      pos == "ADJ" & dplyr::lag(pos == "VERB"),
      dplyr::lag(lemma %in% pseudobibeR::word_lists$linking_matchlist),
      dplyr::lead(pos != "NOUN"),
      dplyr::lead(pos != "ADJ"),
      dplyr::lead(pos != "ADV")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_41_adj_pred = n)

  df[["f_51_demonstratives"]] <- spacy_tks %>%
    dplyr::filter(
      token %in% pseudobibeR::word_lists$pronoun_matchlist,
      dep_rel == "det"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_51_demonstratives = n)

  df[["f_60_that_deletion"]] <- spacy_tks %>%
    dplyr::filter(
      lemma %in% pseudobibeR::word_lists$verb_matchlist & pos == "VERB",
      (
        dplyr::lead(dep_rel == "nsubj") &
          dplyr::lead(pos == "VERB", 2) &
          dplyr::lead(tag != "WP") &
          dplyr::lead(tag != "VBG", 2)
      ) |
        (
          dplyr::lead(tag == "DT") &
            dplyr::lead(dep_rel == "nsubj", 2) &
            dplyr::lead(pos == "VERB", 3)
        ) |
        (
          dplyr::lead(tag == "DT") &
            dplyr::lead(dep_rel == "amod", 2) &
            dplyr::lead(dep_rel == "nsubj", 3) &
            dplyr::lead(pos == "VERB", 4)
        )
    ) %>%
    dplyr::filter(dep_rel != "amod") %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_60_that_deletion = n)

  df[["f_61_stranded_preposition"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "IN",
      dep_rel == "prep",
      dplyr::lead(stringr::str_detect(tag, "[[:punct:]]"))
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_61_stranded_preposition = n)

  df[["f_62_split_infinitve"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "TO",
      (
        dplyr::lead(tag == "RB") &
          dplyr::lead(tag == "VB", 2)
      ) |
        (
          dplyr::lead(tag == "RB") &
            dplyr::lead(tag == "RB", 2) &
            dplyr::lead(tag == "VB", 3)
        )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_62_split_infinitve = n)

  df[["f_63_split_auxiliary"]] <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(dep_rel, "aux") == T,
      (
        dplyr::lead(pos == "ADV") &
          dplyr::lead(pos == "VERB", 2)
      ) |
        (
          dplyr::lead(pos == "ADV") &
            dplyr::lead(pos == "ADV", 2) &
            dplyr::lead(pos == "VERB", 3)
        )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_63_split_auxiliary = n)

  df[["f_64_phrasal_coordination"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "CC",
      (
        dplyr::lead(pos == "NOUN") &
          dplyr::lag(pos == "NOUN")
      ) |
        (
          dplyr::lead(pos == "VERB") &
            dplyr::lag(pos == "VERB")
        ) |
        (
          dplyr::lead(pos == "ADJ") &
            dplyr::lag(pos == "ADJ")
        ) |
        (
          dplyr::lead(pos == "ADV") &
            dplyr::lag(pos == "ADV")
        )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_64_phrasal_coordination = n)

  df[["f_65_clausal_coordination"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "CC",
      dep_rel != "ROOT",
      (
        dplyr::lead(dep_rel == "nsubj") |
          dplyr::lead(dep_rel == "nsubj", 2) |
          dplyr::lead(dep_rel == "nsubj", 3)
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_65_clausal_coordination = n)

  biber_tks <- biber_tks %>%
    quanteda::tokens_remove("\\d_", valuetype = "regex") %>%
    quanteda::tokens_remove("_punct_", valuetype = "fixed")

  if (min(quanteda::ntoken(biber_tks)) < 200) {
    message("Setting type-to-token ratio to TTR")
    TTR <- "TTR"
  } else {
    message("Setting type-to-token ratio to MATTR")
    TTR <- "MATTR"
  }

  biber_2 <- df %>% purrr::reduce(dplyr::full_join, by = "doc_id")

  biber_counts <- dplyr::full_join(biber_1, biber_2, by = "doc_id" )%>%
    replace(is.na(.), 0)

  if (normalize) {
    tot_counts <- quanteda::ntoken(biber_tks) %>%
      data.frame(tot_counts = .) %>%
      tibble::rownames_to_column("doc_id") %>%
      dplyr::as_tibble()

    biber_counts <- dplyr::full_join(biber_counts, tot_counts, by = "doc_id")

    biber_counts <- normalize_counts(biber_counts)
  }

  f_43_type_token <- quanteda.textstats::textstat_lexdiv(biber_tks, measure = TTR) %>%
    dplyr::rename(doc_id = document, f_43_type_token := !!TTR)

  f_44_mean_word_length <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(token, "^[a-z]+$")
    ) %>%
    dplyr::mutate(mean_word_length = stringr::str_length(token)) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::summarise(f_44_mean_word_length = mean(mean_word_length))

  biber_counts <- dplyr::full_join(biber_counts, f_43_type_token, by = "doc_id")

  biber_counts <- dplyr::full_join(biber_counts, f_44_mean_word_length, by = "doc_id")

  biber_counts <- biber_counts %>%
    dplyr::select(order(colnames(biber_counts)))

  biber_counts[] <- lapply(biber_counts, as.vector)

  return(biber_counts)
}

#' @rdname biber_spacy
#' @param udpipe_tks A list or data frame of tokens parsed by
#'   `udpipe::udpipe_annotate()`.
#' @export
biber_udpipe <- function(udpipe_tks, normalize = TRUE) {

  if (inherits(udpipe_tks, "udpipe_connlu")) udpipe_tks <- data.frame(udpipe_tks, stringsAsFactors = F)

  if ("dep_rel" %in% colnames(udpipe_tks) == F) stop("Be sure to set parser = 'default'")
  if ("xpos" %in% colnames(udpipe_tks) == F) stop("Be sure to set tagger = 'default'")
  if ("upos" %in% colnames(udpipe_tks) == F) stop("Be sure to set tagger = 'default'")

  udpipe_tks <- udpipe_tks %>%
    dplyr::select(doc_id, sentence_id, token_id, token, lemma, upos, xpos, head_token_id, dep_rel) %>%
    dplyr::rename(pos = upos, tag = xpos)

  udpipe_tks <- structure(udpipe_tks, class = c("spacyr_parsed", "data.frame"))

  dict <- quanteda::dictionary(pseudobibeR::dict)

  df <- NULL

  biber_tks <- quanteda::as.tokens(udpipe_tks, include_pos = "tag", concatenator = "_") %>%
    quanteda::tokens_remove(" __SP") %>% quanteda::tokens_tolower() %>%
    quanteda::tokens_replace("[[:punct:]]_[[:punct:]]", "_punct_", valuetype = "regex") %>%
    quanteda::tokens_replace("\n__sp", "_punct_", valuetype = "fixed") %>%
    quanteda::tokens_replace("&_cc", "and_cc", valuetype = "fixed") %>%
    quanteda::tokens_remove("^\\W_", valuetype = "regex")


  udpipe_tks <- udpipe_tks %>% dplyr::as_tibble() %>%
    dplyr::mutate(token = tolower(token)) %>%
    dplyr::mutate(pos = ifelse(token == "\n", "PUNCT", pos)) %>%
    dplyr::filter(pos != "SPACE")

  biber_1 <- quanteda::tokens_lookup(biber_tks, dictionary = dict) %>%
    quanteda::dfm() %>%
    quanteda::convert(to = "data.frame") %>%
    dplyr::as_tibble()

  df[["f_02_perfect_aspect"]] <- udpipe_tks %>%
    dplyr::filter(
      lemma == "have",
      stringr::str_detect(dep_rel, "aux") == T
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_02_perfect_aspect = n)


  df[["f_10_demonstrative_pronoun"]] <- udpipe_tks %>%
    dplyr::group_by(doc_id) %>%
    dplyr::filter(
      stringr::str_detect(tag, "DT") == T,
      dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == F, default = TRUE),
      stringr::str_detect(dep_rel, "nsubj|obj|obl|conj|nmod") == T
    ) %>%
    dplyr::filter(token %in% pseudobibeR::word_lists$pronoun_matchlist) %>%
    dplyr::tally() %>%
    dplyr::rename(f_10_demonstrative_pronoun = n)

  df[["f_12_proverb_do"]] <- udpipe_tks %>%
    dplyr::filter(
      lemma == "do",
      stringr::str_detect(dep_rel, "aux") == F
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_12_proverb_do = n)

  df[["f_13_wh_question"]] <- udpipe_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      pos != "DET" & dplyr::lead(dep_rel == "aux"),
      (
        dplyr::lag(pos == "PUNCT", default = T) |
          dplyr::lag(pos == "PUNCT", 2, default = T)
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_13_wh_question = n)

  df[["f_14_nominalizations"]] <- udpipe_tks %>%
    dplyr::filter(
      pos == "NOUN",
      stringr::str_detect(token, "tion$|tions$|ment$|ments$|ness$|nesses$|ity$|ities") == TRUE
    ) %>%
    dplyr::filter(
      !token %in% pseudobibeR::word_lists$nominalization_stoplist
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_14_nominalizations = n)

  f_15_gerunds <- udpipe_tks %>%
    dplyr::filter(
      stringr::str_detect(token, "ing$|ings$") == TRUE,
      stringr::str_detect(dep_rel, "nsubj|obj|obl|conj|nmod") == T
    ) %>%
    dplyr::filter(!token %in% pseudobibeR::word_lists$gerund_stoplist)

  gerunds_n <- f_15_gerunds %>% dplyr::filter(pos == "NOUN") %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(gerunds_n = n)

  df[["f_15_gerunds"]] <- f_15_gerunds %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_15_gerunds = n)

  df[["f_16_other_nouns"]] <- udpipe_tks %>%
    dplyr::filter(
      pos == "NOUN" |
        pos == "PROPN"
    ) %>%
    dplyr::filter(
      stringr::str_detect(token, "-") == F
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::left_join(df[["f_14_nominalizations"]], by = "doc_id") %>%
    dplyr::left_join(gerunds_n, by = "doc_id") %>%
    replace(is.na(.), 0) %>%
    dplyr::mutate(n = n - f_14_nominalizations - gerunds_n) %>%
    dplyr::select(doc_id, n) %>%
    dplyr::rename(f_16_other_nouns = n)

  df[["f_17_agentless_passives"]] <- udpipe_tks %>%
    dplyr::filter(
      dep_rel == "aux:pass",
      dplyr::lead(token != "by", 2, default = T),
      dplyr::lead(token != "by", 3, default = T)
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_17_agentless_passives = n)

  df[["f_18_by_passives"]] <- udpipe_tks %>%
    dplyr::filter(
      dep_rel == "aux:pass",
      (
        dplyr::lead(token == "by", 2) |
          dplyr::lead(token == "by", 3)
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_18_by_passives = n)

  df[["f_19_be_main_verb"]] <- udpipe_tks %>%
    dplyr::filter(
      lemma == "be",
      stringr::str_detect(dep_rel, "aux") == F
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_19_be_main_verb = n)

  df[["f_21_that_verb_comp"]] <- udpipe_tks %>%
    dplyr::filter(
      token == "that",
      pos == "SCONJ",
      dplyr::lag(pos == "VERB")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_21_that_verb_comp = n)

  df[["f_22_that_adj_comp"]] <- udpipe_tks %>%
    dplyr::filter(
      token == "that",
      pos == "SCONJ",
      dplyr::lag(pos == "ADJ")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_22_that_adj_comp = n)

  df[["f_23_wh_clause"]] <- udpipe_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      token != "which",
      dplyr::lag(pos == "VERB")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_23_wh_clause = n)

  df[["f_25_present_participle"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "VBG",
      (
        dep_rel == "advcl" |
          dep_rel == "ccomp"
      ),
      dplyr::lag(dep_rel == "punct")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_25_present_participle = n)

  df[["f_26_past_participle"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "VBN",
      (
        dep_rel == "advcl" |
          dep_rel == "ccomp"
      ),
      dplyr::lag(dep_rel == "punct")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_26_past_participle = n)

  df[["f_27_past_participle_whiz"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "VBN",
      dplyr::lag(pos == "NOUN"),
      dep_rel == "acl"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_27_past_participle_whiz = n)

  df[["f_28_present_participle_whiz"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "VBG",
      dplyr::lag(pos == "NOUN"),
      dep_rel == "acl"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_28_present_participle_whiz = n)

  df[["f_29_that_subj"]] <- udpipe_tks %>%
    dplyr::filter(
      token == "that",
      dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T),
      stringr::str_detect(dep_rel, "nsubj") == T
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_29_that_subj = n)

  df[["f_30_that_obj"]] <- udpipe_tks %>%
    dplyr::filter(
      token == "that",
      dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T),
      dep_rel == "obj"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_30_that_obj = n)

  df[["f_31_wh_subj"]] <- udpipe_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      dplyr::lag(lemma != "ask", 2),
      dplyr::lag(lemma != "tell", 2),
      (
        dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T) |
          (
            dplyr::lag(pos == "PUNCT") &
              dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T, 2) &
              token == "who"
          )
      )
    ) %>%
    dplyr::filter(token != "that" & stringr::str_detect(dep_rel, "nsubj")) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_31_wh_subj = n)

  df[["f_32_wh_obj"]] <- udpipe_tks %>%
    dplyr::filter(
      stringr::str_detect(tag, "^W") == T,
      dplyr::lag(lemma != "ask", 2),
      dplyr::lag(lemma != "tell", 2),
      (
        dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T)  |
          (
            dplyr::lag(pos == "PUNCT") &
              dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == T, 2) &
              stringr::str_detect(token, "^who") == T
          )
      )
    ) %>%
    dplyr::filter(
      token != "that",
      stringr::str_detect(dep_rel, "obj") == T
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_32_wh_obj = n)

  df[["f_34_sentence_relatives"]] <- udpipe_tks %>%
    dplyr::filter(
      token == "which",
      dplyr::lag(pos == "PUNCT")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_34_sentence_relatives = n)

  df[["f_35_because"]] <- udpipe_tks %>%
    dplyr::filter(
      token == "because",
      dplyr::lead(token != "of")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_35_because = n)

  df[["f_38_other_adv_sub"]]<- udpipe_tks %>%
    dplyr::mutate(pre_token = dplyr::lag(pos)) %>%
    dplyr::filter(
      pos == "SCONJ",
      dep_rel == "mark",
      token != "because",
      token != "if",
      token != "unless",
      token != "though",
      token != "although",
      token != "tho"
    )  %>%
    dplyr::filter(
      !(token == "that" &
          pre_token != "ADV"
      )
    ) %>%
    dplyr::filter(
      !(token == "as" &
          pre_token == "AUX"
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_38_other_adv_sub = n)

  df[["f_39_prepositions"]] <- udpipe_tks %>%
    dplyr::filter(dep_rel == "case" &
                    tag == "IN") %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_39_prepositions = n)

  df[["f_40_adj_attr"]] <- udpipe_tks %>%
    dplyr::filter(
      pos == "ADJ",
      (
        dplyr::lead(pos == "NOUN") |
          dplyr::lead(pos == "ADJ")  |
          (
            dplyr::lead(token == ",") &
              dplyr::lead(pos == "ADJ", 2)
          )
      )
    ) %>%
    dplyr::filter(stringr::str_detect(token, "-") == F) %>%
    dplyr::group_by(doc_id) %>% dplyr::tally() %>%
    dplyr::rename(f_40_adj_attr = n)

  df[["f_41_adj_pred"]] <- udpipe_tks %>%
    dplyr::filter(
      pos == "ADJ" & dplyr::lag(pos == "VERB"),
      dplyr::lag(lemma %in% pseudobibeR::word_lists$linking_matchlist),
      dplyr::lead(pos != "NOUN"),
      dplyr::lead(pos != "ADJ"),
      dplyr::lead(pos != "ADV")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_41_adj_pred = n)

  df[["f_51_demonstratives"]] <- udpipe_tks %>%
    dplyr::filter(
      token %in% pseudobibeR::word_lists$pronoun_matchlist,
      dep_rel == "det"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_51_demonstratives = n)

  df[["f_60_that_deletion"]] <- udpipe_tks %>%
    dplyr::filter(
      lemma %in% pseudobibeR::word_lists$verb_matchlist & pos == "VERB",
      (
        dplyr::lead(dep_rel == "nsubj") &
          dplyr::lead(pos == "VERB", 2) &
          dplyr::lead(tag != "WP") &
          dplyr::lead(tag != "VBG", 2)
      ) |
        (
          dplyr::lead(tag == "DT") &
            dplyr::lead(dep_rel == "nsubj", 2) &
            dplyr::lead(pos == "VERB", 3)
        ) |
        (
          dplyr::lead(tag == "DT") &
            dplyr::lead(dep_rel == "amod", 2) &
            dplyr::lead(dep_rel == "nsubj", 3) &
            dplyr::lead(pos == "VERB", 4)
        )
    ) %>%
    dplyr::filter(dep_rel != "amod") %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_60_that_deletion = n)

  df[["f_61_stranded_preposition"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "IN",
      dep_rel == "case",
      dplyr::lead(stringr::str_detect(tag, "[[:punct:]]"))
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_61_stranded_preposition = n)

  df[["f_62_split_infinitve"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "TO",
      (
        dplyr::lead(tag == "RB") &
          dplyr::lead(tag == "VB", 2)
      ) |
        (
          dplyr::lead(tag == "RB") &
            dplyr::lead(tag == "RB", 2) &
            dplyr::lead(tag == "VB", 3)
        )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_62_split_infinitve = n)

  df[["f_63_split_auxiliary"]] <- udpipe_tks %>%
    dplyr::filter(
      stringr::str_detect(dep_rel, "aux") == T,
      (
        dplyr::lead(pos == "ADV") &
          dplyr::lead(pos == "VERB", 2)
      ) |
        (
          dplyr::lead(pos == "ADV") &
            dplyr::lead(pos == "ADV", 2) &
            dplyr::lead(pos == "VERB", 3)
        )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_63_split_auxiliary = n)

  df[["f_64_phrasal_coordination"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "CC",
      (
        dplyr::lead(pos == "NOUN") &
          dplyr::lag(pos == "NOUN")
      ) |
        (
          dplyr::lead(pos == "VERB") &
            dplyr::lag(pos == "VERB")
        ) |
        (
          dplyr::lead(pos == "ADJ") &
            dplyr::lag(pos == "ADJ")
        ) |
        (
          dplyr::lead(pos == "ADV") &
            dplyr::lag(pos == "ADV")
        )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_64_phrasal_coordination = n)

  df[["f_65_clausal_coordination"]] <- udpipe_tks %>%
    dplyr::filter(
      tag == "CC",
      dep_rel != "ROOT",
      (
        dplyr::lead(dep_rel == "nsubj") |
          dplyr::lead(dep_rel == "nsubj", 2) |
          dplyr::lead(dep_rel == "nsubj", 3)
      )
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_65_clausal_coordination = n)

  biber_tks <- biber_tks %>%
    quanteda::tokens_remove("\\d_", valuetype = "regex") %>%
    quanteda::tokens_remove("_punct_", valuetype = "fixed")

  if (min(quanteda::ntoken(biber_tks)) < 200){
    message("Setting type-to-token ratio to TTR")
    TTR <- "TTR"
  } else {
    message("Setting type-to-token ratio to MATTR")
    TTR <- "MATTR"
  }

  biber_2 <- df %>% purrr::reduce(dplyr::full_join, by = "doc_id")

  biber_counts <- dplyr::full_join(biber_1, biber_2, by = "doc_id" )%>%
    replace(is.na(.), 0)

  if (normalize) {
    tot_counts <- quanteda::ntoken(biber_tks) %>%
      data.frame(tot_counts = .) %>%
      tibble::rownames_to_column("doc_id") %>%
      dplyr::as_tibble()

    biber_counts <- dplyr::full_join(biber_counts, tot_counts, by = "doc_id")

    biber_counts <- normalize_counts(biber_counts)
  }

  f_43_type_token <- quanteda.textstats::textstat_lexdiv(biber_tks, measure = TTR) %>%
    dplyr::rename(doc_id = document, f_43_type_token := !!TTR)

  f_44_mean_word_length <- udpipe_tks %>%
    dplyr::filter(
      stringr::str_detect(token, "^[a-z]+$")
    ) %>%
    dplyr::mutate(mean_word_length = stringr::str_length(token)) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::summarise(f_44_mean_word_length = mean(mean_word_length))

  biber_counts <- dplyr::full_join(biber_counts, f_43_type_token, by = "doc_id")

  biber_counts <- dplyr::full_join(biber_counts, f_44_mean_word_length, by = "doc_id")

  biber_counts <- biber_counts %>%
    dplyr::select(order(colnames(biber_counts)))

  biber_counts[] <- lapply(biber_counts, as.vector)

  return(biber_counts)
}

#' Normalize to counts per 1,000 tokens
#'
#' @param counts Data frame with numeric columns for counts of token, with one
#'   row per document. Must include a `tot_counts` column with the total number
#'   of tokens per document.
#' @return `counts` data frame with counts normalized to rate per 1,000 tokens,
#'   and `tot_counts` column removed
#' @keywords internal
normalize_counts <- function(counts) {
  counts %>%
    dplyr::mutate(dplyr::across(where(is.numeric), ~ 1000 * . / tot_counts)) %>%
    dplyr::select(-tot_counts)
}
