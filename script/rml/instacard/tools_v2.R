## Tools for instacard project:
# Version: 2 
# Product Within-Cluster Features Added:

next_last = function(v){
  if(length(v) < 2) return(-1) else return(v[length(v) - 1])
}

uncumsum = function(v){
  nn = length(v)
  if(nn < 2) return(-1) else return(c(v[1], v[-1] - v[-nn]))
}

## input dataset must contain all orders of each customer upto the current order number
build_features = function(dataset){
  dataset %>% 
    mutate(order_hour_of_day = as.numeric(order_hour_of_day)) %>% 
    group_by(user_id, order_number, days_since_prior_order, order_hour_of_day, order_dow) %>% 
    summarise(OrderSize = length(product_id), ## Order Size: Number of products/purchases in an order
              ReorderSize = sum(reordered)) %>% 
    ungroup %>% 
    arrange(user_id, order_number) %>% 
    group_by(user_id) %>% 
    summarise(CustomerPurchaseFrequency  = sum(OrderSize),
              CustomerOrderFrequency     = length(order_number), # TotalCountCustomerOrders
              CustomerReorderFrequency   = sum(ReorderSize), # TotalCountCustomerReorderedProducts
              CustomerAverageOrderGap    = mean(days_since_prior_order, na.rm = T), # CustomerAverageDaysBetweenOrders
              CustomerMaximumOrderGap    = max(days_since_prior_order, na.rm = T), # CustomerMaximumDaysBetweenOrders
              CustomerVarianceOrderGap   = var(days_since_prior_order, na.rm = T),
              CustomerAverageOrderSize   = mean(OrderSize),
              CustomerMaximumOrderSize   = max(OrderSize),
              CustomerMinimumOrderSize   = min(OrderSize),
              CustomerLatestOrderSize    = last(OrderSize),
              CustomerAverageReorderSize = mean(ReorderSize),
              CustomerMaximumReorderSize = max(ReorderSize),
              CustomerLatestReorderSize  = last(ReorderSize),
              CustomerPreferredOrderHour = most_frequent(order_hour_of_day),
              CustomerLatestOrderHour    = max(order_hour_of_day, na.rm = T),
              CustomerEarliestOrderHour = min(order_hour_of_day, na.rm = T),
              CustomerPreferredDOW = most_frequent(order_dow)) %>% 
    mutate(CustomerOrderPace = 1.0/CustomerAverageOrderGap,
           CustomerReorderRate = CustomerReorderFrequency/CustomerPurchaseFrequency) -> customer_orders_behaviour 
  
  # Customer Profile:
  dataset %>% 
    group_by(user_id) %>% 
    summarise(current_order_id     = last(order_id),
              current_order_number = max(order_number),
              current_day_number   = max(day_number),
              CustomerPurchaseDiversity = length(unique(product_id))) %>% 
    ungroup %>% 
    left_join(customer_orders_behaviour, by = 'user_id') %>% 
    na2zero %>% 
    {.[(. == Inf) | (. == -Inf)] <- 0;.} -> customer_profile

  dataset %>% 
    left_join(customer_profile %>% select(user_id, current_order_id), by = 'user_id') %>% 
    arrange(user_id, order_number) %>% 
    group_by(user_id, product_id) %>% 
    summarise(CustomerProductOrderFrequency = length(order_id),
              CustomerProductReorderFrequency = sum(reordered),
              CustomerProductFirstSelectionFrequency = sum(add_to_cart_order == 1),
              CustomerProductFirstTwoSelectionsFrequency = sum(add_to_cart_order < 3),
              CustomerProductFirstThreeSelections = sum(add_to_cart_order < 4),
              CustomerProductAverageOrderGap  = mean(uncumsum(day_number), na.rm = T),
              CustomerProductVarianceOrderGap = var(uncumsum(day_number), na.rm = T),
              CustomerProductIsInCurrentOrder = sum(order_id == current_order_id),
              day_number_last_product_ordered = last(day_number),
              day_number_nextlast_product_ordered = next_last(day_number),
              order_number_last_product_ordered = last(order_number),
              order_number_nextlast_product_ordered = next_last(order_number)) -> customer_product_profile
  
  dataset %>% 
    left_join(customer_profile %>% select(user_id, current_order_id), by = 'user_id') %>% 
    group_by(user_id, aisle_id) %>% 
    summarise(CustomerAisleOrderFrequency = length(order_id),
              CustomerAisleInCurrentOrderFrequency = sum(order_id == current_order_id)) %>% 
    ungroup -> customer_aisle_profile
  
  dataset %>% 
    left_join(customer_profile %>% select(user_id, current_order_id), by = 'user_id') %>% 
    group_by(user_id, department_id) %>% 
    summarise(CustomerDepartmentOrderFrequency = length(order_id),
              CustomerDepartmentInCurrentOrderFrequency = sum(order_id == current_order_id)) %>% 
    ungroup -> customer_department_profile
  
  dataset %>% 
    mutate(order_hour_of_day = as.numeric(order_hour_of_day)) %>% 
    group_by(product_id) %>% 
    summarise(ProductPopularity         = length(order_id), # TotalProductPurchased
              ProductReorderFrequency   = sum(reordered), # TotalProductReordered
              ProductPreferredOrderHour = most_frequent(order_hour_of_day, na.rm = T),
              ProductLatestOrderHour    = max(order_hour_of_day, na.rm = T),
              ProductEarliestOrderHour  = min(order_hour_of_day, na.rm = T),
              ProductPreferredDOW       = most_frequent(order_dow)) %>% 
    ungroup %>% 
    mutate(ProductReorderRate = ProductReorderFrequency/ProductPopularity) %>% 
    left_join(products, by = 'product_id') -> product_profile
  
  customer_product_profile %>% 
    group_by(product_id) %>% 
    summarise(
      ProductAverageOrderGap    = mean(CustomerProductAverageOrderGap),
      ProductFirstSelectionFrequency = sum(CustomerProductFirstSelectionFrequency)) %>% 
    mutate(ProductOrderPace = 1.0/ProductAverageOrderGap) -> product_profile_2
  
  product_profile %<>% left_join(product_profile_2, by = 'product_id')
  
  dataset %>% 
    group_by(aisle_id) %>% 
    summarise(
      AislePopularity = length(order_id),
      AisleReorderFrequency  = sum(reordered)) %>% 
    ungroup -> aisle_profile
  
  dataset %>% 
    group_by(department_id) %>% 
    summarise(
      DepartmentPopularity = length(order_id),
      DepartmentReorderFrequency  = sum(reordered)) %>% 
    ungroup -> department_profile
  
  customer_product_profile %>%
    left_join(product_profile, by = 'product_id') %>% 
    # left_join(products %>% select(product_id, aisle_id, department_id), by = 'product_id') %>% 
    left_join(customer_profile, by = 'user_id') %>% 
    left_join(customer_aisle_profile, by = c('user_id', 'aisle_id')) %>% 
    left_join(customer_department_profile, by = c('user_id', 'department_id')) %>% 
    left_join(aisle_profile, by = 'aisle_id') %>% 
    left_join(department_profile, by = 'department_id') %>% 
    mutate(CustomerProductPerOrder = CustomerProductOrderFrequency/CustomerOrderFrequency,
           CustomerWithinAislePerOrder = CustomerAisleOrderFrequency/CustomerOrderFrequency,
           CustomerWithinDepartmentPerOrder = CustomerDepartmentOrderFrequency/CustomerOrderFrequency,
           CustomerProductPerAisle = CustomerProductOrderFrequency/CustomerAisleOrderFrequency,
           CustomerProductPerDepartment = CustomerProductOrderFrequency/CustomerDepartmentOrderFrequency,
           CustomerProductFirstSelectionRate = ProductFirstSelectionFrequency/CustomerProductOrderFrequency,
           CustomerWithinAisleRate = CustomerAisleOrderFrequency/CustomerPurchaseFrequency,
           CustomerWithinDepartmentRate = CustomerDepartmentOrderFrequency/CustomerPurchaseFrequency,
           CustomerAislePerDepartment = CustomerAisleOrderFrequency/CustomerDepartmentOrderFrequency,
           ProductPerAislePopularity = ProductPopularity/AislePopularity,
           ProductPerDepartmentPopularity = ProductPopularity/DepartmentPopularity,
           AislePerDepartmentPopularity = AislePopularity/DepartmentPopularity,
           DaysSinceLastProductOrdered = day_number_last_product_ordered - day_number_nextlast_product_ordered, 
           OrdersSinceLastProductOrdered = order_number_last_product_ordered - order_number_nextlast_product_ordered - 1) -> X_train
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
  
  products$cluster_id[is.na(products$cluster_id)] <- 0
  
  if(is.null(products$cluster_id)){products$cluster_id <- 1}
  order_products = order_products_prior %>% 
    left_join(products, by = 'product_id') %>%
    left_join(orders %>% 
                # filter(eval_set == 'prior') %>% 
                select(-eval_set) %>% 
                arrange(user_id, order_number) %>% 
                mutate(day_number = days_since_prior_order %>% na2zero) %>% 
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

add_cutpoint_features = function(X_train, orders, cutpoint_orders){
  X_train %>% 
    left_join(cutpoint_orders, by = 'user_id') %>% 
    left_join(orders %>% select(-user_id, -eval_set, -order_number) %>% 
                rename(cutpoint_order_id = order_id, 
                       cutpoint_order_dow = order_dow,
                       cutpoint_order_hod = order_hour_of_day,
                       cutpoint_order_dsp = days_since_prior_order), by = 'cutpoint_order_id')
}


##### Event-Oriented Modelling:

## Create Eventlogs from order_product table:
create_eventlog = function(orders, products, order_products, keywords){
  products$title = products$product_name %>% 
    gsub(pattern = '\\s', replacement = '') %>% 
    gsub(pattern = '-', replacement = '')
  
  # keywords %<>% tolower
  
  # List of keyword products:
  keyword_products = list()
  for(kw in keywords){
    keyword_products[[kw]] <- products$title %>% charFilter(kw)
  }
  
  products_filtered = products %>% 
    dplyr::filter(title %in% unlist(keyword_products)) 

  order_products_filtered = order_products %>% 
    dplyr::filter(product_id %in% products_filtered$product_id) %>% 
    left_join(products_filtered, by = 'product_id') %>% 
    left_join(orders, by = 'order_id')
    
  eventlogs = list()

  # Creating events: ordering products in which keywords are used:
  for(kw in names(keyword_products)){
    cat('\n', 'Creating eventlog for keyword: ', kw, ' ... ')
    order_products_filtered %>% 
      dplyr::filter(title %in% keyword_products[[kw]]) %>% 
      rename(caseID = user_id, eventTime = order_number) %>% 
      group_by(caseID, eventTime) %>% 
      summarise(value = length(product_id)) %>% 
      ungroup %>% 
      mutate(eventType = paste0(kw, 'Ordered'), attribute = 'Count') %>% 
      select(caseID, eventTime, eventType, attribute, value) -> eventlogs[[kw]]
    cat('Done!', '\n')
    
  }
  
  users = order_products_filtered$user_id %>% unique
  orders %>% 
    filter(user_id %in% users) %>% 
    mutate(eventType = 'OrderIssued', attribute = 'DSPO') %>% 
    select(caseID = user_id, eventTime = order_number, eventType, attribute, value = days_since_prior_order) %>% 
    na2zero -> eventlogs[['orders']]
    
  return(eventlogs)
}

create_dynamic_features = function(eventlog, aggregators = c('sum', 'max'), types = c('s', 'e'), win_sizes = c(2,3,6)){
  # eventlog = els$chocolate
  eventlog %>% 
    mutate(eventTime = as.Date('2010-07-01') + eventTime) %>% 
    promer::dfg_pack(event_funs = c('count', 'count_cumsum', 'elapsed', 'tte', 'censored'), 
                     var_funs = c('sum', 'sum_cumsum', 'last'),
                     horizon = 1) -> dfp
  
  swf_tables = c('event_count', 'var_sum', 'var_last')
  dfp %<>% promer::add_swf(tables = swf_tables, aggregators = aggregators, win_sizes = win_sizes)  
  
}

extract_dataset_from_dfpack = function(dfp, target_keyword){
  ftables = names(dfp) %-% c("case_timends", "event_attr_map", "event_time", "event_tte", "event_censored", "event_label")
  df = dfp[[ftables[1]]]
  for(tn in ftables[-1]){
    df %<>% left_join(dfp[[tn]], by = c('caseID', 'eventTime'))
  }
  
  return(list(X = df, y = dfp$event_label[[sprintf("%sOrdered_label", target_keyword)]]))
}

