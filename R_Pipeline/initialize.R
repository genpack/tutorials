# set PATH=<path_to_R>;%PATH%
##### Package Versions: #####
rutils.version = '3.2.2'
rml.version    = '1.5.0'
rbig.version   = '1.3.4'
rfun.version   = '0.0.1'
yaml.version   = '2.2.1'

promer.version       = '1.9.2'
bigreadr.version     = '0.2.0'
reticulate.version   = '1.18'
plotly.version       = '4.9.2.1'
dplyr.version        = '1.0.2'
d3heatmap.version    = '0.6.1.3'

##### Setup ######

load_package = function(package, version = NULL, path = 'R_Pipeline/packages'){
  success = require(package, character.only = T)[1]
  if(success & !is.null(version)){
    pack_version = utils::packageVersion(package) %>% as.character
    success = (pack_version == version)
  }
  
  if(!success & is.null(version)){
    res  = try(install.packages(package))
    success = !inherits(res, 'try-error')
  }

  if(!success){
    search_item <- paste("package", package, sep = ":")
    while(search_item %in% search())
    {
      detach(search_item, unload = TRUE, character.only = TRUE)
    }
    # rutils::delib(package, character.only = T)
    # try to install from source:
    package_address = paste0(path, '/', package,'_', version,'.tar.gz')
    success = file.exists(package_address)
    if(success){
      res = try(install.packages(package_address, source = T, repos = NULL))
      success = !inherits(res, 'try-error')
    } else{cat(sprintf('Package %s version %s does not exist in the packages folder!', package, version), '\n')}
    
    if(success){
      success = require(package, character.only = T)[1]
    }
    if(success){
      pack_version = utils::packageVersion(package) %>% as.character
      success = pack_version == version
    }
    
    if(!success){
      cat('\n', sprintf('Package %s version %s cannot be installed from source!', package, version))
    }

    if(!success){
      # try to install from cran first
      library(devtools)
      res = try(install_version(package, version = version, repos = "http://cran.us.r-project.org"))
      success = !inherits(res, 'try-error')
      if(success){success = require(package, character.only = T)[1]}
      if(success){
        pack_version = utils::packageVersion(package) %>% as.character
        success = pack_version == version
      }
    }
  }
  
  warnif(!success, sprintf("Could not load package %s version %s!", package, version))
}

if(!require(devtools)){install.packages('devtools'); library(devtools)}
if(!require(yaml)){install.packages('yaml'); library(yaml)}
if(!require(jsonlite)){install.packages('jsonlite'); library(jsonlite)}
if(!require(magrittr)){install.packages('magrittr'); library(magrittr)}
if(!require(dplyr)){install.packages('dplyr'); library(dplyr)}
if(!require(lubridate)){install.packages('lubridate'); library(lubridate)}
if(!require(plotly)){install.packages('plotly'); library(plotly)}
if(!require(reshape2)){install.packages('reshape2'); library(reshape2)}
if(!require(reticulate)){install.packages('reticulate'); library(reticulate)}
if(!require(bigreadr)){install.packages('bigreadr'); library(bigreadr)}
if(!require(AUC)){install.packages('AUC'); library(AUC)}

load_package('rutils', version = rutils.version)

#### Some global variables: ####

metrics   = c('gini', 'precision', 'lift', 'loss')
quantiles = c(0.01, 0.02, 0.05, 0.1, 0.2, 0.5)

##### Read Master Config: #####
mc = yaml::read_yaml('R_Pipeline/master_config.yml')

Sys.setenv(AWS_SHARED_CREDENTIALS_FILE = sprintf("D:/Users/%s/.aws/credentials", mc$user),
           AWS_CONFIG_FILE = sprintf("D:/Users/%s/.aws/config", mc$user))

if(is.null(mc$path_data)){
  mc$path_data <- 'D:/Users/%s/Documents/data' %>% sprintf(mc$user)
} else {
  mc$path_data <- mc$path_data
}
if(!file.exists(mc$path_data)){dir.create(mc$path_data)}

for (fn in c('mlmapper', 'mlsampler', 'eventmapper', 'prediction', 'orchestration', 'reports', 'models', 'exchange', 'original')){
  pfn = 'path' %>% paste(fn, sep = '_')
  if(is.null(mc[[pfn]])){
    mc[[pfn]] <- mc$path_data %>% paste(fn, sep = '/')
  }
  if(!file.exists(mc[[pfn]])){dir.create(mc[[pfn]])}
}

if(is.null(mc[['path_rp']])){
  mc[['path_rp']] = 'D:/Users/%s/Documents/CodeCommit/data-science-tools/R_pipeline' %>% sprintf(mc$user)
}

if(is.null(mc[['path_detools']])){
  mc[['path_detools']] = 'D:/Users/%s/Documents/CodeCommit/data-engineering-tools/00_root_folder_structure/1_code_only/9_de_tools' %>% sprintf(mc$user)
}

if(is.null(mc[['path_analytics']])){
  mc[['path_analytics']] = 'D:/Users/%s/Documents/CodeCommit/analytics-%s' %>% sprintf(mc$user, mc$client)
}

if(is.null(mc[['path_configs']])){
  mc[['path_configs']] = paste(mc$path_rp, 'configs', sep = '/') 
}

##### Paths: #####
id_ml = mc$mlmapper_id %>% substr(1,8)
id_el = mc$eventmapper_id %>% substr(1,8)
id_ob = mc$obsmapper_id %>% substr(1,8)

path_ml = paste(mc$path_mlmapper, id_ml, sep = '/')
path_el = paste(mc$path_eventmapper, id_el, sep = '/')
path_ob = paste(mc$path_obsmapper, id_ob, sep = '/')


path_rp = 'D:/Users/%s/Documents/data/rp' %>% sprintf(mc$user)
# path_ml.rp    <- '%s/mlmapper' %>% paste(path_rp, sep = '/')

##### Local Sourcing: #####
source('R_Pipeline/libraries/rp_tools.R')


