library(magrittr)
library(dplyr)
source('~/Documents/software/R/projects/tutorials/templib.R')
library(rutils)
library(rml)
path = "/Users/nima/Documents/data/kaggle/test_train_example"

X_train <- read.csv(path %>% paste('x_train.csv', sep = '/'))
y_train <- read.csv(path %>% paste('y_train.csv', sep = '/')) %>% pull('churn')
X_test  <- read.csv(path %>% paste('x_test.csv', sep = '/'))
y_test  <- read.csv(path %>% paste('y_test.csv', sep = '/')) %>% pull('churn')

moment = function(v, m = c(1,2), na.rm = T){
  if(length(m) == 1) return(sum(v^m))
  M = NULL
  for(i in m){M %<>% c(sum(v^i, na.rm = na.rm))}
  names(M) <- paste0('M', m)
  return(M)
}

colnames(X_train) %>% sapply(function(i) X_train[,i] %>% unique %>% length) %>% 
  cbind(
    X_train %>% as.matrix %>% apply(2, moment, m = 1:4) %>% t) %>% 
  cbind(
    X_train %>% as.matrix %>% apply(2, function(v) {c(n_missing = sum(is.na(v)), n_values = sum(!is.na(v)))}) %>% t) %>% 
  cbind(
    X_train %>% as.matrix %>% apply(2, quantile, probs = 0.01*(0:100)) %>% t) -> finfo


mms = MAP.RML.MMS()
lr1 = CLS.SKLEARN.LR(penalty = 'l1', transformers = mms, return = 'logit')
pca = MAP.STATS.PCA(transformers = list(mms, lr1))
lr2 = CLS.SKLEARN.KNN(name = 'KNN', transformers = pca)
xgb = CLS.SKLEARN.XGB(return = 'logit', transformers = list(lr1, lr2, pca, mms))

xgb$fit(X_train, y_train)
xgb$performance(X_test, y_test)

xgb_raw = CLS.SKLEARN.XGB()
xgb_raw$fit(X_train, y_train)
xgb_raw$performance(X_test, y_test)

###################
gen_edgelist = function(model, first = T){
  edgelist = NULL
  if(is.empty(model$transformers)){
    edgelist %<>% rbind(c('INPUT', model$name))
  } else {
    for(tr in model$transformers){
      edgelist %<>% rbind(c(tr$name, model$name))
      edgelist %<>% rbind(gen_edgelist(tr, first = F))
    }
  }
  if(first){
    edgelist %<>% rbind(c(model$name, 'OUTPUT'))
  }
  return(edgelist)
}

info_model = function(model){
  info = list(name = model$name, type = model$type, class = class(model)[1], description = model$description, package = model$package,
              language = model$package_language, return = model$config$return, 
   fitted = model$fitted, keep_columns = model$config$keep_columns, keep_features = model$config$keep_features, 
   max_train = model$config$max_train, rfe = model$config$rfe.enabled, metric = model$config$metric,
   outputs = model$objects$n_output)
  for(i in names(info)){
    if(is.null(info[[i]])){ info[[i]] <- 'NULL'}
  }
  return(info)
}
  
info_transformers = function(model){
  tbl = do.call(data.frame, info_model(model) %>% list.add(stringsAsFactors = F))
                   
  for(tr in model$transformers){
    tbl_tr = do.call(data.frame, info_model(tr) %>% list.add(stringsAsFactors = F))
    tbl %<>% rbind(tbl_tr)
  }
  return(tbl)
}

info_transformers(xgb) %>% View

library(rvis)
nodes = info_transformers(xgb)
rownames(nodes) <- nodes$name
nodes['INPUT', 'name'] <- 'INPUT'
nodes['INPUT', 'type'] <- 'Data'
nodes['INPUT', 'class'] <- 'INPUT'
nodes['INPUT', 'description'] <- 'Features'
nodes['OUTPUT', 'name'] <- 'OUTPUT'
nodes['OUTPUT', 'type'] <- 'Final Prediction'
nodes['OUTPUT', 'class'] <- 'OUTPUT'
nodes['OUTPUT', 'description'] <- ''
nodes[is.na(nodes)] <- 'NULL'
nodes$type %<>% as.factor

nodes$description = paste(nodes$class, nodes$description, nodes$type, sep = '\n')

links = gen_edgelist(xgb) %>% {colnames(.) <- c('source', 'target');.} %>% as.data.frame %>% 
  mutate(source = as.character(source), target = as.character(target)) %>% 
  left_join(nodes %>% select(source = name, outputs), by = 'source')
rvis::rvisPlot(plotter = 'visNetwork', type = 'graph', obj = list(nodes = nodes, links = links), source = 'source', target = 'target', linkWidth = 'outputs', key = 'name', label = 'description', 
          color = 'type', config = list(direction = 'left.right', node.shape = 'box', layout = 'hierarchical'), linkLabel = 'outputs')

###################
### rml translation:
xgb$plot.network(plotter = 'visNetwork', direction = 'right.left', node.shape = 'box', layout = 'hierarchical')

xgb$plot.network(plotter = 'grviz', direction = 'left.right', node.shape = 'box', node.size = 2.1, link.label.size = 18, node.label.size = 15, link.arrow.size = 2, link.color = 'blue')




