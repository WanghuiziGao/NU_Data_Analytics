# Import dataset into enviornment
Dataset <- read.csv("D:/@Jessie Gao/@NU/201808_ANA 625 - Categorical Data Methods and Applications/Final Project/South Asian Wireless Telecom Operator (SATO 2015).csv", stringsAsFactors = T, na.strings = "NULL")

# Call libraries needed
library(ggplot2)
library(ggcorrplot)
library(vcd)
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
library(lmtest)

# EDA
class(Dataset)
str(Dataset)
dim(Dataset)
View(Dataset)
summary(Dataset)

# EDA dependent variable
plot(Dataset$Class, main = "Bar Plot of Churn Class", col = "#CCCCFF", xlab = "Class of Churn", ylab = "Frequency" , ylim = c(0,1000))

# Histogram for all continuous variables
par(mfrow=c(3,3))
hist(Dataset$network_age,xlab = "Network age (day)",main = "Histogram of Network age")
hist(Dataset$Aggregate_Total_Rev,xlab = "Total revenue (Rupee)",main = "Histogram of Total revenue")
hist(Dataset$Aggregate_SMS_Rev,xlab = "SMS revenue (Rupee)",main = "Histogram of SMS revenue")
hist(Dataset$Aggregate_Data_Rev,xlab = "Data revenue (Rupee)",main = "Histogram of Data revenue")
hist(Dataset$Aggregate_Data_Vol,xlab = "Total Data Volume (byte)",main = "Histogram of Data Volume")
hist(Dataset$Aggregate_Calls,xlab = "Total calls",main = "Histogram of Total Calls")
hist(Dataset$Aggregate_ONNET_REV,xlab = "ONNET revenue (Rupee)",main = "Histogram of ONNNET revenue")
hist(Dataset$Aggregate_OFFNET_REV,xlab = "OFFNET Revenue (Rupee)",main = "Histogram of OFFNET revenue")
hist(Dataset$Aggregate_complaint_count,xlab = "Complaint count",main = "Histogram of Complaint Count")
# All continuous variables are positive skewed

# Box plot Matrix
'%ni%' <- Negate('%in%')  # define not in function
conti_data <- Dataset[, colnames(Dataset) %ni% c("Class", "aug_user_type", "sep_user_type", "sep_fav_a", "aug_fav_a")]
colnames(conti_data) <- c("network_age", "total_revenue", "SMS_revenue", "data_revenue", "data_volume",
                          "calls", "onnet_revenue", "offnet_revenue", "complaint")
conti_data <- as.matrix(conti_data)
options(scipen=999)  # turn-off scientific notation
boxplot.matrix(conti_data, ylim = c(0, 40000), main = "Box Plot Matrix")
boxplot(Aggregate_Data_Vol, xlab = "Data Volume", ylab = "Byte", main = "Box Plot of Data Volume")
# The scale of Aggregate_Data_Vol is much larger than others.

# Correlation matrix
(cor_mat <- round(cor(conti_data),2))
ggcorrplot(cor_mat, title = "Correlation Matrix")
# highest correlation (0.72): Aggregate_OFFNET_REV & Aggregate_Total_Rev 

# Scatterplot: Aggregate_Total_Rev vs Aggregate_OFFNET_REV 
attach(Dataset)
par(mfrow=c(1,1))
options(scipen=999)  # turn-off scientific notation
theme_set(theme_bw())
scattterplot <- ggplot(Dataset, aes(x=Aggregate_Total_Rev, y=Aggregate_OFFNET_REV)) +
  geom_point(aes(col=Class)) +
  geom_smooth(method="loess", se=F)  +
  labs(subtitle="Total Revenue vs Offnet Revenue",
       y="Total Revenue (Rupee)",
       x="Offnet Revenue (Rupee)",
       title="Scatterplot")
plot(scattterplot)

#Boxplot
g = ggplot(Dataset, aes(Class, Aggregate_SMS_Rev))
g + geom_boxplot(varwidth=T, fill="plum") + coord_cartesian(ylim = c(0,100))+
  labs(title="Box plot",
       subtitle="SMS Revenue by Class",
       x="Class",
       y="SMS Revenue (Rupee)")

g = ggplot(Dataset, aes(Class, Aggregate_Data_Vol))
g + geom_boxplot(varwidth=T, fill="plum") + coord_cartesian(ylim = c(0,3000000))+
  labs(title="Box plot",
       subtitle="Data Volume by Class",
       x="Class",
       y="Data Volume (byte)")

g = ggplot(Dataset, aes(Class, Aggregate_Total_Rev))
g + geom_boxplot(varwidth=T, fill="plum") + coord_cartesian(ylim = c(0,2500))+
  labs(title="Box plot",
       subtitle="Total Revenue by Class",
       x="Class",
       y="Total Revenue (Rupee)")

# Contigency Table
addmargins(tab1 <- table(Dataset[,c("aug_user_type", "Class")]))
prop.table(tab1,1)
addmargins(tab2 <- table(Dataset[,c("aug_fav_a", "Class")]))
prop.table(tab2,1)

# Mosaic Plot
strtab <- structable(aug_fav_a ~ aug_user_type+Class, Dataset)
mosaic(strtab, shade=TRUE, main = "Mosaic Plot")

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

# Skewness treatment 
skewness(Dataset2$network_age)

skewness(Dataset2$Aggregate_Total_Rev)
Dataset2$log_Total_Rev <- NA
Dataset2$log_Total_Rev <- ifelse(Dataset2$Aggregate_Total_Rev <= 0, 0, log(Dataset2$Aggregate_Total_Rev))
skewness(Dataset2$log_Total_Rev)

skewness(Dataset2$Aggregate_SMS_Rev)
Dataset2$log_SMS_Rev <- NA
Dataset2$log_SMS_Rev <- ifelse(Dataset2$Aggregate_SMS_Rev <= 0, 0, log(Dataset2$Aggregate_SMS_Rev))
skewness(Dataset2$log_SMS_Rev)

skewness(Dataset2$Aggregate_Data_Rev)
Dataset2$log_Data_Rev <- NA
Dataset2$log_Data_Rev <- ifelse(Dataset2$Aggregate_Data_Rev <= 0, 0, log(Dataset2$Aggregate_Data_Rev))
skewness(Dataset2$log_Data_Rev)

skewness(Dataset2$Aggregate_Data_Vol)
Dataset2$log_Data_Vol <- NA
Dataset2$log_Data_Vol <- ifelse(Dataset2$Aggregate_Data_Vol <= 0, 0, log(Dataset2$Aggregate_Data_Vol))
skewness(Dataset2$log_Data_Vol)

skewness(Dataset2$Aggregate_Calls)
Dataset2$log_Calls <- NA
Dataset2$log_Calls <- ifelse(Dataset2$Aggregate_Calls <= 0, 0, log(Dataset2$Aggregate_Calls))
skewness(Dataset2$log_Calls)

skewness(Dataset2$Aggregate_ONNET_REV)
Dataset2$log_ONNET_REV <- NA
Dataset2$log_ONNET_REV <- ifelse(Dataset2$Aggregate_ONNET_REV <= 0, 0, log(Dataset2$Aggregate_ONNET_REV))
skewness(Dataset2$log_ONNET_REV)

skewness(Dataset2$Aggregate_OFFNET_REV)
Dataset2$log_OFFNET_REV <- NA
Dataset2$log_OFFNET_REV <- ifelse(Dataset2$Aggregate_OFFNET_REV <= 0, 0, log(Dataset2$Aggregate_OFFNET_REV))
skewness(Dataset2$log_OFFNET_REV)

skewness(Dataset2$Aggregate_complaint_count)
Dataset2$log_complaint_count <- NA
Dataset2$log_complaint_count <- ifelse(Dataset2$Aggregate_complaint_count <= 0, 0, log(Dataset2$Aggregate_complaint_count))
skewness(Dataset2$log_complaint_count)

Dataset2 <- Dataset2[,-9:-2]

# Scalization
preprocessParams <- preProcess(Dataset2, method = "scale")
Dataset2 <- predict(preprocessParams, Dataset2)

# Compare raw data and pre-processed data
summary(Dataset)
summary(Dataset2)

# Histogram of pre-processed data
par(mfrow=c(3,3))
hist(Dataset2$network_age,xlab = "Network age (day)",main = "Histogram of Network age")
hist(Dataset2$log_Total_Rev,xlab = "Log Total revenue",main = "Histogram of Log Total revenue")
hist(Dataset2$log_SMS_Rev,xlab = "Log SMS revenue",main = "Histogram of Log SMS revenue")
hist(Dataset2$log_Data_Rev,xlab = "Log Data revenue",main = "Histogram of Log Data revenue")
hist(Dataset2$log_Data_Vol,xlab = "Log Total Data Volume",main = "Histogram of Log Data Volume")
hist(Dataset2$log_Calls,xlab = "Log Total calls",main = "Histogram of Total Log Calls")
hist(Dataset2$log_ONNET_REV,xlab = "Log ONNET revenue",main = "Histogram of Log ONNNET revenue")
hist(Dataset2$log_OFFNET_REV,xlab = "Log OFFNET Revenue",main = "Histogram of Log OFFNET revenue")
hist(Dataset2$log_complaint_count,xlab = "Log Complaint count",main = "Histogram of Log Complaint Count")
# Skewness has been treated and the scales changed to the same level

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
Dataset3 <- Dataset2[, colnames(Dataset2) %in% c("Class", "log_Total_Rev", "log_SMS_Rev","log_ONNET_REV",
                                                 "log_OFFNET_REV", "network_age", "log_Data_Vol", 
                                                 "aug_fav_a", "sep_fav_a")]

# Encode aug_fav_a "other" level to dummy variable
table(Dataset3$aug_fav_a)
Dataset3$aug_fav_a <- ifelse(Dataset3$aug_fav_a == "other", 1, 0)
colnames(Dataset3)[2] <- "aug_fav_a_other"
table(Dataset3$aug_fav_a_other)

# Encode sep_fav_a "ufone" level to dummy variable
table(Dataset3$sep_fav_a)
Dataset3$sep_fav_a <- ifelse(Dataset3$sep_fav_a == "ufone", 1, 0)
colnames(Dataset3)[3] <- "sep_fav_a_ufone"
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

# Anova test model2 v.s.model3
anova(logitmod2, logitmod3, test = "Chisq")







