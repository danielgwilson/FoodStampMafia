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

model <- merge(model, data.frame(
  FIPS = raw_SNAP$FIPS,
  Population = raw_SNAP$POP10),
  by.x = 1,
  by.y = 1)
model$Population <- as.numeric(gsub(',', '', as.character(model$Population)))
summary(model$Population)

#Total Children under 18 
model <- merge(model, 
               data.frame(
                 FIPS = raw_AgeSex$GEO.id2,
                 TotalChildren_Under18 = ((as.numeric(raw_AgeSex$HC01_EST_VC03) + as.numeric(raw_AgeSex$HC01_EST_VC04) + as.numeric(raw_AgeSex$HC01_EST_VC05) + as.numeric(raw_AgeSex$HC01_EST_VC06))
                                          / 100 * as.numeric(raw_AgeSex$HC01_EST_VC01))
                 ),
               by.x = 1,
               by.y = 1)

model <- merge(model, data.frame(
  FIPS = raw_SNAP$FIPS,
  SNAP_Recipients = raw_SNAP$PRGNUM10),
  by.x = 1,
  by.y = 1)

# SNAP households with children under 18
model <- merge(model,
               data.frame(
                 FIPS = raw_FoodStamps$GEO.id2,
                 SNAP_Under18 = as.numeric(raw_FoodStamps$HC02_EST_VC03) / 100 * as.numeric(raw_FoodStamps$HC02_EST_VC01)
                 ),
               by.x = 1,
               by.y = 1
)

# % of SNAP households that are under 18 
model$SNAP_Recipients <- sub(',', '', model$SNAP_Recipients)
model <- merge(model,data.frame(
  FIPS = model$FIPS,
  SNAP_Under18Ratio = as.numeric(model$SNAP_Under18) / as.numeric(model$SNAP_Recipients)
    ),
    by.x = 1,
    by.y = 1
)

# SNAP households under 18 divided by Total Population that is under 18
model <- merge(model,data.frame(
  FIPS = model$FIPS,
  SNAP_Under18PopRatio = (as.numeric(model$SNAP_Under18) / as.numeric(model$TotalChildren_Under18)
  )),
  by.x = 1,
  by.y = 1
)

# SNAP households under 18 divided Population of counties
model <- merge(model,data.frame(
  FIPS = model$FIPS,
  SNAP_Under18TotalPopRatio = (as.numeric(model$SNAP_Under18) / as.numeric(model$Population))
  ),
  by.x = 1,
  by.y = 1
)

