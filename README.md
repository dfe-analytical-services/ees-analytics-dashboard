# Explore education statistics analytics - dashboard

This is an R Shiny dashboard that visualises analytics data collected on our explore education statistics platform.

It is deployed via the DfE POSIT Connect subscription internally. There are two environments, both only accessible to on the DfE network:

* Production - https://rsconnect/rsc/ees-analytics/
* Pre-production - https://rsconnect-pp/rsc/ees-analytics/

## Data processing and update pipelines

This repository only contains code necessary for the dashboard itself.

Code used to extract source data, process it, and save the database tables used in this analytics dashboard, as well as code for ad hoc analysis are kept in a sister GitHub repository ([ees-analytics-data](https://github.com/dfe-analytical-services/ees-analytics-data)).

## Requirements

### i. Software requirements (for running locally)

- Installation of R 4.4.2 or higher
- Installation of RTools44 or higher

### ii. Programming skills required (for editing or troubleshooting)

- R at an intermediate level, [DfE R learning resources](https://dfe-analytical-services.github.io/analysts-guide/learning-development/r.html)
- Particularly [R Shiny](https://shiny.rstudio.com/)

### iii. Access requirements

To use the full data, you will need access the statistics services area of the unity catalog in the DfE delta lake, specifically the `analytics_app` schema.

The following pages give guidance that will help you set up your connection:
- [Connecting to a SQL warehouse from R Studio](https://dfe-analytical-services.github.io/analysts-guide/ADA/databricks_rstudio_sql_warehouse.html)
- [R Shiny app databricks connection guide](https://rsconnect/rsc/posit-connect-guidance/_book/databricks-connections.html).

If you don't have access to the source data, you can still run the dashboard using local test data instead.

You can use the following line to run the app with the same environment variable used in `shinytest2::test_app()`, and make all of the data functions switch to local instead of database:
```r
withr::with_envvar(c(TESTTHAT = "true"), shiny::runApp())
```

## Contributing to the dashboard

### Running locally

Package control is handled using [renv](https://rstudio.github.io/renv/articles/renv.html) at the top level of the repository.

1. Clone or download the repo
2. Open the R project in R Studio or your IDE of choice
3. Run `renv::restore()` to install dependencies
4. Run `install.packages("git2r")` to install the git2r package, ignored by renv to help deployments but necessary for the pre-commit hooks
5. Run `shiny::runApp()` to run the dashboard locally

It's also worth checking that you can run the automated tests using `shinytest2::test_app()`, so you can be confident you have everything set up correctly before you start developing.

### Naming conventions

Quick shorthands:

- `pub` = publication
- `gsc` = Google Search Console
- `meth` = methodology

Most of the app will have objects that start with `service_` or `pub_`, these refer to the page that the objects appear on based on the top navbar.

To help with the ever growing server file until we modularise the code, we've adopted the following naming conventions.

Imagine we had a SQL table called 'example'...

- `example_full` = Full table of date
- `example_by_date` = Filtered table based on user inputs (note that at pub level this is also filtered by pub)
- `example_plot` = Charts based on filtered data
- `example_table` = Tables based on filtered data
- `example_download` = Download links based on filtered data
- `example_box` = Value boxes based on filtered data

### Adding new data

All data is pulled from our unity catalog area under the `analytics_app` schema. Each table used in the app also has a 
local parquet file equivalent for use in automated tests and for development in case you can't access the main database.

If you want to see where to start, have a look at the [PR that added the accordion events](https://github.com/dfe-analytical-services/ees-analytics-dashboard/pull/4/)
as an example for the places in the code that you'll need to touch for new data, it's not exhaustive, and may go out of
date if the app changes, though should give a starting point.

If you're adding any new data into the dashboard, make sure to update the `tests/testdata-generator.R` script to add in 
any new tables, and then use that script to regenerate the test data.

Steps for adding new data:
- Add a call to read in the full table into server.R and cache it
- Create a filtered version based on the user inputs
- Create any value box / table / plot outputs from that filtered data and cache them
- Create a download output and add link to downloads page
- Add any appropriate technical notes
- Add the table name to the lists in the `tests/testdata-generator.R` script and regenerate test data
- Add new UI tests as appropriate

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