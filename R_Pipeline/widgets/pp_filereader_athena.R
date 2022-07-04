## Rscript R_Pipeline/widgets/pp_filereader_athena.R

## This module builds the widetable by directly reading ML-Mapper from s3 bucket using athena sql.
## It uses el_de_tools package to read the data
#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)

id_cols    = c('caseid', 'eventtime')
essentials = c('label', 'tte') # you can set it to the columns you want to have first
  
reticulate::py_run_string("import sys")
reticulate::py_run_string("sys.path.append('%s')" %>% sprintf(mc$path_detools))
et = reticulate::import('el_detools_v06')

chunk_size = 200
#### Build Wide-Table ####
if(file.exists(sprintf("%s/wide.rds", path_ml))){
  wt <- readRDS(sprintf("%s/wide.rds", path_ml))
} else {
  wt = WIDETABLE(path = path_ml, name = 'wide', size_limit = 5e+9)
  wt$data <- wt$data[, c()]
  saveRDS(wt, sprintf("%s/wide.rds", path_ml))
}

table_name = "mlmapper._%s" %>% sprintf(mc[["mlmapper_id"]] %>% gsub(pattern = "-", replacement = "_"))
"SELECT * FROM %s limit 0" %>% sprintf(table_name) %>% 
  et$execute_sql() %>% colnames -> columns

columns = columns %-% colnames(wt)

while(length(columns) > 0){
  fets = columns %>% sample(min(length(columns), chunk_size)) %>% c(essentials, id_cols) %>% unique
  fets = fets %-% colnames(wt) %>% c(id_cols) %>% unique

  "SELECT %s FROM %s WHERE CAST(eventTime AS DATE) >= CAST('%s' AS DATE) AND CAST(eventTime AS DATE) <= CAST('%s' AS DATE)" %>% 
    sprintf(fets %>% paste(collapse = ', '), table_name, mc$mlmapper_start_date, mc$mlmapper_end_date) %>% 
    et$execute_sql() -> tbl
  
  if('eventtime' %in% fets){
    tbl[['eventtime']] <- tbl[['eventtime']] %>% purrr::map(as.character) %>% unlist
  }
  
  rbig::colnames(tbl) %>% sapply(function(u) tbl[[u]] %>% class) %>% unlist -> cls
  listcols = which(cls == 'list')
  
  assert(length(listcols) == 0, cat('These columns are of class list: ', '\n' , listcols %>% paste(collapse = ', '), '\n'))
  
  wt <- readRDS(sprintf("%s/wide.rds", path_ml))
  columns = columns %-% colnames(wt) %-% fets
  
  if(rbig::ncol(wt) > 0){
    wt[id_cols] %>% left_join(tbl, by = id_cols) -> tbl
  }
  
  res = try(wt$add_table(df = tbl), silent = T)
  if(inherits(res, 'try-error')){
    cat('\n', 'Reading file ', fn, ' failed with error: ', as.character(res))
  }

  wt$data <- wt$data[, c()]
  saveRDS(wt, sprintf("%s/wide.rds", path_ml))
}


