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
    arrange(user_id, order_number) %>% 
    distinct(user_id, order_number, days_since_prior_order) %>% 
    group_by(user_id) %>% 
    summarise(avgDaysBetweenCustomerOrders = mean(days_since_prior_order, na.rm = T),
              varDaysBetweenCustomerOrders = var(days_since_prior_order, na.rm = T)) %>% 
    ungroup -> customer_order_pace
    
  # Customer Profile:
  dataset %>% 
    group_by(user_id) %>% 
    summarise(TotalCountCustomerProductsOrdered = length(product_id),
              current_order_id = last(order_id),
              current_order_number = max(order_number),
              current_day_number = max(day_number),
              TotalCountCustomerOrders = max(order_number),
              TotalCountCustomerReorders = sum(reordered),
              avgCustomerOrderHOD = mean(order_hour_of_day %>% as.numeric, na.rm = T),
              maxCustomerOrderHOD = max(order_hour_of_day %>% as.numeric, na.rm = T),
              minCustomerOrderHOD = min(order_hour_of_day %>% as.numeric, na.rm = T),
              avgCustomerOrderDOW = mean(order_dow),
              modCustomerOrderDOW = most_frequent(order_dow)) %>% 
    ungroup %>% 
    left_join(customer_order_pace, by = 'user_id') -> customer_profile
  
  # Customer-aisle profile:
  dataset %>% 
    group_by(user_id, aisle_id) %>% 
    summarise(CountCustomerWithinAisleOrdered = length(order_id)) %>% 
    ungroup -> customer_aisle_profile
  
  # Customer-department profile:
  dataset %>% 
    group_by(user_id, department_id) %>% 
    summarise(CountCustomerWithinDepartmentOrdered = length(order_id)) -> customer_department_profile

  # Customer-Cluster profile: (By cluster we mean product cluster)
  dataset %>% 
    group_by(user_id, cluster_id) %>% 
    summarise(CountCustomerWithinClusterOrdered = length(order_id)) %>% 
    ungroup -> customer_cluster_profile

  # Product Profile:
  dataset %>% 
    group_by(product_id) %>% 
    summarise(TotalProductOrdered = length(order_id),
              TotalProductReordered = sum(reordered),
              avgProductOrderHOD = mean(order_hour_of_day %>% as.numeric, na.rm = T),
              maxProductOrderHod = max(order_hour_of_day %>% as.numeric, na.rm = T),
              minProductOrderHod = min(order_hour_of_day %>% as.numeric, na.rm = T),
              varProductOrderHod  = var(order_hour_of_day %>% as.numeric, na.rm = T),
              avgProductOrderDOW = mean(order_dow),
              modProductOrderDOW = most_frequent(order_dow),
              varProductOrderDOW = var(order_dow)
    ) %>% 
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

  # Cluster Profile:
  dataset %>% 
    group_by(cluster_id) %>% 
    summarise(AbsoluteClusterPopularity = length(order_id),
              TotalWithinClusterReorders = sum(reordered)) %>% 
    ungroup -> cluster_profile

  
  # Feature 1:
  # CountProductOrdered:
  dataset %>% 
    left_join(customer_profile, by = 'user_id') %>% 
    arrange(user_id, order_number) %>% 
    group_by(user_id, product_id, aisle_id, department_id, cluster_id) %>% 
    summarise(CountCustomerProductOrdered = length(order_id),
              CountCustomerProductReordered = sum(reordered),
              CountCustomerProductFirstSelection = sum(order_number == 1),
              CountCustomerProductFirstTwoSelections = sum(order_number < 3),
              CountCustomerProductFirstThreeSelections = sum(order_number < 4),
              IsProductInCurrentCustomersOrder = sum(order_id == current_order_id),
              day_number_last_product_ordered = last(day_number),
              day_number_nextlast_product_ordered = next_last(day_number),
              order_number_last_product_ordered = last(order_number),
              order_number_nextlast_product_ordered = next_last(order_number),
              avgDaysBetweenProductOrders = mean(uncumsum(day_number), na.rm = T),
              varDaysBetweenProductOrders = var(uncumsum(day_number), na.rm = T)
    ) %>% 
    ungroup %>% 
    left_join(customer_aisle_profile, by = c('user_id', 'aisle_id')) %>% 
    left_join(customer_department_profile, by = c('user_id', 'department_id')) %>% 
    left_join(customer_cluster_profile, by = c('user_id', 'cluster_id')) %>% 
    left_join(product_profile, by = 'product_id') %>% 
    left_join(aisle_profile, by = 'aisle_id') %>% 
    left_join(department_profile, by = 'department_id') %>% 
    left_join(cluster_profile, by = 'cluster_id') %>% 
    left_join(customer_profile, by = 'user_id')  -> train_data
  
  
  ### Computed Features: relative poularities, percentages, ratios and rates ...
  train_data %>%
    mutate(CustomerProductPerOrder = CountCustomerProductOrdered/TotalCountCustomerOrders,
           CustomerWithinAislePerOrder = CountCustomerWithinAisleOrdered/TotalCountCustomerOrders,
           CustomerWithinDepartmentPerOrder = CountCustomerWithinDepartmentOrdered/TotalCountCustomerOrders,
           CustomerWithinClusterPerOrder = CountCustomerWithinClusterOrdered/TotalCountCustomerOrders,
           CustomerProductPerAisle = CountCustomerProductOrdered/CountCustomerWithinAisleOrdered,
           CustomerProductPerDepartment = CountCustomerProductOrdered/CountCustomerWithinDepartmentOrdered,
           CustomerProductPerCluster = CountCustomerProductOrdered/CountCustomerWithinClusterOrdered,
           CustomerProductFirstSelectionRate = CountCustomerProductFirstSelection/CountCustomerProductOrdered,
           CustomerWithinAisleRate = CountCustomerWithinAisleOrdered/TotalCountCustomerProductsOrdered,
           CustomerWithinDepartmentRate = CountCustomerWithinDepartmentOrdered/TotalCountCustomerProductsOrdered,
           CustomerWithinClusterRate = CountCustomerWithinClusterOrdered/TotalCountCustomerProductsOrdered,
           CustomerAislePerDepartment = CountCustomerWithinAisleOrdered/CountCustomerWithinDepartmentOrdered,
           ProductPerAislePopularity = TotalProductOrdered/AbsoluteAislePopularity,
           ProductPerDepartmentPopularity = TotalProductOrdered/AbsoluteDepartmentPopularity,
           ProductPerClusterPopularity = TotalProductOrdered/AbsoluteClusterPopularity,
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
  if(is.null(products$cluster_id)){products$cluster_id <- 1}
  products$cluster_id[is.na(products$cluster_id)] <- 0
  
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

