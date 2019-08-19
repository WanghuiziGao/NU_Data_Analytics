# Project Name: Applied Machine Learning Techniques for Underground Metal and Non-Metal Mining Injury Classification
# Team Members: Wanghuizi (Jessie) Gao, Lohith Sekhar Potluri
# Date: April 23, 2019

# Import data
library(readxl)
data <- read_excel("D:/@Jessie Gao/NU/Capstone/Data/R Dataset/Data_20190404.xlsx")
str(data)

# Convert data types
data$DEGREE_INJURY_Three_Level <- as.factor(data$DEGREE_INJURY_Three_Level)
data$Climatic_Region <- as.factor(data$Climatic_Region)
data$UG_LOCATION <- as.factor(data$UG_LOCATION)
data$UG_MINING_METHOD <- as.factor(data$UG_MINING_METHOD)
data$MINING_EQUIP <- as.factor(data$MINING_EQUIP)
data$EQUIP_MFR_NAME <- as.factor(data$EQUIP_MFR_NAME)
data$ACCIDENT_DT <- as.Date(data$ACCIDENT_DT, format='%Y-%m-%d')
data$Day_Accident <- as.factor(data$Day_Accident)
data$Month_Accident <- as.factor(data$Month_Accident)
data$Season_Accident <- as.factor(data$Season_Accident)
data$CAL_YR <- as.factor(data$CAL_YR)
data$CAL_QTR <- as.factor(data$CAL_QTR)
data$ACCIDENT_TIME <- as.numeric(data$ACCIDENT_TIME)
data$Shift <- as.factor(data$Shift)
data$SHIFT_BEGIN_TIME <- as.numeric(data$SHIFT_BEGIN_TIME)
data$TOT_EXPER <- as.numeric(data$TOT_EXPER)
data$MINE_EXPER <- as.numeric(data$MINE_EXPER)
data$JOB_EXPER <- as.numeric(data$JOB_EXPER)
data$OCCUPATION <- as.factor(data$OCCUPATION)
data$ACTIVITY <- as.factor(data$ACTIVITY)
str(data)

# EDA
# Change the order of levels in the dependent variable to High, Medium, Low
print(levels(data$DEGREE_INJURY_Three_Level))
data$DEGREE_INJURY_Three_Level = factor(data$DEGREE_INJURY_Three_Level,levels(data$DEGREE_INJURY_Three_Level)[c(1,3,2)])
print(levels(data$DEGREE_INJURY_Three_Level))
# Bar chart of the dependent variable DEGREE_INJURY
depvar <- table(data$DEGREE_INJURY_Three_Level)
barplot(depvar, main="Bar Chart of Degree Injury", 
        xlab="Levels in Degree Injury", 
        ylab="Frequency of Levels",
        col=c("red","orange","yellow"))

# Bar chart of UG_Location
UG_LOCATION <- table(data$UG_LOCATION)
par(mar= c(5,14,2,3))
barplot(sort(UG_LOCATION, decreasing = FALSE), main="Bar Chart of Underground Location",
        xlab="Frequency of Levels ",
        col=c("#CCCCFF"),
        horiz = TRUE,
        las = 1)

# Bar chart of UG_MINING_METHOD
UG_MINING_METHOD <- table(data$UG_MINING_METHOD)
par(mar= c(5,10,2,3))
barplot(sort(UG_MINING_METHOD, decreasing = FALSE), main="Bar Chart of Underground Mining Method",
        xlab="Frequency of Levels ",
        col=c("#CCCCFF"),
        horiz = TRUE,
        las = 1)

# Bar chart of MINING_EQUIP
MINING_EQUIP <- table(data$MINING_EQUIP)
par(mar = c(5,25,2,1))
barplot(sort(MINING_EQUIP, decreasing = FALSE), main="Bar Chart of Mining Equipment", 
        xlab="Frequency of Levels",
        col=c("#CCCCFF"),
        horiz=TRUE,
        las = 1)

# Bar chart of EQUIP_MFR_NAME
EQUIP_MFR_NAME <- table(data$EQUIP_MFR_NAME)
par(mar = c(5,16.5,2,1))
barplot(sort(EQUIP_MFR_NAME, decreasing = FALSE), main="Bar Chart of Equipment Manufacturer", 
        #ylab="Levels in Equipment Manufacturer", 
        xlab="Frequency of Levels ",
        col=c("#CCCCFF"),
        las = 1,
        horiz=TRUE,
        cex.names=0.75)

#  Bar chart of CAL_YR
CAL_YR <- table(data$CAL_YR)
barplot(CAL_YR, main="Bar Chart of Calender Year", 
        xlab="Levels in Calender Year", 
        ylab="Frequency of Levels ",
        col=c("#CCCCFF"))

# Bar chart of CAL_QTR
CAL_QTR <- table(data$CAL_QTR)
barplot(CAL_QTR, main="Bar Chart of Quarter of the Year", 
        xlab="Levels in Quarter of the Year", 
        ylab="Frequency of Levels ",
        col=c("#CCCCFF"))

# Bar chart of OCCUPATION
OCCUPATION <- table(data$OCCUPATION)
par(mar = c(5,28,2,1))
barplot(sort(OCCUPATION, decreasing = FALSE), main="Bar Chart of Occupation", 
        xlab="Frequency of Levels ",
        col=c("#CCCCFF"),
        las = 1,
        horiz=TRUE,
        cex.names=0.7)

# Bar chart of ACTIVITY
ACTIVITY <- table(data$ACTIVITY)
par(mar = c(5,11,2,1))
barplot(sort(ACTIVITY, decreasing = FALSE), main="Bar Chart of Activity", 
        xlab="Levels in Activity", 
        col=c("#CCCCFF"),
        las = 1,
        horiz=TRUE,
        cex.names=0.75)

# Histogram of TOT_EXPER
hist(data$TOT_EXPER,
     col="skyblue",
     xlab="Distribution of values in Total Experience",
     ylab="Frequency",
     main="Histogram of Total Experience")
summary(data$TOT_EXPER)
describe(data$TOT_EXPER)

# Histogram of MINE_EXPER
hist(data$MINE_EXPER,
     col="skyblue",
     xlab="Distribution of values in Mine Experience",
     ylab="Frequency",
     main="Histogram of Mine Experience")
summary(data$MINE_EXPER)
describe(data$MINE_EXPER)

# Histogram of JOB_EXPER
hist(data$JOB_EXPER,
     col="skyblue",
     xlab="Distribution of values in Job Experience",
     ylab="Frequency",
     main="Histogram of Job Experience")
summary(data$JOB_EXPER)
describe(data$JOB_EXPER)

# Summary of ACCIDENT_DT
summary(data$ACCIDENT_DT)

# Histogram of ACCIDENT_TIME
hist(as.numeric(data$ACCIDENT_TIME),
     col="skyblue",
     xlab="Distribution of values in Accident Time",
     ylab="Frequency",
     main="Histogram of Accident Time")
summary(data$ACCIDENT_TIME)
describe(data$ACCIDENT_TIME)

# Histogram of SHIFT_BEGIN_TIME
hist(data$SHIFT_BEGIN_TIME,
     col="skyblue",
     xlab="Distribution of values in Shift Begin Time",
     ylab="Frequency",
     main="Histogram of Shift Begin Time")
summary(data$SHIFT_BEGIN_TIME)
describe(data$SHIFT_BEGIN_TIME)

# Boxplot of TOT_EXPER among each level of DEGREE_INJURY  
boxplot(data$TOT_EXPER ~ data$DEGREE_INJURY_Three_Level, data=data,
        main="Boxplot for Total Experience among Each Level of Degree Injury Level",
        notch = TRUE,
        xlab="Three levels in Degree Injury",
        ylab="Total Experience",
        col=c("red","orange","yellow"))

# Boxplot of MINE_EXPER among each level of DEGREE_INJURY
boxplot(data$MINE_EXPER ~ data$DEGREE_INJURY_Three_Level, data=data,
        main="Boxplot for Mine Experience among Each Level of Degree Injury Level",
        notch = TRUE,
        xlab="Three levels in Degree Injury",
        ylab="Mine Experience",
        col=c("red","orange","yellow"))

# Boxplot of JOB_EXPER among each level of DEGREE_INJURY
boxplot(data$JOB_EXPER ~ data$DEGREE_INJURY_Three_Level, data=data,
        main="Boxplot for Job Experience among Each Level of Degree Injury Level",
        notch = TRUE,
        xlab="Three levels in Degree Injury",
        ylab="Job Experience",
        col=c("red","orange","yellow"))

# Missing value imputation
# Change all unknown values to missing values in Excel
Data_with_blanks_20190408 <- read_excel("D:/@Jessie Gao/NU/Capstone/Data/R Dataset/Data_with_blanks_20190408.xlsx")
# Delete EQUIP_MFR_NAME
data_with_blanks <- Data_with_blanks_20190408[,-c(7)]
str(data_with_blanks)

# Convert data types
data_with_blanks$DEGREE_INJURY_Three_Level <- as.factor(data_with_blanks$DEGREE_INJURY_Three_Level)
data_with_blanks$Climatic_Region <- as.factor(data_with_blanks$Climatic_Region)
data_with_blanks$UG_LOCATION <- as.factor(data_with_blanks$UG_LOCATION)
data_with_blanks$UG_MINING_METHOD <- as.factor(data_with_blanks$UG_MINING_METHOD)
data_with_blanks$MINING_EQUIP <- as.factor(data_with_blanks$MINING_EQUIP)
data_with_blanks$ACCIDENT_DT <- as.Date(data_with_blanks$ACCIDENT_DT, format='%Y-%m-%d')
data_with_blanks$Day_Accident <- as.factor(data_with_blanks$Day_Accident)
data_with_blanks$Month_Accident <- as.factor(data_with_blanks$Month_Accident)
data_with_blanks$Season_Accident <- as.factor(data_with_blanks$Season_Accident)
data_with_blanks$CAL_YR <- as.factor(data_with_blanks$CAL_YR)
data_with_blanks$CAL_QTR <- as.factor(data_with_blanks$CAL_QTR)
data_with_blanks$ACCIDENT_TIME <- as.numeric(data_with_blanks$ACCIDENT_TIME)
data_with_blanks$Shift <- as.factor(data_with_blanks$Shift)
data_with_blanks$SHIFT_BEGIN_TIME <- as.numeric(data_with_blanks$SHIFT_BEGIN_TIME)
data_with_blanks$TOT_EXPER <- as.numeric(data_with_blanks$TOT_EXPER)
data_with_blanks$MINE_EXPER <- as.numeric(data_with_blanks$MINE_EXPER)
data_with_blanks$JOB_EXPER <- as.numeric(data_with_blanks$JOB_EXPER)
data_with_blanks$OCCUPATION <- as.factor(data_with_blanks$OCCUPATION)
data_with_blanks$ACTIVITY <- as.factor(data_with_blanks$ACTIVITY)
str(data_with_blanks)

# Delete rows which have missing values
colSums(is.na(data_with_blanks))
data_no_blanks <- data_with_blanks[complete.cases(data_with_blanks),]
colSums(is.na(data_no_blanks))
str(data_no_blanks)

# Correlation Matrix
DF <- data_no_blanks[-c(1,13,14)]
nrow(DF)
str(DF)
DF[]<- lapply(DF,as.numeric)
str(DF[])
library(ggplot2)
library(ggcorrplot)
(cor_mat <- round(cor(DF[]),2))
ggcorrplot(cor_mat, title = "Correlation Matrix", hc.order = TRUE, type = "lower", lab = TRUE, lab_size = 2.5)

# Numeric missing values imputation using MICE
numeric_data <- data_with_blanks[, c(1,15,16,18,19,20)]
library(mice)
numeric_data_imputing <- mice(data = numeric_data, seed=9999)
numeric_data_imputed <- complete(numeric_data_imputing)
summary(numeric_data_imputing)
summary(numeric_data)
summary(numeric_data_imputed)
str(numeric_data_imputed)
colSums(is.na(numeric_data_imputed))

# Categorical missing values imputation using KNN
str(data_with_blanks)
categorical_data <- data_with_blanks[, c(1,3,4,5,6,7,8,9,10,11,12,17,21,22)]
summary(categorical_data)
str(categorical_data)
colSums(is.na(categorical_data))
library(VIM)
categorical_data_imputed <- kNN(categorical_data, variable = c(3,4,5,13,14))
categorical_data_imputed <- subset(categorical_data_imputed, select = ID:ACTIVITY)
head(categorical_data_imputed)
str(categorical_data_imputed)
colSums(is.na(categorical_data_imputed))

# Merge imputed numeric data and categorical data
cat_num_data <- merge(categorical_data_imputed,numeric_data_imputed,by="ID")

# Export to Excel
library(xlsx)
write.xlsx(cat_num_data,"D:/@Jessie Gao/NU/Capstone/Data/R Dataset/cat_num_data.xlsx")

# Create dummy variables and drop levels down for MINING_EQUIP, OCCUPATION, and ACTIVITY in Excel
library(readxl)
Data_20190415 <- read_excel("D:/@Jessie Gao/NU/Capstone/Data/R Dataset/Data_20190415.xlsx")
str(Data_20190415)
cleandata <- Data_20190415 
str(cleandata)

# Convert data types
cleandata$DEGREE_INJURY_Three_Level <- as.factor(cleandata$DEGREE_INJURY_Three_Level)
cleandata$Climatic_Region <- as.factor(cleandata$Climatic_Region)
cleandata$UG_LOCATION <- as.factor(cleandata$UG_LOCATION)
cleandata$UG_MINING_METHOD <- as.factor(cleandata$UG_MINING_METHOD)
cleandata$MINING_EQUIP <- as.factor(cleandata$MINING_EQUIP)
cleandata$Mining_Equipment_New_Level <- as.factor(cleandata$Mining_Equipment_New_Level)
cleandata$ACCIDENT_DT <- as.Date(cleandata$ACCIDENT_DT, format='%Y-%m-%d')
cleandata$Day_Accident <- as.factor(cleandata$Day_Accident)
cleandata$Month_Accident <- as.factor(cleandata$Month_Accident)
cleandata$Season_Accident <- as.factor(cleandata$Season_Accident)
cleandata$CAL_YR <- as.factor(cleandata$CAL_YR)
cleandata$CAL_QTR <- as.factor(cleandata$CAL_QTR)
cleandata$Work_Hour_1 <- as.numeric(cleandata$Work_Hour_1)
cleandata$Shift <- as.factor(cleandata$Shift)
cleandata$TOT_EXPER <- as.numeric(cleandata$TOT_EXPER)
cleandata$MINE_EXPER <- as.numeric(cleandata$MINE_EXPER)
cleandata$JOB_EXPER <- as.numeric(cleandata$JOB_EXPER)
cleandata$OCCUPATION <- as.factor(cleandata$OCCUPATION)
cleandata$Occupation_New_Level <- as.factor(cleandata$Occupation_New_Level)
cleandata$ACTIVITY <- as.factor(cleandata$ACTIVITY)
cleandata$Activity_New_Level <- as.factor(cleandata$Activity_New_Level)
str(cleandata)

# Check created dummy variables 
# Bar chart of Climatic_Region
Climatic_Region <- table(cleandata$Climatic_Region)
par(mar= c(5,12,2,3))
barplot(sort(Climatic_Region, decreasing = FALSE), main="Bar Chart of Climatic Region",
        #xlab="Levels in Climatic Region",
        xlab="Frequency of Levels ",
        col=c("#CCCCFF"),
        horiz = TRUE,
        las = 1,
)

# Bar chart of Day_Accident
Day_Accident <- table(cleandata$Day_Accident)
barplot(Day_Accident[c(4,2,6,7,5,1,3)], main="Bar Chart of Accident Day", 
        xlab="Days of Week", 
        ylab="Frequency of Levels ",
        col=c("#CCCCFF"))

# Bar chart of Month_Accident
Month_Accident <- table(cleandata$Month_Accident)
barplot(Month_Accident, main="Bar Chart of Accident Month", 
        xlab="Levels in Accident Month", 
        ylab="Frequency of Levels ",
        col=c("#CCCCFF"))

# Bar chart of Season_Accident
Season_Accident <- table(cleandata$Season_Accident)
barplot(Season_Accident[c(2,3,1,4)], main="Bar Chart of Accident Season", 
        xlab="Levels in Accident Season", 
        ylab="Frequency of Levels ",
        col=c("#CCCCFF"))

# Bar chart of Shift
Shift <- table(cleandata$Shift)
barplot(Shift, main="Bar Chart of Shift of Job", 
        xlab="Levels in Shift of Job", 
        ylab="Frequency of Levels ",
        col=c("#CCCCFF"))

# Histogram of Work_Hour_1
hist(as.numeric(cleandata$Work_Hour_1),
     col="skyblue",
     xlab="Distribution of values in Work Hour",
     ylab="Frequency",
     main="Histogram of Work Hour")
summary(cleandata$Work_Hour_1)
describe(cleandata$Work_Hour_1)

# Bar chart of Mining_Equipment_New_Level
Mining_Equipment_New_Level <- table(cleandata$Mining_Equipment_New_Level)
par(mar = c(5,12,2,1))
barplot(sort(Mining_Equipment_New_Level, decreasing = FALSE), main="Bar Chart of Mining Equipment after Level Reduction", 
        xlab="Frequency of Levels", 
        col=c("#CCCCFF"),
        las = 1,
        horiz=TRUE)

# Bar chart of Occupation_New_Level
OCCUPATION <- table(cleandata$Occupation_New_Level)
par(mar = c(5,6,2,1))
barplot(sort(OCCUPATION, decreasing = FALSE), main="Bar Chart of Occupation after Level Reduction", 
        xlab="Frequency of Levels ",
        col=c("#CCCCFF"),
        las = 1,
        horiz=TRUE)

# Bar chart of Activity_New_Level
ACTIVITY <- table(cleandata$Activity_New_Level)
par(mar = c(5,12,2,1))
barplot(sort(ACTIVITY, decreasing = FALSE), main="Bar Chart of Activity after Level Reduction", 
        xlab="Frequency of Levels", 
        col=c("#CCCCFF"),
        las = 1,
        horiz=TRUE)

# Skewed data transformation
library(psych)

# Check possible transformation for TOT_EXPER
describe(cleandata$TOT_EXPER)
describe(log(cleandata$TOT_EXPER))
describe(sqrt(cleandata$TOT_EXPER))
describe(1/sqrt(cleandata$TOT_EXPER))

# Check possible transformation for MINE_EXPER
describe(cleandata$MINE_EXPER)
describe(log(cleandata$MINE_EXPER))
describe(sqrt(cleandata$MINE_EXPER))
describe(1/sqrt(cleandata$MINE_EXPER))

# Check possible transformation for JOB_EXPER
escribe(cleandata$JOB_EXPER)
describe(log(cleandata$JOB_EXPER))
describe(sqrt(cleandata$JOB_EXPER))
describe(1/sqrt(cleandata$JOB_EXPER))

# Check possible transformation for Work_Hour_1
describe(cleandata$Work_Hour_1)
describe(log(cleandata$Work_Hour_1))
describe(sqrt(cleandata$Work_Hour_1))
describe(1/sqrt(cleandata$Work_Hour_1))

# Perform transformations
cleandata$TOT_EXPER   <-   sqrt(cleandata$TOT_EXPER) 
cleandata$MINE_EXPER  <-   log(cleandata$MINE_EXPER) 
cleandata$JOB_EXPER   <-   log(cleandata$JOB_EXPER) 
cleandata$Work_Hour_1 <-   sqrt(cleandata$Work_Hour_1) 
str(cleandata)

# Creste center and scale function
center_scale <- function(x) {
  scale(x, center = TRUE, scale = TRUE)
}

# Perform center and scale on numeric data
cleandata$TOT_EXPER   <-   center_scale(cleandata$TOT_EXPER) 
cleandata$MINE_EXPER  <-   center_scale(cleandata$MINE_EXPER) 
cleandata$JOB_EXPER   <-   center_scale(cleandata$JOB_EXPER) 
cleandata$Work_Hour_1 <-   center_scale(cleandata$Work_Hour_1) 
str(cleandata)

# Check transformation result
# Histogram of TOT_EXPER
hist(cleandata$TOT_EXPER,
     col="skyblue",
     xlab="Distribution of Transformed Values in Total Experience",
     ylab="Frequency",
     main="Histogram of Total Experience after Transformation")
summary(cleandata$TOT_EXPER)
describe(cleandata$TOT_EXPER)

# Histogram of MINE_EXPER
hist(cleandata$MINE_EXPER,
     col="skyblue",
     xlab="Distribution of Transformed Values in Mine Experience",
     ylab="Frequency",
     main="Histogram of Mine Experience after Transformation")
summary(cleandata$MINE_EXPER)
describe(cleandata$MINE_EXPER)

# Histogram of JOB_EXPER
hist(cleandata$JOB_EXPER,
     col="skyblue",
     xlab="Distribution of Transformed Values in Job Experience",
     ylab="Frequency",
     main="Histogram of Job Experience after Transformation")
summary(cleandata$JOB_EXPER)
describe(cleandata$JOB_EXPER)

# Histogram of Work_Hour_1
hist(as.numeric(cleandata$Work_Hour_1),
     col="skyblue",
     xlab="Distribution of Transformed Values in Work Hour",
     ylab="Frequency",
     main="Histogram of Work Hour after Transformation")
summary(cleandata$Work_Hour_1)
describe(cleandata$Work_Hour_1)

# Correlation matrix
colSums(is.na(cleandata))
cleandata_1 <-  cleandata[-c(5,13,14,15,21,23)]
cleandata_1$Work_Hour <- cleandata_1$Work_Hour_1
cleandata_1$Work_Hour_1 <- NULL
str(cleandata_1)
DF <- cleandata_1
nrow(DF)
str(DF)
DF[]<- lapply(DF,as.numeric)
str(DF[])
library(ggplot2)
library(ggcorrplot)
(cor_mat <- round(cor(DF[]),2))
ggcorrplot(cor_mat, title = "Correlation Matrix on clean data", hc.order = TRUE, type = "lower", lab = TRUE)

# Delete ACCIDENT_DT and CAL_QTR
str(cleandata_1)
cleandata_2 <- cleandata_1[-c(6,11)] 
str(cleandata_2)

# Change factor sequence for dependent variable
print(levels(cleandata_2$DEGREE_INJURY_Three_Level))
cleandata_2$DEGREE_INJURY_Three_Level = factor(cleandata_2$DEGREE_INJURY_Three_Level,levels(cleandata_2$DEGREE_INJURY_Three_Level)[c(1,3,2)])
cleandata_2$DEGREE_INJURY_Three_Level = factor(cleandata_2$DEGREE_INJURY_Three_Level,levels(cleandata_2$DEGREE_INJURY_Three_Level)[c(3,2,1)])
print(levels(cleandata_2$DEGREE_INJURY_Three_Level))
cleandata_2$DEGREE_INJURY_Three_Level <- as.ordered(cleandata_2$DEGREE_INJURY_Three_Level )

# Convert data types
cleandata_2$TOT_EXPER <- as.numeric(cleandata_2$TOT_EXPER)
cleandata_2$MINE_EXPER <- as.numeric(cleandata_2$MINE_EXPER)
cleandata_2$JOB_EXPER <- as.numeric(cleandata_2$JOB_EXPER)
cleandata_2$Work_Hour <- as.numeric(cleandata_2$Work_Hour)
str(cleandata_2)

# Split data to train and test datasets
set.seed(9999)
ind <- sample(2, nrow(cleandata_2), replace = TRUE, prob = c(0.75,0.25))
train <- cleandata_2[ind==1,]
test <- cleandata_2[ind==2,]
str(train)
str(test)

# Bar chart of dependent variable in train dataset
depvar <- table(train$DEGREE_INJURY_Three_Level)
barplot(depvar, main="Bar Chart of Degree Injury", 
        xlab="Levels in Degree Injury", 
        ylab="Frequency of Levels",
        col=c("yellow","orange","red"))
summary(train$DEGREE_INJURY_Three_Level)

# Bar chart of dependent variable in test dataset
barplot(table(test$DEGREE_INJURY_Three_Level), main="Bar Chart of Degree Injury", 
        xlab="Levels in Degree Injury", 
        ylab="Frequency of Levels",
        col=c("yellow","orange","red"))
summary(test$DEGREE_INJURY_Three_Level)

# Train models using 5-fold cross validation
library(tidyverse)
library(caret)
library(combinat)
library(ordinalForest)
set.seed(9999)
train.control <- trainControl(method = "cv", number = 5)

# Ordinal Random Forest (ordinalRF) 
model_orf <- train(DEGREE_INJURY_Three_Level~ ., data = train, method = "ordinalRF", trControl = train.control)
model_orf
summary(model_orf)

# Model evaluation on train data
library(stats)
library(lattice)
library(Matrix)
pred_train <- predict(model_orf, train)

# Confusion Matrix and accuracy rate on train data
(tab <- table(pred_train, train$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on train data
(multinom_roc <- multiclass.roc(train$DEGREE_INJURY_Three_Level, pred_train))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Model evaluation on test data
pred_test <- predict(model_orf, test)

# Confusion Matrix and accuracy rate on test data
(tab <- table(pred_test, test$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on test data
(multinom_roc <- multiclass.roc(test$DEGREE_INJURY_Three_Level, pred_test))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Decision Tree (C5.0Tree) 
library(C50)
model_c5_0 <- train(DEGREE_INJURY_Three_Level~ ., data = train, method = "C5.0Tree", trControl = train.control)
model_c5_0
summary(model_c5_0)

# Model evaluation on train data
pred_train <- predict(model_c5_0, train)

# Confusion Matrix and accuracy rate on train data
(tab <- table(pred_train, train$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on train data
(multinom_roc <- multiclass.roc(train$DEGREE_INJURY_Three_Level, pred_train))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i)) 
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Model evaluation on test data
pred_test <- predict(model_c5_0, test)

# Confusion Matrix and accuracy rate on test data
(tab <- table(pred_test, test$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on test data
(multinom_roc <- multiclass.roc(test$DEGREE_INJURY_Three_Level, pred_test))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i)) 
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# XGBoost Tree (xgbTree)
library(xgboost)
model_xgbTree <- train(DEGREE_INJURY_Three_Level~ ., data = train, method = "xgbTree", trControl = train.control)
model_xgbTree
summary(model_xgbTree)

# Model evaluation on train data
pred_train <- predict(model_xgbTree, train)

# Confusion Matrix and accuracy rate on train data
(tab <- table(pred_train, train$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on train data
(multinom_roc <- multiclass.roc(train$DEGREE_INJURY_Three_Level, pred_train))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]]) 
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Model evaluation on test data
pred_test <- predict(model_xgbTree, test)

# Confusion Matrix and accuracy rate on test data
(tab <- table(pred_test, test$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on test data
(multinom_roc <- multiclass.roc(test$DEGREE_INJURY_Three_Level, pred_test))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]]) 
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Multinomial Logistic Regression (multinom) 
model_multinom <- train(DEGREE_INJURY_Three_Level~ ., data = train, method = "multinom", trControl = train.control)
model_multinom
summary(model_multinom)

# Model evaluation on train data
pred_train <- predict(model_multinom, train)

# Confusion Matrix and accuracy rate on train data
(tab <- table(pred_train, train$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on train data
(multinom_roc <- multiclass.roc(train$DEGREE_INJURY_Three_Level, pred_train))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Model evaluation on test data
pred_test <- predict(model_multinom, test)

# Confusion Matrix and accuracy rate on test data
(tab <- table(pred_test, test$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on test data
(multinom_roc <- multiclass.roc(test$DEGREE_INJURY_Three_Level, pred_test))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Support Vector Machine with Radial Kernel (svmRadial) 
library(kernlab)
model_svm_radial <- train(DEGREE_INJURY_Three_Level~ ., data = train, method = "svmRadial", trControl = train.control)
model_svm_radial
summary(model_svm_radial)

# Model evaluation on train data
pred_train <- predict(model_svm_radial, train)

# Confusion Matrix and accuracy rate on train data
(tab <- table(pred_train, train$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on train data
(multinom_roc <- multiclass.roc(train$DEGREE_INJURY_Three_Level, pred_train))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Model evaluation on test data
pred_test <- predict(model_svm_radial, test)

# Confusion Matrix and accuracy rate on test data
(tab <- table(pred_test, test$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on test data
(multinom_roc <- multiclass.roc(test$DEGREE_INJURY_Three_Level, pred_test))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Neural Network (nnet) 
model_neuralnet <- train(DEGREE_INJURY_Three_Level~ ., data = train, method = "nnet", trControl = train.control)
model_neuralnet
summary(model_neuralnet)

# Model evaluation on train data
pred_train <- predict(model_neuralnet, train)

# Confusion Matrix and accuracy rate on train data
(tab <- table(pred_train, train$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on train data
(multinom_roc <- multiclass.roc(train$DEGREE_INJURY_Three_Level, pred_train))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

# Model evaluation on test data
pred_test <- predict(model_neuralnet, test)

# Confusion Matrix and accuracy rate on test data
(tab <- table(pred_test, test$DEGREE_INJURY_Three_Level))
sum(diag(tab))/sum(tab)

# ROC and AUC on test data
(multinom_roc <- multiclass.roc(test$DEGREE_INJURY_Three_Level, pred_test))
multinom_roc$rocs
rs <- multinom_roc[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))  
# Legend: black: Low vs Medium, red: Low vs High, green: Medium vs High

