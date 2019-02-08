library(magrittr)
library(keras)

path = '~/Documents/data/miscellaneous/'
data = read.csv(path %>% paste0('tte_dataset.csv'), row.names = 'X')
data$externalRefinance %<>% as.integer

trindex = sample(1:10000, 7000, replace = F)
X_train = data[trindex, c(-1, -54)] %>% scale
y_train = data[trindex, 54]

X_test = data[- trindex, c(-1, -54)] %>% scale
y_test = data[- trindex, 54]

model   <- build_model(inputs = dim(X_train)[2], act3 = 'sigmoid') %>% decompile(loss = loss.exp.landa)
history <- model %>% defit(X = X_train, y = y_train)

plot(history, metrics = "loss", smooth = FALSE)

y_pred = pred.exp.landa(model$predict(X_test))

# y_pred = model$predict(X_test)
# y_pred = mean(y_test, na.rm = T)


loss.mae(y_pred, y_test)
