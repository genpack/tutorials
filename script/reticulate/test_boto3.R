library(magrittr)
library(reticulate)

b3 = import('boto3')
aws_s3  = b3$client('s3')

aws_s3$download_file('event_prediction_platform.democlient.elservices.com', 'configurations/periodicAggregator_config.yml', 'periodicAggregator_config.yml')

aws_s3$download_file('staging.democlient.elservices.com', 'mlmapper-c1-input/example/bigeventlog.csv', 'bigeventlog.csv')
