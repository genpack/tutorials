load("data/instacard_data.RData")
library(magrittr)
library(dplyr)
library(rml)
library(rutils)
library(highcharter)
library(promer)
library(tm)

source('tools.R')

# keywords = c('BarbecueSauce', 'BBQSauce', 'Barbecue', 'Sauce', 'Sausage', 'LambShoulder', 'Charcoal', 'bbq', 'CookingFuel')
# target   = 'BarbecueSauce'
keywords = c('cabernetsauvignonwine','shiraz','vintage', 'cabernet', 'sauvignon', 'beverage', 'beer', 'chardonnay', 'whiskey', 'water', 'cocktail', 'cedar', 'pepsi', 'tequila', 'brandy')
target   = 'beer'

eventlogs = create_eventlog(orders, products, order_products_prior, keywords)

eventlogs %>% purrr::reduce(rbind) -> el

## Customers for train & Test
el %>% filter(eventType == sprintf('%sOrdered', target)) %>% pull(caseID) %>% unique %>% sample(0.7*length(.)) -> train_users
el %>% filter(eventType == sprintf('%sOrdered', target)) %>% pull(caseID) %>% unique %>% setdiff(train_users) -> test_users

## Train dataset
dfp_train = el %>%   
  filter(caseID %in% train_users) %>% 
  create_dynamic_features

training_dataset <- dfp_train %>% 
  extract_dataset_from_dfpack(target_keyword = target) 

## Test dataset
dfp_test = el %>%   
  filter(caseID %in% test_users) %>% 
  create_dynamic_features

testing_dataset <- dfp_test %>% 
  extract_dataset_from_dfpack(target_keyword = target) 

xgb = rml::CLS.SKLEARN.XGB(name = sprintf('xgb_%s_v1', target), n_jobs = 8, fe.enabled = T, cv.ntrain = 5)
# xgb$performance.cv(training_dataset$X %>% na2zero %>% select(-caseID, eventTime), training_dataset$y)

xgb$fit(training_dataset$X %>% na2zero %>% select(-caseID, eventTime), training_dataset$y)
xgb$performance(testing_dataset$X %>% na2zero %>% select(-caseID, eventTime), testing_dataset$y, c('precision', 'gini', 'lift'), quantile = c(0.01, 0.02, 0.05, 0.1, 0.5))

xgb %>% model_save('.')
testing_dataset %>% saveRDS('testing_dataset.rds')
training_dataset %>% saveRDS('training_dataset.rds')
