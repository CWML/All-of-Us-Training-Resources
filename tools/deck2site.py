"""Convert sections of the reveal.js deck into Quarto website pages.

Usage: python3 -I deck2site.py <deck.qmd> <site-root>
Pages Billing and Apps are maintained by hand and not generated here.
"""
import re
import sys
from pathlib import Path

deck_path, root = Path(sys.argv[1]), Path(sys.argv[2])
deck = deck_path.read_text()
deck = deck.split("\n---\n", 1)[1]  # drop YAML header

# ---- split into (section, title, body) -------------------------------------
slides, section = [], None
cur = None
for line in deck.split("\n"):
    if line.startswith("# "):
        section = line[2:].strip()
        cur = None
        continue
    if line.startswith("## "):
        title = re.sub(r"\s*\{[^}]*\}\s*$", "", line[3:]).strip()
        cur = [section, title, []]
        slides.append(cur)
        continue
    if cur is not None:
        cur[2].append(line)

def get(title):
    hits = [s for s in slides if s[1] == title]
    assert len(hits) == 1, (title, len(hits))
    return hits[0]

def in_section(name):
    return [s for s in slides if s[0] == name]

# ---- body conversion ---------------------------------------------------------
OPEN = re.compile(r"^(:{3,})\s*(\S.*)$")
CLOSE = re.compile(r"^:{3,}\s*$")

def convert(lines, rel):
    out, stack, skip = [], [], 0
    for line in lines:
        m_close = CLOSE.match(line)
        m_open = None if m_close else OPEN.match(line)
        if skip:
            if m_open:
                skip += 1
            elif m_close:
                skip -= 1
                if skip == 0:
                    stack.pop()
            continue
        if m_open:
            colons, attrs = m_open.groups()
            a = attrs.strip()
            if a in ("notes", "{.notes}"):
                out.append(f'{colons} {{.callout-tip collapse="true" title="Instructor tip"}}')
                stack.append("keep")
            elif a in ("fragment", "{.fragment}"):
                stack.append("drop")
            elif a in ("columns", "{.columns}"):
                out.append(f"{colons} {{.grid}}")
                stack.append("keep")
            elif ".column" in a or a.startswith("{.column"):
                w = re.search(r'width[=:]\s*"?(\d+)%', a)
                k = round(int(w.group(1)) * 12 / 100) if w else 6
                if k == 0:
                    stack.append("skip")
                    skip = 1
                    continue
                out.append(f"{colons} {{.g-col-12 .g-col-md-{k}}}")
                stack.append("keep")
            elif "annotated" in a:
                out.append(f"{colons} {{.annotated}}")
                stack.append("keep")
            else:
                out.append(line)
                stack.append("keep")
            continue
        if m_close:
            kind = stack.pop() if stack else "keep"
            if kind == "keep":
                out.append(line)
            continue
        line = re.sub(r"\]\(images/([^)\s]+)\)",
                      lambda m: f"](<{rel}Intro to workbench 2.0/images/{m.group(1)}>)", line)
        out.append(line)
    assert not stack, stack
    text = "\n".join(out)
    text = re.sub(r"\n{3,}", "\n\n", text).strip("\n")
    return text

def page(path, title, desc, intro, slide_list, outro=""):
    p = root / path
    rel = "../" * (len(Path(path).parts) - 1)
    parts = [f'---\ntitle: "{title}"\ndescription: "{desc}"\n---\n']
    if intro:
        parts.append(intro.strip() + "\n")
    for s in slide_list:
        if isinstance(s, str):
            parts.append(s.strip() + "\n")
            continue
        _, t, body = s
        if t == title:  # first slide repeats the page title: use it as the intro
            parts.append(f"{convert(body, rel)}\n")
            continue
        parts.append(f"## {t}\n\n{convert(body, rel)}\n")
    if outro:
        parts.append(outro.strip() + "\n")
    p.write_text("\n".join(parts))
    print("wrote", path, len(slide_list), "sections")

# ---- page plan ---------------------------------------------------------------
page("pages/get-started/about.qmd", "About All of Us",
     "The All of Us Research Program, its data sources, the CDR, and data access tiers",
     "", in_section("About All of Us"))

page("pages/get-started/whats-new.qmd", "What's New in Workbench 2.0",
     "Researcher Workbench 2.0 on Verily Workbench, and what changed from the classic Workbench",
     "", in_section("What's New in Workbench 2.0"))

page("pages/get-started/access.qmd", "Getting Access",
     "Creating your account, logging in, and finding your way around the Workbench",
     "", in_section("Getting Access"))

page("pages/data/data-collections.qmd", "Data Collections",
     "Data collections, the Data Exchange, and access levels",
     "", in_section("Data Collections"))

page("pages/workspace/workspaces.qmd", "Workspaces",
     "What workspaces are for, the Workspaces page, access levels, and sharing",
     "", in_section("Workspaces"))

page("pages/examples/tutorial-workspaces.qmd", "Tutorial Workspaces",
     "The All of Us tutorial workspaces, workspace migration, and setting up your environment",
     "", in_section("All of Us Tutorial Workspaces"))

setup = in_section("Setting Up a Workspace")
rus = [s for s in setup if s[1].startswith("Research Use Statement")]
setup_rest, inserted = [], False
for s in setup:
    if s in rus:
        if not inserted:
            setup_rest.append("## Answer the Research Use Statement\n\n"
                              "Adding an *All of Us* data collection asks you to answer the "
                              "**Research Use Statement** questions. They're covered step by step on "
                              "their own page: [Research Use Statement](research-use-statement.qmd).")
            inserted = True
        continue
    setup_rest.append(s)
page("pages/workspace/setup.qmd", "Setting Up a Workspace",
     "Create a workspace and add an All of Us data collection",
     "This page uses our example workspace, **`intro-to-AoU`**, created for instruction only.",
     setup_rest)

page("pages/workspace/research-use-statement.qmd", "Research Use Statement",
     "The Research Use Statement questions you answer when adding an All of Us data collection",
     "When you add an *All of Us* data collection to a workspace (see "
     "[Setting Up a Workspace](setup.qmd)), you answer these questions about your research. "
     "Our example answers are for an instructional workspace.",
     rus)

page("pages/workspace/resources.qmd", "Overview and Resources Tabs",
     "Workspace layout, the Overview and Resources tabs, buckets, BigQuery datasets, folders, and references",
     "", in_section("Inside Your Workspace"))

page("pages/data/data-explorer.qmd", "Data Explorer",
     "Add a cohort, build it with criteria, save a data snapshot, and use the exported notebook",
     "", in_section("Data Explorer"))

page("pages/workspace/workflows.qmd", "Workflows",
     "The Workflows tab, Cromwell and Nextflow workflows, batch jobs, and dsub",
     "", in_section("Workflows"))

storage = [get(t) for t in ("Working in Your App", "Snippets Are Gone: Use Your Bucket Folder",
                            "Saving and Reading Files", "Workspace Variables")]
page("pages/workspace/storage-costs.qmd", "Storage & Costs",
     "Saving and reading files in your bucket, workspace variables, storage, and saving money",
     "", storage + in_section("Storage & Costs"))

extras = [s for s in in_section("Optional Extras") if s[1] != "What's in This Section"]
page("pages/extras/extras.qmd", "Optional Extras",
     "Practice with synthetic data, adding a file from a URL, GitHub, and AI tools",
     "Useful tools you **don't need** for the basics.", extras)

wrap = [s for s in in_section("Wrap-up") if s[1] not in ("Questions", "Course Survey")]
page("pages/resources.qmd", "Resources",
     "Good habits, helpful links, and what's next",
     "", wrap)
