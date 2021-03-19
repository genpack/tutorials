# default_templates:

default_templates = list()

#### Classifiers: ####
default_templates$CLS.SCIKIT.XGB =
  list(
    class = 'CLS.SCIKIT.XGB',
    transformers = list(
      list(classes = c('CLS.SCIKIT.XGB', 'CLS.XGBOOST'), probability = 0.02),
      list(classes = c('CLS.SCIKIT.LR', 'CLS.KERAS.DNN'), probability = 0.05),
      list(classes = 'ENC.MALER.FE', probability = 0.1),
      list(classes = c('ENC.CATEGORY_ENCODERS.CATB', 'ENC.CATEGORY_ENCODERS.HLMRT', 'ENC.CATEGORY_ENCODERS.JSTN'), probability = 0.01),
      list(classes = 'MAP.MALER.IDT', probability = 0.2),
      list(classes = c('MAP.PYLMNN.LMNN', 'MAP.STATS.PCA'), probability = 0.02),
      list(classes = 'FET.MALER.D2MUL', probability = 0.01)),

    return = c('logit', 'logit', 'probs'),
    n_jobs = as.integer(3),
    colsample_bytree = list(fun = 'runif'),
    gamma = list(fun = 'runif', min = 1, max = 10),
    eta = list(fun = 'runif', min = 0.05, max = 0.5),
    n_estimators = as.integer(5:100),
    max_depth = as.integer(2:20),
    min_child_weight = as.integer(2:10),
    subsample = list(fun = 'runif', min = 0, max = 1))

default_templates$CLS.XGBOOST =
  list(
    class = 'CLS.XGBOOST',
    transformers = default_templates[['CLS.SCIKIT.XGB']]$transformers,
    return = c('logit', 'logit', 'probs'),
    nthread = as.integer(3),
    colsample_bytree = list(fun = 'runif'),
    gamma = list(fun = 'runif', min = 1, max = 10),
    eta = list(fun = 'runif', min = 0.05, max = 0.5),
    nrounds = 5:100,
    max_depth = 2:20,
    min_child_weight = 2:10,
    scale_pos_weight = 2:10,
    subsample = list(fun = 'runif'))

list(
  class = 'CLS.SCIKIT.LR',
  pass = list(type = c('numeric', 'ordinal')),
  transformers = list(
    list(classes = c('CLS.SCIKIT.XGB', 'CLS.XGBOOST'), probability = 0.5),
    list(classes = c('CLS.SCIKIT.LR', 'CLS.KERAS.DNN'), probability = 0.01),
    list(classes = 'ENC.MALER.FE', probability = 0.2),
    list(classes = c('ENC.CATEGORY_ENCODERS.CATB', 'ENC.CATEGORY_ENCODERS.HLMRT', 'ENC.CATEGORY_ENCODERS.JSTN'), probability = 0.2),
    list(classes = 'MAP.MALER.IDT', probability = 0.01),
    list(classes = c(rep('MAP.MALER.MMS', 4), 'MAP.MALER.ZFS'), probability = 0.6),
    list(classes = c(rep('BIN.MALER.OBB', 7), rep('BIN.SMBINNING.OB', 3)), probability = 0.3),
    list(classes = c(rep('ENC.FASTDUMMIES.OHE',4), 'ENC.SCIKIT.OHE'), probability = 0.6),
    list(classes = c('MAP.PYLMNN.LMNN', rep('MAP.STATS.PCA',9)), probability = 0.1),
    list(classes = 'FET.MALER.D2MUL', probability = 0.1)),
  feature_sample_ratio = list(fun = 'runif', min = 0.1, max = 0.5),
  # feature_sample_size  = 5:80,
  penalty = c(rep('l1',5), 'l2'), return = c('logit', 'logit', 'logit', 'probs')) -> default_templates$CLS.SCIKIT.LR

list(
  class = 'CLS.KERAS.DNN', weight = 0.05, return_logit = c(T, T, F),
  transformers = default_templates[['CLS.SCIKIT.LR']]$transformers,
  num_layers = 1:5,
  first_layer_nodes = 1:1024,
  layer_nodes_ratio = 0.2*(1:10),
  layers_activation = c('relu', 'linear'),
  layers_dropout = list(fun = 'rnorm', mean = 0.3, sd = 0.02),
  initializer_seed = 1:1000,
  kernel_regularization_penalty_l1 = c(rep(0, 10), 0.04*(1:25)),
  kernel_regularization_penalty_l2 = c(rep(0, 10), 0.04*(1:25)),
  learning_rate = list(fun = 'runif'),
  optimizer = c('adadelta', 'adagrad', 'adam', 'adamax', 'nadam', 'rmsprop', 'sgd')) -> default_templates[['CLS.KERAS.DNN']]

#### Mappers: ####
# todo:
# MAP.SCIKIT.QT

list(
  class = 'MAP.MALER.MMS',
  pass = list(type = c('numeric', 'ordinal')),
  transformers = list(
    list(classes = 'FET.MALER.D2MUL', probability = 0.1),
    list(classes = 'ENC.MALER.FE', probability = 0.2)
)) -> default_templates[['MAP.MALER.MMS']]

default_templates[['MAP.MALER.ZFS']] = default_templates[['MAP.MALER.MMS']]
default_templates[['MAP.MALER.ZFS']]$class = 'MAP.MALER.ZFS'

default_templates[['MAP.SCIKIT.ZFS']] = default_templates[['MAP.MALER.MMS']]
default_templates[['MAP.SCIKIT.ZFS']]$class = 'MAP.SCIKIT.ZFS'

default_templates[['MAP.SCIKIT.MMS']] = default_templates[['MAP.MALER.MMS']]
default_templates[['MAP.SCIKIT.MMS']]$class = 'MAP.SCIKIT.MMS'

list(
  class = 'MAP.SCIKIT.NRM',
  pass = list(type = c('numeric', 'ordinal')),
  transformers = default_templates[['MAP.MALER.MMS']]$transformers) -> default_templates[['MAP.SCIKIT.NRM']]


default_templates[['MAP.STATS.PCA']] =
  list(class = 'MAP.STATS.PCA',
       pass = list(type = c('numeric', 'ordinal')),
       transformers = list(
         list(classes = 'FET.MALER.D2MUL', probability = 0.1),
         list(classes = 'ENC.MALER.FE', probability = 0.2)
       ),
       num_components = 5:30)


default_templates[['MAP.MALER.IDT']] = list(class = 'MAP.MALER.IDT')
#### Encoders: ####
transformers_for_encoders = list(
  list(classes = c(rep('BIN.KMEANS.KMC',3), 'BIN.SMBINNING.OB', rep('BIN.MALER.GROUPER', 6)), probability = 0.3)
)

default_templates[['ENC.CATEGORY_ENCODERS.JSTN']]  =  list(class = 'ENC.CATEGORY_ENCODERS.JSTN', pass = list(type = c('nominal', 'ordinal')), transformers = transformers_for_encoders)
default_templates[['ENC.CATEGORY_ENCODERS.CATB']]  =  list(class = 'ENC.CATEGORY_ENCODERS.CATB', pass = list(type = c('nominal', 'ordinal')), transformers = transformers_for_encoders)
default_templates[['ENC.CATEGORY_ENCODERS.HLMRT']] =  list(class = 'ENC.CATEGORY_ENCODERS.HLMRT', pass = list(type = c('nominal', 'ordinal')), transformers = transformers_for_encoders)

list(class = 'ENC.FASTDUMMIES.OHE',
     pass = list(type = 'nominal', n_unique = c(3,25)),
     transformers = transformers_for_encoders) -> default_templates[['ENC.FASTDUMMIES.OHE']]

list(class = 'ENC.SCIKIT.OHE',
     pass = list(type = 'nominal', n_unique = c(3,25)),
     transformers = transformers_for_encoders) -> default_templates[['ENC.SCIKIT.OHE']]

default_templates[['ENC.MALER.FE']] =
  list(class = 'ENC.MALER.FE', pass = list(type = c('numeric', 'ordinal')), action_by_original = 'smart_divide',
       transformers = transformers_for_encoders %<==>% default_templates[['CLS.SCIKIT.LR']]$transformers)


default_templates[['ENC.MALER.TE']] = list(class = 'ENC.MALER.TE',
                                           pass = list(type = c('ordinal', 'nominal')),
                                           transformers = transformers_for_encoders %<==>% default_templates[['CLS.SCIKIT.LR']]$transformers)

default_templates[['ENC.MALER.ME']] = list(class = 'ENC.MALER.ME', pass = list(type = c('ordinal', 'nominal')),
                                           transformers = transformers_for_encoders %<==>% default_templates[['CLS.SCIKIT.LR']]$transformers)
default_templates[['ENC.MALER.MEB']] = list(class = 'ENC.MALER.MEB', pass = list(type = c('ordinal', 'nominal')),
                                            transformers = transformers_for_encoders %<==>% default_templates[['CLS.SCIKIT.LR']]$transformers)
# todo: work on it



#### Binners: ####
list(class = 'BIN.MALER.OBB',
     type = c('numeric', 'ordinal'), n_unique = c(5, Inf),
     transformers = default_templates[['CLS.SCIKIT.LR']]$transformers) -> default_templates[['BIN.MALER.OBB']]

list(class = 'BIN.MALER.GROUPER',
     type = c('nominal', 'ordinal'), n_unique = c(30, Inf), feature_sample_size = 1:2,
     transformers = default_templates[['CLS.SCIKIT.LR']]$transformers) -> default_templates[['BIN.MALER.GROUPER']]

list(class = 'BIN.SMBINNING.OB',
     type = c('numeric', 'ordinal'), n_unique = c(5, Inf),
     transformers = default_templates[['CLS.SCIKIT.LR']]$transformers,
     feature_sample_size = 1:10) -> default_templates[['BIN.SMBINNING.OB']]

list(class = 'BIN.SCIKIT.KMC',
     type = c('numeric', 'ordinal'), n_unique = c(25, Inf),
     transformers = default_templates[['CLS.SCIKIT.LR']]$transformers,
     n_clusters = 2:25) -> default_templates[['BIN.SCIKIT.KMC']]

list(class = 'BIN.KMEANS.KMC',
     type = c('numeric', 'ordinal'), n_unique = c(25, Inf),
     transformers = default_templates[['CLS.SCIKIT.LR']]$transformers,
     num_clusters = 2:25) -> default_templates[['BIN.KMEANS.KMC']]

#### Function Transformers: ####
default_templates[['FNT.MALER.INV']] = list(class = 'FNT.MALER.INV', trim = 100)
default_templates[['FNT.MALER.LOG']] =
  list(class = 'FNT.MALER.LOG', intercept = list(fun = 'runif', min = 0, max = 10))
default_templates[['FNT.MALER.POLY']] =
  list(class = 'FNT.MALER.POLY')



#### Feature Generators: ####
default_templates[['FET.MALER.D2MUL']] = list(class = 'FET.MALER.D2MUL')
default_templates[['FET.SCIKIT.MFG']] = list(class = 'FET.SCIKIT.MFG')

list(class = 'FET.MALER.MGB',
     pass = list(type = c('numeric', 'ordinal'), n_unique = c(5, Inf)),
     transformers = default_templates[['CLS.SCIKIT.LR']]$transformers,
     epochs = 5:25,
     max_fails = 2:5,
     cycle_births = 500:1000,
     cycle_survivors = 100:250,
     final_survivors = 5:25) -> default_templates[['FET.MALER.MGB']]

list(class = 'FET.MALER.LGB',
     pass = list(type = 'ordinal', n_unique = 2),
     transformers = list(
       list(classes = c(rep('BIN.MALER.OBB', 7), rep('BIN.SMBINNING.OB', 3)), probability = 0.5),
       list(classes = c(rep('ENC.FASTDUMMIES.OHE', 4), 'ENC.SCIKIT.OHE'), probability = 0.5)
     ),
     epochs = 5:25,
     max_fails = 2:5,
     cycle_births = 500:1000,
     cycle_survivors = 100:250,
     final_survivors = 5:25) -> default_templates[['FET.MALER.LGB']]

#### Ensemblers: ####
list(class = 'ENS.MALER.BS') -> default_templates[['ENS.MALER.BS']]
list(class = 'ENS.MALER.AGGR') -> default_templates[['ENS.MALER.AGGR']]



#### Overall Treatments ####

for(i in sequence(length(default_templates))) default_templates[[i]]$feature_sample_ratio = list(fun = 'runif', min = 0.01, max = 0.2)
classifiers = names(default_templates) %>% charFilter('CLS.')
for(i in classifiers) default_templates[[i]]$max_train = list(fun = 'rgeom', prob = 0.00001)



