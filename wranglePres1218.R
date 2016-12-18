### Analysis of statewide demographic factors and their association with candidate vote shares 
### 2016 US General Election

# Demographic data from http://censtats.census.gov/usa/usa.shtml 
# Aggregate state winner data from https://ballotpedia.org/Presidential_candidates,_2016

### Init
require(tidyverse)
require(stringr)

### Read in winners 2012 2016 data
  winners <- read.csv("data/stateWinners.csv")  
  str(winners)
  # Extract name of winner and margin of victory, convert state names to abbreviations using 
  # built-in state.abb
  winners <- winners %>%
                    filter(State != "Washington, D.C.") %>%
                    mutate(winner.clean = str_extract(Winner2016, "[A-z]+"),
                      winner.margin = str_extract(Winner2016, "\\+[0-9]+\\.[0-9]\\%"),
                      Clinton = as.numeric(str_extract(Clinton,"^[0-9]+\\.[0-9]+")) / 100,
                      Trump   = as.numeric(str_extract(Trump  ,"^[0-9]+\\.[0-9]+")) / 100,
                      Obama   = as.numeric(str_extract(Obama  ,"^[0-9]+\\.[0-9]+")) / 100,
                      Romney   = as.numeric(str_extract(Romney  ,"^[0-9]+\\.[0-9]+")) / 100,
                      st = state.abb)

### Linear model to predict Clinton's votes based on Obama's
  cm1 <- lm(Clinton ~ Obama, data = winners)
  summary(cm1) # r-squared = 0.9175; Massive association between %votes for Obama and for Clinton 
  
  
### Read in demographics Data
  setwd("states")
  st.file.names <- dir()
  
  # get the state abbreviations out of the filenames (inclludin DC with this approach)
  st.abbreviations <- unlist(map(st.file.names, str_extract, "^[a-z]+"))
  
  # load demographics data into memory,as a list.
  states.list <- map(st.file.names, read.table, header = TRUE, sep=",", 
                                               skip = 5, blank.lines.skip = TRUE, 
                                               col.names = c("Description", "Data", "Footnote", "Unit"), 
                                               nrows=64)
  setwd("..")
  
  # 1. write function to add column
  add.column <- function(data, value, col.name = "xxxxx") {
    data[[col.name]] <- value
    return(data)
  }
  
  # 2. map the function to each element of our lists of data.frames
  states.list <- map2(states.list, st.abbreviations, add.column, col.name = "st")
  
  # 3. Start reorganising into a tidy df (1 row per state). Initialise
  demo.data <- data.frame(matrix(nrow=length(states.list), ncol=nrow(states.list[[1]])+1))  
  colnames(demo.data) <- c("st", as.character(states.list[[1]][[1]]))
  
  # 4. Iterate over all the states
  for (i in 1:length(states.list)) {
    demo.data$st[i] <- toupper(states.list[[i]][[5]][[1]])
    demo.data[i,2:ncol(demo.data)] <- states.list[[i]][[2]]
  }
  
  # Make all the columns containing numbers be numeric:
  demo.data <- cbind(demo.data[1], sapply(demo.data[2:ncol(demo.data)], as.numeric))            
  # Some NA's introduced by coercion; this col will be removed later
  
### Far too many variables. Let's find some way of reducing dimensionality:
  View(demo.data)
  
  # It looks like all of the 'latest' data points are either 2007, 2009, 2010. 
  # Select only columns that contain those years (and state id):
  demo.data <- demo.data %>% select(st, contains("2007"), contains("2009"), contains("2010"))
  
  # Some columns are almost direct matches for one another. Remove by hand (for now):
  names(demo.data)
  demo.data <- demo.data %>% select(-c(3, 4, 5, 16, 17, 19, 21, 22, 23, 32))
  
  
### Feature engineering  
  # All columns that are not summarized in some manner (median, percent,per capita), need to be:
  
  # First rename the total population column for easy manipulation:
  colnames(demo.data)[24] <- "totalPop"
  
  # Scale each col that is not already a percent, or per, or median, by the total pop:
  demo.data <- demo.data %>%
      mutate_each(funs(./totalPop), -totalPop, -st, -contains("percent"), -contains("per "), -contains("median"))
  

### Merge voting and demographic data:
  all.data <- merge(winners, demo.data, by = "st")
  
  # Save for next analysis
  write.csv(all.data, file ="data/mergedPres.csv")
