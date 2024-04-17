# we don't call udpipe functions directly, but biber_udpipe() depends on its
# method for conversion to data frame
library(udpipe)

udp <- readRDS(test_path("text-samples/udpipe-samples.rds"))
udp_biber <- biber_udpipe(udp, normalize = FALSE)

spcy <- readRDS(test_path("text-samples/spacy-samples.rds"))
spacy_biber <- biber_spacy(spcy, normalize = FALSE)

# Features to check. Named list. Names are the sample documents, as given in
# samples.tsv. Values are lists of named features and the counts to expect. Set
# `spacy = FALSE` or `biber = FALSE` to indicate the document tests should be
# skipped for that tagger, e.g. because the model fails to detect a feature for
# this particular sample.
check_features <- list(
  quickbrown = list(
    f_03_present_tense = 1
  ),
  adj_pred = list(
    f_41_adj_pred = 1
  ),
  initial_demonstrative = list(
    f_51_demonstratives = 1
  ),
  subordinator_that = list(
    f_60_that_deletion = 1
  ),
  perfect_aspect = list(
    f_02_perfect_aspect = 1
  ),
  that_verb_comp = list(
    f_21_that_verb_comp = 1
  ),
  that_adj_comp = list(
    f_22_that_adj_comp = 1
  ),
  present_participle = list(
    f_25_present_participle = 1
  ),
  sentence_relatives = list(
    f_34_sentence_relatives = 1
  )
)

for (doc_id in names(check_features)) {
  document_biber <- udp_biber[udp_biber$doc_id == doc_id, ]
  document_spacy <- spacy_biber[spacy_biber$doc_id == doc_id, ]

  test_that(paste0("document: ", doc_id), {
    # make sure this doc_id exists
    expect_equal(nrow(document_biber), 1)
    expect_equal(nrow(document_spacy), 1)

    features <- check_features[[doc_id]]

    for (feature in names(features)) {
      expect_true(feature %in% names(document_biber))
      if (!isFALSE(features$biber)) {
        expect_equal(document_biber[[!! feature]], features[[!! feature]])
      }

      expect_true(feature %in% names(document_spacy))
      if (!isFALSE(features$spacy)) {
        expect_equal(document_spacy[[!! feature]], features[[!! feature]])
      }
    }
  })
}
