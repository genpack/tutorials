library(magrittr)
library(keras)

path = '~/Documents/data/miscellaneous/'
data = read.csv(path %>% paste0('tte_dataset.csv'), row.names = 'X')
data$externalRefinance %<>% as.integer

trindex = sample(1:10000, 7000, replace = F)
X_train = data[trindex, c(-1, -54)] %>% scale
y_train = data[trindex, 54]

X_test = data[- trindex, c(-1, -54)] %>% scale
y_test = data[- trindex, 54]

build_model = function(layer1 = 64, layer2 = 64, inputs = 1, outputs = 1, dropout = 0.1){
  model <- keras_model_sequential() %>%
    layer_dense(units = layer1, activation = "relu", input_shape = inputs) %>%
    layer_dropout(rate = dropout) %>% 
    layer_dense(units = layer2, activation = "relu") %>%
    layer_dropout(rate = dropout) %>% 
    layer_dense(units = outputs)
}

model = build_model(inputs = dim(X_train)[2], outputs = 2) %>% compile(
  loss = "mse",
  optimizer = optimizer_rmsprop(),
  metrics = list("mean_absolute_error")
)
  
summary(model)

print_dot_callback <- callback_lambda(
  on_epoch_end = function(epoch, logs) {
    cat('epoch:', epoch, ' loss: ', logs$loss, 'validation loss:', logs$val_loss, '\n')
  }
)

history <- model %>% fit(
  X_train,
  y_train,
  epochs = 30,
  validation_split = 0.2,
  verbose = 0,
  callbacks = list(print_dot_callback)
)

library(ggplot2)
plot(history, metrics = "mean_absolute_error", smooth = FALSE)

y_pred = model$predict(X_test)
cbind(y_pred, y_test)
abs(y_pred - y_test) %>% mean

######### let's train exponential with two parameters shape and scale:
myloss = function(y_true, y_pred){
  K <- backend()
  landa = 0.5*(K$abs(y_pred[,1]) + y_pred[,1]) + 0.00001
  # landa = K$pow(y_pred[,1] + 0.01, -1)
  
  # x     = 0.5*(K$abs(y_true - y_pred[,2]) + y_true - y_pred[,2]) + 0.00001
  x = (y_true - y_pred[,2]) + 0.00001
  # K$mean(K$pow(K$pow(y_pred, -1) - y_true, 2))
  K$mean(landa*x - K$log(landa))
  # K$mean( K$abs( K$log( K$relu(y_true *1000 ) + 1 ) - K$log( K$relu(y_pred*1000 ) + 1)))
}

model = build_model(layer1 = 64, layer2 = 64, inputs = dim(X_train)[2], outputs = 2) %>% compile(
  loss = myloss,
  optimizer = optimizer_rmsprop(),
  metrics = list("mean_absolute_error")
)

summary(model)

history <- model %>% fit(
  X_train,
  y_train,
  epochs = 30,
  batch_size = 32,
  validation_split = 0.2,
  verbose = 0,
  callbacks = list(print_dot_callback)
)
#  Now let's train for exponential distribution parameters
plot(history, metrics = "loss", smooth = FALSE)
#plot(history, metrics = "mean_absolute_error", smooth = FALSE)

params = model$predict(X_test)
y_pred = (1.0/params[,1]) + params[,2]

abs(y_pred - y_test) %>% mean
