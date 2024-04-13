# addfcl2scoring.R
# This script, joins feature clusters and feature scores from two tables into one table.

##### Setup ######
source('R_Pipeline/initialize.R')

##### Inputs: #####

input_scores = 'gssc2_out.csv'
input_clusters = 'fclc2_out.csv'
output = "%s/%s/greedy_subset_scorer/gssc2fclc2_out.csv" %>% sprintf(mc$path_reports, id_ml)

##### Read: #####
input_scores %<>% find_file(paste(mc$path_reports, id_ml, 
   c('', 'feature_correlation', 'subset_scorer', 'greedy_subset_scorer') %>% 
   c(mc$path_reports), sep = '/'))
input_clusters %<>% find_file(paste(mc$path_reports, id_ml, 'feature_clustering', sep = '/'))

scores   = bigreadr::fread2(input_scores)
clusters = read.csv(input_clusters)

##### Run: #####

scores %>% 
  mutate(score = importance*gini_coefficient) %>% 
  group_by(feature_name) %>% 
  summarise(max_score = max(score, na.rm = T)) %>% 
  ungroup %>% 
  left_join(clusters %>% rename(feature_name = fname), by = 'feature_name') %>% 
  rename(cluster = N365) %>% 
  na.omit %>% 
  write.csv(output)