# Prepare sample texts. All texts from public domain works provided by Project
# Gutenberg, <https://gutenberg.org>, and may be redistributed with no
# restrictions.

text <- read.delim("raw-text.txt", sep = "\t", header = FALSE)

## udpipe
library(udpipe)

ud_model <- udpipe_load_model("english-ewt-ud-2.5-191206.udpipe")

udpipe_samples <- udpipe_annotate(ud_model, x = text$V2, doc_id = text$V1, parser = "default")

usethis::use_data(udpipe_samples, overwrite = TRUE)

## spacyr
library(spacyr)
spacy_initialize(model = "en_core_web_sm")

corpus <- text$V2
names(corpus) <- text$V1

spacy_samples <- spacy_parse(corpus, pos = TRUE, tag = TRUE, dependency = TRUE, entity = FALSE)

usethis::use_data(spacy_samples, overwrite = TRUE)
