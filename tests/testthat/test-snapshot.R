# Test against changes of the output for the sample texts, across all features.
# Uses the testthat snapshot testing framework. See vignette("snapshotting",
# package="testthat").

library(udpipe)

udp <- readRDS(test_path("text-samples/udpipe-samples.rds"))

spcy <- readRDS(test_path("text-samples/spacy-samples.rds"))

test_that("counts are unchanged", {
  expect_snapshot_value(suppressMessages(biber(udp, measure = "TTR", normalize = FALSE)),
                        style = "json2")
  expect_snapshot_value(suppressMessages(biber(spcy, measure = "TTR", normalize = FALSE)),
                        style = "json2")
})

test_that("normalized output is unchanged", {
  expect_snapshot_value(suppressMessages(biber(udp, measure = "TTR")), style = "json2")
  expect_snapshot_value(suppressMessages(biber(spcy, measure = "TTR")), style = "json2")
})
