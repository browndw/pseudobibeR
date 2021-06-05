#'
#' This function takes a spacyr data object that has been
#' part-of-speech tagged and dependency parsed and
#' extracts counts of features that have been used in
#' Douglas Biber's research since the late 1980s.
#'
#' Note that function sometimes relies on lists and a dictionary,
#' both of which are stored as R data.
#' At other times, the function identifies features
#' based on local cues, which are approximations.
#'
#' The function returns a data.frame of normalized counts.
#'
#' @importFrom magrittr %>%
#' @param spacy_tks A data.frame of tokens created by spacyr
#' @return A data.frame of feature counts
#' @export

biber_parse <- function(spacy_tks){

  if ("spacyr_parsed" %in% class(spacy_tks) == F) stop ("biber_parse only works on spacyr parsed objects")
  if ("dep_rel" %in% colnames(spacy_tks) == F) stop ("be sure to set 'dependency = T' when using spacy_parse")
  if ("tag" %in% colnames(spacy_tks) == F) stop ("be sure to set 'tag = T' when using spacy_parse")
  if ("pos" %in% colnames(spacy_tks) == F) stop ("be sure to set 'pos = T' when using spacy_parse")

  dict <- quanteda::dictionary(dict)

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

  biber_1 <- quanteda::dfm(biber_tks) %>%
    quanteda::dfm_lookup(dictionary = dict) %>%
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
    dplyr::filter(
      stringr::str_detect(tag, "DT") == T,
      dplyr::lag(stringr::str_detect(tag, "^N|^CD|DT") == F),
      stringr::str_detect(dep_rel, "nsub|dobj|pobj") == T
    ) %>%
    dplyr::filter(token %in% word_lists$pronoun_matchlist) %>%
    dplyr::group_by(doc_id) %>%
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
      !token %in% word_lists$nominalization_stoplist
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_14_nominalizations = n)

  f_15_gerunds <- spacy_tks %>%
    dplyr::filter(
      stringr::str_detect(token, "ing$|ings$") == TRUE,
      stringr::str_detect(dep_rel, "nsub|dobj|pobj") == T
    ) %>%
    dplyr::filter(!token %in% word_lists$gerund_stoplist)

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
          dep_rel == "prep"
      ),
      dplyr::lag(pos != "AUX")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_25_present_participle = n)

  df[["f_26_past_participle"]] <- spacy_tks %>%
    dplyr::filter(
      tag == "VBN",
      (
        dep_rel == "advcl" |
          dep_rel == "prep"
      ),
      dplyr::lag(pos != "AUX")
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
      dplyr::lag(lemma %in% word_lists$linking_matchlist),
      dplyr::lead(pos != "NOUN"),
      dplyr::lead(pos != "ADJ"),
      dplyr::lead(pos != "ADV")
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_41_adj_pred = n)

  df[["f_51_demonstratives"]] <- spacy_tks %>%
    dplyr::filter(
      token %in% word_lists$pronoun_matchlist,
      dep_rel == "det"
    ) %>%
    dplyr::group_by(doc_id) %>%
    dplyr::tally() %>%
    dplyr::rename(f_51_demonstratives = n)

  df[["f_60_that_deletion"]] <- spacy_tks %>%
    dplyr::filter(
      lemma %in% word_lists$verb_matchlist & pos == "VERB",
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


  biber_2 <- df %>% purrr::reduce(dplyr::full_join, by = "doc_id")

  biber_counts <- dplyr::full_join(biber_1, biber_2, by = "doc_id" )%>%
    replace(is.na(.), 0)

  tot_counts <- quanteda::ntoken(biber_tks) %>%
    data.frame(tot_counts = .) %>%
    tibble::rownames_to_column("doc_id") %>%
    dplyr::as_tibble()

  biber_counts <- dplyr::full_join(biber_counts, tot_counts, by = "doc_id")

  biber_counts <- biber_counts %>%
    dplyr::mutate_if(is.numeric, list(~./tot_counts), na.rm = TRUE) %>%
    dplyr::mutate_if(is.numeric, list(~.*1000), na.rm = TRUE)

  f_43_type_token <- quanteda.textstats::textstat_lexdiv(biber_tks, measure = "MATTR") %>%
    dplyr::rename(doc_id = document, f_43_type_token = MATTR)
  
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
    dplyr::select(order(colnames(biber_counts)), -tot_counts)

  return(biber_counts)

}

