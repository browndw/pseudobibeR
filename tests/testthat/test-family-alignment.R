# Rules shared with the Spanish and French packages (see
# CROSS_LANGUAGE_ALIGNMENT.md). Annotations reproduce en_core_web_sm output.

parsed <- function(doc_id, token, lemma, pos, tag, head, dep) {
  n <- length(token)
  structure(
    data.frame(doc_id = doc_id, sentence_id = 1L, token_id = seq_len(n), token = token,
               lemma = lemma, pos = pos, tag = tag, head_token_id = head, dep_rel = dep,
               stringsAsFactors = FALSE),
    class = c("spacyr_parsed", "data.frame")
  )
}

counts <- function(...) {
  tokens <- do.call(rbind, list(...))
  class(tokens) <- c("spacyr_parsed", "data.frame")
  suppressMessages(biber(tokens, measure = "none", normalize = FALSE))
}

test_that("f_42 excludes adverbs counted as hedges, amplifiers, downtoners, place and time adverbials (D-15)", {
  result <- counts(
    parsed("specialized", c("it", "was", "very", "kind", "of", "him", ",", "maybe", "."),
           c("it", "be", "very", "kind", "of", "he", ",", "maybe", "."),
           c("PRON", "AUX", "ADV", "ADV", "ADP", "PRON", "PUNCT", "ADV", "PUNCT"),
           c("PRP", "VBD", "RB", "RB", "IN", "PRP", ",", "RB", "."),
           c(2, 2, 4, 2, 4, 5, 2, 2, 2),
           c("nsubj", "ROOT", "advmod", "advmod", "prep", "pobj", "punct", "advmod", "punct")),
    parsed("plain", c("he", "ran", "quickly", "."), c("he", "run", "quickly", "."),
           c("PRON", "VERB", "ADV", "PUNCT"), c("PRP", "VBD", "RB", "."),
           c(2, 2, 2, 2), c("nsubj", "ROOT", "advmod", "punct"))
  )
  expect_equal(result$f_42_adverbs, c(0, 1))
  expect_equal(result$f_47_hedges, c(2, 0))
  expect_equal(result$f_48_amplifiers, c(1, 0))
})

test_that("f_62 does not count negation alone as a split (D-28, D-48)", {
  infinitive <- function(doc, adverbs) {
    k <- length(adverbs)
    parsed(doc, c("she", "tried", "to", adverbs, "go", "."),
           c("she", "try", "to", adverbs, "go", "."),
           c("PRON", "VERB", "PART", rep("ADV", k), "VERB", "PUNCT"),
           c("PRP", "VBD", "TO", rep("RB", k), "VB", "."),
           c(2, 2, 4 + k, rep(4 + k, k), 2, 2),
           c("nsubj", "ROOT", "aux", rep("advmod", k), "xcomp", "punct"))
  }
  result <- counts(
    infinitive("not", "not"),
    infinitive("never", "never"),
    infinitive("really", "really"),
    infinitive("not_really", c("not", "really"))
  )
  expect_equal(result$f_62_split_infinitive, c(0, 0, 1, 1))
})

test_that("f_44 counts words in any alphabet (D-51)", {
  result <- counts(
    parsed("accents", c("she", "ate", "at", "the", "caf\u00e9", "na\u00efvely", "."),
           c("she", "eat", "at", "the", "caf\u00e9", "na\u00efvely", "."),
           c("PRON", "VERB", "ADP", "DET", "NOUN", "ADV", "PUNCT"),
           c("PRP", "VBD", "IN", "DT", "NN", "RB", "."),
           c(2, 2, 2, 5, 3, 2, 2),
           c("nsubj", "ROOT", "prep", "det", "pobj", "advmod", "punct"))
  )
  expect_equal(result$f_44_mean_word_length, 22 / 6)
})
