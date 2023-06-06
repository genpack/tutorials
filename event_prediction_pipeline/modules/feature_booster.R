# Feature Booster gets a base model as input and tries to boost it by adding more features to it.
# picks multiple random subsets of features not including in the base model and trains parallel
# Runs a cross validation test on each model and measures performance
# if any of the experiments lead to a better model performance, it returns the boosted model
### booster.R ###
##### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
source('R_Pipeline/libraries/ext_rml.R')
################ Inputs ################
config_filename = 'fb_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'feature_booster', config_filename, sep = '/')) -> fb_config


verify(fb_config$training_months, c('integer', 'numeric'), null_allowed = T) -> fb_config$training_months
verify(fb_config$horizon, c('numeric', 'integer'), default = 3, lengths = 1) -> fb_config$horizon
verify(fb_config$target, 'character', default = 'ERPS', lengths = 1) -> fb_config$target

fb_path = mc$path_reports %>% paste(id_ml, sep = '/')
if(!file.exists(fb_path)) dir.create(gb_path)
fb_path %<>% paste('feature_booster', sep = '/')
if(!file.exists(fb_path)){dir.create(fb_path)}

fb_output <- fb_path %>% paste(fb_config$output, sep = '/')
out = NULL

wt  <- readRDS(sprintf("%s/wide.rds", path_ml))

################ Run: ################
wtcols             = rbig::colnames(wt)
exclude            = c(gss_config$exclude_columns, mc$leakages, 'V1','X', 'caseID', 'eventTime')
features           = wtcols %-% charFilter(wtcols, exclude, and = F)

ylabels  = get_labels(wt, mc, target = fb_config$target, horizon = fb_config$horizon)

for(test_date in fb_config$dates){
  
  train_date = test_date %>% add_month(- fb_config$horizon)
  
  if(is.null(fb_config$training_months)){
    ind_train  = which(wt[['eventTime']] <= train_date)
  } else {
    ind_train %<>% intersect(which(wt[['eventTime']] >  add_month(train_date, - fb_config$training_months)))
  }
  
  ind_test   = which(wt[['eventTime']] == test_date)
  
  y_train  = ylabels[ind_train]
  y_test   = ylabels[ind_test]
  
  X_train  = wt[ind_train, features]
  X_test   = wt[ind_test, features]
  
  fb_config$base_model %>% 
    build_model_from_config(mc, 
                            target = fb_config$target, 
                            horizon = fb_config$horizon, 
                            test_date = test_date) -> base
  
  base$config$cv.set         = list(list(X = X_test, y = y_test))
  base$config$cv.ntrain      = 1
  base$config$cv.ntest       = 1
  base$config$cv.train_ratio = 1
  base$config$cv.test_ratio  = 1
  
  base$config$horizon <- NULL
  base$config$sigma <- NULL
  base$config$decision_threshold <- NULL
  base$config$cv.performance_metric <- NULL
  

  model = feature_booster(base, X_train, y_train, subset_size = fb_config$feature_subset_size, n_experiment = fb_config$num_experiments)  
  if(!is.null(model)){
    pipeline.save_model(model, path_models = mc$path_models %>% paste(id_ml, sep = '/'), test_date = test_date, target = fb_config$target, horizon = fb_config$horizon)
  }
}  
