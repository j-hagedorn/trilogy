
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6575263.svg)](https://doi.org/10.5281/zenodo.6575263)


# What’s here?

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

# Instructions for Use and Collaboration

## Using the Data

To begin using the datasets, please see the [Getting
Started](https://github.com/j-hagedorn/trilogy/blob/master/docs/vignettes/getting_started.md)
document for instructions. This repository is licensed under a [CC
BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) open
license. Its contents are either in the public domain, or permissions
have been granted by the copyright holder for inclusion. To cite the use
of this repository or its data in publications, please reference the
repository as well as the works from which it derives:

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
        author = {Ashliman, D.L.}
    }
    
    @book{thompson_motif_index,
        title = {Motif-index of folk-literature; a classification of narrative elements in folktales, ballads, myths, fables, mediaeval romances, exempla, fabliaux, jest-books, and local legends.},
        shorttitle = {Thompson's {Motif} {Index}},
        publisher = {Indiana University Press},
        address = {Bloomington},
        author = {Thompson, Stith},
        year = {1955}
    }

## Collaboration

We are excited to collaborate. If you find issues with any of the
datasets or scripts, please file an issue on this repository. If you
make improvements to the scripts, or develop new scripts to incorporate
additional motifs, tale types, or tale texts, please submit a pull
request. Additional instructions about contributing are available in the
[Getting
Started](https://github.com/j-hagedorn/trilogy/blob/master/docs/vignettes/getting_started.md)
document.
