# R project for practicing with data manipulation with.

# How to knit the R files:

Use the package `ezknitr` installing it as `devtools::install_github("daattali/ezknitr")`.

To run `spin`, and overcome the working directory problem, use `ezknitr::ezspin("01-data-import/01-data-import-solutions.R", wd = ".")`. Otherwise, use  `knitr::spin()`.