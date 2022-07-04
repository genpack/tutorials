#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
################ Inputs ################
config_filename = 'pp_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'preprocessing', config_filename, sep = '/')) -> pp_config

for(step in pp_config$steps){
  outpath = paste(mc$path_preprocessing, pp_config$output_id, sep = '/')
  if(!file.exists(outpath)){dir.create(outpath)}
  outpath %<>% paste(step$output %++% '.rds', sep = '/')
  if(!file.exists(outpath)){
    # Read input files:
    for (fn in step$input){
      fnp = fn
      if(!file.exists(fnp)){
        fnp = "%s/%s/%s.rds" %>% sprintf(mc$path_preprocessing, pp_config$output_id, fn)
      }
      if(file.exists(fnp)){
        assign(fn, readRDS(fnp))
      } else {
        fnp = "%s/%s/%s" %>% sprintf(mc$path_preprocessing, pp_config$input_id, fn)
        if(file.exists(fnp)){
          assign(fn, rbig::parquet2DataFrame(fnp))
        } else {
          fnp = "%s/%s.csv" %>% sprintf(mc$path_original, fn)
          if(file.exists(fnp)){
            assign(fn, read.csv(fnp, as.is = T))
          } else {
            fnp = mc$path_original %>% paste(fn, 'original', sep = '/')
            if(file.exists(fnp)){
              fnp = paste(fnp, list.files(fnp), sep = '/')
              assign(fn, bigreadr::big_fread2(fnp, colClasses = step$schema %>% unlist, stringsAsFactors = F))
            } else {
              stop(sprintf("file %s not found", fnp))
            }
          }
        }
      }
    }  
    if(!file.exists(mc$path_preprocessing)){dir.create(mc$path_preprocessing)}
    out = parse(text = "operate(%s, step$operation)" %>% sprintf(step$input[1])) %>% eval
    saveRDS(out, outpath)
  }
}