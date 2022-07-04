#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)
source('R_Pipeline/libraries/ext_rml.R')

################ Inputs: ################
config_filename = 'gss_config_xx.yml'
  
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read: ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'greedy_subset_scorer', config_filename, sep = '/')) -> gss_config

verify(gss_config$training_months, c('integer', 'numeric'), null_allowed = T) -> gss_config$training_months
verify(gss_config$horizon, c('numeric', 'integer'), default = 3, lengths = 1) -> gss_config$horizon
verify(gss_config$target, 'character', default = 'ERPS', lengths = 1) -> gss_config$target
verify(gss_config$save_best_model, 'logical', default = T) -> gss_config$save_best_model
verify(gss_config$ruthless, 'logical', default = F) -> gss_config$ruthless
verify(gss_config$input_clustering, 'list', lengths = 3, names_identical = c('file', 'fname_col', 'cluster_col'), null_allowed = T) -> gss_config$input_clustering
verify(gss_config$sample_ratio, 'numeric', domain = c(0,1), lengths = 1, default = 0.02) -> gss_config$sample_ratio
verify(gss_config$metrics, 'character', default = 'gini') -> gss_config$metrics

gss_path = mc$path_reports %>% paste(id_ml, sep = '/')
if(!file.exists(gss_path)) dir.create(gss_path)
gss_path %<>% paste('greedy_subset_scorer', sep = '/')
if(!file.exists(gss_path)){dir.create(gss_path)}

gss_output <- gss_path %>% paste(gss_config$output, sep = '/')
if(file.exists(gss_output)){
  out = read.csv(gss_output, as.is = T)
  # ttt = out$fitting_time %>% as.character %>% lubridate::as_datetime()
  # wna = which(is.na(ttt))
  # ttt[wna] <- out$fitting_time[wna] %>% as.numeric %>% as.POSIXct(origin = '1970-01-01 00:00:00')
  # assert(sum(is.na(ttt)) == 0, 'Some values in column fitting_time are not in date-time format! Fix them before running the module or use a new output file.')
  # out$fitting_time <- as.character(ttt)
} else {
  out = NULL
}

# wt <- WIDETABLE(name = 'wide', path = path.ml)
# wt  %>% saveRDS(sprintf("%s/wide.rds", path.ml))
wt  <- readRDS(sprintf("%s/wide.rds", path_ml))

################ Functions: ################
cluster_distributed_sample = function(clusters, sample_ratio){
  clusters %<>% mutate(cluster = paste0('C', cluster))
  clusters %>% group_by(cluster) %>% 
    summarise(mintake = floor(sample_ratio*length(fname)), maxtake = ceiling(sample_ratio*length(fname))) %>% 
    ungroup %>% 
    rutils::column2Rownames('cluster') -> nfet
  
  picked = c(); extras = c(); 
  for(i in unique(nfet$mintake) %>% setdiff(0)){
    for(cn in rownames(nfet)[nfet$mintake == i]){
      picked %<>% c(clusters$fname[clusters$cluster == cn] %>% sample(size = i))
    }
  }
  
  extra_clusters = rownames(nfet)[(nfet$maxtake - nfet$mintake) == 1]
  clusters %>% filter(cluster %in% extra_clusters, !(fname %in% picked)) %>% 
    group_by(cluster) %>% 
    do({.[sample(sequence(nrow(.)), size = 1), , drop = F]}) %>% 
    pull(fname) -> extras
  
  picked %>% c(extras %>% sample(size = ceiling(sample_ratio*nrow(clusters)) - length(picked)))
}

################ Run: ################
wtcols             = rbig::colnames(wt)
exclude            = c(gss_config$exclude_columns, mc$leakages, 'V1','X', 'caseID', 'eventTime')
features           = wtcols %-% charFilter(wtcols, exclude, and = F)

ylabels            = get_labels(wt, mc, target = gss_config$target, horizon = gss_config$horizon)

if(!is.null(gss_config$input_clustering)){
  gss_config$input_clustering$file %<>% find_file(paths = paste(mc$path_reports, id_ml, 'feature_clustering', sep = '/'))
  clusters = read.csv(gss_config$input_clustering$file, stringsAsFactors = F)
  features %<>% intersect(clusters$fname)
  clusters %<>% filter(fname %in% features)
  clusters[['cluster']] <- clusters[[gss_config$input_clustering$cluster_col]]
}

for(test_date in gss_config$dates){
  
  build_model_from_config(gss_config$model, mc, 
                          target = gss_config$target, 
                          horizon = gss_config$horizon, 
                          test_date = test_date) -> base
  
  dataset = extract_training_dataset(wt, test_date = test_date, features = features, master_config = mc,
                                     target = gss_config$target, horizon = gss_config$horizon,
                                     training_months = gss_config$training_months)
  
  bn = 0
  pf_best = -Inf
  
  if(!is.null(base$config$features.include)){
    try(base$fit(dataset$train$X, dataset$train$y), silent = T)
  }
  if(base$fitted){
    pf_best = base$predict(dataset$test$X) %>% {.[,1]} %>% 
      rml::correlation(dataset$test$y, metrics = gss_config$metrics, quantiles = gss_config$quantiles) %>% 
      {.[1]}
  } else {
    # if(!is.null(out)){
    # todo: This part (retrieving model from scores table) need to be re-visited!
    if(FALSE){
      metric_colname = colnames(out) %-% c('fname', 'fclass', 'n_unique', 'importance', 'model', 'fitting_time') %>% {.[1]}
      out[out$test_date == test_date,] %>% na.omit -> date_scores
      if(nrow(date_scores) > 0){
        date_scores[[metric_colname]] %>% order(decreasing = T) -> ord
        # bmn: best model name; bn: batch number
        bmn = date_scores$model[ord[1]]
        bn  = max(date_scores$batch_number)
        base$name = bmn
        base$objects$features = date_scores %>% filter(model == bmn) %>% select(fname, fclass, n_unique, importance)
        pf_best = date_scores %>% filter(model == bmn) %>% pull(metric_colname) %>% max
      }
    }
  }

  n_fails   = 0
  remaining = features
  used      = character()
  while((bn < gss_config$num_batches) & (n_fails < gss_config$early_stopping) & (length(remaining) > 0)){
    bn        = bn + 1
    modlist   = list()
    remaining = features %-% rml::model_features(base)
    if(gss_config$ruthless){
      remaining = remaining %-% used
      # if(!is.null(out)){
      #   remaining = remaining %-% out$fname[out$test_date == test_date]
      # }
    }
    
    if(length(remaining) > 0){
      for(j in sequence(gss_config$batch_size)){
        model = base$deep_copy(name_suffix = sprintf("_B%sM%s", bn, j))
        model$config$cv.set <- list(dataset$test)
        
        # fetsubset: random subset of features to be added to the existing features:
        if(is.null(gss_config$input_clustering)){
          subset = remaining %>% sample(size = min(gss_config$sample_ratio*ncol(dataset$train$X), length(remaining)))
        } else {
          clusters  = clusters %>% filter(fname %in% remaining)
          subset    = cluster_distributed_sample(clusters, sample_ratio = gss_config$sample_ratio)
        }
        used = used %U% subset
        if(is.null(base$objects$features)){model$config$features.include <- subset} else {
          model$config$features.include = model_features(base) %>% intersect(features) %>% union(subset)  
        }
        model$reset(set_features.include = F)
        modlist[[model$name]] <- model
      }
      
      modlist %>% rml::service_models(dataset$train$X, dataset$train$y, dataset$test$X, dataset$test$y, 
                                      num_cores = gss_config$num_cores, metrics = gss_config$metrics, 
                                      quantiles = gss_config$quantiles) -> res
      
      out %<>% dplyr::bind_rows(res$results %>% 
                                  mutate(batch_number = bn, target = gss_config$target, horizon = gss_config$horizon, test_date = test_date))
      out %>% write.csv(sprintf("%s/%s", gss_path, gss_config$output), row.names = F)
      
      # Pick the best model:
      if(res$best_performance > pf_best){
        cat('\n', "Model performance improved in batch %s: %s ---> %s" %>% sprintf(bn, pf_best, res$best_performance), '\n')
        base    = res$best_model
        pf_best = res$best_performance
        n_fails = 0
      } else {
        n_fails = n_fails + 1
      }
    }
  }

  if(gss_config$save_best_model){
    base %>% pipeline.save_model(path_models = mc$path_models %>% paste(id_ml, sep = '/'), 
                                 test_date = test_date,
                                 target = gss_config$target, horizon = gss_config$horizon)
  }
}

