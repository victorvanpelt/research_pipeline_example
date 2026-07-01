# ==========================================================================
#  Research pipeline - build tasks
#
#  Usage:
#    make            run the R analysis, then build the paper and the slides
#    make r          run the R analysis          (1_code/code.r)
#    make stata      run the Stata analysis       (1_code/code.do)
#    make quarto     render the self-contained Quarto report (1_code/code.qmd)
#    make paper      render the paper             (4_drafts/paper_example.qmd)
#    make slides     render the slides            (4_drafts/presentation_example.qmd)
#    make clean      delete everything the pipeline generates
#    make help       list the targets
#
#  Tools are overridable, e.g.:  make r RSCRIPT=/path/to/Rscript
#  Forward slashes work on every OS. On Windows, run this from Git Bash / WSL /
#  MSYS2, which provide make together with rm, mv, and find.
# ==========================================================================

# Tools (override on the command line or via environment variables)
RSCRIPT ?= Rscript
STATA   ?= stata-se
QUARTO  ?= quarto

.DEFAULT_GOAL := all
.PHONY: all r stata do quarto paper slides clean help

# Default build: run the R analysis, then render the paper and slides.
all: r paper slides

# --- Analysis engines (pick whichever one you use) -----------------------
r:
	$(RSCRIPT) --vanilla 1_code/code.r

# On Windows Stata the batch flag is "/e" instead of "-b".
stata do:
	$(STATA) -b do 1_code/code.do
	@rm -f code.log 1_code/code.log

quarto:
	$(QUARTO) render 1_code/code.qmd

# --- Manuscript and slides (consume 2_process and 3_output) --------------
# Run `make r` (or `make stata`) first so the inputs they read exist.
paper:
	$(QUARTO) render 4_drafts/paper_example.qmd

slides:
	$(QUARTO) render 4_drafts/presentation_example.qmd

# --- Housekeeping --------------------------------------------------------
# Delete everything in 2_process and 3_output except the .gitkeep files,
# plus stray render artifacts, so a fresh `make` reproduces every output.
clean:
	@find 2_process 3_output -type f ! -name '.gitkeep' -delete
	@rm -f 1_code/code.pdf 4_drafts/*.pdf *.log 1_code/*.log
	@echo "Cleaned 2_process, 3_output, and render artifacts."

help:
	@echo "Targets: all (default), r, stata, quarto, paper, slides, clean"
