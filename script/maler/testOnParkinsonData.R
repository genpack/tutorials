library(magrittr)
library(gener)
library(smbinning)

dataset = read.table('~/Documents/data/uci_repo/emg_data_7Jan19/EMG_data_for_gestures-master/01/1_raw_data_13-12_22.03.16.txt', header = T)
dataset$class %<>% as.integer
dataset$Y0 = (dataset$class == 0) %>% as.integer




sm = SMBINNING()

columns = names(dataset) %>% setdiff(c('time', 'class', 'Y0'))
dataset[, columns] %<>% {.*100000}

lr = SCIKIT.LR(transformer = DUMMIFIER(transformer = SMBINNING()))

lr$fit(X = dataset[columns], y = dataset[, 'Y0'])
