#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
################ Inputs ################
config_filename = 'em_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'event_mapper', config_filename, sep = '/')) -> em_config

# emap_config %<>% verify_emap_config

################ Read Data ################
for(step in em_config$steps){
  # Read input files:
  input_data = list()
  for (fn in step$input){
    if(!file.exists(fn)){
      fnp = mc$path_preprocessing %>% paste(em_config$preprocessing_id, paste(fn, 'rds', sep = '.'), sep = '/')
      if(!file.exists(fnp)){stop(sprintf("file %s not found", fnp))}
    } else {fnp = fn}
    readRDS(fnp) -> input_data[[fn]]
  }
  
  if(!file.exists(mc$path_eventmapper)){dir.create(mc$path_eventmapper)}
  outpath = paste(mc$path_eventmapper, em_config$output_id, sep = '/')
  if(!file.exists(outpath)){dir.create(outpath)}
  outpath %<>% paste(step$output %++% '.rds', sep = '/')
  input_data[[step$input[[1]]]] %>% operate(step$operation) %>% saveRDS(outpath)
}
