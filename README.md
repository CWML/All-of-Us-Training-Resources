# All of Us Training Resources

Training materials from the Yale Cushing/Whitney Medical Library (CWML) for researchers and students working with the [NIH *All of Us* Research Program](https://www.researchallofus.org/) data on the **Researcher Workbench 2.0** (powered by Verily).

The repository has three parts:

1. **A website** with the full training as reference pages: <https://cwml.github.io/All-of-Us-Training-Resources/>
2. **An introductory presentation** walking through the Workbench 2.0, from logging in to running an analysis app.
3. **Example R notebooks** that build a cohort, extract data, and run common clinical research analyses.

## Contents

```
index.qmd, pages/         Website pages (Quarto)
_quarto.yml, styles.css   Website settings and styles
docs/                     The built website (published with GitHub Pages)
Intro to workbench 2.0/   Reveal.js presentation: introduction to the Workbench 2.0
notebooks/                R notebooks: example diabetes/CKD analysis workflow
tools/                    Scripts to build website pages from the slides
```

## Website

The website has the same content as the presentation, split into pages, with speaker notes shown as "Instructor tip" boxes. It has a light/dark mode switch and search.

### Editing the website

Edit the `.qmd` files in `pages/` (or `index.qmd`) and rebuild from the repository folder:

```bash
quarto render
```

This writes the site to `docs/`. Commit `docs/` along with your changes; GitHub Pages publishes it.

### Updating pages from the slides

Most pages are generated from `Intro to workbench 2.0/Introduction.qmd`. After changing the slides, regenerate them with:

```bash
python3 tools/deck2site.py "Intro to workbench 2.0/Introduction.qmd" .
python3 tools/site_fixups.py .
quarto render
```

⚠️ This **overwrites** the generated pages, so make lasting edits in the slides (or in `tools/site_fixups.py`), not in those pages. Pages kept by hand and not overwritten: `index.qmd`, `pages/get-started/billing.qmd`, `pages/workspace/apps.qmd`, `pages/extras/github-guide.qmd`, and `pages/examples/notebooks.qmd`.

`tools/redact.py` paints over parts of a screenshot (e.g., names or emails) before it's committed.

## Presentation: Introduction to the Workbench 2.0

A slide deck (built with [Quarto](https://quarto.org/) and reveal.js) covering:

- The *All of Us* Research Program and its data sources
- What changed from the classic Workbench to Workbench 2.0
- Logging in and getting around the Workbench
- Data collections and the Data Exchange
- Billing: initial credits, pods, and setting up a billing account at Yale
- Creating a workspace and adding a data collection, including the Research Use Statement questions
- Building cohorts and datasets with Data Explorer
- Launching apps (JupyterLab, RStudio, SAS) and estimating costs

### Viewing the slides

GitHub shows HTML files as source code, so download the folder to view the slides:

1. Download or clone this repository.
2. Open `Intro to workbench 2.0/Introduction.html` in a web browser (Chrome recommended).

Keep the `images/` and `Introduction_files/` folders next to the HTML file, or the slides won't display correctly.

**Presenting:** use the arrow keys to move between slides, **F** for full screen, **S** for speaker notes, and **Esc** for an overview of all slides.

### Editing the slides

Edit `Introduction.qmd` and re-render with Quarto:

```bash
quarto render "Intro to workbench 2.0/Introduction.qmd"
```

Styling is in `custom.scss`.

## Notebooks: Example Analysis Workflow

The notebooks walk through a complete study comparing a **diabetes (study) cohort** with a **non-diabetes (control) cohort**, including chronic kidney disease (CKD) outcomes. Run them in order:

| Notebook | What it does |
|---|---|
| `0.0 load_environment_variables` | Sets up the environment and loads datasets from the workspace bucket |
| `1.1 diabetes_control_cohort` | Extracts demographic, survey, and measurement data for the control cohort (no diabetes) |
| `1.2 diabetes_ckd_surv_cohort` | Extracts condition and visit data for CKD survival analysis |
| `1.3 diabetes_study_cohort` | Extracts demographic, survey, and measurement data for the study cohort (diabetes) |
| `2.0 clean_join_cohorts_survey_measurements` | Imports, cleans, and joins the cohort datasets |
| `3.0 Statistical_data_analysis_for_clinical_research` | Table One (chi-square, t-tests), logistic and linear regression, and survival analysis (hazard ratios, Kaplan–Meier) |

**Variables used:** age, ethnicity, race, and other demographics; survey questions on current doctor visits and prescriptions; BMI, LDL cholesterol, systolic blood pressure, and A1C; diabetes and CKD diagnoses; visit dates.

### Running the notebooks

The notebooks only run **inside an *All of Us* workspace**. They query the *All of Us* data with BigQuery and read and write files in the workspace bucket.

1. Create a workspace on the [Researcher Workbench](https://workbench.verily.com/) and add an *All of Us* data collection.
2. Build your cohorts and datasets with Data Explorer.
3. Get the notebooks into your workspace, either way:
   - **Clone this repository:** in your workspace, go to **Apps** → **Git repositories** → **+ Add repository** and enter `https://github.com/CWML/All-of-Us-Training-Resources.git`. It's cloned into apps you create afterward.
   - **Download and upload:** download the `.ipynb` files from GitHub and upload them to your app.
4. Launch an R analysis app (e.g., AoU Jupyter with an R kernel).
5. Run the notebooks in order: `0.0` → `1.1`–`1.3` → `2.0` → `3.0`.

> **Note:** Notebooks `1.1`–`1.3` still use SQL queries from the classic Researcher Workbench (1.0), generated for Controlled Tier Dataset v8. They won't run as-is in Workbench 2.0. Build your cohorts with Data Explorer and replace these queries with the ones it generates for you. Updated versions are planned.

**R packages:** `tidyverse`, `bigrquery`, `dplyr`, `lubridate`, `stringr`, `tidyr`, `purrr`, `broom`, `survival`, `survminer`

## Data Use

This repository contains **code only, no *All of Us* data**. If you use these materials:

- Follow the *All of Us* [Data User Code of Conduct](https://www.researchallofus.org/faq/data-user-code-of-conduct/).
- Don't download, screenshot, or share participant-level data from the Workbench.
- Follow the [Data and Statistics Dissemination Policy](https://www.researchallofus.org/faq/data-and-statistics-dissemination-policy/): don't publish participant counts of 1 to 20, or numbers they could be calculated from.
- **Clear notebook outputs before committing** to this repository, so no results are accidentally made public.

## Resources

- [*All of Us* Research Hub](https://www.researchallofus.org/)
- [*All of Us* User Support Hub](https://support.researchallofus.org/)
- [Researcher Workbench Getting Started Guide](https://support.researchallofus.org/hc/en-us/articles/41981050556564-Researcher-Workbench-Getting-Started-Guide)
- [Verily Workbench documentation](https://support.workbench.verily.com/docs/)

## Contact

Maximilian Wegener, MPH
Biomedical Informatics Librarian, Cushing/Whitney Medical Library, Yale School of Medicine
