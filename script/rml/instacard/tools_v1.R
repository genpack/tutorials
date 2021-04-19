## Tools for instacard project:

next_last = function(v){
  if(length(v) < 2) return(NA) else return(v[length(v) - 1])
}

uncumsum = function(v){
  nn = length(v)
  c(v[1], v[-1] - v[-nn])
}

## input dataset must contain all orders of each customer upto the current order number
build_features = function(dataset){
  # Customer Profile:
  dataset %>% 
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
  dataset %>% 
    group_by(user_id, aisle_id) %>% 
    summarise(CountCustomerWithinAisleOrdered = length(order_id)) %>% 
    ungroup -> customer_aisle_profile
  
  # Customer-department profile:
  dataset %>% 
    group_by(user_id, department_id) %>% 
    summarise(CountCustomerWithinDepartmentOrdered = length(order_id)) -> customer_department_profile
  
  # Product Profile:
  dataset %>% 
    group_by(product_id) %>% 
    summarise(AbsoluteProductPopularity = length(order_id),
              TotalProductReorders = sum(reordered)) %>% 
    ungroup -> product_profile
  
  # Aisle Profile:
  dataset %>% 
    group_by(aisle_id) %>% 
    summarise(AbsoluteAislePopularity = length(order_id),
              TotalWithinAisleReorders = sum(reordered)) %>% 
    ungroup -> aisle_profile
  
  # Department Profile:
  dataset %>% 
    group_by(department_id) %>% 
    summarise(AbsoluteDepartmentPopularity = length(order_id),
              TotalWithinDepartmentReorders = sum(reordered)) %>% 
    ungroup -> department_profile
  
  # Feature 1:
  # CountProductOrdered:
  dataset %>% 
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
           ProductPerAislePopularity = AbsoluteProductPopularity/AbsoluteAislePopularity,
           ProductPerDepartmentPopularity = AbsoluteProductPopularity/AbsoluteDepartmentPopularity,
           AislePerDepartmentPopularity = AbsoluteAislePopularity/AbsoluteDepartmentPopularity,
           DaysSinceLastProductOrdered = day_number_last_product_ordered - day_number_nextlast_product_ordered, 
           OrdersSinceLastProductOrdered = order_number_last_product_ordered - order_number_nextlast_product_ordered - 1)
}

# input id_set is dataset containing user_id and product_id
# input cutpoint_dataset must have the same columns as dataset passed to function build_features()
build_labels = function(id_set, label_dataset){
  id_set %>% 
    left_join(label_dataset[, c('user_id', 'product_id', 'reordered')], by = c('user_id', 'product_id')) %>% 
    mutate(label = as.numeric(!is.na(reordered))) %>% 
    pull(label)
}

build_training_pack = function(orders, products, order_products_prior, cutpoint_split = 'last_order', customer_subset = NULL){
  order_products = order_products_prior %>% 
    left_join(products, by = 'product_id') %>%
    left_join(orders %>% 
                # filter(eval_set == 'prior') %>% 
                select(-eval_set) %>% 
                arrange(user_id, order_number) %>% 
                mutate(day_number = days_since_prior_order) %>% 
                rutils::column.cumulative.forward(col = 'day_number', id_col = 'user_id')
              , by = 'order_id')
  if(!is.null(customer_subset)){
    order_products %<>% filter(user_id %in% customer_subset)
  }
  
  ### Pick cutpoint order numbers:
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
  
  cat('\n', '%s rows total, %s rows for feature aggregation, %s rows for labeling, %s rows removed!' %>% 
        sprintf(nrow(order_products), 
                length(ind_features),
                length(ind_labels),
                nrow(order_products) - length(ind_features) - length(ind_labels)))

  return(list(feature_dataset = order_products[ind_features,], label_dataset = order_products[ind_labels,], cutpoint_orders = cutpoint_orders))
}
