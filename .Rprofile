shhh <- suppressPackageStartupMessages # It's a library, so shhh!

source("renv/activate.R")

# Install commit-hooks locally
statusWriteCommit <- file.copy(".hooks/pre-commit.R", ".git/hooks/pre-commit", overwrite = TRUE)
