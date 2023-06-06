#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)
source('R_Pipeline/libraries/ext_rml.R')
################ Inputs ################
config_filename = 'retrain_saved_model.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'prediction', config_filename, sep = '/')) -> prd_config
prd_config %<>% verify_prediction_config

################ Read Data ################
# wt <- WIDETABLE(name = 'wide', path = path_ml)
# wt  %>% saveRDS(sprintf("%s/wide.rds", path_ml))
wt <- readRDS(sprintf("%s/wide.rds", path_ml))
wt$size_limit = prd_config$size_limit


for(test_date in prd_config$dates){
  
  features = prd_config$features %>% 
    extract_feature_names(mc, target = prd_config$target, 
                          horizon = prd_config$horizon, 
                          test_date = test_date) %>% 
    intersect(colnames(wt))
  
  exclude = charFilter(features, c(prd_config$exclude_columns, mc$leakages), and = F)
  features %<>% setdiff(exclude)
  
  ################ Build Model ################
  prd_config$model %>% 
    build_model_from_config(mc, 
                            target = prd_config$target, 
                            horizon = prd_config$horizon, 
                            test_date = test_date) -> model
  model_make_unique_transformer_names(model)
  
  model$objects[['horizon']] <- prd_config$horizon
  model$objects[['target']]  <- prd_config$target
  
  features %<>% union(model_features(model))
  ################ Train & Test data ################
  # date_train = test_date %>% add_month(- prd_config$horizon)
  # 
  # if(is.null(prd_config$training_months)){
  #   ind_train  = which(wt[['eventTime']] <= date_train)
  # } else {
  #   ind_train %<>% intersect(which(wt[['eventTime']] >  add_month(date_train, - prd_config$training_months)))
  # }
  # 
  # ind_test   = which(wt[['eventTime']] == test_date)
  # 
  # X_train  = wt %>% extract.widetable(ind_train, features)
  # ylabels  = get_labels(wt, mc, target = prd_config$target, horizon = prd_config$horizon)
  # dataset$train$y  = ylabels[ind_train]
  # 
  # dataset$test$X  = wt %>% extract.widetable(ind_test, features) %>% rbig::as.data.frame()
  # dataset$test$y  = ylabels[ind_test]
  dataset = extract_training_dataset(wt, test_date = test_date, features = features, master_config = mc,
                                     target = prd_config$target, horizon = prd_config$horizon,
                                     training_months = prd_config$training_months)
  
  model$objects[['start']]   <- min(dataset$train$ID[['eventTime']], na.rm = T)
  model$objects[['end']]     <- max(dataset$train$ID[['eventTime']], na.rm = T)
  model$config$cv.set        <- list(dataset$test)
################ Train, evaluate and Save Model ################
  
  model$fit(dataset$train$X, dataset$train$y)
  # model$performance(dataset$test$X, dataset$test$y)
  # model$performance(dataset$test$X, dataset$test$y, 'lift', 0.02)
  
  prd_config$save_model %<>% verify('logical', default = T)
  if(prd_config$save_model){
    pipeline.save_model(model, path_models = mc$path_models %>% paste(id_ml, sep = '/'), test_date = test_date, target = prd_config$target, horizon = prd_config$horizon)
  }
  
  pf_test = get_performance_metrics(model = model, X = dataset$test$X, y = dataset$test$y, metrics = metrics, quantiles = quantiles, do_print = T)
  if(prd_config$add_train_performance){
    pf_train = get_performance_metrics(model = model, X = dataset$train$X, y = dataset$train$y, metrics = metrics, quantiles = quantiles, do_print = F)
  } else {pf_train = numeric()}
    

  # Add more info for the log table:
  pf_train['rate_train']  <- mean(dataset$train$y)
  pf_train['nrow_train']  <- length(dataset$train$y)
  pf_test['rate_test']   <- mean(dataset$test$y)
  pf_test['nrow_test']   <- length(dataset$test$y)

  if(prd_config$save_run){
    runs_path = mc$path_reports %>% paste(id_ml, sep = '/')
    if(!file.exists(runs_path)) {dir.create(runs_path)}
    runs_path %<>% paste('prediction', sep = '/')
    if(!file.exists(runs_path)) {dir.create(runs_path)}
    
    runs_path = runs_path %>% paste('runs.csv', sep = '/')
    chif(file.exists(runs_path), read.csv(runs_path, as.is = T, colClasses = c(time_trained = 'character')), data.frame()) %>% 
      log_prediction_run(model = model, target = prd_config$target, 
                         horizon = prd_config$horizon,
                         train_date_from = min(dataset$train$ID$eventTime, na.rm = T) %>% as.character, 
                         train_date_to   = max(dataset$train$ID$eventTime, na.rm = T) %>% as.character, 
                         test_date = test_date, performance_test = pf_test, performance_train = pf_train) %>% 
      write.csv(runs_path, row.names = F)
  }
}

