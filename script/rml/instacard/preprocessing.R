# Pre-processing:
#

num_clusters = 100
library(magrittr)
library(dplyr)


### Load Original Data:
rm(list = ls())
gc()
load("~/Documents/software/R/projects/instacard/data/instacard_data.RData")

### NLP Clustering:
tx = readRDS('data/tm_object.rds')
tx$data$dataset$cluster_id = tx$data$CLS

products_pp = products %>% 
  left_join(tx$data$dataset %>% 
     rename(product_id = ID) %>% 
     mutate(product_id = as.integer(as.character(product_id))) %>% 
     select(product_id, cluster_id), by = c('product_id'))

### Orders:
orders$days_since_prior_order[is.na(orders$days_since_prior_order)] <- 0
orders %>% 
  select(-eval_set) %>% 
  arrange(user_id, order_number) %>% 
  mutate(day_number = days_since_prior_order) %>% 
  rutils::column.cumulative.forward(col = 'day_number', id_col = 'user_id') -> orders_pp

### Orders_Products:
order_products_prior %>%     
  left_join(products_pp, by = 'product_id') %>%
  left_join(orders_pp, by = 'order_id') -> order_products_prior_pp

rm(list = 'order_products_prior')
gc()

order_products_train %>%     
  left_join(products_pp, by = 'product_id') %>%
  left_join(orders_pp, by = 'order_id') -> order_products_train_pp

rm(list = c('order_products_train', 'products', 'orders', 'sample_submission'))
gc()

save.image("~/Documents/software/R/projects/instacard/data/preprocessed_data.RData")
