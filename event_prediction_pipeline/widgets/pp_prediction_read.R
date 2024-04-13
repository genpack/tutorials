# Rscript R_Pipeline/widgets/pp_prediction_read.R 

# This module, reads scores, configs and feature importances of multiple prediction run_ids and combine them in a data frame. 

###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')
source('R_Pipeline/libraries/io_tools.R')

config_filename = 'pp_prediction_read.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}
###### Read: ######
# Read widget config:
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

scores = NULL
for(mdl in config$models){
  if(is.null(mdl$children)) {mdl$children = F}
  if(is.null(mdl$model_name)) {mdl$model_name = ''}
  
  if(!is.null(mdl$orchestration_id)){
    si = try(read_orchestration_scores(mc, orchestration_id = mdl$orchestration_id, metrics = config$metrics), silent = T)
    if(inherits(si, 'data.frame')){
      si %>% 
        dplyr::mutate(model_name = mdl$model_name, orchestration_id = mdl$orchestration_id) %>% 
        dplyr::mutate(test_at = gsub(id, pattern = paste0(mdl$model_name, "_"), replacement = "")) %>% 
        dplyr::relocate(orchestration_id, job_id = id, model_name, agent_runid = runid, model_runid) %>% 
        dplyr::bind_rows(scores) -> scores
    } else {cat(as.character(si), '\n')}
  }
  if(!is.null(mdl$agent_runid) & !is.null(mdl$model_runid)){
    si = try(read_prediction_scores(mc, agentrun_id = mdl$agent_runid, modelrun_id = mdl$model_runid, metrics = config$metrics, children = mdl$children, as_table = T), silent = T)
    if(inherits(si, 'data.frame')){
      si %>% 
        mutate(model_name = mdl$model_name,
               agent_runid = mdl$agent_runid,
               model_runid = mdl$model_runid) %>% 
        dplyr::relocate(model_name, agent_runid, model_runid) %>% 
        dplyr::bind_rows(scores) -> scores
    } else {cat(as.character(si), '\n')}
  }
}

if(is.null(config$output_filepath)){
  config$output_filepath <- sprintf("%s/%s/prediction", mc$path_reports, id_ml)
}

write.csv(scores, config$output_filepath %>% paste(config$output_filename, sep = '/'))


# scores %>% select(model_name, agent_runid, model_runid, gini_coefficient, lift_2) %>% View
