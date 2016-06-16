##### project name: FoodStampMafia
##### name: Elaine Pak

#
#
#

###______________________________Mean Population from 2010

# create population data frames from 2 files
popcount <- read.csv("UrbanRuralStatusOfCounty.csv", head=T, stringsAsFactors = FALSE )
popcount2 <- read.csv("SNAPParticipationAndCost.csv", head=T, stringsAsFactors = FALSE )
popcount <- popcount[1:3143,]
popcount2 <- popcount2[1:3196,]

# use merge function to screen out the counties that belong to both files
install.packages("data.table")
library(data.table)
popcount_final <- merge(popcount2, popcount, by.x="FIPS", by.y="FIPS", all = T)

# create a new data frame with just population numbers from both files
popcompare <- data.frame(matrix(nrow = 3196))
popcompare$pop1 <- popcount_final$Population_2010
popcompare$pop2 <- popcount_final$POP10

# the following two lines properly convert variables from character to number
popcompare$pop1 <- sub(',', '', popcompare$pop1)
popcompare$pop2 <- sub(',', '', popcompare$pop2)
popcompare$popmedian <- (as.numeric(popcompare$pop1) + as.numeric(popcompare$pop2))/2
popcompare$FIPS <- popcount_final$FIPS
popcompare <- popcompare[,-1]
popcompare <- popcompare[,-1]
popcompare <- popcompare[,-1]

# done
ready <- data.frame(FIPS = popcount_final$FIPS, pop_mean_2010 = popcompare$popmedian)
write.csv(ready, file = "Elaine-MeanPop2010-.csv", row.names = FALSE)


#
#
#

###______________________________Urban/Rural Status from 2013

urstatus <- read.csv("UrbanRuralStatusOfCounty.csv", head=T, stringsAsFactors = FALSE )
summary(urstatus)

# create a codebook that explains what UIC_2013 numbers 1 thru 12 mean
urstatus_codebook <- data.frame(matrix(nrow = 3221))
urstatus_codebook$UIC_2013 <- urstatus$UIC_2013
urstatus_codebook$Description <- urstatus$Description
duplicated(urstatus_codebook) # shows "TRUE" for duplicated values
urstatus_codebook <- urstatus_codebook[,-1] # get rid of the unnecessary first column full of NA
urstatus_codebook <- urstatus_codebook[!duplicated(urstatus_codebook), ] # now only 12 rows left
urstatus_codebook <- urstatus_codebook[order(urstatus_codebook$UIC_2013),]
# done
ready <- data.frame(UIC_2013 = urstatus_codebook$UIC_2013, Description = urstatus_codebook$Description)
write.csv(ready, file = "UrbanRuralCodebook.csv", row.names = FALSE)

# merge urban/rural status code to Elaine.csv
popcompare <- merge(popcompare, data.frame(FIPS = urstatus$FIPS, UIC_2013 = urstatus$UIC_2013),
                    by.x = "FIPS", by.y = "FIPS", all = T)
write.csv(popcompare, file = "Elaine.csv", row.names = FALSE)


#
#
#

###______________________________Race of people below 125% PL from 2014

# ACS is the data frame of the characteristics of people in different poverty status
ACS <- read.csv("ACS_14_5YR_S1703_with_ann.csv", head=T, stringsAsFactors = FALSE)
elaine <- read.csv("Elaine.csv", head=T, stringsAsFactors = F)
# ACS$HC04_EST_VC22 # Sub125 Hispanic or Latino
# ACS$HC04_EST_VC23 # Sub125 White
# ACS$HC04_EST_VC15 # Sub125 Black
# ACS$HC04_EST_VC16 # Sub125 American Indian and Alaska Native
# ACS$HC04_EST_VC17 # Sub125 Asian
# ACS$HC04_EST_VC18 # Sub125 Native Hawaiian and Other Pacific Islander
# ACS$HC04_EST_VC19 # Sub125 Others
# ACS$HC04_EST_VC20 # Sub125 2 or more races
ACS$GEO.id2 <- as.numeric(ACS$GEO.id2)

# Calculate the number (not percentage) of number of population under 125% PL by race
ACS$HC04_EST_VC22 <- (as.numeric(ACS$HC01_EST_VC22)/100) * as.numeric(ACS$HC04_EST_VC22)
ACS$HC04_EST_VC23 <- (as.numeric(ACS$HC01_EST_VC23)/100) * as.numeric(ACS$HC04_EST_VC23)
ACS$HC04_EST_VC15 <- (as.numeric(ACS$HC01_EST_VC15)/100) * as.numeric(ACS$HC04_EST_VC15)
ACS$HC04_EST_VC16 <- (as.numeric(ACS$HC01_EST_VC16)/100) * as.numeric(ACS$HC04_EST_VC16)
ACS$HC04_EST_VC17 <- (as.numeric(ACS$HC01_EST_VC17)/100) * as.numeric(ACS$HC04_EST_VC17)
ACS$HC04_EST_VC18 <- (as.numeric(ACS$HC01_EST_VC18)/100) * as.numeric(ACS$HC04_EST_VC18)
ACS$HC04_EST_VC19 <- (as.numeric(ACS$HC01_EST_VC19)/100) * as.numeric(ACS$HC04_EST_VC19)
ACS$HC04_EST_VC20 <- (as.numeric(ACS$HC01_EST_VC20)/100) * as.numeric(ACS$HC04_EST_VC20)

# merge race data into existing data set "elaine"
elaine <- merge(elaine, data.frame(GEO.id2 = ACS$GEO.id2,
                                           Hispanic_Sub125 = ACS$HC04_EST_VC22,
                                           White_Sub125 = ACS$HC04_EST_VC23,
                                           Black_Sub125 = ACS$HC04_EST_VC15,
                                           Native_Sub125 = ACS$HC04_EST_VC16,
                                           Asian_Sub125 = ACS$HC04_EST_VC17,
                                           Island_Sub125 = ACS$HC04_EST_VC18,
                                           Others_Sub125 = ACS$HC04_EST_VC19,
                                           More_Sub125 = ACS$HC04_EST_VC20),
                by.x = "FIPS", by.y = "GEO.id2", all = T)

# just renaming the column names to avoid confusion.
# the format is: description_category(if applicable)_year
names(elaine) <- c("FIPS", "PopMean_2010", "UrbanRuralStatus_2013", "Hispanic_Race_2014",
                   "White_Race_2014", "Black_Race_2014", "Native_Race_2014", "Asian_Race_2014",
                   "Islander_Race_2014", "Others_Race_2014", "More_Race_2014")
write.csv(elaine, file = "Elaine.csv", row.names = FALSE)


#
#
#

###______________________________Gender of people below 125% PL from 2014

# ACS$HC01_EST_VC03 total number of male in each county
# ACS$HC01_EST_VC04 total number of female in each county
ACS$HC04_EST_VC03 <- (as.numeric(ACS$HC01_EST_VC03)/100) * as.numeric(ACS$HC04_EST_VC03)
ACS$HC04_EST_VC04 <- (as.numeric(ACS$HC01_EST_VC04)/100) * as.numeric(ACS$HC04_EST_VC04)

# merge gender data into existing data set "elaine"
elaine <- merge(elaine, data.frame(GEO.id2 = ACS$GEO.id2,
                                   Male_Sex_Sub125 = ACS$HC04_EST_VC03,
                                   Female_Sex_Sub125 = ACS$HC04_EST_VC04),
                by.x = "FIPS", by.y = "GEO.id2", all = T)
write.csv(elaine, file = "Elaine.csv", row.names = FALSE)
