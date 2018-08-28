# Import dataset into enviornment
Dataset <- read.csv("D:/@Jessie Gao/@NU/201808_ANA 625 - Categorical Data Methods and Applications/Final Project/South Asian Wireless Telecom Operator (SATO 2015).csv", stringsAsFactors = T, na.strings = "NULL")
class(Dataset)
str(Dataset)
dim(Dataset)
View(Dataset)
summary(Dataset)

# Call libraries needed
library(ggplot2)
library(DataExplorer)
library(ISLR)
library(tibble)
library(caret)
library(pROC)
library(e1071)
library(caret)
library(ROCR)
library(plyr)
library(car)

# EDA dependent variable
plot(Dataset$Class, main = "Bar Plot of Churn Class", col = "#CCCCFF", xlab = "Class of Churn", ylab = "Frequency" , ylim = c(0,1000))

# EDA numeric independent variable 1 - 





# Encode dependent variable (Churned=1, Active=0) 
Dataset$Class <- ifelse(Dataset$Class == "Churned", 1, 0)
Dataset$Class <- factor(Dataset$Class, levels = c(0, 1))
plot(Dataset$Class, main = "Bar Plot of Churn Class", col = "#CCCCFF", xlab = "Class of Churn", ylab = "Frequency" , ylim = c(0,1000))

# Split training and test data (75% training data, 25% test data)
Dataset1 <- Dataset
set.seed(1)
trainDataIndex1 <- createDataPartition(Dataset1$Class, p=0.75, list = F)  
trainData1 <- Dataset1[trainDataIndex1, ]
testData1 <- Dataset1[-trainDataIndex1, ]
table(trainData1$Class)
table(testData1$Class)

# Fit logistic model with training dataset
logitmod1 <- glm(Class ~ ., data = trainData1, family = "binomial")
summary(logitmod1)

# Model evaluation on training data
prob_train_pred1 <- predict(logitmod1, type = "response")
train_pred1 <- ifelse(prob_train_pred1 > 0.5, 1, 0)
head(train_pred1)
(train_tab1 <- table(predicted = train_pred1, actual = trainData1$Class))
# Confusion Matrix
confusionMatrix(train_tab1, positive = "1")
# ROC Curve
roc_train_pred1 <- roc(trainData1$Class ~ prob_train_pred1, plot = TRUE, print.auc = TRUE)
as.numeric(roc_train_pred1$auc)

# Model evaluation on test data
'%ni%' <- Negate('%in%')  # define not in function
testData <- testData1 [, colnames(testData1) %ni% "Class"]
prob_test_pred1 <- (predict(logitmod1, newdata = testData, type = "response"))
test_pred1 <- ifelse(prob_test_pred1 > 0.5, 1, 0)
head(test_pred1)
(test_tab1 <- table(predicted = test_pred1, actual = testData1$Class))
# Confusion Matrix
confusionMatrix(test_tab1, positive = "1")
# ROC Curve
roc_test_pred1 <- roc(testData1$Class ~ prob_test_pred1, plot = TRUE, print.auc = TRUE)
as.numeric(roc_test_pred1$auc)

# Pre-processing
# Missing values
Dataset2 <- Dataset
is.na(Dataset2)
# aug_user_type, sep_user_type, aug_fav_a and sep_fav_a have missing values
table(Dataset2$aug_user_type)
Dataset2$aug_user_type[Dataset2$aug_user_type==""] <- "Other"
Dataset2$aug_user_type <- as.factor(as.character(Dataset2$aug_user_type))
table(Dataset2$aug_user_type)

table(Dataset2$sep_user_type)
Dataset2$sep_user_type[Dataset2$sep_user_type==""] <- "Other"
Dataset2$sep_user_type <- as.factor(as.character(Dataset2$sep_user_type))
table(Dataset2$sep_user_type)

table(Dataset2$aug_fav_a)
Dataset2$aug_fav_a <- recode(Dataset2$aug_fav_a, "c('', '0') = 'other'")
table(Dataset2$aug_fav_a)

table(Dataset2$sep_fav_a)
Dataset2$sep_fav_a <- recode(Dataset2$sep_fav_a, " '' = 'other'")
table(Dataset2$sep_fav_a)

# Drop level for sep_fav_a
Dataset2$sep_fav_a <- recode(Dataset2$sep_fav_a, " c('other', 'zong', 'warid', 'telenor') = 'other'")
table(Dataset2$sep_fav_a)

# Outliers treatment 
summary(Dataset2)  
summary(Dataset2$network_age)  # found unreasonable negative values
# Try1: change to 0
Dataset2$network_age <- ifelse(Dataset2$network_age < 0, 0, Dataset2$network_age)
summary(Dataset2$network_age)

# Try2: change to 6 (minimal positive value)
Dataset2$network_age <- ifelse(Dataset2$network_age < 0, 6, Dataset2$network_age)
summary(Dataset2$network_age)

# Try3: change to their absolute values
Dataset2$network_age <- ifelse(Dataset2$network_age < 0, abs(Dataset2$network_age), Dataset2$network_age)
summary(Dataset2$network_age)
# The model result of these 3 methods are the same.

# Fit model2 with pre-processing data
# Split training and test data (75% training data, 25% test data)
set.seed(1)
trainDataIndex2 <- createDataPartition(Dataset2$Class, p=0.75, list = F)  
trainData2 <- Dataset2[trainDataIndex2, ]
testData2 <- Dataset2[-trainDataIndex2, ]
table(trainData2$Class)
table(testData2$Class)

# Fit logistic model with training dataset
logitmod2 <- glm(Class ~ ., data = trainData2, family = "binomial")
summary(logitmod2)

# Model evaluation on training data
prob_train_pred2 <- predict(logitmod2, type = "response")
train_pred2 <- ifelse(prob_train_pred2 > 0.5, 1, 0)
head(train_pred2)
(train_tab2 <- table(predicted = train_pred2, actual = trainData2$Class))
# Confusion Matrix
confusionMatrix(train_tab2, positive = "1")
# ROC Curve
roc_train_pred2 <- roc(trainData2$Class ~ prob_train_pred2, plot = TRUE, print.auc = TRUE)
as.numeric(roc_train_pred2$auc)

# Model evaluation on test data
'%ni%' <- Negate('%in%')  # define not in function
testData <- testData2 [, colnames(testData2) %ni% "Class"]
prob_test_pred2 <- (predict(logitmod2, newdata = testData, type = "response"))
test_pred2 <- ifelse(prob_test_pred2 > 0.5, 1, 0)
head(test_pred2)
(test_tab2 <- table(predicted = test_pred2, actual = testData2$Class))
# Confusion Matrix
confusionMatrix(test_tab2, positive = "1")
# ROC Curve
roc_test_pred2 <- roc(testData2$Class ~ prob_test_pred2, plot = TRUE, print.auc = TRUE)
as.numeric(roc_test_pred2$auc)

# Fit model3 with 8 significant independent variables based on model2 summary result
# Data preparation
Dataset3 <- Dataset2[, colnames(Dataset2) %in% c("Class", "Aggregate_Total_Rev", "Aggregate_Data_Vol",
                    "Aggregate_OFFNET_REV", "network_age", "Aggregate_SMS_Rev", "Aggregate_Data_Rev",
                    "aug_fav_a", "sep_fav_a")]
# Encode aug_fav_a "other" level to dummy variable
table(Dataset3$aug_fav_a)
Dataset3$aug_fav_a <- ifelse(Dataset3$aug_fav_a == "other", 1, 0)
colnames(Dataset3)[7] <- "aug_fav_a_other"
table(Dataset3$aug_fav_a_other)

# Encode sep_fav_a "ufone" level to dummy variable
table(Dataset3$sep_fav_a)
Dataset3$sep_fav_a <- ifelse(Dataset3$sep_fav_a == "ufone", 1, 0)
colnames(Dataset3)[8] <- "sep_fav_a_ufone"
table(Dataset3$sep_fav_a_ufone)

# Split training and test data (75% training data, 25% test data)
set.seed(1)
trainDataIndex3 <- createDataPartition(Dataset3$Class, p=0.75, list = F)  
trainData3 <- Dataset3[trainDataIndex3, ]
testData3 <- Dataset3[-trainDataIndex3, ]
table(trainData3$Class)
table(testData3$Class)

# Fit logistic model with training dataset
logitmod3 <- glm(Class ~ ., data = trainData3, family = "binomial")
summary(logitmod3)

# Model evaluation on training data
prob_train_pred3 <- predict(logitmod3, type = "response")
train_pred3 <- ifelse(prob_train_pred3 > 0.5, 1, 0)
head(train_pred3)
(train_tab3 <- table(predicted = train_pred3, actual = trainData3$Class))
# Confusion Matrix
confusionMatrix(train_tab3, positive = "1")
# ROC Curve
roc_train_pred3 <- roc(trainData3$Class ~ prob_train_pred3, plot = TRUE, print.auc = TRUE)
as.numeric(roc_train_pred3$auc)

# Model evaluation on test data
'%ni%' <- Negate('%in%')  # define not in function
testData <- testData3 [, colnames(testData3) %ni% "Class"]
prob_test_pred3 <- (predict(logitmod3, newdata = testData, type = "response"))
test_pred3 <- ifelse(prob_test_pred3 > 0.5, 1, 0)
head(test_pred3)
(test_tab3 <- table(predicted = test_pred3, actual = testData3$Class))
# Confusion Matrix
confusionMatrix(test_tab3, positive = "1")
# ROC Curve
roc_test_pred3 <- roc(testData3$Class ~ prob_test_pred3, plot = TRUE, print.auc = TRUE)
as.numeric(roc_test_pred3$auc)










