# Purpose

This repository houses tidy data of key catalogs and collections of
mythology and folklore, for use in discovery of patterns using natural
language processing and others statistical methods. The following
datasets are located in the `/data` sub-folder:

  - `tmi`, *the Thompson Motif Index*: each row is a single motif from
    the index, and also contains information regarding the chapter,grand
    division, division, and subdivision(s) under which motifs are
    nested, as well as the supplementary notes for each motif where
    these exist.
  - `atu`, *the Aarne-Thompson-Uther Tale Type Index*: IN DEVELOPMENT
  - `aft`, *Ashliman’s Folktexts*: each row contains the text of a
    single tale from the [Ashliman corpus of annotated
    tales](https://www.pitt.edu/~dash/folktexts.html), as well as an
    indicator of which ATU tale type the tale exemplifies. This is
    intended to serve as training data for algorithms to classify tale
    types and find motifs and motif sequences in unstructured text.

# Replication

For the purposes of reproducibility and continual methodological
improvement, we have shared the scripts used to obtain and clean these
datasets in the `fetch/` subfolder. The `tmi` dataset was built with the
`fetch_motifs.R` script, the `atu` with the `fetch_taletypes.R` script,
and the `aat` with the `fetch_ashliman.R`script. Additional
considerations and notes regarding the development of the datasets can
be found in the `docs/` folder.

If you find issues with any of the datasets or scripts, please file an
issue on this repository. If you make improvements to the scripts,
please consider submitting a pull request.

# Please use, cite, and make suggestions

This work is licensed under [CC
BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/). If you have
suggestions about how we might extend or improve this data repository,
please file an issue. We are excited to collaborate.
