# County Data
setwd("~/Google Drive/Booz/Counties")
raw_FoodStamps <- read.csv("ACS_14_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,]
raw_Poverty <- read.csv("ACS_14_5YR_C17002_with_ann.csv", stringsAsFactors = FALSE)
raw_Poverty <- raw_Poverty[-1,]

# build main model dataset
model <- data.frame(matrix(nrow = 3142))
model$GEO.id <- raw_FoodStamps$GEO.id2
model$County <- raw_FoodStamps$GEO.display.label
model$TotalHouseholds <- raw_FoodStamps$HC01_EST_VC01
model$SNAP_Households <- raw_FoodStamps$HC02_EST_VC01
model$Poverty_Sub100 <- as.numeric(raw_Poverty$HD01_VD02) + as.numeric(raw_Poverty$HD01_VD03)
model[1] <- NULL

# engineered features
model$SNAP_ParticipationRate <- as.numeric(model$SNAP_Households) / as.numeric(model$TotalHouseholds)
model$SNAP_FillRate <- as.numeric(model$SNAP_Households) / as.numeric(model$Poverty_Sub100)

# state filter
state_FIPS <- read.csv("state_fips.csv", stringsAsFactors = FALSE)
as.numeric(substring(model$GEO.id[1],1,2))
model$State <- NA
state_FIPS <- state_FIPS[order(as.factor(state_FIPS$FIPS)), ]


# county with a specific SNAP_Participation_Rate
model$County[findInterval(0.5278107, model$SNAP_Participation_Rate[order(as.factor(model$SNAP_Participation_Rate))])]
countyWithRatio <- function(x) {
  result <- model$County[findInterval(x, model$SNAP_Participation_Rate[order(as.factor(model$SNAP_Participation_Rate))])]
  return(result)
}

countyWithRatio(0.5278107)
