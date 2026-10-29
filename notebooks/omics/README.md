# Omics series (4.1–4.7)

Seven classes on the *All of Us* genomic and multi-omics data, built around **one question**: what can DNA, RNA, and proteins tell us about **type 2 diabetes**? The thread through the series is the *TCF7L2* variant **rs7903146**, the strongest known genetic risk factor for type 2 diabetes.

Each class is a 120-minute R or Python notebook for the Researcher Workbench 2.0, written for beginners: concepts first, every step explained, "Read the output" guides, exercises with hidden answers, and common errors. Each notebook opens with an **Analysis at a glance** box (the question, the analysis, why, what we conclude, what it can't tell us, connections) and a **Time and cost** box.

## The classes

| Class | Language | Question | Needs first |
|---|---|---|---|
| **4.1 dna_intro** | R + PLINK | What is the genomic data, who has it, and is rs7903146's T allele more common in type 2 diabetes? | 0.0 setup |
| **4.2 gwas_plink** | R + PLINK | Which variants in the *TCF7L2* region are linked to type 2 diabetes? | 4.1 (reuses its sample) |
| **4.3 gwas_hail** | Python + Hail | Does Hail give the same answer as PLINK? | 4.1 and 4.2 |
| **4.4 phewas** | R | Which diseases are linked to rs7903146? | none |
| **4.5 rnaseq** | R (edgeR, limma) | Which genes are more or less active in blood in type 2 diabetes? Does rs7903146 change *TCF7L2* expression? | none |
| **4.6 proteomics** | R (limma) | Which plasma proteins differ, and are they genetically controlled? | none |
| **4.7 rnaseq_proteomics** | R | Do RNA and protein agree, across people and in diabetes? | none (easier after 4.5 and 4.6) |

```
4.1 DNA intro ──→ 4.2 GWAS (PLINK) ──→ 4.4 PheWAS
                  4.3 GWAS (Hail) ─┘   (same analysis, a check)
4.5 RNA ──────┐
              ├──→ 4.7 RNA + protein
4.6 Protein ──┘
```

## Before you start

1. **Run `0.0 setup`** (in `notebooks/`) once, and set `BUCKET_NAME` in `aou_setup.R`.
2. **Keep the folder layout.** These notebooks load `../aou_setup.R` and `../sql/t2d_cohort.sql` from the folder above.
3. **Use an *All of Us* JupyterLab app.** The default app (4 CPUs, 26 GB memory) is enough for every class; PLINK 2 and Hail are already installed.
4. **R packages** are installed by the notebooks when needed: `limma` and `edgeR` from Bioconductor (5–10 minutes the first time), and optionally `org.Hs.eg.db` and `GO.db` for pathway enrichment.
5. **Don't `pip install` Python packages into the shared app** without checking what they replace. In our tests, installing PheTK (a PheWAS tool) downgraded `numpy` and broke Hail.

## Cost

Each student pays for their own workspace. Per class, expect about **$1 to $2**:

- **Data:** each class runs at most one or two BigQuery queries (cents to about $1) and reads small parts of the genomic files.
- **The app:** about **$0.27 an hour** while running. Its **disk costs about $0.70 a day even when the app is stopped**. **Stop** the app after each class, and **delete** it when you've finished the series (save anything you need to your bucket first).

All classes use **samples** (e.g. 2,500 cases + 2,500 controls, or 300 + 300 for RNA and proteins) and one small region of the genome, to keep time and cost down. Each notebook says how to scale up, and what that would cost.

## What each class saves

Files go to your bucket's `data/` folder:

| Class | Saves |
|---|---|
| 4.1 | `gwas_samples.csv` (the sample), and the *TCF7L2* region files in `data/genomics/` |
| 4.2 | `gwas_tcf7l2_plink.csv`, and PLINK's results files in `data/genomics/` |
| 4.3 | `gwas_tcf7l2_hail.csv` |
| 4.4 | `phewas_rs7903146.csv` |
| 4.5 | `rnaseq_t2d_results.csv` |
| 4.6 | `proteomics_t2d_results.csv` |
| 4.7 | `rna_protein_pairs.csv` |

The sample files contain participant-level data and stay in your bucket. The results files are summary statistics (one row per variant, gene, protein, or disease).

## Going further

Combining the classes asks sharper questions. These methods are beyond the series, but each notebook points to them:

| Combine | To ask | Method |
|---|---|---|
| GWAS (4.2) + eQTLs (4.5) | Does the diabetes variant act by changing a gene's expression? | colocalization |
| GWAS (4.2) + pQTLs (4.6) | Does a protein cause diabetes, or just go with it? | Mendelian randomization |
| PheWAS (4.4) + All by All | Does the finding hold in a much bigger sample? | replication |
| RNA (4.5) + protein (4.6) | Is a change seen in both layers? | multi-omics comparison (4.7) |

## Data use

No *All of Us* data is stored in this repository. Don't download, screenshot, or share participant-level data, or counts of 1 to 20, and **clear all outputs** before committing a notebook.
