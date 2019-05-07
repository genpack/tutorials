library(magrittr)
library(dplyr)
library(gener)
library(smbinning)

source('~/Documents/software/R/packages/maler/R/abstract.R')
source('~/Documents/software/R/packages/maler/R/transformers.R')
source('~/Documents/software/R/packages/maler/R/classifiers.R')
source('~/Documents/software/R/packages/maler/R/regressors.R')
source('~/Documents/software/R/packages/maler/R/gentools.R')
source('~/Documents/software/R/packages/maler/R/mltools.R')

dataset = read.table('~/Documents/data/uci_repo/emg_data_7Jan19/EMG_data_for_gestures-master/01/1_raw_data_13-12_22.03.16.txt', header = T)
dataset$class %<>% as.integer
dataset$Y0 = (dataset$class == 0) %>% as.integer

columns = names(dataset) %>% setdiff(c('time', 'class', 'Y0'))
dataset[, columns] %<>% {.*100000}

dataset[columns] -> X
dataset %>% pull(Y0) -> y

g = GENETIC()
debug(g$createFeatures)

g$createFeatures(X, y)
g$featlist
