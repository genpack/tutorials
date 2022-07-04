# Read EPP configs, modify them and save again
##### SETUP: ####
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')

##### INPUTS: ####
################ Inputs ################
config_filename = 'ppcg_from_ppc.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> cm_config

##### RUN: ####
if(!file.exists(cm_config$path_output)){
  dir.create(cm_config$path_output)
}

if(!is.null(cm_config$agentrun_id) & !is.null(cm_config$modelrun_id)){
  config = read_prediction_configs(mc, agentrun_id = cm_config$agentrun_id, modelrun_id = cm_config$modelrun_id)
} else {
  assert(file.exists(cm_config$path_input), paste('Given path', cm_config$path_input ,'does not exist!'))
  
  if(is.null(cm_config$input_format)){cm_config$input_format = 'json'}
  if(cm_config$input_format == 'json'){
    config_address = sprintf("%s/%s.json", cm_config$path_input, 'config')
    config_address %>% file.exists %>% assert(sprintf('File %s does not exist', config_address))
    config = jsonlite::read_json(config_address)
  } else {
    config_address = sprintf("%s/%s.yml", cm_config$path_input, 'config')
    config_address %>% file.exists %>% assert(sprintf('File %s does not exist', config_address))
    config = yaml::read_yaml(config_address)
  }
}


for(cn in names(cm_config$changes)){
  config[[cn]] <- config[[cn]] %>% list.edit(cm_config$changes[[cn]])
}

### Save modified Config
sprintf("%s/%s.yml", cm_config$path_output, 'config') %>% yaml::write_yaml(x = config)  


