#### Setup #####
source('R_Pipeline/initialize.R')
source('R_Pipeline/libraries/io_tools.R')

################ Inputs ################
config_filename = 'pp_mlsampler_copy.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> csmp_config

#### Run: ####
for (id in csmp_config$sampler_ids){
  copy_mlsampler_to_local(mc, id)
}
