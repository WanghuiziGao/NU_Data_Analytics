# Import dataset into enviornment
train_tbl <- read.csv("D:/@Jessie Gao/NU/201901_ANA 665 - Data Mining & Machine Learning/Project/reducing-commercial-aviation-fatalities/train_tbl.csv", stringsAsFactors = T, na.strings = "NULL")

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
library(tidyverse)
library(tidyquant)
library(readxl)
library(skimr)
library(GGally)
library(h2o)
library(recipes)
library(readxl)
library(tidyverse)
library(tidyquant)
library(stringr)
library(forcats)
library(cowplot)
library(fs)
library(glue)

# EDA
class(train_tbl)
str(train_tbl)
summary(train_tbl)
train_tbl$seat <- as.factor(train_tbl$seat)
skim(train_tbl)

# EDA dependent variable
plot(train_tbl$event, main = "Bar Plot of Event Class", col = "#CCCCFF", xlab = "Class of Event", ylab = "Frequency" , ylim = c(0,1000))

# EDA categorical independent variable
# Contingency Table
addmargins(tab1 <- table(train_tbl[,c("seat", "event")]))
prop.table(tab1,1)

# Mosaic Plot
(strtab <- structable(seat ~ event, train_tbl))
mosaic(strtab, shade=TRUE, main = "Mosaic Plot")

# Histogram for all continuous variables
par(mfrow=c(3,8))
hist(train_tbl$ecg,xlab = "ecg",main = "Histogram of ecg")
hist(train_tbl$r,xlab = "r",main = "Histogram of r")
hist(train_tbl$gsr,xlab = "gsr",main = "Histogram of gsr")
hist(train_tbl$eeg_fp1,xlab = "eeg_fp1",main = "Histogram of eeg_fp1")
hist(train_tbl$eeg_f7,xlab = "eeg_f7",main = "Histogram of eeg_f7")
hist(train_tbl$eeg_f8,xlab = "eeg_f8",main = "Histogram of eeg_f8")
hist(train_tbl$eeg_t4,xlab = "eeg_t4",main = "Histogram of eeg_t4")
hist(train_tbl$eeg_t6,xlab = "eeg_t6",main = "Histogram of eeg_t6")
hist(train_tbl$eeg_t5,xlab = "eeg_t5",main = "Histogram of eeg_t5")
hist(train_tbl$eeg_t3,xlab = "eeg_t3",main = "Histogram of eeg_t3")
hist(train_tbl$eeg_fp2,xlab = "eeg_fp2",main = "Histogram of eeg_fp2")
hist(train_tbl$eeg_o1,xlab = "eeg_o1",main = "Histogram of eeg_o1")
hist(train_tbl$eeg_p3,xlab = "eeg_p3",main = "Histogram of eeg_p3")
hist(train_tbl$eeg_pz,xlab = "eeg_pz",main = "Histogram of eeg_pz")
hist(train_tbl$eeg_f3,xlab = "eeg_f3",main = "Histogram of eeg_f3")
hist(train_tbl$eeg_fz,xlab = "eeg_fz",main = "Histogram of eeg_fz")
hist(train_tbl$eeg_f4,xlab = "eeg_f4",main = "Histogram of eeg_f4")
hist(train_tbl$eeg_c4,xlab = "eeg_c4",main = "Histogram of eeg_c4")
hist(train_tbl$eeg_p4,xlab = "eeg_p4",main = "Histogram of eeg_p4")
hist(train_tbl$eeg_poz,xlab = "eeg_poz",main = "Histogram of eeg_poz")
hist(train_tbl$eeg_c3,xlab = "eeg_c3",main = "Histogram of eeg_c3")
hist(train_tbl$eeg_cz,xlab = "eeg_cz",main = "Histogram of eeg_cz")
hist(train_tbl$eeg_o2,xlab = "eeg_o2",main = "Histogram of eeg_o2")

# Correlation matrix
'%ni%' <- Negate('%in%')  # define not in function
conti_data <- train_tbl[, colnames(train_tbl) %ni% c("seat", "event")]
conti_data <- as.matrix(conti_data)
options(scipen=999)  # turn-off scientific notation
(cor_mat <- round(cor(conti_data),1))
ggcorrplot(cor_mat, title = "Correlation Matrix", hc.order = TRUE, type = "lower", outline.col = "white")

# Preprocessing
# Skewness
skewed_feature_names <- train_tbl %>%
  select_if(is.numeric) %>%
  map_df(skewness) %>%
  gather(factor_key = T) %>%
  arrange(desc(value)) %>%
  filter(abs(value) >= 1) %>%
  pull(key) %>%
  as.character()

# Center, Scaling
recipe_obj <- recipe(event ~ ., data = train_tbl) %>%
  step_zv(all_predictors()) %>%
  step_YeoJohnson(skewed_feature_names) %>%
  step_center(all_numeric()) %>%
  step_scale(all_numeric())

prepared_recipe <- recipe_obj %>% prep()

train_processed_tbl <- bake(prepared_recipe, new_data = train_tbl)

# Histogram after preprocessing
par(mfrow=c(3,8))
hist(train_processed_tbl$ecg,xlab = "ecg",main = "Histogram of ecg")
hist(train_processed_tbl$r,xlab = "r",main = "Histogram of r")
hist(train_processed_tbl$gsr,xlab = "gsr",main = "Histogram of gsr")
hist(train_processed_tbl$eeg_fp1,xlab = "eeg_fp1",main = "Histogram of eeg_fp1")
hist(train_processed_tbl$eeg_f7,xlab = "eeg_f7",main = "Histogram of eeg_f7")
hist(train_processed_tbl$eeg_f8,xlab = "eeg_f8",main = "Histogram of eeg_f8")
hist(train_processed_tbl$eeg_t4,xlab = "eeg_t4",main = "Histogram of eeg_t4")
hist(train_processed_tbl$eeg_t6,xlab = "eeg_t6",main = "Histogram of eeg_t6")
hist(train_processed_tbl$eeg_t5,xlab = "eeg_t5",main = "Histogram of eeg_t5")
hist(train_processed_tbl$eeg_t3,xlab = "eeg_t3",main = "Histogram of eeg_t3")
hist(train_processed_tbl$eeg_fp2,xlab = "eeg_fp2",main = "Histogram of eeg_fp2")
hist(train_processed_tbl$eeg_o1,xlab = "eeg_o1",main = "Histogram of eeg_o1")
hist(train_processed_tbl$eeg_p3,xlab = "eeg_p3",main = "Histogram of eeg_p3")
hist(train_processed_tbl$eeg_pz,xlab = "eeg_pz",main = "Histogram of eeg_pz")
hist(train_processed_tbl$eeg_f3,xlab = "eeg_f3",main = "Histogram of eeg_f3")
hist(train_processed_tbl$eeg_fz,xlab = "eeg_fz",main = "Histogram of eeg_fz")
hist(train_processed_tbl$eeg_f4,xlab = "eeg_f4",main = "Histogram of eeg_f4")
hist(train_processed_tbl$eeg_c4,xlab = "eeg_c4",main = "Histogram of eeg_c4")
hist(train_processed_tbl$eeg_p4,xlab = "eeg_p4",main = "Histogram of eeg_p4")
hist(train_processed_tbl$eeg_poz,xlab = "eeg_poz",main = "Histogram of eeg_poz")
hist(train_processed_tbl$eeg_c3,xlab = "eeg_c3",main = "Histogram of eeg_c3")
hist(train_processed_tbl$eeg_cz,xlab = "eeg_cz",main = "Histogram of eeg_cz")
hist(train_processed_tbl$eeg_o2,xlab = "eeg_o2",main = "Histogram of eeg_o2")

# Modeling

h2o.init()

y <- "event"
x <- setdiff(names(train_h2o), y)

automl_models_h2o <- h2o.automl(
  x = x,
  y = y,
  training_frame = as.h2o(train_processed_tbl),
  max_runtime_secs = 30,
  nfolds = 10
)

automl_models_h2o@leaderboard


