# Feature Transfer Module
# This module transfer a feature from one mlmapper wideTable into another.
# In case caseIDs are different, it will map them using a caseid_mapper.

#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
################ Inputs ################
config_filename = 'feature_transfer.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('widgets', config_filename, sep = '/')) -> ft_config
################ Mapping ################

inpath  = paste(mc$path_mlmapper, ft_config$input_id, sep = '/')
outpath = paste(mc$path_mlmapper, ft_config$output_id, sep = '/')

# Take id columns from the output mlmapper:
sprintf("%s/%s/wide.rds", mc$path_mlmapper, ft_config$output_id) %>% readRDS() -> wtout
wtt = wtout[c('caseID', 'eventTime')] %>% rename(caseid_out = caseID)

# Take id columns and features to be transferred from the input mlmapper:
sprintf("%s/%s/wide.rds", mc$path_mlmapper, ft_config$input_id) %>% readRDS() -> wtin
wtn = wtin[c('caseID', 'eventTime', ft_config$features) %>% unique] %>% rename(caseid_in = caseID)
if(!is.null(ft_config$shift_months)){
  wtn$eventTime = wtn$eventTime + months(ft_config$shift_months)
}

if(!is.null(ft_config$caseid_mapper)){
  # The caseid_mapper is taken from preprocessing by default
  # The mapper's first column must be the input mlmapper caseid and 
  # the second column must be the caseid of the output mlmapper
  mpr = read_table_epp(mc, ft_config$caseid_mapper, bucket = 'preprocessing', format = 'rds')
  colnames(mpr) = c('caseid_in', 'caseid_out')
  mpr %<>% distinct %>% filter(caseid_in %in% wtn$caseid_in)

  # Duplicated caseids in the output mlmapper will be dropped. One and only one caseid from input mlmapper is allowed 
  mpr = mpr[!duplicated(mpr$caseid_out),]
  
  wtt %<>% left_join(mpr, by = 'caseid_out')
} else {
  wtt$caseid_in = wtt$caseid_out
}

wtt %<>% left_join(wtn, by = c('caseid_in', 'eventTime'))

# to do:
# wtt %>% group_by(caseid_out, eventTime) %>% summarise(...)

wtt$eventTime  %>% identical(wtout[['eventTime']]) %>% assert('Look at that')
wtt$caseid_out %>% identical(wtout[['caseID']]) %>% assert('Look at that')

res = try(wtout$add_table(df = wtt %>% select(-caseid_in) %>% rename(caseID = caseid_out)), silent = T)
if(inherits(res, 'try-error')){
  cat('\n', 'Transfer failed with error: ', as.character(res))
} else {
  wtout$data <- wtout$data[, c()]
  saveRDS(wtout, sprintf("%s/%s/wide.rds", mc$path_mlmapper, ft_config$output_id))
}
