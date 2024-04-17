# Parse the samples with udpipe and spacy models.

text <- read.delim("samples.tsv", sep = "\t", header = FALSE)

## udpipe
library(udpipe)

ud_model <- udpipe_load_model("english-ewt-ud-2.5-191206.udpipe")

udp <- udpipe_annotate(ud_model, x = text$V2, doc_id = text$V1, parser = "default")

saveRDS(udp, file = "udpipe-samples.rds")

## spaCy
library(spacyr)
spacy_initialize(model = "en_core_web_sm")

corpus <- text$V2
names(corpus) <- text$V1

spcy <- spacy_parse(corpus, pos = TRUE, tag = TRUE, dependency = TRUE, entity = FALSE)

saveRDS(spcy, file = "spacy-samples.rds")
