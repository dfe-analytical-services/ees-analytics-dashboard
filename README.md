# Explore education statistics analytics - dashboard

This is an R Shiny dashboard that visualises analytics data collected on our explore education statistics platform.

It is deployed via the DfE POSIT Connect subscription internally. There are two environments, both only accessible to DfE AD:

* Production - https://rsconnect/rsc/ees-analytics/
* Pre-production - https://rsconnect-pp/rsc/ees-analytics/

## Data processing and update pipelines

Code used to extract source data, process it, and save the database tables used in this analytics dashboard, as well as code for ad hoc analysis are kept in a sister GitHub repository - [ees-analytics-data](https://github.com/dfe-analytical-services/ees-analytics-data). This repository only contains code necessary for the dashboard itself.

## Requirements

### i. Software requirements (for running locally)

- Installation of R 4.4.2 or higher
- Installation of RTools44 or higher

### ii. Programming skills required (for editing or troubleshooting)

- R at an intermediate level, [DfE R learning resources](https://dfe-analytical-services.github.io/analysts-guide/learning-development/r.html)
- Particularly [R Shiny](https://shiny.rstudio.com/)

### iii. Access requirements

Data storage:
- Access the statistics services area of the unity catalog in the delta lake, specifically the `analytics_app` schema.

If you don't have access to the source data, you can run the dashboard using local test data instead.

This will set the same environment variable used in shinytest2, and make all of the data functions switch to local instead of database:
```r
withr::with_envvar(c(TESTTHAT = "true"), shiny::runApp())
```

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
5. Run `shiny::runApp()` to run the dashboard locally

It's also worth checking that you can run the automated tests using `shinytest2::test_app()`, so you can be confident you have everything set up correctly before you start developing.

### Adding new data

All data is pulled from our unity catalog area under the `analytics_app` schema. Each table used in the app also has a local parquet file equivalent for use in automated tests and for development in case you can't access the main database.

If you're adding any new data into the dashboard, make sure to update the `tests/testdata-generator.R` script to add in any new tables, and then use that script to regenerate the test data.

### Tests and test data

Tests can be run locally by using `shinytest2::test_app()`. You should do this regularly to check that the tests are passing against the code you are working on.

The tests use data in the `tests/testdata/` folder, to regenerate this data use the `tests/testdata-generator.R` script. 

``` r
source("tests/testdata-generator.R")
```

Whenever a new database table is added for the app, add this into the generator script so then the tests will have a copy to use. The list of files in the `tests/testdata` folder should always match the list of database tables that the app requires.

GitHub Actions provide CI by running the automated tests on every pull request into the main branch using the `.github/workflows/dashboard-tests.yml` workflow.

### Code styling and pre-commit hooks

The function `styler::style_dir()` will tidy code according to tidyverse styling using the styler package. Run this regularly as our pre-commit hooks (set in the `.hooks/pre-commit.R` file) will prevent you committing code that isn't tidied. This function also helps to test the running of the code and for basic syntax errors such as missing commas and brackets.

You should also run `lintr::lint_dir()` regularly as lintr will check all pull requests for the styling of the code, it does not style the code for you like styler, but is slightly stricter and checks for long lines, variables not using snake case, commented out code and undefined objects amongst other things.

## Contact

explore.statistics@education.gov.uk