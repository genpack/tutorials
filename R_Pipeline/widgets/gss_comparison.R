source('R_Pipeline/initialize.R')

config = list()
config$input.scores_1 = 'gssc15_out.csv'
config$input.scores_2 = 'gssc13_out.csv'
config$dates = '2020-01-01'

config$input.scores_1 %<>% find_file(paths = paste(mc$path_reports, id_ml, 'greedy_subset_scorer', sep = '/'))
config$input.scores_2 %<>% find_file(paths = paste(mc$path_reports, id_ml, 'greedy_subset_scorer', sep = '/'))

config$input.scores_1 %>% bigreadr::fread2() -> s1
config$input.scores_2 %>% bigreadr::fread2() -> s2

######

s1$test_date %<>% as.character
s2$test_date %<>% as.character

s1 %>% distinct(model, test_date, batch_number, gini) %>% 
  filter(test_date %in% config$dates) %>% 
  group_by(batch_number) %>% 
  summarise(mean_gini = mean(gini), med_gini = median(gini), max_gini = max(gini)) %>% 
  ungroup -> g1

s2 %>% distinct(model, test_date, batch_number, gini) %>% 
  filter(test_date %in% config$dates) %>% 
  group_by(batch_number) %>% 
  summarise(mean_gini2 = mean(gini), med_gini2 = median(gini), max_gini2 = max(gini)) %>% 
  ungroup -> g2

g1 %>% left_join(g2, by = 'batch_number') %>% 
  plotly::plot_ly(x = ~batch_number, y = ~max_gini, type = 'area', name = 'GSS') %>% 
  plotly::add_lines(x = ~batch_number, y = ~max_gini2, name = 'GSS2')

######

s1 %>% distinct(model, test_date, batch_number, lift_2pc) %>% 
  filter(test_date %in% config$dates) %>% 
  group_by(batch_number) %>% 
  summarise(mean_lift_2pc = mean(lift_2pc), med_lift_2pc = median(lift_2pc), max_lift_2pc = max(lift_2pc)) %>% 
  ungroup -> l1

s2 %>% distinct(model, test_date, batch_number, lift_2pc) %>% 
  filter(test_date %in% config$dates) %>% 
  group_by(batch_number) %>% 
  summarise(mean_lift_2pc2 = mean(lift_2pc), med_lift_2pc2 = median(lift_2pc), max_lift_2pc2 = max(lift_2pc)) %>% 
  ungroup -> l2

l1 %>% left_join(l2, by = 'batch_number') %>% 
  plotly::plot_ly(x = ~batch_number, y = ~max_lift_2pc, type = 'area', name = 'GSS') %>% 
  plotly::add_lines(x = ~batch_number, y = ~max_lift_2pc2, name = 'GSS2')
