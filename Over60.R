setwd("~/GitHub/FoodStampMafia")
rm(list=ls())
raw_FoodStamps <- read.csv("ACS_14_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,]
raw_AgeSex <- read.csv("ACS_10_5YR_S0101_with_ann.csv", stringsAsFactors = FALSE)
raw_AgeSex <- raw_AgeSex[-1,]
raw_SNAP <- read.csv("snap_data.csv", stringsAsFactors = FALSE)

# build main model dataset
model <- data.frame(matrix(nrow = 3142))
model$FIPS <- raw_FoodStamps$GEO.id2
model[1] <- NULL
model$County <- raw_FoodStamps$GEO.display.label

model$State <- sub(' ', '', sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][2]}))
model$County <- sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][1]})

