library(magrittr)
library(dplyr)
library(reticulate)
use_python("/Users/nima/anaconda3/bin/python")

event_prediction_platform_scripts_path = "~/Documents/software/Python/projects/event_prediction_platform/scripts"
event_prediction_platform_data_path    = "~/Documents/software/Python/projects/event_prediction_platform/Datasets"
# use_virtualenv("myenv")
# use_condaenv("myenv")

import('pandas', as = 'pd')

el = import('ellib')

class(el)

# source_python(event_prediction_platform_scripts_path %>% paste('orangeDataFrameCreator.py', sep = "/"))

xgb = import('ellib.ClassificationModels.e_xgboost')

model = xgb$XGBoostClassify()

D = read.csv(event_prediction_platform_data_path %>% paste('Kaggle Bank Churn.csv', sep = '/') , as.is = T)

train_x     = D %>% select(CreditScore, Geography, Gender, Age, Tenure, Balance, NumOfProducts, HasCrCard, IsActiveMember) %>% r_to_py
train_label = D %>% select(Exited) %>% r_to_py

L = el$data$encode_categoricals(train_x, c('Geography', 'Gender'))
X = L[[1]]
Y = train_label

L = el$data$split(X, Y, 0.5)

X_train = L[[1]] 
X_test  = L[[2]]
Y_train = L[[3]]
Y_test  = L[[4]]

model$fit(X_train, Y_train, verbose = T)

