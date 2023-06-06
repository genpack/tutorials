# Idea: Train a child classifier(can be logistic regression) 
# by features of each cluster and use child model probs to train the base model (can be xgboost).
# Features in the single clusters, go to the base model through a MinMax scaler

# This code gets a base input prediction config and modifies only its transformers
# each transformer is a model created from the child model config and is trained only by features of its associated cluster.
# Child models may use a MinMaxScaler and OHEncoder to mmodify the features
# It requires feature clustering output (the cluster tree rds file)

###### Setup: ######
source('R_Pipeline/initialize.R')
load_package('rml', version = rml.version)

###### Inputs: ######

# Which column of the cluster tree table should be used?
clustering_column = 'N635'

# Which model are you going to modify (specify address of a prediction config)
input_config_base   = 'skxgb_gssc2_elppn.yml'
input_config_child  = 'sklr_gssc2_elppn.yml'
output_config = 'skxgb_gssc2_elppn_cm2.yml'

# Specify the clustering tree table. (either full path or filename in the expected folder)
input_clusters = 'fclc1_out.csv'

# What other base config parameters should change?
changes = list(name = 'skxgb_gssc2_elppn_cm2', fe.enabled = F, mc.enabled = T, remove_failed_transformers = T)

###### Read: ######
# Read hp_config:
input_config_base %<>% find_file(paste(mc$path_config, 'prediction', sep = '/'))
config = yaml::read_yaml(input_config_base)

input_config_child %<>% find_file(paste(mc$path_config, 'prediction', sep = '/'))
config_child = yaml::read_yaml(input_config_child)

# Read the clustering tree table:
input_clusters %<>% find_file(paste(mc$path_reports, id_ml, 'feature_clustering', sep = '/'))
ct = read.csv(input_clusters)

###### Run: Modify Config: ######

clusters = unique(ct[, clustering_column])
config$model$transformers = list()
pass = character()
nt   = 0
for(cn in clusters){
  fet = ct$fname[ct[, clustering_column] == cn]
  if(length(fet) > 1){
    nt = nt + 1
    cc = config_child$model
    cc$name = "CCL" %>% paste(cn, sep = '_')
    cc$features = fet
    config$model$transformers[[nt]] <- cc
  } else {
    pass = c(pass, fet)
  }
}

if(length(pass) > 0){
  cc = config_child$model
  cc$name = "LRSingles"
  cc$features = pass
  config$model$transformers[[nt + 1]] <- cc
}

config$features <- NULL

for(cn in names(changes)){
  config$model[[cn]] <- changes[[cn]]
}

###### Save New Config: ######

output_config = mc$path_configs %>% paste('prediction', output_config, sep = '/')

yaml::write_yaml(config, output_config)


