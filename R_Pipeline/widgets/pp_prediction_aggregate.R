# Rscript R_Pipeline/widgets/pp_prediction_aggregate.R
# This module, aggregates probabilities of the xgboost models run in the python pipeline.

###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')
source('R_Pipeline/libraries/io_tools.R')

config_filename = 'pp_prediction_aggregate.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}
###### Read: ######
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

verify(config$metrics, 'character', 
       domain = c('gini', 'lift_2pc', 'precision_2pc'), 
       default = 'gini') -> config$metrics

###### Pick Best Models and Read Probabilities: ######
probs  = NULL
for(mdl in config[['models']]){
  if(mdl$pick == 'single_model'){
    pp  = read_prediction_probs(mc, agentrun_id = mdl$agent_runid, modelrun_id = mdl$model_runid)
    pp$agent_runid = mdl$agent_runid
    pp$model_runid = mdl$model_runid
    probs %<>% dplyr::bind_rows(pp)
  } else if(mdl$pick == 'best_children'){
    ids = pp_best_children(mc, agentrun_id = mdl$agent_runid, modelrun_id = mdl$model_runid, metrics = mdl$metrics, num_children = mdl$num_children)
    
    pps = ids %>% purrr::map(read_prediction_probs, master_config = mc, agentrun_id = mdl$agent_runid, children = F)
    
    names(pps) <- ids
    
    for(mid in names(pps)){
      pps[[mid]]$agent_runid = mdl$agent_runid
      pps[[mid]]$model_runid = mid
      probs %<>% dplyr::bind_rows(pps[[mid]])
    }
  } else if(mdl$pick == 'orchestration'){
    mdl$children <- verify(mdl$children, 'logical', default = F)
    op = read_orchestration_probs(mc, orchestration_id = mdl$orchestration_id, children = mdl$children)
    if(mdl$children){
      for (mid in names(op)){
        op[[mid]]$orchestration_id = mdl$orchestration_id
        probs %<>% dplyr::bind_rows(op[[mid]])
      }
    } else{
      op$orchestration_id = mdl$orchestration_id
      probs %<>% dplyr::bind_rows(op)
    }
  }
}

########

probs_agg = probs %>% 
  group_by(orchestration_id, caseID, eventTime) %>% 
  summarise(maxProb = max(probability), minProb = min(probability), avgProb = mean(probability), medProb = median(probability)) %>% 
  ungroup %>% left_join(probs %>% distinct(orchestration_id, caseID, eventTime, label), by = c('orchestration_id', 'caseID', 'eventTime'))

probs_agg %>% group_by(orchestration_id, eventTime) %>% 
  summarise(gini_coefficient  = correlation(probability, label, 'gini'),
            lift_2 = correlation(probability, label, 'lift', 0.02)) %>% 
  ungroup



