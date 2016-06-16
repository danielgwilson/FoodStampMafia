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



################################
#------------------------
# Elaine's workspace
#------------------------
################################

# inital setup
# setwd("~/Google Drive/Booz/FoodStampMafia")
rm(list=ls())
model <- read.csv("daniel.csv", stringsAsFactors = FALSE)
model_elaine <- read.csv("Elaine.csv", stringsAsFactors = FALSE)

# to get rid of model_elaine's NA's, merge model and model_elaine
model <- merge(model, model_elaine, by.x = "FIPS", by.y = "FIPS") # now model is complete with data that danny and elaine found

# split into training and test sets
smpl_size <- floor(0.75 * nrow(model)) # set a sample size, e.g. 75% training -> 25% test
set.seed(1337) # set the seed so that the randomness is reproducible
train_indeces <- sample(seq_len(nrow(model)), size = smpl_size) # get the indeces of a sample of the designated size

train <- model[train_indeces, ] # save the sample indeces to train
test <- model[-train_indeces, ] # save everything BUT the sample indeces to test

library(rpart)
fit <- rpart(SNAP_RatioSub75 ~ Population + FIPS + Hispanic_Race_2014 + White_Race_2014 +
               Black_Race_2014 + Native_Race_2014 + Asian_Race_2014 + Islander_Race_2014 +
               Others_Race_2014 + More_Race_2014 + UrbanRural_2013 + Male_Sex_Sub125 +
               Female_Sex_Sub125 + Sub18_Age_Sub125+ From18To64_Age_Sub125 +
               Over65and65_Age_Sub125 + LessThanHighSchool_Edu_Sub125 +
               HighSchoolGraduate_Edu_Sub125 + CollegeDegree_Edu_Sub125 +
               BachelorOrHigher_Edu_Sub125 + Fulltime_Work_Sub125 + Parttime_Work_Sub125
             + No_Work_Sub125, data=train, method = "class")
plot(fit)
text(fit)
fitVariablesUsed <- names(fit[,1:2])
preds <- predict(fit, data = newdata[,c(fitVariablesUsed)], type = c("prob"))
prediction <- data.frame(preds) # matrix for each of the observation!!!
names(prediction) <- c("Prob_Above75", "Prob_Sub75") # Okay why is the order so messed up


# prediction <- order[(prediction$),]

#install.packages('rattle')
#install.packages('rpart.plot')
#install.packages('RColorBrewer')
library(rattle)
library(rpart.plot)
library(RColorBrewer)

fancyRpartPlot(fit)

library(caret)
#test <- test[-which(test$State == "District of Columbia"),] # remove district of columbia from the test set since it wasn't trained
predictions <- predict(fit, test)

library(ggplot2)
group <- rep(NA,1292)
group <- ifelse(seq(1,1292) %in% train_indeces,"Train","Test")
df <- data.frame(county=model$FIPS, ratio=model$SNAP_ParticipationRatio,group)
ggplot(df,aes(x = county,y = ratio, color = group)) + geom_point() +
  scale_color_discrete(name="") + theme(legend.position="top")


confusionMatrix(predictions, y_test)

install.packages('randomForest')
library(randomForest)
set.seed(415)



# fit <- randomForest(as.factor(SNAP_RatioSub75) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize + FamilyID2,
#                     data=train, 
#                     importance=TRUE, 
#                     ntree=2000)