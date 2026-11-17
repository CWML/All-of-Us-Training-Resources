"""
aou_setup.py: shared settings and helpers for the Python notebooks.

It reads BUCKET_NAME and CURRENT_DATASET from my_settings.R (your own settings,
saved by 0.0 setup) or, if they aren't there, from aou_setup.R, so you only set
them in one place. Notebooks in a subfolder
load it with:

    import sys; sys.path.insert(0, "..")
    from aou_setup import *
"""
import glob
import os
import re

_HERE = os.path.dirname(os.path.abspath(__file__))
_SETTINGS_FILES = [os.path.join(_HERE, "my_settings.R"), os.path.join(_HERE, "aou_setup.R")]


def _setting(name):
    """Read a setting such as BUCKET_NAME <- "...": from my_settings.R if it's there, else aou_setup.R."""
    for path in _SETTINGS_FILES:
        if os.path.exists(path):
            with open(path) as f:
                match = re.search(rf'^{name}\s*<-\s*"([^"]*)"', f.read(), re.MULTILINE)
            if match:
                return match.group(1)
    raise ValueError(f"Can't find {name} in my_settings.R or aou_setup.R")


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
        "Save your bucket's folder name with 0.0 setup, Step 2 (or create a bucket on the Resources tab).")
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
