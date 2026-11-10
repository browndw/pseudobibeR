# pseudobibeR 1.3.9000 (development version)

## Corrections that change results

* These changes align the English package with decisions shared by the
  Spanish (`pseudobibeR.es`) and French (`pseudobibeR.fr`) packages; decision
  IDs refer to `CROSS_LANGUAGE_ALIGNMENT.md` in this repository.

* `f_42_adverbs` follows Biber's definition: adverbs counted as place or time
  adverbials (f_04, f_05), downtoners (f_46), hedges (f_47) or amplifiers
  (f_48) are no longer also counted as total adverbs (D-15). Exclusion is by
  occurrence, so the words of a multiword hedge such as *kind of* are removed
  once and other adverbs in the same text still count.
* `f_44_mean_word_length` counts words in any alphabet (*café*, *naïve*);
  previously only ASCII letters were accepted (D-51).
* `f_62_split_infinitive` no longer counts negation alone as a split
  (*to not go*, *to never go*); *to not really go* still counts (D-28, D-48).
