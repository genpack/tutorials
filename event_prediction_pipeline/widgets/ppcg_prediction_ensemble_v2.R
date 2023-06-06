# Rscript R_Pipeline/widgets/ppcg_prediction_ensemble_v2.R
# This module, generates epp prediction config of an ensemble model containing multiple models of various kinds, 
# features and hyper-parameters. 
# You can also make some changes to all the configs as well by setting parameter 'changes' in the config.
# This module uses a config file ppcg_prediction_ensemble.yml in the configs/widgets/
# v2: generates config for version tags/version=8.0.0 and after (major change in the configs structure)

###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')
source('R_Pipeline/libraries/io_tools.R')

config_filename = 'ppcg_prediction_ensemble.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}
###### Read: ######
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

verify(config$dates, 'character', default = "") -> config$dates
verify(config$num_seeds, c('numeric', 'integer'), domain = c(1, 1000), lengths = 1, default = 10) -> config$num_seeds
verify(config$metrics, 'character', 
       # domain = c('gini_coefficient', 'lift_2', 'precision_2', 'lift_5'), 
       default = 'gini_coefficient') -> config$metrics

###### Pick Best Model's Configs: ######
bag  = list()
sds  = c()
base = NULL
for(mdl in config[['models']]){
  if(mdl$pick == 'single_model'){
    pc  = read_prediction_configs(mc, agentrun_id = mdl$agent_runid, modelrun_id = mdl$model_runid)
    bag[[length(bag) + 1]] <- pc$model
    sds = c(sds, mdl$num_seeds)
    if(is.null(base)){base = pc}
  } else if(mdl$pick == 'best_children'){
    
    ids = pp_best_children(mc, agentrun_id = mdl$agent_runid, modelrun_id = mdl$model_runid, metrics = mdl$metrics, num_children = mdl$num_children)

    pcs = ids %>% 
      purrr::map(read_prediction_configs, master_config = mc, agentrun_id = mdl$agent_runid, children = F) %>% 
      purrr::map(function(u) u[['model']])
    bag = bag %<==>% pcs
    sds = c(sds, rep(mdl$num_seeds, length(pcs)))
    if(is.null(base)){base = pcs[[1]]}
  }
}
sds %<>% as.integer()
###### Build Config: ######

for(test_date in config$dates){
  out = base %>% list.extract('dataset', 'mode', 'optimise', 'verbose', 'version', 'max_memory_GB', 'timeout')
  if(!is.null(config$mlsampler_id)){out$dataset = config$mlsampler_id}
  if(test_date != ""){
    cname = paste(config$output_name, test_date, sep = '_')
    out$train = paste('train', test_date, sep = '_')
    out$test  = paste('test' , test_date, sep = '_')
  } else {cname = config$output_name}
  
  
  out$model = list(
    classifier = list(
        type = 'AveragingEnsembler', 
        parameters = list(
          num_models = sds,
          seed = as.integer(sequence(sum(sds)) - 1)
        ),
        models = bag))
  
  out %<>% rutils::list.edit(config$changes)
  
  out$model$features <- bag %>% list.pull('features') %>% unique
  
  out %<>% rutils::list.edit(config$changes)
  
  yaml::write_yaml(out, pp_config_filename(config$output_path, cname))
}
