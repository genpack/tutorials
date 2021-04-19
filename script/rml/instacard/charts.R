### Setup
library(magrittr)
library(dplyr)
library(rml)
library(rutils)
library(highcharter)

### Charts:

tx = readRDS('data/tm_object.rds')
tx$data$dataset$cluster_id = tx$data$CLS

user_subset_train = orders$user_id %>% unique %>% sample(40000)
user_subset_test  = orders$user_id %>% unique %>% setdiff(user_subset_train) %>% sample(2000)


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


## Total Count of products ordered (distribution in logarithmic scale):
a1 = X_train %>% distinct(product_id, TotalProductOrdered) %>% 
  left_join(products_pp) %>% arrange(desc(TotalProductOrdered))
a1$TotalProductOrdered %>% log(base = 10) %>% hist(breaks = 1000)

## For each customer and each product, average days between consequent orders of that product divided by average days between consequent orders make by that customer

a2 = X_train %>% mutate(CustomerProductCycleRate = avgDaysBetweenProductOrders/avgDaysBetweenCustomerOrders) %>% 
  select(user_id, product_id, TotalCountCustomerOrders, TotalProductOrdered, CustomerProductPerOrder, CountCustomerProductOrdered, avgDaysBetweenProductOrders, avgDaysBetweenCustomerOrders, CustomerProductCycleRate) %>% 
  na.omit
View(a2)

## Example:
pid = a2$product_id %>% unique %>% sample(1)
a2 %>% filter(product_id == pid) %>% pull(CustomerProductCycleRate) %>% hist(breaks = 1000)

a3 = a2 %>% 
  group_by(product_id) %>% 
  summarise(AvgProductCycleRate = mean(CustomerProductCycleRate), 
            AvgProductPerOrder = mean(CustomerProductPerOrder)) %>% 
  ungroup

a3 %>% select(AvgProductCycleRate, AvgProductPerOrder) %>% plot()

# 10 Most popular products:
a4 = X_train %>% 
  distinct(product_id, TotalProductOrdered) %>% 
  arrange(desc(TotalProductOrdered)) %>%
  head(10) %>% 
  left_join(products, by = 'product_id') %>% 
  mutate(product_id = factor(product_id, levels = product_id))

a4 %>% plotly::plot_ly(y = ~product_id, x = ~TotalProductOrdered, type = 'bar', text = ~product_name)
    

# 10 Most popular aisles with 10 most popular products in each:
a5 = X_train %>% 
  distinct(aisle_id, AbsoluteAislePopularity) %>% 
  arrange(desc(AbsoluteAislePopularity)) %>% head(10) %>% 
  left_join(X_train %>% distinct(aisle_id, product_id, TotalProductOrdered), by = 'aisle_id') %>% 
  group_by(aisle_id) %>% 
  do({arrange(., desc(TotalProductOrdered)) %>% head(10)}) %>% 
  ungroup %>% 
  mutate(aisle_id = as.character(aisle_id)) %>% 
  left_join(products %>% select(-aisle_id), by = 'product_id')

a5 %>% viser::viserPlot(y = list('aisle_id', 'product_name'), x = 'TotalProductOrdered', type = 'bar', plotter = 'highcharter')


########
# 10 Most popular clusters with 10 most popular products in each:
a6 = X_train %>% 
  distinct(cluster_id, AbsoluteClusterPopularity) %>% 
  arrange(desc(AbsoluteClusterPopularity)) %>% head(10) %>% 
  left_join(X_train %>% distinct(cluster_id, product_id, TotalProductOrdered), by = 'cluster_id') %>% 
  group_by(cluster_id) %>% 
  do({arrange(., desc(TotalProductOrdered)) %>% head(10)}) %>% 
  ungroup %>% 
  mutate(cluster_id = as.character(cluster_id)) %>% 
  left_join(products_pp %>% select(-cluster_id), by = 'product_id')

a6 %>% viser::viserPlot(y = list('cluster_id', 'product_name'), x = 'TotalProductOrdered', type = 'bar', plotter = 'highcharter')

####
# Dispersion of product order counts of the top five departments

a7 = X_train %>% 
  distinct(department_id, AbsoluteDepartmentPopularity) %>% 
  arrange(desc(AbsoluteDepartmentPopularity)) %>% head(5) %>% 
  left_join(X_train %>% distinct(department_id, product_id, TotalProductOrdered), by = 'department_id') %>% 
  group_by(department_id) %>% 
  do({arrange(., desc(TotalProductOrdered))}) %>% 
  ungroup %>% 
  mutate(department_id = as.character(department_id)) %>% 
  left_join(products_pp %>% select(-department_id), by = 'product_id')

a7 %>% 
  mutate(TotalProductOrdered = as.numeric(TotalProductOrdered)) %>% 
  as.data.frame %>% 
  bpexploder::bpexploder(settings = list(groupVar = 'department_id', yVar = 'TotalProductOrdered'))


# Dispersion of product order counts of the top five clusters

a8 = X_train %>% 
  distinct(cluster_id, AbsoluteClusterPopularity) %>% 
  arrange(desc(AbsoluteClusterPopularity)) %>% head(5) %>% 
  left_join(X_train %>% distinct(cluster_id, product_id, TotalProductOrdered), by = 'cluster_id') %>% 
  group_by(cluster_id) %>% 
  do({arrange(., desc(TotalProductOrdered))}) %>% 
  ungroup %>% 
  mutate(cluster_id = as.character(cluster_id)) %>% 
  left_join(products_pp %>% select(-cluster_id), by = 'product_id')

a8 %>% 
  mutate(TotalProductOrdered = as.numeric(TotalProductOrdered)) %>% 
  as.data.frame %>% 
  bpexploder::bpexploder(settings = list(groupVar = 'cluster_id', yVar = 'TotalProductOrdered'))




# Distribution of reorder rates:
# todo: add ProductReorderRate to features
a9 = X_train %>% 
  distinct(product_id, TotalProductOrdered, TotalProductReordered) %>% 
  filter(TotalProductReordered > 0) %>% 
  mutate(ProductReorderRate = TotalProductReordered/TotalProductOrdered) %>% 
  arrange(desc(ProductReorderRate))

a9 %>%
  pull(ProductReorderRate) %>% 
#  log %>% 
  hist(breaks = 1000)

# Idea: cluster the feature and make OHE categorical features from it

a9 %>% pull(ProductReorderRate) %>% density %>% plot 

### 


# Feature cross-correlations:
# ntf: not features
features = colnames(X_train)
ntf = features %>% charFilter('_') 
features %<>% setdiff(ntf)
#cppf: Customer-Product Profile Features:
cppf = features %>% charFilter('customer', 'product') %>% setdiff('TotalCountCustomerProductsOrdered')
features %<>% setdiff(cppf)
#cipf: Customer-Aisle Profile Features:
cipf = features %>% charFilter('customer', 'aisle')
features %<>% setdiff(cipf)
#cdpf: Customer-Department Profile Features:
cdpf = features %>% charFilter('customer', 'Department')
features %<>% setdiff(cdpf)
#ccpf: Customer-Cluster Profile Features:
ccpf = features %>% charFilter('customer', 'Cluster')
features %<>% setdiff(ccpf)
#cpf: Customer Profile Features:
cpf = features %>% charFilter('customer')
features %<>% setdiff(cpf)
#ppf: Product Profile Features:
ppf = features %>% charFilter('product')
features %<>% setdiff(ppf)

########## Correlation Heatmap for Customer-Profile Features
# cpf %<>% setdiff(charFilter(cpf, 'HOD'))
a10 = X_train[cpf] %>% distinct %>% 
  as.matrix %>% {.[(. == Inf) | (. == -Inf)] <- 0;.} %>% 
  cor %>% as.data.frame

a10 %>% d3heatmap::d3heatmap(xaxis_height = 200, xaxis_font_size = 12, yaxis_width = 220, yaxis_font_size = 12)

########## Correlation Heatmap for Product-Profile Features
# ppf %<>% setdiff(charFilter(ppf, 'HOD'))
a11 = X_train[ppf] %>% distinct %>% 
  as.matrix %>% {.[(. == Inf) | (. == -Inf)] <- 0;.} %>% 
  cor %>% as.data.frame

a11 %>% na2zero %>% d3heatmap::d3heatmap(xaxis_height = 200, xaxis_font_size = 12, yaxis_width = 220, yaxis_font_size = 12)

########## Correlation Heatmap for Customer-Profile-Product Features
# cppf %<>% setdiff(charFilter(cppf, 'HOD'))
a12 = X_train[cppf] %>% distinct %>% 
  as.matrix %>% {.[(. == Inf) | (. == -Inf)] <- 0;.} %>% 
  cor %>% as.data.frame

a12 %>% na2zero %>% d3heatmap::d3heatmap(xaxis_height = 200, xaxis_font_size = 12, yaxis_width = 220, yaxis_font_size = 12)

