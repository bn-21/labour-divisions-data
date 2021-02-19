# labour-divisions-data
Contains results of how all Labour MPs voted in all divisions in the UK House of Commons from 2001 to 23/03/2016.

## Why are you reading this?
The data for this comes from Hansard, using the R package `hansard`. This requires Hansard's API being accessed for every division -- and given that there are over 3700 divisions, this isn't very computationally efficient! It took me over an hour to run.

The `lab-divisions.csv` dataset is all you need from here. However, if you are interested in replication, you can view the R file as well.
