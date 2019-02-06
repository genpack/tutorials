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

  
model = build_model(inputs = dim(X_train)[2]) %>% compile(
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
# normal regression:
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
abs(y_test - y_pred) %>% mean

# exponential regression:
model = build_model(inputs = dim(X_train)[2]) %>% compile(
  loss = "mse",
  optimizer = optimizer_rmsprop(),
  metrics = list("mean_absolute_error")
)

history <- model %>% fit(
  X_train,
  10000.0/(1 + y_train),
  epochs = 30,
  validation_split = 0.2,
  batch_size = 30,
  verbose = 0,
  callbacks = list(print_dot_callback)
)

library(ggplot2)
plot(history, metrics = "loss", smooth = FALSE)

y_pred = (10000.0/abs(model$predict(X_test))) - 1 
abs(y_test - y_pred) %>% mean

hist(y_pred, breaks = 100) # very steep exponential
abs(model$predict(X_test)) %>% hist(breaks = 100) # this must look uniform!


# logarithmic regression:
model = build_model(inputs = dim(X_train)[2]) %>% compile(
  loss = "mse",
  optimizer = optimizer_rmsprop(),
  metrics = list("mean_absolute_error")
)

history <- model %>% fit(
  log(abs(X_train)),
  log(y_train + 1),
  epochs = 30,
  validation_split = 0.2,
  batch_size = 30,
  verbose = 0,
  callbacks = list(print_dot_callback)
)

library(ggplot2)
plot(history, metrics = "loss", smooth = FALSE)

y_pred = exp(model$predict(log(abs(X_test)))) - 1 
abs(y_test - y_pred) %>% mean

hist(y_pred, breaks = 100) # very steep exponential
abs(model$predict(X_test)) %>% hist(breaks = 100) # this must look uniform!
