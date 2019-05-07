library(magrittr)
library(keras)

# build synthetic data:
x1 = rnorm(10000, mean = 124, sd = 13)
x2 = runif(10000, min = -10, max = 10)
x3 = rexp(10000, rate = 0.001)

y  = rweibull(10000, shape = 0.01*x1 - 0.1*x2 + 0.001*x3 + 2, scale = 0.2*x1 - 0.5*x2 + 0.01*x3 - 1)

X = data.frame(X1 = x1, X2 = x2, X3 = x3)
trindex = sample(1:10000, 7000, replace = F)
X_train = X[trindex, ] %>% as.matrix
y_train = y[trindex]
X_test  = X[- trindex, ] %>% as.matrix
y_test  = y[- trindex]

# verify (assume you have the 100% accurate model):
output = data.frame(shape = 0.01*X_test[,'X1'] - 0.1*X_test[,'X2'] + 0.001*X_test[,'X3'] + 2, scale = 0.2*X_test[,'X1'] - 0.5*X_test[,'X2'] + 0.01*X_test[,'X3'] - 1)
landa  = output[,'scale']
k      = output[,'shape']
z      = 1.0/k
y_pred = landa*gamma(1 + z)
abs(y_pred - y_test) %>% mean(na.rm = T)
abs(mean(y_test, na.rm = T) - y_test) %>% mean(na.rm = T)

# verify with normal regression:
model  = lm(y_train ~ X_train)
stats::predict(model, X_test)
y_pred = -1.46151 +  0.18341*X_test[,'X1'] - 0.48370*X_test[,'X2'] + 0.01013*X_test[,'X3'] 
y_pred %>% loss.mae(y_test)


### modeling
model = build_model(inputs = ncol(X_train), outputs = 2, act3 = 'sigmoid') %>% decompile(loss.weibull.me)
history = model %>% defit(X_train, y_train)

plot(history, metrics = "loss", smooth = FALSE)
#plot(history, metrics = "mean_absolute_error", smooth = FALSE)

model$predict(X_test) %>% pred.weibull %>% loss.mae(y_test)
mean(y_test, na.rm = T) %>% loss.mae(y_test)
