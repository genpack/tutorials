# Can xgboost get differences between two features:
N = 10000

mld = data.frame(X1 = rnorm(N))
for(i in sequence(200)){
  mld[, 'X' %>% paste0(i)] <- runif(10000)
}

mld$label = ifelse((log(mld$X112) - 3*exp(mld$X24) + 2*mld$X36)/exp(mld$X11) > -10*mld$X23, 1, 0)
mld$label = ifelse(sin(mld$X131) + cos(2*mld$X51^2) + 10*mld$X181^3 - (0.1/mld$X56^2) < 1, 1, 0)

ind = nrow(mld) %>% sequence %>% sample(0.7*N)

X_train = mld[ind,] %>% select(-label)
y_train = mld[ind, 'label']
X_test  = mld[- ind,] %>% select(-label)
y_test  = mld[- ind, 'label']


xgb = CLS.SCIKIT.XGB(eta = 0.05, n_estimators = as.integer(200))
xgb$fit(X_train, y_train)
xgb$performance(X_test, y_test)
