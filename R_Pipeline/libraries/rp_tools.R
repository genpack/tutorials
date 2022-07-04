# Nsn82mKYaEKuodPq30qF
#### Some functions: ####

extract_feature_names = function(config, master_config = NULL, ...){
  if(is.null(config)) {return(NULL)}
  fset = character()
  for(item in config){
    if(inherits(item, 'character')){
      fset = c(fset, item)
    } else if (inherits(item, 'list')){
      if((length(item) == 1) & inherits(item[[1]], 'character')) {fset = c(fset, item)} else {
        filename = item$file
        filetype = verify(item$type, 'character', lengths = 1, domain = c('json', 'csv'), default = 'csv')
        if(!is.null(item$file)){
          filename %<>% find_file(paths = c(sprintf("%s/%s", master_config$path_reports, id_ml),
                                           sprintf("%s/%s", master_config$path_mlmapper, id_ml)))
          if(filetype == 'csv'){
            flist = paste(filename, sep = '/') %>% bigreadr::fread2(stringsAsFactor = F)
          } else {
            flist = paste(filename, sep = '/') %>% jsonlite::fromJSON()
          }
        } else if(!is.null(item$model)){
          item$model$reset = FALSE
          item$model %>% build_model_from_config(master_config, ...) -> model
          flist = model$objects$features
        }

        if(!is.null(item$operation)) flist %<>% rutils::operate(item$operation)
        fset = c(fset, flist)
        # index = order(flist[[item$score_col]], decreasing = item$decreasing)
        # fset = c(fset, flist[index[sequence(item$num_top)], item$name_col])
      }
    }
  }

  fset %>% unique
}

log_prediction_run = function(pred_log = data.frame(), model, train_date_from, train_date_to, test_date, performance_test, performance_train = NULL, target = 'ERPS', horizon = 3){
  
  nn = nrow(pred_log) + 1
  pred_log[nn, 'model_name']    = model$name
  pred_log[nn, 'model_type']    = model$description
  pred_log[nn, 'model_package'] = model$package
  pred_log[nn, 'target']        = target
  pred_log[nn, 'horizon']       = horizon
  pred_log[nn, 'train_from']    = train_date_from
  pred_log[nn, 'train_to']      = train_date_to
  pred_log[nn, 'test_at']       = test_date
  pred_log[nn, 'num_features']  = model$objects$features %>% nrow
  pred_log[nn, 'time_trained']  = model$objects$fitting_time %>% as.character
  
  for(mtrc in names(performance_test)){
    pred_log[nn, mtrc] <- performance_test[mtrc]
  }
  if(!is.empty(performance_train)){
    for(mtrc in names(performance_train)){
      pred_log[nn, mtrc %>% paste('train', sep = '_')] <- performance_train[mtrc]
    }
  }
  
  return(pred_log)
}

get_performance_metrics = function(pf = numeric(), model, X, y, do_print = T, ...){
  yp = try(model$predict(X)[,1], silent = T)
  if(!inherits(yp, 'try-error')){
    pf = correlation(yp, y, ...) %>% unlist
    if(do_print) {cat('\n'); print(pf)}
    return(pf)
  } else {
    cat('\n', yp, '\n')
  }
}

get_labels = function(wt, master_config, target = 'ERPS', horizon = 3){
  target = verify(target, 'character', domain = names(master_config$target))
  horizon_adjust = verify(master_config$target[[target]][['horizon_adjust']], domain = c(0,1), lengths = 1, default = 0)
  
  columns = rbig::colnames(wt)
  
  if(!is.null(master_config$target[[target]][['tte']])){
    tte = wt[[master_config$target[[target]][['tte']]]]
    if(!is.null(master_config$target[[target]][['censored']])){
      uncensored = wt[[master_config$target[[target]][['censored']]]] %>% as.logical %>% {!.}
    } else if(!is.null(master_config$target[[target]][['uncensored']])){
      uncensored = wt[[master_config$target[[target]][['uncensored']]]] %>% as.logical
    } else {
      stop("tte specified without censored or uncensored column!")
    }
  } else if (!is.null(master_config$target[[target]][['label']])) {
    cat('Warning: Binary labels are directly read from ML-Mapper. Horizon is ignored!!', '\n')
    return(wt[[master_config$target[[target]][['label']]]] %>% as.logical %>% as.integer)
  } else {
    stop("Label columns not found in the ML-Mapper!")
  }
  return(as.integer(uncensored & (tte < horizon + horizon_adjust + 1)))
}

verify_prediction_config = function(config){
  assert(verify(config$dates, 'character', null_allowed = F) %>% as.Date %>% is.na %>% sum == 0, 
         'Unrecognized date format!')
  
  verify(config$save_run, 'logical', default = T) -> config$save_run
  verify(config$training_months, c('numeric', 'integer'), null_allowed = T) -> config$training_months
  verify(config$add_train_performance, 'logical', default = F) -> config$add_train_performance
  verify(config$horizon, c('numeric', 'integer'), default = 3, lengths = 1) -> config$horizon
  verify(config$target, 'character', default = 'ERPS', lengths = 1) -> config$target
  verify(config$size_limit, 'numeric', default = 5e+09, lengths = 1) -> config$size_limit
  
  verify(config$features, c('character', 'list'))
  
  
  return(config)
}

# Basic verification of model config
verify_model_config =function(config){
  verify(config$class, 'character', lengths = 1, null_allowed = F)
  
  if(config$class %>% gsub(pattern = '_', replacement = '') %>% tolower == 'savedmodel'){
    verify(config$path, 'character', lengths = 1, default = '')
    verify(config[['name']], 'character', lengths = 1, null_allowed = F)
    if(!is.null(config$path)){
      assert(file.exists(config$path %>% paste(config[['name']], sep = '/')), 
             sprintf('Model path %s/%s does not exist!', config$path, config[['name']]))
    }
    config$reset %<>% verify('logical', domain = c(T,F), lengths = 1, default = T)
  }
    
  return(config)
}

verify_master_config = function(config){
  return(config)
}

build_model_from_config = function(config, master_config = NULL, ...){
  
  config %<>% verify_model_config
  
  model_config = config %>% 
    list.remove('name', 'class', 'reset', 'path', 'transformers', 'gradient_transformers', 'features', 'exclude_features')
    
  if(config$class %>% gsub(pattern = '_', replacement = '') %>% tolower == 'savedmodel'){
    if(is.null(config$path)){
      aug_config = list(...)
      if(is.null(config$target)){config$target <- aug_config$target}
      if(is.null(config$test_date)){config$test_date <- aug_config$test_date}
      if(is.null(config$horizon)){config$horizon <- aug_config$horizon}
      config$path = sprintf("%s/%s/%s/%s/%s", 
                            master_config$path_models, 
                            master_config$mlmapper_id %>% substr(1,8), 
                            config$target, 
                            paste0('H', config$horizon),
                            config$test_date)
    }
    model = model_load(config[['name']], config$path)
    if(inherits(config$rename, 'character')){
      model$name <- config$rename
    }
    model$config <- model$config %<==>% list.remove(config, c('name', 'rename', 'class', 'reset', 'path', 'target', 'test_date', 'horizon'))
    if(model$fitted){
      if(config$reset){
        model$reset(reset_transformers = T, reset_gradient_transformers = T, set_features.include = T)
      }
    }
    if(!is.null(config[['features']]) & is.null(config[['features.include']])){
      model$config$features.include <- config[['features']] %>% extract_feature_names(master_config)
    }
    if(!is.null(config[['exclude_features']]) & is.null(config[['features.exclude']])){
      model$config$features.exclude <- config[['exclude_features']] %>% extract_feature_names(master_config)
    }
  } 
  
  else if(config$class %>% gsub(pattern = '_', replacement = '') %>% tolower == 'savedmodeltransformers'){
    if(is.null(config$path)){
      aug_config = list(...)
      if(is.null(config$target)){config$target <- aug_config$target}
      if(is.null(config$test_date)){config$test_date <- aug_config$test_date}
      if(is.null(config$horizon)){config$horizon <- aug_config$horizon}
      config$path = sprintf("%s/%s/%s/%s/%s", 
                            master_config$path_models, 
                            master_config$mlmapper_id %>% substr(1,8), 
                            config$target, 
                            paste0('H', config$horizon),
                            config$test_date)
    }
    mother = model_load(config[['name']], config$path)
    if(config$reset){
      for(tr in mother$transformers){
        if(tr$fitted){
           tr$reset(reset_transformers = T, reset_gradient_transformers = T, set_features.include = T)
           tr$config <- tr$config %<==>% list.remove(config, c('name', 'rename', 'class', 'reset', 'path', 'target', 'test_date', 'horizon'))
        }
      }
    } else {
      for(tr in mother$transformers){
        # todo: more config parameters may be added
        for(cn in names(config) %>% intersect(c('return'))){
          tr$config[[cn]] <- config[[cn]]
        }
      }
    model = mother$transformers
  }} 
  
  else if(config$class %>% gsub(pattern = '_', replacement = '') %>% tolower == 'modeltemplate'){
    tempset = yaml::read_yaml(config$template_config)
    if(inherits(config$features, 'character')){
      featset = config$features
    } else {
      featset = config[['features']] %>% extract_feature_names(master_config)
    }
    model = list()
    for(i in sequence(config$num_models %>% verify(c('numeric', 'integer'), lengths = 1, default = 1) %>% as.integer)){
      model = c(model, build_model_from_template(template_name = config$template_name, model_name = config$model_name, templates = tempset, features = featset, metric = config$features$score_col))
    }
  }
  
  else {
    model = new(config$class, config = model_config)
    if(!is.null(config[['name']])){
      model$name <- config[['name']]
    }
    if(!is.null(config[['features']]) & is.null(config[['features.include']])){
      model$config$features.include <- config[['features']] %>% extract_feature_names(master_config)
    }
    if(!is.null(config[['exclude_features']]) & is.null(config[['features.exclude']])){
      model$config$features.exclude <- config[['exclude_features']] %>% extract_feature_names(master_config)
    }
  }
  
  for(cfg in config$transformers){
    # nt = length(model$transformers)
    # model$transformers[[nt + 1]]  <- build_model_from_config(cfg)
    model$transformers  <- c(model$transformers, build_model_from_config(cfg, master_config, ...))
  }

  for(cfg in config$gradient_transformers){
    nt = length(model$gradient_transformers)
    model$gradient_transformers[[nt + 1]]  <- build_model_from_config(cfg, master_config, ...)
  }
  
  return(model)
}

# Converts prediction run log table from python pipeline to r-pipeline format
convert_prediction_log = function(runs){
  for(i in sequence(nrow(runs))){
      spl = runs$description[i] %>% strsplit('_') %>% unlist
      
      runs[i, 'target'] = spl[1]
      runs[i, 'test_at'] = spl[2]
      runs[i, 'model_name'] = c('EPP', spl[-(1:2)]) %>% paste(collapse = '_')
      runs[i, 'train_to'] = spl[2] %>% add_month(-3)
  }
  runs %<>% mutate(time_trained = lubridate::as_datetime(end), horizon = 3, model_type = NA, model_package = NA, train_from = NA, num_features = NA,
                   train_gini = NA, train_precision = NA, rate_train = NA, rate_test = 0.01*Churn_Rate_pct,
                   nrow_train = NA, nrow_test = NA) %>% 
    rename(gini = gini_coefficient, lift2p = lift_2, precision2p = precision_2, loss = log_loss)
  
  runs$lift = runs[, 'Lift_.Churn_Rate']
  runs$precision = runs[, 'Precision_.Churn_Rate']
  
  runs %>% select(model_name, model_type, model_package, target, horizon, train_from, train_to, test_at, 
                  num_features, time_trained, gini, precision, lift, loss, lift2p, precision2p, 
                  train_gini, train_precision, rate_train, nrow_train, rate_test, nrow_test)
}  

pipeline.save_model = function(model, path_models, test_date, target = 'ERPS', horizon  = 3){
  if(!file.exists(path_models)){dir.create(path_models)}
  target_path = path_models %>% paste(target, sep = '/')
  if(!file.exists(target_path)) dir.create(target_path)
  horizon_path = paste(target_path, paste0('H', horizon), sep = '/')
  if(!file.exists(horizon_path)) dir.create(horizon_path)
  
  model %>% rml::model_save(paste(horizon_path, test_date, sep = '/'))
}

find_file = function(filename, paths = NULL){
  filepath = filename
  isthere = file.exists(filepath)
  
  np = length(paths)
  i  = 0
  while(!isthere & (i < np)){
    i = i + 1
    filepath = paste(paths[i], filename, sep = '/')
    isthere = file.exists(filepath)
  }
  assert(isthere, 'File(s) not found: ', paste0(paths, '/', filename, '\n'))
  return(filepath)
}

service_models = function(modlist, X_train, y_train, X_test, y_test, num_cores = 1, metrics = 'gini', quantiles = NULL){
  modlist %<>% rml::fit_models(X = X_train, y = y_train, num_cores = num_cores, verbose = 1)
  names(modlist) <- modlist %>% rutils::list.pull('name')
  
  yy = rml::predict_models(modlist, X = X_test, num_cores = num_cores, verbose = 1)
  pf = rml::correlation(yy, y_test, metrics = metrics, quantiles = quantiles)
  
  assert(length(pf) == length(modlist), 'Some models failed to predict!')
  
  pfdf = pf %>% lapply(unlist) %>% purrr::reduce(rbind) %>% as.data.frame %>% {rownames(.)<-names(modlist);.}
  print(pfdf)
  
  
  modlist %>% lapply(function(x) x$objects$features %>% mutate(model = x$name, fitting_time = as.character(x$objects$fitting_time))) %>% 
    purrr::reduce(dplyr::bind_rows) %>% 
    left_join(pfdf %>% rownames2Column('model')) -> ptab
  
  ord = order(ptab[[names(pf[[1]])[1]]], decreasing = T)[1]
  
  return(list(best_model = modlist[[ptab$model[ord]]], best_performance = max(ptab[[names(pf[[1]])[1]]]), results = ptab))
}

extract_training_dataset = function(wt, test_date, features, master_config, target = 'ERPS', horizon = 3, training_months = NULL){
  date_train = test_date %>% add_month(- horizon)
  
  ind_train  = which(wt[['eventTime']] <= date_train)
  if(!is.null(training_months)){
    ind_train %<>% intersect(which(wt[['eventTime']] >  add_month(date_train, - training_months)))
  }
  
  ind_test   = which(wt[['eventTime']] == test_date)
  
  X_train  = wt %>% extract.widetable(ind_train, features)
  ylabels  = get_labels(wt, master_config, target = target, horizon = horizon)
  y_train  = ylabels[ind_train]
  
  X_test  = wt %>% extract.widetable(ind_test, features) %>% rbig::as.data.frame()
  y_test  = ylabels[ind_test]
  return(list(train = list(ID = wt[ind_train, c('caseID', 'eventTime')], X = X_train, y = y_train), test = list(ID = wt[ind_test, c('caseID', 'eventTime')], X = X_test, y = y_test)))
}

read_file = function(file_config){
  if(file_config$filetype == 'json'){
    out = jsonlite::read_json(file_config$filename)
  } else if (file_config$filetype == 'csv'){
    out = bigreadr::fread2(file_config$filename)
  }
  if(!is.null(file_config$operation)){
    out %<>% rutils::operate(file_config$operation)
  }
  return(out)
}

# estimate downsampled dataset size:
train_dataset_info = function(wt, n_months = 12, test_date = '2020-01-01', dns_rate = NULL, n_features = NULL){
  wt[c('eventTime', 'label')] %>% group_by(eventTime) %>% 
    summarise(n_pos = sum(label), n_row = length(label)) %>% 
    ungroup -> info
  
  if(is.null(n_features)){n_features = rbig::ncol(wt)}
  
  to   = test_date %>% rutils::add_month(-3)
  from = to %>% rutils::add_month(- n_months)
  
  info %<>% filter(eventTime >= from, eventTime <= to) %>% 
    mutate(n_neg = n_row - n_pos, n_cell = n_row*n_features/1000000, rate = n_pos/n_row)
    
  if(!is.null(dns_rate)){
    info %<>% 
      mutate(n_neg_dns = n_neg*dns_rate) %>% 
      mutate(n_row_dns = n_neg_dns + n_pos) %>% 
      mutate(n_cell_dns = n_row_dns*n_features/1000000, rate_dns = n_pos/n_row_dns)
  }
  return(info)
}

stepwise_model_selector = function(probs_df, aggregator = max, metric = 'precision', quantile = 0.02, verbose = 0){
  children = colnames(probs_df) %-% c('caseID', 'eventTime', 'label')
  perf     = rml::correlation(x = probs_df[children] %>% as.data.frame, 
                              y = probs_df[['label']], 
                              metrics = metric, quantiles = quantile) %>% unlist
  
  for (child in children){
    perf[child] = rml::correlation(probs_df[[child]], probs_df[['label']], metrics = metric, quantiles = quantile)
  }
  
  ordered_children = names(perf)[perf %>% order(decreasing = T)]
  
  new_selected     = ordered_children[1]
  new_performance  = perf[new_selected]
  best_performance = new_performance
  remained = children %-% new_selected
  
  i = 1
  while(i < length(remained)){
    if (new_performance > best_performance & verbose > 0){
      cat('\n', "Better Performance Found: %s --> %s. Ensemble Size: %s" %>% 
            sprintf(best_performance, new_performance, length(new_selected)), "\n")
    }
    selected = new_selected
    best_performance = new_performance
    children = sample(children, length(children))
    remained = children %-% selected
    while(new_performance <= best_performance & i < length(remained)){
      new_selected    = c(selected, remained[i])
      new_performance = probs_df[new_selected] %>% as.matrix %>% apply(1, aggregator) %>% rml::correlation(probs_df$label, metric = metric, quantiles = quantile) 
      if(verbose > 1){
        cat("\n", "i: %s, New Performance: %s, Best Performance: %s" %>% sprintf(i, new_performance, best_performance))
      }
      i = i + 1
    }
  }
  return(list(selected = selected, performance = best_performance))
}
