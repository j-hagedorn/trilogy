Purpose
=======

This repository houses tidy datasets for the following catalogs and
collections of mythology and folklore, for use in discovery of patterns
using natural language processing and others statistical methods. The
following datasets are located in the `/data` sub-folder:

-   `tmi`, *the Thompson Motif Index*:
-   `atu`, *the Aarne-Thompson-Uther Tale Type Index*:
-   `aat`, *Ashliman’s annotated tales*:

Replication
===========

For the purposes of reproducibility and continual methodological
improvement, we have shared the scripts used to obtain and clean these
datasets in the `fetch/` subfolder. The `tmi` dataset was built with the
`fetch_motifs.R` script, the `atu` with the `fetch_taletypes.R` script,
and the `aat` with the `fetch_ashliman.R`script. If you find issues with
any of the datasets or scripts, please file an issue on this repository.
If you make improvements to the scripts, please consider submitting a
pull request.

Please use, remix, and cite
===========================

This work is licensed under [CC BY-NC
4.0](https://creativecommons.org/licenses/by-nc/4.0/).
