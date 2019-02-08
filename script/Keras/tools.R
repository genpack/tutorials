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

pred.exp.landa = function(output){
  return(1.0/output)
}

pred.exp.scale = function(output){
  return(output)
}

pred.weibull = function(output){
  landa    = output[,1] + eps
  shapeinv = 1.0/(output[,2] + eps)
  landa*gamma(1 + shapeinv)
}


pred.weibull.lp = function(output){
  # z: 1/shape = 1/k = 1/(p + 1)
  landa = output[,1] + eps
  z = 1.0/(output[,2] + 1.0)
  landa*gamma(1 + z)
}

### losses:
loss.mae = function(y_true, y_pred){
  abs(y_pred - y_true) %>% mean(na.rm = T)
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

loss.weibull.me = function(y_true, y_pred){
  loglanda = K$log(y_pred[,1] + eps)
  shape    = y_pred[,2] + eps
  logx     = K$log(y_true + eps) - loglanda
  K$mean(K$exp(shape*logx) + loglanda - K$log(shape) - (shape - 1)*logx)
}

loss.weibull.me.r = function(y_true, y_pred){
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

