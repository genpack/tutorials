###### Package: c3 ===================================
### examples.R -------------------------
# https://github.com/mrjoh3/c3
# examples.R

library(c3);
library(magrittr);

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niragen-master/R/linalg.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/c3.R')


# Chart 1:

data = data.frame(a = abs(rnorm(20) * 10),
                  b = abs(rnorm(20) * 10),
                  Label = LETTERS[1:20],
                  Time = Sys.time() + 5000*seq(20),
                  date = seq(as.Date("2014-01-01"), by = "month", length.out = 20))

data %>% c3

# Translation:
data %>% c3.combo(x = 0:19, y = list('a', 'b'))

# Another one:
data %>% c3.combo(x = 'Label', y = list('a', 'b'))


# Stupid package cannot plot only one series!! Should fix it later!!
# Try: data %>% c3.combo(x = 'c', y = 'a')


# Chart 2:

data %>% c3(x = 'date')

# Translation:
data %>% c3.combo(x = 'date', y = list('a', 'b'))

# If x is Date, it works with one series:!!
data %>% c3.combo(x = 'date', y = 'a')



# for test:
data %>% c3 %>% c3_mixedGeom(types = list(a = 'bar', b = 'bar', d = 'bar'), stacked = c('a', 'b'))

# Chart 3:

data$c = abs(rnorm(20) *10)
data$d = abs(rnorm(20) *10)

data %>% c3 %>%
  c3_mixedGeom(type = 'bar',
               stacked = c('b','d'),
               types = list(a='area',
                            c='spline'))

# Translation:
data %>% c3.combo(y = list('a', 'b', 'c', 'd'), shape = list('area', 'bar', 'bar', 'spline'), config = list(barMode = 'stack'))



# Chart 4:

iris %>%
  c3(x='Sepal_Length', y='Sepal_Width', group = 'Species') %>% 
  c3_scatter()

# todo: THis stupid package converts dot to underline!!!! take care of it later!
iris %>% c3.scatter.molten(x = list(Sepal_Length = 'Sepal.Length'), y = list(Sepal_Width = 'Sepal.Width'), group = 'Species')


# Continue the rest ...

# Donut:
data.frame(Iran=20,US=45,Denmark=10) %>%
  c3() %>%
  c3_donut(title = 'Countries')

data.frame(Country = c('Iran', 'US', 'Denmark'), Value = c(1,4,5)) %>% 
  c3.pie(theta = 'Value', label = 'Country')


# Gauge:
c3(data.frame(88)) %>% c3_gauge()

# niravis Translation:
88 %>% c3.gauge


