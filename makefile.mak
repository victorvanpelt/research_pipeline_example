# Default goal is run. So you can just type "make"
.DEFAULT_GOAL := run

# Paths (insert your local paths or environmental variable)
STATA   := $(STATA)
RSCRIPT := $(RSCRIPT)
QUARTO  := $(QUARTO)

# code variables
DOFILE = 1_code\code.do
RFILE   = 1_code\code.r
QMD     = 1_code\code.qmd

# run command runs the stata code
run: do

# Stata code. Run with "make do". Last line removes the log file.
do: $(DOFILE)
	"$(STATA)" /e /q do $(DOFILE) > NUL 2>&1
	@cmd /c "if exist "*.log"  del /q /f "*.log" 

# R code. Run with "make r"
r:
	"$(RSCRIPT)" --vanilla --quiet "$(RFILE)" >NUL 2>&1

# Quarto code. Run with "make quarto." Immediately removes quarto.html after running and moves code.pdf to 3_output
quarto:
	"$(RSCRIPT)" --vanilla --quiet "$(RFILE)" >NUL 2>&1
	"$(QUARTO)" render "$(QMD)" --execute --embed-resources
	@cmd /c "if exist "1_code\code.pdf" move "1_code\code.pdf" "3_output\code.pdf"

# housekeeping to remove stuck logfiles, quarto files, and clear process and output folders. Run with "make clean"
clean:
	@cmd /c "if exist "*.log"  del /q /f "*.log"
	@cmd /c "if exist "*.smcl"  del /q /f "*.smcl"
	@cmd /c "if exist "1_code\code.html" del "1_code\code.html""

	@cmd /c powershell -NoLogo -NoProfile -Command "If(!(Test-Path '2_process')){New-Item -ItemType Directory -Path '2_process' | Out-Null}; Get-ChildItem -LiteralPath '2_process' -Force | Where-Object Name -ne '.gitkeep' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; If(!(Test-Path '2_process\.gitkeep')){ 'keep' | Out-File -NoNewline '2_process\.gitkeep' -Encoding ascii }"
	@cmd /c powershell -NoLogo -NoProfile -Command "If(!(Test-Path '3_output')){New-Item -ItemType Directory -Path '3_output' | Out-Null}; Get-ChildItem -LiteralPath '3_output' -Force | Where-Object Name -ne '.gitkeep' | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; If(!(Test-Path '3_output\.gitkeep')){ 'keep' | Out-File -NoNewline '3_output\.gitkeep' -Encoding ascii }"

# Phony targets. Type "make r," "make do," or "make clean"
.PHONY: run do r quarto clean