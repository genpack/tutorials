### test 3: split customers for test and train, use only prior product orders. 
# Use NLP clustering to group products into 100 clusters,
# Add cutpoint features: numberOfDaysUntilNextOrder, DOW and HOD of the next order

tx = readRDS('data/tm_object.rds')
tx$data$dataset$cluster_id = tx$data$CLS

user_subset_train = orders$user_id %>% unique %>% sample(20000)
user_subset_test  = orders$user_id %>% unique %>% setdiff(user_subset_train) %>% sample(10000)


products_pp = products %>% left_join(tx$data$dataset %>% 
                          rename(product_id = ID) %>% 
                          mutate(product_id = as.integer(as.character(product_id))) %>% 
                          select(product_id, cluster_id), by = c('product_id'))


train_pack = build_training_pack(orders, products_pp, order_products_prior, customer_subset = user_subset_train)
test_pack  = build_training_pack(orders, products_pp, order_products_prior, customer_subset = user_subset_test)

X_train = build_features(train_pack$feature_dataset)
X_test  = build_features(test_pack$feature_dataset)

y_train = X_train %>% select(user_id, product_id) %>% build_labels(train_pack$label_dataset)
y_test  = X_test %>% select(user_id, product_id) %>% build_labels(test_pack$label_dataset)

# Add cutpoint features
X_train %<>% add_cutpoint_features(orders, train_pack$cutpoint_orders)
X_test  %<>% add_cutpoint_features(orders, test_pack$cutpoint_orders)
####


## XGBoost model
# We use the R package RML to train a XGBoost model with default hyper-parameters:
xgb = rml::CLS.SKLEARN.XGB(name = 'xgb_v3', n_jobs = 8, fe.enabled = T)

X_train = X_train %>% 
  select(- user_id,
         - current_order_id)

xgb$fit(X_train, y_train)

perf = xgb$performance(X_test, y_test, metrics = c('gini', 'precision', 'recall', 'lift', 'accuracy', 'f1'), quantiles = c(0.02, 0.05, 0.1, 0.2, 0.5))
# Adding more training data does not help improve model performance
# Changing number of customers for training data from 20000 to 80000 did not change performance

xgb %>% rml::model_save('models')
