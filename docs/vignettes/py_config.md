Based on the documentation included
[here](https://support.rstudio.com/hc/en-us/articles/360023654474-Installing-and-Configuring-Python-with-RStudio).
Assumes that Python (using Miniconda) has been installed.

1.  *In terminal*: Ensure that installation of Python has the virtualenv
    package installed by running: `pip install virtualenv`
2.  *In terminal*: Navigate into RStudio project directory using:
    `cd "C:/Users/joshh/Documents/GitHub/trilogy"`
3.  *In terminal*: Create new virtual environment in a folder called
    `my_env` within project directory using the following command:
    `virtualenv my_env`
4.  *In terminal*: Activate the `virtualenv` in current project using
    the following command: `source my_env/bin/activate`
5.  *In terminal*: Install packages
    `pip install numpy pandas matplotlib spacy`
6.  *In console*: Install package `install.packages("reticulate")`
7.  Configure `reticulate` to point to the Python executable in your
    `virtualenv` by creating an `.Rprofile` file in your project
    directory, with the following contents:
    `Sys.setenv(RETICULATE_PYTHON = "my_env/bin/python")`
