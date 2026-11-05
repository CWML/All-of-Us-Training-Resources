# reference/: public documents for AI assistants

This folder is for **public** *All of Us* and OMOP documentation, kept on your own computer so an AI assistant can check real table names, column names, and concept IDs instead of guessing. **Only this README is in Git** (see `.gitignore`): download the documents yourself.

**Never put *All of Us* data, query results, or notebook outputs here.**

| File to save here | Source |
|---|---|
| `cdr_v9_data_dictionary_*.csv` | the CDR v9 data dictionary Google Sheet, linked from the [Data Dictionaries](https://support.researchallofus.org/hc/en-us/articles/360033200232-Data-Dictionaries) article: **File → Download → CSV** for each tab you need |
| `genomic_multiomics_data_organization.pdf` | [How the All of Us Genomic and multi-omics data are organized](https://support.researchallofus.org/hc/en-us/articles/49999549117588-How-the-All-of-Us-Genomic-and-multi-omics-data-are-organized) |
| `omop_cdm_*.md` or `.html` | the [OMOP CDM documentation](https://ohdsi.github.io/CommonDataModel/) and [wiki](https://github.com/OHDSI/CommonDataModel/wiki), for CDM v5.x |
| `concepts.md` | the concept IDs this project uses, looked up in [Athena](https://athena.ohdsi.org/search-terms/start) or the [Data Browser](https://databrowser.researchallofus.org/) (don't download Athena's vocabulary files) |

Example notebooks: this repository's `notebooks/` (outputs cleared). *All of Us* tutorial notebooks: never download them from the Workbench (it's logged as egress, and many are saved with outputs). Use a public copy, or clear them in the Workbench and push them through GitHub.
