# Data Management Example
 This repository gives a simple example on how to manage data and structure analyses, so it can easily be shared on github and use version control. The repository uses Stata, R, and Quarto to illustrate how everything functions. However, it should work with any type of coding and analysis language.

## Repository structure
 It has the following folders:
 - 0_data: stores the raw data, but does not share it in the repository.
 - 1_code: stores the code files which are shared in the repository.  
 - 2_process: stores temporary output/ passing output between code. Also, does not share it in the repository using a gitignore file  
 - 3_output: contains output such as tables and figures  

 There are other folders you can consider adding:
 - #_external: used for storing copies or data and/or code to be shared  
 - #_slides: stores the slides for talks  
 - #_docs: stores the drafts of papers  
