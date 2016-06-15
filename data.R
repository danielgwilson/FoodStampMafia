# initial stuff like setting the working directory
setwd("~/Google Drive/Booz/FoodStampMafia")
rm(list=ls()) # clears all variables from your workspace -- same as the sweepy broom thing on the right

# load some csv files
raw_FoodStamps <- read.csv("ACS_14_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,] # deletes descriptor line -- rerun the above line without this to see descriptions
raw_Poverty <- read.csv("ACS_10_5YR_S1703_with_ann.csv", stringsAsFactors = FALSE)
raw_Poverty <- raw_Poverty[-1,]
raw_SNAP <- read.csv("snap_data.csv", stringsAsFactors = FALSE) # I didn't have to remove a descriptive line for this one


##############################
# ----------------------------
# build main model dataset
# ----------------------------
##############################
model <- data.frame(matrix(nrow = 3142)) # create an empty data frame with the correct length
model$FIPS <- raw_FoodStamps$GEO.id2 # copy the FIPS code column and make the header name FIPS
model[1] <- NULL # delete the initial empty NAs column
model$County <- raw_FoodStamps$GEO.display.label # copy the County Name, State column from the census data

# state filter -- split the County Name, State column into separate county and state columns by splitting at the comma
model$State <- sub(' ', '', sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][2]}))
model$County <- sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][1]})

# DIFFERENT NUMBER OF ROWS EXAMPLE -- use merge and a temporary two column dataframe to load in data with different lengths
# note that I did some math while loading in Poverty_Sub125. Use as.numeric to get it to read properly.
model <- merge(model, data.frame(
  FIPS = raw_Poverty$GEO.id2, 
  Poverty_Sub125 = (as.numeric(raw_Poverty$HC04_EST_VC01) / 100.0) * as.numeric(raw_Poverty$HC01_EST_VC01)), 
  by.x = 1,
  by.y = 1)

# DIFFERENT NUMBER OF ROWS EXAMPLE (simple) -- note that you can also explicitly state the reference column name "FIPS"
model <- merge(model, data.frame(
  FIPS = raw_SNAP$FIPS,
  SNAP_Recipients = raw_SNAP$PRGNUM10),
  by.x = "FIPS",
  by.y = "FIPS")

# The numbers above have COMMAS. WTF. This is annoying to deal with when calculating things, so let's get rid of them.
model$SNAP_Recipients <- as.numeric(gsub(',', '', as.character(model$SNAP_Recipients))) # gsub replaces "," with ""

# This is an engineered feature. I want a ratio of participants to possible participants.
model$SNAP_ParticipationRatio <- model$SNAP_Recipients / model$Poverty_Sub125

# Importing population data, same as above.
model <- merge(model, data.frame(
  FIPS = raw_SNAP$FIPS,
  Population = raw_SNAP$POP10),
  by.x = 1,
  by.y = 1)
# The population data also has problems with commas.
model$Population <- as.numeric(gsub(',', '', as.character(model$Population)))


# Another engineered feature -- I want a boolean that is 1 if the SNAP ratio is below 75%, and 0 if it is above.
model$SNAP_RatioSub50 <- ifelse(model$SNAP_ParticipationRatio <= 0.75, 1, 0)

# This saves your dataframe to a csv file and lets you use it elsewhere.
write.csv(model, file = "daniel.csv", row.names = FALSE)
