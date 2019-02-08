library(magrittr)
library(keras)

# build synthetic data:
x1 = rnorm(10000, mean = 124, sd = 13)
x2 = runif(10000, min = -10, max = 10)
x3 = rcauchy(10000, location = 1, scale = 0.3)

y  = rweibull(10000, shape = 0.01*x1 - 0.1*x2 + 0.001*x3 + 2, scale = 0.2*x1 - 0.5*x2 + 0.01*x3 - 1)

X = data.frame(X1 = x1, X2 = x2, X3 = x3)
trindex = sample(1:10000, 7000, replace = F)
X_train = X[trindex, ] %>% scale
y_train = y[trindex]
X_test  = X[- trindex, ] %>% scale
y_test  = y[- trindex]



# y_pred = data.frame(scale = 0.2*x1 - 0.5*x2 + 0.01*x3 - 1, shape = 0.01*x1 - 0.1*x2 + 0.001*x3 + 1) %>% as.matrix
# loss.weibull.me.r(y, y_pred)

model = build_model(inputs = ncol(X_train), outputs = 2, act3 = 'sigmoid') %>% decompile(loss.weibull.me)
history = model %>% defit(X_train, y_train)

plot(history, metrics = "loss", smooth = FALSE)
#plot(history, metrics = "mean_absolute_error", smooth = FALSE)

model$predict(X_test) %>% pred.weibull %>% loss.mae(y_test)
mean(y_test, na.rm = T) %>% loss.mae(y_test)

