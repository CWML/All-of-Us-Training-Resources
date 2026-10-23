# Curriculum plan: All of Us notebooks (draft for review)

**Status:** agreed 2026-10-16. Being built.

## 1. The research question

> **Which factors, from health records, surveys, measurements, wearables, genes, gene expression, and proteins, are associated with type 2 diabetes?**

Every class uses the **same cohort** and adds one new kind of data or analysis. Students see the same people from different angles, and every class's numbers match.

## 2. The cohort

| | Definition |
|---|---|
| **Cases** | Age **18+**, with at least one diagnosis of **type 2 diabetes** (concept **201826**, or any more specific concept below it) |
| **Controls** | Age **18+**, with **no** diagnosis of diabetes of **any** type (concept **201820**, *Diabetes mellitus*, and everything below it) |
| **Everyone** | Has **electronic health record (EHR) data** (see decision D5) |
| **Ancestry** | All ancestries; genetic ancestry principal components (PCs) as covariates in the genetic analyses |
| **Omics classes** | Also limited to people who have that data type (genome sequence, RNA-seq, proteomics) |

**Age** is calculated at one fixed date for everyone (see decision D6) and is a covariate in every model, never a filter beyond 18+.

### Variables

| Variable | Source | Concept IDs |
|---|---|---|
| Age, sex at birth, gender, race, ethnicity | `person` table | descriptive, not filters |
| Type 2 diabetes | `condition_occurrence` + `concept_ancestor` | 201826 and descendants |
| Any diabetes (to exclude from controls) | same | 201820 and descendants |
| Type 1 diabetes (see D4) | same | 201254 and descendants |
| BMI, systolic blood pressure, HbA1c, LDL | `measurement` | BMI 3038553; systolic BP 3004249, 4152194; HbA1c 3004410; LDL 3028437, 3028288, 3009966, 36031404 (all mg/dL). Checked against the OHDSI vocabulary. The old 1.1 used 40795800 for LDL, a LOINC *component* that only works through the Cohort Builder's own hierarchy |
| PTSD survey questions | `ds_survey` / `observation` | 43528846, 43530361 (as in 1.1) |
| Chronic kidney disease (survival outcome) | `condition_occurrence` | the CKD list in the current 1.2, rebuilt from its parent concept |
| Visits (for follow-up time) | `visit_occurrence` | as in 1.2 |
| Genetic ancestry and PCs | `wgs/short_read/snpindel/aux/ancestry/ancestry_preds.tsv` | file, not a concept |

### SQL style

Short, readable SQL on the standard OMOP tables, for example:

```sql
-- People with type 2 diabetes (concept 201826) or any more specific type of it
SELECT DISTINCT co.person_id
FROM `{CURRENT_DATASET}.condition_occurrence` co
JOIN `{CURRENT_DATASET}.concept_ancestor` ca
  ON co.condition_concept_id = ca.descendant_concept_id
WHERE ca.ancestor_concept_id = 201826
```

The cohort SQL lives in **one shared file**, `notebooks/sql/t2d_cohort.sql`, that both the R and Python notebooks read, so the two can't drift apart. Each notebook still prints the SQL so students see what runs. The point-and-click **Data Explorer** stays in the classes as the no-code way to build the same cohort, with a check that both give similar numbers.

## 3. The notebooks

### Core series (R): rewrite of the current notebooks

| Notebook | What it does | Change from now |
|---|---|---|
| `aou_setup.R` | Settings and helper functions | Add helpers for the new shared SQL file |
| **0.0 setup** | Check the settings and the data connection | Small updates |
| **1.1 build_cohorts** | Cases and controls, demographics, survey answers, measurements | **New queries** (readable OMOP SQL, type 2 diabetes, 18+, no race or ethnicity filters) |
| **1.2 survival_data** | Diabetes and CKD diagnosis dates, visits | New queries, same cohort |
| **2.1 clean** | Non-answer codes (*PMI: Skip*, *Prefer not to answer*), impossible values and units, finding and removing duplicates, missing data and what `drop_na()` costs | **New** (from part of 2.0) |
| **2.2 reshape** | Long vs wide; `pivot_wider()` and `pivot_longer()`; when each is needed | **New** (from part of 2.0) |
| **2.3 join_and_bind** | Binding groups; join types (`left`, `inner`, `full`, `anti`) with a picture; checks after every join (row counts, unmatched IDs, ID types) | **New** (from part of 2.0) |
| **3.1 table_one** | Descriptive statistics and tests | Recheck all outputs and text |
| **3.2 logistic_regression** | Odds of type 2 diabetes | Recheck all outputs and text |
| **3.3 linear_regression** | Systolic blood pressure | Recheck all outputs and text |
| **3.4 survival_analysis** | Time from type 2 diabetes to CKD | New follow-up rules (D15): time zero = first type 2 diabetes date; event = first CKD date; censored at the earlier of the last EHR date and death. Kaplan–Meier curves with ggplot2 instead of survminer (D17) |

### Omics series: new, in `notebooks/omics/`

Each starts with a **short cohort section** (the shared SQL, limited to people with that data type), so it works on its own. Each links back to 2.1–2.3 for the cleaning and joining skills.

| Notebook | Language | What it does | Data |
|---|---|---|---|
| **4.1 dna_intro** | R + Terminal | What the genomic data is (short-read and long-read genome sequences, microarrays), file formats (PLINK, Hail, VCF), how to read a small piece | `wgs/`, `microarray/` |
| **4.2 gwas_plink** | R (calls PLINK 2) | Extract the *TCF7L2* region for the cohort, quality control, logistic regression per variant with age, sex, and ancestry PCs; Manhattan and QQ plots | ACAF `pgen`, chr10 |
| **4.3 gwas_hail** | Python (Hail) | The same GWAS in Hail, on the same people and variants; compare with 4.2 | ACAF `splitMT` or the 4.2 extract |
| **4.4 phewas** | R | Take the lead variant (rs7903146) and test it against many phenotypes | genotype + EHR |
| **4.5 rnaseq** | R | Gene expression in type 2 diabetes (the current 4.0 draft, moved and updated) | `multiomics/rnaseq` |
| **4.6 proteomics** | R | Protein levels in type 2 diabetes | `multiomics/` proteomics |
| **4.7 rnaseq_proteomics** | R | Do genes and their proteins change together? | both |

Supporting files: `notebooks/sql/t2d_cohort.sql` (shared query, used by every notebook); in `notebooks/omics/`: `aou_setup.py` (Python version of `aou_setup.R`), and `README.md` (the series overview, data map, and decisions log below).

### Series 5: survey data (new, in `notebooks/surveys/`)

Each starts with the short cohort section, so it works on its own.

| Notebook | What it does |
|---|---|
| **5.1 survey_basics** | How surveys are organised (modules, questions, answers); finding them in the data dictionary and Data Browser; non-answers (*PMI: Skip*, *Prefer not to answer*, *Don't know*); skip logic (a missing answer can mean "not asked"); questions with several answers; survey dates and versions |
| **5.2 family_history_lifestyle** | Family history of diabetes, smoking, alcohol, physical activity, and type 2 diabetes |
| **5.3 social_factors** | Food insecurity, health care access, and other social factors, and type 2 diabetes |

### Series 6: wearables (new, in `notebooks/wearables/`)

| Notebook | What it does |
|---|---|
| **6.1 fitbit_basics** | Which Fitbit tables exist (use the **daily** tables; minute-level steps are huge and costly); who has Fitbit data and why they aren't a random sample; summarising many days to one value per person; valid wear days |
| **6.2 steps_and_t2d** | Average daily steps and type 2 diabetes, modelled on the published All of Us study of step counts and chronic disease; steps measured **before** the diagnosis, to avoid reverse causation |
| **6.3 sleep_and_heart_rate** | The same approach with sleep and resting heart rate |

Apple HealthKit data (fewer participants) can be added later.

### Every notebook includes

- Learning objectives, time, and what it uses and saves
- A plain-language **concepts primer**
- An explanation of **why** for every step, not just how
- **Read the output** guides after each result
- A **cost note** at the top (each student has their own workspace and billing account)
- Exercises with hidden answers; common errors; key takeaways
- **Instructor tips**: talking points and questions students are likely to ask
- For the genetics classes, a **glossary** (variant, allele, genotype, PC, odds ratio per allele, genome-wide significance)

## 4. Decisions log

| # | Decision | Why | Status |
|---|---|---|---|
| D1 | **Type 2 diabetes** (201826) instead of all diabetes (201820) | Type 1 and type 2 have different causes and different genetics; mixing them weakens every signal, especially *TCF7L2* | Decided |
| D2 | Cases and controls **18+**, no upper age limit; age as a covariate | Keeps everyone; age is handled in the models. Optional exercise: controls aged 40+ (younger controls may still develop diabetes) | Decided |
| D3 | Controls have **no diabetes of any type** | Someone with type 1 or unspecified diabetes isn't a clean "no diabetes" comparison | Decided |
| D4 | Exclude cases who **also** have a type 1 diabetes diagnosis? | Health records often contain both codes for the same person; dropping them makes cases cleaner but loses people | Decided (show how many are dropped) |
| D5 | Everyone must have **EHR data** | Without health records, "no diabetes diagnosis" just means "no records", not "no diabetes" | Decided |
| D6 | Age at a **fixed date** (the dataset's cutoff, 2025-01-01, for v9) | "Age today" changes every time the notebook runs, so numbers wouldn't match between runs or classes | Decided |
| D7 | All ancestries, adjusted for genetic **ancestry PCs** | Fits All of Us; analysing one group would leave most participants out | Decided |
| D8 | **Samples**, not everyone: default 2,500 cases + 2,500 controls in the omics classes, adjustable at the top | Each student pays for their own compute; this is enough for a clear *TCF7L2* result | Decided |
| D9 | GWAS region: *TCF7L2*, chr10:112.7–113.4 Mb (GRCh38) | The strongest known type 2 diabetes locus; extracting it took 10 seconds and 3 MB for 5,000 people | Decided |
| D10 | Both **PLINK** (R) and **Hail** (Python) for the GWAS, on the same data | Students see two common tools and can compare their results | Decided |
| D11 | Readable OMOP SQL in **one shared file** | Easier to teach than the Cohort Builder's generated SQL; one definition for R and Python. The data dictionary also marks the `cb_` tables as *not recommended for research analysis* | Decided |
| D14 | "Has EHR data" = at least one visit from an EHR site **or** shared by the participant (`visit_occurrence_ext.src_id` starting with `EHR site` or `Participant Mediated EHR`) | Uses the standard OMOP tables instead of the `cb_search_person` flag; participant-shared records are real health records | Decided (decision A); `EHR site` tested: 381,006 people |
| D16 | People who died before the age date: age **at death**, plus `deceased` and `death_date` columns | Otherwise their age keeps growing after death (ages up to 119 in the first test) | Decided (decision B) |
| D17 | Drop `survminer`; draw survival curves with `ggplot2` | `survminer` failed to install in the app (its dependency `nloptr` needs compiling) | Decided (decision C) |
| D18 | Case definition: **1 code** (current) or **2+ codes** (All by All's rule)? | 1 code finds more cases; 2+ codes are more certain (higher PPV) but lose cases | Decided: 1 code is the main definition; 2+ code days as a comparison (column `t2d_code_days`) |
| D15 | Follow-up from **EHR dates**: entry at the first relevant date, censoring at the earlier of the last EHR date and death | Follow-up should only count time when a diagnosis could have been recorded; `observation_period` also counts survey dates | Decided (details below this table) |
| D12 | Rewrite the existing classes' queries too | They haven't been taught or shared yet, so every class can use one cohort | Decided |
| D13 | Split 2.0 into **2.1 clean, 2.2 reshape, 2.3 join_and_bind** | Fills gaps (join types, deduplication, pivot longer, non-answer codes, impossible values) in short, single-purpose notebooks | Decided |

### Follow-up dates (for 3.4, and as background in 1.2)

- `first_ehr_date` and `last_ehr_date`: the first and last **EHR visit** dates per person (`visit_occurrence` with `visit_occurrence_ext.src_id` from an EHR source). Added to the shared SQL.
- Not `observation_period`: its dates come from EHR **and** surveys (data dictionary: "EHR/PPI"), so a recent survey can stretch someone's follow-up past their last health record.
- `death_date` from `death`. If only the year is known, it's recorded as December 31.
- Time zero depends on the question: first **type 2 diabetes** date for diabetes → CKD (3.4); first **EHR** date for "who develops type 2 diabetes" (an incidence question). Censoring is the earlier of the last EHR date and death in both.
- Exclude people whose event came before time zero (e.g. CKD before diabetes).
- Idea from the All of Us Friday coffee series, 2026-10-16.

## 5. Build order

1. Shared cohort SQL file and helpers; test the queries in the Workbench, and compare counts with Data Explorer
2. **Omics series first** (specifically requested), in table order: 4.1 → 4.7. Each omics notebook has its own short cohort section, so it doesn't depend on the core rewrite.
3. Core series: 1.1, 1.2, then 2.1–2.3, then recheck 3.1–3.4
4. Survey series: 5.1 → 5.3
5. Wearables series: 6.1 → 6.3

Each step is tested in the Workbench before the next one starts.

## 6. Data facts found so far (from the workspace)

- Data folder: `~/workspace/vwb-aou-datasets-controlled-v8r9/v9/` (named v8r9, holds v9): `known_issues`, `microarray`, `multiomics`, `transfer_in`, `wgs`
- Short-read genome sequences: **535,662** participants. ACAF common variants come as `bed`, `bgen`, `multiMT`, `pgen`, `plink_bed`, `splitMT`, `vcf`. One chromosome in PLINK 1 format is 540–790 GB; in `pgen` format, 75 GB (chr10). The `.psam` files have **no sex** recorded, so sex comes from the `person` table.
- PLINK 1.9, PLINK 2, and Hail 0.2.137 are installed in the regular app; no cluster needed for a region.
- RNA-seq: 8,980 samples × 77,814 genes; manifest columns `sampleid`, `research_id`, and BAM paths.
- From the CDR v9 release talk (Office Hours, 2026-07-24; notes in `Notes/aou_youtube/`):
  - **Controlled Tier person IDs changed between v8 and v9.** Files saved from v8 (e.g. the classic notebooks' CSVs) can't be joined to v9 data; every class must build its data from v9.
  - 481,000 participants with EHR; 9,969 proteomics samples; 14,521 long-read genomes; 68,000 with Fitbit.
  - Precomputed **relatedness** and genetic ancestry files exist (for GWAS quality control in 4.2–4.3); file paths are in the data dictionary's *Genomic and Multi-omics File Paths* tab.
  - **All by All** phenome-wide results (refreshed with v8 data) can be used in v9 workspaces: a resource for 4.4 PheWAS.
  - Clinical-notes conditions (NLP, 99,000 people) are a separate release, not in `condition_occurrence`, so our diabetes definition doesn't use them.
  - The data cutoff date (our age date, 2025-01-01) wasn't mentioned; still needs a source.
- From other Office Hours talks (notes in `Notes/aou_youtube/`):
  - **Multi-omics:** RNA-seq is from **whole blood** (Watchmaker kit); proteomics is **plasma, Olink Explore** (5,000+ proteins), as 61 batch files plus one cross-batch normalized matrix (with or without about 127 replicates). Expression PCA clusters reflect **library preparation, not biology**; adjust for expression PCs and genotype PCs. How participants were selected wasn't stated. AoU tutorial notebooks use downsampled data on n1-highmem-4.
  - **All by All phenotypes:** phecode cases need **≥ 2 codes**; controls = everyone else with EHR data. Lab cleaning pipeline (units, lab-specific outlier cut-offs, per-person summaries) is a model for 2.1. Rerunning All by All is not recommended (quoted about $22,000 per phenotype); use the precomputed tables and allbyall.researchallofus.org for 4.4.
  - **Computable phenotypes:** combining codes, medications and labs raises PPV; requiring 2+ codes lowers sensitivity; plot phenotype counts by date to catch coding drift.
  - **Fitbit:** valid day = fewer than 200 missing minutes; use data from 2018 onward for sleep (algorithm changed in 2017); don't naively pool "bring your own device" and WEAR participants; leave a gap (e.g. 30 days) before diagnosis. Steps were among the strongest links for obesity and diabetes.
- Not yet checked: the proteomics folder, `rnaseq_metadata.tsv`, the microarray files, `ancestry_preds.tsv` columns, and how many cases and controls have each data type.
