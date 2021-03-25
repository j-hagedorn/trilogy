# Purpose

This repository houses tidy data of key catalogs and collections of
mythology and folklore, for use in discovery of patterns using natural
language processing and others statistical methods. The following
datasets are located in the `/data` sub-folder:

  - `tmi`, *The Motif Index*: each row is a single motif from the
    *Thompson Motif Index*, and also contains information regarding the
    chapter,grand division, division, and subdivision(s) under which
    motifs are nested, as well as the supplementary notes for each motif
    where these exist.
  - `atu`, *the Aarne-Thompson-Uther Tale Type Index*: IN DEVELOPMENT
  - `aft`, *Annotated Folktales*: each row contains the text of a single
    tale , as well as an indicator of which ATU tale type the tale
    exemplifies. This is intended to serve as training data for
    algorithms to classify tale types and find motifs and motif
    sequences in unstructured text. The dataset was initially seeded
    with [D.L. Ashliman’s corpus of annotated
    tales](https://www.pitt.edu/~dash/folktexts.html)

# Replication

For the purposes of reproducibility and continual methodological
improvement, we have shared the scripts used to obtain and clean these
datasets in the `fetch/` subfolder. The `tmi` dataset was built with the
`fetch_motifs.R` script, the `atu` with the `fetch_taletypes.R` script,
and the `aat` with the `fetch_ashliman.R`script. Additional
considerations and notes regarding the development of the datasets can
be found in the `docs/` folder.

If you find issues with any of the datasets or scripts, please file an
issue on this repository. If you make improvements to the scripts, or
develop new scripts to incorporate additional motifs, tale types, or
tale texts, please submit a pull request. Additional instructions about
contributing are available in the
[docs/vignettes/getting\_started](https://github.com/j-hagedorn/trilogy/blob/master/docs/vignettes/getting_started.md)
document.

# Please use, cite, and make suggestions

This work is licensed under a [CC
BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) open
license. Its contents are either in the public domain, or permissions
have been granted by the copyright holder for inclusion.

To cite the use of this repository or its data in publications, please
reference the repository as well as the works which it derives from:

    @misc{trilogy_repo,
        title = {trilogy},
        url = {https://github.com/j-hagedorn/trilogy},
        author = {Hagedorn, Joshua},
        abstract = {Reference datasets for myth and folktale motifs}
    }
    
    @misc{ashliman_folktexts,
        title = {Folktexts: {A} library of folktales, folklore, fairy tales, and mythology},
        copyright = {© 1996-2021},
        shorttitle = {Ashliman's {Folktexts}},
        url = {http://www.pitt.edu/~dash/folktexts.html},
        language = {English},
        journal = {Folktexts},
        author = {Ashliman, D.L.}
    }
    
    @book{thompson_motif_index,
        address = {Bloomington},
        edition = {Revised and enlarged edition},
        title = {Motif-index of folk-literature; a classification of narrative elements in folktales, ballads, myths, fables, mediaeval romances, exempla, fabliaux, jest-books, and local legends.},
        shorttitle = {Thompson's {Motif} {Index}},
        url = {https://catalog.hathitrust.org/Record/001276245},
        language = {English},
        publisher = {Indiana University Press},
        author = {Thompson, Stith},
        year = {1955},
        keywords = {Bibliography., Classification., Folk literature, Folklore, Themes, motives.}
    }

If you have suggestions about how we might extend or improve this data
repository, please file an issue. We are excited to collaborate.
