# Can xgboost get combinations of categorical and numericals:
N = 10000

mld = data.frame(X1 = rnorm(N))
for(i in sequence(200)){
  mld[, 'X' %>% paste0(i)] <- rexp(10000, 1/i)
}


mld$C1  = sample(1:12, size = N, replace = T)
mld$X34 = rnorm(N, mean = 1/runif(N), sd = 6)

mld %>% group_by(C1) %>% summarise(rate = mean(X34)) -> map

mld %>% left_join(map, by = 'C1') %>% pull(rate) -> xx

mld$label = ifelse(mld$X134/(xx + mld$X31) > 1, 1, 0)

ind = nrow(mld) %>% sequence %>% sample(0.7*N)

X_train = mld[ind,] %>% select(-label)
y_train = mld[ind, 'label']
X_test  = mld[- ind,] %>% select(-label)
y_test  = mld[- ind, 'label']


xgb = CLS.SCIKIT.XGB(eta = 0.05, n_estimators = as.integer(200))
xgb$fit(X_train, y_train)
xgb$performance(X_test, y_test)

