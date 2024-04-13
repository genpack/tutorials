# This module remove some festures/columns from a widetable
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
################ Read & Validate config ################

config_filename = 'feature_remover.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read: ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> fr_config

wt <- readRDS(sprintf("%s/wide.rds", path_ml))

# todo: write it in rbig::remove_column()
features = fr_config$features %^% rbig::colnames(wt)
if(length(features) > 0){
  filenames = sprintf(list.files(sprintf("%s/wide", path_ml)) %^% paste(features, 'RData', sep = '.'))
  
  file.remove(sprintf("%s/wide", path_ml) %>% paste(filenames, sep = "/"))
  wt$data <- wt$data[colnames(wt$data) %-% features]
  wt$meta <- filter(wt$meta, !(column %in% features))
  wt$numcols <- unique(wt$meta$column) %>% length
  saveRDS(wt, sprintf("%s/wide.rds", path_ml))
  cat('\n', sprintf("%s columns removed from the wide table.", length(features)))
} else {
  cat('\n', 'No column removed!')
}



