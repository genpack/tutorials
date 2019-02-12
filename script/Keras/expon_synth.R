library(magrittr)
library(keras)

# build synthetic data:
x1 = rnorm(10000, mean = 124, sd = 13)
x2 = runif(10000, min = -10, max = 10)
x3 = rcauchy(10000, location = 1, scale = 0.3)
X  = data.frame(X1 = x1, X2 = x2, X3 = x3) %>% scale
x1 = X[,'X1']
x2 = X[,'X2']
x3 = X[,'X3']

y  = rexp(10000, rate = 0.01 + sigmoid(2*x1 - 5*x2 + x3 + 3)) %>% floor %>% as.numeric

trindex = sample(1:10000, 7000, replace = F)
X_train = X[trindex, ]
y_train = y[trindex]
X_test  = X[- trindex, ]
y_test  = y[- trindex]

########## if we know the rate, can NN regress it by normal loss?  ##########
model = build_model(act3 = 'relu', inputs = ncol(X_train)) %>% decompile(loss = 'mse')
history = model %>% defit(X_train, r_train)

r_pred = model$predict(X_test)
r_pred %>% loss.mae(r_test)
mean(r_test) %>% loss.mae(r_test)


########## 
model = build_model(act3 = 'sigmoid', inputs = ncol(X_train)) %>% decompile(loss = loss.exp.l)
history = model %>% defit(X_train, y_train)

y_pred = model$predict(X_test) %>% pred.exp.landa
y_pred %>% loss.medae(y_test)
y_pred %>% loss.mae(y_test)
mean(y_test) %>% loss.mae(y_test)
median(y_test) %>% loss.medae(y_test)
