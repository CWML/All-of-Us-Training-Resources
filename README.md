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

The **"Previous section / Next section"** buttons at the bottom of each section's first and last page are added by `tools/site_fixups.py` (see `SECTIONS` there). If you add, remove, or reorder sections in `_quarto.yml`, update that list too and rerun the commands above.

`tools/redact.py` paints over parts of a screenshot (e.g., names or emails) before it's committed.

## Presentation: Introduction to the Workbench 2.0

A slide deck (built with [Quarto](https://quarto.org/) and reveal.js) covering:

- The *All of Us* Research Program and its data sources
- What changed from the classic Workbench to Workbench 2.0
- Logging in and getting around the Workbench
- Data collections and the Data Exchange
- Billing: initial credits, pods, and setting up a Google Cloud billing account at Yale
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

## Notebooks

R and Python notebooks in **series**, in `notebooks/`: each notebook does one thing, so each can be taught as its own class.

- **`notebooks/core/`** (1.1–3.4): one study from start to finish, people **with type 2 diabetes** vs **without diabetes**, including time to chronic kidney disease (CKD): build the cohort with SQL; clean, reshape, and join; Table 1, logistic and linear regression, survival analysis.
- **`notebooks/omics/`** (4.1–4.7): genomes, GWAS with PLINK and Hail, PheWAS, RNA-seq, and proteomics, around type 2 diabetes and the *TCF7L2* variant rs7903146.
- Planned: **surveys** (5.x) and **wearables** (6.x).

Every series uses the same cohort query, `notebooks/sql/t2d_cohort.sql`.

The core series:

| Notebook | What it does |
|---|---|
| `aou_setup.R` | Settings you edit once (bucket and dataset) and shared helper functions |
| `0.0 setup` | Checks your settings and the connection to the data |
| `1.1 build_cohorts` | The OMOP tables, concept IDs, and SQL; the cohort query; a sample; survey answers and measurements |
| `1.2 survival_data` | Time zero, event, and censoring; first CKD dates; follow-up |
| `2.1 clean` | Non-answers, messy text, duplicates, units, plausible ranges, missing data |
| `2.2 reshape` | Long vs wide; one value per person |
| `2.3 join_and_bind` | Binding rows; join types; checks after every join |
| `3.1 table_one` | A Table 1 with your own functions; the small-count check |
| `3.2 logistic_regression` | Odds ratios for type 2 diabetes; adjustment; reverse causation |
| `3.3 linear_regression` | Systolic blood pressure; model comparison; residuals |
| `3.4 survival_analysis` | Kaplan–Meier curves, log-rank test, Cox model |

**Full instructions** and the omics series are in [`notebooks/README.md`](notebooks/README.md).

The earlier versions of the notebooks (classic Workbench) are in `notebooks/archive/`.

### Running the notebooks

The notebooks only run **inside an *All of Us* workspace** (Workbench 2.0). They query the *All of Us* data with BigQuery and save files in your bucket.

1. Create a workspace on the [Researcher Workbench](https://workbench.verily.com/), add the *All of Us* Controlled Tier data collection, and create a **bucket** on the Resources tab.
2. Get the notebooks into your workspace, either way:
   - **Clone this repository:** in your workspace, go to **Apps** → **Git repositories** → **+ Add repository** and enter `https://github.com/CWML/All-of-Us-Training-Resources.git`. It's cloned into apps you create afterward.
   - **Download and upload:** download the whole `notebooks/` folder from GitHub and upload it **with its subfolders**: the notebooks in `core/` and `omics/` load `aou_setup.R` and `sql/` from the folder above.
3. Launch an app (e.g., AoU Jupyter, which has R and Python kernels).
4. Open **`0.0 setup`** and follow it: it has you edit two lines in `aou_setup.R`.
5. Run a series in order: core `1.1` → `1.2` → `2.1` → `2.2` → `2.3` → `3.1` to `3.4` (the queries in `1.1` and `1.2` only need to run once; later notebooks read the saved files), or omics `4.1` → `4.7`.

**R packages:** `tidyverse`, `lubridate`, `bigrquery`, `broom`, `survival`. `aou_setup.R` installs any that are missing the first time it runs (this can take a few minutes).

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
