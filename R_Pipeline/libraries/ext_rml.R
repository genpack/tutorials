get_ranking_weights = function(ordmat, num_required, col_weights, type){
  nc = ncol(ordmat); nr = nrow(ordmat); assert(num_required < nr)
  if(length(col_weights) != nc){col_weights %<>% rutils::vect.extend(nc)}
  col_weights %<>% rutils::vect.normalise()
  
  num_top = num_required*col_weights
  grow    = rutils::chif(type == 'intersection', 3, 11)
  limit   = rutils::chif(type == 'intersection', 2, 10)
  rank_weight = numeric(nr)
  while(abs(grow) > limit){
    num_top = floor(num_top + nc*grow*col_weights)
    
    picked = rutils::chif(type == 'intersection', sequence(nr), c())
    for(i in sequence(nc)){
      u = ordmat[sequence(num_top[i]) %^% sequence(nr), i]
      if(type == 'intersection'){
        picked %<>% intersect(u)
      } else {
        picked %<>% union(u)
      }
    }
    
    grow  = num_required - length(picked)
    if(grow > 0) {rank_weight[picked] <- rank_weight[picked] + 1}
  }
  return(rank_weight)
}

SmartAggregator = setRefClass('SmartAggregator', contains = "CLASSIFIER",
   methods = list(
     initialize = function(...){
       callSuper(...)
       type             <<- 'Ensembler'
       description      <<- 'Smart Aggregator Ensembler'
       package_language <<- 'R'
       package          <<- 'local'

       if(is.empty(name)){name <<- 'ENSSA' %>% paste0(sample(10000:99999, 1))}
       
       config$rw.enabled     <<- verify(config$rw.enabled, 'logical', lengths = 1, domain = c(T,F), default = F)
       config$rw.num_top     <<- verify(config$rw.num_top, c('numeric', 'integer'), lengths = 1, null_allowed = T)
       config$rw.ratio_top   <<- verify(config$rw.ratio_top, 'numeric', default = 0.1, lengths = 1)
       config$rw.joiner_type <<- verify(config$rw.joiner_type, 'character', lengths = 1, domain = c('intersection', 'union'), default = 'intersection')
       config$aggregator     <<- verify(config$aggregator, 'function', lengths = 1, default = mean)
     },
     
     model.fit = function(X, y){
       objects$features <<- objects$features %>% filter(fclass %in% c('numeric', 'integer'))
       X = X[objects$features$fname]
       
       nt = ncol(X)
       if(config$rw.enabled){
         if(is.null(config$rw.column_weights)){
           X %>% as.matrix %>% 
             apply(2, correlation, y = y, metrics = 'lift', quantiles = config$rw.ratio_top) %>%
             vect.normalise ->> objects$column_weights
         } else {
           verify(config$rw.column_weights, c('numeric', 'integer'), lengths = nt) ->> objects$column_weights 
         } 
       }
     },
     
     model.predict = function(X){
       
       out = X %>% apply(1, config$aggregator)
       
       if(config$rw.enabled){
         if(is.null(config$rw.num_top)){
           num_required = nrow(X)*config$rw.ratio_top
         } else {
           num_required = config$rw.num_top
         }
         
         rank_weights = get_ranking_weights(
           ordmat = X %>% as.matrix %>% apply(2, order, decreasing = T), 
           num_required = num_required, 
           col_weights = objects$column_weights,
           type = config$rw.joiner_type) %>% rutils::vect.map(0, 5)
         
         out %<>% logit_fwd %>% {. + rank_weights} %>% logit_inv
       }

       out %<>% as.data.frame
       return(out)
     }
   )
)

optimize_column_weights = function(fitted_model, X_test, y_test, lift_ratio = 0.02, plot_precisions = T){
  nr = nrow(X_test)
  fitted_model$transform_x(X_test) -> X
  nc = ncol(X)
  
  sequence(10^nc - 1) %>% stringr::str_pad(nc, pad = '0') %>% 
    strsplit(split = '') %>% 
    lapply(as.integer) -> weights
  
  weights %>% 
    lapply(get_ranking_weights_intersection, 
           ordmat = X %>% as.matrix %>% apply(2, order, decreasing = T), 
           num_required = lift_ratio*nr) %>% 
    lapply(function(ind) mean(y_test[ind])) %>% 
    unlist -> precisions
 
  if(plot_precisions) {plot(precisions)}
  
  weights[[order(precisions) %>% tail(1)]]
}

# Internal function used by grouper module
fit_map = function(X, y, cats, encoding = 'target_ratio'){
  allmaps  = list()
  scores   = get_chisq_scores(X, y, cats)
  cats     = cats[order(scores)]
  map_base = get_map(X, y, source = cats[1], target = 'M0', encoding = encoding)
  X = apply_map(X, map_base)
  allmaps[[cats[1]]] <- map_base
  columns = cats[-1]
  benchmark = Inf; iii = 1
  for(i in sequence(length(columns))){
    col   = columns[i]
    XT    = concat_columns(X, sources = c('M' %>% paste0(iii - 1), col), target = 'C' %>% paste0(iii))
    mapi  = get_map(XT, y, source = 'C' %>% paste0(iii), target = 'M' %>% paste0(iii), encoding = encoding)
    XT    = apply_map(XT, mapi)
    fval  = suppressWarnings({chisq.test(XT %>% pull('M' %>% paste0(iii)), y)})
    fval  = fval$statistic %>% pchisq(df = fval$parameter['df'], lower.tail = F, log.p = T)
    
    if(fval < benchmark){
      allmaps[[col]] = mapi
      X = XT
      benchmark = fval
      iii   = iii + 1
    }
  }
  return(allmaps)
}

# Internal function used by grouper module
fit_map_new = function(X, y, cats, encoding = 'target_ratio'){
  allmaps  = list()
  scores   = get_chisq_scores(X, y, cats)
  cats     = cats[order(scores)]
  map_base = get_map(X, y, source = cats[1], target = 'M0', encoding = encoding)
  X = apply_map(X, map_base)
  allmaps[[cats[1]]] <- map_base
  columns = cats[-1]
  benchmark = Inf; iii = 1
  for(col in columns){
    XT    = concat_columns(X, sources = c('M' %>% paste0(iii - 1), col), target = 'C' %>% paste0(iii))
    ind1  = XT %>% nrow %>% sequence %>% sample(floor(0.5*nrow(XT)))
    ind2  = XT %>% nrow %>% sequence %>% setdiff(ind1)
    X1    = XT[ind1,]; X2 = XT[ind2,]; y1 = y[ind1]; y2 = y[ind2]
    mapi  = get_map(X1, y1, source = 'C' %>% paste0(iii), target = 'M' %>% paste0(iii), encoding = encoding)
    X1    = apply_map(X1, mapi)
    X2    = apply_map(X2, mapi)
    p1    = get_chisq_scores(X1, y1, 'M' %>% paste0(iii))
    p2    = get_chisq_scores(X2, y2, 'M' %>% paste0(iii))
    
    if((p1 < benchmark) & (p2 < benchmark)){
      allmaps[[col]] = mapi
      X = apply_map(XT, mapi)
      benchmark = max(p1, p2)
      iii   = iii + 1
    }
  }
  return(allmaps)
}

# Internal function used by grouper module
predict_map = function(X, maplist){
  if(inherits(maplist, 'character')){
    return(X[maplist])
  }
  columns = names(maplist)
  nmap    = length(maplist)
  for(i in sequence(nmap)){
    map    = maplist[[i]]
    col    = columns[i]
    ns     = colnames(map)
    source = ns[1]
    target = ns[2]
    X      = apply_map(X, map)
    if(i < nmap){
      X    = concat_columns(X, sources = c(target, columns[i+1]), target = colnames(maplist[[i+1]])[1])
    }
  }
  return(X %>% pull(target))
}


predict_glm_fit <- function(glmfit, newmatrix, addintercept=TRUE){
  newmatrix %<>% as.matrix
  if (addintercept)
    newmatrix <- cbind(1,newmatrix)
  eta <- newmatrix %*% glmfit$coef
  glmfit$family$linkinv(eta)
}



# Internal function used by grouper module
apply_map = function(X, mapping){
  X %>% left_join(mapping, by = colnames(mapping)[1])
}

Grouper = setRefClass('Grouper', contains = "MODEL", methods = list(
  initialize = function(...){
    callSuper(...)
    type             <<- 'Binner'
    description      <<- 'Categorical Feature Grouper'
    package          <<- 'local'
    package_language <<- 'R'
    if(is.empty(name)){name <<- 'GRP' %>% paste0(sample(10000:99999, 1))}
    
    config[['pp.remove_numeric_features']] <<- T
    config[['pp.remove_nominal_features']] <<- F
    
    config$encoding <<- verify(config$encoding, 'character', domain =c('target_ratio', 'flasso'), default = 'target_ratio')
    #config$num_components <<- config$num_components %>% verify(c('numeric', 'integer'), default = 5) %>% as.integer
  },
  
  model.fit = function(X, y){
    assert(ncol(X) > 0, 'No nominal features found!')
    objects$model <<- fit_map_new(X, y, objects$features$fname, encoding = config$encoding)
  },
  
  model.predict = function(X){
    predict_map(X, objects$model) %>% as.data.frame %>% {colnames(.) <- NULL;.}
  }
))

