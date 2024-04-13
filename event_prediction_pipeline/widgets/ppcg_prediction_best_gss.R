# Rscript R_Pipeline/widgets/ppcg_prediction_best_gss.R 

# This module, generates epp prediction config of the best model in a given gss job. 
# You can also make some changes to the config as well by setting parameter 'changes' in the config.
# This module uses a config file epp_best_gss.yml in the configs/widgets

###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')
source('R_Pipeline/libraries/io_tools.R')

config_filename = 'ppcg_prediction_best_gss.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}
###### Read: ######
# Read feature scores:
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

if(is.null(config$input_prediction_config)){
  config$input_prediction_config = list()
  sprintf("%s/prediction/agentrun=%s/modelrun=%s/config.json", 
          mc$path_data, 
          config$input_agent_runid,
          config$input_model_runid) -> config$input_prediction_config$filename
  config$input_prediction_config$filetype = 'json'
  if(!file.exists(config$input_prediction_config$filename)){
    copy_prediction_to_local(mc, agentrun_id = config$input_agent_runid, modelrun_id = config$input_model_runid)
  }
}

prd_config = read_file(config$input_prediction_config)

if(is.null(config$input_scores$filename)){
  sprintf("%s/prediction/agentrun=%s/modelrun=%s/raw_scores.csv", 
          mc$path_data, 
          config$input_agent_runid,
          config$input_model_runid) -> config$input_scores$filename
  
} else {
  reports_gss_path = sprintf("%s/%s/greedy_subset_scorer", mc$path_reports, id_ml)
  config$input_scores$filename %<>% find_file(paths = reports_gss_path)
}

config$input_scores$filename %>% bigreadr::fread2() -> scores
if(!is.null(config$input_scores$operation)){
  scores %<>% rutils::operate(config$input_scores$operation)
}
scores$test_date %<>% as.character
if(is.null(config$gss_dates)){
  config$gss_dates = unique(scores$test_date)
}

verify(config$dates, 'character', default = "") -> config$dates
verify(config$num_seeds, c('numeric', 'integer'), domain = c(1, 1000), lengths = 1, default = 1) -> config$num_seeds
verify(config$ranking_metric, 'character', lengths = 1, 
       domain = c('model_performance', 'feature_score'), 
       default = 'feature_score') -> config$ranking_metric
verify(config$performance_metric, 'character', lengths = 1, 
       default = 'gini_coefficient') -> config$performance_metric

###### Pick Features: ######

if(config$ranking_metric == 'model_performance'){
  config$num_models <- verify(config$num_models, c('numeric', 'integer'), lengths = 1, domain = c(1, Inf), default = 1) %>% as.integer
  scores %>% 
    dplyr::distinct(model_id, test_date, batch_number, .keep_all = T) %>% 
    filter(test_date %in% config$gss_dates) %>% 
    arrange(test_date, desc(!!sym(config$performance_metric))) %>% 
    group_by(test_date) %>% 
    do({.[sequence(config$num_models),]}) %>% ungroup -> bm
  
  scores %>% filter(model_id %in% bm$model_id) %>% 
    mutate(score = importance*!!sym(config$performance_metric)) %>% 
    filter(score > 0) %>% arrange(desc(score)) %>% 
    pull(fname) %>% unique -> fset
  
  if(!is.null(config$num_features)){fset %<>% head(config$num_features)}
  
} else if (config$ranking_metric == 'feature_score'){
  config$num_features <- verify(config$num_features, c('numeric', 'integer'), lengths = 1, domain = c(1, Inf), default = 900) %>% as.integer
  scores %>% 
    mutate(score = importance*!!sym(config$performance_metric)) %>% 
    group_by(fname) %>% summarise(max_score = max(score)) %>% 
    filter(max_score > 0) %>% arrange(desc(max_score)) %>% head(config$num_features) %>% 
    pull(fname) -> fset
}

###### Build Config: ######

for(test_date in config$dates){
  out = prd_config %>% list.extract('dataset', 'mode', 'optimise', 'verbose', 'max_memory_GB')
  if(!is.null(config$mlsampler_id)){out$dataset = config$mlsampler_id}
  if(test_date != ""){
    cname = paste(config$output_name, test_date, sep = '_')
    out$train = paste('train', test_date, sep = '_')
    out$test  = paste('test' , test_date, sep = '_')
  } else {cname = config$output_name}
  
  if(config$num_seeds > 1){
    out$model = list(
      name = 'Ensemblers.local.Averaging', 
      transforms = list(
        Y_transforms = list(list(ellib.Transformations.local.ClassificationTarget = c())),
        X_transforms = list()),
      parameters = list(
        num_models = list(config$num_seeds %>% as.integer),
        seed = sequence(config$num_seeds),
        partial = T,
        persist_predictions = T
      ),
      models = list(prd_config$model %>% rutils::list.remove('features')))
  } else {
    out$model = prd_config$model
  }
  

  out %<>% rutils::list.edit(config$changes)
  
  out$model$features <- fset 
  
  yaml::write_yaml(out, pp_config_filename(config$output_path, cname))
}
