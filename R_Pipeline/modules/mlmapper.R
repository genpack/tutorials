# Module ML Mapper for the R Pipeline:

#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
load_package('promer', version = promer.version)
################ Inputs ################
config_filename = 'ml_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'mlmapper', config_filename, sep = '/')) -> ml_config
################ Mapping ################

outpath = paste(mc$path_mlmapper, ml_config$output_id, sep = '/')
if(!file.exists(outpath)){dir.create(outpath)}

if(!is.null(ml_config$clock)){
  assert(inherits(ml_config$clock, 'list'))
  if(is.null(ml_config$clock$source)){ml_config$clock$source = 'mlmapper'}
  if(ml_config$clock$source == 'mlmapper'){
    sprintf("%s/%s/wide.rds", mc$path_mlmapper, id_ml) %>% readRDS() -> wt
    wtn = wt[c('caseID', 'eventTime')]
  } else {stop('Clock source other than mlmapper is not yet supported!')}
  
  if(!is.null(ml_config$clock$caseid_mapper)){
    # The mapper inputs are taken from preprocessing by default
    # The mapper's first column must be mlmapper caseid (clock source caseid) and 
    # the second column must be the caseid of the input eventlog
    mpr = read_table_epp(mc, ml_config$clock$caseid_mapper, bucket = 'preprocessing', format = 'rds')
    colnames(mpr) = c('caseID', 'el_caseID')
    mpr %<>% distinct
    
    wtn %<>% left_join(mpr, by = 'caseID')
    wtn %>% select(caseID = el_caseID, eventTime) %>% na.omit %>%
      distinct(caseID, eventTime) %>% 
      mutate(eventType = 'Clock', attribute = 'counter', value = 1) -> el_clock
  }
} else el_clock = NULL

for(step in ml_config$steps){
  prd = verify(step$period, 'character', domain = c('month', 'day'), default = 'month') 
  sqn = verify(step$sequential, 'logical', default = T) 
  
  el = NULL
  for (fn in step$input){
    fnp = "%s/%s/%s.rds" %>% sprintf(mc$path_eventmapper, mc$eventmapper_id, fn)
    if(file.exists(fnp)){
      el %<>% dplyr::bind_rows(readRDS(fnp)) 
    } else {stop(sprintf("file %s not found", fnp))}
  }
  el$eventTime %<>% as.Date
  
  el_clock %>% 
    anti_join(distinct(el, caseID, eventTime)) %>% 
    rbind(el) %>% 
    dfg_pack(period = prd, 
             event_funs = step$event_funs,
             horizon = step$horizon,
             sequential = sqn) -> pack
  
  ################ Save Output ################
  outpath = sprintf("%s/%s/dfpack/%s.rds", mc$path_mlmapper, ml_config$output_id, step$output)
  
  if(length(config$events_exclude) > 0){
    for(tn in names(pack)  %-% c('case_timends', 'event_attr_map')){
      pack[[tn]] %>% charFilter(config$events_exclude) -> colnames_to_remove
      pack[[tn]] <- pack[[tn]][colnames(pack[[tn]]) %-% colnames_to_remove]
    }
  }

  if(length(config$attributes_exclude) > 0){
    for(tn in names(pack)  %-% c('case_timends', 'event_attr_map')){
      pack[[tn]] %>% charFilter(config$attributes_exclude) -> colnames_to_remove
      pack[[tn]] <- pack[[tn]][colnames(pack[[tn]]) %-% colnames_to_remove]
    }
  }
  
  pack %>% saveRDS(outpath)
}

