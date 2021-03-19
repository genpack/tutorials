# Test upsampling:
library(reticulate)
library(rutils)
library(rml)
library(dplyr)
####################
sv   = reticulate::import('smote_variants')
imbd = reticulate::import('imbalanced_databases')

dataset = imbd$load_iris0()

######

X = dataset[['data']] %>% as.data.frame %>% {colnames(.) <- dataset$feature_names;.}
y = dataset[['target']] %>% as.integer

oversampler= sv$distance_SMOTE()

# X_samp and y_samp contain the oversampled dataset
res = oversampler$sample(X %>% as.matrix, y)
Xu  = res[[1]] %>% as.data.frame
yu  = res[[2]] %>% as.numeric

mean(yu)

