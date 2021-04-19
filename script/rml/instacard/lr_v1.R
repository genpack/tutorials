### test 2: split customers for test and train, use only prior product orders. 
# Use NLP clustering to group products into 100 clusters:

tx = readRDS('data/tm_object.rds')
tx$data$dataset$cluster_id = tx$data$CLS

user_subset_train = orders$user_id %>% unique %>% sample(10000)
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

####
# LR from base:
lr = CLS.SKLEARN.LR(name = 'lr_v1', penalty = 'l1', solver = 'liblinear', 
                    transformers = MAP.RML.MMS())

X_train = X_train %>% 
  select(- user_id,
         - current_order_id) %>% 
  {.[(. == Inf) | (. == -Inf)] <- NA;.} %>% 
  na2zero

lr$fit(X_train, y_train)

X_test %<>% 
  select(- user_id,
         - current_order_id) %>% 
  {.[(. == Inf) | (. == -Inf)] <- NA;.} %>% 
  na2zero

perf = lr$performance(X_test, y_test, metrics = c('gini', 'precision', 'recall', 'lift', 'accuracy', 'f1'), quantiles = c(0.02, 0.05, 0.1, 0.2, 0.5))

lr %>% rml::model_save('models')


###


