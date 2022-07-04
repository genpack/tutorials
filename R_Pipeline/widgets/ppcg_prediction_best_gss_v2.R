# Rscript R_Pipeline/widgets/ppcg_prediction_best_gss_v2.R 

# This module, generates epp prediction config of the best model in a given gss job. (Currently only works for )
# You can also make some changes to the config as well by setting parameter 'changes' in the config.
# This module uses a config file epp_best_gss.yml in the configs/widgets

###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')
source('R_Pipeline/libraries/io_tools.R')

config_filename = 'ppcg_prediction_best_gss.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}
###### Read: ######
# Read feature scores:
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

scores = NULL
for(sc in config$input_scores){
  if(!is.null(sc$agent_runid) & !is.null(sc$model_runid)){
    sprintf("%s/prediction/agentrun=%s/modelrun=%s/raw_scores.csv", 
            mc$path_data, sc$agent_runid, sc$model_runid) -> sc$filename
    if(!file.exists(sc$filename)){
      copy_prediction_to_local(mc, agentrun_id = sc$agent_runid, modelrun_id = sc$model_runid)
    }
    assert(file.exists(sc$filename), sprintf('File %s does not exist.', sc$filename))
    
    # if input config is not specified, takes the config of the first GSS model:
    if(is.null(config$input_config)){
      config$input_config = list()
      sprintf("%s/prediction/agentrun=%s/modelrun=%s/config.json", 
              mc$path_data, 
              sc$agent_runid,
              sc$model_runid) -> config$input_config$filename
      config$input_config$filetype = 'json'
      if(!file.exists(config$input_config$filename)){
        copy_prediction_to_local(mc, agentrun_id = sc$agent_runid, modelrun_id = sc$model_runid, files = 'config.json')
      }
      assert(file.exists(config$input_config$filename), "File %s does not exist!" %>% sprintf(config$input_config$filename))
    }
  }
  
  if(!is.null(sc$filename)){
    if(!file.exists(sc$filename)){
      reports_gss_path = sprintf("%s/%s/greedy_subset_scorer", mc$path_reports, id_ml)
      sc$filename %<>% find_file(paths = reports_gss_path)
    }
    
    sc$filename %>% bigreadr::fread2() -> si
  }
  
  if(!is.null(sc$operation)) {si %<>% rutils::operate(sc$operation)}
  
  if(!is.null(sc$quantile)){
    si %<>% group_by(model_id) %>% do({
      filter(., importance > quantile(importance, probs = 1.0 - sc$quantile))
    }) %>% ungroup
  }
  
  scores %<>% rbind(si)
}

prd_config = read_file(config$input_config)

scores$test_date %<>% as.character
if(is.null(config$gss_dates)){
  config$gss_dates = unique(scores$test_date)
}

verify(config$model_start_rank, c('numeric', 'integer'), domain = c(1, 10), lengths = 1, default = 1) %>% as.integer -> config$model_start_rank

verify(config$remove_zif, 'logical', lengths = 1, domain = c(T,F), default = T) -> config$remove_zif
verify(config$feature_name_col, 'character', lengths = 1, default = "feature_name") -> config$feature_name_col
verify(config$dates, 'character', default = "") -> config$dates
verify(config$num_seeds, c('numeric', 'integer'), domain = c(1, 1000), lengths = 1, default = 1) -> config$num_seeds
verify(config$ranking_metric, 'character', lengths = 1, 
       domain = c('model_performance', 'feature_score'), 
       default = 'feature_score') -> config$ranking_metric
verify(config$performance_metric, 'character', lengths = 1, 
       default = 'gini_coefficient') -> config$performance_metric

###### Pick Features: ######

if(config$ranking_metric == 'model_performance'){
  config$num_models <- verify(config$num_models, c('numeric', 'integer'), lengths = 1, domain = c(1, Inf), default = 1) %>% as.integer
  scores %>% 
    dplyr::distinct(model_id, test_date, batch_number, .keep_all = T) %>% 
    filter(test_date %in% config$gss_dates) %>% 
    arrange(test_date, desc(!!sym(config$performance_metric))) %>% 
    group_by(test_date) %>% 
    do({.[sequence(config$num_models + config$model_start_rank - 1) %-% sequence(config$model_start_rank - 1),]}) -> bm
  
  fset <- scores %>% filter(model_id %in% bm$model_id) %>% 
    mutate(score = importance*!!sym(config$performance_metric))

  if(config$remove_zif){fset %<>% filter(score > 0)}
  
  fset %>% arrange(desc(score)) %>% 
    pull(!!sym(config$feature_name_col)) %>% unique -> fset
  
  if(!is.null(config$num_features)){fset %<>% head(config$num_features)}
  
} else if (config$ranking_metric == 'feature_score'){
  config$num_features <- verify(config$num_features, c('numeric', 'integer'), lengths = 1, domain = c(1, Inf), default = 900) %>% as.integer
  scores %>% 
    mutate(score = importance*!!sym(config$performance_metric)) %>% 
    group_by(feature_name) %>% summarise(max_score = max(score)) %>% 
    filter(max_score > 0) %>% arrange(desc(max_score)) %>% head(config$num_features) %>% 
    pull(feature_name) -> fset
}

###### Build Config: ######

for(test_date in config$dates){
  out = prd_config %>% list.extract('dataset', 'mode', 'optimise', 'verbose','version', 'max_memory_GB')
  if(!is.null(config$mlsampler_id)){out$dataset = config$mlsampler_id}
  if(test_date != ""){
    cname = paste(config$output_name, test_date, sep = '_')
    out$train = paste('train', test_date, sep = '_')
    out$test  = paste('test' , test_date, sep = '_')
  } else {cname = config$output_name}
  
  if(config$num_seeds > 1){
    out$model = list(
      classifier = list(
        type = 'AveragingEnsembler',
        parameters = list(
          num_models = list(config$num_seeds %>% as.integer),
          seed = sequence(config$num_seeds),
          partial = T,
          persist_predictions = T
        ),
        models = list(prd_config$model %>% rutils::list.remove('features'))))
  } else {
    out$model = prd_config$model
  }

  out$model$features <- NULL
  
  if(!is.null(config$changes)){out %<>% rutils::list.edit(config$changes)}
  
  out$model$features <- fset 
  
  yaml::write_yaml(out, pp_config_filename(config$output_path, cname))
}
