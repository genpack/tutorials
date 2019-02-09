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

######### verify 100% accurate model: #########
r = sigmoid(2*x1 - 5*x2 + x3 + 3)
r_train = r[trindex]
r_test  = r[- trindex]

pred.exp.landa(r_test) %>% loss.mae(y_test)
pred.exp.landa(r_test) %>% loss.medae(y_test)
abs(pred.exp.landa(r_test) - y_test) %>% summary
median(y_test) %>% loss.medae(y_test)

######### verify 2: #########
r = runif(10000, 0, 1)
rexp(10000, rate = 1.0/r) %>% loss.mae(1/r)
rexp(10000, rate = 1.0/r) %>% loss.medae(1/r)
mean(1/r) %>% loss.medae(1/r) 
mean(1/r) %>% loss.mae(1/r) 


X  = cbind(1, x1, x2, x3)
  
objfun = function(w, X, y){
  landa = (X %*% w) %>% as.numeric %>% sigmoid
  (landa*y - log(landa)) %>% mean(na.rm = T)
}

objgrad = function(w, X, y){
  a  = (X %*% w) %>% as.numeric %>% sigmoid
  b  = (X %*% w) %>% as.numeric %>% sigprim
  d  = b*(y - (1/a))
  colMeans(d*X, na.rm = T)
}

testgrad = function(fun, grad, w, ...){
  g  = grad(w, ...)
  gp = g
  for(i in sequence(length(w))){
    w1 = w
    w1[i] = w1[i] + eps
    gp[i] = (fun(w1, ...) - fun(w, ...))/eps
  }
  cat('\n', g, '\n', gp)
}

optim = function(fun, grad, w0, ...){
  w   = w0
  f0  = objfun(w0, ...)
  
  k   = 1.0
  
  imp = Inf
  cnt = 0
  while(abs(imp) > eps & (cnt < 1000) & (k > eps)){
    cnt = cnt + 1
    g   = objgrad(w, ...)
    w   = w - k*g
    f   = objfun(w, ...)
    imp = f0 - f
    if(imp < 0){
      # cat('imp = ', imp, '\n')
      w = w + k*g
      f = f0
      k = 0.5*k
      imp = Inf
    } else {
      f0  = f
      k   = k*2
    }
    cat('cnt: ', cnt, '--> obj = ', f, '--> imp = ', imp, '--> k = ', k, '--> g = ', g, '--> w = ', w, '\n')
  }
  return(w)
}

train = function(X, y){
  w0  = c(0, 0, 0, 0)
  X   = cbind(1, X) %>% as.matrix
  optim(objfun, objgrad, w0, X, y)
}

predict = function(w, X){
  X   = cbind(1, X) %>% as.matrix
  (X %*% w) %>% as.numeric %>% sigmoid
}


w = train(X_train, y_train)

predict(w, X_test) %>% pred.exp.landa %>% loss.medae(y_test)
table(y)
cbind()
predict(w, X_test) %>% pred.exp.landa %>% head(10)
head(y_test)
