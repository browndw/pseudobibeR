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
#' \item{f_13_wh_question}{Direct *wh-* questions (e.g., *When are you leaving?*)}
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
#' \item{f_43_type_token}{Type-token ratio (including punctuation), using the statistic chosen in `measure`, or TTR if there are fewer than 200 tokens in the smallest document.}
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
#' @param tokens A dataset of tokens created by `spacyr::spacy_parse()` or
#'   `udpipe::udpipe_annotate()`
#' @param ttr_measure Measure to use for type-token ratio. Passed to
#'   `quanteda.textstats::textstat_lexdiv()` to calculate the statistic. Can be
#'   the Moving Average Type-Token Ratio (MATTR), ordinary Type-Token Ratio
#'   (TTR), corrected TTR (CTTR), Mean Segmental Type-Token Ratio (MSTTR), or
#'   `"none"` to skip calculating a type-token ratio. If a statistic is chosen
#'   but there are fewer than 200 token in the smallest document, the TTR is
#'   used instead.
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
biber <- function(tokens, measure = c("MATTR", "TTR", "CTTR", "MSTTR", "none"),
                  normalize = TRUE) {
  measure <- match.arg(measure)

  UseMethod("biber")
}

#' @rdname biber
#' @export
biber.spacyr_parsed <- function(tokens, measure, normalize = TRUE) {
  if ("dep_rel" %in% colnames(tokens) == F) stop("be sure to set 'dependency = T' when using spacy_parse")
  if ("tag" %in% colnames(tokens) == F) stop("be sure to set 'tag = T' when using spacy_parse")
  if ("pos" %in% colnames(tokens) == F) stop("be sure to set 'pos = T' when using spacy_parse")

  return(parse_biber_features(tokens, measure, normalize, "spacy"))
}

#' @rdname biber
#' @export
biber.udpipe_connlu <- function(tokens, measure, normalize = TRUE) {

  udpipe_tks <- data.frame(tokens, stringsAsFactors = F)

  if ("dep_rel" %in% colnames(udpipe_tks) == F) stop("Be sure to set parser = 'default'")
  if ("xpos" %in% colnames(udpipe_tks) == F) stop("Be sure to set tagger = 'default'")
  if ("upos" %in% colnames(udpipe_tks) == F) stop("Be sure to set tagger = 'default'")

  udpipe_tks <- udpipe_tks %>%
    dplyr::select("doc_id", "sentence_id", "token_id", "token", "lemma", "upos",
                  "xpos", "head_token_id", "dep_rel") %>%
    dplyr::rename(pos = "upos", tag = "xpos")

  udpipe_tks <- structure(udpipe_tks, class = c("spacyr_parsed", "data.frame"))

  return(parse_biber_features(udpipe_tks, measure, normalize, "udpipe"))
}

#' @importFrom rlang .data :=
parse_biber_features <- function(tokens, measure, normalize, engine = c("spacy", "udpipe")) {
  engine <- match.arg(engine)

  dict <- quanteda::dictionary(pseudobibeR::dict)

  df <- NULL

  biber_tks <- quanteda::as.tokens(tokens, include_pos = "tag", concatenator = "_") %>%
    quanteda::tokens_remove(" __SP") %>%
    quanteda::tokens_tolower() %>%
    quanteda::tokens_replace("[[:punct:]]_[[:punct:]]", "_punct_", valuetype = "regex") %>%
    quanteda::tokens_replace("\n__sp", "_punct_", valuetype = "fixed") %>%
    quanteda::tokens_replace("&_cc", "and_cc", valuetype = "fixed") %>%
    quanteda::tokens_remove("^\\W_", valuetype = "regex")


  tokens <- tokens %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(token = tolower(.data$token)) %>%
    dplyr::mutate(pos = ifelse(.data$token == "\n", "PUNCT", .data$pos)) %>%
    dplyr::filter(.data$pos != "SPACE")

  biber_1 <- quanteda::tokens_lookup(biber_tks, dictionary = dict) %>%
    quanteda::dfm() %>%
    quanteda::convert(to = "data.frame") %>%
    dplyr::as_tibble()

  df[["f_02_perfect_aspect"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$lemma == "have",
      stringr::str_detect(.data$dep_rel, "aux")
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_02_perfect_aspect = "n")


  df[["f_10_demonstrative_pronoun"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      stringr::str_detect(.data$tag, "DT"),
      dplyr::lag(stringr::str_detect(.data$tag, "^N|^CD|DT") == F, default = TRUE),
      stringr::str_detect(.data$dep_rel, if (engine == "udpipe") "nsubj|obj|obl|conj|nmod" else "nsubj|dobj|pobj")
    ) %>%
    dplyr::filter(.data$token %in% pseudobibeR::word_lists$pronoun_matchlist) %>%
    dplyr::tally() %>%
    dplyr::rename(f_10_demonstrative_pronoun = "n")

  df[["f_12_proverb_do"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$lemma == "do",
      stringr::str_detect(.data$dep_rel, "aux") == F
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_12_proverb_do = "n")

  df[["f_13_wh_question"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      stringr::str_detect(.data$tag, "^W") == T,
      .data$pos != "DET" & dplyr::lead(.data$dep_rel == "aux"),
      (
        dplyr::lag(.data$pos == "PUNCT", default = T) |
          dplyr::lag(.data$pos == "PUNCT", 2, default = T)
      )
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_13_wh_question = "n")

  df[["f_14_nominalizations"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$pos == "NOUN",
      # TODO missing terminal $ below?
      stringr::str_detect(.data$token, "tion$|tions$|ment$|ments$|ness$|nesses$|ity$|ities")
    ) %>%
    dplyr::filter(
      !.data$token %in% pseudobibeR::word_lists$nominalization_stoplist
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_14_nominalizations = "n")

  f_15_gerunds <- tokens %>%
    dplyr::filter(
      stringr::str_detect(.data$token, "ing$|ings$") == TRUE,
      stringr::str_detect(.data$dep_rel, if (engine == "spacy") "nsub|dobj|pobj" else "nsubj|obj|obl|conj|nmod")
    ) %>%
    dplyr::filter(!.data$token %in% pseudobibeR::word_lists$gerund_stoplist)

  gerunds_n <- f_15_gerunds %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(.data$pos == "NOUN") %>%
    dplyr::tally() %>%
    dplyr::rename(gerunds_n = "n")

  df[["f_15_gerunds"]] <- f_15_gerunds %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_15_gerunds = "n")

  df[["f_16_other_nouns"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$pos == "NOUN" |
        .data$pos == "PROPN"
    ) %>%
    dplyr::filter(
      stringr::str_detect(.data$token, "-") == F
    ) %>%
    dplyr::tally() %>%
    dplyr::left_join(df[["f_14_nominalizations"]], by = "doc_id") %>%
    dplyr::left_join(gerunds_n, by = "doc_id") %>%
    replace_nas() %>%
    dplyr::mutate(n = .data$n - .data$f_14_nominalizations - .data$gerunds_n) %>%
    dplyr::select("doc_id", "n") %>%
    dplyr::rename(f_16_other_nouns = "n")

  df[["f_17_agentless_passives"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$dep_rel == if (engine == "spacy") "auxpass" else "aux:pass",
      dplyr::lead(.data$token != "by", 2, default = T),
      dplyr::lead(.data$token != "by", 3, default = T)
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_17_agentless_passives = "n")

  df[["f_18_by_passives"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$dep_rel == if (engine == "spacy") "auxpass" else "aux:pass",
      (
        dplyr::lead(.data$token == "by", 2) |
          dplyr::lead(.data$token == "by", 3)
      )
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_18_by_passives = "n")

  df[["f_19_be_main_verb"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$lemma == "be",
      stringr::str_detect(.data$dep_rel, "aux") == F
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_19_be_main_verb = "n")

  df[["f_21_that_verb_comp"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$token == "that",
      .data$pos == "SCONJ",
      dplyr::lag(.data$pos == "VERB")
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_21_that_verb_comp = "n")

  df[["f_22_that_adj_comp"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$token == "that",
      .data$pos == "SCONJ",
      dplyr::lag(.data$pos == "ADJ")
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_22_that_adj_comp = "n")

  df[["f_23_wh_clause"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      stringr::str_detect(.data$tag, "^W") == T,
      .data$token != "which",
      dplyr::lag(.data$pos == "VERB")
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_23_wh_clause = "n")

  df[["f_25_present_participle"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "VBG",
      (
        .data$dep_rel == "advcl" |
          .data$dep_rel == "ccomp"
      ),
      # beginning of sentence:
      dplyr::lag(.data$dep_rel == "punct", default = TRUE)
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_25_present_participle = "n")

  df[["f_26_past_participle"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "VBN", (
        .data$dep_rel == "advcl" |
          .data$dep_rel == "ccomp"
      ),
      # beginning of sentence:
      dplyr::lag(.data$dep_rel == "punct", default = TRUE)
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_26_past_participle = "n")

  df[["f_27_past_participle_whiz"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "VBN",
      dplyr::lag(.data$pos == "NOUN"),
      .data$dep_rel == "acl"
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_27_past_participle_whiz = "n")

  df[["f_28_present_participle_whiz"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "VBG",
      dplyr::lag(.data$pos == "NOUN"),
      .data$dep_rel == "acl"
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_28_present_participle_whiz = "n")

  df[["f_29_that_subj"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$token == "that",
      dplyr::lag(stringr::str_detect(.data$tag, "^N|^CD|DT") == T),
      stringr::str_detect(.data$dep_rel, "nsubj") == T
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_29_that_subj = "n")

  df[["f_30_that_obj"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$token == "that",
      dplyr::lag(stringr::str_detect(.data$tag, "^N|^CD|DT") == T),
      .data$dep_rel == if (engine == "spacy") "dobj" else "obj"
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_30_that_obj = "n")

  df[["f_31_wh_subj"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      stringr::str_detect(.data$tag, "^W") == T,
      dplyr::lag(.data$lemma != "ask", 2),
      dplyr::lag(.data$lemma != "tell", 2),
      (
        dplyr::lag(stringr::str_detect(.data$tag, "^N|^CD|DT") == T) | (
          dplyr::lag(.data$pos == "PUNCT") &
            dplyr::lag(stringr::str_detect(.data$tag, "^N|^CD|DT") == T, 2) &
            .data$token == "who"
        )
      )
    ) %>%
    dplyr::filter(.data$token != "that", stringr::str_detect(.data$dep_rel, "nsubj")) %>%
    dplyr::tally() %>%
    dplyr::rename(f_31_wh_subj = "n")

  df[["f_32_wh_obj"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      stringr::str_detect(.data$tag, "^W") == T,
      dplyr::lag(.data$lemma != "ask", 2),
      dplyr::lag(.data$lemma != "tell", 2),
      (
        dplyr::lag(stringr::str_detect(.data$tag, "^N|^CD|DT") == T)  |
          (
            dplyr::lag(.data$pos == "PUNCT") &
              dplyr::lag(stringr::str_detect(.data$tag, "^N|^CD|DT") == T, 2) &
              stringr::str_detect(.data$token, "^who") == T
          )
      )
    ) %>%
    dplyr::filter(
      .data$token != "that",
      stringr::str_detect(.data$dep_rel, "obj") == T
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_32_wh_obj = "n")

  df[["f_34_sentence_relatives"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$token == "which",
      dplyr::lag(.data$pos == "PUNCT")
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_34_sentence_relatives = "n")

  df[["f_35_because"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$token == "because",
      dplyr::lead(.data$token != "of")
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_35_because = "n")

  df[["f_38_other_adv_sub"]]<- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::mutate(pre_token = dplyr::lag(.data$pos)) %>%
    dplyr::filter(
      .data$pos == "SCONJ",
      .data$dep_rel == "mark",
      .data$token != "because",
      .data$token != "if",
      .data$token != "unless",
      .data$token != "though",
      .data$token != "although",
      .data$token != "tho"
    )  %>%
    dplyr::filter(
      !(.data$token == "that" &
          .data$pre_token != "ADV"
      )
    ) %>%
    dplyr::filter(
      !(.data$token == "as" &
          .data$pre_token == "AUX"
      )
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_38_other_adv_sub = "n")

  if (engine == "spacy") {
    df[["f_39_prepositions"]] <- tokens %>%
      dplyr::group_by(.data$doc_id) %>%
      dplyr::filter(.data$dep_rel == "prep") %>%
      dplyr::tally() %>%
      dplyr::rename(f_39_prepositions = "n")
  } else {
    df[["f_39_prepositions"]] <- tokens %>%
      dplyr::group_by(.data$doc_id) %>%
      dplyr::filter(.data$dep_rel == "case" &
                      .data$tag == "IN") %>%
      dplyr::tally() %>%
      dplyr::rename(f_39_prepositions = "n")
  }

  df[["f_40_adj_attr"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$pos == "ADJ",
      (
        dplyr::lead(.data$pos == "NOUN") |
          dplyr::lead(.data$pos == "ADJ")  |
          (
            dplyr::lead(.data$token == ",") &
              dplyr::lead(.data$pos == "ADJ", 2)
          )
      )
    ) %>%
    dplyr::filter(stringr::str_detect(.data$token, "-") == F) %>%
    dplyr::tally() %>%
    dplyr::rename(f_40_adj_attr = "n")

  df[["f_41_adj_pred"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$pos == "ADJ",
      dplyr::lag(.data$pos == "VERB" | .data$pos == "AUX"),
      dplyr::lag(.data$lemma %in% pseudobibeR::word_lists$linking_matchlist),
      dplyr::lead(.data$pos != "NOUN"),
      dplyr::lead(.data$pos != "ADJ"),
      dplyr::lead(.data$pos != "ADV")
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_41_adj_pred = "n")

  df[["f_51_demonstratives"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$token %in% pseudobibeR::word_lists$pronoun_matchlist,
      .data$dep_rel == "det"
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_51_demonstratives = "n")

  df[["f_60_that_deletion"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$lemma %in% pseudobibeR::word_lists$verb_matchlist,
      .data$pos == "VERB",
      (
        dplyr::lead(.data$dep_rel == "nsubj") &
          dplyr::lead(.data$pos == "VERB", 2) &
          dplyr::lead(.data$tag != "WP") &
          dplyr::lead(.data$tag != "VBG", 2)
      ) |
        (
          dplyr::lead(.data$tag == "DT") &
            dplyr::lead(.data$dep_rel == "nsubj", 2) &
            dplyr::lead(.data$pos == "VERB", 3)
        ) |
        (
          dplyr::lead(.data$tag == "DT") &
            dplyr::lead(.data$dep_rel == "amod", 2) &
            dplyr::lead(.data$dep_rel == "nsubj", 3) &
            dplyr::lead(.data$pos == "VERB", 4)
        )
    ) %>%
    dplyr::filter(.data$dep_rel != "amod") %>%
    dplyr::tally() %>%
    dplyr::rename(f_60_that_deletion = "n")

  df[["f_61_stranded_preposition"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "IN",
      .data$dep_rel == if (engine == "spacy") "prep" else "case",
      dplyr::lead(stringr::str_detect(.data$tag, "[[:punct:]]"))
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_61_stranded_preposition = "n")

  df[["f_62_split_infinitve"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "TO",
      (
        dplyr::lead(.data$tag == "RB") &
          dplyr::lead(.data$tag == "VB", 2)
      ) |
        (
          dplyr::lead(.data$tag == "RB") &
            dplyr::lead(.data$tag == "RB", 2) &
            dplyr::lead(.data$tag == "VB", 3)
        )
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_62_split_infinitve = "n")

  df[["f_63_split_auxiliary"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      stringr::str_detect(.data$dep_rel, "aux") == T,
      (
        dplyr::lead(.data$pos == "ADV") &
          dplyr::lead(.data$pos == "VERB", 2)
      ) |
        (
          dplyr::lead(.data$pos == "ADV") &
            dplyr::lead(.data$pos == "ADV", 2) &
            dplyr::lead(.data$pos == "VERB", 3)
        )
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_63_split_auxiliary = "n")

  df[["f_64_phrasal_coordination"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "CC",
      (
        dplyr::lead(.data$pos == "NOUN") &
          dplyr::lag(.data$pos == "NOUN")
      ) |
        (
          dplyr::lead(.data$pos == "VERB") &
            dplyr::lag(.data$pos == "VERB")
        ) |
        (
          dplyr::lead(.data$pos == "ADJ") &
            dplyr::lag(.data$pos == "ADJ")
        ) |
        (
          dplyr::lead(.data$pos == "ADV") &
            dplyr::lag(.data$pos == "ADV")
        )
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_64_phrasal_coordination = "n")

  df[["f_65_clausal_coordination"]] <- tokens %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::filter(
      .data$tag == "CC",
      .data$dep_rel != "ROOT",
      (
        dplyr::lead(.data$dep_rel == "nsubj") |
          dplyr::lead(.data$dep_rel == "nsubj", 2) |
          dplyr::lead(.data$dep_rel == "nsubj", 3)
      )
    ) %>%
    dplyr::tally() %>%
    dplyr::rename(f_65_clausal_coordination = "n")

  biber_tks <- biber_tks %>%
    quanteda::tokens_remove("\\d_", valuetype = "regex") %>%
    quanteda::tokens_remove("_punct_", valuetype = "fixed")


  biber_2 <- df %>% purrr::reduce(dplyr::full_join, by = "doc_id")

  biber_counts <- dplyr::full_join(biber_1, biber_2, by = "doc_id") %>%
    replace_nas()

  if (normalize) {
    tot_counts <- data.frame(tot_counts = quanteda::ntoken(biber_tks)) %>%
      tibble::rownames_to_column("doc_id") %>%
      dplyr::as_tibble()

    biber_counts <- dplyr::full_join(biber_counts, tot_counts, by = "doc_id")

    biber_counts <- normalize_counts(biber_counts)
  }

  if (measure != "none") {
    if (min(quanteda::ntoken(biber_tks)) < 200) {
      message("Setting type-to-token ratio to TTR")
      measure <- "TTR"
    }

    f_43_type_token <- quanteda.textstats::textstat_lexdiv(biber_tks, measure = measure) %>%
      dplyr::rename(doc_id = "document", f_43_type_token := !!measure)

    biber_counts <- dplyr::full_join(biber_counts, f_43_type_token, by = "doc_id")
  }

  f_44_mean_word_length <- tokens %>%
    dplyr::filter(
      stringr::str_detect(.data$token, "^[a-z]+$")
    ) %>%
    dplyr::mutate(mean_word_length = stringr::str_length(.data$token)) %>%
    dplyr::group_by(.data$doc_id) %>%
    dplyr::summarise(f_44_mean_word_length = mean(.data$mean_word_length))

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
    dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ 1000 * . / tot_counts)) %>%
    dplyr::select(-"tot_counts")
}

#' Replace all NAs with 0
#'
#' @param x Vector potentially containing NAs
#' @keywords internal
replace_nas <- function(x) {
  replace(x, is.na(x), 0)
}
