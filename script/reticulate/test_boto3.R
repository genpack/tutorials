library(magrittr)
library(reticulate)

b3 = import('boto3')
aws_s3  = b3$client('s3')

aws_s3$download_file('sticky.democlient.elulaservices.com', 'configurations/periodicAggregator_config.yml', 'periodicAggregator_config.yml')

aws_s3$download_file('staging.democlient.elulaservices.com', 'mlmapper-c1-input/example/bigeventlog.csv', 'bigeventlog.csv')
