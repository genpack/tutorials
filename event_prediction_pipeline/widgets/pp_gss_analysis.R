##### Setup #####

source('R_Pipeline/initialize.R')

##### Input #####
config = list()
# specify gss agent and model runids: 
config$input.agent_runid = ''
config$input.model_runid = ''

config$dates = '2020-01-01'

##### Read #####
scores_path <- sprintf("%s/prediction/%s/%s/raw_scores.csv", 
                       mc$path_data, 
                       config$input.agent_runid %>% substr(1,8),
                       config$input.model_runid %>% substr(1,8))

scores_path %>% bigreadr::fread2() -> scores

scores$test_date %<>% as.character

config$dates = unique(scores$test_date)

##### Run #####

# model profile/model performances
mp = 
  scores %>% 
  dplyr::distinct(model_id, test_date, batch_number, .keep_all = T) %>% 
  filter(test_date %in% config$dates)
  
# Performance progress in batches:
mp %>% 
  group_by(batch_number) %>% 
  summarise(max_gini = max(gini_coefficient), max_lift_2pc = max(lift_2), max_precision_2pc = max(precision_2)) %>% 
  ungroup -> p1

# Plot Performance progress by batch number:
p1 %>% plotly::plot_ly(x = ~batch_number, y = ~max_gini, type = 'scatter', mode = 'lines') %>% 
  plotly::layout(title = 'GSS Gini progress')

p1 %>% plotly::plot_ly(x = ~batch_number, y = ~max_precision_2pc, type = 'scatter', mode = 'lines') %>% 
  plotly::layout(title = 'GSS Precision@2% progress')

# Gini progress in batches:
mp %>% 
  group_by(batch_number) %>% 
  summarise(mean_gini = mean(gini_coefficient), med_gini = median(gini_coefficient), max_gini = max(gini_coefficient)) %>% 
  ungroup -> g1


# best N models of each date:
N = 3
mp %>% 
  arrange(test_date, desc(gini_coefficient)) %>% 
  group_by(test_date) %>% 
  do({.[sequence(N),]}) %>% select(model_id, gini = gini_coefficient, lift_2pc = lift_2, precision_2pc = precision_2) -> bm
  
# features of the best N models:
scores %>% filter(model_id %in% bm$model_id) %>% 
  mutate(score = importance*gini_coefficient) %>% 
  filter(score > 0) %>% arrange(desc(score)) %>% 
  pull(feature_name) %>% unique -> fset

# best N features:
N = 830
scores %>% 
  mutate(score = importance*gini_coefficient) %>% 
  group_by(feature_name) %>% summarise(score = max(score)) %>% 
  filter(score > 0) %>% arrange(desc(score)) %>% head(N) %>% 
  pull(feature_name) -> fset

# fset %>% paste(collapse = "\n- ") %>% cat
# number of features progress in batches:
scores %>% 
  filter(test_date %in% config$dates) %>% 
  group_by(model_id, test_date, batch_number) %>% 
  summarise(num_feat = length(feature_name), num_nz_feat = sum(importance > 0),
            gini = max(gini_coefficient), lift_2pc = max(lift_2), precision_2pc = max(precision_2)) -> nf_model
nf_model %>% 
  group_by(test_date, batch_number) %>% 
  summarise(max_num_feat = max(num_feat), max_num_nz_feat = max(num_nz_feat),
            max_gini = max(gini), max_lift_2pc = max(lift_2pc), max(precision_2pc) = max(precision_2pc)) %>% 
  ungroup -> nf1

# 

# g1 %>% left_join(g2, by = 'batch_number') %>% 
#   plotly::plot_ly(x = ~batch_number, y = ~max_gini, type = 'area', name = 'GSS') %>% 
#   plotly::add_lines(x = ~batch_number, y = ~max_gini2, name = 'GSS2')




# features of the best model


######
# 
# s1 %>% distinct(model, test_date, batch_number, lift_2pc) %>% 
#   filter(test_date %in% config$dates) %>% 
#   group_by(batch_number) %>% 
#   summarise(mean_lift_2pc = mean(lift_2pc), med_lift_2pc = median(lift_2pc), max_lift_2pc = max(lift_2pc)) %>% 
#   ungroup -> l1
# 
# s2 %>% distinct(model, test_date, batch_number, lift_2pc) %>% 
#   filter(test_date %in% config$dates) %>% 
#   group_by(batch_number) %>% 
#   summarise(mean_lift_2pc2 = mean(lift_2pc), med_lift_2pc2 = median(lift_2pc), max_lift_2pc2 = max(lift_2pc)) %>% 
#   ungroup -> l2
# 
# l1 %>% left_join(l2, by = 'batch_number') %>% 
#   plotly::plot_ly(x = ~batch_number, y = ~max_lift_2pc, type = 'area', name = 'GSS') %>% 
#   plotly::add_lines(x = ~batch_number, y = ~max_lift_2pc2, name = 'GSS2')
