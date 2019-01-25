library(magrittr)

# run a task with these arguments:
awsTaskLaunch = function(taskName, profile, region = 'ap-southeast-2', cluster = 'sticky', launchType = 'FARGATE', variables){
  cov = list(
    containerOverrides = list(list(
      name        = taskName,
      environment = list(list(
        name  = 'config',
        value = 's3://sticky.dummy.elula.ai/config.sample.yml'
      ))
    ))
  )
  
  networkConfiguration = '"awsvpcConfiguration={subnets=[subnet-00bd73a8441685ba5],securityGroups=[sg-0bd52dca744ae20e4],assignPublicIp=ENABLED}"'
  overrides = rjson::toJSON(cov)
  
  'aws ecs run-task' %>% paste(
    paste('task-definition', taskName),
    paste('profile', profile),
    paste('region', region),
    paste('cluster', cluster),
    paste('launch-type', launchType), 
    paste('network-configuration', paste0('"', networkConfiguration, '"')), 
    paste('overrides', overrides),
    sep = ' --'
  )
}

awsTaskLaunch('agent-training', 'admin@aipoc')

