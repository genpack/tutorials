### examples.R -------------------------------
library(magrittr)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')


# Line chart

morrisjs(mdeaths) %>% 
  mjsLine()


# Bar chart

morrisjs(mdeaths) %>% 
  mjsBar()

# Area chart

morrisjs(mdeaths) %>% 
  mjsArea()

# Donut chart
# For donuts, inputs should be a list of two elements: a vector of characters and a vector of numerics.

morrisjs(list(c("Label 1", "Label 2"), c(10, 20)), width =200, height = 200) %>% 
  mjsDonut(options = list(resize = T, colors = c('blue', 'red')))

# Translation:

data.frame(Labels = c("Label 1", "Label 2"), Values = c(10, 20), Colour = c('blue', 'red')) %>%
  morrisjs.pie(label = 'Labels', theta = 'Values', color = 'Colour', width = 200, height = 200, config = list(colorize = F))

# todo: try alternatives with point.color ,...

#Inputs

#For lines, areas and bars, inputs can be either ts, xts or mts:

morrisjs(mdeaths) %>% 
  mjsLine()

morrisjs(ts.union(fdeaths, mdeaths)) %>% 
  mjsLine()

# They can also be data.frames or tbl_dfs with the first column being of class Date:

df <- tibble::tibble(date = as.Date(c("2011-01-01", "2011-02-01", "2011-03-01")), 
                     series1 = rnorm(3), series2 = rnorm(3)) 
morrisjs(df) %>% 
  mjsLine(options = list(lineColors = c('blue', 'red'))) 


# Translate:

df %>% as.data.frame %>% morrisjs.tsline(t = 'date', y = list('series1', 'series2'), color = list('blue', 'red'))

df %>% as.data.frame %>% morrisjs.tsbar(t = 'date', y = list('series1', 'series2'), color = list('blue', 'red'))


# More arguments for options:
# http://morrisjs.github.io/morris.js/lines.html


# Does not work
# data.frame(x = LETTERS[1:5], y1 = 1:5, y2 = 5:1) %>% morrisjs %>% mjsBar(options = list(xkeys = 'x', ykeys = c('y1', 'y2')))



