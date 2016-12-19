# election2016
Brief exploration of demographics and voting behavior by state in 2016 US General Election

This repository takes data from a couple of different sources to match (a) Election results by state, with (b) Demographic information for each state. 

Voting data for 2016 and 2012: "https://ballotpedia.org/Presidential_candidates,_2016" # Note "," in URL

Demographics data by state: http://censtats.census.gov/usa/usa.shtml

# Dependencies:
tidyverse (ggplot2, dplyr, stringr)

ggrepel: requires R >= 3.0.0, ggplot >= 2.0
 
# Feature engineering: wranglePres.R

(1) Ensure columns in voting table are either numeric or candidates (not both).

(2) Reduce number of demographics columns. Many columns are same data from different years. 

(3) A number of columns are very similar data; just keep essential ones.

(4) Scale all columns that are not per capita or percent or median by total population per state.

(5) Merge the voting and demographics data frames for analysis 

# Graphical analysis: analyzePres.R

(1) Load merged data frame back in to memory

(2) Write a ggplot function to take individual demographics, candidate, and sizing columns as inputs

(3) Create scatterplots showing relationships between demographics and percent vote share, points sized by sizing column (best is state population)

(4) Add best fit lines to make clear relationship between demographics and candidate vote share in (a) states Clinton won, and (b) states Trump won.







