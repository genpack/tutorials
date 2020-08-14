library(magrittr)
library(keras)

c(X_train, y_train, X_test, y_test) %<-% read_kaggle_data()

model   <- build_model(inputs = dim(X_train)[2], act3 = 'sigmoid') %>% decompile(loss = loss.exp.landa)
history <- model %>% defit(X = X_train, y = y_train)

plot(history, metrics = "loss", smooth = FALSE)

y_pred = convert.exp.landa(model$predict(X_test))

# y_pred = model$predict(X_test)
# y_pred = mean(y_test, na.rm = T)


loss.mae(y_pred, y_test)
loss.medae(y_pred, y_test)

