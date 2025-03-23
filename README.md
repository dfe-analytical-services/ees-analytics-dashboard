# Explore education statistics analytics - dashboard

This is an R Shiny dashboard that visualises analytics data collected on our explore education statistics platform.

It is deployed via the DfE POSIT Connect subscription internally. There are two environments, both only accessible to DfE AD:

* Production - https://rsconnect/rsc/ees-analytics/
* Pre-production - https://rsconnect-pp/rsc/ees-analytics/

## Data processing and update pipelines

Code used to extract source data, process it, and save a permanent store for usage by the analytics dashboard, as well as ad hoc analysis scripts are in a separate GitHub repository - https://github.com/dfe-analytical-services/explore-education-statistics-analytics.

## Requirements

### i. Software requirements (for running locally)

- Installation of R 4.4.2 or higher
- Installation of RTools44 or higher

### ii. Programming skills required (for editing or troubleshooting)

- R at an intermediate level, [DfE R learning resources](https://dfe-analytical-services.github.io/analysts-guide/learning-development/r.html)
- Particularly [R Shiny](https://shiny.rstudio.com/)

### iii. Access requirements

If you don't have access to the source data, you can run the dashboard using local test data instead.

This will set the same environment variable used in shinytest2, and make all of the data functions switch to local instead of database:
```r
withr::with_envvar(c(TESTTHAT = "true"), shiny::runApp())
```

Data storage:
- Access the statistics services area of the unity catalog in the delta lake

To set up access to the app, and understand how the app itself is connected to the SQL warehouse on the server, look at:
- [Connecting to a SQL warehouse from R Studio](https://dfe-analytical-services.github.io/analysts-guide/ADA/databricks_rstudio_sql_warehouse.html)
- [R Shiny app databricks connection guide](https://rsconnect/rsc/posit-connect-guidance/_book/databricks-connections.html).

## Contributing to the dashboard

### Running locally

Package control is handled using [renv](https://rstudio.github.io/renv/articles/renv.html) at the top level of the repository.

1. Clone or download the repo
2. Open the R project in R Studio
3. Run `renv::restore()` to install dependencies
4. Run `install.packages("git2r")` to install the git2r package, ignored by renv to help deployments but necessary for the pre-commit hooks.
4. Run `shiny::runApp()` to run the dashboard locally

### Tests and test data

Tests can be run locally by using `shinytest2::test_app()`. You should do this regularly to check that the tests are passing against the code you are working on.

The tests use data in the `tests/testdata/` folder, to regenerate this data use the `tests/testdata-generator.R` script. 

``` r
source("tests/testdata-generator.R")
```

Whenever a new database table is added for the app, add this into the generator script so then the tests will have a copy to use. The list of files in the `tests/testdata` folder should always match the list of database tables that the app requires.

GitHub Actions provide CI by running the automated tests on every pull request into the main branch using the `.github/workflows/dashboard-tests.yml` workflow.

### Flagging issues

If you spot any issues with the application, please flag it in the "Issues" tab of this repository, and label as a bug. Include as much detail as possible to help us diagnose the issue and prepare a suitable remedy.

### Making suggestions

You can also use the "Issues" tab in GitHub to suggest new features, changes or additions. Include as much detail on why you're making the suggestion and any thinking towards a solution that you have already done.

### Navigation

In general all `.R` files will have a usable outline, so make use of that for navigation if in RStudio: `Ctrl-Shift-O`.

### Code styling 

The function `styler::style_dir()` will tidy code according to tidyverse styling using the styler package. Run this regularly as our pre-commit hooks will prevent you committing code that isn't tidied. This function also helps to test the running of the code and for basic syntax errors such as missing commas and brackets.

You should also run `lintr::lint_dir()` regularly as lintr will check all pull requests for the styling of the code, it does not style the code for you like styler, but is slightly stricter and checks for long lines, variables not using snake case, commented out code and undefined objects amongst other things.

### Pre-commit hooks

We have some pre-commit hooks set up to help with code quality. These are controlled by the `.hooks/pre-commit.R` file.

## Contact

explore.statistics@education.gov.uk