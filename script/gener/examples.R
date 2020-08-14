library(gener)
library(magrittr)

my_table %>% filter(col_A == 2, col_b < 3, col_c < 7)
'my_table' %>% sql.filter(col_A = ' = 2', col_b = '> 3', col_b = '< 7')


