extract_items = function(ss){
  ss %>%
    gsub(pattern = '\n', replacement = '') %>%
    gsub(pattern = ' ', replacement = '') %>%
    strsplit('-') %>% {.[[1]]}
}

from_prediction_to_local = function(agent_run_id, model_run_id, filename = 'log.txt', target = NULL, client = 'cua', profile = 'write@cua-sticky'){
  file_address = paste0('s3://', 'prediction.prod.sticky.', 
                        client, '.elulaservices.com/agentrun=', 
                        agent_run_id, '/modelrun=', model_run_id,
                        '/', filename)
  
  if(!is.null(target)){path = paste0(target, '/')} else {path = './'}
  
  paste('aws', 's3', 'cp', file_address, path, '--profile', profile)
  
}

from_prediction_to_exchange = function(agent_run_id, model_run_id, filename = 'log.txt', target = NULL, client = 'cua', profile = 'write@cua-sticky'){
  file_address = paste0('s3://', 'prediction.prod.sticky.', 
                        client, '.elulaservices.com/agentrun=', 
                        agent_run_id, '/modelrun=', model_run_id,
                        '/', filename)
  path = paste0('s3://', 'exchange.prod.sticky.', 
                client, '.elulaservices.com/')
  if(!is.null(target)){path = paste0(path, target, '/')}
  paste('aws', 's3', 'cp', file_address, path, '--profile', profile)
  
}


from_sampler_to_local = function(run_id = 'daa93024-f381-4fb0-b42d-346e9bea0116', target = NULL, client = 'cua', profile = 'write@cua-sticky'){
  dir_address = paste0('s3://', 'mlsampler.prod.sticky.', 
                        client, '.elulaservices.com/run=', 
                        run_id, '/')
  
  if(!is.null(target)){path = paste0(target, '/')} else {path = './'}
  path %<>% paste0(substr(run_id, 1, 8), '/')
  
  paste('aws', 's3', 'cp', dir_address, path, '--recursive', '--profile', profile)
}
  
from_mlmapper_to_local = function(run_id = 'd0f614b5-94e6-4684-93bd-c517bbc32500', target = NULL, client = 'cua', profile = 'write@cua-sticky'){
  dir_address = paste0('s3://', 'mlmapper.prod.sticky.', 
                       client, '.elulaservices.com/run=', 
                       run_id, '/')
  
  if(!is.null(target)){path = paste0(target, '/')} else {path = './'}
  path %<>% paste0(substr(run_id, 1, 8), '/')
  
  paste('aws', 's3', 'cp', dir_address, path, '--recursive', '--profile', profile)
}


from_prediction_to_local(agent_run_id = '4e0f8fca-a8b4-4c5e-9804-9880059f4c5e', 
                         model_run_id = '44c99eba-ef68-4422-ae87-4e5b428bbdc6', 
                         client = 'cua', profile = 'write@cua-sticky')

	
from_prediction_to_local(agent_run_id = 'd58a032b-4e8e-4913-aa93-f9db2c9a7eb1', 
                         model_run_id = '70b1bce2-82dd-4bde-8957-4f66c5c49f0e', 
                         filename = 'config.json', client = 'cua', profile = 'write@cua-sticky')

from_prediction_to_exchange(agent_run_id = '274adf84-39aa-4c65-8e43-848340d363e2', 
                         model_run_id = 'c7eaceb5-5fa6-474b-8070-acf7311e4513', 
                         target = 'Nima', filename = 'config.json', client = 'cua', profile = 'write@cua-sticky')


from_sampler_to_local(run_id = 'e2caa47d-8fed-4d05-ba83-d81794898702', 
                      target = 'D:/Users/nima.ramezani/Documents/data/samplers', client = 'cua', profile = 'write@cua-sticky')

from_mlmapper_to_local(run_id = 'e2caa47d-8fed-4d05-ba83-d81794898702', 
                      target = 'D:/Users/nima.ramezani/Documents/data/mlmapper', client = 'cua', profile = 'write@cua-sticky')

load_gener = function(){
  source('~/Documents/software/R/packages/gener/R/gener.R')
  source('~/Documents/software/R/packages/gener/R/linalg.R')
}

load_maler = function(){
  source('~/Documents/software/R/packages/maler/R/mltools.R')
  source('~/Documents/software/R/packages/maler/R/abstract.R')
  source('~/Documents/software/R/packages/maler/R/classifiers.R')
  source('~/Documents/software/R/packages/maler/R/transformers.R')
}
