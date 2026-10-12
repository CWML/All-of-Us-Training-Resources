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

Short R notebooks that walk through a complete study comparing people **with** and **without diabetes**, including time to chronic kidney disease (CKD). Each notebook does one thing, so each can be taught as its own short class.

| Notebook | What it does | Class |
|---|---|---|
| `aou_setup.R` | Settings you edit once (bucket and dataset) and shared helper functions | |
| `0.0 setup` | Checks your settings and the connection to the data | Any |
| `0.1 use_saved_data` | *Optional:* converts files saved by the earlier notebooks, so you can skip 1.1 and 1.2 | |
| `1.1 build_cohorts` | Cohort Builder SQL (updated for 2.0) for the study population: demographics, PTSD survey answers, and measurements. Also shows how to use a Data Explorer export instead. | 1 |
| `1.2 survival_data` | Diabetes and CKD diagnosis dates, and last visits | 1 or 5 |
| `2.0 clean_and_join` | Cleans, reshapes, and joins the data into one analysis table | 2 |
| `3.1 table_one` | Descriptive statistics, chi-square and t-tests, and a small-count check | 3 |
| `3.2 logistic_regression` | Univariable and multivariable models for the odds of diabetes | 4 |
| `3.3 linear_regression` | Models for systolic blood pressure, compared by fit | 4 |
| `3.4 survival_analysis` | Kaplan–Meier curves and a Cox model with baseline predictors | 5 |

**Variables used:** age, gender, race, ethnicity; two PTSD survey questions (seeing a doctor, receiving treatment); BMI, systolic blood pressure, LDL cholesterol, and HbA1c; diabetes and CKD diagnoses; visit dates.

**Full instructions**, including how to build the same cohorts in **Data Explorer**, are in [`notebooks/README.md`](notebooks/README.md).

The earlier versions of the notebooks (classic Workbench) are in `notebooks/archive/`.

### Running the notebooks

The notebooks only run **inside an *All of Us* workspace** (Workbench 2.0). They query the *All of Us* data with BigQuery and save files in your bucket.

1. Create a workspace on the [Researcher Workbench](https://workbench.verily.com/), add the *All of Us* Controlled Tier data collection, and create a **bucket** on the Resources tab.
2. Get the notebooks into your workspace, either way:
   - **Clone this repository:** in your workspace, go to **Apps** → **Git repositories** → **+ Add repository** and enter `https://github.com/CWML/All-of-Us-Training-Resources.git`. It's cloned into apps you create afterward.
   - **Download and upload:** download the `notebooks/` files from GitHub, **including `aou_setup.R`**, and upload them to one folder in your app.
3. Launch an R app (e.g., AoU Jupyter with an R kernel).
4. Open **`0.0 setup`** and follow it: it has you edit two lines in `aou_setup.R`.
5. Run the notebooks in order: `1.1` → `1.2` → `2.0` → `3.1` to `3.4`. The queries in `1.1` and `1.2` only need to run once; later notebooks read the saved files.

**R packages:** `tidyverse`, `lubridate`, `bigrquery`, `broom`, `survival`, `survminer`

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
