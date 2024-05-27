It is assumed that users of this data may have different levels of
proficiency with different data tools. Below are a few quick notes on
how to access the data and start using it.

# Cloning the repo locally

If you cloned the GitHub repository on your local machine and have R
installed, you can simply run the following:

``` r
library(tidyverse)
tmi <- read_csv("../../data/tmi.csv")
atu_df <- read_csv("../../data/atu_df.csv")
atu_seq <- read_csv("../../data/atu_seq.csv")
atu_combos <- read_csv("../../data/atu_combos.csv")
aft <- read_csv("../../data/aft.csv")
```

# Pulling from GitHub

If you want to pull the raw flat files from the web using another coding
language (e.g. Python), use the following steps:

1.  Go to the [data folder of this
    repo](https://github.com/j-hagedorn/trilogy/tree/master/data)
2.  Select the data file you want to access (e.g. `aft.csv`)
3.  Click the *View Raw* button to display the raw data format.
4.  Copy the URL from the browser.

You can then read the data into Python, R, or other environments. Users
who are comfortable using MS Excel can access the raw flat files using
the URLs mentioned above and [import them into
Excel](https://support.office.com/en-za/article/Import-or-export-text-txt-or-csv-files-5250ac4c-663c-47ce-937b-339e391393ba)
using the steps outlined in the link.

# Use in Reproducible Research

For reproducible research, analyses using the dataset should use the URL
identifying the current version of the dataset at the time the analysis
was run.

To get a permanent link for reproducible research:

1.  Navigate to the dataset’s URL. For example,
    <https://github.com/j-hagedorn/trilogy/blob/master/data/aft.csv>.
2.  Press the `y` button on the keyboard to get a permanent link to the
    exact version of the dataset. Even as the dataset changes, other
    researchers will be able to use this link to run their code against
    the same version you used. See the GitHub documentation on “[Getting
    permanent links to
    files](https://docs.github.com/en/github/managing-files-in-a-repository/getting-permanent-links-to-files)”
    for more information.  
3.  Select the link to *View Raw*, which will display the raw `.csv`
    file. The URL will change its form, and also include an access
    token.
4.  Copy this URL. It is the key which will allow for reproducing any
    analysis using the dataset.

Once a permanent link has been copied, read the data into the desired
environment. An example of how to access the dataset is given below
using the `R` language, though similarly simple commands exist for
Python and other languages:

    aft <- read_csv("https://raw.githubusercontent.com/j-hagedorn/trilogy/YOUR_SHA_HERE/data/aft.csv?token=YOUR_TOKEN_HERE")

Please note that Excel is not recommended as a tool for reproducible
research, as the methods used to transform the data after download are
not captured in a replicable format.

# Growing and Refining the Corpus

We intend for the `trilogy` corpus to be supplemented over time, both
through our own efforts and through the efforts of folklorists around
the world. The open-source *Git* framework for collaboratively
developing code provides a stable and well-documented structure for
collaboratively maintaining a standard reference corpus.

1.  *Supplementing the corpus with new texts*. A new set of annotated
    tales can be submitted via a “pull request” in *GitHub*. Submissions
    should include a script to fetch new texts and transform them into
    the dataframe structure used by the `aft` dataset, as well as any
    source files required to run the script. For an example, see the
    `fetch/fetch_ashliman.R` script used to obtain the initial dataset.
    Pull requests provide a structure for submission of changes, as well
    as for testing and review of newly introduced code. Collaborators
    are encouraged to publish descriptions of their contributions as
    well: for instance, as a short data paper to the [*Journal of Open
    Humanities Data*](https://openhumanitiesdata.metajnl.com/).
2.  *Improving data quality*. In addition to growing the corpus, the
    *Git* framework allows for the ongoing improvement of data quality.
    Users of the dataset can file an issue on the repository in order to
    identify improvements to the data, or submit pull-requests proposing
    fixes to the existing scripts.

# Inspecting Source Scripts

For the purposes of reproducibility and continual methodological
improvement, we have shared the scripts used to obtain and clean these
datasets in the `fetch/` subfolder. The `tmi` dataset was built with the
`fetch_motifs.R` script, the `atu` with the `fetch_taletypes.R` script,
and the `aat` with the `fetch_ashliman.R`script. Additional
considerations and notes regarding the development of the datasets can
be found in the `docs/` folder.
