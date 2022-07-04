## Rscript R_Pipeline/widgets/pp_mlmapper_parquet2csv.R

## This module builds the widetable by reading ML-Mapper
#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rutils', version = rutils.version)
load_package('rbig', version = rbig.version)

id_cols    = c('caseID', 'eventTime')
essentials = c('label', 'tte') # you can set it to the columns you want to have first
#####################  

chunk_size = 1000

#### Build Wide-Table ####
if(file.exists(sprintf("%s/wide.rds", path_ml))){
  wt <- readRDS(sprintf("%s/wide.rds", path_ml))
} else {
  wt = WIDETABLE(path = path_ml, name = 'wide', size_limit = 5e+9)
  wt$data <- wt$data[, c()]
  saveRDS(wt, sprintf("%s/wide.rds", path_ml))
}

fetpath = "%s/%s/etc/features.json" %>% sprintf(mc$path_mlmapper, id_ml)
columns = jsonlite::read_json(fetpath) %>% unlist

columns = columns %-% colnames(wt)

while(length(columns) > 0){
  fets = columns %>% sample(min(length(columns), chunk_size)) %>% c(essentials, id_cols) %>% unique
  fets = fets %-% colnames(wt) %>% c(id_cols) %>% unique

  tbl <- rbig::parquet2DataFrame(
    path.parquet = "%s/data/" %>% sprintf(path_ml), 
    columns = fets, silent = F) %>% filter(
      eventTime >= mc$mlmapper_start_date, 
      eventTime <= mc$mlmapper_end_date)

  wt <- readRDS(sprintf("%s/wide.rds", path_ml))
  columns = columns %-% colnames(wt) %-% colnames(tbl)
  
  res = try(wt$add_table(df = tbl), silent = T)
  if(inherits(res, 'try-error')){
    cat('\n', 'Reading file ', fn, ' failed with error: ', as.character(res))
  }

  wt$data <- wt$data[, c()]
  saveRDS(wt, sprintf("%s/wide.rds", path_ml))
}


