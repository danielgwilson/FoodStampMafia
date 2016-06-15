setwd("~/Google Drive/Booz/FoodStampMafia")
rm(list=ls())

model <- read.csv("daniel.csv", stringsAsFactors = FALSE)

# split into training and test sets
smpl_size <- floor(0.75 * nrow(model))

set.seed(1337)
train_indeces <- sample(seq_len(nrow(model)), size = smpl_size)

train <- model[train_indeces, ]
test <- model[-train_indeces, ]

library(rpart)
fit <- rpart(SNAP_RatioSub50 ~ Population + FIPS + State, data=train, method = "class")
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
findInterval("Florida",(test[["State"]]))
predictions <- predict(fit, test)
print(predictions)
distconfusionMatrix(predictions$class, y_test)
