# Convert orders to eventlog:
library(dplyr)
library(magrittr)
library(promer)
library(rutils)

day_start = '2010-01-01'


## Simple Model among customers who have already ordered the product, using only features made from the product order event
product = '49302'
product.aisle = products %>% filter(product_id == product) %>% pull(aisle_id)
# friends = products %>% filter(aisle_id == product.aisle) %>% pull(product_id)
##
# ind = which(order_products_prior$product_id == product) %U% which(order_products_prior$product_id %in% friends)
ind = which(order_products_prior$product_id == product)
order_products_prior.smp = order_products_prior[ind,]

## All users who have at least used this product once:
users = orders %>% filter(order_id %in% order_products_prior.smp$order_id) %>% pull(user_id)

orders.smp = orders %>% filter(eval_set == 'prior') %>% 
  filter(user_id %in% users)

######

orders.smp %>% 
  mutate(eventTime = order_number + as.Date(day_start), caseID = paste0('U', user_id)) %>%
  select(order_id, caseID, eventTime) %>% 
  left_join(order_products_prior.smp, by = 'order_id') %>% 
  mutate(eventType = paste0('P', product_id, '_Ordered')) %>% 
  mutate(attribute = 'occurrence', value = 1) %>% 
  select(caseID, eventTime, eventType, attribute, value) -> el

#### 
pack <- promer::dfg_pack(el, sequential = T, event_funs = c('count', 'count_cumsum', 'elapsed', 'tte', 'censored'), horizon = 1)
