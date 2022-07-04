# Run all saved models:

#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)
source('R_Pipeline/libraries/ext_rml.R')
################ Inputs ################
config_filename = 'rsm_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('run_saved_models', config_filename, sep = '/')) -> rsm_config
verify(rsm_config$add_train_performance, 'logical', default = F) -> rsm_config$add_train_performance

output_file = mc$path_reports %>% paste(id_ml, 'run_saved_models', sep = '/')
if(!file.exists(output_file)){dir.create(output_file)}
output_file %<>% paste(rsm_config$output, sep = '/')

################ Read & Validate config ################

################ Read Data ################
wt <- readRDS(sprintf("%s/wide.rds", path_ml))
wt$size_limit = 5e+09

################ Run ################
targets = list.files(mc$path_models %>% paste(id_ml, sep = '/'))
if(!is.null(rsm_config$targets)) {targets %<>% intersect(rsm_config$targets)}
for(tn in targets){
  tnp = paste(mc$path_models,id_ml, tn, sep = '/')
  horizons = list.files(tnp)
  if(!is.null(rsm_config$horizons)) {horizons %<>% intersect(paste0('H', rsm_config$horizons))}
  for(hn in horizons){
    yls = get_labels(wt, mc, tn, hn %>% gsub(pattern = 'H', replacement = '') %>% as.integer)
    hnp = paste(tnp, hn, sep = '/')
    dates = list.files(hnp)
    if(!is.null(rsm_config$dates)) {dates %<>% intersect(rsm_config$dates)}
    for(dt in dates){
      dtp = paste(hnp, dt  , sep = '/')
      ind = which(wt[['eventTime']] == dt)
      
      y_test = yls[ind]
      
      models = list.files(dtp)
      if(!is.null(rsm_config$models)) {models %<>% intersect(rsm_config$models)}
      for(mn in models){
        model_load(model_name = mn, path = dtp) -> model
        model_features(model) %^% colnames(wt) -> features
        X_test  = wt[ind, features]
        "Model %s with target %s tested at %s:" %>% sprintf(model$name, tn, dt) %>% cat('\n')
        
        pf_test = get_performance_metrics(model = model, X = X_test, y = y_test, metrics = metrics, quantiles = quantiles, do_print = T)
        if(rsm_config$add_train_performance){
          pf_train = get_performance_metrics(model = model, X = X_train, y = y_train, metrics = metrics, quantiles = quantiles, do_print = F)
        } else {pf_train = numeric()}

        # Add more info for the log table:
        pf_test['rate_test']   <- mean(y_test)
        pf_test['nrow_test']   <- length(y_test)
        
        hr = verify(model$objects$horizon, c('numeric', 'integer'), default = 3)
        chif(file.exists(output_file), read.csv(output_file, as.is = T, colClasses = c(time_trained = 'character')), data.frame()) %>% 
          log_prediction_run(model   = model, target = tn, 
                             horizon = hr,
                             train_date_from = chif(is.null(model$objects$start), NA, model$objects$start %>% as.character), 
                             train_date_to   = dt %>% add_month(- hr),
                             test_date = dt, performance_test = pf_test, performance_train = pf_train) %>% 
          write.csv(output_file, row.names = F)
      }
    }
  }
}