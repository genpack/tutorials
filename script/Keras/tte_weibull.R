library(magrittr)
library(zeallot)
library(keras)

c(X_train, y_train, X_test, y_test) %<-% read_kaggle_data()

y_train %>% hist(breaks = 100, prob = T)
y_train %>% density %>% lines(col="blue")

a = mean(y_train)
b = mean(y_train^2) - a^2
d = 1 + b/(a^2)

fgama = function(z) gamma(2*z + 1)/(gamma(z+1)^2) - d
ggama = function(z) (fgama(z + eps) - fgama(z))/eps
z     = eqSolver1d(fgama, ggama, 1)
shape = 1.0/z
landa = a/gamma(1 + z)
  
x = 0.01*(0:(100*max(y_test))); lines(x, pdf.weibull(x, landa, shape), col="red")
rweibull(length(y_train), shape = shape, scale = landa) %>% density %>% lines(col="green")

model = build_model(inputs = ncol(X_train), outputs = 1, act3 = 'relu') %>% decompile(loss.weibull.linv)

history = model %>% defit(X_train, y_train)

plot(history, metrics = "loss", smooth = FALSE)
#plot(history, metrics = "mean_absolute_error", smooth = FALSE)

y_pred = model$predict(X_test) %>% pred.weibull.linv
loss.plot(y_pred, y_test)
loss.summary(y_pred, y_test)


# compare to normal regression:
model  = lm(y_train ~ X_train)
y_pred = model$coefficients[1] + as.numeric(X_test %*% model$coefficients[-1])
loss.summary(y_pred, y_test)
