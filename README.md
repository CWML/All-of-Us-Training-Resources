# All of Us Training Resources

Training materials from the Yale Cushing/Whitney Medical Library (CWML) for researchers and students working with the [NIH *All of Us* Research Program](https://www.researchallofus.org/) data on the **Researcher Workbench 2.0** (powered by Verily).

The repository has two parts:

1. **An introductory presentation** walking through the Workbench 2.0, from logging in to running an analysis app.
2. **Example R notebooks** that build a cohort, extract data, and run common clinical research analyses.

## Contents

```
Intro to workbench 2.0/   Reveal.js presentation: introduction to the Workbench 2.0
notebooks/                R notebooks: example diabetes/CKD analysis workflow
```

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
| `00. load_environment_variables` | Sets up the environment and loads datasets from the workspace bucket |
| `01. diabetes_control_cohort` | Extracts demographic, survey, and measurement data for the control cohort (no diabetes) |
| `01.5 diabetes_ckd_surv_cohort` | Extracts condition and visit data for CKD survival analysis |
| `02. diabetes_study_cohort` | Extracts demographic, survey, and measurement data for the study cohort (diabetes) |
| `03. clean_join_cohorts_survey_measurements` | Imports, cleans, and joins the cohort datasets |
| `04. Statistical_data_analysis_for_clinical_research` | Table One (chi-square, t-tests), logistic and linear regression, and survival analysis (hazard ratios, Kaplan–Meier) |

**Variables used:** age, ethnicity, race, and other demographics; survey questions on current doctor visits and prescriptions; BMI, LDL cholesterol, systolic blood pressure, and A1C; diabetes and CKD diagnoses; visit dates.

### Running the notebooks

The notebooks only run **inside an *All of Us* workspace**. They query the *All of Us* data with BigQuery and read and write files in the workspace bucket.

1. Create a workspace on the [Researcher Workbench](https://workbench.verily.com/) and add an *All of Us* data collection.
2. Build your cohorts and datasets with Data Explorer.
3. Launch an R analysis app (e.g., JupyterLab with an R kernel) and upload the notebooks.
4. Run the notebooks in order, `00` → `04`.

The SQL queries in notebooks `01`–`02` were generated from specific cohort and dataset definitions. If you build your own cohorts, replace them with the queries Data Explorer generates for you.

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
