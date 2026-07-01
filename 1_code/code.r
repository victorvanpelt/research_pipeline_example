# Clear everything
rm(list = ls()); invisible(gc())

# Use CRAN mirror (needed when running via Rscript / make)
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Move to the project root whether we start there or inside 1_code
if (dir.exists(file.path(getwd(), "1_code"))) setwd(file.path(getwd(), "1_code"))
setwd("..")
ROOT <- getwd()

# Packages: sandwich gives heteroskedasticity-robust SE; everything else is base R
need <- c("sandwich")
to_install <- setdiff(need, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)  # repos taken from options()
invisible(lapply(need, require, character.only = TRUE))

# Paths (forward slashes work on every OS)
path_csv   <- file.path(ROOT, "0_data",    "gen_ai_earnings.csv")
path_proc  <- file.path(ROOT, "2_process", "gen_ai_earnings.rds")
path_edit  <- file.path(ROOT, "2_process", "edit_gen_ai_earnings.rds")
path_table <- file.path(ROOT, "3_output",  "table_1.tex")

dir.create(file.path(ROOT, "2_process"), showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(ROOT, "3_output"),  showWarnings = FALSE, recursive = TRUE)

# 1. Import the raw CSV and store an untouched copy in 2_process
df <- read.csv(path_csv)
saveRDS(df, path_proc)

# 2. Reload, transform, and save the edited data (kept separate from the raw copy)
rm(df); invisible(gc())
df <- readRDS(path_proc)

df$earnings_scaled <- df$earnings / 10
df <- df[df$earnings_scaled >= 0, , drop = FALSE]   # drop the negative scaled earnings

saveRDS(df, path_edit)

# 3. Reload the edited data and run the analysis
rm(df); invisible(gc())
df <- readRDS(path_edit)

mod <- lm(earnings_scaled ~ gen_ai, data = df)
vc  <- sandwich::vcovHC(mod, type = "HC1")          # robust SE, matches Stata's ", r"

# 4. Write a LaTeX table to 3_output that the paper and slides can \input.
#    A plain booktabs table only needs \usepackage{booktabs} and mirrors the
#    Stata esttab output, so either engine produces an interchangeable table_1.tex.
b    <- coef(mod)
se   <- sqrt(diag(vc))
tval <- b / se
n    <- as.integer(nobs(mod))
pval <- 2 * pt(-abs(tval), df = n - length(b))
r2   <- summary(mod)$r.squared
Fst  <- unname(tval["gen_ai"]^2)                    # robust Wald F for the single slope
Fp   <- pf(Fst, 1, n - length(b), lower.tail = FALSE)

stars <- function(p) if (p < .01) "***" else if (p < .05) "**" else if (p < .10) "*" else ""
f3    <- function(x) formatC(x, format = "f", digits = 3)

tex <- c(
  "\\begin{table}[htbp]\\centering",
  "\\caption{TABLE 1 - REGRESSIONS OF SCALED EARNINGS ON GENERATIVE AI}",
  "\\begin{tabular}{lc}",
  "\\toprule",
  " & earnings\\_scaled \\\\",
  "\\midrule",
  sprintf("gen\\_ai & %s%s \\\\",   f3(b["gen_ai"]),       stars(pval["gen_ai"])),
  sprintf(" & (%s) \\\\",           f3(se["gen_ai"])),
  "\\addlinespace",
  sprintf("Constant & %s%s \\\\",   f3(b["(Intercept)"]),  stars(pval["(Intercept)"])),
  sprintf(" & (%s) \\\\",           f3(se["(Intercept)"])),
  "\\midrule",
  sprintf("Observations & %d \\\\", n),
  sprintf("$R^2$ & %s \\\\",        f3(r2)),
  sprintf("F & %s \\\\",            f3(Fst)),
  sprintf("p & %s \\\\",            f3(Fp)),
  "\\bottomrule",
  "\\end{tabular}",
  "\\par\\vspace{0.4em}",
  "\\parbox{0.6\\textwidth}{\\footnotesize \\emph{Notes.} Robust standard errors in parentheses. $^{*}\\,p<0.10$, $^{**}\\,p<0.05$, $^{***}\\,p<0.01$.}",
  "\\end{table}"
)
writeLines(tex, path_table)

# Exit
q(save = "no")
