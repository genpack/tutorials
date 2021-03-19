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

path_best_xgb  = "~/Documents/software/Python/projects/stky/Tools/Configs/Prediction/clnt/best_xgb"
path_base_xgb  = "~/Documents/software/Python/projects/stky/Tools/Configs/Prediction/clnt/baseline_xgb"
path_11        = "~/Documents/software/Python/projects/stky/Tools/Configs/Prediction/clnt/nima_config_11"
path_12        = "~/Documents/software/Python/projects/stky/Tools/Configs/Prediction/clnt/nima_config_12"


path_dec18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/dec18"
path_nov18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/nov18"
path_oct18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/oct18"
path_sep18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/sep18"
path_aug18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/aug18"
path_jul18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/jul18"
path_jun18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/jun18"
path_may18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/may18"
path_apr18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/apr18"
path_mar18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/mar18"
path_feb18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/feb18"
path_jan18     = "~/Documents/software/Python/projects/stky/Tools/Configs/Sampler/clnt/jan18"

yaml.load_file(path_base_xgb %>% paste('config.yml', sep = '/')) -> cfg_base
yaml.load_file(path_best_xgb %>% paste('config.yml', sep = '/')) -> cfg_best

cfg_best %>% elpipe.to_hierarchical %>% hierarchical_to_mlconfig -> mlcfg_best
mlcfg_best$write.el_config(path = path_9)



bfet = read.csv('~/Documents/data/fetlists/bf_xgb_clnt_sep18.csv') %>% extract(,1) %>% as.character
cats = bfet %>% charFilter('code', 'type', 'channel', 'mood', and = F) %>% 
  setdiff(charFilter(., 'dist', 'itude', 'avg', 'num', 'periods', 'area', 'population', 'days', 'sum', 
                     'minimum', 'balance','valu', 'diff', 'mean', and = F)) 
removed  = bfet %>% charFilter('applicationamount', 'mortgagetype', 'numborrowers', 'codearea', 'population', 'securitytype', 'estimatedlvr', and = F)
bfet = bfet %-% removed %>% c("currentNumBorrowers", "currentSecurityType", "estimatedLVR")

samplerids = c(sep18 = 'c1564472-3f54-4e30-81e6-c6a41ac65a9e')
################################################################ Replicate nima_config_5:
rs    = CFG.SCIKIT.RS(features = bfet)
mms   = CFG.SCIKIT.MMS(features = bfet %-% cats)
zfs   = CFG.SCIKIT.ZFS(features = bfet)

te   = CFG.CATEGORY_ENCODERS.TE(features = 'currentSecurityPostcodeSA4')
km   = CFG.ELB.KMEANS(transformers = list(te), parameters = list(num_clusters = 9, keep_columns = F))
ohe  = CFG.SCIKIT.OHE(transformers = list(km))
pca  = CFG.SCIKIT.PCA(parameters = list(n_components = 5), transformers = list(rs))
xgb  = CFG.ELB.XGB(name = 'best', parameters = cfg_best$model$parameters, features = bfet)
xgbl = CFG.ELB.ATMP(parameters = list(agent = '4a8d359e-0f2c-4f8f-bb24-571adf587b9c', model = '39a5f557-0e27-4359-a97a-df84daf3a651', logit = T))
lr_1 = CFG.SCIKIT.LR(parameters = list(penalty = 'l1', solver = 'liblinear'), transformers = list(ohe, pca, xgbl))
# lr_2 = CFG.ELB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
#                        transformers = list(nr_2, nr_1, xgb, lr_1), config = list(dataset = 'cdbc300f-7832-494a-8fc1-c1e18d7f9199'))
lr_2 = CFG.ELB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = bfet, 
                        transformers = list(zfs, xgbl, ohe), config = list(dataset = samplerids['sep18']))

lr_2$write.elpipe_config(filename = 'config.yml', path = path_12)
################

cfg_best %>% elpipe.to_hierarchical %>% hierarchical_to_maler() -> aa

cats = cats %-% cats %>% charFilter


build_sampler_config(ml_id = '42892553-6776-4684-9f8d-b6d8eb288aa3', test_date = '2018-07-01', features = bfet) %>% 
  yaml::write_yaml(path_jul18 %>% paste('config.yml', sep = '/'))
