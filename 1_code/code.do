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

//Write the data appendix output: summary statistics and distribution figures
//for the analysis data, written to 3_output/data_appendix and assembled into
//a document by 4_drafts/data_appendix_example.qmd.
capture mkdir "3_output/data_appendix"

//summary statistics for the quantitative variables
estpost tabstat earnings earnings_scaled, statistics(count mean sd min p25 p50 p75 max) columns(statistics)
esttab using "3_output/data_appendix/summary_stats.tex", replace booktabs ///
    cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3)) max(fmt(3))") ///
    nonumber nomtitle nonote noobs
eststo clear

//frequency table for the categorical variable
estpost tabulate gen_ai
esttab using "3_output/data_appendix/freq_gen_ai.tex", replace booktabs ///
    cells("b(fmt(0)) pct(fmt(1))") collabels("Frequency" "Percent") ///
    nonumber nomtitle noobs
eststo clear

//distribution figures: histograms for the quantitative variables, a bar
//chart for the categorical one
histogram earnings, color(gs12)
graph export "3_output/data_appendix/hist_earnings.png", replace width(1400)
histogram earnings_scaled, color(gs12)
graph export "3_output/data_appendix/hist_earnings_scaled.png", replace width(1400)
graph bar (count), over(gen_ai) bar(1, color(gs12)) ytitle("Frequency")
graph export "3_output/data_appendix/bar_gen_ai.png", replace width(1400)

//close stata
exit, STATA clear
