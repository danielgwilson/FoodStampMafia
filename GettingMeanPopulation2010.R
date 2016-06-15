## 2016/06/14
## Elaine Pak

# create population data frames from 2 files
popcount <- read.csv("UrbanRuralStatusOfCounty.csv", head=T, stringsAsFactors = FALSE )
popcount2 <- read.csv("SNAPParticipationAndCost.csv", head=T, stringsAsFactors = FALSE )
popcount <- popcount[1:3143,]
popcount2 <- popcount2[1:3196,]

# use merge function to screen out the counties that belong to both files
install.packages("data.table")
library(data.table)
popcount_final <- merge(popcount2, popcount, by.x="FIPS", by.y="FIPS")

# create a new data frame with just population numbers from both files
popcompare <- data.frame(matrix(nrow = 3143))
popcompare$pop1 <- popcount_final$Population_2010
popcompare$pop2 <- popcount_final$POP10
# the following two lines properly convert variables from character to number
popcompare$pop1 <- sub(',', '', popcompare$pop1)
popcompare$pop2 <- sub(',', '', popcompare$pop2)
popcompare$popmedian <- (as.numeric(popcompare$pop1) + as.numeric(popcompare$pop2))/2

# done
ready <- data.frame(FIPS = popcount_final$FIPS, pop_mean_2010 = popcompare$popmedian)
write.csv(ready, file = "MeanPopulation2010.csv", row.names = FALSE)
