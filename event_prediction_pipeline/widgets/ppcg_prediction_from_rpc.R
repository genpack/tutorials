# R-Pipeline to El Python Pipeline config convertor:
# This module converts a prediction config from R-Pipeline to El Python Pipeline

##### SETUP: ####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
load_package('rml', version = rml.version)

source('R_Pipeline/libraries/pp_tools.R')

################ Inputs ################
config_filename = 'ppcg_prediction_from_rpc.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> pcg_config

##### RUN: ####
assert(file.exists(pcg_config$output), paste(pcg_config$output, 'does not exist!'))

pcg_config$input %<>% find_file(paths = sprintf("%s/prediction", mc$path_configs))
yaml::read_yaml(pcg_config$input) -> rp_config

wt <- readRDS(sprintf("%s/wide.rds", path_ml))

wtcols   = rbig::colnames(wt)
exclude  = charFilter(wtcols, c(rp_config$exclude_columns, mc$leakages), and = F)
features = rp_config$features %>% extract_feature_names(mc) %>% 
  intersect(wtcols) %>% setdiff(exclude)

rp_config$model %>% build_model_from_config(mc) -> model
parameters = rp_config$model %>% list.remove(model$reserved_words) %>% 
rutils::list.remove('class', 'name', 'horizon', 'target', 'test_date')

cfg_model = do.call('CFG.ELLIB.XGB', 
                    list.add(name = rp_config$model$name,  
                             parameters = parameters, 
                             features = features, 
                             config = list(dataset = pcg_config$sampler_id)))
    
if(!file.exists(cfg_config$output)){dir.create(cfg_config$output)}
    
cfg_model$write.epp_config(filename = 'config.yml', path = cfg_config$output)



  