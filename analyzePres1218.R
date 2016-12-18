### Use wranglePres to create all.data data frame first
require(ggrepel)
require(stringr)

# Read data
all.data <- read.csv("data/mergedPres.csv")

## Write function to make plots:

plot.pres <- function(data, cand, data.col,size.col) {
  
  d.name <- gsub(".", " ", colnames(data)[data.col], fixed= TRUE)
  s.name <- gsub(".", " ", colnames(data)[size.col], fixed= TRUE)
  cand.col <- which(colnames(data)==cand)
  
  p <- ggplot(data, aes(x=data[,cand.col], y = data[,data.col], colour = winner.clean),
              environment = environment())
  
  p <- p + geom_point(aes(size=data[,size.col]), alpha = .25) +
       geom_text_repel(aes(label=st), size = 2.5) +
      labs (x = paste(cand, " vote share"), y = d.name) +
      guides(colour=guide_legend(title="2016 Winner"), size=guide_legend(title = s.name)) +
      geom_smooth(method="lm") +
      theme_bw()
              
  print(p)
  return(p)
}

### Graph to find out whether there is a correlation between demographic variables and voting outcomes

  #How to size points?
  sizeCol <- match("totalPop", names(all.data))


  # % people with college degree: Clear negative association with % Trump support

    # Match by regex for first letters in name:
    dataCol <- which(str_detect(names(all.data),"^Educ"))
    (plot.pres(all.data, "Trump", dataCol, sizeCol))
    

  # Birth health: Clear negative association with % Trump support
    
    # Match by name:
    dataCol <- match("Infant.deaths.per.1.000.live.births.2007", names(all.data))
    (plot.pres(all.data, "Trump", dataCol, sizeCol))
    
  # Percent pop below poverty level: Pos association in states where Trump won: 
    
    # Match by regex:
    dataCol <- which(str_detect(names(all.data),"Population.below"))
    (plot.pres(all.data, "Trump", dataCol, sizeCol))
  
  # % Foreign born: Clear negative association with % Trump support
    
    # Match by regex:
    dataCol <- which(str_detect(names(all.data),"Place.of.birth"))
    (plot.pres(all.data, "Trump", dataCol, sizeCol))
    
  # Per capita personal income: Clear negative association with % Trump support
    
    # Match by regex:
    dataCol <- which(str_detect(names(all.data),"Median"))
    (plot.pres(all.data, "Trump", dataCol, sizeCol))


  # Federal govt expenditure per capita: Neg association where Clinton won, Pos where Trump won. 
    
    # Match by regex:
    dataCol <- which(str_detect(names(all.data),"Federal.Government"))
    (plot.pres(all.data, "Trump", dataCol, sizeCol))
    
