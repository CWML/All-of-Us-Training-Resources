# =============================================================================
# aou_setup.R: shared settings and helper functions for the example notebooks
#
# Every notebook starts with:  source("aou_setup.R")
# Keep this file in the same folder as the notebooks.
# =============================================================================

# ---- 1. EDIT THESE TWO SETTINGS ---------------------------------------------

# Your bucket's folder name: the name shown on the Resources tab. If the bucket
# is inside a folder on the Resources tab, include it: "my_folder/my-bucket".
# Not sure? Run 0.0 setup: it lists the folders it finds.
BUCKET_NAME <- "workspace-bucket"

# The All of Us dataset (CDR) to query: "<project-id>.<dataset-id>".
# Copy it from the FROM line of any Data Explorer query in your workspace.
# Controlled Tier CDR v9 is C2025Q4R6.
CURRENT_DATASET <- "wb-silky-artichoke-2408.C2025Q4R6"

# ---- 2. NOTHING BELOW NEEDS TO CHANGE ----------------------------------------

# Install any packages the notebooks need that aren't in this app yet.
# This only happens the first time (it can take a few minutes); after that it's skipped.
NEEDED_PACKAGES <- c("tidyverse", "lubridate", "bigrquery", "broom", "survival")
missing_packages <- NEEDED_PACKAGES[!vapply(NEEDED_PACKAGES, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "),
          " (first time only, this can take a few minutes)...")
  user_lib <- Sys.getenv("R_LIBS_USER")
  dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(user_lib, .libPaths()))
  repos <- getOption("repos")
  if (is.null(repos) || identical(unname(repos["CRAN"]), "@CRAN@")) repos <- "https://cloud.r-project.org"
  install.packages(missing_packages, lib = user_lib, repos = repos)
}

suppressPackageStartupMessages({
  library(tidyverse)  # dplyr, tidyr, readr, stringr, purrr, ggplot2
  library(lubridate)  # dates
  library(bigrquery)  # BigQuery
})

# Google Cloud project that pays for queries (set automatically in every app)
BILLING_PROJECT <- Sys.getenv("GOOGLE_CLOUD_PROJECT")

# Your bucket is mounted as a folder in the app. We keep our files in its data/ folder.
BUCKET_DIR <- file.path(Sys.getenv("HOME"), "workspace", BUCKET_NAME)
DATA_DIR   <- file.path(BUCKET_DIR, "data")

if (!dir.exists(BUCKET_DIR)) {
  found <- list.dirs(file.path(Sys.getenv("HOME"), "workspace"), recursive = FALSE)
  stop("Can't find your bucket folder: ", BUCKET_DIR,
       "\nFolders found in ~/workspace: ",
       if (length(found)) paste(basename(found), collapse = ", ") else "none",
       "\nUpdate BUCKET_NAME in aou_setup.R (or create a bucket on the Resources tab).",
       call. = FALSE)
}
dir.create(DATA_DIR, showWarnings = FALSE)

# Run a SQL query and return the result as a data frame
run_query <- function(sql) {
  tb <- bq_project_query(BILLING_PROJECT, sql)
  bq_table_download(tb)
}

# Save a data frame as CSV in your bucket's data/ folder
save_data <- function(df, file_name) {
  path <- file.path(DATA_DIR, file_name)
  write_csv(df, path)
  message("Saved ", file_name, " to ", DATA_DIR)
  invisible(path)
}

# Read a CSV from your bucket's data/ folder
load_data <- function(file_name) {
  read_csv(file.path(DATA_DIR, file_name), show_col_types = FALSE)
}

# ---- 3. ANALYSIS HELPERS (used by notebooks 3.1-3.3) -------------------------

# Read final_analysis.csv and set up variable types for modelling
prepare_analysis_data <- function() {
  load_data("final_analysis.csv") %>%
    mutate(
      gender    = factor(gender),
      race      = factor(race),
      ethnicity = factor(ethnicity),
      # rebuilt from age, so files saved with older age-group labels still work
      age_group = cut(age, breaks = c(25, 35, 45, 51), right = FALSE,
                      labels = c("25-34", "35-44", "45-50")),
      diabetes  = factor(diabetes, levels = c("No", "Yes"))   # the flagging variable
    )
}

message("Setup done. Dataset: ", CURRENT_DATASET, " | Data folder: ", DATA_DIR)
