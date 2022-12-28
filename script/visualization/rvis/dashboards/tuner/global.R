### Example dashboard for segmentation model tuning ------------------------
library(magrittr)

library(shiny)
library(shinydashboard)
library(shinyBS)
library(rvis)

# Build dummy data
features = paste0('F', 1:50)
segments = paste0('S', 1:9)

segment_config = list()
for(sn in segments){
  segment_config[[sn]] = list(defining_features = list())
  for (i in sample(1:50, size = sample(5:50, size = 1))){
    segment_config[[sn]]$defining_features %<>% rlist::list.append(
      list(
        feature_name = paste0('F', i), 
        feature_weight = sample(c(1,1,1,-1), size = 1)
      ) 
    )
  }
}

seg_data <- data.frame(caseID = 'CASE' %>% paste0(1:10000))

for(i in 1:50){
  seg_data[[paste0('F', i)]] <- rnorm(10000, mean = runif(1, min = -10, max = 10), sd = runif(1, min = 1, max = 5))
  ind = sample(1:10000, size = min(500*i, 9900))
  seg_data[ind, paste0('F', i)] <- NA
}


for(sn in segments){
  seg_data[[sn]] <- rexp(10000, rate = sample(0.01*(1:100), size = 1))
  segment_config[[sn]]$feature_set <- segment_config[[sn]]$defining_features %>% rutils::list.pull('feature_name')
}


### Functions:

get_filtered_scores = function(segment_data, segment_name, ...){
  segment_data[get_filtered_indexes(segment_data, segment_name, ...), segment_name]
}

get_filtered_indexes = function(segment_data, segment_name, segment_features, exclusion_features, quantile_range = c(0,1)){
  
  exclusion_features %<>% intersect(segment_features)

  sparsity = is.na(seg_data[segment_features]) %>% as.data.frame()
  
  include = segment_data %>% nrow %>% sequence
  if(length(exclusion_features) > 0){
    exclude = segment_data %>% nrow %>% sequence
    for(fn in exclusion_features){
      wna = which(sparsity[[fn]])
      exclude %<>% intersect(wna)
    }
  } else exclude = c()

  include %<>% setdiff(exclude)
  score_range = segment_data[include, segment_name] %>% quantile(probs = quantile_range)
  
  include = include[which(
    segment_data[include, segment_name] >= score_range[1] & 
    segment_data[include, segment_name] <= score_range[2])]
  
  return(include)  
}

# # sc: (list) segment_config
# # awm: Attribute Weighting Matrix (Feature Weighting Matrix)
# awm_from_config = function(sc){
#   AWM = data.frame()
#   
#   for(fn in features){
#     AWM[fn, ] = 0
#   }
#   
#   for(seg in sc$segments){
#     for(fn in seg$defining_features)
#       AWM[fn$feature_name, seg$name] = fn$feature_weight
#   }
#   AWM %>% rutils::na2zero() %>% t %>% as.data.frame
# }
# 
# 
# sn = 'S1'
# cat('\n Building moments for segment %s ...' %>% sprintf(sn))
# seg_features = segment_config[[sn]]$feature_set
# awm_from_config(segment_config)
# 
# seg_awm = awm[sn, seg_features]
# seg_sparsity = as.data.frame((seg_data[seg_features] > 0) %>% apply(2, as.numeric))
# seg_sparsity[sn] = seg_data[sn]
# seg_sparsity %>% rml::bucket_moments(sn, seg_features, ncuts = 1000) -> bm
# bm$quantile = bm$cumulative_count/nrow(seg_sparsity)
# bm$sparsity = bm$cumulative_sum_V2/bm$cumulative_count
# cat('Done! \n')
# 



### Run Test:
# exclusion_features = c('F2', 'F5')
# selected_segment = 'Segment_2'
# segment_features = segment_config[[selected_segment]]$feature_set
# get_filtered_scores(seg_data, selected_segment, segment_features, exclusion_features)


feature_sparsity = is.na(seg_data[features]) %>% apply(2, as.numeric) %>% as.data.frame


plot_sparsity_rate = function(feature_sparsity, indexes, features){
  feature_sparsity[indexes, features] %>% 
    colMeans %>% as.data.frame() -> feature_sparsity_rates
  
  colnames(feature_sparsity_rates) <- 'Sparse'
  feature_sparsity_rates %<>% dplyr::mutate(non_Sparse = 1.0 - Sparse) %>% 
    rutils::rownames2Column('feature_name')
  
  billboarder() %>%
    bb_barchart(
      data = feature_sparsity_rates %>% dplyr::arrange(Sparse),
      stacked = TRUE
    ) %>%
    bb_axis(rotated = TRUE) %>% 
    bb_x_axis(position = "outer-top", label = 'Feature Name') %>%
    bb_y_grid(show = TRUE) %>%
    bb_y_axis(tick = list(format = suffix("%")),
              label = list(text = "Feature Sparsity Rate", position = "outer-top")) %>% 
    bb_legend(position = "outset") %>% 
    bb_labs(title = "Feature Sparsity",
            caption = "Scentre Connect Segmentation Tuning")
}

reactive_values = list(
  indexes = get_filtered_indexes(
    segment_data = seg_data, 
    segment_name = 'S1', 
    segment_features = segment_config[['S1']]$feature_set, 
    exclusion_features = segment_config[['S1']]$feature_set))

reactive_values$scores <- seg_data[reactive_values$indexes, 'S1']


