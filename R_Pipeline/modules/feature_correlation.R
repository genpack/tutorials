## Feature correlation with label for the entire ML-Mapper
#### Setup: ####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)

################ Inputs ################
config_filename = 'fc_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read: ################
yaml::read_yaml(mc$path_configs %>% 
                  paste('modules', 'feature_correlation', config_filename, sep = '/')) -> fc_config

# wt <- WIDETABLE(name = 'wide', path = path_ml)
# wt  %>% saveRDS(sprintf("%s/wide.rds", path_ml))
wt <- readRDS(sprintf("%s/wide.rds", path_ml))
# path_ml %>% paste('categorical_encodings.json', sep = '/') %>% jsonlite::read_json() -> caten
# fg <- readRDS(path_rp %>% paste('feature_groups.rds', sep = '/'))
path_rp <-  mc$path_reports %>% paste(id_ml, sep = '/')
if(!file.exists(path_rp)) dir.create(path_rp)

################ Feature Evaluation on entire ML-Mappper  ################
ylabels  = get_labels(wt, mc, target = fc_config$target, horizon = fc_config$horizon)

if(is.null(fc_config$features)){
  features = rbig::colnames(wt)
} else {
  features = fc_config$features %>% extract_feature_names(mc) %>% 
    intersect(rbig::colnames(wt))
}

features %<>% setdiff(charFilter(features, fc_config$exclude_columns, and = F)) %>% 
  setdiff(charFilter(features, mc$leakages, and = F))

path = sprintf("%s/feature_correlation", path_rp)
if(!file.exists(path)){dir.create(path)}

path = sprintf("%s/feature_correlation/%s.csv", path_rp, fc_config$output)
if(file.exists(path)){fetlog = read.csv(path)} else {fetlog = NULL}

remaining_features = features %-% rownames(fetlog)

while(length(remaining_features) > 0){
  fetsubset = remaining_features %>% 
    sample(size = min(fc_config$chunk_size, length(remaining_features)))
  remaining_features %<>% setdiff(fetsubset)
  tbl = evaluate_features(wt[fetsubset], ylabels, metrics = metrics, quantiles = quantiles) %>% rownames2Column('fname')
  if(is.null(fetlog)){
    fetlog = tbl
  } else {
    fetlog %<>% dplyr::bind_rows(tbl)
  }
  fetlog %>% write.csv(path)
}


