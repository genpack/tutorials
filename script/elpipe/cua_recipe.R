library(gener)
library(magrittr)
library(yaml)
source('~/Documents/software/R/projects/tutorials/script/elpipe/tools.R')
source('~/Documents/software/R/projects/tutorials/script/elpipe/elpipe.R')

source('~/Documents/software/R/projects/funchain/funclass.R')
source('~/Documents/software/R/projects/funchain/funlib.R')
source('~/Documents/software/R/projects/funchain/funlib2.R')
source('~/Documents/software/R/projects/funchain/builders.R')
source('~/Documents/software/R/projects/funchain/solvers.R')
source('~/Documents/software/R/packages/gener/R/gener.R')
source('~/Documents/software/R/packages/maler/R/mltools.R')
source('~/Documents/software/R/packages/maler/R/abstract.R')
source('~/Documents/software/R/packages/maler/R/classifiers.R')
source('~/Documents/software/R/packages/maler/R/transformers.R')
source('~/Documents/software/R/packages/maler/R/gentools.R')

pred_path_best_xgb  = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/best_xgb"
pred_path_base_xgb  = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/baseline_xgb"
pred_path_t2_lgbm   = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/T2_LightGBM"
pred_path_t2_catb   = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/T2_Catboost"

pred_path_11        = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/nima_config_11"
pred_path_12        = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/nima_config_12"
pred_path_13        = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/nima_config_13"

sampler_path = list()
sampler_path$dec18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/dec18"
sampler_path$nov18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/nov18"
sampler_path$oct18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/oct18"
sampler_path$sep18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/sep18"
sampler_path$aug18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/aug18"
sampler_path$jul18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/jul18"
sampler_path$jun18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/jun18"
sampler_path$may18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/may18"
sampler_path$apr18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/apr18"
sampler_path$mar18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/mar18"
sampler_path$feb18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/feb18"
sampler_path$jan18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Sampler/CLEINT/jan18"

pred_path = list()
pred_path$dec18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/dec18"
pred_path$nov18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/nov18"
pred_path$oct18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/oct18"
pred_path$sep18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/sep18"
pred_path$aug18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/aug18"
pred_path$jul18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/jul18"
pred_path$jun18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/jun18"
pred_path$may18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/may18"
pred_path$apr18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/apr18"
pred_path$mar18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/mar18"
pred_path$feb18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/feb18"
pred_path$jan18     = "~/Documents/software/Python/projects/event_prediction_platform/Tools/Configs/Prediction/CLEINT/jan18"

best_xgb_runs = list(jan18 = list(agent = '480b5fe8-6e3a-4dc9-818a-e648807bf116', model = '091f7301-08b3-4cd9-80dc-15ca64d3e835'),
                     feb18 = list(agent = '2ce151b1-f042-42bf-bb2e-db0943b2db78', model = '633e0b6f-7da2-4c91-b70b-55c19d294782'),
                     mar18 = list(agent = '4794178c-304b-4bde-ae5c-6666b7d62a29', model = 'ee97368c-3326-4586-a67a-e1b82b2930ff'),
                     apr18 = list(agent = '55f2fa3c-82ee-4b22-bd1c-0856146f6654', model = '44fc059d-a10f-4f06-b432-0103764881f8'),
                     may18 = list(agent = 'a35f08f6-46ad-4aca-a1bf-3eccecaa8305', model = 'a3030002-f8bf-41b5-a762-33d10ebbd7d2'),
                     jun18 = list(agent = '274e0500-d159-4f8d-a026-4064025c9617', model = 'deb31cca-0da7-4f87-ba52-2213b030d37a'),
                     jul18 = list(agent = '3f044f67-6f59-4ac3-9bc0-cc45977605f6', model = 'f8db11af-e47f-4388-aca3-5864f9ee1beb'),
                     aug18 = list(agent = '90d21b97-f3e9-42e1-9cf5-720b23bb730f', model = 'd40dd92d-33a9-452b-b11f-3fb4631dbcbe'),
                     sep18 = list(agent = '208e943d-cf8c-4cc4-9f84-d3a7e4822591', model = '0baca3c7-c483-4cbf-b821-ae3ef9ad1c4a'),
                     oct18 = list(agent = '54d44520-5758-4a39-92d7-dd5f7c09ed00', model = '09cab89a-391d-4f61-9019-ded72402ad33'),
                     nov18 = list(agent = '2a98c9b5-6c5f-4311-af06-e6c6b77d93b8', model = 'a501107a-ec88-4181-95e3-1554d3d6c92b'),
                     dec18 = list(agent = '9a2ccbae-69d9-4ae5-b159-0fb5609f29d0', model = '749afc1c-e954-4ea0-9a5e-ca4211b88b1e'))
                     
yaml.load_file(pred_path_base_xgb %>% paste('config.yml', sep = '/')) -> cfg_base
yaml.load_file(pred_path_best_xgb %>% paste('config.yml', sep = '/')) -> cfg_best
yaml.load_file(pred_path_t2_catb %>% paste('config.yml', sep = '/')) -> cfg_catb
yaml.load_file(pred_path_t2_lgbm %>% paste('config.yml', sep = '/')) -> cfg_lgbm

bfet = read.csv('~/Documents/data/fetlists/bf_xgb_CLEINT_sep18.csv') %>% {.[,1]} %>% as.character
removed  = bfet %>% charFilter('applicationamount', 'mortgagetype', 'numborrowers', 'codearea', 'population', 'securitytype', 'estimatedlvr', and = F)
bfet = bfet %-% removed %>% c("currentNumBorrowers", "currentSecurityType", "estimatedLVR")

cats = bfet %>% charFilter('code', 'type', 'channel', 'mood', and = F) %>% 
  setdiff(charFilter(., 'dist', 'itude', 'avg', 'num', 'periods', 'area', 'population', 'days', 'sum', 
                     'minimum', 'balance','valu', 'diff', 'mean', and = F)) 
longcats = c("currentResidentialPostcode", "currentSecurityPostcode",    "currentSecurityPostcodeSA4")

samplerids = c(
               jan18 = 'cb503e0a-39d4-402d-81af-051bfe1824db',
               feb18 = '9a81df87-bba9-473e-b903-6bc496a7e97a',
               mar18 = '8a2c65c7-e90c-4bc0-89d5-335523950194',
               apr18 = '1313bb87-06d5-4bfc-93b2-55f8de808a41',
               may18 = '4f46b35f-1ded-40ea-978c-2bfdc840f3dd',
               jun18 = '97ab925a-69c7-49e2-813b-9363b2bd8623',
               jul18 = '7236e471-b5a4-4c99-bc2e-e2c287af50d5',
               aug18 = 'f091f3d4-333c-4714-a967-42215cf126e7',
               sep18 = 'c1564472-3f54-4e30-81e6-c6a41ac65a9e',
               oct18 = '68cf2cf3-fe4f-432c-95d9-328a1eec0aff',
               nov18 = '8210e4f0-7b08-4090-9977-655fd80eb155',
               dec18 = '8d2abea7-ea06-45b6-a116-c27a0de13e16'
               )

months = names(samplerids)                     


month = 'jan18'


################### Recipe 1: ##################
xgb  = CFG.ELLIB.XGB(name = 'best', parameters = cfg_best$model$parameters, features = bfet, config = list(dataset = samplerids[month]))
xgb$write.elpipe_config(filename = 'config.yml', path = pred_path[[month]])

################### Recipe 2: ##################
mms   = CFG.SCIKIT.MMS(features = bfet %-% cats)
rs    = CFG.SCIKIT.RS(features = bfet)

te    = CFG.CATEGORY_ENCODERS.TE(features = 'currentSecurityPostcodeSA4')
km    = CFG.ELLIB.KMEANS(transformers = list(te), parameters = list(num_clusters = 9, keep_columns = F))
ohe   = CFG.SCIKIT.OHE(transformers = list(km))

pca  = CFG.SCIKIT.PCA(parameters = list(n_components = 5), transformers = list(rs))

xgbl = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))
lr_1 = CFG.SCIKIT.LR(parameters = list(penalty = 'l1', solver = 'liblinear'), transformers = list(ohe, pca, xgbl))
xgb  = CFG.ELLIB.XGB(name = 'best', parameters = cfg_best$model$parameters, features = bfet)
lr_2 = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(mms, lr_1, xgb), config = list(dataset = samplerids[month]))

################### Recipe 3 V1: ##################
mms   = CFG.SCIKIT.MMS(features = bfet %-% cats)
xgbl  = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))
lr_2  = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(mms, xgbl), config = list(dataset = samplerids[month]))
################### Recipe 3 V2: ##################
xgb   = CFG.ELLIB.XGB(parameters = cfg_best$model$parameters)
lr_2  = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(mms, xgb), config = list(dataset = samplerids[month]))

################### Recipe 3 V3: ##################
xgb  = CFG.ELLIB.XGB(parameters = cfg_best$model$parameters, logit = T)
lr_2 = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(mms, xgb), config = list(dataset = samplerids[month]))
################### Recipe 4: ##################
mms   = CFG.SCIKIT.MMS(features = bfet %-% cats)
rs    = CFG.SCIKIT.RS(features = bfet %-% cats)
xgbl  = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))

pca  = CFG.SCIKIT.PCA(parameters = list(n_components = 25), transformers = list(rs))

te   = CFG.CATEGORY_ENCODERS.TE(features = 'currentSecurityPostcodeSA4')
km   = CFG.ELLIB.KMEANS(transformers = list(te), parameters = list(num_clusters = 9, keep_columns = F))
ohe  = CFG.SCIKIT.OHE(transformers = list(km))

lr_2 = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(mms, xgbl, pca, ohe), config = list(dataset = samplerids[month]))

################### Recipe 5: ##################
mms   = CFG.SCIKIT.MMS(features = bfet %-% cats)
xgbl  = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))

rs    = CFG.SCIKIT.RS(features = bfet %-% cats)
pca  = CFG.SCIKIT.PCA(parameters = list(n_components = 5), transformers = list(rs))

te   = CFG.CATEGORY_ENCODERS.TE(features = 'currentSecurityPostcodeSA4')
km   = CFG.ELLIB.KMEANS(transformers = list(te), parameters = list(num_clusters = 9, keep_columns = F))
ohe  = CFG.SCIKIT.OHE(transformers = list(km))

lr_2 = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(mms, xgbl, pca, ohe), config = list(dataset = samplerids[month]))

################### Recipe 6: ##################
zfs   = CFG.SCIKIT.ZFS(features = bfet)

te    = CFG.CATEGORY_ENCODERS.TE(features = 'currentSecurityPostcodeSA4')
km    = CFG.ELLIB.KMEANS(transformers = list(te), parameters = list(num_clusters = 9, keep_columns = F))
ohe   = CFG.SCIKIT.OHE(transformers = list(km))

xgbl = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))
lr_2 = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                        transformers = list(zfs, xgbl, ohe), config = list(dataset = samplerids[month]))

################### Recipe 6V2: ##################
xgb  = CFG.ELLIB.XGB(parameters = cfg_best$model$parameters, logit = F)
lr_2 = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(zfs, xgbl, ohe), config = list(dataset = samplerids[month]))

################### Recipe 7: ##################

zfs   = CFG.SCIKIT.ZFS(features = bfet %-% cats)
ohe   = CFG.SCIKIT.OHE(features = cats %-% longcats)
lr_1  = CFG.SCIKIT.LR(parameters = list(penalty = 'l1', solver = 'liblinear'), transformers = list(ohe, zfs))
xgbl  = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))
lr_2  = CFG.ELLIB.XGB(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(xgbl, lr_1), config = list(dataset = samplerids[month]))

################### Recipe 8: ##################
lgbm  = CFG.ELLIB.LGBM(parameters = cfg_lgbm$model$parameters)
xgbl  = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))
lr_2  = CFG.ELLIB.XGB(parameters = cfg_best$model$parameters, features = bfet, 
                         transformers = list(xgbl, lgbm), config = list(dataset = samplerids[month]))
################### Recipe 9: ##################
rs    = CFG.SCIKIT.RS(features = bfet %-% cats)
catb  = CFG.ELLIB.CATB(parameters = cfg_catb$model$parameters)
base  = CFG.ELLIB.XGB(parameters = cfg_base$model$parameters)
xgbl  = CFG.ELLIB.ATMP(parameters = list(agent = best_xgb_runs[[month]]$agent, model = best_xgb_runs[[month]]$model, logit = T))
lr_2  = CFG.ELLIB.XGB(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                         transformers = list(rs, catb, base, xgbl), config = list(dataset = samplerids[month]))

################### Recipe 10: ##################
zfs  = CFG.SCIKIT.ZFS(features = bfet %-% cats)
gbm  = CFG.ELLIB.LGBM(parameters = cfg_lgbm$model$parameters, logit = T)
xgb  = CFG.ELLIB.XGB(parameters = cfg_best$model$parameters, logit = T)
lr_2 = CFG.ELLIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                       transformers = list(zfs, gbm, xgb), config = list(dataset = samplerids[month]))

################
lr_2$write.elpipe_config(filename = 'config.yml', path = pred_path[[month]])


################

# cfg_lgbm %>% elpipe.to_hierarchical %>% hierarchical_to_maler() -> aa

################

build_sampler_config(ml_id = '42892553-6776-4684-9f8d-b6d8eb288aa3', test_date = '2018-12-01', features = bfet) %>% 
  yaml::write_yaml(sampler_path$dec18 %>% paste('config.yml', sep = '/'))

################

read.csv('/Users/nima/Documents/software/Python/projects/event_prediction_platform/Tools/runs/CLEINT/Prediction/runs.csv', as.is = T) -> runs

runs %>% filter(user == "nima.ramezani@elgroup.com", state == 'SUCCEEDED') %>% 
  mutate(month = description %>% substr(1, 5), recipe = description %>% substr(10, 10), mapperid = description %>% substr(20, 27)) %>% 
  filter(month %in% months) %>% 
#  select(agentrunid, runid, description, month, recipe, state, gini_coefficient, lift_2, f_1) %>% 
  mutate(gini_coefficient = as.numeric(gini_coefficient)) -> runs2

runs2 = cbind(samplerid = samplerids[runs2$month], runs2)

View(runs2)

runs2 %>% reshape2::dcast(month ~ recipe, value.var = 'gini_coefficient', fun.aggregate = mean_narm) %>% 
  {colnames(.) <- paste('Recipe', colnames(.));.} %>% View

runs %>% filter(user == "nima.ramezani@elgroup.com", state == 'FAILED') %>% arrange(desc(start)) %>% 
  select(agentrunid, runid, description) %>% {.[1,]} -> lf
from_prediction_to_local(agent_run_id = lf$agentrunid, model_run_id = lf$runid, client = 'CLEINT', profile = 'write@CLEINT-event_prediction_platform')

from_sampler_to_local(run_id = samplerids[[month]], target = 'D:/Users/nima.ramezani/Documents/data/samplers')

