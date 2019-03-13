library(sparklyr)
library(dplyr)
options(sparklyr.java9 = TRUE)

sc <- spark_connect(master = "local")
iris_tbl <- sdf_copy_to(sc, iris, name = "iris_tbl", overwrite = TRUE)

# This one fails:
spbinned = iris_tbl %>% ft_bucketizer(input_col = 'Sepal_Width', output_col = 'SPBIN', splits = c(Zero = 0, One = 1, Two = 2, Three = 3)) %>% collect


# This works:
iris_tbl %>%
  ft_bucketizer(input_col  = "Sepal_Length",
                output_col = "Sepal_Length_bucket",
                splits     = c(Zero = 0, Four = 4.5, Five = 5, Eight = 8)) %>% collect -> df

# fails!!
iris_tbl %>% 
  ft_bucketizer(input_col = 'Sepal_Width', 
                output_col = 'SPBIN', splits = c(0, 1, 3.89))


# works!
iris_tbl %>% 
  ft_bucketizer(input_col = 'Sepal_Width', 
                output_col = 'SPBIN', splits = c(0, 1, 3.9))
  


# Fails!!
iris_tbl %>% 
  ft_bucketizer(input_col = 'Sepal_Width', 
                output_col = 'SPBIN', splits = c(0, 1, 4)) %>% collect

# NOTE: You should add Inf to the end of splits and -Inf to the beginning to make sure boundary covers all values
spark.bucketize = function(sdf, input_col, output_col, splits){
  ns = names(splits) 
  if(is.null(ns)){
    return(sdf %>% sparklyr::ft_bucketizer(input_col = input_col, output_col = output_col, splits = splits))
  } else {
    return(sdf %>% 
             sparklyr::ft_bucketizer(input_col = input_col, output_col = 'OutputIndexed', splits = splits %>% unname) %>% 
             sparklyr::ft_index_to_string(input_col = 'OutputIndexed', output_col = output_col, labels = ns)) %>% 
             select(- OutputIndexed)
  }
}


iris_tbl %>% spark.bucketize(input_col = 'Sepal_Width', output_col = 'SPBIN', splits = c(Zero = 0, One = 1, Two = 2, Four = 4, Five = 5)) %>% 
  collect -> binned

