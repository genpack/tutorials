###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')
source('R_Pipeline/libraries/io_tools.R')

##### FB1: Features Booster 1: ######
# Boosting a model by adding features of another model. 
# Features of the right side model are added to the left side model:
# The output model will have the same configuration of the left side model 
# except its features:

output_model_name: 'left_model_fboost_01'

# left_side_model
left_agent_runid = 'xxx'
left_model_runid = 'xxx'

# right_side_model
right_agent_runid = 'xxx'
right_model_runid = 'xxx'

dates   = c('2021-01-01', '2021-05-01')
dataset = NULL

output_path = sprintf("%s/2_submission_configs/%s/05_predictions/R_Pipeline", mc$path_analytics, mc$client)

read_prediction_configs(mc, left_agent_runid, left_model_runid) -> pcl
read_prediction_configs(mc, right_agent_runid, right_model_runid) -> pcr

pcl$model$features %<>% union(pcr$model$features)
if(!is.null(dataset)) {pcl$dataset = dataset}

pcl$max_memory_GB = NULL
pcl$version       = NULL

if(!is.null(dates)) {
  for(dt in dates){
    pcl$train = paste('train', dt, sep = '_')
    pcl$test  = paste('test', dt, sep = '_')
    output_filename <- pp_config_filename(output_path, output_model_name %>% paste(dt, sep = '_'))
    yaml::write_yaml(pcl, output_filename)
  }
} else {
  output_filename <- pp_config_filename(output_path, output_model_name)
  yaml::write_yaml(pcl, output_filename)
}





