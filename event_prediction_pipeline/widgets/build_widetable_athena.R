## This module builds the widetable by directly reading ML-Mapper from s3 bucket using athena sql.
## It uses el_de_tools package to read the data
#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)
load_package('bigreadr', version = bigreadr.version)


reticulate::py_run_string("import sys")
reticulate::py_run_string("sys.path.append('%s')" %>% sprintf(mc$path_detools))
et = reticulate::import('el_detools_v06')

chunk_size = 200
#### Build Wide-Table ####
wt = WIDETABLE(path = path_ml, name = 'wide', size_limit = 5e+9)

table_name = "mlmapper._%s" %>% sprintf(mc[["mlmapper_id"]] %>% gsub(pattern = "-", replacement = "_"))
"SELECT * FROM %s limit 0" %>% sprintf(table_name) %>% 
  et$execute_sql() %>% colnames -> columns

columns = columns %-% colnames(wt)
# columns = c('caseID', 'eventTime', 'tte', 'label')
while(length(columns) > 0){
  fets = columns %>% sample(min(length(columns), chunk_size))
  
  "SELECT %s FROM %s WHERE CAST(eventTime AS DATE) >= CAST('%s' AS DATE) AND CAST(eventTime AS DATE) <= CAST('%s' AS DATE)" %>% 
    sprintf(fets %>% paste(collapse = ', '), table_name, mc$mlmapper_start_date, mc$mlmapper_end_date) %>% 
    et$execute_sql() -> tbl
  
  if ('eventTime' %in% colnames(tbl)){
    if(!inherits(tbl$eventTime, 'character')){
      
      tt <- try(purrr::map(tbl$eventTime, as.character) %>% unlist, silent = T)
      if(inherits(tt, 'try-error')){
        tt = c()
        for(i in sequence(nrow(tbl))){
          tt[i] <- as.character(tbl$eventTime[i - 1])
        }
      }
      tbl$eventTime <- tt
    }
  }
  res = try(wt$add_table(df = tbl), silent = T)
  if(inherits(res, 'try-error')){
    cat('\n', 'Reading file ', fn, ' failed with error: ', as.character(res))
  }
  columns = columns %-% fets 
}


wt$data <- wt$data[, c()]
saveRDS(wt, sprintf("%s/wide.rds", path_ml))



# et$execute_sql("select * from packaging.robustness_scores_pkg")