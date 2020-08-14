library(magrittr)
source('~/Documents/software/R/packages/maler/R/mltools.R')
source('~/Documents/software/R/packages/maler/R/abstract.R')
source('~/Documents/software/R/packages/maler/R/transformers.R')
source('~/Documents/software/R/packages/maler/R/classifiers.R')


dataset  = read.csv('~/Documents/data/miscellaneous/KaggleBankChurn.csv')
columns  = names(dataset) 
features = columns %-% c('RowNumber', 'CustomerId', 'Surname', 'Exited')

X = dataset[features]
y = dataset %>% pull('Exited')

ind = X %>% nrow %>% sequence %>% sample(6000)
X_train = X[ind,]
y_train = y[ind]

X_test = X[-ind,]
y_test = y[-ind]

  
dm = DUMMIFIER(name = 'D')
nr = NORMALIZER(name = 'N')
id = IDENTITY(name = 'I', transformers = list(nr, dm))

id$fit(X_train, y_train)
Xt  = id$predict(X_train)
Xts = id$predict(X_test)

pos = which(y_train == 1)
neg = which(y_train == 0)
  
prcomp(Xt) -> pr
prcomp(Xt[pos,]) -> pr_pos
predict(pr_pos, Xt) -> dd_pos
predict(pr, Xt) -> dd

dd[, c(1,2)] %>% plot(col = y + 1)
dd_pos[, c(1,2)] %>% plot(col = y + 1)

predict(pr_pos, Xts) -> dds_pos
predict(pr, Xts) -> dds


xgb = CLS.SCIKIT.LR(penalty = 'l1')
xgb$fit(Xt, y_train)
xgb$performance(Xts, y_test, 'gini')

xgb$reset()
xgb$fit(dd_pos, y_train)
xgb$performance(dds_pos, y_test, 'gini')

xgb$reset()
xgb$fit(dd, y_train)
xgb$performance(dds, y_test, 'gini')
