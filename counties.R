# County Data
raw_FoodStamps <- read.csv("ACS_14_5YR_S2201_with_ann.csv", stringsAsFactors = FALSE)
raw_FoodStamps <- raw_FoodStamps[-1,]
raw_Poverty <- read.csv("ACS_10_5YR_S1703_with_ann.csv", stringsAsFactors = FALSE)
raw_Poverty <- raw_Poverty[-1,]
raw_SNAP <- read.csv("snap_data.csv", stringsAsFactors = FALSE)


##############################
# ----------------------------
# build main model dataset
model <- data.frame(matrix(nrow = 3142))
model$GEO.id2 <- raw_FoodStamps$GEO.id2
model[1] <- NULL
model$County <- raw_FoodStamps$GEO.display.label

# state filter
model$State <- sub(' ', '', sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][2]}))
model$County <- sapply(model$County, FUN = function(x) {strsplit(x, split = ",")[[1]][1]})

model <- merge(model, data.frame(
  GEO.id2 = raw_Poverty$GEO.id2, 
  Poverty_Sub125 = (as.numeric(raw_Poverty$HC04_EST_VC01) / 100.0) * as.numeric(raw_Poverty$HC01_EST_VC01)), 
  by.x = 1,
  by.y = 1)

model$GEO.id2 = as.numeric(model$GEO.id2)

model <- merge(model, data.frame(
  GEO.id2 = raw_SNAP$FIPS,
  SNAP_Recipients = raw_SNAP$PRGNUM10),
  by.x = 1,
  by.y = 1)

model$SNAP_Recipients <- sub(',', '', as.character(model$SNAP_Recipients))
model$SNAP_ParticipationRatio <- as.numeric(model$SNAP_Recipients) / as.numeric(model$Poverty_Sub125)
model <- merge(model, data.frame(
  GEO.id2 = raw_SNAP$FIPS,
  Population = raw_SNAP$POP10),
  by.x = 1,
  by.y = 1)
model$Population <- sub(',', '', as.character(model$Population))

# split into training and test sets
smpl_size <- floor(0.75 * nrow(model))

set.seed(1337)
train_indeces <- sample(seq_len(nrow(model)), size = smpl_size)

train <- model[train_indeces, ]
test <- model[-train_indeces, ]


# random forest
library(rpart)
library(randomForest)
fit <- randomForest(as.factor(SNAP_ParticipationRatio) ~ as.factor(State) + as.factor(Population),
                   data=train,
                   importance=TRUE,
                   ntree=2000)
varImpPlot(fit)