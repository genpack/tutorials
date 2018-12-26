### linechart.R --------------------------
library(niragen)
library(googleVis)

source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/googleVis.R')

# Example 1:

df=data.frame(country=c("US", "GB", "BR"), 
              val1=c(10,13,14), 
              val2=c(23,12,32))

df %>% gvisLineChart(xvar = 'val1', yvar = 'val2') %>% plot


# viser Translation:
df %>% googleVis.line(x = 'val1', y = 'val2') %>% plot


# Example 2:

df=data.frame(
  country = c("US", "GB", "US", "BR"), 
  val1=c(10,13,14, 18), 
  val2=c(15,12,6, 11), 
  val3=c(23,12,32, 9))

gvisLineChart(df, "country", c("val1","val2", "val3"),
              options=list(
                series="[{targetAxisIndex: 0},
                {targetAxisIndex:1}]",
                vAxes="[{title:'Val 1'}, {title:'Val 2'}, {title:'Val 3'}]"
              )) %>% plot

# viser Translation:
df %>% googleVis.line(x = 'val1', y = 'val2') %>% plot

