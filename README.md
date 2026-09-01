# Research Pipeline Example

A template for a reproducible research project: raw data go in, one command runs the analysis and builds the paper and the slides, and every number and table in those documents comes from the code. `make` rebuilds everything in the right order, from raw data to finished PDF, and the drafts are written in [Quarto](https://quarto.org), so they read results from the analysis rather than hard-coding them. Edit the code, run `make`, and every number, table, and document updates together; nothing is copied by hand, so nothing goes stale.

The pipeline is a starting point for empirical research projects. The example uses Stata, R, and Quarto, but the structure works with any language.

The folder structure follows the [TIER Protocol](https://www.projecttier.org/tier-protocol/protocol-4-0/), a widely used standard for documenting reproducible research.

## Repository structure

```
research_pipeline_example/
├── 0_data/                        raw inputs (real raw data is NOT shared)
│   ├── gen_ai_earnings.csv        small synthetic dataset so the example runs
│   └── codebook.md                what each variable means and its type
├── 1_code/                        analysis code (shared; the heart of the repo)
│   ├── code.do                    Stata
│   ├── code.r                     R
│   └── code.qmd                   Quarto version of the R code
├── 2_process/                     intermediate / passing data between steps (NOT shared)
├── 3_output/                      shared outputs: tables and figures
│   ├── table_1.tex                written by the analysis, read by the drafts
│   └── data_appendix/             stats and figures for the data appendix
├── 4_drafts/                      the documents; each .qmd renders to a committed .pdf
│   ├── paper.qmd             	   the manuscript
│   ├── presentation.qmd   		   the slides
│   ├── data_appendix.qmd		   the data appendix (describes the analysis data)
│   ├── references.bib             bibliography for the drafts
│   └── materials/                 beamer theme, logo, fonts for the slides
├── Makefile                       build tasks (the pipeline)
├── AGENTS.md                      rules for AI coding agents working in this repo
├── LICENSE          		       MIT license
├── .gitignore                     what is and is not version-controlled
├── .gitattributes   			   normalizes line endings across operating systems
└── README.md        			   this file
```

The folders are numbered in the order data flow through them: `0_data → 1_code → 2_process → 3_output → 4_drafts`.

Other folders you might add as a project grows:

- `#_external` for copies of data or code shared with you by others,
- `#_slides` if you want to separate talks from paper drafts,
- `#_docs` for notes, memos, or referee correspondence.

## Workflow

```
0_data/gen_ai_earnings.csv   (in 0_data/codebook.md)
        │
        ▼
1_code  (run ONE engine: code.r | code.do | code.qmd)
        │
        ├──► 2_process/gen_ai_earnings.(rds|dta)        copy of raw data
        ├──► 2_process/edit_gen_ai_earnings.(rds|dta)   edited analysis data
        ├──► 3_output/table_1.tex                       shared table
        └──► 3_output/data_appendix/                    appendix stats + figures
                    │
                    ▼   (files read from 2_process and 3_output)
        ├──► 4_drafts/paper.qmd          ─► paper.pdf
        ├──► 4_drafts/presentation.qmd   ─► presentation.pdf
        └──► 4_drafts/data_appendix.qmd  ─► data_appendix.pdf
```

## Three analysis engines

`1_code` holds the same analysis written three ways. All three produce matching results, so use whichever fits your workflow.


| File       | Language | What it does                                                                           |
| ------------ | ---------- | ---------------------------------------------------------------------------------------- |
| `code.do`  | Stata    | import → transform → regress (robust SE) → write`3_output/table_1.tex` via `esttab`    |
| `code.r`   | R        | same, in base R +`sandwich`; also saves intermediate data to `2_process`               |
| `code.qmd` | Quarto   | a self-contained report that builds the table inline                                   |

The analysis itself is deliberately trivial: regress a scaled earnings measure on a generative-AI indicator, with heteroskedasticity-robust standard errors. All three engines write the data appendix's statistics and figures to `3_output/data_appendix/`; `4_drafts/data_appendix.qmd` assembles them into a short document describing the analysis data variable by variable.

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

This runs the R analysis and then renders the data appendix, the paper, and the slides. Open the results in `4_drafts/`. The build logic is in the `Makefile` at the repo root.

## Make targets


| Command                | Result                                                                                 |
| ------------------------ | ---------------------------------------------------------------------------------------- |
| `make` (or `make all`) | run the R analysis, then render the data appendix, the paper, and the slides           |
| `make r`               | run the R analysis (`1_code/code.r`)                                                   |
| `make stata`           | run the Stata analysis (`1_code/code.do`)                                              |
| `make quarto`          | render the self-contained Quarto report (`1_code/code.qmd`)                            |
| `make appendix`        | render the data appendix (`4_drafts/data_appendix.qmd`)                                |
| `make paper`           | render the paper (`4_drafts/paper.qmd`)                                                |
| `make slides`          | render the slides (`4_drafts/presentation.qmd`)                                        |
| `make clean`           | delete everything the pipeline generates, so the next`make` reproduces it from scratch |
| `make help`            | list the targets                                                                       |

`make` (with no target) runs everything in the right order. If you build a single document, run `make r` (or `make stata`) first, because the drafts read the files those steps write.

If a tool is not on your `PATH`, point `make` to it:

```bash
make r      RSCRIPT=/usr/local/bin/Rscript
make stata  STATA="/usr/local/stata18/stata-se"
make paper  QUARTO=/opt/quarto/bin/quarto
```

## Version control and data hygiene

The `.gitignore` uses an *ignore-everything-then-allow* strategy: it ignores all files, then explicitly re-includes only what should be shared. This makes it easy to reason about what leaves your machine.


| Folder      |            Shared in git?            | Why                                                                                                                                                |
| ------------- | :-------------------------------------: | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `0_data`    |  the synthetic CSV and its codebook  | **Real raw data should not be shared.** Drop your own data here; it stays ignored. The synthetic file is a teaching exception so the example runs. |
| `1_code`    |                  yes                  | Code is the reproducible core of the project.                                                                                                      |
| `2_process` |                  no                  | Intermediate files are large and disposable; they are regenerated by the code.                                                                     |
| `3_output`  |                  yes                  | Final tables and figures, so collaborators and readers can see results without rerunning.                                                          |
| `4_drafts`  | sources, materials, and rendered PDFs | The`.qmd`/`.bib` sources plus the built PDFs; render intermediates (`.tex`, `.aux`, `_files/`) stay ignored.                                       |

Each folder keeps a `.gitkeep` file so the (otherwise empty) folder still exists after a fresh clone.

## Adapting this to your own project

1. Replace `0_data/gen_ai_earnings.csv` with your data (and keep real raw data out of git). Update `0_data/codebook.md` so every variable and the data's origin stay documented.
2. Edit the transform and analysis in your engine of choice in `1_code`. Write your tables and figures to `3_output`.
3. In `4_drafts`, write your paper and slides so they read from `2_process` and `3_output` instead of hard-coding numbers.
4. Keep the folder discipline. When in doubt: raw data in `0_data`, code in `1_code`, throwaway files in `2_process`, results you keep in `3_output`, writing in `4_drafts`.

## AI coding agents

This repository ships no tooling for AI agents, because setups differ across users and the technology changes quickly. Instead, `AGENTS.md` states the rules AI coding agents must follow in this repository. Most agentic coding tools read it automatically; Claude Code and Gemini CLI do not yet. If you use either, run one command once in this folder to point it at the file: `echo '@AGENTS.md' > CLAUDE.md` for Claude Code, or `echo '@./AGENTS.md' > GEMINI.md` for Gemini CLI. The pointer files stay on your machine because `.gitignore` excludes them, so the repository ships only `AGENTS.md`.

The rules keep AI within the pipeline's discipline: raw data in `0_data` are read-only (the hand-maintained `0_data/codebook.md` is the one exception), files in `2_process` and `3_output` are build artifacts only the code may write, and agents never perform research tasks themselves, never commit, and never push. Every change therefore stays in the working tree for you to review. A change counts as done only when `make clean` followed by `make` rebuilds every output without errors.

Because every number in the drafts is generated by the pipeline, you check an agent's work by rerunning the pipeline and reading the diff, not by proofreading the paper. The two commands that keep you in charge are `make` and `git diff`.

**Try it.** Open your coding agent in this folder and ask it to winsorize `earnings_scaled` at the 1st and 99th percentiles in whichever engine you use. It should state a short plan, edit `1_code/`, rerun the pipeline, and report the rebuild. Then rerun it yourself with `make clean && make`, read `git diff` (code and tables diff line by line; figures and rebuilt PDFs show as binary changes), and decide what to commit.

## Requirements

You do not need everything below; install what your chosen engine and outputs require.

- **Git**, to clone and version the project.
- **GNU Make.** Ships with macOS and Linux. On Windows, run the commands from **Git Bash**, **WSL**, or **MSYS2**, which provide `make` together with `rm`, `mv`, and `find`.
- **An analysis engine:** Stata (with the `estout` package: run `ssc install estout` once), or R (with the `sandwich` package), or just Quarto + R (`code.qmd` also uses `tibble` and `modelsummary`).
- **Quarto**, to render the drafts and the Quarto report.
- **A LaTeX distribution** for the PDFs. [TinyTeX](https://yihui.org/tinytex/) is the easiest (`quarto install tinytex`). The slides use **xelatex** for the custom fonts.
- **R packages for rendering Quarto:** `rmarkdown` and `knitr` (Quarto's knitr engine needs them). Install with `install.packages(c("rmarkdown", "knitr"))`. The scripts install their own analysis packages automatically, including `haven` when the drafts render from Stata's `.dta` output.

---

Maintained by [Victor van Pelt](https://www.victorvanpelt.com). Released under the [MIT License](LICENSE): reuse and adapt freely, as long as the copyright and license notice stay with copies. Third-party files in `4_drafts/materials/` (the Helvetica Neue fonts) keep their own licenses.
