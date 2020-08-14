# Can xgboost get differences between two features:
N = 10000
y = c(1,0) %>% sample(N, replace = T, prob = c(0.2, 0.8))

xx = ifelse(y == 1, 0.5 + runif(N, 0, 0.5), runif(N, 0, 0.5))
plot(xx, col = y + 1)
x1 = runif(N)
x2 = runif(N)
x2 = runif(N)
x3 = runif(N)
x4 = runif(N)
x5 = runif(N)
x6 = xx + x1 + x2 + x3 + x4 + x5
# plot(x1 + x2 + x3 + x4 + x5 - x6, col = y + 1)


mld = data.frame(X1 = x1, X2 = x2, label = y)
for(i in sequence(200)){
  mld[, 'X' %>% paste0(i)] <- runif(10000)
}
mld$X25 = x1
mld$X85 = x2
mld$X32 = x3
mld$X44 = x4
mld$X73 = x5
mld$X7  = x6

ind = nrow(mld) %>% sequence %>% sample(0.7*N)

X_train = mld[ind,] %>% select(-label)
y_train = mld[ind, 'label']
X_test  = mld[- ind,] %>% select(-label)
y_test  = mld[- ind, 'label']


xgb = CLS.SCIKIT.XGB(eta = 0.05, n_estimators = as.integer(200))
xgb$fit(X_train, y_train)
xgb$performance(X_test, y_test)
