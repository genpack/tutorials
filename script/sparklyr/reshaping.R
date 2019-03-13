library(sparklyr)
library(dplyr)
options(sparklyr.java9 = TRUE)

sc <- spark_connect(master = "local")
iris_tbl <- sdf_copy_to(sc, iris, name = "iris_tbl", overwrite = TRUE)

# aggregating by mean
iris_tbl %>%
  mutate(Petal_Width = ifelse(Petal_Width > 1.5, "High", "Low" )) %>%
  sdf_pivot(Petal_Width ~ Species,
            fun.aggregate = list(Petal_Length = "mean"))

# aggregating all observations in a list
iris_tbl %>%
  mutate(Petal_Width = ifelse(Petal_Width > 1.5, "High", "Low" )) %>%
  sdf_pivot(Petal_Width ~ Species,
            fun.aggregate = list(Petal_Length = "sum", Sepal_Length = "AVG"))

iris %>%
  mutate(Petal_Width = ifelse(Petal.Width > 1.5, "High", "Low" )) %>%
  reshape2::dcast(Petal_Width ~ Species,
                  fun.aggregate = sum, value.var = 'Petal.Length')



