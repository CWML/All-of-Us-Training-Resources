# Instructions for AI assistants

This repository holds **training materials** for the *All of Us* Researcher Workbench 2.0 (Verily): R and Python notebooks in `notebooks/`, and a Quarto website in `pages/` (built into `docs/`). See [Coding with AI and GitHub](pages/extras/ai-coding.qmd) for how we work with AI assistants.

## The one rule: you never see the data

- *All of Us* data stays in the Workbench. **Don't ask for data, query results, or notebook outputs**, and never write code that prints participant IDs, dates, or individual rows: show only summaries.
- Code here is written on a computer **without** *All of Us* data, pushed to GitHub, and run in the Workbench.
- Test new code on a **small made-up data frame** with the same column names.

## The data and the code

- Controlled Tier **CDR v9** in BigQuery: `wb-silky-artichoke-2408.C2025Q4R6`, in the **OMOP** Common Data Model. SQL is BigQuery Standard SQL.
- Apple HealthKit is a separate dataset: `wb-silky-artichoke-2408.C_V9_R6_offcycle_healthkit` (long format; `value` is text).
- R uses the tidyverse and bigrquery. **Settings and helpers are in `notebooks/aou_setup.R`**: `run_query()`, `save_data()`, `load_data()`, `hide_small_counts()`, `load_cohort_sample()`, `run_if_cheap()`, `last_query_cost()`, `aou_data_dir()`. Use them; don't rewrite them.
- Every series uses the shared cohort query `notebooks/sql/t2d_cohort.sql` (type 2 diabetes cases vs controls).
- `WORKSPACE_CDR` and `WORKSPACE_BUCKET` are **not** set in Workbench 2.0.
- Notebooks live in series folders (`core/`, `omics/`, `surveys/`, `wearables/`) and load `../aou_setup.R`.

## Check, don't guess

- **Never invent concept IDs, table names, or column names.** Check the public documents in `reference/` (see `reference/README.md`) or ask. Say when you're unsure.
- BigQuery charges by data read: select only the columns needed, price queries with `run_if_cheap()`, and warn about any query on a large table (the Fitbit minute-level tables are over 6 TB).

## Before anything is shared

- **No counts of 1 to 20**, and none that can be worked out from other numbers (derived counts): use `hide_small_counts()`, and combine small groups.
- No single-person values: maxima, minima, box-plot whiskers or outliers, plots of one person's data.
- Notebooks are committed with **outputs cleared**. The pre-commit check (`tools/check_notebooks.py`) and the GitHub check enforce it.

## Writing style

Plain language for beginners: explain **why** before **how**; short sentences; tables for comparisons; a "Read the output" note after each result.
