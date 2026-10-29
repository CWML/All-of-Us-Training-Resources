R and Python notebooks for learning to analyse *All of Us* data in the Researcher Workbench 2.0, organised in **series**. **Each notebook does one thing**, so each can be taught as its own class.

**Written for beginners.** Each notebook has learning objectives, a plain-language primer on the key concepts, an explanation of every step and function, "Read the output" guides, exercises with hidden answers, common errors, and key takeaways. Notebook **0.0** includes a 5-minute introduction to Jupyter and R.

## Folder layout

```
notebooks/
├── 0.0 setup.ipynb        start here
├── aou_setup.R            settings you edit once + helper functions (R)
├── aou_setup.py           the same settings for Python notebooks (read from aou_setup.R)
├── sql/                   the shared type 2 diabetes cohort query
├── core/                  1.1 – 3.4: build a cohort, clean and join, analyse
├── omics/                 4.1 – 4.7: genomes, GWAS, PheWAS, RNA-seq, proteomics
└── archive/               earlier versions
```

Notebooks in a series folder load the shared files from the folder above (`source("../aou_setup.R")`), so **keep this layout**: cloning the repository does that for you.

## Core series (`core/`)

> **Being rewritten.** The core notebooks below are the current versions. They're being updated to the same type 2 diabetes cohort as the omics series (see `CURRICULUM_PLAN.md`), with 2.0 split into 2.1 clean, 2.2 reshape, and 2.3 join_and_bind.

| Notebook | What it does | Class |
|---|---|---|
| [`aou_setup.R`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/aou_setup.R) | Settings you edit once (bucket and dataset) and shared helper functions | |
| [`0.0 setup`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/0.0%20setup.ipynb) | Checks your settings and the connection to the data | Any |
| [`1.1 build_cohorts`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/1.1%20build_cohorts.ipynb) | Cohort Builder SQL (updated for 2.0): demographics, PTSD survey answers, and measurements, saved separately for the study and control groups | 1 |
| [`1.2 survival_data`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/1.2%20survival_data.ipynb) | Diabetes and CKD diagnoses, and visits | 1 or 5 |
| [`2.0 clean_and_join`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/2.0%20clean_and_join.ipynb) | Flags each group, stacks them, then cleans, reshapes, and joins everything into one analysis table | 2 |
| [`3.1 table_one`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.1%20table_one.ipynb) | Descriptive statistics, chi-square and t-tests, and a small-count check | 3 |
| [`3.2 logistic_regression`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.2%20logistic_regression.ipynb) | Univariable and multivariable models for the odds of diabetes | 4 |
| [`3.3 linear_regression`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.3%20linear_regression.ipynb) | Models for systolic blood pressure, compared by fit | 4 |
| [`3.4 survival_analysis`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.4%20survival_analysis.ipynb) | Kaplan–Meier curves and a Cox model with baseline predictors | 5 |

**Variables used:** age, gender, race, ethnicity; two PTSD survey questions (seeing a doctor, receiving treatment); BMI, systolic blood pressure, LDL cholesterol, and HbA1c; diabetes and CKD diagnoses; visit dates.

### How they fit together

```
aou_setup.R          settings + helpers, loaded by every notebook
     │
1.1 build_cohorts ──► person_study.csv       person_control.csv
                      survey_study.csv       survey_control.csv
                      measurement_study.csv  measurement_control.csv
1.2 survival_data ──► condition_arranged.csv, visit_arranged.csv
     │
2.0 clean_and_join ─► flag the groups (diabetes = Yes / No), stack them, clean, join
                      ──► final_analysis.csv, measurements_wide.csv
     │
3.1 table_one · 3.2 logistic · 3.3 linear · 3.4 survival
```

The queries in **1.1** and **1.2** run once and save their results to your bucket's `data/` folder. Every later notebook reads those files, so a class can start at any notebook once the data is saved.

## Omics series (`omics/`)

Each class starts with a short cohort section, so it works on its own (4.2 and 4.3 build on 4.1). One research question runs through the series: **type 2 diabetes** and the *TCF7L2* variant **rs7903146**. Every notebook opens with an "Analysis at a glance" box and a time and cost estimate (about **$1 to $2** per student per class on the default app).

| Notebook | Language | What it does |
|---|---|---|
| [`4.1 dna_intro`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/4.1%20dna_intro.ipynb) | R + PLINK | The genomic data, file formats, linking genomes to the cohort, genetic ancestry, and one famous variant |
| [`4.2 gwas_plink`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/4.2%20gwas_plink.ipynb) | R + PLINK | A regional GWAS: QC, logistic regression per variant, regional and Q-Q plots, why adjust |
| [`4.3 gwas_hail`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/4.3%20gwas_hail.ipynb) | Python + Hail | The same GWAS in Hail, compared with PLINK |
| [`4.4 phewas`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/4.4%20phewas.ipynb) | R | The All by All browser, then a PheWAS of rs7903146 in a random sample; selection and collider bias |
| [`4.5 rnaseq`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/4.5%20rnaseq.ipynb) | R (edgeR, limma) | Normalization, differential expression in blood, an eQTL check of *TCF7L2* |
| [`4.6 proteomics`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/4.6%20proteomics.ipynb) | R (limma) | Olink proteins: QC, batch checks, differential abundance, pQTLs |
| [`4.7 rnaseq_proteomics`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/4.7%20rnaseq_proteomics.ipynb) | R | RNA and protein in the same people, and a summary of the series |

**Before the omics classes:** run **0.0 setup** once. Don't `pip install` packages into the shared app without checking what they replace: installing PheTK, for example, downgraded a package Hail needs.

## Getting started

You need an *All of Us* workspace with the **Controlled Tier** data collection and a **bucket** (Resources tab → **+ New resource** → Cloud Storage bucket).

1. **Get the notebooks** into your workspace, either way:
   - **Clone this repository:** in your workspace, go to **Apps** → **Git repositories** → **+ Add repository** and enter `https://github.com/CWML/All-of-Us-Training-Resources.git`. It's cloned into apps you create afterward.
   - **Download and upload:** download the whole `notebooks/` folder and upload it to your app **with its subfolders**, so `aou_setup.R` and `sql/` stay one level above the series folders.
2. **Launch an app**, e.g. AoU Jupyter (it has R and Python kernels).
3. Open **`0.0 setup`** and follow it. It has you edit two lines in `aou_setup.R`:
   - `BUCKET_NAME`: your bucket's folder name
   - `CURRENT_DATASET`: the dataset, copied from the `FROM` line of any Data Explorer query (Controlled Tier CDR v9 is `C2025Q4R6`)
4. Run a series in order: core `1.1` → `1.2` → `2.0` → `3.1` to `3.4`; or omics `4.1` → `4.7`.

**R packages:** `tidyverse`, `lubridate`, `bigrquery`, `broom`, `survival`. `aou_setup.R` installs any that are missing the first time it runs (this can take a few minutes).

## The study population

Both groups come from the SQL in notebook **1.1**, generated by the classic Workbench's Cohort Builder and updated for Workbench 2.0 (every table is written as `` `{CURRENT_DATASET}.table` ``):

- Age **25 to 50**, and **alive**
- Race: **White**, **Black or African American**, or **Asian**
- Ethnicity: **Hispanic or Latino** or **Not Hispanic or Latino**
- Gender: **Man** or **Woman**
- **Study group:** has a diagnosis of **diabetes mellitus** (any type). **Control group:** doesn't.

## Build the cohorts in Data Explorer

Prefer point-and-click? You can build the same two groups in **Data Explorer** instead of running the SQL in notebook 1.1. You'll make **two cohorts** (study and control) and save a **data snapshot** of each.

### 1. Add a cohort

**Resources** tab → **+ New resource** → **Cohort**:

1. **Select collection:** All of Us Controlled Tier, version **cdrv9** → **Next**
2. **No new policies** → **Next**
3. **Cohort name:** `diabetes_study` (and later `diabetes_control`) → **Add to your workspace**

### 2. Add the criteria

In the cohort view, use **Add criteria** to build these groups. Within a group, choose **Meet all criteria**. Groups combine with **AND**.

| Group | Included / Excluded | Criteria (Add criteria → …) |
|---|---|---|
| 1. Demographics | Included, **meet all** | Demographics → **Current Age**: 25 to 50 · **Race**: White, Black or African American, Asian · **Ethnicity**: Hispanic or Latino, Not Hispanic or Latino · **Gender identity**: Man, Woman |
| 2. Diabetes | **Study cohort: Included** / **Control cohort: Excluded** | Domains → **Condition** → 🔍 search *diabetes mellitus* → select **Diabetes mellitus** |
| 3. Alive | **Excluded** | Demographics → **Deceased** |

Click **Apply**. The participant count updates.

### 3. Save a data snapshot

**Save data snapshot** (top right), then:

1. **Select data:**
   - **Demographics**
   - **+ Browse more data** → **Surveys** → the two PTSD questions: *"Are you still seeing a doctor or health care provider for post-traumatic stress disorder (PTSD)?"* and *"Are you currently prescribed medications and/or receiving treatment for post-traumatic stress disorder (PTSD)?"*
   - **+ Browse more data** → **Labs and Measurements** → **BMI**, **systolic blood pressure**, **LDL cholesterol**, **HbA1c**
2. **File format:** *Queries for the cohort (IPYNB) with R Notebook*
3. **Destination bucket:** your bucket → **Save**

Repeat steps 1 to 3 for the **control** cohort (group 2 set to **Excluded**).

### 4. Use the exports with these notebooks

Run each exported notebook once: it saves CSV files to your bucket under `bq_exports/`. Then follow **"Optional: use a Data Explorer export instead"** at the end of notebook **1.1**: it renames the columns and saves each cohort with the same file names as the SQL version (`person_study.csv`, `person_control.csv`…), so notebooks 2.0 to 3.4 work unchanged.

> **To confirm in the Workbench:** where the PTSD questions and the four measurements appear under **+ Browse more data**, and that **Deceased** can be used as an exclusion. Menus may differ slightly.
>
> **Counts won't exactly match the SQL version.** Data Explorer and the Cohort Builder SQL in notebook 1.1 calculate age and match diagnosis codes in slightly different ways. Both are fine for learning; just use one method consistently.

## Already have data from the earlier notebooks?

If you ran the earlier (classic Workbench) versions of these notebooks, your saved CSV files **work as they are**: they use the same file names (`person_study.csv`, `survey_control.csv`, `condition_arranged.csv`…). Set `BUCKET_NAME` in `aou_setup.R` to the bucket that holds them (in a migrated workspace, the one named like `rw-migration-aou-rw-…`), run **0.0**, then **skip 1.1 and 1.2** and start at **2.0**.

Those files come from the older dataset (CDR v8), so results won't match a fresh CDR v9 run. **Don't combine them with CDR v9 data:** participant IDs changed between v8 and v9, so v8 files can't be joined to v9 tables or files. The earlier notebooks themselves are in [`archive/`](https://github.com/CWML/All-of-Us-Training-Resources/tree/main/notebooks/archive). The current core notebooks are in `core/`.

## Data use

This repository contains **code only, no *All of Us* data**.

- Don't download, screenshot, or share **participant-level data**
- Don't share counts of **1 to 20**, or numbers they could be calculated from (notebook 3.1 checks for these)
- **Clear notebook outputs** before you share or commit a notebook
