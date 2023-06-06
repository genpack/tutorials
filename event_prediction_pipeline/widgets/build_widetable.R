#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('bigreadr', version = bigreadr.version)

#### Build Wide-Table ####
wt = WIDETABLE(path = path_ml, name = 'wide', size_limit = 5e+9)

fns = sprintf("%s/csv", path_ml) %>% list.files %>% charFilter('.csv')

if(length(fns) > 0){
  for(fn in fns){
    tbl = bigreadr::big_fread2(file = paste(path_ml, 'csv', fn, sep = '/'))
    if(!is.null(tbl$caseID)) tbl$caseID %<>% as.character
    if(!is.null(tbl$eventTime)) tbl$eventTime %<>% as.Date
    
    res = try(wt$add_table(df = tbl), silent = T)
    if(inherits(res, 'try-error')){
      cat('\n', 'Reading file ', fn, ' failed with error: ', as.character(res))
    }
  }
} else {
  cat('\n', 'No csv files found in the ml-mapper!' %>% 
        paste('Please run mlmapper_parquet2csv.ipynb with jupyter notebook to create csv files out of ML-Mapper.', '\n'))
  
  cat('Checking for DF-Packs ...', '\n')
  fns = sprintf("%s/dfpack", path_ml) %>% list.files %>% charFilter('.rds')
  if(length(fns) > 0){
    for(fn in fns){
      dfp = readRDS(paste(path_ml, 'dfpack', fn, sep = '/'))
      for(tn in names(dfp) %-% c('case_timends', 'event_attr_map')){
        tbl = dfp[[tn]]
        if(!is.null(tbl$caseID)) tbl$caseID %<>% as.character
        if(!is.null(tbl$eventTime)) tbl$eventTime %<>% as.Date
        res = try(wt$add_table(df = tbl), silent = T)
        if(inherits(res, 'try-error')){
          cat('\n', 'Reading file ', fn, ' failed with error: ', as.character(res))
        }
      }
    }
  } else {
    stop('No dfpack folder found i the ml-mapper!. Run mlmapper module to create dfpacks.')
  }
}

# Convert -9999 to NA
for(i in colnames(wt)){ind = which(wt[[i]] == -9999); if(length(ind) > 0){wt[ind, i] <- NA}}

wt$data <- wt$data[, c()]
saveRDS(wt, sprintf("%s/wide.rds", path_ml))
