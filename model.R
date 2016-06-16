##############################
# ----------------------------
# Danny's starting example for subsetting training and test sets,
# then building a machine learning model off of them.
# * Please do not commit changes to this file on GitHub *
# ----------------------------
##############################

# inital setup
setwd("~/Google Drive/Booz/FoodStampMafia")
rm(list=ls())
model <- read.csv("daniel.csv", stringsAsFactors = FALSE)


# split into training and test sets
smpl_size <- floor(0.75 * nrow(model)) # set a sample size, e.g. 75% training -> 25% test
set.seed(1337) # set the seed so that the randomness is reproducible
train_indeces <- sample(seq_len(nrow(model)), size = smpl_size) # get the indeces of a sample of the designated size

train <- model[train_indeces, ] # save the sample indeces to train
test <- model[-train_indeces, ] # save everything BUT the sample indeces to test

library(rpart)
fit <- rpart(SNAP_RatioSub75 ~ Population + FIPS, data=train, method = "class")
plot(fit)
text(fit)

#install.packages('rattle')
#install.packages('rpart.plot')
#install.packages('RColorBrewer')
library(rattle)
library(rpart.plot)
library(RColorBrewer)

fancyRpartPlot(fit)

library(caret)
test <- test[-which(test$State == "District of Columbia"),] # remove district of columbia from the test set since it wasn't trained
predictions <- predict(fit, test)
print(predictions)
distconfusionMatrix(predictions$class, y_test)

install.packages('randomForest')
library(randomForest)
set.seed(415)



# fit <- randomForest(as.factor(SNAP_RatioSub75) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID2,
#                     data=train, 
#                     importance=TRUE, 
#                     ntree=2000)
