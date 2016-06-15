setwd("~/Google Drive/Booz/FoodStampMafia")
rm(list=ls())

model <- read.csv("daniel.csv", stringsAsFactors = FALSE)

# split into training and test sets
smpl_size <- floor(0.75 * nrow(model))

set.seed(1337)
train_indeces <- sample(seq_len(nrow(model)), size = smpl_size)

train <- model[train_indeces, ]
test <- model[-train_indeces, ]