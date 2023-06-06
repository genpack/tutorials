copy_mlmapper_to_local = function(master_config){
  bucket_ml   = 's3://mlmapper.prod.st.%s.elservices.com' %>% sprintf(master_config$client)
  shellscr    = paste0('aws s3 cp ', bucket_ml, '/run=', 
                       master_config$mlmapper_id, ' ', master_config$path_mlmapper,
                       '/', substr(master_config$mlmapper_id, 1, 8), '/', ' --recursive', ' --profile ', 
                       master_config$aws_profile)
  shell(shellscr)
}

list_bucket = function(master_config, bucket = NULL, id = NULL, folders = NULL, intern = F){
  if(is.null(bucket)){
    scr = sprintf("aws s3 ls --profile %s", master_config$aws_profile)
  } else {
    if(is.null(id)){
      scr = "aws s3 ls s3://%s.prod.st.%s.elservices.com --profile %s" %>% 
        sprintf(bucket, master_config$client, master_config$aws_profile)
    } else {
      runstr = rutils::chif(bucket == 'prediction', 'agentrun', 'run')
      if(is.null(folders)){
        scr = "aws s3 ls s3://%s.prod.st.%s.elservices.com/%s=%s/ --profile %s" %>% 
          sprintf(bucket, master_config$client, runstr , id, master_config$aws_profile)
      } else {
        foldstr = ""
        for(fn in folders){foldstr %<>% paste(fn, sep = "/")}
        scr = "aws s3 ls s3://%s.prod.st.%s.elservices.com/%s=%s%s --profile %s" %>% 
          sprintf(bucket, master_config$client, runstr, id, foldstr, master_config$aws_profile)
      }
    }
  }
 shell(scr, intern = intern)
}

copy_mlsampler_to_local = function(master_config, mlsampler_id){
  
  bucket_mls  = 's3://mlsampler.prod.st.%s.elservices.com' %>% sprintf(master_config$client)
  shellscr    = paste0('aws s3 cp ', bucket_mls, '/run=', 
                       mlsampler_id, ' ', master_config$path_mlsampler,
                       '/', substr(mlsampler_id, 1, 8), '/', ' --recursive', ' --profile ', 
                       master_config$aws_profile)
  shell(shellscr)
}

copy_orchestration_to_local = function(master_config, orchestration_id){
  
  bucket_mls  = 's3://orchestration.prod.st.%s.elservices.com' %>% sprintf(master_config$client)
  shellscr    = paste0('aws s3 cp ', bucket_mls, '/run=', 
                       orchestration_id, ' ', master_config$path_orchestration,
                       '/', substr(orchestration_id, 1, 8), '/', ' --recursive', ' --profile ', 
                       master_config$aws_profile)
  shell(shellscr)
}

sync_exchange = function(master_config, filename, path = '.', is_folder = F){
  shellscr  = "aws s3 cp %s/%s/%s s3://exchange.prod.st.%s.elservices.com/%s/%s --profile %s" %>% 
    sprintf(master_config$path_exchange, path, filename, master_config$client, path, chif(is_folder, ' --recursive', ''), master_config$aws_profile)
  
  shell(shellscr)
}

copy_to_exchange = function(master_config, source, destination){
  shellscr = sprintf("aws s3 cp %s s3://exchange.prod.st.%s.elservices.com/%s --profile %s", 
                   source, master_config$client, destination, master_config$aws_profile)
  shell(shellscr)
}

copy_to_local = function(master_config, bucket, id, files = NULL, folders = NULL){
  bucket_mls  = 's3://%s.prod.st.%s.elservices.com' %>% sprintf(bucket, master_config$client)
  if(bucket == 'prediction'){runstr = '/agentrun='} else {runstr = '/run='}
  shellscr    = paste0('aws s3 cp ', bucket_mls, runstr, id, 
                       chif(is.null(folders), '', '/'), folders, 
                       chif(is.null(files),'', '/'), files,
                       ' ', master_config[['path' %>% paste(bucket, sep = '_')]],
                       '/', substr(id, 1, 8), '/', folders, 
                       chif(is.null(folders),'', '/'), files, 
                       chif(is.null(files), ' --recursive', ''), ' --profile ', 
                       master_config$aws_profile)
  shell(shellscr)
}

copy_prediction_to_local = function(master_config, agentrun_id, modelrun_id = NULL, folders = NULL, files = NULL){
  bucket_pr   = 's3://prediction.prod.st.%s.elservices.com' %>% sprintf(master_config$client)
  if(is.null(modelrun_id)){
    shellscr    = paste0('aws s3 cp ', bucket_pr, 
                         '/agentrun=', agentrun_id, 
                         chif(is.null(folders), '', '/' %++% folders),
                         chif(is.null(files), ''  , '/' %++% files),
                         ' ', 
                         master_config$path_prediction,
                         '/agentrun=', agentrun_id, '/',
                         chif(is.null(folders), '', folders %++% '/'),
                         chif(is.null(files), '', files),
                         chif(is.null(files), ' --recursive', ''), 
                         ' --profile ', master_config$aws_profile)
  } else {
    shellscr    = paste0('aws s3 cp ', bucket_pr, 
                         '/agentrun=', agentrun_id, 
                         '/modelrun=', modelrun_id, 
                         chif(is.null(folders), '', '/' %++% folders),
                         chif(is.null(files), ''  , '/' %++% files),
                         ' ', 
                         master_config$path_prediction,
                         '/agentrun=', agentrun_id, '/modelrun=', modelrun_id, '/', files,
                         chif(is.null(folders), '', folders %++% '/'),
                         chif(is.null(files), ' --recursive', ''), 
                         ' --profile ', master_config$aws_profile)
  }
  
  for(sc in shellscr){shell(sc)}  
}

read_table_epp = function(master_config, table_name, bucket = c('preprocessing', 'obsmapper', 'eventmapper'), format = c('parquet', 'rds')){
  bucket = match.arg(bucket)
  format = match.arg(format)
  path = master_config[[paste('path', bucket, sep = '_')]] %>% 
    paste(master_config[[paste(bucket, 'id', sep = '_')]] %>% substr(1,8), table_name, sep = '/')
  if(format == 'parquet'){
    return(path %>% rbig::parquet2DataFrame())
  } else {
    return(readRDS(path %>% paste('rds', sep = '.')))
  }
}

read_prediction_scores = function(master_config, agentrun_id, modelrun_id, metrics = NULL, children = F, as_table = F){
  if(as_table){
    scs <- read_prediction_scores(master_config = master_config, agentrun_id = agentrun_id, modelrun_id = modelrun_id, metrics = metrics, children = children, as_table = F) %>% rutils::list.clean()
    if(!children){scs = list(scs)}
    scs %>% purrr::map(as.data.frame) -> tables
    common_columns = tables %>% purrr::map(colnames) %>% purrr::reduce(intersect)
    tables %>% purrr::map(function(u) u[common_columns]) %>% purrr::reduce(rbind) -> out
    rownames(out) <- names(tables)
    return(out)
  } else {
    if(children){
      'aws s3 sync s3://prediction.prod.st.%s.elservices.com/agentrun=%s/ %s/agentrun=%s/ --exclude="*" --include="*/scores.json" --profile %s' %>% 
        sprintf(master_config$client, agentrun_id, master_config$path_prediction, agentrun_id, master_config$aws_profile) %>% 
        shell
      folders = list_bucket(master_config, bucket = 'prediction', id = agentrun_id, intern = T)
      mdlruns = folders[folders %>% grep(pattern = 'modelrun') %-% grep(folders, pattern = modelrun_id)] %>% 
        gsub(pattern = '\\s', replacement = '') %>% 
        gsub(pattern = 'PREmodelrun=', replacement = '') %>% 
        gsub(pattern = '/', replacement = '')
      
      names(mdlruns) <- mdlruns
      purrr::map(mdlruns, read_prediction_scores, master_config = master_config, agentrun_id = agentrun_id, children = F, as_table = F) 
    } else {
      scores_filename = sprintf("%s/agentrun=%s/modelrun=%s/scores.json", 
                                master_config$path_prediction, agentrun_id, modelrun_id)
      if(!file.exists(scores_filename)){
        copy_prediction_to_local(master_config, agentrun_id = agentrun_id, modelrun_id = modelrun_id, files = 'scores.json')
      }
      if(file.exists(scores_filename)){
        out = try(jsonlite::read_json(scores_filename), silent = T)
        if(!inherits(out, 'list')){
          try(readLines(scores_filename) %>% 
                gsub(lines, pattern = 'NaN', replacement = 0) %>% 
                jsonlite::fromJSON(), silent = T) -> out
        }  
        if(inherits(out, 'list')){
          if(!is.null(metrics)){
            out %<>% list.extract(metrics)
          }
          return(out)
        } else {
          cat('\n', sprintf('Warning: reading file %s failed: ', scores_filename), '\n', as.character(out))
        }
      }
    }
  }
}

read_prediction_features = function(master_config, agentrun_id, modelrun_id, children = F, as_table = F, feature_importances = F){
  if(as_table){
    fets = read_prediction_features(master_config = master_config, agentrun_id = agentrun_id, modelrun_id = modelrun_id, children = children, as_table = F, feature_importances = feature_importances)
    if(feature_importances){
      allf = fets %>% purrr::map(names) %>% purrr::reduce(union)
      defv = NA
    } else {
      allf = fets %>% purrr::reduce(union)
      defv = 0
    }
    out  = matrix(defv, nrow = length(fets), ncol = length(allf), dimnames = list(names(fets), allf)) %>% as.data.frame
    for(id in names(fets)){
      if(feature_importances){
        out[id, names(fets[[id]])] <- fets[[id]] 
      } else{
        out[id, fets[[id]]] <- 1
      }
    }
    return(out)
  } else {
    cfgs = read_prediction_configs(master_config = master_config, agentrun_id = agentrun_id, modelrun_id = modelrun_id, children = children)
    if(!children){cfgs = list(cfgs); names(cfgs) <- modelrun_id}
    out = cfgs %>% purrr::map(function(v) v[['model']][['features']] %>% unlist)
    if(feature_importances){
      for(id in names(out)){
        nms = out[[id]] %>% as.character
        out[[id]] = rep(-1, length(nms))
        names(out[[id]]) <- nms
        fipath = sprintf("%s/agentrun=%s/modelrun=%s/feature_importance.json", master_config$path_prediction, agentrun_id, id)
        if(!file.exists(fipath)){
          copy_prediction_to_local(master_config = master_config, 
                                   agentrun_id = agentrun_id, 
                                   modelrun_id = id, files = 'feature_importance.json')
        }
        if(file.exists(fipath)){
          fimp = jsonlite::read_json(fipath) %>% unlist
          if(!inherits(fimp, 'numeric')){
            nmsfimp = names(fimp)
            fimp    = as.numeric(fimp)
            names(fimp) <- nmsfimp
          }
        } else {
          fimp = c()
        }
        nmsint = intersect(nms, names(fimp))
        out[[id]][nmsint] = fimp[nmsint]
      }  
    }
    return(out)
  }
}

read_orchestration_features = function(master_config, orchestration_id, children = F, feature_importances = F){
  read_job = function(job){
    read_prediction_features(master_config = master_config, agentrun_id = job['runid'], modelrun_id = job['model_runid'], children = children, as_table = T, feature_importances = feature_importances) %>% 
      rownames2Column('model_runid') %>% 
      mutate(id = job['id'], agent_runid = job['runid'])
  }
  
  read_orchestration_jobs(master_config, orchestration_id) %>% 
    dplyr::filter(component == 'prediction', state == 'SUCCEEDED') %>% 
    apply(1, read_job) %>% purrr::reduce(dplyr::bind_rows) %>% 
    select(id, agent_runid, model_runid, colnames(.)) 
}

read_prediction_configs = function(master_config, agentrun_id, modelrun_id, children = F){
  if(children){
    'aws s3 sync s3://prediction.prod.st.%s.elservices.com/agentrun=%s/ %s/agentrun=%s/ --exclude="*" --include="*/config.json" --profile %s' %>% 
      sprintf(master_config$client, agentrun_id, master_config$path_prediction, agentrun_id, master_config$aws_profile) %>% 
      shell
    
    folders = list_bucket(master_config, bucket = 'prediction', id = agentrun_id, intern = T)
    mdlruns = folders[folders %>% grep(pattern = 'modelrun') %-% grep(folders, pattern = modelrun_id)] %>% 
      gsub(pattern = '\\s', replacement = '') %>% 
      gsub(pattern = 'PREmodelrun=', replacement = '') %>% 
      gsub(pattern = '/', replacement = '')
    
    names(mdlruns) <- mdlruns
    purrr::map(mdlruns, read_prediction_configs, master_config = master_config, agentrun_id = agentrun_id, children = F) 
  } else {
    config_filename = sprintf("%s/agentrun=%s/modelrun=%s/config.json", 
                              master_config$path_prediction, agentrun_id, modelrun_id)
    if(!file.exists(config_filename)){
      copy_prediction_to_local(master_config, agentrun_id = agentrun_id, modelrun_id = modelrun_id, files = 'config.json')
    }
    jsonlite::read_json(config_filename)
  }
}

read_config = function(master_config, bucket = 'mlsampler', id){
  config_filename = sprintf("%s/%s/config.json", 
                            master_config[[paste('path', bucket, sep = '_')]], 
                            id %>% substr(1, 8))
  if(!file.exists(config_filename)){
    copy_to_local(master_config, bucket = bucket, id = id, files = 'config.json')
  }
  jsonlite::read_json(config_filename)
}

read_prediction_hyperparameters = function(...){
  pcs <- read_prediction_configs(...)
  
  pcs %>% purrr::map(function(v) v[['model']][['parameters']] %>% as.data.frame) -> tables
  common_columns = tables %>% purrr::map(colnames) %>% purrr::reduce(intersect)
  tables %>% purrr::map(function(u) u[common_columns]) %>% purrr::reduce(rbind) -> out
  rownames(out) <- names(pcs)
  return(out)
}

read_orchestration_jobs  = function(master_config, orchestration_id){
  jobs_filename = "%s/%s/jobs.json" %>% sprintf(mc$path_orchestration, substr(orchestration_id, 1, 8))
  if(!file.exists(jobs_filename)){
    copy_orchestration_to_local(master_config = master_config, orchestration_id = orchestration_id)
  }
  jsonlite::read_json(jobs_filename) %>% lapply(as.data.frame) %>% 
    purrr::reduce(rbind)
}

## Get a list of child models from an orchestration run:
read_orchestration_scores = function(master_config, orchestration_id, metrics = c('gini_coefficient', 'lift_2', 'precision_2')){
  read_job = function(job){
    job %>% t %>% as.data.frame %>% cbind(
      read_prediction_scores(master_config = master_config, agentrun_id = job['runid'], modelrun_id = job['model_runid'], metrics = metrics, children = F, as_table = F)) %>% 
      as.data.frame
  }
  
  read_orchestration_jobs(master_config, orchestration_id) %>% 
    dplyr::filter(component == 'predictions', state == 'SUCCEEDED') %>% 
    apply(1, read_job) %>% purrr::reduce(rbind) %>% select(-component, -critical, -state)
}

# TODO: add children_subset to other read_prediction_xxx functions
read_prediction_probs = function(master_config, agentrun_id, modelrun_id, children = F, children_subset = NULL, as_table = F){
  if(as_table){
    probs = read_prediction_probs(
      master_config = master_config, 
      agentrun_id = agentrun_id, 
      modelrun_id = modelrun_id, children = children, children_subset = children_subset, as_table = F) %>% list.clean
    probs_df = NULL
    for(model_id in names(probs)){
      probs_model = probs[[model_id]] %>% select(caseID, eventTime, label, probability)
      names(probs_model)[4] <- model_id
      if(is.null(probs_df)){probs_df = probs_model} else {
        probs_df %<>% left_join(probs_model, by = c('caseID', 'eventTime', 'label'))
      }
    }
    return(probs_df)
  }
  if(children){
    'aws s3 sync s3://prediction.prod.st.%s.elservices.com/agentrun=%s/ %s/agentrun=%s/ --exclude="*" --include="*/predictions/predictions.parquet" --profile %s' %>% 
      sprintf(master_config$client, agentrun_id, master_config$path_prediction, agentrun_id, master_config$aws_profile)
    
    folders = list_bucket(master_config, bucket = 'prediction', id = agentrun_id, intern = T)
    mdlruns = folders[folders %>% grep(pattern = 'modelrun') %-% grep(folders, pattern = modelrun_id)] %>% 
      gsub(pattern = '\\s', replacement = '') %>% 
      gsub(pattern = 'PREmodelrun=', replacement = '') %>% 
      gsub(pattern = '/', replacement = '')
    
    if(!is.null(children_subset)){mdlruns %<>% intersect(children_subset)}
    
    names(mdlruns) <- mdlruns
    purrr::map(mdlruns, read_prediction_probs, master_config = master_config, 
               agentrun_id = agentrun_id, children = F)
  } else {
    probs_filename = sprintf("%s/agentrun=%s/modelrun=%s/predictions/predictions.parquet", 
                             master_config$path_prediction, agentrun_id, modelrun_id)
    if(!file.exists(probs_filename)){
      copy_prediction_to_local(master_config = master_config, agentrun_id = agentrun_id, modelrun_id = modelrun_id,
                               files = "predictions/predictions.parquet")
    }
    out = try(arrow::read_parquet(probs_filename), silent = T)
    if(inherits(out, 'data.frame')){
      return(out)
    }
  }
}

read_orchestration_probs = function(master_config, orchestration_id, children = F){
  read_job = function(job, children = F){
    pp = read_prediction_probs(master_config = master_config, agentrun_id = job['runid'], modelrun_id = job['model_runid'], children = children)
      # {colnames(.)[3] <- paste(job['runid'] %>% substr(1,8), job['model_runid'] %>% substr(1,8), sep = '_');.}
      # {colnames(.)[3] <- job['id'];.}
    if(children){
      out = NULL
      for(mid in names(pp)){
        pp[[mid]]$model_runid = mid
        out = rbind(out, pp[[mid]])
      }
      return(out)
    } else {return(pp)}
  }
  
  read_orchestration_jobs(master_config, orchestration_id) %>% 
    dplyr::filter(component == 'prediction', state == 'SUCCEEDED') -> jobs
  out = jobs %>% apply(1, read_job, children = children)
  names(out) <- jobs$id
  return(out)
}


read_mlsampler_configs = function(master_config, mlsampler_id){
  if(length(mlsampler_id) > 1){
    return(mlsampler_id %>% sapply(read_sampler_config, master_config = master_config))
  } else {
    config_path = sprintf("%s/%s/config.json", master_config$path_mlsampler, mlsampler_id %>% substr(1,8))
    if(!file.exists(config_path)){
      copy_to_local(master_config, bucket = 'mlsampler', id = mlsampler_id, files = 'config.json')
    }
    return(jsonlite::read_json(config_path))
  }
}


read_mlsampler_folder_info = function(mlsampler_config, folder_name = 'train'){
  folders = mlsampler_config$outputs %>% purrr::map(names) %>% unlist
  ds_info = list(dns_rate = 1.0)
  ind     = which(folders == folder_name)
  fn      = folders[[ind]]
  if(length(fn) == 1){
    for(i in sequence(length(mlsampler_config$outputs[[ind]][[fn]]))){
      if(!is.null(mlsampler_config$outputs[[ind]][[fn]][[i]][['splitter']])){
        if(mlsampler_config$outputs[[ind]][[fn]][[i]][['splitter']] == 'timeseries_split_by_day'){
          if(mlsampler_config$outputs[[ind]][[fn]][[i]][['split']] == 1){
            ds_info[['from']] = mlsampler_config$outputs[[ind]][[fn]][[i]][['end_time']]
          } else if(mlsampler_config$outputs[[ind]][[fn]][[i]][['split']] == 0){
            ds_info[['to']] = mlsampler_config$outputs[[ind]][[fn]][[i]][['end_time']] %>% rutils::add_month(-1)
          }
        }
      }
      
      if(!is.null(mlsampler_config$outputs[[ind]][[fn]][[i]][['sampler']])){
        if((mlsampler_config$outputs[[ind]][[fn]][[i]][['sampler']] == 'stratified_sampling') & (mlsampler_config$outputs[[ind]][[fn]][[i]][['filter_col']] == 'label'))
          ds_info[['dns_rate']] <- mlsampler_config$outputs[[ind]][[fn]][[i]][['fraction']][['0']]/mlsampler_config$outputs[[ind]][[fn]][[i]][['fraction']][['1']]
      }
    }
  }
  return(ds_info)
}
  
# todo: add argument children
read_prediction_dataset_info = function(master_config, agentrun_id, modelrun_id){
  pc = read_prediction_configs(master_config, agentrun_id, modelrun_id)
  read_mlsampler_configs(master_config, pc$dataset) -> samc
  if(is.null(pc$test)){pc$test = 'test'}
  if(is.null(pc$train)){pc$train = 'train'}
  test_info  = read_mlsampler_folder_info(samc, pc$test)
  train_info = read_mlsampler_folder_info(samc, pc$train)
  names(test_info)  <- paste('test', names(test_info), sep = '_')
  names(train_info) <- paste('train', names(train_info), sep = '_')
  train_info$mlmapper_id = samc$dataset
  return(test_info %<==>% train_info)
}

# if filename is specified, the result is synced with the given filename.
read_prediction_comprehensive = function(master_config, from_time = NULL, to_time = Sys.time(), filename = NULL){
  
  lambda = function(job){
    read_prediction_scores(mc, agentrun_id = job['agentrun'], modelrun_id = job['modelrun'], as_table = T)
  }
  
  beta = function(job){
    cfg = read_prediction_configs(mc, agentrun_id = job['agentrun'], modelrun_id = job['modelrun'])
    cfg$model$num_features <- length(cfg$model$features)
    cfg$model$features     <- NULL
    unlist(cfg) %>% as.matrix %>% t %>% as.data.frame
  }
  
  gamma = function(job){
    read_prediction_features(mc, agentrun_id = job['agentrun'], modelrun_id = job['modelrun'], feature_importances = T, as_table = T)
  }
  
  eta = function(job){
    read_prediction_dataset_info(mc, agentrun_id = job['agentrun'], modelrun_id = job['modelrun']) %>% 
      unlist %>% as.matrix %>% t %>% as.data.frame
  }
  
  columns = c('is_parent', 'agentrun', 'modelrun', 'start_time', 'end_time')
  
  reticulate::import('st_api_client') -> sapic
  client = sapic$StAPIClient(mc$client)

  cat('Extracting 100 jobs from ', to_time, '... ')
  query = "SELECT %s FROM agent_to_model WHERE state = 'SUCCEEDED' AND end_time < '%s' ORDER BY end_time DESC" %>% 
    sprintf(paste(columns, collapse = ','), to_time)
  client$job_keeper$query(query) -> runs
  cat('Done! ', '\n')
  
  if(!is.null(from_time)){
    from_time = as.POSIXct(from_time)
    rutils::assert(!rutils::is.empty(from_time))
    while(min(runs$end_time) > from_time){
      cat('Extracting 100 jobs from ', min(runs$end_time), '... ')
      "SELECT %s FROM agent_to_model WHERE state = 'SUCCEEDED' AND end_time < '%s' ORDER BY end_time DESC" %>% 
        sprintf(paste(columns, collapse = ','), min(runs$end_time)) %>% 
        client$job_keeper$query() %>% 
        rbind(runs) -> runs
      cat('Done! ', '\n')
    }
  }
  
  runs %<>% dplyr::filter(!is_parent, end_time > from_time) %>% select(-is_parent) %>% 
    mutate(agentmodel_id = paste0("A", substr(agentrun, 1, 8), "M", substr(modelrun, 1, 8)))
  
  runs_0 <- NULL
  if(!is.null(filename)){
    if(file.exists(filename)){
      bigreadr::fread2(filename) -> runs_0
      runs %<>% dplyr::filter(!agentmodel_id %in% runs_0$agentmodel_id)
    }
  }

  if(nrow(runs) > 0){
    cat('Extracting dataset info ... ')
    runs %>% 
      as.matrix %>% apply(1, eta) %>% 
      purrr::reduce(dplyr::bind_rows) %>% 
      dplyr::mutate(test_dns_rate = as.numeric(test_dns_rate), train_dns_rate = as.numeric(train_dns_rate)) -> dsinfo
    cat('Done! ', '\n')
    ind    = which(dsinfo$mlmapper_id == mc$mlmapper_id)
    runs   = runs[ind, ]
    dsinfo = dsinfo[ind, ]

    
    if(nrow(runs) > 0){
      
      assert(nrow(dsinfo) == nrow(runs), 'Something is wrong!')
      dsinfo$agentmodel_id = runs$agentmodel_id

      cat('Extracting scores ... ')
      runs %>% 
        as.matrix %>% apply(1, lambda) %>% 
        purrr::reduce(rbind) -> scores
      
      assert(nrow(scores) == nrow(runs), 'Something is wrong!')
      scores$agentmodel_id = runs$agentmodel_id
      cat('Done! ', '\n')
      
      cat('Extracting configs ... ')
      runs %>% 
        as.matrix %>% apply(1, beta) %>% 
        purrr::reduce(dplyr::bind_rows) -> configs

      assert(nrow(configs) == nrow(runs), 'Something is wrong!')
      configs$agentmodel_id = runs$agentmodel_id
      cat('Done! ', '\n')
      
      cat('Extracting feature importances ... ')
      runs %>% as.matrix %>% apply(1, gamma) -> ff
      
      assert(length(ff) == nrow(runs), 'Something is wrong!')
      names(ff) <- runs$agentmodel_id
      
      features <- NULL; i <- 0
      for(i in sequence(as.integer(length(ff)/100))){
        model_subset = names(ff)[100*(i-1) + sequence(100)]
        ff %>% list.extract(model_subset) %>% 
          purrr::reduce(dplyr::bind_rows) %>% 
          dplyr::mutate(agentmodel_id = model_subset) %>% 
          dplyr::bind_rows(features) -> features
      }
      if(is.null(i)){i = 0}
      
      model_subset = names(ff)[100*i + sequence(length(ff) - 100*i)]
      ff %>% list.extract(model_subset) %>% 
        purrr::reduce(dplyr::bind_rows) %>% 
        dplyr::mutate(agentmodel_id = model_subset) %>% 
        dplyr::bind_rows(features) -> features
      
      cat('Done! ', '\n')
      
      runs %<>% 
        dplyr::left_join(scores, by = 'agentmodel_id') %>% 
        dplyr::left_join(dsinfo, by = 'agentmodel_id') %>% 
        dplyr::left_join(configs, by = 'agentmodel_id') %>% 
        dplyr::left_join(features, by = 'agentmodel_id')
    }
  }

  if(!is.null(runs_0)){runs <- runs %>% dplyr::bind_rows(runs_0 %>% match_column_classes(runs))}
  if(!is.null(filename) & !(runs$agentmodel_id %==% runs_0$agentmodel_id)){runs %>% bigreadr::fwrite2(filename)}
  if(!is.null(from_time)){runs = runs[runs$end_time > from_time,]}
  runs = runs[runs$mlmapper_id == mc$mlmapper_id,]
  
  return(runs)
}  


match_column_classes = function(df1, df2){
  cols = colnames(df1) %^% colnames(df2)
  for(cn in colnames(df1) %^% colnames(df2)){
    if(class(df1[[cn]])[1] != class(df2[[cn]])[1]){
      df1[[cn]] <- rutils::coerce(df1[[cn]], class(df2[[cn]])[1])
    }
  }
  return(df1)
} 

list.replace = function(input, pattern, replacement){
  if(inherits(input, 'character')){
    return(input %>% stringr::str_replace(pattern = pattern, replacement = replacement))
  } else if (inherits(input, 'list')){
    for(i in sequence(length(input))){
      input[[i]] = list.replace(input[[i]], pattern = pattern, replacement = replacement)
    }
  }
  return(input)
}

  