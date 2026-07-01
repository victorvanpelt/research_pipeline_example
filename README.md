# Research Pipeline Example

A small, working template for a **reproducible and dynamic** research project: raw data go in, one command runs the analysis and builds the paper and the slides, and every number and table in those documents is pulled straight from the code. Nothing is copied by hand, so nothing goes stale.

It is meant as a starting point for PhD students and faculty. The example uses Stata, R, and Quarto, but the structure works with any language.

## Why a pipeline?

Most research projects accumulate a pile of scripts, spreadsheets, and a manuscript whose numbers were pasted in by hand months ago. When the data change, someone has to remember every table, coefficient, and sample size to update. That is slow and error-prone.

This template avoids that by enforcing two habits:

1. **Separate the stages.** Raw data, code, intermediate files, outputs, and drafts each live in their own numbered folder and never mix.
2. **Generate everything downstream from code.** Tables, the paper, and the slides are rebuilt from the data by running the pipeline, so they are always in sync.

The payoff is that the project is *reproducible* (anyone can rebuild every result from the code) and *dynamic* (change the data, re-run, and the manuscript updates itself).

## What "dynamic" means here

"Dynamic" is the combination of two ideas:

- **A build pipeline.** `make` re-runs the analysis and re-renders the documents in the right order, from raw data to finished PDF.
- **Literate documents.** The paper and slides are written in [Quarto](https://quarto.org), which lets a document *read* results from the analysis instead of hard-coding them.

Concretely, in this example:

- The paper reports its sample size with `` `r sample_size` `` , a value read from the processed data rather than typed in.
- Table 1 in both the paper and the slides is `\input` from `3_output/table_1.tex`, the exact file the analysis wrote.

Edit `0_data/gen_ai_earnings.csv` (or the code), run `make`, and the coefficient, the table, the reported sample size, the paper, and the slides all change together. No copy-paste, no mismatched numbers.

## Repository structure

```
research_pipeline_example/
├── 0_data/        raw inputs      (real raw data is NOT shared; see below)
│   └── gen_ai_earnings.csv        small synthetic dataset so the example runs
├── 1_code/        analysis code   (shared; the heart of the repo)
│   ├── code.do      Stata
│   ├── code.r       R
│   └── code.qmd     Quarto (self-contained literate report)
├── 2_process/     intermediate / passing data between steps (NOT shared)
├── 3_output/      shared outputs: tables and figures
│   └── table_1.tex               written by the analysis, read by the drafts
├── 4_drafts/      the manuscript and the slides
│   ├── paper_example.qmd
│   ├── presentation_example.qmd
│   ├── references.bib
│   └── materials/  beamer theme, logo, fonts
├── makefile.mak   build tasks (the pipeline)
├── .gitignore     what is and is not version-controlled
└── README.md
```

The folders are numbered in the order data flow through them: `0_data → 1_code → 2_process → 3_output → 4_drafts`.

Other folders you might add as a project grows:

- `#_external` for copies of data or code shared with you by others,
- `#_slides` if you want to separate talks from paper drafts,
- `#_docs` for notes, memos, or referee correspondence.

## How the pieces connect

```
0_data/gen_ai_earnings.csv
        │
        ▼
1_code  (run ONE engine: code.r  |  code.do  |  code.qmd)
        │
        ├──► 2_process/edit_gen_ai_earnings.(rds|dta)   intermediate data
        │
        └──► 3_output/table_1.tex                       shared table
                    │
                    ├──► 4_drafts/paper_example.qmd         ─► paper_example.pdf
                    └──► 4_drafts/presentation_example.qmd  ─► presentation_example.pdf
```

## The three analysis engines (pick one)

`1_code` holds the *same* analysis written three ways. Use whichever fits your workflow; they produce matching results.

| File | Language | What it does |
|------|----------|--------------|
| `code.do`  | Stata  | import → transform → regress (robust SE) → write `3_output/table_1.tex` via `esttab` |
| `code.r`   | R      | same, in base R + `sandwich`; also saves intermediate data to `2_process` |
| `code.qmd` | Quarto | a self-contained literate report that builds the table inline at render time |

The analysis itself is deliberately trivial: regress a scaled earnings measure on a generative-AI indicator, with heteroskedasticity-robust standard errors. The point is the plumbing, not the result.

## Quickstart

**1. Install the prerequisites** (see [Requirements](#requirements)).

**2. Get the code.**

```bash
git clone https://github.com/victorvanpelt/research_pipeline_example.git
cd research_pipeline_example
```

The synthetic dataset is already in `0_data`, so the example runs immediately.

**3. Build everything.**

```bash
make -f makefile.mak
```

This runs the R analysis, then renders the paper and the slides. Open the results in `4_drafts/`.

> **Why `-f makefile.mak`?** The build file is named `makefile.mak` rather than the usual `Makefile` so it does not clash with other tooling and is easy to spot. Tell `make` to use it with `-f makefile.mak`, or rename it to `Makefile` and just type `make`.

## Make targets

| Command | Result |
|---------|--------|
| `make` (or `make all`) | run the R analysis, then render the paper and the slides |
| `make r`      | run the R analysis (`1_code/code.r`) |
| `make stata`  | run the Stata analysis (`1_code/code.do`) |
| `make quarto` | render the self-contained Quarto report (`1_code/code.qmd`) |
| `make paper`  | render the paper (`4_drafts/paper_example.qmd`) |
| `make slides` | render the slides (`4_drafts/presentation_example.qmd`) |
| `make clean`  | delete everything the pipeline generates, so the next `make` reproduces it from scratch |

Run `make r` (or `make stata`) before `make paper`/`make slides`, because the drafts read the files those steps write. `make` (with no target) already does this in the right order.

The tool locations are overridable if they are not on your `PATH`:

```bash
make r      RSCRIPT=/usr/local/bin/Rscript
make stata  STATA="/usr/local/stata18/stata-se"
make paper  QUARTO=/opt/quarto/bin/quarto
```

## Version control and data hygiene

The `.gitignore` uses an *ignore-everything-then-allow* strategy: it ignores all files, then explicitly re-includes only what should be shared. This makes it easy to reason about what leaves your machine.

| Folder | Shared in git? | Why |
|--------|:--------------:|-----|
| `0_data`    | only the synthetic CSV | **Real raw data should not be shared.** Drop your own data here; it stays ignored. The synthetic file is a teaching exception so the example runs. |
| `1_code`    | yes | Code is the reproducible core of the project. |
| `2_process` | no  | Intermediate files are large and disposable; they are regenerated by the code. |
| `3_output`  | yes | Final tables and figures, so collaborators and readers can see results without rerunning. |
| `4_drafts`  | sources, materials, and rendered PDFs | The `.qmd`/`.bib` sources plus the built PDFs; render intermediates (`.tex`, `.aux`, `_files/`) stay ignored. |

Each folder keeps a `.gitkeep` file so the (otherwise empty) folder still exists after a fresh clone.

## Adapting this to your own project

1. Replace `0_data/gen_ai_earnings.csv` with your data (and keep real raw data out of git).
2. Edit the transform and analysis in your engine of choice in `1_code`. Write your tables and figures to `3_output`.
3. In `4_drafts`, write your paper and slides so they read from `2_process` and `3_output` instead of hard-coding numbers.
4. Keep the folder discipline. When in doubt: raw data in `0_data`, code in `1_code`, throwaway files in `2_process`, results you keep in `3_output`, writing in `4_drafts`.

## Requirements

You do not need everything below; install what your chosen engine and outputs require.

- **Git**, to clone and version the project.
- **GNU Make.** Ships with macOS and Linux. On Windows, run the commands from **Git Bash**, **WSL**, or **MSYS2**, which provide `make` together with `rm`, `mv`, and `find`.
- **An analysis engine:** Stata (with the `estout` package: run `ssc install estout` once), or R (with the `sandwich` package), or just Quarto + R.
- **Quarto**, to render the drafts and the Quarto report.
- **A LaTeX distribution** for the PDFs. [TinyTeX](https://yihui.org/tinytex/) is the easiest (`quarto install tinytex`). The slides use **xelatex** for the custom fonts.
- **R packages for rendering Quarto:** `rmarkdown` and `knitr` (Quarto's knitr engine needs them). Install with `install.packages(c("rmarkdown", "knitr"))`. The scripts install their own analysis packages automatically.

---

Maintained by [Victor van Pelt](https://www.victorvanpelt.com). Reuse and adapt freely.
