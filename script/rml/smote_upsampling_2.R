# Test upsampling:
library(magrittr)
library(reticulate)
library(rutils)
library(rml)
library(dplyr)
####################
os.path = import('os.path')

sklearn.neighbors    = import('sklearn.neighbors')
KNeighborsClassifier = sklearn.neighbors$KNeighborsClassifier

sklearn.tree = import('sklearn.tree')
DecisionTreeClassifier = sklearn.tree$DecisionTreeClassifier

sv = import('smote_variants')
datasets = import('sklearn.datasets')

cache_path= os.path$join(os.path$expanduser('~'), 'smote_test')

if (!os.path$exists(cache_path)){
  os.makedirs(cache_path)}

dataset= datasets$load_breast_cancer()

X = dataset[['data']] %>% as.data.frame %>% {colnames(.) <- dataset$feature_names;.}
y = dataset[['target']]

knn_classifier = KNeighborsClassifier()
dt_classifier  = DecisionTreeClassifier()

oversampler = sv$distance_SMOTE()

res = oversampler$sample(X %>% as.matrix, y %>% as.integer)
Xu = res[[1]] %>% as.data.frame
yu = res[[2]] %>% as.integer

knn = CLS.SKLEARN.KNN(cv.ntrain = 10, cv.train_ratio = 0.7)
knn$performance.cv(X, y) %>% median
knn$performance.cv(Xu, yu) %>% median
