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
popcompare <- popcompare[,-1]
popcompare <- popcompare[,-1]
popcompare <- popcompare[,-1]
popcompare$FIPS <- popcount_final$FIPS

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
               by.x = "FIPS", by.y = "FIPS")
write.csv(popcompare, file = "Elaine.csv", row.names = FALSE)
