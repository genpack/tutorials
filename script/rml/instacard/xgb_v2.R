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

train = build_features(train_pack$feature_dataset)
test  = build_features(test_pack$feature_dataset)

exclude_columns = colnames(train) %>% charFilter('_')
X_train = train[colnames(train) %-% exclude_columns]
X_test  = test[colnames(test) %-% exclude_columns]

y_train = train %>% select(user_id, product_id) %>% build_labels(train_pack$label_dataset)
y_test  = test %>% select(user_id, product_id) %>% build_labels(test_pack$label_dataset)

####
## XGBoost model
# We use the R package RML to train a XGBoost model with default hyper-parameters:
xgb = rml::CLS.SKLEARN.XGB(name = 'xgb_v2', n_jobs = 8, fe.enabled = T)


xgb$fit(X_train, y_train)

perf = xgb$performance(X_test, y_test, metrics = c('gini', 'precision', 'recall', 'lift', 'accuracy', 'f1'), quantiles = c(0.02, 0.05, 0.1, 0.2, 0.5))
# Adding more training data does not help improve model performance
# Changing number of customers for training data from 20000 to 80000 did not change performance

xgb %>% rml::model_save('models')


###
test_pack$cutpoint_orders %>% 
  rename(order_id = cutpoint_order_id) %>% 
  left_join(order_products_prior, by = 'order_id') -> actual_orders

actual_orders %>% 
  group_by(user_id) %>% 
  summarise(order_size = length(unique(product_id))) %>% 
  ungroup -> actual_order_sizes

threshold = 0.5
test %>% 
  as.data.frame %>% 
  cbind(xgb$predict(X_test), label = y_test) %>% 
  group_by(user_id) %>% 
  summarise(order_size_expected = sum(label, na.rm = T), 
            tp = sum((xgb_v2_probs > threshold) & (label == 1)),
            fp = sum((xgb_v2_probs > threshold) & (label == 0)),
            tn = sum((xgb_v2_probs < threshold) & (label == 0)),
            fn = sum((xgb_v2_probs < threshold) & (label == 1))) %>% 
  ungroup %>% 
  mutate(precision = tp/(tp + fp), recall = tp/(tp + fn)) %>% 
  left_join(actual_order_sizes, by = 'user_id') %>% 
  mutate(f1 = 2*precision*recall/(precision + recall)) %>% 
  arrange(desc(f1, precision, order_size)) -> res

# Number of customers whose orders were 100% new products (never ordered before)
sum(res$order_size_expected == 0)

plot(AUC::roc(predictions = xgb$predict(X_test)[,1], labels = y_test %>% as.factor))



## success rate distribution among customers who had at least one expected product ordered:
res %>% filter(order_size_expected > 0) %>% pull(precision) %>% hist(breaks = 1000)
res %>% filter(order_size_expected > 0) %>% pull(recall) %>% hist(breaks = 1000)
res %>% filter(order_size_expected > 0) %>% pull(f1) %>% hist(breaks = 1000)

res %>% filter(order_size_expected > 0) %>% pull(precision) %>% round(2) %>% table

suc %>% filter(order_size_expected > 0, corpred == 0) %>% View
# order_size_expected: order_size_precedented


# LR from base:
lr = CLS.SKLEARN.LR(name = 'lr_v1', penalty = 'l1', solver = 'liblinear', 
                    transformers = MAP.RML.MMS())
lr$fit(X_train %>% {.[(. == Inf) | (. == -Inf)] <- NA;.} %>% na2zero, y_train)


