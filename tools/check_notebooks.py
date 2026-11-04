#!/usr/bin/env python3
"""Check files before they go to GitHub: no notebook outputs, no data files, no credentials.

Usage:
    python3 tools/check_notebooks.py FILE [FILE ...]

Exits with status 1 (and lists the problems) if any file:
  - is a Jupyter notebook with saved outputs (tables, plots, printed results)
  - has a data-file extension (.csv, .tsv, .parquet, .vcf, .bam, .rds, ...)
  - is larger than 25 MB
  - contains something that looks like a credential (private key, GitHub or Google token)

Used by the pre-commit hook (see the GitHub Guide on the course site) and by the
GitHub check in .github/workflows/check-notebooks.yml. Needs only Python 3.
"""
import json
import os
import re
import sys

DATA_EXTENSIONS = (
    ".csv", ".tsv", ".txt.gz", ".parquet", ".feather", ".xlsx", ".xls",
    ".vcf", ".vcf.gz", ".vcf.bgz", ".bgen", ".pgen", ".bed", ".bim", ".fam",
    ".bam", ".cram", ".rds", ".rdata", ".rda", ".h5", ".pkl",
)
MAX_BYTES = 25 * 1024 * 1024
CREDENTIALS = re.compile(
    r"-----BEGIN [A-Z ]*PRIVATE KEY-----"   # SSH and service-account keys
    r"|ghp_[A-Za-z0-9]{36}"                  # GitHub personal access token
    r"|github_pat_[A-Za-z0-9_]{50,}"         # GitHub fine-grained token
    r"|ya29\.[A-Za-z0-9_-]{20,}"             # Google OAuth access token
    r"|AIza[0-9A-Za-z_-]{35}"                # Google API key
)
TEXT_EXTENSIONS = (".ipynb", ".py", ".r", ".R", ".sql", ".sh", ".md", ".qmd", ".yml", ".yaml", ".json", ".txt")


def problems_in(path):
    found = []
    lower = path.lower()
    if lower.endswith(DATA_EXTENSIONS):
        found.append("data file (keep data in the Workbench)")
    if os.path.getsize(path) > MAX_BYTES:
        found.append(f"larger than {MAX_BYTES // (1024 * 1024)} MB")
    if lower.endswith(".ipynb"):
        try:
            nb = json.load(open(path, encoding="utf-8"))
            n = sum(1 for c in nb.get("cells", []) if c.get("cell_type") == "code" and c.get("outputs"))
            if n:
                found.append(f"notebook with saved outputs in {n} cell(s): clear them first")
        except (json.JSONDecodeError, UnicodeDecodeError):
            found.append("notebook that isn't valid JSON")
    if path.endswith(TEXT_EXTENSIONS):
        text = open(path, encoding="utf-8", errors="ignore").read()
        if CREDENTIALS.search(text):
            found.append("something that looks like a password, key, or token")
    return found


def main(paths):
    bad = 0
    for path in paths:
        if not os.path.isfile(path) or path.startswith(("docs/", ".git/")):
            continue                     # deleted files; the built website (docs/) has its own images
        for problem in problems_in(path):
            print(f"✗ {path}: {problem}")
            bad += 1
    if bad:
        print(f"\n{bad} problem(s) found. Nothing was committed or merged. "
              "Fix them, then try again.\n"
              "Clear outputs: jupyter nbconvert --clear-output --inplace <notebook>")
        return 1
    print(f"✓ Checked {len(paths)} file(s): no outputs, data files, or credentials found.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
