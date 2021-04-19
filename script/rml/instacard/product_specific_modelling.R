load("~/Documents/software/R/projects/instacard/data/instacard_data.RData")
library(magrittr)
library(dplyr)
library(rml)
library(rutils)
library(highcharter)
library(promer)
library(tm)

source('~/Documents/software/R/projects/instacard/tools.R')

# keywords = c('BarbecueSauce', 'BBQSauce', 'Barbecue', 'Sauce', 'Sausage', 'LambShoulder', 'Charcoal', 'bbq', 'CookingFuel')
# target   = 'BarbecueSauce'
keywords = c('banana', 'fruit', 'apple', 'kiwi', 'orange', 'grape', 'pear', 'plum', 'strawberry', 'melon')
target   = 'banana'

eventlogs = create_eventlog(orders, products, order_products_prior, keywords)

eventlogs %>% purrr::reduce(rbind) -> el

## Customers for train
el %>% filter(eventType == sprintf('%sOrdered', target)) %>% pull(caseID) %>% unique %>% sample(0.7*length(.)) -> train_users
el %>% filter(eventType == sprintf('%sOrdered', target)) %>% pull(caseID) %>% unique %>% setdiff(train_users) -> test_users

# el$caseID %>% unique %>% sample(10000) -> picked_users

training_dataset <- el %>%   
  filter(caseID %in% train_users) %>% 
  create_dynamic_features(target_keyword = target) 

## Customers for test
testing_dataset <- el %>%   
  filter(caseID %in% test_users) %>% 
  create_dynamic_features(target_keyword = target) 

xgb = rml::CLS.SKLEARN.XGB(name = sprintf('xgb_%s_v1', target), n_jobs = 8, fe.enabled = T, cv.ntrain = 5)
# xgb$performance.cv(training_dataset$X %>% na2zero %>% select(-caseID, eventTime), training_dataset$y)
xgb %>% model_save('.')
testing_dataset %>% saveRDS('testing_dataset.rds')
training_dataset %>% saveRDS('training_dataset.rds')

xgb$fit(training_dataset$X %>% na2zero %>% select(-caseID, eventTime), training_dataset$y)
xgb$performance(testing_dataset$X %>% na2zero %>% select(-caseID, eventTime), testing_dataset$y, 'precision', quantile = c(0.01, 0.02, 0.05, 0.1, 0.5))

