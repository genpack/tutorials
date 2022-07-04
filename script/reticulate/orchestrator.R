library(magrittr)
library(dplyr)
library(yaml)
library(reticulate)
use_python("/Users/nima/anaconda3/bin/python")

# pd    = import('pandas')
boto  = import('boto3')
# sys   = import('sys') 
# os    = import('os')
urlp  = import('urllib.parse') 
# yaml  = import('yaml') 
# tme   = import('time')
el    = import('ellib')
# jsn   = import('json')

py_run_string("import os")

# This gives default client sessions:
# aws_s3  = boto$client('s3')
# aws_ecs = boto$client('ecs')

botsec  = boto$session$Session(profile_name= 'write@event_prediction_platform')
aws_s3  = botsec$client('s3')
aws_ecs = botsec$client('ecs')

environ = Sys.getenv()

# if (py_eval("'config' not in os.environ")){
#   cat('no config file location in environment variables specified.')
#   stop()
# }

if (!'config' %in% names(environ)){
  cat('no config file location in environment variables specified.')
  "s3://event_prediction_platform.dummy.el.ai/config.sample.yml"-> environ[['config']]
}

o = urlp$urlparse(environ[['config']])
aws_s3$download_file(o$netloc, o$path %>% substr(2, nchar(.)), 'config.yml')
config = read_yaml('config.yml')
cat('config file downloaded and loaded.')


o = urlp$urlparse(config[['data']][['source']])
aws_s3$download_file(o$netloc, o$path %>% substr(2, nchar(.)), 'dataset.csv')
cat('dataset downloaded.')

# dataset = pd$read_csv('dataset.csv')
dataset = read.csv('dataset.csv')

Y = dataset[, config[['response']], drop = F]
X = dataset %>% {.[, config[['response']]] <- NULL;.}

L = el$data$encode_categoricals(X %>% r_to_py, config[['categorical']])
X = L[[1]]

