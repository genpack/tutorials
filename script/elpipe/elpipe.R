el_model_types = c('ClassificationModels.local.WrapperXGBoost', 'ClassificationModels.local.WrapperLightGBM', 'ClassificationModels.local.WrapperLogisticRegression', 'ClassificationModels.local.WrapperCatBoost')

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
    
    get.elpipe_config = function(){
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
    
    write.elpipe_config = function(filename = 'config.yml', path = getwd()){
      hnd = list(
        logical = function(x) {
          result <- ifelse(x, "True", "False")
          class(result) <- "verbatim"
          return(result)
        }
      )
      get.elpipe_config() %>% yaml::write_yaml(path %>% paste(filename, sep = '/'), handlers = hnd)
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
CFG.SKLEARN.MMS = setRefClass('CFG.SKLEARN.MMS', contains = 'MODEL_CONFIG', 
   methods = list(
     initialize = function(...){
       callSuper(...)
       type <<- 'sklearn.preprocessing.MinMaxScaler'
       if(is.empty(name)){name <<- 'SKMMS' %>% paste0(sample(10000:99999, 1))}
     }
   )
)
CFG.SKLEARN.MAS = setRefClass('CFG.SKLEARN.MAS', contains = 'MODEL_CONFIG', 
                             methods = list(
                               initialize = function(...){
                                 callSuper(...)
                                 type <<- 'sklearn.preprocessing.MaxAbsScaler'
                                 if(is.empty(name)){name <<- 'SKMAS' %>% paste0(sample(10000:99999, 1))}
                               }
                             )
)
CFG.SKLEARN.RS = setRefClass('CFG.SKLEARN.RS', contains = 'MODEL_CONFIG', 
                             methods = list(
                               initialize = function(...){
                                 callSuper(...)
                                 type <<- 'sklearn.preprocessing.RobustScaler'
                                 if(is.empty(name)){name <<- 'SKRS' %>% paste0(sample(10000:99999, 1))}
                               }
                             )
)
CFG.SKLEARN.ZFS = setRefClass('CFG.SKLEARN.ZFS', contains = 'MODEL_CONFIG', 
                             methods = list(
                               initialize = function(...){
                                 callSuper(...)
                                 type <<- 'sklearn.preprocessing.StandardScaler'
                                 if(is.empty(name)){name <<- 'SKZFS' %>% paste0(sample(10000:99999, 1))}
                               }
                             )
)

CFG.SKLEARN.LR = setRefClass('CFG.SKLEARN.LR', contains = 'MODEL_CONFIG', 
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

CFG.SKLEARN.PCA = setRefClass('CFG.SKLEARN.PCA', contains = 'MODEL_CONFIG', methods = list(
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

CFG.SKLEARN.OHE = setRefClass('CFG.SKLEARN.OHE', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'sklearn.preprocessing.OneHotEncoder'
    if(is.empty(name)){name <<- 'SKOHE' %>% paste0(sample(10000:99999, 1))}
  }
))

CFG.SKLEARN.KMEANS = setRefClass('CFG.SKLEARN.KMEANS', contains = 'MODEL_CONFIG', methods = list(
  initialize = function(...){
    callSuper(...)
    type <<- 'sklearn.cluster.KMeans'
    if(is.empty(name)){name <<- 'SKKM' %>% paste0(sample(10000:99999, 1))}
    parameters$n_clusters <<- parameters$n_clusters %>% verify(c('integer', 'numeric'), lengths = 1, domain = c(2, 25), default = 5) %>% as.integer
  }
))


