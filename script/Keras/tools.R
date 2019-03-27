K   = backend()
eps = 0.0001

build_model_simple = function(inputs = 1, outputs = 2, dropout = 0.1, activation = 'linear'){
  K = backend()
  model <- keras_model_sequential() %>%
    layer_dense(units = outputs, activation = activation, input_shape = inputs)
  return(model)
}

build_model = function(layer1 = 64, layer2 = 32, inputs = 1, outputs = 1, dropout = 0.1, act1 = 'linear', act2 = 'relu', act3 = 'sigmoid', show = T){
  model = keras_model_sequential() %>%
    layer_dense(units = layer1, activation = act1, input_shape = inputs) %>%
    layer_dropout(rate = dropout) %>% 
    layer_dense(units = layer2, activation = act2) %>%
    layer_dropout(rate = dropout) %>% 
    layer_dense(units = outputs, activation = act3)
  if(show){summary(model)}
  return(model)
}

print_callback <- callback_lambda(
  on_epoch_end = function(epoch, logs) {
    cat('epoch:', epoch, ' loss: ', logs$loss, 'validation loss:', logs$val_loss, '\n')
  }
)

defit = function(model, X, y){
  model %>% fit(X, y, epochs = 30, batch_size = 32, validation_split = 0.2, verbose = 0, callbacks = list(print_callback)) 
}

decompile = function(model, loss = 'mse', metric = "mean_absolute_error"){
  model %>% compile(
    loss = loss,
    optimizer = optimizer_rmsprop(),
    metrics = list(metric)
  )
}

# optimization using steepest descent method:
optim.sdm = function(fun, grad, w0, ...){
  w   = w0
  f0  = fun(w0, ...)
  
  k   = 1.0
  
  imp = Inf
  cnt = 0
  while(abs(imp) > eps & (cnt < 1000) & (k > eps)){
    g   = grad(w, ...)
    w   = w - k*g
    f   = fun(w, ...)
    imp = f0 - f
    if(imp < 0){
      # cat('imp = ', imp, '\n')
      w = w + k*g
      f = f0
      k = 0.5*k
      imp = Inf
    } else {
      cnt = cnt + 1
      cat('Iter: ', cnt, '--> loss value: ', f, '--> improvement: ', imp, '--> step size: ', k, '\n')
      f0  = f
      k   = k*2
    }
    # cat('cnt: ', cnt, '--> obj = ', f, '--> imp = ', imp, '--> k = ', k, '--> g = ', g, '--> w = ', w, '\n')
  }
  return(w)
}

convert.exp.landa = function(output){
  return(1.0/output)
}

convert.exp.scale = function(output){
  return(output)
}

convert.weibull = function(output){
  landa    = output[,1] + eps
  shapeinv = 1.0/(output[,2] + eps)
  landa*gamma(1 + shapeinv)
}


convert.weibull.lp = function(output){
  # z: 1/shape = 1/k = 1/(p + 1)
  landa = output[,1] + eps
  z = 1.0/(output[,2] + 1.0)
  landa*gamma(1 + z)
}

### losses:
loss.mae = function(y_true, y_pred){
  abs(y_pred - y_true) %>% mean(na.rm = T)
}

loss.medae = function(y_true, y_pred){
  abs(y_pred - y_true) %>% median(na.rm = T)
}

loss.weibull.bz = function(y_true, y_pred){
  K <- backend()
  b = y_pred[,1] + eps
  z = y_pred[,2]
  x = y_true + eps
  
  -K$mean(K$log(b) + K$log(z + 1) + z*K$log(x) - b*K$pow(x, z + 1))
}

loss.weibull.bz.geo = function(y_true, y_pred){
  K <- backend()
  b = y_pred[,1] + eps
  z = y_pred[,2]
  x = y_true + eps
  u = K$pow(x, 1 - k)
  v = K$exp(K$pow(x, k))
  w = b*k
  K$prod(u*v*w)
}

loss.weibull.wtte = function(y_true, y_pred){
  K <- backend()
  x = (y_true + eps)/y_pred[,1]
  -K$mean(K$log(y_pred[,2]) + y_pred[,2]*K$log(x) - K$pow(x, y_pred[,2]))
}

loss.weibull.ls = function(y_true, y_pred){
  loglanda = K$log(y_pred[,1] + eps)
  shape    = y_pred[,2] + eps
  logx     = K$log(y_true + eps) - loglanda
  K$mean(K$exp(shape*logx) + loglanda - K$log(shape) - (shape - 1)*logx)
}

loss.weibull.lp.inv = function(y_true, y_pred){
  # linv: 1/landa or inverse of scale
  # shape: given as global variable 
  loglinv  = K$log(y_pred + eps)
  shape    = 1.044835
  logx     = K$log(y_true + eps) + loglinv
  K$mean(K$pow(x, shape) - loglinv - K$log(shape) - (shape - 1)*logx)
}

loss.weibull.ls.r = function(y_true, y_pred){
  loglanda = log(y_pred[,1] + eps)
  shape    = y_pred[,2] + eps
  logx     = log(y_true + eps) - loglanda
  mean(exp(shape*logx) + loglanda - log(shape) - (shape - 1)*logx)
}

loss.weibull.lp = function(y_true, y_pred){
  # l: landa or scale
  # p: shape - 1 = k - 1
  loglanda = K$log(y_pred[,1] + eps)
  p        = y_pred[,2]
  logx     = K$log(y_true + eps) - loglanda
  K$mean(K$exp((p + 1)*logx) + loglanda - K$log(p + 1) - p*logx)
}

loss.exp.landa = function(y_true, y_pred){
  landa = y_pred
  x     = y_true
  K$mean(landa*x - K$log(landa))
}

loss.exp.l = function(y_true, y_pred){
  landa = y_pred + eps
  x     = y_true + eps
  K$mean(landa*x - K$log(landa))
}

sigmoid = function(x) {1.0/(1.0 + exp(-x))}
sigprim = function(x) {a = exp(-x); return(a/((1.0 + a)^2))}

read_kaggle_data = function(path = '~/Documents/data/miscellaneous/'){
  data = read.csv(path %>% paste0('tte_dataset.csv'), row.names = 'X')
  data$externalRefinance %<>% as.integer
  
  trindex = sample(1:10000, 7000, replace = F)
  X_train = data[trindex,] %>% dplyr::select(-id, -status, -tte) %>% scale
  y_train = data[trindex, 'tte']
  
  X_test = data[- trindex, ] %>% dplyr::select(-id, -status, -tte) %>% scale
  y_test = data[- trindex, 'tte']
  
  list(X_train = X_train, y_train = y_train, X_test = X_test, y_test = y_test)
}


loss.plot = function(y_pred, y_true){
  er  = abs(y_pred - y_true)
  ss  = er %>% quantile
  w25 = er < ss['25%'] 
  w50 = er < ss['50%']
  w75 = er < ss['75%']
  col = rep('red', length(er))
  col[w25] <- 'green'
  col[w50 & !w25] <- 'blue'
  col[w75 & !w50] <- 'yellow'
  
  #plot(y_pred - y_true, col = col)
  plot(y_pred - y_true, col = col)
  N = length(col)
  # cat('Green : ', sum(col == 'green')/N, '\n')
  # cat('Blue  : ', sum(col == 'blue')/N, '\n')
  # cat('Yellow: ', sum(col == 'yellow')/N, '\n')
  # cat('Red   : ', sum(col == 'red')/N, '\n')
}


loss.summary = function(y_pred, y_true){
  cat('\n', 'Summary of loss: ', '\n', '\n')
  cat('Mean Absolute Error   : ', loss.mae(y_pred, y_true), '\n')
  cat('Median Absolute Error : ', loss.medae(y_pred, y_true), '\n')
  cat('Error Distribution    : ', '\n')
  summary(y_pred, y_true)
  ss  = y_true %>% quantile
  
  er  = abs(y_pred - y_true)
  n25 = sum(er < ss['25%'])
  n50 = sum(er < ss['50%'])
  n75 = sum(er < ss['75%'])
  N = length(er)
  
  cat(n25, ' (', round(n25*100/N),'%)', ' of errors are less than ', ss['25%'], '\n')
  cat(n50, ' (', round(n50*100/N),'%)', ' of errors are less than ', ss['50%'], '\n')
  cat(n75, ' (', round(n75*100/N),'%)', ' of errors are less than ', ss['75%'], '\n')
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

objfun.exp.lm = function(w, X, y){
  landa = (X %*% w) %>% as.numeric %>% sigmoid
  (landa*y - log(landa)) %>% mean(na.rm = T)
}

objgrad.exp.lm = function(w, X, y){
  a  = (X %*% w) %>% as.numeric %>% sigmoid
  b  = (X %*% w) %>% as.numeric %>% sigprim
  d  = b*(y - (1/a))
  colMeans(d*X, na.rm = T)
}

lm.exp = function(X, y, w0 = NULL){
  if(is.null(w0)){w0 = rep(0, 1 + ncol(X))}
  X   = cbind(1, X) %>% as.matrix
  optim.sdm(objfun.exp.lm, objgrad.exp.lm, w0, X, y)
}

predict.lm.exp = function(w, X){
  X   = cbind(1, X) %>% as.matrix
  (X %*% w) %>% as.numeric %>% sigmoid
}

predict.lm = function(w, X){
  X   = cbind(1, X) %>% as.matrixø
  (X %*% w) %>% as.numeric
}