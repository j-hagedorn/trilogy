# Trilogy Data Dictionary

## TMI

The `tmi` dataset contains the Thompson Motif Index (TMI), with each row representing a single motif.

![](images/tmi_example.png)

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
- `provenance`
- `tale_type`
- `remarks`
- `combos`

### Motif Sequences

The `atu_seq` dataset has one row for each occurrence of a TMI motif within a tale type from the ATU index.  The following variables are available for each occurrence of a motif identified within the `tale_type` description from the `atu_df` dataset.  For some tales, multiple combinations of motifs are noted as possible permutations of the tale (for example, ATU 605A is a story in "*A young man, born of an animal... or from a giant... [B631, F611.1.1, F611.1.11-F611.1.15, T516] develops great strength (at the forge, in the forest, in war, by suckling for many years [F611.2.1, F611.2.3]...)*").  In these instances, all of the possible permutations are listed as specific variants of the tale type.  When ranges of motifs are referenced (e.g. *F611.1.11-F611.1.15*, above) all motifs within that range are included and provided with different variants.

#### Variables

- `atu_id`: The tale type identifier.  This field can be used to join this dataset with the `atu_df` to get additional data regarding the tale type.
- `tale_variant`: The specific permutation of the tale type, as described above.
- `motif_order`: The order in which the motif is mentioned within the text of the `tale_type` description.  Since the `tale_type` description most often summarizes the story in chronological order, this field is a rough approximation of the order in which motifs occur within the tale.
- `motif`: The identifier for the motif.  This field can be used to join to the `tmi` dataset to get additional data related to the motif.

### Tale Combinations

The `atu_combos` dataset has one row for each possible combination of a given `atu_id` with another `atu_id`, as identified in the ATU Index.  The following variables are available for each combination identified:

#### Variables

- `atu_id`
- `combo`

## AFT

The Annotated Folk Tales (i.e. `aft`) dataset contains folktales that have been marked as characteristic of a specific tale type from the ATU.  It contains one row per tale, and only includes stories with a specified `atu_id`.

![](images/aft_example.png)

#### Variables

- `atu_id`
- `tale_title`
- `provenance`
- `notes`
- `source`
- `text`
- `data_source`
- `date_obtained`

