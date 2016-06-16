# package init
install.packages(c("choroplethr", "choroplethrMaps")) 
library(choroplethr)
library(choroplethrMaps)

# create a data frame with FIPS code and the target variable cast as value
county_choropleth(data.frame(region = model$FIPS, value = model$SNAP_ParticipationRatio))