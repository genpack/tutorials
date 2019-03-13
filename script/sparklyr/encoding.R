# encoder:
  
library(sparklyr)
library(dplyr)
options(sparklyr.java9 = TRUE)

df = data.frame(X = c(1,2,3,5,7), Y = c(2,5,2,7,6))
sc  <- spark_connect(master = "local")
tbl <- sdf_copy_to(sc, df, name = "iris_tbl", overwrite = TRUE)

lbl <- paste('Label',0:7)

# Fails!
tbl %>% ft_index_to_string(input_col = 'X', output_col = 'X_Encoded', labels = lbl) %>% collect

tbl %>% ft_one_hot_encoder(input_col = 'X', output_col = 'X_Encoded') %>% collect
