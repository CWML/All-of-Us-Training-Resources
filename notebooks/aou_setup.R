# =============================================================================
# aou_setup.R: shared settings and helper functions for the example notebooks
#
# Notebooks in the series folders (core/, omics/, ...) start with:
#   source("../aou_setup.R")
# and 0.0 setup, next to this file, with source("aou_setup.R").
# Keep this file in notebooks/, with sql/ and the series folders.
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

# Read a CSV from your bucket's data/ folder. Extra options go to read_csv(),
# e.g. load_data("gwas_samples.csv", col_types = cols(person_id = "c"))
load_data <- function(file_name, ...) {
  read_csv(file.path(DATA_DIR, file_name), show_col_types = FALSE, ...)
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

# ---- 4. HELPERS FOR THE OMICS NOTEBOOKS (notebooks/omics/) -------------------

# The All of Us genomic and multi-omics files are mounted as a folder in
# ~/workspace/. Its name depends on the workspace (e.g. vwb-aou-datasets-controlled-v8r9),
# so this finds it and returns the folder for one data version (e.g. .../v9).
aou_data_dir <- function(version = "v9") {
  mounts <- list.files(file.path(Sys.getenv("HOME"), "workspace"),
                       pattern = "^vwb-aou-datasets-controlled", full.names = TRUE)
  found <- file.path(mounts, version)
  found <- found[dir.exists(found)]
  if (length(found) == 0) {
    stop("Can't find the All of Us ", version, " data folder in ~/workspace/. ",
         "Check that the Controlled Tier data collection is added to this workspace.",
         call. = FALSE)
  }
  found[1]
}

# All of Us policy: never share counts of 1 to 20. This blanks them out (shows NA)
# in a table with a count column called n, e.g. df %>% count(x) %>% hide_small_counts()
hide_small_counts <- function(df) {
  mutate(df, n = if_else(n <= 20, NA_integer_, as.integer(n)))
}

# Everyone in sql/t2d_cohort.sql (cases, controls, and excluded) who can be used in a
# genetic analysis: the same steps as 4.1 Parts 3 and 4. They have a short-read genome,
# aren't on the relatedness list, are 18 to 100, and have sex at birth Female or Male;
# genetic ancestry and PCs are added. Runs the cohort query (cents to under $1).
genomic_people <- function(sql_file = "../sql/t2d_cohort.sql") {
  snpindel <- file.path(aou_data_dir("v9"), "wgs", "short_read", "snpindel")

  cohort <- run_query(str_glue(read_file(sql_file), AGE_DATE = "2025-01-01")) %>%
    mutate(person_id = as.character(person_id))
  genome_ids <- read_tsv(file.path(snpindel, "acaf_threshold", "pgen", "acaf_threshold.chr10.psam"),
                         col_types = cols(.default = "c"))[["#IID"]]
  related <- read_tsv(file.path(snpindel, "aux", "relatedness", "relatedness_flagged_samples.tsv"),
                      col_types = cols(.default = "c"))$sample_id
  ancestry <- read_tsv(file.path(snpindel, "aux", "ancestry", "ancestry_preds.tsv"),
                       col_types = cols(.default = "c"))

  n_pcs <- str_count(ancestry$pca_features[1], ",") + 1
  pcs <- ancestry %>%
    transmute(person_id = research_id,
              ancestry  = ancestry_pred,
              pca_features = str_remove_all(pca_features, "\\[|\\]")) %>%
    separate_wider_delim(pca_features, delim = ",", names = paste0("PC", 1:n_pcs)) %>%
    mutate(across(starts_with("PC"), as.numeric))

  cohort %>%
    filter(person_id %in% genome_ids,
           !person_id %in% related,
           between(age, 18, 100),
           sex_at_birth %in% c("Female", "Male")) %>%
    mutate(has_genome = TRUE) %>%
    arrange(person_id) %>%
    left_join(pcs, by = "person_id")
}

# The genomic sample for the GWAS notebooks (4.1 to 4.3): a random sample of
# n_per_group cases and n_per_group controls from genomic_people().
# The same seed gives the same people as 4.1.
t2d_gwas_samples <- function(n_per_group = 2500, seed = 2026,
                             sql_file = "../sql/t2d_cohort.sql") {
  people <- genomic_people(sql_file) %>% filter(cohort %in% c("case", "control"))
  set.seed(seed)
  people %>%
    group_by(cohort) %>%
    slice_sample(n = n_per_group) %>%
    ungroup()
}

message("Setup done. Dataset: ", CURRENT_DATASET, " | Data folder: ", DATA_DIR)
