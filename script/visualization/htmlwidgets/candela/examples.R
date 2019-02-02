
### examples.R ---------------------
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
  candela.bar.molten(x='mpg', y='wt', color='disp', config = list(aggregate.func = 'mean'))

candela('BarChart', data = mtcars %>% rownames2Column('Model'), x='Model', y='wt', aggregate = 'value')
# Translated to niravis:
mtcars %>% rownames2Column('Model') %>% candela.bar(x='Model', y='wt')


# Chart 2:

id = c('A', 'B', 'C')
class = c(0, 1, 1)
A = c(1.0, 0.5, 0.3)
B = c(0.5, 1.0, 0.2)
C = c(0.3, 0.2, 1.0)
data = data.frame(id, class, A, B, C)

candela('SimilarityGraph', data=data, id='id', color='class', threshold=0.4)
# The example does not work! Wait for the package bug to be fixed!


candela('ScatterPlot', data = mtcars %>% rownames2Column('Model'), x='disp', y='wt', color='Model', shape = 'vs')

mtcars %>% rownames2Column('Model') %>% candela.scatter(x='disp', y='wt', color='Model', shape = 'vs')
