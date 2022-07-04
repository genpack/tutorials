# prediction_config_creation
##### SETUP: ####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
load_package('rml', version = rml.version)

source('R_Pipeline/libraries/epp_tools.R')
source('R_Pipeline/libraries/epp.R')

################ Inputs ################
config_filename = 'ppcg_prediction.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> pcg_config

##### RUN: ####
assert(file.exists(pcg_config$path_output), paste(pcg_config$path_output, 'does not exist!'))

read.csv(pcg_config$mlsampler_runs) -> runs

runs %<>% filter(state == "SUCCEEDED") %>% 
  mutate(description = gsub(description, pattern = paste0(mc$mlmapper_id %>% substr(1,8), '_'), replacement = "")) %>% 
  filter(description %in% pcg_config$dates) %>% arrange(desc(start)) %>% distinct(description, .keep_all = T) %>% 
  column2Rownames('description')

warnif(nrow(runs) < length(pcg_config$dates), paste('No sampler exists', 'for these dates:', paste(pcg_config$dates %-% rownames(runs), collapse = ',')))
if(nrow(runs) > 0){
  yaml::read_yaml(pcg_config$prediction_config) -> prd_config

  wt <- readRDS(sprintf("%s/wide.rds", path_ml))
  
  wtcols   = rbig::colnames(wt)
  exclude  = charFilter(wtcols, c(prd_config$exclude_columns, mc$leakages), and = F)
  features = prd_config$features %>% extract_feature_names(mc) %>% 
    intersect(wtcols) %>% setdiff(exclude)
  
  prd_config$model %>% build_model_from_config(mc) -> model
  parameters = prd_config$model %>% list.remove(model$reserved_words) %>% list.remove(c('class', 'name'))
  for(test_date in pcg_config$dates){
    cfg_model = do.call('CFG.ELLIB.XGB', 
                        list.add(name = prd_config$model$name,  
                                 parameters = parameters, 
                                 features = features, 
                                 config = list(dataset = runs[test_date, 'runid'])))
    
    outpath = pcg_config$path_output %>% paste(paste('ERPS', test_date, prd_config$model$name, sep = '_'), sep = '/')
    
    if(!file.exists(outpath)){dir.create(outpath)}
    
    cfg_model$write.epp_config(filename = 'config.yml', path = outpath)
  }
}


  