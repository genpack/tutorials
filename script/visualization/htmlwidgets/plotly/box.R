### box.R -------------------------------
library(magrittr)
library(plotly)

properties = read.csv('C:/Nima/RCode/packages/master/niravis-master/data/properties.csv' , as.is = T)
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/plotly.R')


### basic boxplot
plot_ly(y = rnorm(50), type = "box") %>%
  add_trace(y = rnorm(50, 1), type = "box")

# niravis translation:
ggplot2::diamonds %>% plotly.box(y = c(rnorm(50), rnorm(50)), x = c(rep('trace 1', 50), rep('trace 2', 50)))



### adding jittered points
plot_ly(x = rnorm(50), type = "box", boxpoints = "all", jitter = 0.3,
        pointpos = -1.8) %>%
  add_trace(x = rnorm(50, 1), type = "box", jitter = 0.3)


### several box plots
plot_ly(ggplot2::diamonds, y = ~price, color = ~cut, type = "box")

# dim 1 (X Axis): Categorical
# dim 2 (Y Axis): Numeric 
# dim 3 (Color): Categorical

### grouped box plots
plot_ly(ggplot2::diamonds, x = ~price, y = ~cut, color = ~clarity, type = "box") %>%
  layout(boxmode = "group")

# niravis Translation:
suppressWarnings(show(ggplot2::diamonds %>% plotly.box(y = 'cut', x = 'price', group = 'clarity')))
