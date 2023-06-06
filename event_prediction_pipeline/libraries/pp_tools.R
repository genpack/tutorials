el_model_types = c('ClassificationModels.local.WrapperXGBoost', 'ClassificationModels.local.WrapperLightGBM', 'ClassificationModels.local.WrapperLogisticRegression', 'ClassificationModels.local.WrapperCatBoost')

# converts a model into a transformer. 
# Note: when injecting a model config 1 as transformer of config 2, 
# transformers of model config 1 should be added to the list of transformers of config 2. 
# Names of transformers of model config 1 should be genertaed and set in config 2,
# property 'transform_kill_after_use' for all transformers of model config 1, must be set to True 
epp.model_to_transformer = function(tname, model_config, inputs = NULL){
  tlist = epp.extract_transformers(model_config)
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

epp.inject_transformer = function(config, ...){
  
}

# builds an ensembler model from a given model, by generating random seeds

# embedds/injects given model config to be ensembled by an ensembler config:
epp.ensembler.inject_model = function(ensembler_config, model_config){
  ensembler_config$model$models[[1]] <- model_config$model %>% list.remove('features')
  ensembler_config$model$models[[1]]$n_bootstrap <- 0
  ensembler_config$model$features <- model_config$model$features
  ensembler_config$dataset <- model_config$dataset
  return(ensembler_config)
}



epp.hierarchical_transformer_list = function(tnames, flat, features){
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
    transformers[[trn]]$transformers = epp.hierarchical_transformer_list(tc_transformers, flat, features)
  }
  return(transformers)
}

# Extracts transformers from a model config:
epp.extract_transformers = function(config){
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

epp.to_hierarchical = function(config){
  flat = epp.extract_transformers(config)
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
    transformers = epp.hierarchical_transformer_list(root_transformers, flat, config$model$features),
    config =  config$model %>% 
      list.remove('name', 'parameters', 'transforms', 'features') %>% 
      list.add(features.include = config$model$features)
  )
}

epp.extract_transformers_from_hierarchical = function(hc){
  tlist = list()
  for(tr in hc$transformers){
    tlist[[tr$name]] <- epp.extract_transformers_from_hierarchical(tr)
  }
  return(tlist)
}

epp.class_mapping = c(
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

cfg.class_mapping = c(
  CLS.SKLEARN.XGB = 'CFG.ELLIB.XGB'
)

rml.class_mapping = c(
  sklearn.preprocessing.OneHotEncoder = 'ENC.SCIKIT.OHE',
  elb.Transformations.local.KMeansTransformer = 'BIN.RML.KMEANS',
  sklearn.decomposition.PCA = 'MAP.SCIKIT.PCA',
  category_encoders.TargetEncoder = 'ENC.CATEGORY_ENCODERS.TE',
  elb.Transformations.local.CategoricalDecomposer = 'ENC.FASTDUMMIES.OHE',
  sklearn.preprocessing.MinMaxScaler = 'MAP.SCIKIT.NR',
  ClassificationModels.local.WrapperLightGBM = 'CLS.SPARKLYR.GBT',
  ClassificationModels.local.WrapperLogisticRegression = 'CLS.SCIKIT.LR',
  ClassificationModels.local.WrapperXGBoost = 'CLS.SCIKIT.XGB', 
  sklearn.cluster.KMeans = 'BIN.SCIKIT.KM')

hierarchical_to_mlconfig = function(hc, class_mapping = epp.class_mapping){
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


hierarchical_to_rml = function(hc, class_mapping = rml.class_mapping){
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




MODEL_CONFIG = setRefClass('MODEL_CONFIG',
  fields  = list(name = "character", type = "character", config = "list", features = 'character', parameters = 'list', transformers = 'list'),
  methods = list(
    as.el_transformer = function(){
      if(is.empty(transformers)){
        if(is.empty(features)){
          root_transformers = NULL
        } else {
          if(length(features) == 1){
            if(features %>% substr(1,6) == 'params'){
              root_transformers = list(features)
            } else {
              root_transformers = list(list(features))
            }
          } else {
            root_transformers = list(features)
          }
        }
      } else {
        root_transformers = list()
        for(tr in transformers){
          root_transformers %<>% c(tr$name)
        }
      }
      
      out = list(transform_name = name, 
                 transform_columns = root_transformers) %>% list.clean
      
      if(type %in% el_model_types){
        class = 'ellib.Transformations.local.WrapperModelAsATransformer'
        out$name = type
        out$parameters = parameters
        out$logit = logit
      } else {
        class = type
        out = out %<==>% parameters
      }
      out %<>% list
      names(out) <- class
      return(out %>% list.clean)
    },
    
    get.el_transformers = function(tlist = list()){
      for(i in sequence(length(transformers))){
        tlist %<>% transformers[[i]]$get.el_transformers()
        tlist[[length(tlist) + 1]]  <- transformers[[i]]$as.el_transformer()
      }
      
      treated = c(); i = 0
      while(i < length(tlist)){
        i = i + 1
        if(tlist[[i]][[1]]$transform_name %in% treated){
          tlist[[i]] <- NULL
        } else {
          tlist[[i]][[1]]$transform_kill_after_use <- !(tlist[[i]][[1]]$transform_name %in% list.pull(transformers, 'name'))
          treated = c(treated, tlist[[i]][[1]]$transform_name)
        }
      }
      # Alternatively you can do this:
      # tk = lapply(tlist, function(x) x[[1]]$transform_name) %>% unlist %>% duplicated %>% {!.} %>% which
      # tlist %<>% list.extract(tk)
      # 
      return(tlist)
    },
    
    get.epp_config = function(){
      tl = list(Y_transforms = list(
        list(ellib.Transformations.local.ClassificationTarget = c())
      ))
      tl$X_transforms = get.el_transformers()
      list(dataset  = config$dataset,
           mode     = 'train',
           optimise = TRUE,
           verbose  = as.integer(1),
           # max_memory_GB = 2,
           model = list(
             name = type,
             parameters = parameters,
             transforms = tl,
             features = features
           )) -> cfg
      # Correction:
      # for(i in sequence(length(cfg$model$transforms$X_transforms))){
      #   cfg$model$transforms$X_transforms[[i]][[1]]$transform_name = paste0("\"", cfg$model$transforms$X_transforms[[i]][[1]]$transform_name, "\"")
      #   if('transform_columns' %in% names(cfg$model$transforms$X_transforms[[i]][[1]])){
      #     tcstr = c()
      #     for(tc in cfg$model$transforms$X_transforms[[i]][[1]]$transform_columns){
      #       ss = paste0("\"", tc, "\"")
      #       if(length(tc) > 1){
      #         ss = paste0("[", paste(ss, collapse = ','),"]")
      #       }
      #       tcstr = c(tcstr, ss)
      #     }
      #     tcstr  %<>%  paste(collapse = ',')
      #     cfg$model$transforms$X_transforms[[i]][[1]]$transform_columns <- paste0("[", tcstr, "]")
      #   }
      # }
      return(cfg)
    },
    
    write.epp_config = function(filename = 'config.yml', path = getwd()){
      hnd = list(
        logical = function(x) {
          result <- ifelse(x, "True", "False")
          class(result) <- "verbatim"
          return(result)
        }
      )
      get.epp_config() %>% yaml::write_yaml(path %>% paste(filename, sep = '/'), handlers = hnd)
    }
  )
)    


CFG.ELLIB.XGB = setRefClass('CFG.ELLIB.XGB', contains = 'MODEL_CONFIG', 
    fields = list(logit = 'logical'),                           
    methods = list(
      initialize = function(...){
        callSuper(...)
        type <<- 'ClassificationModels.local.WrapperXGBoost'
        if(is.empty(name)){name <<- 'ELXGB' %>% paste0(sample(10000:99999, 1))}
      }
    )
)

CFG.ELLIB.LR = setRefClass('CFG.ELLIB.LR', contains = 'MODEL_CONFIG', 
  fields = list(logit = 'logical'),
  methods = list(
    initialize = function(...){
      callSuper(...)
      type <<- 'ClassificationModels.local.WrapperLogisticRegression'
      if(is.empty(name)){name <<- 'ELLR' %>% paste0(sample(10000:99999, 1))}
    }
  )
)

CFG.ELLIB.LGBM = setRefClass('CFG.ELLIB.LGBM', contains = 'MODEL_CONFIG', 
  fields = list(logit = 'logical'),
  methods = list(
    initialize = function(...){
     callSuper(...)
     type <<- 'ClassificationModels.local.WrapperLightGBM'
     if(is.empty(name)){name <<- 'ELLGBM' %>% paste0(sample(10000:99999, 1))}
    }
  )
)

CFG.ELLIB.CATB = setRefClass('CFG.ELLIB.CATB', contains = 'MODEL_CONFIG', 
                                fields = list(logit = 'logical'),
                                methods = list(
                                  initialize = function(...){
                                    callSuper(...)
                                    type <<- 'ClassificationModels.local.WrapperCatBoost'
                                    if(is.empty(name)){name <<- 'ELLCATB' %>% paste0(sample(10000:99999, 1))}
                                  }
                                )
)
CFG.SCIKIT.MMS = setRefClass('CFG.SCIKIT.MMS', contains = 'MODEL_CONFIG', 
   methods = list(
     initialize = function(...){
       callSuper(...)
       type <<- 'sklearn.preprocessing.MinMaxScaler'
       if(is.empty(name)){name <<- 'SKMMS' %>% paste0(sample(10000:99999, 1))}
     }
   )
)
CFG.SCIKIT.MAS = setRefClass('CFG.SCIKIT.MAS', contains = 'MODEL_CONFIG', 
                             methods = list(
                               initialize = function(...){
                                 callSuper(...)
                                 type <<- 'sklearn.preprocessing.MaxAbsScaler'
                                 if(is.empty(name)){name <<- 'SKMAS' %>% paste0(sample(10000:99999, 1))}
                               }
                             )
)
CFG.SCIKIT.RS = setRefClass('CFG.SCIKIT.RS', contains = 'MODEL_CONFIG', 
                             methods = list(
                               initialize = function(...){
                                 callSuper(...)
                                 type <<- 'sklearn.preprocessing.RobustScaler'
                                 if(is.empty(name)){name <<- 'SKRS' %>% paste0(sample(10000:99999, 1))}
                               }
                             )
)
CFG.SCIKIT.ZFS = setRefClass('CFG.SCIKIT.ZFS', contains = 'MODEL_CONFIG', 
                             methods = list(
                               initialize = function(...){
                                 callSuper(...)
                                 type <<- 'sklearn.preprocessing.StandardScaler'
                                 if(is.empty(name)){name <<- 'SKZFS' %>% paste0(sample(10000:99999, 1))}
                               }
                             )
)

CFG.SCIKIT.LR = setRefClass('CFG.SCIKIT.LR', contains = 'MODEL_CONFIG', 
                            methods = list(
                              initialize = function(...){
                                callSuper(...)
                                type <<- 'ellib.Transformations.mlpy.LogisticRegressionTransformer'
                                if(is.empty(name)){name <<- 'SKLR' %>% paste0(sample(10000:99999, 1))}
                              }
                            )
)
CFG.ELLIB.OHE = setRefClass('CFG.ELLIB.OHE', contains = 'MODEL_CONFIG', 
  methods = list(
    initialize = function(...){
      callSuper(...)
      if(is.empty(name)){name <<- 'ELOHE' %>% paste0(sample(10000:99999, 1))}
      type <<- 'ellib.Transformations.local.CategoricalDecomposer'
      
      if(is.null(config$encodings)){
        config$encodings <<- "params['encodings']"
      }
    }, 
    as.el_transformer = function(){
      callSuper() %>% {.[[1]] %<>% list.add(encodings = config$encodings);.}
    }
  )
)


CFG.CATEGORY_ENCODERS.TE = setRefClass('CFG.CATEGORY_ENCODERS.TE', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'category_encoders.TargetEncoder'
    if(is.empty(name)){name <<- 'CETE' %>% paste0(sample(10000:99999, 1))}
  }
))

CFG.ELLIB.ATMP = setRefClass('CFG.ELLIB.ATMP', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'ellib.Transformations.local.AddTrainedModelProbabilities'
    if(is.empty(name)){name <<- 'ELATMP' %>% paste0(sample(10000:99999, 1))}
  }
))

CFG.SCIKIT.PCA = setRefClass('CFG.SCIKIT.PCA', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'sklearn.decomposition.PCA'
    if(is.empty(name)){name <<- 'SKPCA' %>% paste0(sample(10000:99999, 1))}
    parameters$n_components <<- parameters$n_components %>% verify(c('integer', 'numeric'), lengths = 1, domain = c(2,100), default = 5) %>% as.integer
  }
))

CFG.ELLIB.KMEANS = setRefClass('CFG.ELLIB.KMEANS', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'ellib.Transformations.local.KMeansTransformer'
    if(is.empty(name)){name <<- 'ELKM' %>% paste0(sample(10000:99999, 1))}
    parameters$num_clusters <<- parameters$num_clusters %>% verify(c('integer', 'numeric'), lengths = 1, domain = c(2,100), default = 5) %>% as.integer
  }
))

CFG.SCIKIT.OHE = setRefClass('CFG.SCIKIT.OHE', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'sklearn.preprocessing.OneHotEncoder'
    if(is.empty(name)){name <<- 'SKOHE' %>% paste0(sample(10000:99999, 1))}
  }
))

CFG.SCIKIT.KMEANS = setRefClass('CFG.SCIKIT.KMEANS', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'sklearn.cluster.KMeans'
    if(is.empty(name)){name <<- 'SKKM' %>% paste0(sample(10000:99999, 1))}
    parameters$n_clusters <<- parameters$n_clusters %>% verify(c('integer', 'numeric'), lengths = 1, domain = c(2, 25), default = 5) %>% as.integer
  }
))

read_table_pp = function(pp_id, table_name = 'mstr_prd'){
  path_pp %>% paste(pp_id, table_name, sep = '/') %>% parquet2DataFrame
}

pp_config_filename = function(path, config_name){
  if(!file.exists(path)){dir.create(path)}
  path_output = paste(path, config_name, sep = '/')
  if(!file.exists(path_output)){dir.create(path_output)}
  return(path_output %>% paste('config.yml', sep = '/'))
}

# Returns the best num_children (hpo or gss) model configs. 
# These configs can comes under level models in the pp ensembler config:
pp_best_children = function(master_config, agentrun_id, modelrun_id, metrics = 'gini_coefficient', num_children = 1){
  # check if raw_scores exists:
  rsindex = list_bucket(master_config, bucket = 'prediction', id = agent_runid, 
                        folders = "modelrun=%s/raw_scores.csv" %>% sprintf(model_runid), 
                        intern = T) %>% grep(pattern = 'raw_scores.csv')
  rsexists = !rutils::is.empty(rsindex)
  
  if(rsexists){
    rspath = sprintf("%s/agentrun=%s/modelrun=%s/raw_scores.csv", master_config$path_prediction, agent_runid, model_runid)
    if(!file.exists(rspath)){
      copy_prediction_to_local(mc, agentrun_id = agent_runid, modelrun_id = model_runid, files = 'raw_scores.csv')
    }
    rsexists = file.exists(rspath)
  }
  if(rsexists){
    ids = c()
    scores = bigreadr::big_fread2(rspath)
    for(mtrc in metrics){
      ids = c(ids, scores %>% dplyr::distinct(model_id, .keep_all = T) %>% 
                arrange(desc(!!sym(mtrc))) %>% head(num_children) %>% pull(model_id))
    }
    return(ids)
  } else {
    scores = read_prediction_scores(master_config, agentrun_id, modelrun_id, children = T, as_table = T)
    
    mid_best = character()
    for(metric in metrics){
      ind_best = scores[, metric] %>% order(decreasing = T) %>% {.[sequence(num_children)]}
      mid_best %<>% union(rownames(scores)[ind_best]) 
    }
    return(mid_best)
  }
}
  
  
pp_xgb_model_config = function(parameters = list(), features = list()){
  list(classifier = list(type = 'XGBoostClassifier',
                         parameters = parameters), 
       features = features)
}
  


  