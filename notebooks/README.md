R and Python notebooks for learning to analyse *All of Us* data in the Researcher Workbench 2.0, organised in **series**. **Each notebook does one thing**, so each can be taught as its own class.

**Written for beginners.** Each notebook has learning objectives, a plain-language primer on the key concepts, an explanation of every step and function, "Read the output" guides, exercises with hidden answers, common errors, and key takeaways. Notebook **0.0** includes a 5-minute introduction to Jupyter and R.

## Folder layout

```
notebooks/
├── 0.0 setup.ipynb        start here
├── aou_setup.R            settings you edit once + helper functions (R)
├── aou_setup.py           the same settings for Python notebooks (read from aou_setup.R)
├── sql/                   the shared type 2 diabetes cohort query
├── core/                  1.1 – 3.4: build a cohort; clean, reshape, join; analyse
├── omics/                 4.1 – 4.7: genomes, GWAS, PheWAS, RNA-seq, proteomics
├── surveys/               5.1 – 5.3 (coming soon)
├── wearables/             6.1 – 6.3 (coming soon)
└── archive/               earlier versions
```

Notebooks in a series folder load the shared files from the folder above (`source("../aou_setup.R")`), so **keep this layout**: cloning the repository does that for you.

## Core series (`core/`)

Nine R notebooks that take one study from start to finish: people **with type 2 diabetes** (cases) compared with people **without diabetes** (controls), including **time to chronic kidney disease** (CKD) after diagnosis. They use the same cohort query as every other series (`sql/t2d_cohort.sql`) and a sample of 5,000 cases and 5,000 controls. Every notebook opens with an "Analysis at a glance" box and a time and cost estimate.

| Notebook | What it does | Time |
|---|---|---|
| [`aou_setup.R`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/aou_setup.R) | Settings you edit once (bucket and dataset) and shared helper functions | |
| [`0.0 setup`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/0.0%20setup.ipynb) | Checks your settings and the connection to the data | |
| [`1.1 build_cohorts`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/1.1%20build_cohorts.ipynb) | The OMOP tables, concept IDs, and SQL; the cohort query; a sample; survey answers and measurements | 90 min |
| [`1.2 survival_data`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/1.2%20survival_data.ipynb) | Time zero, event, and censoring; first CKD dates; follow-up | 60 min |
| [`2.1 clean`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/2.1%20clean.ipynb) | Types, non-answers, messy text, duplicates, units, plausible ranges, missing data, a cleaning log | 105 min |
| [`2.2 reshape`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/2.2%20reshape.ipynb) | Long vs wide; one value per person; `pivot_wider()` and `pivot_longer()` | 70 min |
| [`2.3 join_and_bind`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/2.3%20join_and_bind.ipynb) | `bind_rows()`; left, inner, full, and anti joins; checks after every join; the analysis table | 75 min |
| [`3.1 table_one`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.1%20table_one.ipynb) | A Table 1 with your own functions; missing data; the small-count check | 75 min |
| [`3.2 logistic_regression`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.2%20logistic_regression.ipynb) | Odds ratios for type 2 diabetes; adjustment; reverse causation | 85 min |
| [`3.3 linear_regression`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.3%20linear_regression.ipynb) | Systolic blood pressure; model comparison; residuals | 75 min |
| [`3.4 survival_analysis`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/core/3.4%20survival_analysis.ipynb) | Kaplan–Meier curves (ggplot2), log-rank test, Cox model, proportional hazards | 90 min |

**Variables used:** age, sex at birth, gender, race, ethnicity; two PTSD survey questions (asked only of people who reported PTSD); BMI, systolic blood pressure, LDL cholesterol, and HbA1c; type 2 diabetes and CKD dates; EHR and death dates.

### How they fit together

```
sql/t2d_cohort.sql
     │
1.1 build_cohorts ──► cohort_sample.csv, survey_raw.csv, measurement_raw.csv
1.2 survival_data ──► ckd_dates.csv
     │
2.1 clean ─────────► cohort_clean.csv, survey_clean.csv, measurement_clean.csv
2.2 reshape ───────► survey_wide.csv, measurements_wide.csv
2.3 join_and_bind ─► final_analysis.csv
     │
3.1 table_one · 3.2 logistic · 3.3 linear · 3.4 survival
```

Only **1.1** and **1.2** query BigQuery (about $2 to $3 in total); every later notebook reads the saved files, so a class can start at any notebook once the data is saved.

## Omics series (`omics/`)

Each class starts with a short cohort section, so it works on its own (4.2 and 4.3 build on 4.1). Details, costs, and setup notes: [`omics/README.md`](https://github.com/CWML/All-of-Us-Training-Resources/blob/main/notebooks/omics/README.md). One research question runs through the series: **type 2 diabetes** and the *TCF7L2* variant **rs7903146**. Every notebook opens with an "Analysis at a glance" box and a time and cost estimate (about **$1 to $2** per student per class on the default app).

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
   - `CURRENT_DATASET`: the dataset. It's already set to Controlled Tier CDR v9 (`wb-silky-artichoke-2408.C2025Q4R6`). **Don't** copy it from a Data Explorer query: the Data Explorer currently uses CDR v8 (`C2024Q3R9`)
4. Run a series in order: core `1.1` → `1.2` → `2.1` → `2.2` → `2.3` → `3.1` to `3.4`; or omics `4.1` → `4.7`.

**R packages:** `tidyverse`, `lubridate`, `bigrquery`, `broom`, `survival`. `aou_setup.R` installs any that are missing the first time it runs (this can take a few minutes).

## The study population

Every series uses the cohort in `sql/t2d_cohort.sql`:

- Adults (**18+** on 2025-01-01, the CDR v9 data cutoff, or at death) with at least one **EHR** visit
- **Cases:** a type 2 diabetes diagnosis (concept 201826 or anything under it), and no type 1 diabetes diagnosis
- **Controls:** no diabetes diagnosis of any type (concept 201820 or anything under it)
- Race and ethnicity are **described**, not used to choose people

The core series takes a random sample of 5,000 cases and 5,000 controls (ages 18 to 100); the omics classes take their own samples among people with each data type.

## Point and click: Data Explorer

The **Data Explorer**, Workbench 2.0's point-and-click tool, can build a similar cohort without SQL. Two cautions: it currently uses **CDR v8** (`C2024Q3R9`), while these notebooks use **CDR v9**, and participant IDs changed between v8 and v9, so **Data Explorer exports can't be combined with the notebooks' files**. Its rules also differ a little (e.g. age today instead of on 2025-01-01), so its counts won't match. Step-by-step instructions for this cohort are being updated.

## Files from earlier versions of these notebooks

Files saved by earlier versions (`person_study.csv`, `final_analysis.csv` with diabetes of any type, …) **don't work** with the current notebooks: the cohort, file names, and columns have changed. Files saved from CDR v8 also can't be combined with CDR v9 data, because participant IDs changed between v8 and v9. The earlier notebooks are in [`archive/`](https://github.com/CWML/All-of-Us-Training-Resources/tree/main/notebooks/archive) and in the repository's history.

## Data use

This repository contains **code only, no *All of Us* data**.

- Don't download, screenshot, or share **participant-level data**
- Don't share counts of **1 to 20**, or numbers they could be calculated from (notebook 3.1 checks for these)
- **Clear notebook outputs** before you share or commit a notebook
