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

# ---- 3. THE STUDY POPULATION (used by notebooks 1.1 and 1.2) ----------------
#
# Adults aged 25-50 who are alive; race White, Black, or Asian; ethnicity
# Hispanic or not Hispanic; gender Man or Woman. Each person is flagged
# diabetes = "Yes" (any diabetes mellitus diagnosis) or "No".

cohort_sql <- function() {
  str_glue("
WITH diabetes_people AS (
  -- everyone with a diagnosis of diabetes mellitus (concept 201820) or any more specific type
  SELECT DISTINCT person_id
  FROM `{CURRENT_DATASET}.condition_occurrence`
  WHERE condition_concept_id IN (
    SELECT descendant_concept_id
    FROM `{CURRENT_DATASET}.concept_ancestor`
    WHERE ancestor_concept_id = 201820
  )
),
cohort AS (
  SELECT
    p.person_id,
    IF(d.person_id IS NOT NULL, 'Yes', 'No') AS diabetes
  FROM `{CURRENT_DATASET}.person` p
  LEFT JOIN diabetes_people d ON p.person_id = d.person_id
  WHERE FLOOR(DATE_DIFF(CURRENT_DATE(), DATE(p.birth_datetime), DAY) / 365.25) BETWEEN 25 AND 50
    AND p.race_concept_id      IN (8527, 8516, 8515)        -- White, Black, Asian
    AND p.ethnicity_concept_id IN (38003563, 38003564)      -- Hispanic, not Hispanic
    AND p.gender_concept_id    IN (45878463, 45880669)      -- Woman, Man
    AND NOT EXISTS (                                        -- alive
      SELECT 1 FROM `{CURRENT_DATASET}.death` dd WHERE dd.person_id = p.person_id
    )
)")
}

# ---- 4. ANALYSIS HELPERS (used by notebooks 3.1-3.3) -------------------------

# Read final_analysis.csv and set up variable types for modelling
prepare_analysis_data <- function() {
  load_data("final_analysis.csv") %>%
    mutate(
      gender    = factor(gender),
      race      = factor(race),
      ethnicity = factor(ethnicity),
      age_group = factor(age_group, levels = c("25-34", "35-44", "45-50")),
      diabetes  = factor(diabetes, levels = c("No", "Yes")),
      diabetes_binary       = if_else(diabetes == "Yes", 1L, 0L),
      ptsd_doctor_binary    = if_else(ptsd_doctor == "Yes", 1L, 0L),
      ptsd_treatment_binary = if_else(ptsd_treatment == "Yes", 1L, 0L)
    )
}

message("Setup done. Dataset: ", CURRENT_DATASET, " | Data folder: ", DATA_DIR)
