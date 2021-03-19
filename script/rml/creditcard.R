# credit card fraud detection

# Banks and credit card companies would like to detect fraudulent transactions to avoid 
# charging customers for items that they did not purchase.

# In this example, we use some classifiers from RML package to see how accurate they are in detecting fraudulent transactions. 

# This datasets contains a number of transactions made by credit cards in September 2013 by european cardholders. 
# The dataset is public and has been taken from Kaggle:
# https://www.kaggle.com/mlg-ulb/creditcardfraud

# The dataset contains transactions that occurred in two days. There are 492 fraudulent transactions 
# out of 284,807. The dataset is highly unbalanced (The number of frauds account for 0.17% of all transactions) 

# As described in the dataset source, all the features except for 'Time' and 'Amount'
# went through a PCA transformation so
# the dataset contains only numerical input variables. 
 
# Due to confidentiality issues, the original features and more background information about the data has not been provided. 
# Features V1 to V28 are the first 28 principal components ranked by variance and scaled.
# The feature 'Time' contains the time difference between each transaction and the first transaction in the dataset in seconds. 
# The feature 'Amount' is the transaction Amount. 
# Feature 'Class' is the target variable. It takes value 1 in case of fraud and 0 otherwise.

# We will try to Understand the distributions of the dataset and predict the target using some existing classifiers from RML.
# We will also use some techniques to improve the prediction accuracy through which you will learn 
# some of the functionalities provided in the RML package.

##### Setup ####
library(magrittr)
library(dplyr)
library(rbig)
library(rutils)
library(highcharter)
# library(rml)

source('~/Documents/software/R/packages/rml/R/mltools.R')
source('~/Documents/software/R/packages/rml/R/mlvis.R')
source('~/Documents/software/R/packages/rml/R/abstract.R')
source('~/Documents/software/R/packages/rml/R/transformers.R')
source('~/Documents/software/R/packages/rml/R/classifiers.R')
source('~/Documents/software/R/packages/rml/R/mappers.R')
source('~/Documents/software/R/packages/rml/R/gentools.R')


#### Read Data ####
bigreadr::big_fread2('/Users/nima/Documents/data/Kaggle/creditcard.csv') -> data
X = data %>% select(-Time, - Class)
y = data %>% pull(Class)

### Some visualisations:
cols = colnames(X)
cbind(X, label = y) %>% reshape2::melt(id.vars = 'label', measure.vars = cols) %>% 
  group_by(variable, label) %>% summarise(Average = mean(value)) %>% 
  viser::highcharter.bar(x = list('variable', 'label'), y = 'Average')
#### Not good for this problem!
features = c('V1', 'V2', 'Amount')
ind = X %>% nrow %>% sequence %>% sample(100)
cbind(X[ind, features], label = y[ind]) %>% 
  reshape2::melt(id.vars = 'label', measure.vars = features) %>% 
  crosstalk::SharedData$new() -> shared_features

crosstalk::bscols(
  list(
    list(
      crosstalk::filter_select('variable', 'Feature', shared_features, ~variable, multiple = F),
      crosstalk::filter_slider('value', 'Value', shared_features, ~value)),
    shared_features %>% plotly::plot_ly(y = ~value, x = ~label, type = 'bar')
  )  
)
#######
X = cbind(X, label = y)
X$V1 %>% quantile(probs = seq(0, 1, 0.01)) -> q
X$V1 %>% cut(breaks = q) -> ff
levels(ff) <- 1:100
ff %>% as.character %>% as.integer -> q_ind
X$V1_C = q[q_ind]
X[c('V1', 'V1_C', 'label')] %>% group_by(V1_C)

X %>% mutate(V1Q = cut(V1, breaks = quantile(V1, probs = seq(0, 1, 0.01)))) %>% 
  group_by(V1Q) %>% summarise(V1 = max(V1), label_sum = sum(label), label_count = length(label)) %>% 
  arrange(V1) %>% mutate(label_cumsum = cumsum(label_sum), label_cumcount = cumsum(label_count)) %>% 
  select(V1, M1 = label_cumsum, cnt = label_cumcount)
#########
fet = X %>% select(-label) %>% 
  evaluate_features(y, metrics = c('gini', 'log_loss')) %>% 
  rownames2Column('fname')

fet %>% arrange(desc(gini)) %>% head

binary_class_bar(X['V4'], y, C0_tag = 'Non-Fraud', C1_tag = 'Fraud')


binary_class_bar(X[paste0('V', 1:28)], y, C0_tag = 'Non-Fraud', C1_tag = 'Fraud')
binary_class_pie(X[paste0('V', 10:12)], y, C0_tag = 'Non-Fraud', C1_tag = 'Fraud')

#########


########
model = list()
cvres = list()

#### Initial model ####
# We will first train a XGBoost classifier from R package 'xgboost'. 
# As most of you know, XGboost models are robust, reliable and less sensitive to pre-processing or feature engineering.
# So in the first step, we directly feed data to the XGBoost model and measure a cross-validation performance:

model[[1]] = CLS.XGBOOST(name = 'XGB', 
                         cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, nthread = 4)
cvres[[1]] = model[[1]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1'))
# Convert a two dimentional nested list (list of lists) into a data frame:
cvres[[1]] = cvres[[1]] %>% lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[1]]$gini)
median(cvres[[1]]$f1)

# It seems that the performance is not too bad, but can't we do better?
# I keep hearing that XGBoost is the best classifier for imbalanced target class,
# so I expect it would not be easy to outperform XGBoost, but let's give it a try:

## Transfer to another experiment:
## First of all notice that these performance metrics are gained from a model trained with a random subset of 30% of rows.
## Better performance could be achieved if the model was trained with more rows like
## 80% of the entire dataset using for train and the other 20% for test.
## Since running experiments with 80% of rows would be time consuming,
## we decided to keep 30% of rows while we find the best configuration and then we will train the optimal model
## with 80% of the entire dataset.



# We start experimentation with downsampling the majority class. 
# In downsampling, a subsample of the majority class is randomly picked so that a fixed desired class ratio is achieved.
# Let's say we want to sample a dataset with a 10% class ratio, while the actual class ratio is 0.17%.
# To reach a 10% class ratio, in this case, we need to take a random subsample of the majority class, 
# keeping all rows of the minority class.
# This will reduce the total number of rows, so while performance might improve due to reduce imbalancy, 
# it may be deminished due to the reduction of training data. Let's see which one pervails:


model[[2]] = CLS.XGBOOST(name = 'XGB_DNS10PC', 
                         cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, nthread = 4,
                         smp.enabled = TRUE, smp.method = 'downsample', smp.class_ratio = 0.1)

cvres[[2]] = model[[2]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[2]]$gini)
median(cvres[[2]]$f1)

# As you can see, the gini score has increased by downsampling but 
# the F1 score has reduced. 
# The F1 score is using the decision boundary set by class rate quantile which ensures equality of precision and recall.

##### Now we try it with 50% class ratio:
model[[3]] = CLS.XGBOOST(name = 'XGB_DNS50PC', 
                         cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, nthread = 4,
                         smp.enabled = TRUE, smp.method = 'downsample', smp.class_ratio = 0.5)

cvres[[3]] = model[[3]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[3]]$gini)
median(cvres[[3]]$f1)
# Using 50% class ratio with downsampling for this dataset, reduces the number of rows considerably, 
# so there won't be enough 
# rows for training which makes the model unstable.

## Using Upsampling:
# model without upsampling using 10% of rows for training:

# model with upsampling using 10% of rows for training:
model[[4]] = CLS.XGBOOST(name = 'XGB_UPS10PC',
                       cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, nthread = 4,
                       smp.enabled = TRUE, smp.method = 'upsample', smp.class_ratio = 0.1)
cvres[[4]] = model[[4]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[4]]$gini)
median(cvres[[4]]$f1)


# XGBoost model with smote upsampling using 10% of rows for training:
model[[5]] = CLS.XGBOOST(name = 'XGB_SMOTE10PC',
                         cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, nthread = 4,
                         smp.enabled = TRUE, smp.method = 'smote', smp.class_ratio = 0.1,
                         smp.config = list(model = 'distance_SMOTE'))

cvres[[5]] = model[[5]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[5]]$gini)
median(cvres[[5]]$f1)
# Significant improvement observed using smote upsampling with XGBoost!

# As you can see, upsampling deminishes the performance in comparison to the model using the actual class ratio

## Let's try a Logistic Regression model from sklearn package:

model[[6]] = CLS.SKLEARN.LR(name = 'SKLR',
                            cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, 
                            penalty = 'l1', solver = 'liblinear')

cvres[[6]] = model[[6]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[6]]$gini)
median(cvres[[6]]$f1)

## Logistic Regression with transformers:

model[[7]] = CLS.SKLEARN.LR(name = 'SKLR_TMMS',
                            cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, 
                            penalty = 'l1', solver = 'liblinear', 
                            transformers = MAP.RML.MMS())
cvres[[7]] = model[[7]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[7]]$gini)
median(cvres[[7]]$f1)

## The MinMaxScaler (MMS) transformer actually improves the gini but reduces f1 score on class rate quantile boundary decision threshold.
# Let's not use transformers because in imbalanced classification problems, f1 score is a better measure rather than gini or Area Under ROC 

## Logistic Regression with downsampling:
model[[8]] = CLS.SKLEARN.LR(name = 'SKLR_DNS10PC',
                            cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8, 
                            penalty = 'l1', solver = 'liblinear',
                            smp.enabled = TRUE, smp.method = 'downsample', smp.class_ratio = 0.1)

cvres[[8]] = model[[8]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[8]]$gini)
median(cvres[[8]]$f1)
# Downsampling reduces the performance,
# Now try upsampling:

model[[9]] = CLS.SKLEARN.LR(name = 'SKLR_UPS10PC',
                            cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8,
                            penalty = 'l1', solver = 'liblinear',
                            smp.enabled = TRUE, smp.method = 'upsample', smp.class_ratio = 0.1)

cvres[[9]] = model[[8]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[9]]$gini)
median(cvres[[9]]$f1)


### Smote Upsampling:
model[[10]] = CLS.SKLEARN.LR(name = 'SKLR_SMOTE10PC',
                             cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8,
                             penalty = 'l1', solver = 'liblinear',
                             smp.enabled = TRUE, smp.method = 'smote', smp.class_ratio = 0.1,
                             smp.config = list(model = 'distance_SMOTE'))

cvres[[10]] = model[[10]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[10]]$gini)
median(cvres[[10]]$f1)

### Smote Upsampling with MMS transformer:

model[[11]] = CLS.SKLEARN.LR(name = 'SKLR_TMMS_SMOTE10PC',
                             cv.ntrain = 5, cv.ntest = 5, cv.train_ratio = 0.8, cv.test_ratio = 0.8,
                             penalty = 'l1', solver = 'liblinear',
                             transformers = MAP.RML.MMS(),
                             smp.enabled = TRUE, smp.method = 'smote', smp.class_ratio = 0.1,
                             smp.config = list(model = 'distance_SMOTE'))

cvres[[11]] = model[[11]]$performance.cv(X, y, metrics = c('gini', 'precision', 'recall', 'f1')) %>% 
  lapply(as.data.frame) %>% purrr::reduce(rbind)

median(cvres[[11]]$gini)
median(cvres[[11]]$f1)

### We found that distance_SMOTE cannot improve performance of the logistic regression model.
#
# model %>% lapply(function(x) x$name) %>% unlist -> nms
# cvres %>% lapply(function(x) median(x[['f1']])) %>% {names(.)<-nms;.} -> scores
# 

