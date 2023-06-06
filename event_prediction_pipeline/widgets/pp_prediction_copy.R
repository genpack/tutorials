# copy_prediction
#### Setup #####
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/io_tools.R')

## Copy ElpyPipe Prediction Output to Local:

################ Inputs ################
config_filename = 'pp_prediction_copy.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> cpr_config


if(!is.null(cpr_config$prediction_runs)){
  cpr_config$add_results <- verify(cpr_config$add_results, 'logical', lengths = 1, default = T)
  
  runs = read.csv(cpr_config$prediction_runs, stringsAsFactors = F) %>% filter(state == 'SUCCEEDED')
  
  ind_runs = runs %>% nrow %>% sequence
  str_time = lubridate::as_datetime(runs$start)
  if(!is.null(cpr_config$min_start_date)){
    ind_runs = which(str_time >= cpr_config$min_start_date) %>% intersect(ind_runs)
  }
  
  if(!is.null(cpr_config$max_start_date)){
    ind_runs = which(str_time <= cpr_config$max_start_date) %>% intersect(ind_runs)
  }
  
  ################ Run ################
  
  for(i in ind_runs){
    copy_prediction_to_local(mc, agentrun_id = runs$agentrunid[i], modelrun_id = runs$runid[i])
    if(cpr_config$add_results){
      resultpath = mc$path_prediction %>% 
        paste(runs$agentrunid[i] %>% substr(1,8),
              runs$runid[i] %>% substr(1,8),
              'scores.json', sep = '/')
      
      result = jsonlite::read_json(resultpath)
      
      for(mtrc in names(result)){
        if(inherits(result[[mtrc]], 'list')){
          for(cm in names(result[[mtrc]])){
            runs[i, cm] <- result[[mtrc]][[cm]]
          }
        } else {
          runs[i, mtrc] <- result[[mtrc]]
        }
      }
    }
  }  
  
  if (cpr_config$add_results){write.csv(runs, cpr_config$prediction_runs, row.names = F)}

}

for (item in cpr_config$runids) {
  copy_prediction_to_local(mc, agentrun_id = item$agent_runid, modelrun_id = item$model_runid)
}

