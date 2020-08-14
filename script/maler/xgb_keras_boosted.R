library(magrittr)
library(dplyr)
source('~/Documents/software/R/projects/tutorials/templib.R')
load_gener()
load_maler()

path = "/Users/nima/Documents/data/miscellaneous/test_train_example"

X_train <- read.csv(path %>% paste('x_train.csv', sep = '/'))
y_train <- read.csv(path %>% paste('y_train.csv', sep = '/')) %>% pull('churn')
X_test  <- read.csv(path %>% paste('x_test.csv', sep = '/'))
y_test  <- read.csv(path %>% paste('y_test.csv', sep = '/')) %>% pull('churn')

xgb = CLS.SCIKIT.XGB(return = 'logit')
xgb$fit(X_train, y_train)
xgb$performance(X_test, y_test)

nr = MAP.MALER.MMS()
nn = CLS.KERAS.DNN(transformers = nr, output_activation = 'softmax', optimiser = 'adamax', loss = 'categorical_crossentropy', layers_dropout = 0.1, first_layer_nodes = 64, epochs = 80)
nn$fit(X_train, y_train)
nn$performance(X_test, y_test)
nn$predict(X_test) %>% range

####### Replicate directly:
a   = layer_input(shape = 48, name = 'nima')
b   = a %>% layer_dense(units = 64, activation = 'relu') %>% layer_dropout(rate = 0.1)
out = b %>% layer_dense(units = 2, activation = 'softmax')
mdl = keras_model(inputs = a, outputs = out)
mdl %>% compile(optimizer = 'adamax', loss = 'categorical_crossentropy')
mdl$fit(nr$predict(X_train) %>% data.matrix, to_categorical(y_train %>% as.integer, 2),
        epochs = as.integer(80), batch_size = as.integer(32), validation_split = 0.2)
mdl$predict(nr$predict(X_test))[,2] %>% correlation(y_test, metric = 'gini')

####### Train on the error of xgboost:
# Today 29 April 2020, I learned a lot of new things about keras deep learning modelling:
# https://keras.io/models/model/
# https://keras.io/layers/merge/
# https://github.com/keras-team/keras/issues/7275

xgb_logit = xgb$predict(X_train) %>% as.matrix
myloss = function(y_true, y_pred){
  K <- backend()
  x <- y_pred[,1]
  g <- y_pred[,2]
  y <- y_true[,1]
  K$mean(y*K$log(1.0 + K$exp(- x - g)) + (1.0 - y)*K$log(1.0 + K$exp(x + g)))
}

myloss_r = function(y_true, y_pred, gradient = xgb_logit[,1]){
  mean(y_true*log(1.0 + exp(- y_pred - gradient)) + (1.0 - y_true)*log(1.0 + exp(y_pred + gradient)))
}

a1   = layer_input(shape = 1, name = 'logit')
a2   = layer_input(shape = 48, name = 'data')
b    = a2 %>% layer_dense(units = 64, activation = 'relu') %>% layer_dropout(rate = 0.1)
o1   = b %>% layer_dense(units = 1, activation = 'linear')
out  = layer_concatenate(list(o1, a1))


# mdl = keras_model(inputs = list(a1, a2), outputs = list(o1, a1))
mdl = keras_model(inputs = list(a1, a2), outputs = out)
mdl %>% compile(optimizer = 'adamax', loss = myloss)
target = to_categorical(y_train %>% as.integer, 2) %>% cbind(NA)
target = y_train %>% as.integer %>% as.matrix %>% cbind(NA)
gradnt = xgb$predict(X_train) %>% data.matrix
mdl$fit(list(gradnt, nr$predict(X_train) %>% data.matrix), target,
        epochs = as.integer(80), batch_size = as.integer(32), validation_split = 0.2)

# For test
xgb_out = xgb$predict(X_test)[,1]
nn_out  = mdl$predict(list(xgb$predict(X_test) %>% data.matrix, nr$predict(X_test) %>% data.matrix))[,1] 
#nn_out  = mdl$predict(list(matrix(), nr$predict(X_test) %>% data.matrix))[,1] 
(nn_out + xgb_out) %>% correlation(y_test, metric = 'gini')
myloss_r(y_test, xgb_out, 0)
myloss_r(y_test, nn_out, xgb_out)

# For train
xgb_out = xgb$predict(X_train)[,1]
nn_out  = mdl$predict(list(xgb$predict(X_train) %>% data.matrix, nr$predict(X_train) %>% data.matrix))[,1] 
(nn_out + xgb_out) %>% correlation(y_train, metric = 'gini')
myloss_r(y_train, xgb_out, 0)
myloss_r(y_train, nn_out, xgb_out)


## Maler Translation:
nn = CLS.KERAS.DNN(epochs = 80, transformers = nr, gradient_transformers = xgb)
# nn$model.fit %>% debug
nn$fit(X_train, y_train)
# nn$predict %>% debug
nn$performance(X_test, y_test)


# Other way round:

nnn  = CLS.KERAS.DNN(epochs = 80, transformers = nr)
xgb2 = CLS.XGBOOST(gradient_transformers = nnn)
xgb2$fit(X_train, y_train)
xgb2$performance(X_test, y_test)

# More complicated:
nnn  = CLS.KERAS.DNN(epochs = 80, transformers = MAP.MALER.ZFS(), gradient_transformers = nn)
xgb2 = CLS.XGBOOST(gradient_transformers = nnn)
xgb2$fit(X_train, y_train)
xgb2$performance(X_test, y_test)

