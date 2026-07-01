//clear everything to ensure nothing came before
clear all

//go to the project root
capture cd 1_code   // if we're at the project root, step into 1_code (otherwise nothing)
cd ..               // now we're guaranteed to be at the project root
// Forward slashes work on Windows, macOS, and Linux.

//import raw data and store an untouched copy in the process-folder (also handy for merging)
import delimited "0_data/gen_ai_earnings.csv", clear
save "2_process/gen_ai_earnings.dta", replace

//import the raw copy, transform the data, and save the edited data
use "2_process/gen_ai_earnings.dta", clear

gen earnings_scaled = earnings / 10
drop if earnings_scaled < 0

save "2_process/edit_gen_ai_earnings.dta", replace

//import the edited data and run the analysis to generate output
use "2_process/edit_gen_ai_earnings.dta", clear

//Run a basic regression with robust SE and store results (run "ssc install estout" once first!)
eststo: regress earnings_scaled gen_ai, r

//Write a LaTeX table to 3_output that the paper and slides can \input.
//"booktabs" produces \toprule/\midrule/\bottomrule, matching the R output.
esttab using "3_output/table_1.tex", replace booktabs ///
b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(r2 F p N, fmt(3 3 3 0)) ///
title(TABLE 1 - REGRESSIONS OF SCALED EARNINGS ON GENERATIVE AI) ///
nonotes addnotes("Robust standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01.")
eststo clear

//close stata
exit, STATA clear
