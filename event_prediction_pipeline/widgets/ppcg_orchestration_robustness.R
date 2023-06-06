# This widgets generates a python-pipeline config for performing a robustness test
###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')

config_filename = 'ppcg_orchestration_robustness.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

###### Read: ######
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

###### Run: ######
jobs = list()

for(test_date in config$dates){
  job = list(component = 'prediction', critical = F)
  job$config_ref = config$agent_runid
  job$id = config$name %>% paste(test_date %>% gsub(pattern = '-', replacement = '_'), sep = '_')
  job$injection = list(dataset = config$mlsampler_id, 
                       train   = paste('train', test_date, sep = '_'), 
                       test    = paste('test', test_date, sep = '_'))
  jobs[[length(jobs) + 1]] <- job
}

list(
  orchestration = list(
    # default_job_timeout = verify(config$default_job_timeout, default = '6h'),
    interval = verify(config$interval, default = '30s'),
    propagate_tags = verify(config$propagate_tags, default = F)
    # timeout = verify(config$timeout, default = '1d')
  ), jobs = jobs) %>% yaml::write_yaml(pp_config_filename(config$output_path, config$name))

