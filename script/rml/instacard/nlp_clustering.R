# Clustering products using NLP:
# Clear memory:
rm(list = ls('order_products_prior', 'order_products_train'))
gc()
### 



## 
library(tm)
texer::TEXT.MINER(products, text_col = 'product_name', id_col = 'product_id') -> tx
# tx$plot.wordCloud(weighting = 'freq')
# tx$data$DTM %>% colnames

## todo: This does not work for clustering. Add functionality to the package:
tx$settings$metric = 'binary' 

tx$clust(weighting = 'tfidf', nc = 100)

# Observe some clusters: todo: add this functionality to the package: wordcloud, barchart, ...
# tx$data$CRS[2,] %>% sort %>% tail
# tx$data$CRS[6,] %>% sort %>% tail

saveRDS(tx, 'data/tm_object.rds')
