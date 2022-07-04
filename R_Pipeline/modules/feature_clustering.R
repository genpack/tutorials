# Feature Clustering

#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)
load_package('rfun', version = rfun.version)
load_package('rml', version = rml.version)
source('R_Pipeline/libraries/ext_rml.R')
################ Inputs ################
config_filename = 'fcl_config_01.yml'

args = commandArgs(trailingOnly = T)
if(!is.empty(args)){
  config_filename = args[1]
}

################ Read & Validate config ################
yaml::read_yaml(mc$path_configs %>% paste('modules', 'feature_clustering', config_filename, sep = '/')) -> fcl_config
# mds_dim = verify(fcl_config$mds_dim, c('numeric','integer'), domain = c(2, 100), null_allowed) %>% as.integer
# n_clust = verify(fcl_config$max_num_clusters, c('numeric','integer'), domain = c(2, 100), default = 50) %>% as.integer

################ Read Data ################
# wt <- WIDETABLE(name = 'wide', path = path_ml)
# wt  %>% saveRDS(sprintf("%s/wide.rds", path_ml))
wt <- readRDS(sprintf("%s/wide.rds", path_ml))
wt$size_limit = 2e+09

if(is.null(fcl_config$features)){
  features = rbig::colnames(wt)
} else {
  features = fcl_config$features %>% extract_feature_names(mc) %>% 
    intersect(rbig::colnames(wt))
}
features %<>% setdiff(charFilter(features, fcl_config$exclude_columns, and = F)) %>% 
  setdiff(charFilter(features, mc$leakages, and = F))

################ Read or Compute Cross Correlations ################
path = sprintf("%s/%s/feature_clustering", mc$path_reports, id_ml)
if(!file.exists(path)){dir.create(path)}

compute = is.null(fcl_config$cross_correlation)
if(!compute){
  path    = sprintf("%s/%s.rds", path, fcl_config$cross_correlation)
  compute = !file.exists(path)
}

if(compute){
  rbig::cor.widetable.parallel(wt[features]) -> ccr
  if(!is.null(fcl_config$cross_correlation)){
    saveRDS(ccr, path)
  }
} else {
  ccr = readRDS(path)
}

################ Read or Compute Feature Clustering: ################
dst = 1.0 - abs(ccr)

rml::cluster_tree(dst) -> ctr

# Old Clustering:
# if(is.null(fcl_config$mds_dim)){fcl_config$mds_dim <- nrow(ccr) - 1}
# # The max value for number of MDS dimensions is num_features - 1
# fcl_config$mds_dim %<>% min(nrow(ccr) - 1)
# 
# compute = is.null(fcl_config$feature_coordinate)
# if(!compute){
#   path_fc = sprintf("%s/%s/feature_clustering/%s.rds", mc$path_reports, id_ml, fcl_config$feature_coordinate)
#   compute = !file.exists(path_fc)
# }
# 
# if(compute){
#   u   = cmdscale(dst, k = fcl_config$mds_dim)
#   
#   if(!is.null(fcl_config$feature_coordinate)){
#     saveRDS(u, path_fc)
#   }
# } else {
#   u = readRDS(path_fc)
# }

################ Run K-Means for Clustering: ################
# Auto determination of num clusters by elbow plot:
# elb = rutils::elbow(u, num.clusters = fcl_config$num_clusters)
# if(!is.null(fcl_config$elbow)){
#   saveRDS(elbow, sprintf("%s/%s/%s.rds", mc$path_reports, id_ml, fcl_config$elbow))
# }

# bnc = rutils::best_num_clusters(elb$wgss, method = "angle_threshold")
# clusters =  elb$clst[[paste0('NC', bnc)]]$cluster

################ Save Output: ################
outpath = sprintf("%s/%s/feature_clustering", mc$path_reports, id_ml)
if(!file.exists(outpath)){dir.create(outpath)}
outfile = sprintf("%s/%s.csv", outpath, fcl_config$output)
ctr$tree_table %>% as.data.frame %>% 
  rutils::rownames2Column('fname') %>% 
  write.csv(outfile, row.names = F)

if(!is.null(fcl_config$cluster_tree)){
  outfile = sprintf("%s/%s.rds", outpath, fcl_config$cluster_tree)
  ctr %>% saveRDS(outfile)
}
