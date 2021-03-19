# Test upsampling:
library(magrittr)
library(reticulate)
library(rutils)
library(rml)
library(dplyr)
####################
sv = import('smote_variants')
imb_datasets = import('imblearn.datasets')
sklearn.neighbors    = import('sklearn.neighbors')
KNeighborsClassifier = sklearn.neighbors$KNeighborsClassifier

####################
dataset = imb_datasets$fetch_datasets()[['libras_move']]
X = dataset[['data']] %>% as.data.frame
y = dataset[['target']]
y[y == -1] <- 0

feature_names = try(dataset$feature_names, silent = T)
if(inherits(feature_names, 'character')){
  colnames(X) <- dataset$feature_names
}

classifier= CLS.SKLEARN.KNN(n_neighbors= 5L, cv.ntest = 5, cv.test_ratio = 0.7, cv.performance_metric = 'gini')
classifier$performance.cv(X, y) %>% median

oversampler= sv$distance_SMOTE()
res = oversampler$sample(X %>% as.matrix, y %>% as.integer)
Xu = res[[1]] %>% as.data.frame
yu = res[[2]] %>% as.integer

classifier= CLS.SKLEARN.KNN(n_neighbors= 5L, cv.ntest = 5, cv.test_ratio = 0.7, cv.performance_metric = 'gini')
classifier$performance.cv(Xu, yu) %>% median

