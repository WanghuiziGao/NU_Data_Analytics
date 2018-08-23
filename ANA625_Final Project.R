#Import dataset into enviornment
Dataset <- read.csv("D:/@Jessie Gao/@NU/201808_ANA 625 - Categorical Data Methods and Applications/Final Project/South Asian Wireless Telecom Operator (SATO 2015).csv", stringsAsFactors = T, na.strings = "NULL")
class(Dataset)
str(Dataset)
head(Dataset)
colnames(Dataset)
dim(Dataset)
View(Dataset)
summary(Dataset)

#Call libraries needed
library(ggplot2)
library(DataExplorer)
library(ISLR)
library(tibble)
library(caret)
library(pROC)
library(e1071)

#EDA dependent variable
plot(Dataset$Class, main = "Bar Plot of Churn Class", col = "#CCCCFF", xlab = "Class of Churn", ylab = "Frequency" , ylim = c(0,1000))

#EDA numeric independent variable 1 - 




#Fit logistic model without pre-processing
model_glm_pre <- glm(Class ~ ., data = Dataset, family = "binomial")
summary(model_glm_pre)

#Model evaluation
head(predict(model_glm_pre, type = "response")) 
class_pred <- ifelse(predict(model_glm_pre, type = "response") > 0.5, "Churned", "Active")
head(class_pred)
(pred_tab <- table(predicted = class_pred, actual = Dataset$Class))
confusionMatrix(pred_tab, positive = "Churned")

pre_prob <- predict(model_glm_pre, data = Dataset, type = "response")
pre_roc <- roc(Dataset$Class ~ pre_prob, plot = TRUE, print.auc = TRUE)
as.numeric(pre_roc$auc)

#Pre-processing





#Fit logistic model after pre-processing





#Model evaluation









