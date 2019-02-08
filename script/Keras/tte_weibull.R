library(magrittr)
library(keras)

path = '~/Documents/data/miscellaneous/'
data = read.csv(path %>% paste0('tte_dataset.csv'), row.names = 'X')
data$externalRefinance %<>% as.integer

# data %<>% dplyr::filter(status == 1) %>% dplyr::select(-status)
# trindex = sample(data %>% nrow %>% sequence, 2500, replace = F)

trindex = sample(1:10000, 7000, replace = F)
X_train = data[trindex, ] %>% dplyr::select(-id, -tte) %>% as.matrix %>% scale
y_train = data[trindex, 'tte']

X_test = data[- trindex, ] %>% dplyr::select(-id, -tte) %>% as.matrix %>% scale
y_test = data[- trindex, 'tte']


model = build_model(inputs = ncol(X_train), outputs = 2, act3 = 'sigmoid') %>% decompile(loss.weibull.me)

history = model %>% defit(X_train, y_train)

plot(history, metrics = "loss", smooth = FALSE)
#plot(history, metrics = "mean_absolute_error", smooth = FALSE)

model$predict(X_test) %>% pred.weibull %>% loss.mae(y_test)
mean(y_test) %>% loss.mae(y_test)


# compare to normal regression:
model  = lm(y_train ~ X_train)
y_pred = model$coefficients[1] + as.numeric(X_test %*% model$coefficients[-1])
y_pred %>% loss.mae(y_test)
