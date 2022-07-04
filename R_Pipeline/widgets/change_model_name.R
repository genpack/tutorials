# Module change_model_name:
#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rml', version = rml.version)

################ Inputs ################
config_filename = 'cmn_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('change_model_name', config_filename, sep = '/')) -> cmn_config
cmn_config$remove_old_model = verify(cmn_config$remove_old_model, 'logical', default = T)
runs_file = paste(mc$path_report, id_ml, 'prediction', 'runs.csv', sep = '/')
if(file.exists(runs_file)){runs = runs_file %>% read.csv -> runs} else {runs = NULL}

################ Run: ################
for(test_date in cmn_config$dates){
  model_path = mc$path_models %>% paste(id_ml, cmn_config$target, paste0('H', cmn_config$horizon), test_date, sep = '/')
  assert(file.exists(model_path), paste('Model path', model_path, 'does not exist!'))
  model_addr = model_path %>% paste(cmn_config$old_name, sep = '/')
  if(file.exists(model_addr)){
    model_load(model_name = cmn_config$old_name, path = model_path) -> model
    model$name = cmn_config$new_name
    
    if(cmn_config$remove_old_model) shell(glue::glue("rmdir /s /q \"{model_addr}\" "))
    
    model %>% model_save(path = model_path)
  }
}

if(!is.null(runs)){
  ind = which((runs$target == cmn_config$target) & 
                (runs$horizon == cmn_config$horizon) & 
                (runs$test_at %in% cmn_config$dates) & 
                (runs$model_name == cmn_config$old_name))
  runs$model_name[ind] <- cmn_config$new_name
  
  runs %>% write.csv(paste(mc$path_report, 'prediction', 'runs.csv', sep = '/'), row.names = F)  
}

