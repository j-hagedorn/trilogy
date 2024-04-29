# Trilogy Data Dictionary

## TMI

The `tmi` dataset contains the Thompson Motif Index (TMI), with each row representing a single motif.

![](images/tmi_example.png)

### Brief Review of Thompson's Structure

While a complete description of the index structure is provided by Thompson, in the introductory section entitled 'Plan of the Work', it is worth providing a brief review here.  Detailed motifs are nested into larger and larger groups, culminating in the 'chapters' of the index:

*chapter > grand division > division > subdivision(s) > motif*

Descriptions of each level are provided here, derived from Thompson's introduction:

0. *Chapter*: The largest groupings in the index are called "chapters".
1. *Grand Division*: Within each chapter, grand divisions are ranges of a hundred numbers, or some multiple of a hundred numbers. E.g. B0—B99 concerns mythical animals; B100—B199, magic animals; etc.
2. *Division*: Within each grand division, divisions are ranges of tens or groups of tens. The first (e.g. *B0—B9. Mythical animals — general.*) and last (e.g. *B90—B99. Other mythical animals.*) divisions serve specific roles: the first "treats the general idea of the grand division", while the last "deals with miscellaneous material". The rest of the intervening divisions deal with "specific ideas" (e.g. *B50—B59. Bird-men.*) 
3. *Subdivision(s)*: Within each division (e.g. B10—B19) the arrangement follows a similar principle. The first number (ending in "0") refers to the general concept, succeeding numbers to specific aspects, and the last to miscellaneous/additional material.
4. *Motif(s)*:  Motifs have different levels of granularity.  Since a motif is defined simply as the finest-grained level of the structure, subdivisions which have received greater attention will tend to have more finely distinguished motifs. Thompson notes that "It is frequently desirable to subdivide a number. This is done by pointing, thus: B11. Dragon. — B11.1. Origin of the dragon. — B11.1.1. Dragon from cock's egg. — B11.1.2. Dragon from transformed horse. — B11.2. Form of dragon. — B11.2.1. Dragon as compound animal. This system of subdivision maybe carried on indefinitely. Such an item as E501 with more than two hundred subdivisions will illustrate the manner in which any item may be subdivided, no matter how elaborate the analysis."

#### Variables

- `id`: the unique identified motif identifier.  This includes identifiers at various hierarchical levels (for instance, *A13*, *A13.1*, and *A13.1.1* each has a single row in this dataset, despite occurring at different hierarchical levels).
- `chapter_id`,`chapter_name`: The identifier and name of the highest-level grouping of motifs, called chapters.  These include groupings such as: *Myths*, *Animals*, *Tabu*, *Magic*, *Death*, *Marvels*, etc.
- `motif_name`: The text description of the motif.
- `notes`: Various notes related to the motif, including information on additional descriptions, countries of origin, literature sources, etc.
- `level`: The level of the TMI hierarchy which the motif is from (0-6). 
- `level_0`-`level_6`: The hierarchical level groups under which the motif falls.  For example, the motif *A15.4.1* (Potter As Creator) includes *A0* at `level_0`, *A10* at `level_1`, *A15* at `level_2`, *A15.4* at `level_3`, and *A15.4.1* at `level_4`, and is NA at `level_5` and `level_6`.

## ATU

There are a few datasets derived from the Aarne–Thompson–Uther (ATU) Index published by Hans-Jörg Uther.

![](images/atu_example.png)

### Tale Types

The `atu_df` dataset has one row for each tale type from the index.  The following variables are available for each tale type:

#### Variables

- `chapter`: The highest level groupings into which tale types are classified.  Includes: *Anecdotes And Jokes*, *Animal Tales*, *Formula Tales*, *Tales Of Magic*, etc.
- `division`: The next highest level of groupings into which tale types are classified.  Example: *Stories About A Fool 1200-1349*.
- `sub_division`: The lowest level of groupings into which tale types are classified.
- `atu_id`: The tale type identifier.  This dataset contains one row per `atu_id`.
- `tale_name`: The descriptive name for the tale type, corresponding to an `atu_id`.
- `litvar`: A list of literary variants of the tale type, from different collections.
- `provenance`: The location(s) or culture(s) from which the tale type comes.
- `tale_type`: A brief summary of the plot of the tale type.
- `remarks`: Miscellaneous remarks about the tale type, such as who first documented it, when it was documented, and where (e.g. "*...by Maurice de Sully in a French sermon in the 12th c.*").
- `combos`: A manually documented list of `tale_id`s which are commonly combined with the tale type in practice.

### Motif Sequences

The `atu_seq` dataset has one row for each occurrence of a TMI motif within a tale type from the ATU index.  The following variables are available for each occurrence of a motif identified within the `tale_type` description from the `atu_df` dataset.  For some tales, multiple combinations of motifs are noted as possible permutations of the tale (for example, ATU 605A is a story in "*A young man, born of an animal... or from a giant... [B631, F611.1.1, F611.1.11-F611.1.15, T516] develops great strength (at the forge, in the forest, in war, by suckling for many years [F611.2.1, F611.2.3]...)*").  In these instances, all of the possible permutations are listed as specific variants of the tale type.  When ranges of motifs are referenced (e.g. *F611.1.11-F611.1.15*, above) all motifs within that range are included and provided with different variants.

#### Variables

- `atu_id`: The tale type identifier.  This field can be used to join this dataset with the `atu_df` to get additional data regarding the tale type.
- `tale_variant`: The specific permutation of the tale type, as described above.
- `motif_order`: The order in which the motif is mentioned within the text of the `tale_type` description.  Since the `tale_type` description most often summarizes the story in chronological order, this field is a rough approximation of the order in which motifs occur within the tale.
- `motif`: The identifier for the motif.  This field can be used to join to the `tmi` dataset to get additional data related to the motif.

### Tale Combinations

The `atu_combos` dataset has one row for each possible combination of a given `atu_id` with another `atu_id`, as identified in the `combos` field of the `atu_df` dataset. The following variables are available for each combination identified:

#### Variables

- `atu_id`: The tale type identifier.  This field can be used to join this dataset with the `atu_df` to get additional data regarding the tale type.
- `combo`: A tale type identifier which is noted for its occurrence in combination with `atu_id`.

## AFT

The Annotated Folk Tales (i.e. `aft`) dataset contains folktales that have been marked as characteristic of a specific tale type from the ATU.  It contains one row per tale, and only includes stories with a specified `atu_id`.

![](images/aft_example.png)

#### Variables

- `atu_id`: The tale type identifier.  This field can be used to join this dataset with the `atu_df` to get additional data regarding the tale type.
- `tale_title`: The specific name of the tale.  Note that this is commonly different than the text description of the tale type from `atu_df`, though sometimes they match.
- `provenance`: Designates the country, region, tribe, and/or author from which the tale comes.
- `notes`: Miscellaneous notes related to the tale, provided by the archiver.
- `source`: The publication from which the tale has been derived or excerpted.
- `text`: The narrative text of the tale itself.
- `data_source`: The name of the corpus, website, or other source from which the tale was obtained.
- `date_obtained`: The date on which the tale data was obtained from the `data_source`.

