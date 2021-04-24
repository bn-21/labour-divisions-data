# labour-divisions-data
Contains results of how all Labour MPs voted in all divisions in the UK House of Commons in the 2015-17 Parliament.

## Why are you reading this?
The data for this comes from Hansard, using the R package `hansard`. This requires Hansard's API being accessed for every division, which takes around eight minutes to run.

The `lab-divisions.csv` dataset is all you need from here. However, if you are interested in replication, you can view the `R` file as well (`data_reading.R`). I have also uploaded my bibliography file (`EC340.json`) and the CSL theme used to compile the bibliography (`harvard-cite-them-right.csl`). These are required when knitting the final `R` Markdown file to HTML.
