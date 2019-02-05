###### Package: candela ===================================
### bar.R ---------------------
library(candela)
library(magrittr)
library(dplyr)

source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/candela.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/jscripts.R')


candela('BarChart', data=mtcars, x='mpg', y='wt', color='disp', aggregate = 'mean')
# Does not show anything !!!!

# Translated to niravis:
mtcars %>% mutate(mpg = as.character(mpg), disp = as.character(disp)) %>% 
  candela.bar(x='mpg', y='wt', color='disp', config = list(aggregator.function.string = 'mean'))

candela('BarChart', data = mtcars %>% rownames2Column('Model'), x='Model', y='wt', aggregate = 'value')

# Translated to niravis:
mtcars %>% rownames2Column('Model') %>% candela.bar(x='Model', y='wt')


