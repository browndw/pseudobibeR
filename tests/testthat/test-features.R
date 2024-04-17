library(udpipe)

udp <- readRDS(test_path("text-samples/udpipe-samples.rds"))

udp_biber <- biber_udpipe(udp, normalize = FALSE)

# Features to check. Named list. Names are the sample documents, as given in
# samples.tsv. Values are lists of named features and the counts to expect.
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
  document <- udp_biber[udp_biber$doc_id == doc_id, ]

  test_that(paste0("document: ", doc_id), {
    # make sure this doc_id exists
    expect_equal(nrow(document), 1)

    features <- check_features[[doc_id]]

    for (feature in names(features)) {
      expect_true(feature %in% names(document))
      expect_equal(document[[!! feature]], features[[!! feature]])
    }
  })
}
