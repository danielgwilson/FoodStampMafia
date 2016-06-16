# County Data
# setwd(C:\Users\579323\Desktop\FoodStampMafia)
rm(list=ls())
raw_FoodStamps <- read.csv("ACS_14_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,]
raw_Poverty <- read.csv("ACS_14_5YR_C17002_with_ann.csv", stringsAsFactors = FALSE)
raw_Poverty <- raw_Poverty[-1,]
raw_Education <- read.csv("Educational_attainment.csv", stringsAsFactors = FALSE)
raw_leisure <- read.csv("Leisure_numbers.csv")
raw_leisure <- raw_leisure[-1,]
raw_HCEstablishments <- read.csv("Healthcare_establishments.csv", stringsAsFactors = FALSE)

summary(raw_Education)
as.numeric(raw_FoodStamps$GEO.id2)
total <- merge(raw_FoodStamps, raw_Education, by.x="GEO.id2", by.y="GEO.id2", all= TRUE)
summary(raw_Poverty)
summary(raw_FoodStamps)

# Creating model
Nick <- data.frame(matrix(nrow = 3142))
Nick$FIPS <-as.numeric(raw_FoodStamps$GEO.id2)
Nick[1] <-NULL

#Simplest data import. Same raws, copy paste column
Nick$County <- raw_FoodStamps$GEO.display.label
# Raw count is DIFFERENT
Nick <- merge(Nick, data.frame("FIPS" = raw_Education$GEO.id2,
                               "BD" = raw_Education$Recipients.of.Bachelor.Degree.2010,
                               "HS" = raw_Education$HS.graduate..no.further.education),
               by.x="FIPS",
               by.y="FIPS")

#test
raw_leisure <- raw_leisure[raw_leisure$X2010 != "No Data"]

Nick <- merge(Nick, data.frame("FIPS" = as.numeric(raw_HCEstablishments$FIPS),
                               "HCLocations" = raw_HCEstablishments$ESTAB),
              by.x="FIPS",
              by.y="FIPS")

Nick <- merge(Nick, data.frame("FIPS" = as.numeric(raw_leisure$X),
                               "NumberofRecipients" = raw_leisure$X2010,
                               "PercentagePopLeisure" = raw_leisure$X.2),
              by.x="FIPS", 
              by.y="FIPS")


