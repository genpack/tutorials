# Update all saved models:

#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)
source('R_Pipeline/libraries/ext_rml.R')
################ Inputs ################

################ Read & Validate config ################

################ Read Data ################

################ Run ################
for(tn in list.files(mc$path_models %>% paste(id_ml, sep = '/'))){
  tnp = paste(mc$path_models,id_ml, tn, sep = '/')
  for(hn in list.files(tnp)){
    hnp = paste(mc$path_models,id_ml, tn, hn, sep = '/')
    for(dt in list.files(hnp)){
      dtp = paste(hnp, dt, sep = '/')
      
      for(mn in list.files(dtp)){
        model_load(model_name = mn, path = dtp, update = T) %>% model_save(path = dtp)
      }
    }
  }
}