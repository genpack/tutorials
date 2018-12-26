### Gallery.R: --------------------------------------

# General Examples of googleVis gallery with niraVis Translation:
library(gener)
library(viser)
library(googleVis)
library(magrittr)

### Chart 1:
df=data.frame(country=c("US", "GB", "BR"), 
              val1=c(10,13,14), 
              val2=c(23,12,32))
Line <- gvisLineChart(df)

plot(Line)


# Translation:

df %>% viserPlot(x = 'country', y = list('val1', 'val2'), plotter = 'googleVis', type = 'line') %>% plot




### Chart 2:
df=data.frame(country=c("US", "GB", "BR"), 
              val1=c(10,13,14), 
              val2=c(23,12,32),
              val3=c(13,2,92))
Line2 <- gvisLineChart(df, "country", c("val1","val2", "val3"),
                       options=list(
                         series="[{targetAxisIndex: 1},
                         {targetAxisIndex:1}, {targetAxisIndex:1}]",
                         vAxes="[{title:'Left'}, {title:'Right'}, {title:'Ignore'}]"
                       ))
plot(Line2)

df %>% googleVis.line(x = 'country', y = list('val1', 'val2', 'val3'), ySide = 'Right') %>% plot

df %>% googleVis.line(x = 'country', y = 'val3', y2 = list('val1', 'val2'), config = list(yAxis.label = 'Left', y2Axis.label = 'Right')) %>% plot


### Chart 3:
Bar <- gvisBarChart(df)
plot(Bar)

# Translation:
df %>% googleVis.bar(y = 'country', x = list('val1', 'val2', 'val3')) %>% plot

### Chart 4:
Column <- gvisColumnChart(df)
plot(Column)

# Translation:
df %>% googleVis.bar(x = 'country', y = list('val1', 'val2', 'val3')) %>% plot

### Chart 5:
Area <- gvisAreaChart(df)
plot(Area)

# Translation:
df %>% googleVis.area(x = 'country', y = list('val1', 'val2', 'val3')) %>% plot

# Todo: continue the rest of charts

