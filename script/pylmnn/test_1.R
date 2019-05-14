library(magrittr)
library(dplyr)
library(reticulate)


knn_module  <- import('sklearn.neighbors')
lmnn_module <- import('pylmnn')

iris %>% partition(0.7) -> part

X_train = part$part1 %>% dplyr::select(-Species)
y_train = part$part1 %>% pull(Species)
X_test  = part$part2 %>% dplyr::select(-Species)
y_test  = part$part2 %>% pull(Species)

