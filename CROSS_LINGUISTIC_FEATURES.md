# Biber's features in English, Spanish and French

This table shows how each of the 67 features is realized by the three packages
in the pseudobibeR family:

- [pseudobibeR](https://github.com/browndw/pseudobibeR) (English),
- [pseudobibeR.es](https://github.com/browndw/pseudobibeR.es) (Spanish),
- [pseudobibeR.fr](https://github.com/browndw/pseudobibeR.fr) (French).

The features come from Douglas Biber's multidimensional analysis of English
registers (Biber 1985, 1988). Many of them carry over directly to Spanish and
French: all three languages have passives, relative clauses and modal verbs.
Others are tied to English grammar (pronoun *it*, the pro-verb *do*,
contractions such as *don't*). For those, the Spanish and French packages
count the construction that does the same job in that language, or keep the
column at zero if there is no such construction.

## How to read the table

**Feature numbers line up across languages.** `f_15` is "the same feature" in
all three packages, even when the column name differs. Spanish and French use
names that describe what they actually count (`f_15_nominal_infinitives`
rather than `f_15_gerunds`). To get the shared English-style names in every
package, for example to combine results from several languages, use:

```r
biber(parsed, feature_names = "shared")
# or once per session, for all three packages:
options(pseudobibeR.feature_names = "shared")
```

**The correspondence column** says how close the languages are:

| Correspondence | Meaning |
|---|---|
| **Same** | The same grammatical construction exists and is counted in the same way. |
| **Analogue** | The English construction does not exist, or works differently; the package counts the construction that fills the same role. |
| **Zero** | No reasonable counterpart; the column is always 0 and kept only so that tables line up. |

Each package's README has a fuller table with examples, and each package
documents its exact counting rules in a technical reference. Decisions about
analogues are logged in [CROSS_LANGUAGE_ALIGNMENT.md](CROSS_LANGUAGE_ALIGNMENT.md).

## The features

### A. Tense and aspect

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 01 | past tense (*walked*) | preterite and imperfect (*llegó, llegaba*) | passé simple and imperfect (*arriva, arrivait*) | Same |
| 02 | perfect aspect (*has walked*) | *haber* + participle (*ha llegado*) | *avoir/être* + participle (*il est arrivé*) | Same |
| 03 | present tense (*walks*) | present indicative and subjunctive (*llega, llegue*) | present indicative and subjunctive (*arrive*) | Same |

### B. Place and time adverbials

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 04 | place adverbials (*outdoors, nearby*) | *aquí, lejos, arriba…* | *dehors, loin, ici…* | Same |
| 05 | time adverbials (*early, soon*) | *ayer, hoy, pronto…* | *demain, hier, bientôt…* | Same |

### C. Pronouns and pro-verbs

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 06 | first person (*I, we*) | *yo, nosotros, me…* | *je, nous, me…* | Same |
| 07 | second person (*you*) | *tú, usted, vosotros…* | *tu, vous, te…* | Same |
| 08 | third person (*he, they*) | *él, ella, ellos…* | *il, elle, ils, lui…* | Same |
| 09 | pronoun *it* | impersonal subjects (*llueve, es importante que…*) | impersonal *il* (*il pleut, il faut*) | Analogue |
| 10 | demonstrative pronouns (*that is…*) | *esto, eso, aquello* | *ce/c', ça, cela, celui-ci* | Same |
| 11 | indefinite pronouns (*someone*) | *alguien, nada, ninguno…* | *quelqu'un, rien, personne…* | Same |
| 12 | pro-verb *do* (*she did*) | *hacerlo* (*Luis también lo hizo*) | *le faire* (*je le fais souvent*) | Analogue |

Notes: English *it* refers to things and also fills empty subject slots.
Spanish has no overt "it", and French *il/elle* also mean "he/she", so both
packages count only the impersonal uses (weather, *it is necessary that…*).

### D. Questions

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 13 | *wh*-questions (*What happened?*) | *¿Qué pasó?* | *Qui a pris mon stylo ?* | Same |

### E. Nominal forms

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 14 | nominalizations (*-tion, -ment, -ity*) | *-ción, -miento, -dad…* | *-tion, -ment, -ité…* | Same |
| 15 | gerunds (*Running is fun*) | nominal infinitives (*Fumar perjudica, el saber*) | nominal infinitives (*Fumer tue, le savoir*) | Analogue |
| 16 | other nouns | other nouns | other nouns | Same |

Notes: an English gerund is a verb form used as a noun. Spanish and French use
the infinitive for this; their *-ndo/-ant* forms are not nominal.

### F. Passives

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 17 | agentless passive (*was approved*) | *fue aprobada*, *se publicaron los datos* | *a été préparé* | Same |
| 18 | *by*-passive (*written by…*) | *escrita por…* | *écrit par…* | Same |

### G. Stative forms

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 19 | *be* as main verb | *ser/estar* as main verb | *être* as main verb | Same |
| 20 | existential *there* | *hay, había* | *il y a* | Same |

### H. Subordination

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 21 | *that* after a verb (*I think that…*) | *que* after a verb (*creo que…*) | *que* after a verb (*je crois que…*) | Same |
| 22 | *that* after an adjective (*glad that…*) | *es importante que…* | *content que…* | Same |
| 23 | *wh*-clauses (*I know what he said*) | *sé lo que dijo, no sé quién…* | *je sais ce qu'il a dit* | Same |
| 24 | infinitives (*to leave*) | infinitives (*quiere salir*) | infinitives (*il veut partir*) | Same |
| 25 | *-ing* adverbial clause (*Walking home, I…*) | gerund clause (*Caminando por el parque, …*) | participial clause (*En travaillant dur, …*) | Analogue |
| 26 | past participial clause (*Built in a week, …*) | *Terminado el examen, …* | *Construit en un an, …* | Same |
| 27 | reduced relative, past participle (*the house built in 1900*) | *la casa construida en 1900* | *la maison construite en 1900* | Same |
| 28 | reduced relative, present participle (*the man wearing a hat*) | — (always 0) | *l'homme portant un chapeau* | Zero (es) / Same (fr) |
| 29 | *that* relative, subject (*the dog that bit me*) | *que*, subject | *qui* (*le chien qui m'a mordu*) | Same |
| 30 | *that* relative, object (*the dog that I saw*) | *que*, object | *que* (*le livre que j'ai lu*) | Same |
| 31 | *wh*-relative, subject (*the man who…*) | *quien, el cual*, subject | *lequel*, subject | Analogue |
| 32 | *wh*-relative, object (*the man whom…*) | *quien, el cual*, object | *lequel*, object (rare) | Analogue |
| 33 | pied-piping (*the way in which…*) | *con quien, en el que…* | *avec qui, dont, auquel…* | Same |
| 34 | sentence relative (*…, which surprised me*) | *…, lo que/lo cual…* | *…, ce qui/ce que…* | Same |
| 35 | causal *because* | *porque* | *parce que* | Same |
| 36 | concessive *although/though* | *aunque* | *bien que, quoique* | Same |
| 37 | conditional *if/unless* | *si, a menos que, salvo que* | *si, à moins que, sauf si* | Same |
| 38 | other adverbial subordinators (*while, since*) | *cuando, mientras, para que…* | *quand, pendant que, puisque…* | Same |

Notes:

- f_28: Spanish has no adjectival present participle. A gerund after a noun
  (*una caja conteniendo libros*) is considered incorrect in standard Spanish,
  so the column is kept at zero.
- f_29–f_32: English splits relatives by marker (*that* vs. *who/which*).
  Spanish and French split them by their own marker families: *que* vs.
  *quien/cual*, and *qui/que* vs. *lequel*. French marks subject and object by
  the form of the pronoun (*qui* vs. *que*).
- f_35–f_37 count only subordinators with one clear meaning, as Biber did.
  Words with several meanings (*since, puisque, como*) go to f_38.

### I. Prepositions, adjectives and adverbs

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 39 | prepositions | prepositions | prepositions | Same |
| 40 | attributive adjectives (*a new idea*) | *una idea nueva* | *une idée nouvelle* | Same |
| 41 | predicative adjectives (*it is new*) | *es nueva* | *elle est nouvelle* | Same |
| 42 | other adverbs | other adverbs | other adverbs | Same |

f_42 counts adverbs that are not already counted as place or time adverbials,
downtoners, hedges or amplifiers.

### J. Lexical specificity

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 43 | type/token ratio | type/token ratio | type/token ratio | Same |
| 44 | mean word length | mean word length | mean word length | Same |

These two are measures, not counts, and are never normalized.

### K. Lexical classes

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 45 | conjuncts (*however*) | *sin embargo* | *cependant* | Same |
| 46 | downtoners (*barely*) | *apenas* | *à peine* | Same |
| 47 | hedges (*maybe, sort of*) | *quizás, tal vez* | *peut-être, en quelque sorte* | Same |
| 48 | amplifiers (*very, totally*) | *muy, totalmente* | *très, complètement* | Same |
| 49 | emphatics (*really, for sure*) | *de hecho, sin duda* | *vraiment, bien sûr* | Same |
| 50 | discourse particles (*well, anyway*) | *bueno, pues* | *eh bien, du coup* | Same |
| 51 | demonstratives before a noun (*this book*) | *este libro* | *ce livre* | Same |

### L. Modals

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 52 | possibility (*can, may*) | *poder* | *pouvoir* | Same |
| 53 | necessity (*must, should*) | *deber, tener que, hay que* | *devoir, il faut* | Same |
| 54 | prediction (*will, would*) | future, conditional, *ir a* | future, conditional, *aller* + infinitive | Same |

### M. Specialized verb classes

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 55 | public verbs (*say, announce*) | *decir, anunciar* | *dire, annoncer* | Same |
| 56 | private verbs (*think, believe*) | *creer, pensar* | *croire, penser* | Same |
| 57 | suasive verbs (*suggest, insist*) | *sugerir, pedir* | *proposer, exiger* | Same |
| 58 | *seem/appear* | *parecer, resultar* | *sembler, paraître* | Same |

### N. Reduced forms and dispreferred structures

These features count an informal or less expected alternative when a fuller or
more standard form is available.

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 59 | contractions (*don't, I'll*) | colloquial reduced forms (*pa'*, *toy*) | colloquial reduced forms (*p'tit, t'as, y a*) | Analogue |
| 60 | *that*-deletion (*I think [ ] he left*) | reduced complement (*creo haber entendido*) | reduced complement (*je crois avoir compris*) | Analogue |
| 61 | stranded preposition (*the man I spoke to*) | resumptive relative (*el chico que hablé de él*) | orphan preposition or resumptive (*la fille que je sors avec*) | Analogue |
| 62 | split infinitive (*to really understand*) | *para realmente entender* | *de vraiment comprendre* | Same |
| 63 | split auxiliary (*has probably been*) | *ha probablemente sido* | *a probablement été* | Same |

Notes:

- f_59: standard French elision (*j'ai, l'homme*) is obligatory, so it is not
  counted. Only reductions with a full alternative (*p'tit* for *petit*) count.
- f_60: Spanish and French cannot normally drop *que*. The usual reduced
  alternative is an infinitive (*creo haber entendido* instead of *creo que he
  entendido*), counted after *creer/pensar/esperar/decir/afirmar*.
- f_61: Spanish cannot strand a preposition, so it counts the colloquial
  alternative to pied-piping: a relative with a repeated pronoun. Colloquial
  French also has true stranding (*la fille que je sors avec*).
- f_62: in French, short adverbs normally come before the infinitive (*pour
  mieux comprendre*), so only adverbs that normally follow it count.
- f_62 and f_63: negation alone (*to not go*, *n'a pas mangé*) is not counted.

### O. Coordination

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 64 | phrasal coordination (*apples and pears*) | *peras y manzanas* | *des pommes et des poires* | Same |
| 65 | clausal coordination (*it rained and we stayed*) | *llovió y nos quedamos* | *il pleuvait et nous sommes restés* | Same |

### P. Negation

| # | English | Spanish | French | Correspondence |
|---|---|---|---|---|
| 66 | synthetic negation (*no one, never, nor*) | *nadie, nunca, ni…* | *personne, jamais, aucun…* | Same |
| 67 | analytic negation (*not*) | *no* | *pas* (with or without *ne*) | Same |

Following Tottie, "synthetic" negation is built into a word (*nobody*), while
"analytic" negation is a separate particle (*not*). French *ne* is not counted
on its own, because it only accompanies another negative word.

## Normalization

Counts are given per 1,000 words by default (`normalize = TRUE`). In all three
packages, "words" exclude punctuation, symbols and numbers written in digits.
f_43 and f_44 are measures and are never normalized.

## References

Biber, D. (1985). Investigating macroscopic textual variation through
multifeature/multidimensional analyses. *Linguistics*, 23(2), 337–360.

Biber, D. (1988). *Variation across speech and writing*. Cambridge University
Press.

Tottie, G. (1991). *Negation in English speech and writing: A study in
variation*. Academic Press.
