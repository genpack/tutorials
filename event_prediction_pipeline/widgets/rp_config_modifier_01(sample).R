# Idea: Take the first n principal components of each cluster to train a model.

# This code gets an input prediction and modifies only its transformers/features
# by picking the first n principal component(s) from each cluster. 
# It requires feature clustering output (the cluster tree rds file)

###### Setup: ######
source('R_Pipeline/initialize.R')
load_package('rml', version = rml.version)

###### Inputs: ######

# How many components of each feature should we use
num_top_components = 1

# Which column of the cluster tree table should be used?
clustering_column = 'N635'

# Which model hyper-parameters do you want to use (specify address of a prediction config)
input_config  = 'skxgb_gssc2_elppn.yml'
output_config = 'skxgb_gssc2_elppn_cm1.yml'

# Specify the clustering tree table. (either full path or filename in the expected folder)
input_clusters = 'fclc1_out.csv'

# What other config parameters should change?
changes = list(name = 'skxgb_gssc2_elppn_cm1', fe.enabled = F)

###### Read: ######
# Read hp_config:
input_config %<>% find_file(paste(mc$path_config, 'prediction', sep = '/'))
config = yaml::read_yaml(input_config)

# Read the clustering tree table:
input_clusters %<>% find_file(paste(mc$path_reports, id_ml, 'feature_clustering', sep = '/'))
ct = read.csv(input_clusters)

# Read and operate the feature scores table:
# filename.scores %<>% 
#   find_file(paste(mc$path_reports, id_ml, 
#                   c('', 'feature_correlation', 'subset_scorer', 'greedy_subset_scorer') %>% 
#                   c(mc$path_reports), sep = '/'))
# scores = bigreadr::fread2(filename.scores$file)
# if(!is.null(filename.scores$operation)){
#   scores %<>% rutils::operate(filename.scores$operation)
# }

###### Run: Modify Config: ######

clusters = unique(ct[, clustering_column])
config$model$transformers = list()
pass = character()
nt   = 0
for(cn in clusters){
  fet = ct$fname[ct[, clustering_column] == cn]
  if(length(fet) > 1){
    nt = nt + 1
    list(class = 'MAP.STATS.PCA',
         name = paste0('PCA', 'CL', cn), 
         num_components = num_top_components,
         transformers = list(
           list(
             class = 'MAP.RML.MMS',
             name = paste0('MMS', 'CL', cn),
             pp.trim_outliers = T,
             pp.trim_outliers.adaptive = T,
             pp.mask_missing_values = 0
           )
         ),
         features = fet) -> config$model$transformers[[nt]]
  } else {
    pass = c(pass, fet)
  }
}

if(length(pass) > 0){
  list(class = 'MAP.RML.MMS',
       name = "MMS", 
       pp.trim_outliers = T,
       pp.trim_outliers.adaptive = T,
       pp.mask_missing_values = 0,
       features = pass) -> config$model$transformers[[nt + 1]]
}

config$features <- NULL

for(cn in names(changes)){
  config$model[[cn]] <- changes[[cn]]
}

###### Save New Config: ######

output_config = mc$path_configs %>% paste('prediction', output_config, sep = '/')

yaml::write_yaml(config, output_config)


