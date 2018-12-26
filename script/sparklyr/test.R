conf = list()
conf$`sparklyr.cores.local` <- 4
conf$`sparklyr.shell.driver-memory` <- "16G"
conf$spark.memory.fraction <- 0.9

sc <- spark_connect(master = "local", version = "2.1.0", config = conf)

options(sparklyr.java9 = TRUE)

el = spark_read_csv(sc, name = 'el', path = 's3://sticky.democlient.elulaservices.com/source-data/bigeventlog.csv', header = TRUE)
# Complete syntax with all arguments:
# el = spark_read_csv(sc, name = 'el', path = 's3://sticky.democlient.elulaservices.com/source-data/bigeventlog.csv', header = TRUE, columns = NULL, infer_schema = TRUE, delimiter = ",", quote = "\"", escape = "\\", charset = "UTF-8", null_value = NULL, options = list(), repartition = 0, memory = TRUE, overwrite = TRUE)


el = spark_read_csv(sc, name = 'el', path = 'Documents/data/sticky/bigeventlog.csv', 
                    header = TRUE, columns = NULL,
                    infer_schema = TRUE, delimiter = ",", quote = "\"",
                    escape = "\\", charset = "UTF-8", null_value = NULL,
                    options = list(), repartition = 0, memory = TRUE,
                    overwrite = TRUE)
