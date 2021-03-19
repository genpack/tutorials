library(magrittr)
library(gener)
library(dplyr)
library(smbinning)

source('~/Documents/software/R/packages/maler/R/abstract.R')
source('~/Documents/software/R/packages/maler/R/transformers.R')
source('~/Documents/software/R/packages/maler/R/classifiers.R')

dataset = read.table('~/Documents/data/uci_repo/emg_data_7Jan19/EMG_data_for_gestures-master/01/1_raw_data_13-12_22.03.16.txt', header = T)
dataset$class %<>% as.integer
dataset$Y0 = (dataset$class == 0) %>% as.integer

columns = names(dataset) %>% setdiff(c('time', 'class', 'Y0'))
dataset[, columns] %<>% {.*100000}

sm = SMBINNING()
#sm$fit(X = dataset[columns], y = dataset[, 'Y0'])

dm = DUMMIFIER(transformers = sm)

#dm$fit(X = dataset[columns], y = dataset[, 'Y0'])

#cr = CATREMOVER(transformer = dm())
#X2 = dm$predict(dataset[columns])

lr = CLS.SCIKIT.LR(transformers = dm, penalty = 'l1')

lr$fit(X = dataset[columns], y = dataset[, 'Y0'])
lr$get.performance.cv(X = dataset[columns], y = dataset[, 'Y0'])

dt = SCIKIT.DT(transformer = dm, settings = list(cross_validation = list(reset_transformer = F)))
dt$fit(X = dataset[columns], y = dataset[, 'Y0'])

dt$get.performance.cv(X = dataset[columns], y = dataset[, 'Y0'])
