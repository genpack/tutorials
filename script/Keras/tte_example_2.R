library(magrittr)
library(keras)

c(X_train, y_train, X_test, y_test) %<-% read_kaggle_data()


model = build_model(inputs = dim(X_train)[2]) %>% decompile

# normal regression:
history <- model %>% defit(X_train, y_train)

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
