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
- `sub_division`
- `atu_id`
- `tale_name`
- `litvar`
- `provenance`
- `tale_type`
- `remarks`
- `combos`

### Motif Sequences

The `atu_seq` dataset has one row for each occurrence of a TMI motif within a tale type from the ATU index.  The following variables are available for each occurrence of a motif identified within:

#### Variables

- `atu_id`
- `tale_variant`
- `motif_order`
- `motif`

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

