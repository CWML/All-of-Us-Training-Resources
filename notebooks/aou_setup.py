"""
aou_setup.py: shared settings and helpers for the Python notebooks.

It reads BUCKET_NAME and CURRENT_DATASET from aou_setup.R, so you only set them
in one place (run 0.0 setup and edit aou_setup.R). Notebooks in a subfolder
load it with:

    import sys; sys.path.insert(0, "..")
    from aou_setup import *
"""
import glob
import os
import re

_HERE = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(_HERE, "aou_setup.R")) as f:
    _R_SETUP = f.read()


def _setting(name):
    """Read a setting such as BUCKET_NAME <- "..." from aou_setup.R."""
    match = re.search(rf'^{name}\s*<-\s*"([^"]*)"', _R_SETUP, re.MULTILINE)
    if match is None:
        raise ValueError(f"Can't find {name} in aou_setup.R")
    return match.group(1)


BUCKET_NAME = _setting("BUCKET_NAME")
CURRENT_DATASET = _setting("CURRENT_DATASET")

# Your bucket is mounted as a folder in the app. We keep our files in its data/ folder.
BUCKET_DIR = os.path.join(os.path.expanduser("~"), "workspace", BUCKET_NAME)
DATA_DIR = os.path.join(BUCKET_DIR, "data")

if not os.path.isdir(BUCKET_DIR):
    found = sorted(os.listdir(os.path.join(os.path.expanduser("~"), "workspace")))
    raise FileNotFoundError(
        f"Can't find your bucket folder: {BUCKET_DIR}\n"
        f"Folders found in ~/workspace: {', '.join(found) or 'none'}\n"
        "Update BUCKET_NAME in aou_setup.R (or create a bucket on the Resources tab).")
os.makedirs(DATA_DIR, exist_ok=True)


def aou_data_dir(version="v9"):
    """The folder where the All of Us genomic and multi-omics files are mounted."""
    found = sorted(glob.glob(os.path.join(os.path.expanduser("~"), "workspace",
                                          "vwb-aou-datasets-controlled*", version)))
    if not found:
        raise FileNotFoundError(
            f"Can't find the All of Us {version} data folder in ~/workspace/. "
            "Check that the Controlled Tier data collection is added to this workspace.")
    return found[0]


def hide_small_counts(df, column="n"):
    """All of Us policy: never share counts of 1 to 20. Blanks them out (shows NaN)."""
    df = df.copy()
    df[column] = df[column].where(df[column] > 20)
    return df


print(f"Setup done. Dataset: {CURRENT_DATASET} | Data folder: {DATA_DIR}")
