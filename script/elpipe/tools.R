library(gener)
library(magrittr)
library(yaml)

# converts a model into a transformer. 
# Note: when injecting a model config 1 as transformer of config 2, 
# transformers of model config 1 should be added to the list of transformers of config 2. 
# Names of transformers of model config 1 should be genertaed and set in config 2,
# property 'transform_kill_after_use' for all transformers of model config 1, must be set to True 
elpipe.model_to_transformer = function(tname, model_config, inputs = NULL){
  tlist = elpipe.extract_transformers(model_config)
  names(tlist) = paste(tname, names(tlist), sep = '_')
  if(is.empty(tlist)){
    root_transformers = list(model_config$features)
  } else {
    root_transformers = names(tlist) %-% (tlist %>% list.pull('transform_kill_after_use') %>% which %>% names)
    if((length(tlist) == 1) & (tlist[[1]]$class == 'elb.Transformations.local.CategoricalDecomposer')){
      root_transformers %<>% as.list %>% list.add(model_config$features)
    }
  }
  list(
    elb.Transformations.local.WrapperModelAsTransformer = 
    list(transform_name = tname,
         transform_columns = root_transformers,
         name = model_config$model$name,
         parameters = model_config$parameters))
}

elpipe.inject_transformer = function(config, ...){
  
}

# builds an ensembler model from a given model, by generating random seeds

# embedds/injects given model config to be ensembled by an ensembler config:
elpipe.ensembler.inject_model = function(ensembler_config, model_config){
  ensembler_config$model$models[[1]] <- model_config$model %>% list.remove('features')
  ensembler_config$model$models[[1]]$n_bootstrap <- 0
  ensembler_config$model$features <- model_config$model$features
  ensembler_config$dataset <- model_config$dataset
  return(ensembler_config)
}



elpipe.hierarchical_transformer_list = function(tnames, flat, features){
  transformers = list()
  assert(tnames %<% names(flat))
  
  for(trn in tnames){
    tr = flat[[trn]]
    if(tr$class == 'elb.Transformations.local.WrapperModelAsATransformer'){
      tr_class = tr$name
    } else {
      tr_class = tr$class
    }
    
    tc_features = c()
    tc_transformers = c()
    
    for(item in tr$transform_columns){
      if(sum(item %in% features) > 0){
        tc_features = tc_features %U% (item %^% features)
      } else if(item %in% names(flat)){
        tc_transformers = c(tc_transformers, item)
      } else {stop('Unknown column!')}
    }

    transformers[[trn]] = list(name = trn, class = tr_class, config = list(features.include = tc_features, features.exclude = tr$exclude), params = tr$parameters) %>% list.clean
    transformers[[trn]]$config <- transformers[[trn]]$config %<==>% (tr %>% list.remove('name','transform_kill_after_use', 'transform_name','transform_columns', 'class', 'exclude', 'params'))
    transformers[[trn]]$transformers = elpipe.hierarchical_transformer_list(tc_transformers, flat, features)
  }
  return(transformers)
}

# Extracts transformers from a model config:
elpipe.extract_transformers = function(config){
  flat = list()
  for(i in sequence(length(config$model$transforms$X_transforms))){
    tr_class = names(config$model$transforms$X_transforms[[i]])
    tr = config$model$transforms$X_transforms[[i]][[1]]
    if(is.null(tr$transform_name)){
      tname = 'T' %>% paste0(i - 1)
    } else {tname = tr$transform_name}
    flat[[tname]] <- tr
    flat[[tname]]$class <- tr_class
    flat[[tname]]$transform_kill_after_use %<>% verify('logical', domain = c(T, F), lengths = 1, default = F)
  }
  return(flat)  
}

elpipe.to_hierarchical = function(config){
  flat = elpipe.extract_transformers(config)
  if(is.empty(flat)){
    root_transformers = c()
  } else {
    root_transformers = names(flat) %-% (flat %>% list.pull('transform_kill_after_use') %>% which %>% names)
  }
  if(inherits(config$model$features, 'list')) config$model$features %<>% unlist
  list(
    class  = config$model$name,
    name   = 'base',
    params = config$model$parameters,
    transformers = elpipe.hierarchical_transformer_list(root_transformers, flat, config$model$features),
    config =  config$model %>% 
      list.remove('name', 'parameters', 'transforms', 'features') %>% 
      list.add(features.include = config$model$features)
  )
}

elpipe.extract_transformers_from_hierarchical = function(hc){
  tlist = list()
  for(tr in hc$transformers){
    tlist[[tr$name]] <- elpipe.extract_transformers_from_hierarchical(tr)
  }
  return(tlist)
}

elpipe.class_mapping = c(
  sklearn.preprocessing.OneHotEncoder = 'CFG.SCIKIT.OHE',
  elb.Transformations.local.KMeansTransformer = 'CFG.ELB.KM',
  sklearn.decomposition.PCA = 'CFG.SCIKIT.PCA',
  elb.Transformations.local.AddTrainedModelProbabilities = 'CFG.ELB.ATMP',
  category_encoders.TargetEncoder = 'CFG.CATEGORY_ENCODERS.TE',
  elb.Transformations.local.CategoricalDecomposer = 'CFG.ELB.OHE',
  sklearn.preprocessing.MinMaxScaler = 'CFG.SCIKIT.MMS',
  sklearn.preprocessing.MaxAbsScaler = 'CFG.SCIKIT.MAS',
  sklearn.preprocessing.RobustScaler = 'CFG.SCIKIT.RS',
  sklearn.preprocessing.StandardScaler = 'CFG.SCIKIT.ZFS',
  ClassificationModels.local.WrapperLightGBM = 'CFG.ELB.LGBM',
  ClassificationModels.local.WrapperLogisticRegression = 'CFG.ELB.LR',
  elb.Transformations.mlpy.LogisticRegressionTransformer = 'CFG.SCIKIT.LR',
  ClassificationModels.local.WrapperXGBoost = 'CFG.ELB.XGB', 
  sklearn.cluster.KMeans = 'CFG.SCIKIT.KM')


maler.class_mapping = c(
  sklearn.preprocessing.OneHotEncoder = 'ENC.SCIKIT.OHE',
  elb.Transformations.local.KMeansTransformer = 'BIN.MALER.KMEANS',
  sklearn.decomposition.PCA = 'MAP.SCIKIT.PCA',
  category_encoders.TargetEncoder = 'ENC.CATEGORY_ENCODERS.TE',
  elb.Transformations.local.CategoricalDecomposer = 'ENC.FASTDUMMIES.OHE',
  sklearn.preprocessing.MinMaxScaler = 'MAP.SCIKIT.NR',
  ClassificationModels.local.WrapperLightGBM = 'CLS.SPARKLYR.GBT',
  ClassificationModels.local.WrapperLogisticRegression = 'CLS.SCIKIT.LR',
  ClassificationModels.local.WrapperXGBoost = 'CLS.SCIKIT.XGB', 
  sklearn.cluster.KMeans = 'BIN.SCIKIT.KM')

hierarchical_to_mlconfig = function(hc, class_mapping = elpipe.class_mapping){
  if(is.null(class_mapping)){
    mltype = hc$class
  } else {
    mltype = class_mapping[hc$class]
  }
  out = new(mltype, name = hc$name, 
            features     = chif(is.null(hc$config$features.include), character(), hc$config$features.include), 
            parameters   = chif(is.null(hc$params), list(), hc$params), 
            transformers = list())
  for(tr in hc$transformers){
    nn = length(out$transformers)
    out$transformers[[nn + 1]] <- hierarchical_to_mlconfig(tr, class_mapping = class_mapping)
  }
  return(out)
}


hierarchical_to_maler = function(hc, class_mapping = maler.class_mapping){
  if(is.null(class_mapping)){
    mltype = hc$class
  } else {
    mltype = class_mapping[hc$class]
  }
  
  outconfig = hc$config %>% list.extract('features.include', 'features.exclude') %<==>% hc$params %>% 
    list.add(name = hc$name)
  out = do.call(mltype, args = outconfig)
  for(tr in hc$transformers){
    nn = length(out$transformers)
    out$transformers[[nn + 1]] <- hierarchical_to_mlconfig(tr, class_mapping = class_mapping)
  }
  return(out)
}

build_sampler_config = function(ml_id = '4dd4692e-cb3e-444e-b2cf-a17e89bdcc27', num_partitions = 1, test_date = '2018-09-01', train_date = NULL, optimise_date = NULL, validation_date = NULL, features = NULL){
  if(is.null(train_date)){train_date = test_date %>% add_month(-3)}
  if(is.null(optimise_date)){optimise_date = test_date}
  if(is.null(validation_date)){validation_date = test_date %>% add_month(1)}
  
  train_list = list(
    list(end_time = train_date %>% add_year(-1), split = as.integer(1), splitter = 'timeseries_split_by_day'),
    list(end_time = train_date %>% add_month(1), split = as.integer(0), splitter = 'timeseries_split_by_day'))
    
  test_list = list(
    list(end_time = test_date, split = as.integer(1), splitter = 'timeseries_split_by_day'),
    list(end_time = test_date %>% add_month(1), split = as.integer(0), splitter = 'timeseries_split_by_day'))
  
  optimise_list = list(
    list(end_time = optimise_date, split = as.integer(1), splitter = 'timeseries_split_by_day'),
    list(end_time = optimise_date %>% add_month(1), split = as.integer(0), splitter = 'timeseries_split_by_day'))

  validate_list = list(
    list(end_time = validation_date, split = as.integer(1), splitter = 'timeseries_split_by_day'),
    list(end_time = validation_date %>% add_month(1), split = as.integer(0), splitter = 'timeseries_split_by_day'))

  list(dataset = ml_id, num_partitions = as.integer(num_partitions), 
       outputs = list(list(train = train_list), list(optimise = optimise_list), list(test = test_list), list(validate = validate_list)),
       columns = c('caseID', 'eventTime', 'label', 'tte', features)
  )
}


