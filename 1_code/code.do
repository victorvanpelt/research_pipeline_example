//clear everything to ensure nothing came before
clear all

//go to the main director
capture cd 1_code   // if we're at the project root, step into 1_code (otherwise nothing)
cd ..               // now we're guaranteed to be at the project root

//import raw data and store as input data file in process-folder
// also for merging data
import delimited "0_data\gen_ai_earnings.csv"
save "2_process\gen_ai_earnings.dta", replace

//import input data, transform the data, and save as edited data
clear all
use "2_process\gen_ai_earnings.dta", replace

gen earnings_scaled = earnings / 10
drop if earnings_scaled<0

save "2_process\edit_gen_ai_earnings.dta", replace

//import edited data, conduct analysis to generate output
clear all
use "2_process\edit_gen_ai_earnings.dta"

//Run a basic regression and store results (must run ssc install estout first!)
eststo: regress earnings_scaled gen_ai, r

//Generate output file (.rtf file)
esttab using "3_output\Table 1stata.rtf", ///
replace stats(r2 F p df_m N) b(3) aux(se 3) star(* 0.10 ** 0.05 *** 0.01) obslast onecell nogaps ///
compress title(TABLE 1 - REGRESSIONS OF SCALED EARNINGS ON GENERATIVE AI) addnotes(p-levels are two-tailed, * p < 0.10, ** p < 0.05, *** p < 0.01; the numbers within the round parentheses are robust standard errors.) nonotes
eststo clear

//close stata
exit, STATA clear