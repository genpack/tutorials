## Micro Widgets:
#### Setup #####
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/io_tools.R')
source('R_Pipeline/libraries/pp_tools.R')

#### 01-list PP prediction bucket #####

mc %>% list_bucket('prediction', id = 'xxxxxxx')

mc %>% list_bucket('prediction', id = 'xxxxxxx', folders = "modelrun=xxxxxxxxxxxxxx")

#### 02-list PP mlmapper runids #####
mc %>% list_bucket('mlmapper')

mc %>% list_bucket('mlmapper', id = 'xxxxxxxxx')

mc %>% list_bucket('mlsampler', id = 'xxxxxxx', folders = c('train_2020-01-01', 'data'))

#### 03-list of mlmapper features #####
mc %>% copy_to_local(bucket = 'mlmapper', id = mc$mlmapper_id, files = 'etc/features.json')
fet = jsonlite::read_json("%s/%s/etc/features.json" %>% sprintf(mc$path_mlmapper, id_ml))
fet = fet$features %>% unlist



#### 11-Copy PP ML Mapper to Local: ####
copy_mlmapper_to_local(mc)

#### 12-Copy PP preprocessing to Local: ####
copy_to_local(mc, bucket = 'preprocessing', id = mc$preprocessing_id)


#### 13-Copy PP orchestration to Local: ####
copy_orchestration_to_local(mc, orchestration_id = 'xxxx')

#### 14-Copy PP prepdiction to Local: ####

copy_to_local(mc, bucket = 'prediction', id = 'xxxxxx')

copy_prediction_to_local(mc, agentrun_id = '', modelrun_id = '')
copy_prediction_to_local(mc, agentrun_id = '', modelrun_id = '', folders = 'prediction')
copy_prediction_to_local(mc, agentrun_id = '', modelrun_id = '', files = 'scores.json')


#### 14-Copy PP Mlsampler to Local: ####

copy_to_local(mc, bucket = 'mlsampler', id = 'xxxxxx')
copy_to_local(mc, bucket = 'mlsampler', id = 'xxxxxx', folders = 'test_2020-10-01')



#### 23- Read a table from preprocessing: ####
tbl = pp_read_table(mc, 'lnpa', 'preprocessing', format = 'parquet')
tbl = pp_read_table(mc, 'lnpa', 'preprocessing', format = 'rds')

#### 15-Copy from local to exchange s3 bucket: ####
# Examples:
# The file must exist in the local exchange folder
sync_exchange(mc, 'results.csv', 'Nima/test_results')
sync_exchange(mc, 'test_results', 'Nima', is_folder = T)

copy_to_exchange(mc, 'D:/User/nima.ramezani/Documents/data/reports/xxxx/prediction/runs.csv', 'Nima/reports/runs.csv')

#### 31- Read mlsampler config
read_mlsampler_configs(mc, mlsampler_id = pc$dataset) -> samc

#### 41-Read PP prediction scores from a given prediction id: ####
read_prediction_scores(mc, agentrun_id = 'xxxx', modelrun_id = 'xxxx') -> ps

scores = read_prediction_scores(mc, agentrun_id = 'xxxx', modelrun_id = 'xxxx', children = T, as_table = T)

#### 42-Read PP prediction scores from a given orchestration id: ####
runs = read_orchestration_scores(mc, orchestration_id = 'xxxxx-xxxxx-xxxx', metrics = c('gini_coefficient', 'lift_2', 'precision_2'))
write.csv(runs, "%s/%s/prediction/%s" %>% sprintf(mc$path_reports, id_ml, 'pp_runs_xxxx.csv'))

#### 43-read PP prediction config of a single prediction as a list: ####
read_prediction_configs(mc,
                        agentrun_id = 'xxxx',
                        modelrun_id = 'xxxx') -> pc

#### 44-Read prediction probabilities from a given orchestration id: ####
read_orchestration_probs(mc, orchestration_id = 'xxxxx-xxxxx-xxxx')

#### 45-Read PP prediction probabilities from a given prediction id (gss or hpo): ####
read_prediction_probs(mc, agentrun_id = 'xxxx', modelrun_id = 'xxxx', children = T, as_table = T)

#### 46-Read PP prediction configs from a given prediction id with children as a table (gss or hpo): ####
read_prediction_configs(mc, agentrun_id = 'xxxx', modelrun_id = 'xxxx', children = T, as_table = T)

#### 47-Read PP prediction features from a given prediction id with children as a table (gss): ####
read_prediction_features(mc, agentrun_id = 'xxxx', modelrun_id = 'xxxx', children = T, as_table = T)

#### 48-Read PP prediction feature importances from a given prediction id with children as a table (gss): ####
read_prediction_features(mc, agentrun_id = 'xxxx', modelrun_id = 'xxxx', children = T, as_table = T, feature_importances = T)

#### 49-read dataset information of a pp prediction run

agent_runid = 'xxx'
model_runid = 'xxx'

pc = read_prediction_configs(mc, agentrun_id = agent_runid, modelrun_id = model_runid)


#### 51- Copy orchestration results in prediction reports: ####
orchestration_id = 'xxxxxxxxx'
table_name       = 'robustness_best_hpo'

runs = read_orchestration_scores(mc, orchestration_id = orchestration_id)
runs %>% 
  mutate(model_name = table_name,
         test_at = gsub(id, pattern = paste0(table_name, "_"), replacement = "") %>% 
           gsub(pattern = "_", replacement = "-")) %>% 
  write.csv("%s/%s/prediction/%s.csv" %>% sprintf(mc$path_reports, id_ml, table_name))


#### 52- Read production model robustness results: ####
reticulate::py_run_string("import sys")
reticulate::py_run_string("sys.path.append('%s')" %>% sprintf(mc$path_detools))
et = reticulate::import('el_detools_v06')
et$execute_sql("select * from packaging.robustness_scores_pkg") %>% 
  mutate(test_at = dataset_month %>% as.Date %>% as.character,
         model_name = 'production_robustness') %>% 
  write.csv("%s/%s/prediction/%s.csv" %>% sprintf(mc$path_reports, id_ml, 'production_robustness'))

#### 101- Load a saved RP model for evaluation: ####
model_name =  'skxgb1_gssc7v5'
test_date  =  '2020-12-01'
horizon    = 3
target     = 'ERPS'

rml::model_load(
  model_name = model_name, 
  path = sprintf("%s/%s/%s/H%s/%s", mc$path_models, id_ml, target, horizon, test_date), update = F) -> model

## See features:
# model$objects$features %>% View

#### 102- Get all normalized feature importances (including children) from an orchestration: ####
orchestration_id = 'xxxxxxx'
table_name       = 'model_x'

fio = read_orchestration_features(mc, orchestration_id = orchestration_id, children = T, feature_importances = T) %>% 
  mutate(test_date = gsub(id, pattern = paste0(table_name, "_"), replacement = ""))

fio_norm = fio
fio_norm[, fet] <- fio[, fet] %>% as.matrix %>% apply(1, rutils::vect.map) %>% t

### 102-2 Get average feature importances for each orchestration job: ####

fet = colnames(fio) %-% c('id','test_date', 'agent_runid', 'model_runid')

fio_norm  %>% 
  dplyr::group_by(id, test_date) %>% 
  do({colMeans(.[fet], na.rm = T) %>% t %>% as.data.frame}) -> fio_agg

### 102-3 Get most important features for a given orchestration job: ####
n_top = 5

job_id = paste(table_name, '2021-03-01', sep = '_')
topfet = fio_agg[fio_agg$id == job_id, fet] %>% unlist %>% sort(decreasing = T) %>% head(n_top)

### 102-4 Tmportance Trend for a particular feature: ####
feature_names = names(topfet)

fio_agg[c('test_date', feature_names)] %>% as.data.frame %>% 
  reshape2::melt(id.vars = 'test_date', value.name = 'scaled_mean_feature_importance', variable.name = 'feature_name') %>% 
  plotly::plot_ly(x = ~test_date, y = ~scaled_mean_feature_importance, color = feature_name,
                  type = 'scatter', mode = 'lines')


#### 103: Check performance of saved predictions on the ER and PS separately: ####
orchestration_id = 'xxxxxx'

wt <- readRDS(sprintf("%s/wide.rds", path_ml))

read_orchestration_probs(mc, orchestration_id = orchestration_id) %>% 
  purrr::reduce(rbind) -> probs

mlm = wt[c("caseID", "eventTime", "uncensored_y_core_LoanClosureReason_PropertySale",
          "uncensored_y_core_LoanClosureReason_ExternalRefinance", "tte")]

res = probs %>% left_join(ml, by = c("caseID", "eventTime")) %>% 
  mutate(label_ps = uncensored_y_core_LoanClosureReason_PropertySale & (tte <= 4),
         label_er = uncensored_y_core_LoanClosureReason_ExternalRefinance & (tte <= 4)) %>% 
  mutate(label_erps = label_er | label_ps)


# verify:
sum(res$label != res$label_erps)

### 103-1: Churn rate over time for ER and PS and overall:
res %>% group_by(eventTime) %>% 
  summarise(churn_rate_er = mean(label_er), churn_rate_ps = mean(label_ps), churn_rate_erps = mean(label_erps)) %>% 
  ungroup %>% 
  reshape2::melt(id.vars = 'eventTime', value.name = "churn_rate") %>% 
  plotly::plot_ly(x = ~eventTime, y = ~churn_rate, color = ~variable, type = 'scatter', mode = 'lines')

### 103-2: Churn rate for PS and ER as a percentatge of total churners:
res %>% group_by(eventTime) %>% 
  summarise(n_er = sum(label_er), n_ps = sum(label_ps), n_erps = sum(label_erps)) %>% 
  ungroup %>% 
  mutate(p_er = 100*n_er/n_erps, p_ps = 100*n_ps/n_erps) %>% 
  plotly::plot_ly(type = 'bar', x = ~eventTime, y = ~p_ps, name = 'Property Sale') %>% 
  plotly::add_trace(y = ~p_er, name = 'External Refinance') %>% 
  plotly::layout(yaxis = list(title = 'Percentage (%)', barmode = 'stack'))


### 103-3: Performance trend for ER and PS over time: 
res %>% group_by(eventTime) %>% 
  do({correlation(.[['probability']], .[['label_ps']], metrics = c('gini', 'lift', 'precision'), quantiles = 0.02) %>% 
      as.data.frame %>% mutate(eventTime = .[['eventTime']][1])}) %>% 
  rename(ps_gini = gini, ps_lift_2pc = lift_2pc, ps_precision_2pc = precision_2pc) -> res_ps

res %>% group_by(eventTime) %>% 
  do({correlation(.[['probability']], .[['label_er']], metrics = c('gini', 'lift', 'precision'), quantiles = 0.02) %>% 
      as.data.frame %>% mutate(eventTime = .[['eventTime']][1])}) -> res_er

# Gini
left_join(res_er, res_ps, by = 'eventTime') %>% 
  plotly::plot_ly(x = ~eventTime, y = ~gini, type = 'bar', name = 'External Refinance') %>% 
  plotly::add_bars(y = ~ps_gini, name = 'PropertySale')

# Lift 2%
left_join(res_er, res_ps, by = 'eventTime') %>% 
  plotly::plot_ly(x = ~eventTime, y = ~lift_2pc, type = 'bar', name = 'External Refinance') %>% 
  plotly::add_bars(y = ~ps_lift_2pc, name = 'PropertySale')

# Precision 2%
left_join(res_er, res_ps, by = 'eventTime') %>% 
  plotly::plot_ly(x = ~eventTime, y = ~precision_2pc, type = 'bar', name = 'External Refinance') %>% 
  plotly::add_bars(y = ~ps_precision_2pc, name = 'PropertySale')



#### 104: Correlation of features with label trend over time for ER and PS: ####
feature_name = 'xxxx'

## Get res from 103

wt[c(caseID, eventTime, feature_name)]
res %>% group_by(even)

#### 105: Analyse GSS raw scores: ####
# 
agent_runid = ''
model_runid = ''

scores_path = "%s/agentrun=%s/modelrun=%s/raw_scores.csv" %>% 
  sprintf(mc$path_prediction, agent_runid, model_runid)

if(!file.exists(scores_path)){copy_prediction_to_local(mc, agent_runid, model_runid, files = 'raw_scores.csv')}
bigreadr::fread2(scores_path) -> scores

# mp: model profile
mp <- scores %>% 
  group_by(batch_number, model_id) %>% 
  summarise(num_features = length(feature_name), num_features_nz = sum(importance > 0), gini = max(gini_coefficient), lift_2 = max(lift_2))

# batch profile:
mp %>% group_by(batch_number) %>% summarise(max_nf = max(num_features), max_nf_nz = max(num_features_nz), max_gini = max(gini), max_lift_2 = max(lift_2))



#### 201: Boosting a model by adding (merging) features of another model. ####
# Features of the right side model are added to the left side model:

left_agent_runid =  'xxx'
left_model_runid =  'xxx'
  
right_agent_runid =  'xxx'
right_model_runid =  'xxx'

output_model_name = 'my_combined_model'
output_model_path = 'D:/Users/firstname.surname/Documents/CodeCommit/analytics-democlient/2_submission_configs/democlient/05_predictions/R_Pipeline'

read_prediction_configs(mc, agentrun_id = left_agent_runid , modelrun_id = left_model_runid)  -> pcl
read_prediction_configs(mc, agentrun_id = right_agent_runid, modelrun_id = right_model_runid) -> pcr

pcl$model$features %<>% union(pcr$model$features)
assert(file.exists(output_model_path))
output_folder <- output_model_path %>% paste(output_model_name, sep = '/')
if(!file.exists(output_folder)){dir.create(output_folder)}
yaml::write_yaml(pc1, paste(output_folder, 'config.yml', sep = '/'))


#### 202: Hyper-parameter grid search booster orchestration for pp: #####

# base model:
agent_runid =  'xxx'
model_runid =  'xxx'

parameter_space = list(
  n_estimators = runif(10, -50, 100) %>% as.integer %>% sort
)

dates = c('2021-04-01', '2021-05-01')
output_model_name = 'base_hpboost'

output_model_path = sprintf('%s/2_submission_configs/%s/06_orchestration/R_Pipeline', mc$path_analytics, mc$client)

read_prediction_configs(mc, agentrun_id = agent_runid , modelrun_id = model_runid)  -> base

if(base$model$classifier$type == 'AveragingEnsembler'){
  base$model$classifier$models[[1]]$classifier$parameters -> params
  injstr = 'model.classifier.models[0].classifier.parameters.%s'
} else {
  base$model$classifier$parameters -> params
  injstr = 'model.classifier.parameters.%s'
}

default_job_timeout = NULL
mlsampler_id = NULL

if(is.null(dates)){dates = ''}

jobs = list()
for(pn in names(parameter_space)){
  for(pv in parameter_space[[pn]]){
    for(test_date in dates){
      job = list(component = 'prediction', critical = F)
      job$config_ref = agent_runid
      job$id = output_model_name %>% paste(paste(pn,params[[pn]] + pv, sep = "="), test_date, sep = '_')
      if(test_date == ''){
        job$injection = list()
      } else {        
        job$injection = list(train   = paste('train', test_date, sep = '_'), 
                             test    = paste('test', test_date, sep = '_'))
      }
      job$injection[[sprintf(injstr, pn)]] <- params[[pn]] + pv
      if(!is.null(mlsampler_id)){job$injection$dataset <- mlsampler_id}
      jobs[[length(jobs) + 1]] <- job
    }
  }
}

list(
  orchestration = list(
    default_job_timeout = verify(default_job_timeout, default = '6h'),
    interval = verify(config$interval, default = '30s'),
    propagate_tags = verify(config$propagate_tags, default = T),
    timeout = verify(config$timeout, default = '1d')
  ), jobs = jobs) %>% yaml::write_yaml(pp_config_filename(output_model_path, output_model_name))




#### 203: Hyper-parameter injector orchestration for pp: #####
# This booster gets a list of base model preduction runs and injects hyperparameters of the injector model to each of them.
# You will need to have table 'scores' available which contains base models and their ids. 
# Obtain it from pp_prediction_read module.

injector_agent_runid = 'xxx'
injector_model_runid = 'xxx'
output_model_name    = 'hp_inj1'

default_job_timeout = NULL
interval            = NULL
timeout             = NULL

read_prediction_configs(mc, agentrun_id = injector_agent_runid , modelrun_id = injector_model_runid)  -> injector
if(injector$model$classifier$type == 'AveragingEnsembler'){
  injector$model$classifier$models[[1]]$classifier$parameters -> injector_params
} else {
  injector$model$classifier$parameters -> injector_params
}

output_model_path = sprintf('%s/2_submission_configs/%s/06_orchestration/R_Pipeline', mc$path_analytics, mc$client)

scores %<>% distinct(model_name, .keep_all = T)
jobs = list()
for(i in sequence(nrow(scores))){
  job = list(component = 'prediction', critical = F, 
             config_ref = scores$agent_runid[i], 
             id = paste(scores$model_name[i], output_model_name, sep = '_'),
             injection = list())

  read_prediction_configs(mc, agentrun_id = scores$agent_runid[i] , modelrun_id = scores$model_runid[i])  -> base
  
  if(base$model$classifier$type == 'AveragingEnsembler'){
    injstr = 'model.classifier.models[0].classifier.parameters.%s'
  } else {
    injstr = 'model.classifier.parameters.%s'
  }
  
  for(pn in names(injector_params)){
    job$injection[[sprintf(injstr, pn)]] <- injector_params[[pn]]
  }
    
  jobs[[length(jobs) + 1]] <- job
}

list(
  orchestration = list(
    default_job_timeout = verify(default_job_timeout, default = '6h'),
    interval = verify(interval, default = '30s'),
    timeout = verify(timeout, default = '1d')
  ), jobs = jobs) %>% yaml::write_yaml(pp_config_filename(output_model_path, output_model_name))




#### 301: ppcg: Warm Start PP HPO Config to boost a base PP model config: ####

hpo_agent_runid =  'xxx'
hpo_model_runid =  'xxx'

base_agent_runid  = 'xxx'
base_model_runid  = 'xxx'

base_is_ensemble  = TRUE
output_model_name = 'my_combined_model'
output_model_path = 'D:/Users/firstname.surname/Documents/CodeCommit/analytics-democlient/2_submission_configs/democlient/05_predictions/R_Pipeline'

hpoc <- read_prediction_configs(mc, agentrun_id = hpo_agent_runid, modelrun_id = hpo_model_runid)
base <- read_prediction_configs(mc, agentrun_id = base_agent_runid, modelrun_id = base_model_runid)

if(base_is_ensemble){
  hpoc$model <- base$model$classifier$models[[1]]
  hpoc$model$features <- base$model$features
  ## Setting the starting point:
  hpoc$hpo$params$points_to_evaluate = list(base$model$classifier$models[[1]]$classifier$parameters)
} else {
  hpoc$model <- base$model
  ## Setting the starting point:
  hpoc$hpo$params$points_to_evaluate = list(base$model$classifier$parameters)
}

# change special parameters:
if('eta' %in% names(hpoc$hpo$params$points_to_evaluate[[1]])){
  hpoc$hpo$params$points_to_evaluate[[1]][['eta_k']] = hpoc$hpo$params$points_to_evaluate[[1]][['eta']]*hpoc$hpo$params$points_to_evaluate[[1]][['n_estimators']]
  hpoc$hpo$params$points_to_evaluate[[1]][['eta']]   = NULL
}
for(pn in names(hpoc$hpo$params$points_to_evaluate[[1]]) %^% c('gamma', 'alpha', 'lambda', 'min_child_weight')){
  hpoc$hpo$params$points_to_evaluate[[1]][[paste(pn, 'exp', sep = '_')]] = log(hpoc$hpo$params$points_to_evaluate[[1]][[pn]])
  hpoc$hpo$params$points_to_evaluate[[1]][[pn]] = NULL
}

## todo: adjust search space 1- warm-start search space, 2- default in points_to_evaluate for missing parameters
hpoc$hpo$space %<>% list.extract(names(hpoc$hpo$params$points_to_evaluate[[1]]))


hpoc$dataset = base$dataset
hpoc$train   = base$train
hpoc$test    = base$test

# My defaults (change them if you want)
hpoc$hpo$feature_select = FALSE
hpoc$hpo$num_trials     = 100L
hpoc$hpo$params$n_initial_points = 20L
hpoc$hpo$metric = 'lift_2'
hpoc$hpo$num_parallel = 16L
# hpoc$version = tags/v8.2.0.dev28

assert(file.exists(output_model_path))
output_folder <- output_model_path %>% paste(output_model_name, sep = '/')
if(!file.exists(output_folder)){dir.create(output_folder)}
yaml::write_yaml(hpoc, paste(output_folder, 'config.yml', sep = '/'))
#  Now, modify the config as you desire


#### 302: ppcg: PP GSS Config: ####
model_name  = 'gss_m48dns3_ss10nb80bs10es15_dec20'
dataset     = 'xxx'
dates       = c('2020-12-01')
batch_size  = 10L
num_batches = 80L
subset_size = 0.1
early_stopping = 15L

xgboost_parameters = list(
  colsample_bytree = 0.6,
  eta = 0.05,
  max_depth = 4L,
  min_child_weight = 75L,
  n_estimators = 100L,
  scale_pos_weight = 2L,
  subsample = 0.6
)

fetpath = "%s/%s/etc/features.json" %>% sprintf(mc$path_mlmapper, id_ml)
features = jsonlite::read_json(fetpath) %>% unlist %>% 
  setdiff(charFilter(., mc$leakages, and = F)) %>% setdiff(c('caseID', 'eventTime'))

outpath = "%s/2_submission_configs/%s/05_predictions/R_Pipeline" %>% sprintf(mc$path_analytics, mc$client)
outpath %<>% pp_config_filename(model_name)

list(dataset = dataset,
     max_memory_GB = 1,
     optimise = F,
     verbose = 1L,
     mode = 'train',
     feature_selection = list(
       algorithm = 'greedy_subset_scores',
       subset_size = subset_size,
       num_batches = num_batches,
       batch_size = batch_size,
       sample_sets = as.list(dates),
       maximize = T,
       metric = 'gini_coefficient',
       early_stopping = early_stopping
     ), 
     model = pp_xgb_model_config(xgboost_parameters, features)) %>% 
  yaml::write_yaml(outpath)

#### 401: Manual Aggregation of pp probabilities: ####
# Obtain table 'probs' from widget pp_prediction_aggregate

test_date = '2020-04-01'

### Check label, caseID and eventTime are identical for all models
# probs %>% filter(eventTime == test_date) %>% group_by(model_runid) %>% summarise(cnt = sum(label)) %>% pull(cnt) %>% unique -> cuvfsl
### cuvfsl: count of unique values for sum of labels
# assert(cuvfsl == 1)

probs %>% 
  filter(eventTime == test_date) %>% 
  mutate(id = paste(agent_runid %>% substr(1,8), model_runid %>% substr(1,8), sep = '_')) %>% 
  reshape2::dcast(caseID + eventTime ~ id, value.var = 'probability') -> pw
# pw: probabilities wide

probs %>% filter(eventTime == test_date) %>% distinct(caseID, eventTime, label) -> df_id

pw %<>% left_join(df_id, by = c('caseID', 'eventTime'))

pwmat = pw %>% select(-caseID, -eventTime, -label) %>% as.matrix
pw$maxProbs  = pwmat %>% apply(1, max)
pw$minProbs  = pwmat %>% apply(1, min)
pw$meanProbs = pwmat %>% apply(1, mean)
pw$medProbs  = pwmat %>% apply(1, median)

rml::correlation(pw$maxProbs, pw$label, 'lift', quantiles = 0.02)
rml::correlation(pw$minProbs, pw$label, 'lift', quantiles = 0.02)
rml::correlation(pw$medProbs, pw$label, 'lift', quantiles = 0.02)
rml::correlation(pw$meanProbs, pw$label, 'lift', quantiles = 0.02)


#### 501: rpcg_from_pp ####
# This micro-widget converts a pp ensemble xgboost model config to a single rp model config

agent_runid   = 'xxx'
model_runid   = 'xxx'
rp_model_name = 'my_model'
dates         = c('2020-11-01', '2020-12-01')

ppc <- read_prediction_configs(mc, agentrun_id = agent_runid, modelrun_id = model_runid)

mdl <- ppc$model$classifier$models[[1]]$classifier$parameters %<==>%
  list(name  = rp_model_name,
       class = 'CLS.SKLEARN.XGB',
       n_jobs = 4L,
       fe.enabled = T)

rpc <- list(dates = dates, target = 'ERPS', horizon = 3L, model = mdl, features = ppc$model$features)

rpc %>% yaml::write_yaml(file = sprintf("%s/modules/prediction/%s.yml", mc$path_config, rp_model_name))

#### 600: FCTI-1: scores: Use services from StAPIClient ####


##### 602: FCTI-2: get feature info from feature factory: #####

fetpath = "%s/%s/etc/features.json" %>% sprintf(mc$path_mlmapper, id_ml)
features = jsonlite::read_json(fetpath) %>% unlist %>% 
  setdiff(charFilter(., mc$leakages, and = F)) %>% setdiff(c('caseID', 'eventTime'))

path_lib = sprintf("%s/R_Pipeline/libraries", getwd())

reticulate::py_run_string("import sys")
reticulate::py_run_string("sys.path.append('%s')" %>% sprintf(path_lib))
ffe_module = reticulate::import('ff_extract')
ff_module  = reticulate::import('ellib.feature_factory')
ff = ff_module$feature_factory$FeatureFactory(verbose = F)
ffe_module$get_standard_feature_info(feature_factory = ff, all_features = features) %>% 
  ffe_module$ff_to_df() -> finfo

#### 603: FCTI-3: get feature factory scores for features, periodics, ppp tables and columns: ####
# To find the path to your poetry python in Windows, it should be in: 
# '<HOME_DIRECTORY>/AppData/Local/pypoetry/Cache/virtualenvs/<VIRTUAL_ENVIRONMENT>/Scripts/Python.exe'
Sys.setenv(RETICULATE_PYTHON = '<HOME_DIRECTORY>/AppData/Local/pypoetry/Cache/virtualenvs/<VIRTUAL_ENVIRONMENT>/Scripts/Python.exe')
reticulate::use_virtualenv('<HOME_DIRECTORY>/AppData/Local/pypoetry/Cache/virtualenvs/<VIRTUAL_ENVIRONMENT>', required = T)
# Make sure reticulate python has chaanged to the one in the poetry virtual environment:
reticulate::py_config()

qmean = function(x, probs = 0.0, ...){
  cut_point = quantile(x, probs = probs)
  mean(x[x >= cut_point], ...)
}

runs = read_prediction_comprehensive(mc, from_time = '2021-08-01', 
                                     filename = sprintf("%s/%s/prediction/epp_runs.csv", mc$path_reports, id_ml))
# filename = sprintf("%s/%s/prediction/epp_runs.csv", mc$path_reports, id_ml)
# runs = bigreadr::fread2(filename)

leaky_features = colnames(runs) %^% mc$leakage
if(length(leaky_features) > 0){
  tbr = which(runs[leaky_features] %>% rowSums(na.rm = T) > 0)
  if(length(tbr) > 0){
    runs = runs[-tbr,  ]
  }
}

# runs = runs[runs$test_to != '2021-06-01',]

# you will need variables 'finfo' and 'features' from 602:

runs %>% 
  reshape2::melt(id.vars = c('agentrun', 'modelrun', 'gini_coefficient', 'lift_2', 'test_from'), 
                 measure.vars = colnames(.) %^% features,
                 variable.name = 'feature_name', value.name = 'importance') -> raw

# rm(list = 'runs')

raw = raw[!is.na(raw$importance),]
gc()

# Compute intra-model scaled feature importances and intra-month scaled model performances:
raw %>% 
  dplyr::group_by(agentrun, modelrun) %>% 
  dplyr::mutate(importance_mms = rutils::vect.map(importance)) %>% 
  dplyr::ungroup() %>% 
  # dplyr::group_by(test_from) %>% 
  dplyr::mutate(gini_mms = rutils::vect.map(gini_coefficient)) %>% 
  # dplyr::ungroup() %>% 
  dplyr::mutate(score = importance_mms*gini_mms) %>% 
  # dplyr::mutate(score = importance_mms*gini_coefficient) %>% 
  dplyr::left_join(finfo %>% select(feature_name = name, periodic_name, input_table), by = 'feature_name') -> raw

raw$input_table[is.na(raw$input_table)] <- 'unknown'
raw$periodic_name[is.na(raw$periodic_name)] <- 'unknown'

raw %>% bigreadr::fwrite2("%s/%s/prediction/raw_scores.csv" %>% sprintf(mc$path_report, id_ml))
# raw <- bigreadr::fread2("%s/%s/prediction/raw_scores.csv" %>% sprintf(mc$path_report, id_ml))

raw %>% 
  dplyr::group_by(feature_name, periodic_name, input_table) %>% 
  dplyr::summarise(
    num_models = sum(!is.na(score)), 
    num_zeros = sum(score == 0, na.rm = T), 
    max_importance = max(importance, na.rm = T), 
    avg_importance = mean(importance, na.rm = T), 
    max_importance_mms = max(importance_mms, na.rm = T), 
    avg_importance_mms = mean(importance_mms, na.rm = T), 
    max_score = max(score, na.rm = T), 
    score_q98 = quantile(score, probs = 0.98),
    score_q75 = quantile(score, probs = 0.75),
    avg_score = mean(score, na.rm = T),
    avg_score_t2  = qmean(score, probs = 0.98, na.rm = T),
    avg_score_t25 = qmean(score, probs = 0.75, na.rm = T)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(zero_rate = num_zeros/num_models) %>% 
  dplyr::select(feature_name, periodic_name, input_table, 
                num_models, num_zeros, 
                max_importance, avg_importance, max_importance_mms, avg_importance_mms, 
                max_score, score_q98, score_q75,
                avg_score, avg_score_t2, avg_score_t25, zero_rate) -> feature_info

feature_info %>% plotly::plot_ly(x = ~avg_score, y = ~max_score, color = ~zero_rate, type = 'scatter', mode = 'markers')
feature_info %>% plotly::plot_ly(x = ~avg_score_t25, y = ~max_score, color = ~zero_rate, type = 'scatter', mode = 'markers')
feature_info %>% plotly::plot_ly(x = ~avg_score_t25, y = ~score_q75, color = ~zero_rate, type = 'scatter', mode = 'markers')
feature_info %>% plotly::plot_ly(x = ~avg_score_t2, y = ~score_q75, color = ~zero_rate, type = 'scatter', mode = 'markers')
feature_info %>% plotly::plot_ly(x = ~avg_score_t2, y = ~score_q98, color = ~zero_rate, type = 'scatter', mode = 'markers')

# feature_info$input_table[is.na(feature_info$input_table)] <- 'combined_features'
feature_info %>% write.csv("%s/%s/prediction/feature_info.csv" %>% sprintf(mc$path_report, id_ml))
# feature_info <- read.csv("%s/%s/prediction/feature_info.csv" %>% sprintf(mc$path_report, id_ml))

# feature_info %>% 
#   dplyr::group_by(input_table) %>% 
#   summarise(freq = sum(num_models), zero_freq = sum(num_zeros), num_features = length(unique(feature_name)),
#             max_importance = max(max_importance), avg_importance = sum(avg_importance*num_models)/sum(num_models),
#             max_importance_mms = max(max_importance_mms), avg_importance_mms = sum(avg_importance_mms*num_models)/sum(num_models),
#             max_score = max(max_score), avg_score = sum(avg_score*num_models)/sum(num_models), 
#             avg_score_t10 = ) %>% 
#   ungroup %>% mutate(zero_rate = zero_freq/freq) -> table_info

# To find how many features does each table have among the top 10%, 25% and 50% of features?
ft_10 = feature_info %>% filter(score_q98 > quantile(score_q98, probs = 0.9))  %>% pull(feature_name)
ft_25 = feature_info %>% filter(score_q98 > quantile(score_q98, probs = 0.75)) %>% pull(feature_name)
ft_50 = feature_info %>% filter(score_q98 > quantile(score_q98, probs = 0.5))  %>% pull(feature_name)

raw %>% 
  dplyr::group_by(input_table) %>% 
  dplyr::summarise(
    freq = sum(!is.na(importance)), 
    zero_freq = sum(importance == 0, na.rm = T),
    num_features = length(unique(feature_name)),
    num_features_top10 = sum(unique(feature_name) %in% ft_10),
    num_features_top25 = sum(unique(feature_name) %in% ft_25),
    num_features_top50 = sum(unique(feature_name) %in% ft_50),
    max_importance = max(importance, na.rm = T), 
    avg_importance = mean(importance, na.rm = T), 
    max_importance_mms = max(importance_mms, na.rm = T), 
    avg_importance_mms = mean(importance_mms, na.rm = T), 
    max_score = max(score, na.rm = T), 
    score_q98 = quantile(score, probs = 0.98),
    score_q75 = quantile(score, probs = 0.75),
    avg_score = mean(score, na.rm = T),
    avg_score_t2  = qmean(score, probs = 0.98, na.rm = T),
    avg_score_t25 = qmean(score, probs = 0.75, na.rm = T)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(zero_rate  = zero_freq/freq,
                nft10_rate = num_features_top10/num_features,
                nft25_rate = num_features_top25/num_features,
                nft50_rate = num_features_top50/num_features) -> table_info

table_info %>% plotly::plot_ly(x = ~avg_score, y = ~max_score, color = ~zero_rate, type = 'scatter', mode = 'markers')
table_info %>% plotly::plot_ly(x = ~avg_score_t25, y = ~max_score, color = ~zero_rate, type = 'scatter', mode = 'markers')
table_info %>% plotly::plot_ly(x = ~avg_score_t25, y = ~score_q75, color = ~zero_rate, type = 'scatter', mode = 'markers')
table_info %>% plotly::plot_ly(x = ~avg_score_t2, y = ~score_q75, color = ~zero_rate, type = 'scatter', mode = 'markers')
table_info %>% plotly::plot_ly(x = ~avg_score_t2, y = ~score_q98, color = ~zero_rate, type = 'scatter', mode = 'markers')

table_info %>% write.csv("%s/%s/prediction/table_info.csv" %>% sprintf(mc$path_report, id_ml))
# table_info <- read.csv("%s/%s/prediction/table_info.csv" %>% sprintf(mc$path_report, id_ml))

####
feature_info %>% 
  group_by(feature_name) %>% 
  do({
    .[['input_columns']] %>% 
      gsub(pattern = "\\]", replacement = "") %>% 
      gsub(pattern = "\\[", replacement = "") %>% 
      gsub(pattern = "\\'", replacement = "") %>% 
      gsub(pattern = "\\s", replacement = "") %>% 
      strsplit(',') %>% 
      unlist -> columns
    data.frame(feature_name = .['feature_name'], table_column = paste(.['input_table'], columns, sep = '.'))
  }) -> fc_map

tbd <- fc_map$table_column %>% unique %>% charFilter('\\.event_time', '\\.caseid', '_id', and = F)
fc_map %<>% dplyr::filter(!table_column %in% tbd)

####

# feature_info %>% left_join(fc_map, by = 'feature_name') %>% 
#   group_by(table_column) %>% 
#   summarise(freq = sum(num_models), zero_freq = sum(num_zeros), num_features = length(unique(feature_name)),
#             max_importance = max(max_importance), avg_importance = sum(avg_importance*num_models)/sum(num_models),
#             max_importance_mms = max(max_importance_mms), avg_importance_mms = sum(avg_importance_mms*num_models)/sum(num_models),
#             max_score = max(max_score), avg_score = sum(avg_score*num_models)/sum(num_models)) %>% 
#   ungroup %>% mutate(zero_rate = zero_freq/freq) %>% na.omit -> column_info
  
raw %>% 
  left_join(fc_map, by = 'feature_name') %>% 
  dplyr::group_by(table_column) %>% 
  dplyr::summarise(
    freq = sum(!is.na(importance)), 
    zero_freq = sum(importance == 0, na.rm = T), 
    max_importance = max(importance, na.rm = T), 
    avg_importance = mean(importance, na.rm = T), 
    max_importance_mms = max(importance_mms, na.rm = T), 
    max_score = max(score, na.rm = T), 
    score_q98 = quantile(score, probs = 0.98),
    score_q75 = quantile(score, probs = 0.75),
    avg_score = mean(score, na.rm = T),
    avg_score_t2  = qmean(score, probs = 0.98, na.rm = T),
    avg_score_t25 = qmean(score, probs = 0.75, na.rm = T)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(zero_rate = zero_freq/freq) -> column_info

column_info %>% write.csv("%s/%s/prediction/column_info.csv" %>% sprintf(mc$path_report, id_ml))
# column_info <- read.csv("%s/%s/prediction/column_info.csv" %>% sprintf(mc$path_report, id_ml))


#### 604: FCTI 4: Saving Tables to the exchange folder: ####

copy_to_exchange(mc, 
                 sprintf("%s/%s/prediction/epp_runs.csv", mc$path_reports, id_ml), 
                 'Nima/feature_importances/%s/epp_runs.csv' %>% sprintf(id_ml))
copy_to_exchange(mc, 
                 sprintf("%s/%s/prediction/raw_scores.csv", mc$path_reports, id_ml), 
                 'Nima/feature_importances/%s/raw_scores.csv' %>% sprintf(id_ml))
copy_to_exchange(mc, 
                 "%s/%s/prediction/feature_info.csv" %>% sprintf(mc$path_report, id_ml), 
                 'Nima/feature_importances/%s/feature_info.csv' %>% sprintf(id_ml))
copy_to_exchange(mc, 
                 "%s/%s/prediction/table_info.csv" %>% sprintf(mc$path_report, id_ml), 
                 'Nima/feature_importances/%s/table_info.csv' %>% sprintf(id_ml))
copy_to_exchange(mc, 
                 "%s/%s/prediction/column_info.csv" %>% sprintf(mc$path_report, id_ml), 
                 'Nima/feature_importances/%s/column_info.csv' %>% sprintf(id_ml))

#### 605: FCTI 5: Aggregated Tables from 603: ####
library(dplyr)
# Sample: 7 features with zero predictive value
feature_info %>% select(-periodic_name, -input_columns) %>% 
  filter(zero_rate == 1) %>% head(7) %>% View

# Sample: top 7 features with the highest average scores gained:
feature_info %>% select(-periodic_name, -input_columns) %>% 
  arrange(desc(avg_score)) %>% head(7) %>% View

# Sample: 7 pre-processing input tables with highest zero-rates:
table_info %>% arrange(desc(zero_rate)) %>% head(7) %>% View

# Sample: 7 pre-processing input tables with the lowest max-scores
table_info %>% arrange(max_score) %>% head(7) %>% View

# Sample: 7 pre-processing input tables with the highest average-scores
table_info %>% arrange(desc(avg_score)) %>% head(7) %>% View

# Sample: 7 pre-processing input tables with the highest max-scores
table_info %>% arrange(desc(max_score)) %>% head(7) %>% View

# List: table-columns with 100% zero-rates
column_info %>% filter(zero_rate == 1) %>% View

# Total features coming from BDM tables
bdm_tables = table_info$input_table %>% charFilter('_prd')
table_info %>% 
  select(input_table, num_features) %>% 
  filter(input_table %in% bdm_tables) %>% 
  arrange(num_features) %>% View

# Top 10 features that tend to be the most important in St performance
feature_info %>% select(feature_name, table_column, input_table, zero_rate, avg_score) %>% 
  arrange(desc(avg_score)) %>% head(10)

# A sample of seven features with no predictive value for churn:
feature_info %>% select(feature_name, table_column, input_table, zero_rate, max_score) %>% 
  arrange(max_score) %>% head(7)

# Three models in which features of a wonderlake table are most important:
raw %>% 
  left_join(finfo %>% select(feature_name = name, input_table), by = 'feature_name') %>% 
  filter(input_table == 'mpmp_wlk') %>% 
  arrange(desc(score)) %>% 
  head(3)








#### 303: PPCG: Modify prediction config: ####
path_input_config  = 'path/to/input/yaml/config.yml'
path_output_config = 'path/to/input/yaml/new_config.yml'

pc = yaml::read_yaml(path_input_config)
## Put your changes here:
pc$dataset = 'xxx'
## 
yaml::write_yaml(pc, path_output_config)

pytools = reticulate::import("pytools")

#### 304: Eliminate some components of a pp production orchestration; #####
## Embedding new model in figtree:
# https://elgroup.atlassian.net/browse/PRODUCT-1846

# 1- Make a new branch name:  git checkout -b DELIVERY-3862_6M_Model_Update_GSB
# 2- Open orchestration config with an editor
# 3- change mlsampler_for_train, remove random_split sampler and add num_months and downsampling if required
# 4- change mlsampler_for_robustness 
# 5- update prediction config (Don't forget to remove test and train keys)
# 6- find configs for all stages from jobwrangler and update the skipped_components and replaced_configs configs below
# 7- Run the widget
# 8- Review the output config. Make sure the test orchestration starts with mlsampler_for_train and all references are correct
# 9- Update refresh_execution_month in the config
# 10- put all tags keys inside brackets like tags: [mlsampler/robustness, st]
# 11 - insert components_version key from original config before parameters key
# 12- run the tests config with tag like this: refresh/2022-06,testing/DELIVERY-3862,st
# 13- commit and push the branch if succeeded


library(magrittr)
library(rlist)

input_orchestration_config  = "/Users/nima/Documents/software/Python/projects/fig-tree/configs/orchestration/st/gsb.yml"
output_orchestration_config = "/Users/nima/Documents/software/Python/projects/fig-tree/configs/orchestration/st/gsb_test.yml"

skipped_components = list(
  
  preprocessing_staging = '77c761d4-b080-4258-993f-0b1764a417f6',
  preprocessing_bdm = 'a663ce4d-5296-4de2-85e0-e4c6e8ab299d',
  preprocessing_sdm = 'd2f756fa-28b8-4e67-8b9f-b3f275f2055d',
  dqc_ppp_staging_profiling = '',
  dqc_ppp_sdm_profiling = '',
  dqc_ppp_staging_check_target = '',
  obsmapper_st = '',
  eventmapper_st = '',
  mlmapper_st = '4fa5a66c-2320-4ac4-a775-8e6d1ca86031',
  insights_mlmapper_st = 'eedfda72-a7c1-4300-b05a-40764cfc37c3',
  dqc_mlmapper_profiling_st = '',
  dqc_mlmapper_checks_st = '')

replaced_configs = list(
  'predictions/st/train' = '4b6ff69d-38d7-4b13-8c2e-f27cb0b736f3'
)

additional_injections = list(
  prediction_train_st = list(test = 'test', train = 'train'),
  prediction_robustness_st = list(test = 'test', train = 'train')
)

yaml::read_yaml(input_orchestration_config) -> input_config


ids = input_config$jobs %>% lapply(function(u) u$id) %>% unlist

output_config = input_config
output_config$jobs %<>% rlist::list.remove(which(ids %in% names(skipped_components)))

output_config %<>% rutils::list.clean()

for(sc in names(skipped_components)){
  output_config %<>% list.replace(pattern = sprintf("\\$\\{%s.runid\\}", sc), replacement = skipped_components[[sc]])
}

prod_config_names = output_config$jobs %>% lapply(function(u) 
  rutils::chif(is.null(u[['production_config_name']]), NA, u[['production_config_name']])) %>% unlist

for(rc in names(replaced_configs)){
  for(i in which(prod_config_names == rc)){
    output_config$jobs[[i]]$config_ref <- replaced_configs[[rc]]
    output_config$jobs[[i]]$production_config_name <- NULL
  }
}

ids = output_config$jobs %>% lapply(function(u) u$id) %>% unlist

for(ai in names(additional_injections)){
  for(i in which(ids == ai)){
    output_config$jobs[[i]]$injection %<>% rlist::list.merge(additional_injections[[ai]])
  }
}

# 

yaml::write_yaml(output_config, output_orchestration_config, 
                 indent.mapping.sequence = F, 
                 handlers = list(logical = function(x) {
                   result <- ifelse(x, "true", "false")
                   class(result) <- "verbatim"
                   return(result)
                 }))
