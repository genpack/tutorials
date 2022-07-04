# ppcg_prediction_best_hpo.R
# This module, generates epp prediction config of the best model in a given hpo job. 
# You can also make some changes to the config as well by setting parameter 'changes' in the config.
# This module uses a config file epp_best_hpo.yml in the configs/widgets/

###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')
source('R_Pipeline/libraries/io_tools.R')

config_filename = 'ppcg_prediction_best_hpo.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}
###### Read: ######
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

scores = read_prediction_scores(mc, config$input_agent_runid, config$input_model_runid, children = T, as_table = T)

verify(config$dates, 'character', default = "") -> config$dates
verify(config$num_seeds, c('numeric', 'integer'), domain = c(1, 1000), lengths = 1, default = 1) -> config$num_seeds
verify(config$performance_metric, 'character', lengths = 1, 
       # domain = c('gini_coefficient', 'lift_2', 'precision_2'), 
       default = 'gini_coefficient') -> config$performance_metric

###### Pick Best Model's Config: ######
ind_best = scores[, config$performance_metric] %>% order(decreasing = T) %>% {.[1]}
mid_best = rownames(scores)[ind_best]
read_prediction_configs(mc, config$input_agent_runid, mid_best) -> pc
###### Build Config: ######

for(test_date in config$dates){
  out = pc %>% list.extract('dataset', 'mode', 'optimise', 'verbose', 'max_memory_GB')
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
      models = list(pc$model %>% rutils::list.remove('features')))
  } else {
    out$model = pc$model
  }
  

  out %<>% rutils::list.edit(config$changes)
  
  out$model$features <- pc$model$features 
  
  yaml::write_yaml(out, pp_config_filename(config$output_path, cname))
}
