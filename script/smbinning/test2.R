library(dplyr)
library(magrittr)
library(smbinning)


filename = '~/Documents/data/miscellaneous/KaggleBankChurn.csv'
data     = read.csv(filename)
data     = data %>% select(- RowNumber, - CustomerId, - Surname)

res = smbinning(data, y = 'Exited', x = 'Age')
d2  = smbinning.gen(data, res, chrname = 'ageBin') %>% select(-Age)

# Categorical (Fails):
#res = smbinning.factor(data, y = 'Exited', x = 'Geography')
#d3  = smbinning.gen(data, res, chrname = 'geoBin')



# test to see if binning improves prediction:

library(reticulate)
use_python("/Users/nima/anaconda3/bin/python")
pandas = import('pandas')

module_lm = import('sklearn.linear_model')

lr = module_lm$LogisticRegression(penalty = 'l1',solver = 'liblinear')

# performance evaluation:

# module_ms  = import('sklearn.model_selection')
# cv         = module_ms$ShuffleSplit(n_splits = 10, test_size = 0.4, random_state = 0)
# module_ms$cross_val_score(lr, X %>% r_to_py(convert = T), y %>% r_to_py(convert = T), scoring = 'roc_auc', cv = cv)

crossValidate = function(model, data, ne = 10){
  N  = nrow(data)
  scores = c()
  X  = data %>% select(-Exited)
  y  = data %>% pull(Exited)
  X  = pandas$get_dummies(X)
  
  for (i in sequence(ne)){
    trindex = data %>% nrow %>% sequence %>% sample(size = floor(0.7*N))
    
    X_train = X[trindex, ]
    y_train = y[trindex]
    X_test  = X[- trindex,]
    y_test  = y[- trindex]
    
    lr$fit(X_train, y_train)
    scores = c(scores, lr$score(X_test, y_test))
  }
  return(scores)
}

crossValidate(lr, data)

crossValidate(lr, d2)



