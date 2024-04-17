test_that("normalize_counts is correct", {
  test_df <- data.frame(
    "doc_id" = c("foo", "bar", "baz"),
    "feature_1" = c(1, 2, 3),
    "feature_2" = c(3, 2, 1),
    "tot_counts" = c(1000, 2000, 3000)
  )

  out <- normalize_counts(test_df)

  expect_equal(out$feature_1, c(1, 1, 1))
  expect_equal(out$feature_2, c(3, 1, 1/3))
})
