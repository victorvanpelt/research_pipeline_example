# Research Pipeline Example

A working template for a reproducible and dynamic research project: raw data go in, one command runs the analysis and builds the paper and the slides, and every number and table in those documents is pulled straight from the code. Nothing is copied by hand, so nothing goes stale, and everything is reproducible. The pipeline is also dynamic: `make` rebuilds everything in the right order, from raw data to finished PDF, and the paper and slides are written in [Quarto](https://quarto.org), so they read results from the analysis instead of hard-coding them. Edit the code, run `make`, and every number, table, and document updates together. No copy-paste, no mismatched numbers.

This pipeline is meant as a starting point for empirical research projects by academics and researchers. The example showcases Stata, R, and Quarto processes, but, in principle, the structure works with any coding language.

The structure of this research pipeline is in line with the concept of the [TIER Protocol](https://www.projecttier.org/tier-protocol/protocol-4-0/), a widely used standard for documenting reproducible research.

## Repository structure

```
research_pipeline_example/
├── 0_data/        raw inputs      (real raw data is NOT shared; see below)
│   ├── gen_ai_earnings.csv        small synthetic dataset so the example runs
│   └── codebook.md                what each variable means, where the data come from
├── 1_code/        analysis code   (shared; the heart of the repo)
│   ├── code.do      Stata
│   ├── code.r       R
│   └── code.qmd     Quarto (self-contained literate report)
├── 2_process/     intermediate / passing data between steps (NOT shared)
├── 3_output/      shared outputs: tables and figures
│   ├── table_1.tex               written by the analysis, read by the drafts
│   └── data_appendix/            stats and figures for the data appendix
├── 4_drafts/      the documents; each .qmd renders to a committed .pdf
│   ├── paper_example.qmd          the manuscript
│   ├── presentation_example.qmd   the slides
│   ├── data_appendix_example.qmd  the data appendix (describes the analysis data)
│   ├── references.bib             bibliography for the drafts
│   └── materials/                 beamer theme, logo, fonts for the slides
├── makefile.mak     build tasks (the pipeline)
├── Makefile         two-line wrapper including makefile.mak, so plain `make` works
├── AGENTS.md        rules for AI coding agents working in this repo
├── .gitignore       what is and is not version-controlled
├── .gitattributes   normalizes line endings across operating systems
└── README.md        this file
```

The folders are numbered in the order data flow through them: `0_data → 1_code → 2_process → 3_output → 4_drafts`.

Other folders you might add as a project grows:

- `#_external` for copies of data or code shared with you by others,
- `#_slides` if you want to separate talks from paper drafts,
- `#_docs` for notes, memos, or referee correspondence.

## How the pieces connect

```
0_data/gen_ai_earnings.csv   (documented in 0_data/codebook.md)
        │
        ▼
1_code  (run ONE engine: code.r | code.do; code.qmd is self-contained ─► 1_code/code.pdf)
        │
        ├──► 2_process/gen_ai_earnings.(rds|dta)        untouched raw copy
        ├──► 2_process/edit_gen_ai_earnings.(rds|dta)   edited analysis data
        ├──► 3_output/table_1.tex                       shared table
        └──► 3_output/data_appendix/                    appendix stats + figures
                    │
                    ▼   (the drafts read from 2_process and 3_output)
        ├──► 4_drafts/paper_example.qmd          ─► paper_example.pdf
        ├──► 4_drafts/presentation_example.qmd   ─► presentation_example.pdf
        └──► 4_drafts/data_appendix_example.qmd  ─► data_appendix_example.pdf
```

## The three analysis engines (pick one)

`1_code` holds the *same* analysis written three ways. Use whichever fits your workflow; they produce matching results.

| File | Language | What it does |
|------|----------|--------------|
| `code.do`  | Stata  | import → transform → regress (robust SE) → write `3_output/table_1.tex` via `esttab` |
| `code.r`   | R      | same, in base R + `sandwich`; also saves intermediate data to `2_process` |
| `code.qmd` | Quarto | a self-contained literate report that builds the table inline at render time |

The analysis itself is deliberately trivial: regress a scaled earnings measure on a generative-AI indicator, with heteroskedasticity-robust standard errors. The point is the plumbing, not the result.

`code.r` and `code.do` also write the data appendix's statistics and figures to `3_output/data_appendix/`; `4_drafts/data_appendix_example.qmd` assembles them into a short document describing the analysis data variable by variable. `code.qmd` is self-contained and skips this step.

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
make
```

This runs the R analysis, then renders the data appendix, the paper, and the slides. Open the results in `4_drafts/`. (The build logic lives in `makefile.mak`, named so it is easy to spot; the two-line `Makefile` just includes it so plain `make` works.)

## Make targets

| Command | Result |
|---------|--------|
| `make` (or `make all`) | run the R analysis, then render the data appendix, the paper, and the slides |
| `make r`      | run the R analysis (`1_code/code.r`) |
| `make stata`  | run the Stata analysis (`1_code/code.do`) |
| `make quarto` | render the self-contained Quarto report (`1_code/code.qmd`) |
| `make appendix` | render the data appendix (`4_drafts/data_appendix_example.qmd`) |
| `make paper`  | render the paper (`4_drafts/paper_example.qmd`) |
| `make slides` | render the slides (`4_drafts/presentation_example.qmd`) |
| `make clean`  | delete everything the pipeline generates, so the next `make` reproduces it from scratch |
| `make help`   | list the targets |

`make` (with no target) runs everything in the right order. If you build a single document, run `make r` (or `make stata`) first, because the drafts read the files those steps write.

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
| `0_data`    | the synthetic CSV and its codebook | **Real raw data should not be shared.** Drop your own data here; it stays ignored. The synthetic file is a teaching exception so the example runs. |
| `1_code`    | yes | Code is the reproducible core of the project. |
| `2_process` | no  | Intermediate files are large and disposable; they are regenerated by the code. |
| `3_output`  | yes | Final tables and figures, so collaborators and readers can see results without rerunning. |
| `4_drafts`  | sources, materials, and rendered PDFs | The `.qmd`/`.bib` sources plus the built PDFs; render intermediates (`.tex`, `.aux`, `_files/`) stay ignored. |

Each folder keeps a `.gitkeep` file so the (otherwise empty) folder still exists after a fresh clone.

## Adapting this to your own project

1. Replace `0_data/gen_ai_earnings.csv` with your data (and keep real raw data out of git). Update `0_data/codebook.md` so every variable and the data's origin stay documented.
2. Edit the transform and analysis in your engine of choice in `1_code`. Write your tables and figures to `3_output`.
3. In `4_drafts`, write your paper and slides so they read from `2_process` and `3_output` instead of hard-coding numbers.
4. Keep the folder discipline. When in doubt: raw data in `0_data`, code in `1_code`, throwaway files in `2_process`, results you keep in `3_output`, writing in `4_drafts`.

## AI coding agents

`AGENTS.md` states the rules AI coding agents must follow in this repository; most agentic coding tools read it automatically. The rules protect the pipeline's discipline: raw data in `0_data` are read-only, files in `2_process` and `3_output` are build artifacts only the code may write, the three analysis engines stay in sync, and agents never commit or push, so every change stays in the working tree for you to review. A change counts as done only when `make clean` followed by `make` rebuilds every output without errors.

## Requirements

You do not need everything below; install what your chosen engine and outputs require.

- **Git**, to clone and version the project.
- **GNU Make.** Ships with macOS and Linux. On Windows, run the commands from **Git Bash**, **WSL**, or **MSYS2**, which provide `make` together with `rm`, `mv`, and `find`.
- **An analysis engine:** Stata (with the `estout` package: run `ssc install estout` once), or R (with the `sandwich` package), or just Quarto + R (`code.qmd` also uses `tibble` and `modelsummary`).
- **Quarto**, to render the drafts and the Quarto report.
- **A LaTeX distribution** for the PDFs. [TinyTeX](https://yihui.org/tinytex/) is the easiest (`quarto install tinytex`). The slides use **xelatex** for the custom fonts.
- **R packages for rendering Quarto:** `rmarkdown` and `knitr` (Quarto's knitr engine needs them). Install with `install.packages(c("rmarkdown", "knitr"))`. The scripts install their own analysis packages automatically, including `haven` when the drafts render from Stata's `.dta` output.

---

Maintained by [Victor van Pelt](https://www.victorvanpelt.com). Reuse and adapt freely.
