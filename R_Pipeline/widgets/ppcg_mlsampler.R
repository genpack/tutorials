# Create sampler configs for months:
##### SETUP: ####
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/io_tools.R')
source('R_Pipeline/libraries/pp_tools.R')

################ Inputs ################
config_filename = 'ppcg_mlsampler.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Some Functions ################
get_train_config = function(name = 'train', start_date, test_date, stratified_sampling = NULL, training_gap = 3){
  out = list()
  out[[name]] <- list(
    list(
      splitter = 'timeseries_split_by_day',
      end_time = start_date %>% add_month(1), split = 1L),
    list(
      splitter = 'timeseries_split_by_day',
      end_time = test_date %>% add_month(1-training_gap), split = 0L)
  )
  if(!is.null(stratified_sampling)){
    cnt = 0
    for(ss in stratified_sampling){
      cnt = cnt + 1
      list(
        sampler = 'stratified_sampling',
        filter_col = ss$column,
        fraction   = ss$ratios %>% as.list %>% {names(.)<-ss$values;.}) -> out[[name]][[2 + cnt]]
    }
  }
  return(out)
}

get_test_config = function(name = 'test', test_date){
  out = list()
  out[[name]] <- list(
    list(
      splitter = 'timeseries_split_by_day',
      end_time = test_date, split = 1L),
    list(
      splitter = 'timeseries_split_by_day',
      end_time = test_date %>% add_month(1), split = 0L)
  )
  return(out)
}

get_start_date = function(master_config, scg_config, test_date){
  if(scg_config$window_type == 'growing'){
    if(!is.null(scg_config$start_date)){
      start_date =  scg_config$start_date
    } else if(!is.null(master_config$mlmapper_start_date)){
      start_date =  master_config$mlmapper_start_date
    } else {stop('Fixed start date must be specified in growing window.')}
  } else if (scg_config$window_type == 'sliding'){
    scg_config$num_months <- verify(scg_config$num_months, c('numeric', 'integer'), domain = c(1, Inf), default = 12) %>% as.integer
    start_date = test_date %>% add_month(-scg_config$num_months-scg_config$training_gap)
  } else {stop('Invalid parameter window_type!')}
  return(start_date)
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> scg_config
scg_config$all_in_one     = verify(scg_config$all_in_one, 'logical', default = T)
scg_config$num_months     = verify(scg_config$num_months, c('numeric','integer'), default = 12) %>% as.integer
scg_config$add_optimise   = verify(scg_config$add_optimise, 'logical', default = F)
scg_config$num_partitions = verify(scg_config$num_partitions, c('numeric','integer'), default = 200) %>% as.integer
scg_config$downsampling_rate = verify(scg_config$downsampling_rate, 'numeric', domain = c(0,1), null_allowed = T)
scg_config$training_gap = verify(scg_config$training_gap, c('numeric', 'integer'), domain = c(0,Inf), default = 3) %>% as.integer

if(!is.null(scg_config$downsampling_rate)){
  if(is.null(scg_config$stratified_sampling)){scg_config$stratified_sampling = list()}
  scg_config$stratified_sampling[[1 + length(scg_config$stratified_sampling)]] <- list(column = 'label', values = c(0,1), ratios = c(scg_config$downsampling_rate, 1.0))
}
##### RUN: ####
assert(file.exists(scg_config$path_output), paste('Given path', scg_config$path_output ,'does not exist!'))
if(is.null(scg_config$window_type)){
  scg_config$window_type <- 'sliding' 
}
if(scg_config$all_in_one){
  cfg = list(dataset = mc$mlmapper_id, 
             num_partitions = scg_config$num_partitions, 
             outputs = list()
  )
  path_config = paste0(scg_config$path_output, '/', mc$mlmapper_id %>% substr(1,8), '_', paste(range(scg_config$dates), collapse = '-'))
  if(scg_config$num_months != 12){
    path_config %<>% paste0('_m', scg_config$num_months)
  }
  if(!file.exists(path_config)){dir.create(path_config)}
  path_config = paste(path_config, 'config.yml', sep = '/')
  for(test_date in scg_config$dates){
    start_date = get_start_date(master_config = mc, scg_config = scg_config, test_date = test_date)
    
    cfg$outputs %<>% list.add(get_train_config(name = paste('train', test_date, sep = '_'), start_date, test_date, stratified_sampling = scg_config$stratified_sampling, training_gap = scg_config$training_gap))
    cfg$outputs %<>% list.add(get_test_config(name  = paste('test' , test_date, sep = '_'), test_date))
    if(scg_config$add_optimise){
      cfg$outputs %<>% list.add(get_test_config(name  = paste('optimise' , test_date, sep = '_'), test_date))
    }
  }
  
  cfg %>% yaml::write_yaml(path_config)  
} else {
  for(test_date in scg_config$dates){
    path_config = paste0(scg_config$path_output, '/', mc$mlmapper_id %>% substr(1,8), '_', test_date)
    if(scg_config$num_months != 12){
      path_config %<>% paste0('_m', scg_config$num_months)
    }

    if(!file.exists(path_config)){dir.create(path_config)}
    path_config = paste(path_config, 'config.yml', sep = '/')
    
    start_date = get_start_date(master_config = mc, scg_config = scg_config, test_date = test_date)
    
    list(dataset = mc$mlmapper_id, 
         num_partitions = scg_config$num_partitions, 
         outputs = list(
           get_train_config(start_date = start_date, test_date = test_date, stratified_sampling = scg_config$stratified_sampling, training_gap = scg_config$training_gap),
           get_test_config(test_date = test_date),
           chif(scg_config$add_optimise, get_test_config(name = 'optimise', test_date = test_date), NULL)
         ) %>% list.clean
    ) %>% yaml::write_yaml(path_config)  
  }
}


