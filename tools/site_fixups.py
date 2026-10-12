"""Post-process generated website pages: drop presenter-only notes, add links.

Usage: python3 -I site_fixups.py <site-root>
"""
import sys
from pathlib import Path

root = Path(sys.argv[1])
TIP = '::: {.callout-tip collapse="true" title="Instructor tip"}\n'

def edit(path, pairs):
    p = root / path
    s = p.read_text()
    for a, b in pairs:
        assert s.count(a) == 1, (path, a[:60], s.count(a))
        s = s.replace(a, b)
    p.write_text(s)

def drop_tip(text):
    """Return (tip-block-with-text, '') pair to remove a whole tip."""
    return (TIP + text + "\n:::\n", "")

edit("pages/data/data-collections.qmd", [
    ("The Exchange lists 10 collections in total. Show the others in the live demo.",
     "The Exchange lists 10 collections in total."),
    drop_tip("Show these in the live demo."),
])
edit("pages/get-started/access.qmd", [
    ("Students who already have Workbench access can skip this slide. Registration happens on the All of Us Research Hub before Workbench access; screenshots aren't included because the pages are only shown to new users.",
     "If you already have Workbench access, skip this step. Registration happens on the All of Us Research Hub before you can use the Workbench."),
    drop_tip("Screenshot shows the presenter's name. Crop it if needed."),
])
edit("pages/data/data-explorer.qmd", [
    ("The screenshot's \"Last modified … by\" column showed a staff email; it has been painted out. ", ""),
    ("Only large counts are shown on these slides.", "Only large counts are shown on this page."),
    ("the same fields as *New Cloud Storage Bucket*",
     "the same fields as [New Cloud Storage Bucket](../workspace/resources.qmd#new-cloud-storage-bucket)"),
])
edit("pages/extras/extras.qmd", [
    (" (to become the GitHub page on the website)", ""),
])
edit("pages/workspace/resources.qmd", [
    ("More detail on each resource type follows.", "More detail on each resource type is below."),
    ("New Cohort is covered in the Data Explorer section.",
     "New Cohort is covered on the [Data Explorer](../data/data-explorer.qmd) page."),
])
edit("pages/workspace/storage-costs.qmd", [
    ("See *New Cloud Storage Bucket*", "See [New Cloud Storage Bucket](resources.qmd#new-cloud-storage-bucket)"),
    ("see *New Cloud Storage Bucket*", "see [New Cloud Storage Bucket](resources.qmd#new-cloud-storage-bucket)"),
    ("See *What Is an App?* and *Reading the Cost Estimate* in the Apps section.",
     "See [What is an app?](apps.qmd#what-is-an-app) and [Reading the cost estimate](apps.qmd#reading-the-cost-estimate) on the Apps page."),
])
edit("pages/examples/tutorial-workspaces.qmd", [
    ("see *Workspace Variables* in the Apps section",
     "see [Workspace Variables](../workspace/storage-costs.qmd#workspace-variables)"),
])
edit("pages/resources.qmd", [
    ("Connect GitHub with your Workbench **SSH key** (see *Optional Extras*)",
     "Connect GitHub with your Workbench **SSH key** (see the [GitHub guide](extras/github-guide.qmd))"),
    ("for code only (see *Optional Extras*)",
     "for code only (see [AI tools](extras/extras.qmd#ai-tools-use-them-outside-the-workbench))"),
])
edit("pages/workspace/workflows.qmd", [
    ("see *Optional Extras: GitHub*", "see the [GitHub guide](../extras/github-guide.qmd)"),
])
print("fixups applied")

# Link the Connect GitHub section to the full guide page
p = root / "pages/extras/extras.qmd"
s = p.read_text()
a = "## Add a Repository\n"
assert s.count(a) == 1
s = s.replace(a, "**Full step-by-step instructions**, including troubleshooting: [GitHub Guide](github-guide.qmd)\n\n" + a)
p.write_text(s)
print("github link added")
