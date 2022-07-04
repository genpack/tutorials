#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)
source('R_Pipeline/libraries/ext_rml.R')

################ Inputs: ################
config_filename = 'ss_config_01.yml'
  
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}


################ Read: ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'subset_scorer', config_filename, sep = '/')) -> ss_config

verify(ss_config$horizon, c('numeric', 'integer'), default = 3, lengths = 1) -> ss_config$horizon
verify(ss_config$target, 'character', default = 'ERPS', lengths = 1) -> ss_config$target
verify(ss_config$save_best_model, 'logical', default = T) -> ss_config$save_best_model
verify(ss_config$metrics, 'character', default = 'gini') -> ss_config$metrics

ss_path = mc$path_reports %>% paste(id_ml, sep = '/')
if(!file.exists(ss_path)){dir.create(ss_path)}
ss_path %<>% paste('subset_scorer', sep = '/')
if(!file.exists(ss_path)){dir.create(ss_path)}

ss_output <- ss_path %>% paste(ss_config$output, sep = '/')
if(file.exists(ss_output)){
  out = read.csv(ss_output, as.is = T)
} else {
  out = NULL
}

# wt <- WIDETABLE(name = 'wide', path = path.ml)
# wt  %>% saveRDS(sprintf("%s/wide.rds", path.ml))
wt  <- readRDS(sprintf("%s/wide.rds", path_ml))
wt$size_limit = 5e+09

################ Loop: ################
wtcols             = rbig::colnames(wt)
exclude            = c(gss_config$exclude_columns, mc$leakages, 'V1','X', 'caseID', 'eventTime')
features           = wtcols %-% charFilter(wtcols, exclude, and = F)

ylabels   = get_labels(wt, mc, target = ss_config$target, horizon = ss_config$horizon)

for(test_date in ss_config$dates){
  
  dataset = extract_training_dataset(wt, test_date = test_date, features = features, master_config = mc,
                                     target = ss_config$target, horizon = ss_config$horizon,
                                     training_months = ss_config$training_months)
  
  # modlist is the list of models to be trained each containing a random subset of features
  modlist  = list()
  template = ss_config$model
  template$feature_sample_ratio = verify(ss_config$sample_ratio, 'numeric', domain = c(0,1), lengths = 1, default = 0.02)
  templates = list(my_template = template)
  for(j in sequence(ss_config$num_experiments)){
    rml::build_model_from_template(template_name = 'my_template', 
                                   model_name = ss_config$model$name %>% paste(j, sep = '_'), 
                                   features = features, templates = templates) -> model
    
    model$objects[['horizon']] <- ss_config$horizon
    model$objects[['target']]  <- ss_config$target
    model$objects[['start']]   <- min(wt[['eventTime']][ind_train])
    model$objects[['end']]     <- max(wt[['eventTime']][ind_train])
    
    modlist[[model$name]] <- model
  }
  
  res = modlist %>% service_models(dataset$train$X, dataset$train$y, dataset$test$X, dataset$test$y, 
                                   num_cores = ss_config$num_cores, metrics = ss_config$metrics, 
                                   quantiles = ss_config$quantiles)
  if(ss_config$save_best_model){
    res$best_model %>% 
      pipeline.save_model(path_models = mc$path_models %>% paste(id_ml, sep = '/'), 
                          test_date = test_date, target = ss_config$target, horizon = ss_config$horizon)
  }
  
  out %<>% dplyr::bind_rows(res$results)

  out %>% write.csv(sprintf("%s/%s", ss_path, ss_config$output), row.names = F)
}

