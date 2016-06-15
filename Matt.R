# County Data
setwd("~/Documents/FoodStampMafia")

# Load data
raw_FoodStamps <- read.csv("ACS_14_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,]
raw_Poverty <- read.csv("ACS_14_5YR_C17002_with_ann.csv", stringsAsFactors = FALSE)
raw_Poverty <- raw_Poverty[-1,]
raw_Disability <-  read.csv("Disability.csv", head = TRUE) 
raw_Disability <- raw_Disability[-1,]
raw_Fertility <- read.csv("Fertility.csv", head = TRUE)
raw_Fertility <- raw_Fertility[-1]

# Create model
model <- data.frame(matrix(nrow = 3142))
model$FIPS <- as.numeric(raw_FoodStamps$GEO.id2)
model[1] <- NULL

# simplest data import. Same rows, copy pasta column
model$County <- raw_FoodStamps$GEO.display.label

# row count is DIFFERENT. WTF HD01_VD02
# example: model <- merge(dataframe1, dataframe2, by.x=dataframe1matchingcolumn, by.y=dataframe2matchingcolumn)
model <- merge(model, 
              data.frame("FIPS" = raw_Disability$GEO.id2,
                         "total_pop" = raw_Disability$HD01_VD01,
                         "SNAP_houses" = raw_Disability$HD01_VD02,
                         "SNAP_disable" = raw_Disability$HD01_VD03,
                         "NoSNAP_houses" = raw_Disability$HD01_VD05,
                         "Houses_disable" = raw_Disability$HD01_VD06),
               by.x="FIPS", 
               by.y="FIPS")
model <- merge(model,
               data.frame("FIPS" = raw_Fertility$GEO.id2,
                          "total_women" = raw_Fertility$HD01_VD01,
                          "births_12" = raw_Fertility$HD01_VD02,
                          "births_married"= raw_Fertility$HD01_VD03),
               by.x= "FIPS",
               by.y= "FIPS")


