# County Data
setwd("C:/Users/579323/Desktop/FoodStampMafia")
raw_FoodStamps <- read.csv("ACS_14_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,]
raw_Poverty <- read.csv("ACS_14_5YR_C17002_with_ann.csv", stringsAsFactors = FALSE)
raw_Poverty <- raw_Poverty[-1,]
raw_Education <- read.csv("Educational_attainment.csv", stringsAsFactors = FALSE)
raw_Education <- raw_Education[-1,]

summary(raw_Education)
as.numeric(raw_FoodStamps$GEO.id2)
total <- merge(raw_FoodStamps, raw_Education, by.x="GEO.id2", by.y="GEO.id2", all= TRUE)
summary(raw_Poverty)
summary(raw_FoodStamps)

# Creating model
model <- data.frame(matrix(nrow = 3142))
model$FIPS <-as.numeric(raw_FoodStamps$GEO.id2)
model[1] <-NULL

#Simplest data import. Same raws, copy paste column
model$County <- raw_FoodStamps$GEO.display.label
# Raw count is DIFFERENT
model <- merge(model,
               data.frame("FIPS" = raw_Education$GEO.id2,
                          "BD" = raw_Education$Recipients.of.Bachelor.Degree.2010,
                          "HS" = raw_Education$HS.graduate..no.further.education),
               by.x="FIPS",
               by.y="FIPS", all=T)


model$BD <- raw_Education$Recipients.of.Bachelor.Degree.2010


##############################
# ----------------------------
# build main model dataset
model <- data.frame(matrix(nrow = 3142))
model$GEO.id <- raw_FoodStamps$GEO.id2
model$County <- raw_FoodStamps$GEO.display.label

# state filter
model$State <- sub(' ', '', sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][2]}))
model$County <- sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][1]})

model$TotalHouseholds <- raw_FoodStamps$HC01_EST_VC01
model$SNAP_Households <- raw_FoodStamps$HC02_EST_VC01
model$Poverty_Sub100 <- as.numeric(raw_Poverty$HD01_VD02) + as.numeric(raw_Poverty$HD01_VD03)
model[1] <- NULL


# engineered features
model$SNAP_ParticipationRate <- as.numeric(model$SNAP_Households) / as.numeric(model$TotalHouseholds)
model$SNAP_FillRate <- as.numeric(model$SNAP_Households) / as.numeric(model$Poverty_Sub100)


# county with a specific SNAP_Participation_Rate
countyWithRatio <- function(x) {
  result <- model$County[findInterval(x, model$SNAP_ParticipationRate[order(as.factor(model$SNAP_ParticipationRate))])]
  return(result)
}

countyWithRatio(0.5278107)
