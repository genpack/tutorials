#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)
source('R_Pipeline/libraries/ext_rml.R')

################ Inputs: ################
config_filename = 'ss_config_01.yml'
  
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}


################ Read: ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'subset_scorer', config_filename, sep = '/')) -> ss_config

verify(ss_config$horizon, c('numeric', 'integer'), default = 3, lengths = 1) -> ss_config$horizon
verify(ss_config$target, 'character', default = 'ERPS', lengths = 1) -> ss_config$target

ss_path = mc$path_reports %>% paste(id_ml, sep = '/')
if(!file.exists(ss_path)){dir.create(ss_path)}
ss_path %<>% paste('subset_scorer', sep = '/')
if(!file.exists(ss_path)){dir.create(ss_path)}

ss_output <- ss_path %>% paste(ss_config$output, sep = '/')
if(file.exists(ss_output)){
  out = read.csv(ss_output, as.is = T)
} else {
  out = NULL
}

# wt <- WIDETABLE(name = 'wide', path = path.ml)
# wt  %>% saveRDS(sprintf("%s/wide.rds", path.ml))
wt  <- readRDS(sprintf("%s/wide.rds", path_ml))
wt$size_limit = 5e+09

################ Loop: ################
wtcols             = rbig::colnames(wt)
exclude            = c(gss_config$exclude_columns, mc$leakages, 'V1','X', 'caseID', 'eventTime')
features           = wtcols %-% charFilter(wtcols, exclude, and = F)

ylabels   = get_labels(wt, mc, target = ss_config$target, horizon = ss_config$horizon)

for(test_date in ss_config$dates){
  train_date = test_date %>% add_month(- ss_config$horizon)
  
  if(is.null(ss_config$training_months)){
    ind_train  = which(wt[['eventTime']] <= train_date)
  } else {
    ind_train %<>% intersect(which(wt[['eventTime']] >  add_month(date_train, - ss_config$training_months)))
  }
  
  ind_test   = which(wt[['eventTime']] == test_date)

  y_train  = ylabels[ind_train]
  y_test   = ylabels[ind_test]
  
  for(j in sequence(ss_config$num_experiments)){
    features %>% sample(size = ss_config$subset_size %>% min(length(features))) -> fset
    
    X_train  = wt[ind_train, fset]
    X_test   = wt[ind_test, fset]
    
    ################ Build Model ################
    ss_config$model %>% build_model_from_config(mc) -> model
    model_make_unique_transformer_names(model)
    
    model$objects[['horizon']] <- ss_config$horizon
    model$objects[['target']]  <- ss_config$target
    model$objects[['start']]   <- min(wt[['eventTime']][ind_train])
    model$objects[['end']]     <- max(wt[['eventTime']][ind_train])
    
    model$config[['pp.remove_invariant_features']] = F
    model$config$features.include = fset

    res = try(model$fit(X_train, y_train), silent = T)
    yp  = try(model$predict(X_test)[,1], silent = T)
    if(inherits(res, 'try-error')){
      cat('\n', res)
    } else {
      
      sprintf("Experiment %s: model= %s, Test Date= %s", j, model$name, test_date) %>% cat('\n')
      pf   = get_performance_metrics(model = model, X = X_test, y = y_test, metrics = ss_config$metrics, quantiles = ss_config$quantiles, do_print = T)
      ptab = model$objects$features %>% mutate(train_date = train_date, test_date = test_date, model = model$name)
      ptab$fitting_time <- model$objects$fitting_time
      
      for(mn in names(pf)) {ptab[, mn] <- pf[mn]}

      out %<>% rbind(ptab)
    }
  
    dd = j %% as.integer(verify(ss_config$saving_period, c('numeric', 'integer'), lengths = 1, domain = c(1, Inf), null_allowed = T))
    if(!is.empty(dd)){
      if(dd == 0){
        out %>% write.csv(sprintf("%s/%s.csv", ss_path, ss_config$output), row.names = F)
      }
    }
    
  }  
}
  
out %>% write.csv(sprintf("%s/%s.csv", ss_path, ss_config$output), row.names = F)
