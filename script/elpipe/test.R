library(gener)
library(magrittr)
library(yaml)

path_1  = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/nima_config_1"
path_3  = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/nima_config_3"
path_5  = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/nima_config_5"
path_6  = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/nima_config_6"
path_7  = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/nima_config_7"
path_en = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/ensemble xgb"

path_best_xgb = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/best_xgb"
path_base_xgb = "~/Documents/software/Python/projects/sticky/Tools/Configs/Prediction/CUA/baseline_xgb"
  
yaml.load_file(path_1 %>% paste('config.yml', sep = '/')) -> cfg1
yaml.load_file(path_3 %>% paste('config.yml', sep = '/')) -> cfg3
yaml.load_file(path_5 %>% paste('config.yml', sep = '/')) -> cfg5
yaml.load_file(path_6 %>% paste('config.yml', sep = '/')) -> cfg6
yaml.load_file(path_7 %>% paste('config.yml', sep = '/')) -> cfg7
yaml.load_file(path_en %>% paste('config.yml', sep = '/')) -> cfg_en

yaml.load_file(path_base_xgb %>% paste('config.yml', sep = '/')) -> cfg_base



################################################################
elpipe.to_hierarchical(cfg1) -> hrc1
elpipe.to_hierarchical(cfg2) -> hrc2


################################################################
# embedding cfg_base to replace ensembler model of cfg_en:
cfg_en %>% elpipe.ensembler.inject_model(cfg5) -> cfg


################################################################ Replicate nima_config_5:
nr1  = CFG.SCIKIT.NR(name = 'NR1', 
              features = cfg5$model$transforms$X_transforms[[1]]$sklearn.preprocessing.MinMaxScaler$transform_columns[[1]]
              )
nr2  = CFG.SCIKIT.NR(name = 'NR2', 
              features = cfg5$model$transforms$X_transforms[[2]]$sklearn.preprocessing.MinMaxScaler$transform_columns[[1]]
)

te   = CFG.CATEGORY_ENCODERS.TE(features = 'currentSecurityPostcodeSA4')
km   = CFG.SCIKIT.KMEANS(transformers = list(te), parameters = list(n_clusters = 9))
ohe  = CFG.SCIKIT.OHE(transformers = list(km))
pca  = CFG.SCIKIT.PCA(parameters = list(n_components = 25), transformers = list(nr1, nr2))
atmp = CFG.ELULALIB.ATMP(parameters = list(agent = "274adf84-39aa-4c65-8e43-848340d363e2", model = "c7eaceb5-5fa6-474b-8070-acf7311e4513", logit = T))
lr   = CFG.ELULALIB.LR(parameters = list(penalty = 'l1', solver = 'liblinear', use_SGD = F), features = cfg5$model$features, 
             transformers = list(nr1, nr2, ohe, pca), config = list(dataset = '1d10e12c-1ad3-4813-abfa-35d87b70493f'))

lr$get.el_config() -> cfg
hnd = list(
  logical = function(x) {
    result <- ifelse(x, "True", "False")
    class(result) <- "verbatim"
    return(result)
  }
)
cfg %>% yaml::write_yaml('config.yml', handlers = hnd)

################
cfg5 %>% elpipe.to_hierarchical %>% hierarchical_to_mlconfig -> cfg
