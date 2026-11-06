#!/bin/bash
# The GWAS from 4.2, on one chromosome of the All of Us ClinVar PLINK files.
#
# The same script runs in two places (workflows_dsub.ipynb):
#   - in your app, to test it on one chromosome first
#   - inside a dsub job, on its own cloud machine, once per chromosome
#
# Everything it needs comes in as environment variables:
#   CHR      the chromosome, e.g. 21
#   BED      the .bed file (the .bim and .fam files must be in the same folder)
#   KEEP     the people to keep (one person_id per line)
#   PHENO    the phenotype file (#IID, t2d: 2 = case, 1 = control)
#   COVAR    the covariate file (#IID, age, sex_male, PC1 ... PC10)
#   OUT_DIR  the folder to write the results to

set -euo pipefail   # stop at the first error, so a failed step fails the job

mkdir -p "${OUT_DIR}"

plink2 \
  --bfile "${BED%.bed}" \
  --keep "${KEEP}" \
  --maf 0.01 --geno 0.1 --hwe 1e-10 \
  --pheno "${PHENO}" --pheno-name t2d \
  --covar "${COVAR}" --covar-variance-standardize \
  --glm hide-covar firth-fallback \
  --out "${OUT_DIR}/chr${CHR}"
