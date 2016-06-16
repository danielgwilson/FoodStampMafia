setwd("~/GitHub/FoodStampMafia")
rm(list=ls())
raw_FoodStamps <- read.csv("ACS_10_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,]
raw_AgeSex <- read.csv("ACS_10_5YR_S0101_with_ann.csv", stringsAsFactors = FALSE)
raw_AgeSex <- raw_AgeSex[-1,]
raw_SNAP <- read.csv("daniel.csv", stringsAsFactors = FALSE)
raw_Poverty <- read.csv("ACS_10_5YR_S1703_with_ann.csv", stringsAsFactors = FALSE)
raw_Poverty <- raw_Poverty[-1,]

# build main model dataset
model <- data.frame(matrix(nrow = 3143))
model$FIPS <- raw_FoodStamps$GEO.id2
model[1] <- NULL
model$County <- raw_FoodStamps$GEO.display.label

model$State <- sub(' ', '', sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][2]}))
model$County <- sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][1]})

model <- merge(model, data.frame(
  FIPS = raw_SNAP$FIPS,
  Population = raw_SNAP$Population),
  by.x = 1,
  by.y = 1)
model$Population <- as.numeric(gsub(',', '', as.character(model$Population)))
summary(model$Population)

model <- merge(model, data.frame(
  FIPS = raw_SNAP$FIPS,
  SNAP_Eligible = raw_SNAP$Poverty_Sub125),
  by.x = 1,
  by.y = 1
)

model <- merge(model, data.frame(
  FIPS = raw_SNAP$FIPS,
  SNAP_Recipients= raw_SNAP$SNAP_Recipients),
  by.x = 1,
  by.y = 1
)

model <- merge(model,
               data.frame(
                 FIPS = raw_AgeSex$GEO.id2,
                 Total_Over60 = ((as.numeric(raw_AgeSex$HC01_EST_VC15) + as.numeric(raw_AgeSex$HC01_EST_VC16) + as.numeric(raw_AgeSex$HC01_EST_VC17) 
                   + as.numeric(raw_AgeSex$HC01_EST_VC18) + as.numeric(raw_AgeSex$HC01_EST_VC19) + as.numeric(raw_AgeSex$HC01_EST_VC20))
                   / 100 * as.numeric(raw_AgeSex$HC01_EST_VC01))),
  by.x = 1, 
  by.y = 1
  )

model <- merge(model, data.frame(
  FIPS = raw_FoodStamps$GEO.id2,
  SNAP_Over60 = as.numeric(raw_FoodStamps$HC02_EST_VC02) / 100 * as.numeric(raw_FoodStamps$HC02_EST_VC01)),
  by.x = 1,
  by.y = 1
  )

# People over 65 years old that are less than 125% of the poverty level
# HC01_EST_VC10 is the total amount of people who are over 65 years and in poverty 
model <- merge(model, data.frame(
  FIPS = raw_Poverty$GEO.id2,
  SNAPEligible_Over60 = as.numeric(raw_Poverty$HC04_EST_VC10) / 100 * as.numeric(raw_Poverty$HC01_EST_VC10)),
  by.x = 1,
  by.y = 1
)

