# Convert orders to eventlog:
library(dplyr)
library(magrittr)
library(promer)
library(rutils)

### In this module we test a special type of modelling where we use all product orders to build the training data
# product id, here, becomes a categorical feature and there is only one target: probability of the 
# product type in the feature being in the next customer order or not. 
# So we convert a multi-class classification model into a binary classification.
# In this modelling, each product for each customer is one training row in the dataset and for each customer, 
# we only include products that the customer has at least ordered once.
# If we include all products for all customers both train and test sets will be huge and the target becomes extremely imbalanced.

# Disadvantages:
# You cannot include customer's behaviour in regards to other products as features for predicting a particular product

# Advantages:
# One model for all products rather than multiple models for multile products
# Fewer features but long training dataset

##### Features: What features can we make for such a model?

### Time of order features:
# dow of the order for which existence of the product is being predicted
# hod of the order for which existence of the product is being predicted

### Customer Behaviour Features with regards to the product:
## Count of product ordered so far by customer: CountProductOrdered
## Percentage customer product ordered (# product ordered by customer/total count of orders by customer)

## flag: product existed in the last customer's order

## Out of the last n orders made by the customer, what percentage of them included the product? (n = 2,3,4,5,6, ..., 10)
## as n increases, we face more cases that the customer has less than n orders in total. 
## This makes the values in these features non-realistic. Best to use missing values masking and let model decide 

# How many products from the product aisle has been ordered so far
# Percentage of orders including at least one product from the aisle/total count of orders
# Similar for the last n orders

# percentage of orders in which the product was the first selected product by customer
# percentage of this within the last n orders

# percentage of orders in which the product was among the first three selected products by customer
# percentage of this within the last n orders

# The most frequent dow on which the product was ordered
# the most frequent hod at which the product was ordered

#### Product-Specific Features: (Behaviour of all customers in regards to the product):
## total count of the product being ordered (Absolute Popularity)
## Percentage of the product being ordered within the associated aisle (Within-aisle Relative Popularity)
# (total count of the product being ordered/total count of products ordered from the associated aisle)
## Percentage of the product being ordered within the associated department (Within-Department Relative Popularity)
# (total count of the product being ordered/total count of products ordered from the associated department)
## These features can be defined for each individual customer as well:
## For example: customer within aisle relative popularity, customer within department relative popularity

#### aisle-Specific Features: (Behaviour of all customers in regards to the aisle associated with the product):
# (Similar to product-specific features we can define:
# aisle absolute popularity
# within-department aisle relative popularity
#### Department-Specific Features: (Behaviour of all customers in regards to the aisle associated with the product):

## NLP based product clustering:
## We can define various metrics based on similarity of terms used in the product name. Best metric is binary metric
## Run a multi-dimensional scaling to give coordinates to the products in a multi-dim space and cluster them
## These coordinates can be used as features as well
# (a product is represented by a k-dimensional vector where k is number of customers!)
# Features can be genertated from each of these metrics using multi-dim scaling

### Features Based on a product clustering, we can define more customer-product based features :
# within-cluster relative popularity 
# total count of customer orders from the associated cluster plus percentage to total orders
# total count of customer orders within the last n orders

## Let's just select a sample subset of customers to shrink data size. We will build data with full size later:

customer_subset = orders$user_id %>% unique %>% sample(10000)

orders$days_since_prior_order[is.na(orders$days_since_prior_order)] <- 0

next_last = function(v){
  if(length(v) < 2) return(NA) else return(v[length(v) - 1])
}

uncumsum = function(v){
  nn = length(v)
  c(v[1], v[-1] - v[-nn])
}

########
order_products = order_products_prior %>% 
  left_join(products, by = 'product_id') %>%
  left_join(orders %>% 
              filter(eval_set == 'prior') %>% 
              select(-eval_set) %>% 
              arrange(user_id, order_number) %>% 
              mutate(day_number = days_since_prior_order) %>% 
              rutils::column.cumulative.forward(col = 'day_number', id_col = 'user_id')
            , by = 'order_id') %>% 
  filter(user_id %in% customer_subset)

# File order_products is our main source of data: we build all the features by aggregating this table

## Split for labeling:
# Since orders exact dates are not known, we need to 
# pick an order number (maybe randomly) for each customer as the last order number 
# up to the cutpoint for labeling.
# For example for a customer x, if we pick order number 6 as the cutpoint,
# then we use information in orers 1 to 5 to create features for that customer at that point in time
# and contents of order 6 is used to generate label for the training dataset for that customer.
# 
# If last order is picked as cutpoint (rather than random), 
# we will have the maximum number of rows in the training data. 
# However, we can pick multiple order numbers as labeling cut-point and 
# generate training data based on those picked cutpoint order numbers.
# Then row bind the generated training datasets to make a bigger and richer training dataset. 
# Here we only use the last orders as cutpoints and generate one trainig dataset from that:

order_products %>% 
  arrange(user_id, order_number) %>% 
  group_by(user_id) %>% 
  summarise(cutpoint_order_number = max(order_number),
            cutpoint_order_id = last(order_id)) %>% 
  ungroup -> cutpoint_orders

order_products %<>% 
  left_join(cutpoint_orders, by = 'user_id') %>% 
  mutate(flag_label = order_number == cutpoint_order_number,
         flag_feature = order_number < cutpoint_order_number)
  
ind_features = which(order_products$flag_feature)
ind_labels   = which(order_products$flag_label)

######
# Customer Profile:
order_products[ind_features, ] %>% 
  group_by(user_id) %>% 
  summarise(TotalCountCustomerProductOrders = length(order_id),
            current_order_id = last(order_id),
            current_order_number = max(order_number),
            current_day_number = max(day_number),
            TotalCountCustomerOrders = max(order_number),
            avgDaysBetweenCustomerOrders = mean(days_since_prior_order, na.rm = T),
            medDaysBetweenCustomerOrders = median(days_since_prior_order, na.rm = T),
            maxDaysBetweenCustomerOrders = max(days_since_prior_order, na.rm = T),
            minDaysBetweenCustomerOrders = min(days_since_prior_order, na.rm = T),
            sdvDaysBetweenCustomerOrders = sd(days_since_prior_order, na.rm = T)) -> customer_profile

# Customer-aisle profile:
order_products[ind_features, ] %>% 
  group_by(user_id, aisle_id) %>% 
  summarise(CountCustomerWithinAisleOrdered = length(order_id)) %>% 
  ungroup -> customer_aisle_profile

# Customer-department profile:
order_products[ind_features, ] %>% 
  group_by(user_id, department_id) %>% 
  summarise(CountCustomerWithinDepartmentOrdered = length(order_id)) -> customer_department_profile

# Product Profile:
order_products[ind_features, ] %>% 
  group_by(product_id) %>% 
  summarise(TotalProductOrdered = length(order_id),
            TotalProductReordered = sum(reordered)) %>% 
  ungroup -> product_profile

# Aisle Profile:
order_products[ind_features, ] %>% 
  group_by(aisle_id) %>% 
  summarise(AbsoluteAislePopularity = length(order_id),
            TotalWithinAisleReorders = sum(reordered)) %>% 
  ungroup -> aisle_profile

# Department Profile:
order_products[ind_features, ] %>% 
  group_by(department_id) %>% 
  summarise(AbsoluteDepartmentPopularity = length(order_id),
            TotalWithinDepartmentReorders = sum(reordered)) %>% 
  ungroup -> department_profile

# Feature 1:
# CountProductOrdered:
order_products[ind_features, ] %>% 
  left_join(customer_profile, by = 'user_id') %>% 
  arrange(user_id, order_number) %>% 
  group_by(user_id, product_id, aisle_id, department_id) %>% 
  summarise(CountCustomerProductOrdered = length(order_id),
            CountCustomerProductReordered = sum(reordered),
            CountCustomerProductFirstSelection = sum(order_number == 1),
            CountCustomerProductFirstTwoSelections = sum(order_number < 3),
            CountCustomerProductFirstThreeSelections = sum(order_number < 4),
            ProductInCurrentCustomersOrder = sum(order_id == current_order_id),
            day_number_last_product_ordered = last(day_number),
            day_number_nextlast_product_ordered = next_last(day_number),
            order_number_last_product_ordered = last(order_number),
            order_number_nextlast_product_ordered = next_last(order_number),
            avgDaysBetweenProductOrders = mean(uncumsum(day_number), na.rm = T),
            medDaysBetweenProductOrders = median(uncumsum(day_number), na.rm = T),
            maxDaysBetweenProductOrders = max(uncumsum(day_number), na.rm = T),
            minDaysBetweenProductOrders = min(uncumsum(day_number), na.rm = T),
            sdvDaysBetweenProductOrders = sd(uncumsum(day_number), na.rm = T)
  ) %>% 
  ungroup %>% 
  left_join(customer_aisle_profile, by = c('user_id', 'aisle_id')) %>% 
  left_join(customer_department_profile, by = c('user_id', 'department_id')) %>% 
  left_join(product_profile, by = 'product_id') %>% 
  left_join(aisle_profile, by = 'aisle_id') %>% 
  left_join(department_profile, by = 'department_id') %>% 
  left_join(customer_profile, by = 'user_id')  -> train_data
  

### Computed Features: relative poularities, percentages, ratios and rates ...
train_data %>%
  mutate(CustomerProductPerOrder = CountCustomerProductOrdered/TotalCountCustomerOrders,
         CustomerProductPerAisle = CountCustomerProductOrdered/CountCustomerWithinAisleOrdered,
         CustomerProductPerDepartment = CountCustomerProductOrdered/CountCustomerWithinDepartmentOrdered,
         CustomerProductFirstSelectionRate = CountCustomerProductFirstSelection/CountCustomerProductOrdered,
         CustomerWithinAisleRate = CountCustomerWithinAisleOrdered/TotalCountCustomerProductOrders,
         CustomerWithinDepartmentRate = CountCustomerWithinDepartmentOrdered/TotalCountCustomerProductOrders,
         CustomerAislePerDepartment = CountCustomerWithinAisleOrdered/CountCustomerWithinDepartmentOrdered,
         ProductPerAislePopularity = TotalProductOrdered/AbsoluteAislePopularity,
         ProductPerDepartmentPopularity = TotalProductOrdered/AbsoluteDepartmentPopularity,
         AislePerDepartmentPopularity = AbsoluteAislePopularity/AbsoluteDepartmentPopularity,
         DaysSinceLastProductOrdered = day_number_last_product_ordered - day_number_nextlast_product_ordered, 
         OrdersSinceLastProductOrdered = order_number_last_product_ordered - order_number_nextlast_product_ordered - 1) -> train_data_2

## Add label:
train_data_2 %>% 
  left_join(order_products[ind_labels, c('user_id', 'product_id', 'reordered')], by = c('user_id', 'product_id')) %>% 
  mutate(label = as.numeric(!is.na(reordered))) %>% 
  select(- reordered) -> train_data_3

train_data_3 %>% 
  left_join(cutpoint_orders, by = 'user_id') %>% 
  left_join(orders %>% select(-user_id, -eval_set, -order_number) %>% 
              rename(cutpoint_order_id = order_id, 
                     cutpoint_order_dow = order_dow,
                     cutpoint_order_hod = order_hour_of_day,
                     cutpoint_order_dsp = days_since_prior_order), by = 'cutpoint_order_id') -> train_data_4
  
  
### If customer will orders again, 
# we probably don't know in how many days ahead he/she will order and in which day of week and hour of day will he order 
# So, we cannot use these three features: cutpoint_order_dow, cutpoint_order_hod and cutpoint_order_dsp for training
# However, sometimes we want to find probabilities of order as a function of such information.
# For example we may want to know if next order happens in n days ahead, 
# how does probabilities of one particular product is impacted by n.
# A requirement for such analysis to be meaningful is that 
# 1- a model is trained using such information as features: 
#   (number of days ahead next order will happen, dow next order, hod next order)
# 2- these features come out as very significant or important features. 
# In other words, model performance should be significantly different with and without any of these features.
# We first train a model without these three columns:


 
### Test dataset:

