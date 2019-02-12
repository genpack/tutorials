library(magrittr)
library(zeallot)

c(X_train, y_train, X_test, y_test) %<-% read_kaggle_data()
# read_kaggle_data() %>% list2env(.GlobalEnv)

# keras
model   <- build_model(inputs = dim(X_train)[2], act3 = 'sigmoid') %>% decompile(loss = loss.exp.landa)
history <- model %>% defit(X = X_train, y = y_train)
plot(history, metrics = "loss", smooth = FALSE)
y_pred = convert.exp.landa(model$predict(X_test))
loss.mae(y_pred, y_test)
loss.medae(y_pred, y_test)

testgrad(objfun.exp.lm, objgrad.exp.lm, rep(1, ncol(X_train)), X_train, y_train)
w = train.exp.lm(X_train, y_train)

predict.exp.lm(w, X_test) %>% pred.exp.landa %>% loss.summary(y_test)


