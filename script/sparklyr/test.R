library(magrittr)
library(dplyr)
library(sparklyr)

conf = list()
conf$`sparklyr.cores.local` <- 4
conf$`sparklyr.shell.driver-memory` <- "16G"
conf$spark.memory.fraction <- 0.9

sc <- spark_connect(master = "local", config = conf)

# options(sparklyr.java9 = TRUE)


# Complete syntax with all arguments:
# el = spark_read_csv(sc, name = 'el', path = 's3://staging.democlient.elservices.com/mlmapper-c1-input/example/bigeventlog.csv', header = TRUE, columns = NULL, infer_schema = TRUE, delimiter = ",", quote = "\"", escape = "\\", charset = "UTF-8", null_value = NULL, options = list(), repartition = 0, memory = TRUE, overwrite = TRUE)


# el = spark_read_csv(sc, name = 'el', path = 'Documents/data/bigeventlog.csv', 
#                     header = TRUE, columns = NULL,
#                     infer_schema = TRUE, delimiter = ",", quote = "\"",
#                     escape = "\\", charset = "UTF-8", null_value = NULL,
#                     options = list(), repartition = 0, memory = TRUE,
#                     overwrite = TRUE)




# read periodic aggregator config yaml file:
library(yaml)
path = "periodicAggregator_config.yml"
config = read_yaml(path, fileEncoding = "UTF-8")
source('tools.R')
df = MLMapper.periodic.sparklyr(el, config)

  

