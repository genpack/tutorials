# This widgets generates a python-pipeline config for performing a robustness test
###### Setup: ######
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/pp_tools.R')

config_filename = 'ppcg_orchestration_modifier.yml'
args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

###### Read: ######
mc$path_configs %>% paste('widgets', config_filename, sep = '/') %>% yaml::read_yaml() -> config

###### Run: ######

yaml::read_yaml(config$input_orchestration_config) -> input_config

ids = input_config$jobs %>% lapply(function(u) u$id) %>% unlist

output_config = input_config
output_config$jobs %<>% rlist::list.remove(which(ids %in% names(config$skipped_components)))

output_config %<>% rutils::list.clean()

for(sc in names(config$skipped_components)){
  if(!is.null(config$skipped_components[[sc]])){
    output_config %<>% list.replace(pattern = sprintf("\\$\\{%s.runid\\}", sc), replacement = config$skipped_components[[sc]])
  }
}

prod_config_names = output_config$jobs %>% lapply(function(u) 
  rutils::chif(is.null(u[['production_config_name']]), NA, u[['production_config_name']])) %>% unlist

for(rc in names(config$replaced_configs)){
  for(i in which(prod_config_names == rc)){
    output_config$jobs[[i]]$config_ref <- config$replaced_configs[[rc]]
    output_config$jobs[[i]]$production_config_name <- NULL
  }
}

ids = output_config$jobs %>% lapply(function(u) u$id) %>% unlist

for(ai in names(config$additional_injections)){
  for(i in which(ids == ai)){
    output_config$jobs[[i]]$injection %<>% rlist::list.merge(config$additional_injections[[ai]])
  }
}

# 

yaml::write_yaml(output_config, config$output_orchestration_config, 
                 indent.mapping.sequence = F, 
                 handlers = list(logical = function(x) {
                   result <- ifelse(x, "true", "false")
                   class(result) <- "verbatim"
                   return(result)
                 }))
