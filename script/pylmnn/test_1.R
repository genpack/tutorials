library(magrittr)
library(dplyr)
library(reticulate)
library(maler)


knn_module  <- import('sklearn.neighbors')
lmnn_module <- import('pylmnn')

iris %>% partition(0.7) -> part

X_train = part$part1 %>% dplyr::select(-Species)
y_train = part$part1 %>% pull(Species)
X_test  = part$part2 %>% dplyr::select(-Species)
y_test  = part$part2 %>% pull(Species)

lmnn = lmnn_module$LargeMarginNearestNeighbor(n_neighbors=as.integer(10), max_iter=as.integer(5), n_components=as.integer(3))
lmnn$fit(X_train %>% data.matrix, y_train)

knn = knn_module$KNeighborsClassifier(n_neighbors=as.integer(10))
knn$fit(lmnn$transform(X_train %>% data.matrix), y_train)

# Compare plots:
lmnn$transform(X_train %>% data.matrix) %>% plot(col = y_train)
X_train %>% plot(col = y_train)
