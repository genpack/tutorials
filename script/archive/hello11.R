

################## FOLDER HTMLWIDGETS ===============================

###### Package plotly ==================================

### pie.R -------------------------------
library(magrittr)
library(dplyr)
library(gener)

library(plotly)
library(billboarder)
library(morrisjs)
library(rCharts)

source('../../packages/master/viser-master/R/plotly.R')
source('../../packages/master/viser-master/R/billboarder.R')
source('../../packages/master/viser-master/R/coffeewheel.R')
source('../../packages/master/viser-master/R/morrisjs.R')
source('../../packages/master/viser-master/R/nvd3.R')
source('../../packages/master/viser-master/R/rAmCharts.R')

# Example 1:
USPersonalExpenditure <- data.frame("Categorie"=rownames(USPersonalExpenditure), USPersonalExpenditure)
data <- USPersonalExpenditure[,c('Categorie', 'X1960')]

plot_ly(labels = data$Categorie, values = data$X1960, type = 'pie') %>%
  layout(title = 'United States Personal Expenditures by Categories in 1960',
         xaxis = list(showgrid = F, zeroline = F, showticklabels = FALSE),
         yaxis = list(showgrid = F, zeroline = F, showticklabels = FALSE))

# Translation:
plotly.pie(data, label = 'Categorie', theta = 'X1960')

# with other packages:

billboarder.pie(data, label = 'Categorie', theta = 'X1960')
coffeewheel.pie(data, label = 'Categorie', theta = 'X1960')
morrisjs.pie(data, label = 'Categorie', theta = 'X1960', color = c('blue', 'orange', 'green', 'red', 'purple'))
nvd3.pie(data, label = 'Categorie', theta = 'X1960')
rAmCharts.pie(data, label = 'Categorie', theta = 'X1960')



# with subplots:
plot_ly() %>%
  add_pie(data = count(diamonds, cut), labels = ~cut, values = ~n,
          name = "Cut", domain = list(x = c(0, 0.4), y = c(0.4, 1))) %>%
  add_pie(data = count(diamonds, color), labels = ~cut, values = ~n,
          name = "Color", domain = list(x = c(0.6, 1), y = c(0.4, 1))) %>%
  add_pie(data = count(diamonds, clarity), labels = ~cut, values = ~n,
          name = "Clarity", domain = list(x = c(0.25, 0.75), y = c(0, 0.6))) %>%
  layout(title = "Pie Charts with Subplots", showlegend = F,
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

# todo: Translation 


# Example 2:
Animals <- c("giraffes", "orangutans", "monkeys", "giraffes", "giraffes","orangutans","monkeys")
SF_Zoo <- c(20, 14, 23, 12, 17, 21, 11)
LA_Zoo <- c(12, 18, 29, 14, 19, 27, 16)
NY_Zoo <- c(2,  NA, 19, 21, 50,  1, 0)
data <- data.frame(Animals, SF_Zoo, LA_Zoo, NY_Zoo)

plot_ly(labels = data$Animals, values = data$SF_Zoo, type = 'pie') %>%
  layout(title = 'Hello World',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

# Translation
plotly.pie(data, label = 'Animals', theta = 'SF_Zoo')

# todo: fix it
plotly.pie.old(data, theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo'))
plotly.pie.old(data, theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo'), label = 'Animals')

### bubble.R -------------------------------
# Example 1: Numbers of School Earning by Sex

library(plotly)

data <- read.csv("widgets/plotly/data/school_earnings.csv")

data$Women = as.numeric(data$Women)
data$Men   = as.numeric(data$Men)
data$Gap   = as.numeric(data$Gap)
data$School   = as.character(data$School)

# This does not work!
plot_ly(data, x = ~Women, y = ~Men, type = 'scatter', mode = 'markers', 
        marker = list(size = ~Gap, opacity = 0.5)) %>%
  layout(title = 'Numbers of School Earning by Sex',
         xaxis = list(showgrid = FALSE),
         yaxis = list(showgrid = FALSE))

# This works!
p = plot_ly(x = data$Women, y = data$Men, type = 'scatter', mode = 'markers', 
            marker = list(size = data$Gap, opacity = 0.5)) %>%
  layout(title = 'Numbers of School Earning by Sex',
         xaxis = list(showgrid = FALSE),
         yaxis = list(showgrid = FALSE))



# viser Translation:

data %>% plotly.scatter(x = 'Women', y = 'Men', size = 'Gap') # todo: 

### tsline.R -------------------------------
library(plotly)
library(dplyr)

source('../../packages/master/gener-master/R/gener.R')

source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/plotly.R')
source('../../packages/master/viser-master/R/jscripts.R')

#####################################

today <- Sys.Date()
tm <- seq(0, 600, by = 10)
x <- today - tm
y <- rnorm(length(x))
p <- plot_ly(x = ~x, y = ~y, mode = 'lines', text = paste(tm, "days from today"))

# viser translation:

data.frame(x = x, y = y) %>% plotly.tsline(x = 'x', y = 'y')


#####################################



p <- plot_ly(economics, x = date, y = uempmed) %>%
  add_trace(y = fitted(loess(uempmed ~ as.numeric(date))), x = date) %>%
  layout(title = "Median duration of unemployment (in weeks)",
         showlegend = FALSE) %>%
  dplyr::filter(uempmed == max(uempmed)) %>%
  layout(annotations = list(x = date, y = uempmed, text = "Peak", showarrow = T))




### bar.R -------------------------------
library(plotly)
library(magrittr)
library(dplyr)

library(highcharter)

source('../../packages/master/gener-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/highcharter.R')
source('../../packages/master/viser-master/R/plotly.R')
source('../../packages/master/viser-master/R/viserPlot.R')
source('../../packages/master/viser-master/R/jscripts.R')
source('../../packages/master/viser-master/R/dygraphs.R')


# This does not work!
Animals <- c("giraffes", "orangutans", "monkeys")
SF_Zoo <- c(20, 14, 23)
LA_Zoo <- c(12, 18, 29)
NY_Zoo <- c(15, 16, 21)
DR_Zoo <- c(13, 19, 7)
data <- data.frame(Animals, SF_Zoo, LA_Zoo, NY_Zoo, DR_Zoo)
# works in the fucking new version!

plot_ly(data, x = ~Animals, y = ~SF_Zoo, type = 'bar', name = 'SF Zoo') %>%
  add_trace(y = ~LA_Zoo, name = 'LA Zoo') %>%
  add_trace(y = ~NY_Zoo, name = 'NY Zoo') %>%
  add_trace(y = ~DR_Zoo, name = 'DR Zoo') %>%
  layout(yaxis = list(title = 'Count'), barmode = 'group')


# Translation:
viserPlot(obj = data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'plotly', type = 'combo')

p = c3.combo(obj = data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar')

data %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  candela.bar.molten(x = 'Animals', y = 'value', color = 'Group')

p = viserPlot(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dimple', type = 'combo')

p = viserPlot(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dygraphs', type = 'combo')

p %>% subplot(p, nrows = 3, shareY = T)  # What is this?!


# Other types and packages:
h = viserPlot(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', type = 'combo', plotter = 'highcharter')
#d = dygraphs.combo(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar')
#r = rCharts.combo(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar')




plot(googleVis.line(data, x = 'Animals', y = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
plot(googleVis.bar(data, x = 'Animals', y = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
plot(googleVis.gauge(data, theta = 'SF_Zoo', label = 'Animals'))
plot(googleVis.gauge(data, theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
plot(googleVis.gauge(data[2,], theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))

### cookBook.R -------------------------------

# https://cpsievert.github.io/plotly_book/scatter-traces.html#line-plots

library(plotly)
library(magrittr)
library(htmlwidgets)
library(dygraphs)
library(shiny)
library(dplyr)

source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/dygraphs.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/plotly.R')


subplot(
  plot_ly(mpg, x = ~cty, y = ~hwy, name = "default"),
  plot_ly(mpg, x = ~cty, y = ~hwy) %>% 
    add_markers(alpha = 0.2, name = "alpha"),
  plot_ly(mpg, x = ~cty, y = ~hwy) %>% 
    add_markers(symbol = I(1), name = "hollow")
)

# Translation:  
subplot(
  mpg %>% plotly.scatter(x = 'cty', y = list(default = 'hwy')),
  # Not added opacity yet! chart skipped
  mpg %>% plotly.scatter(x = 'cty', y = list(hollow = 'hwy'), shape = 'circle_hollow')
)

# Discover:
# try z dim:
plot_ly(mpg, x = ~cty, y = ~hwy, z = ~displ, name = "default", type = 'scatter3d')



# Chart 2:


subplot(
  plot_ly(x = 1:25, y = 1:25, symbol = I(1:25), name = "pch"),
  plot_ly(mpg, x = ~cty, y = ~hwy, symbol = ~cyl, 
          symbols = 1:3, name = "cyl")
)

# Translation
subplot(
  data.frame(x = 1:25, y = 1:25) %>% 
    plotly.scatter(x = 'x', y = list(pch = 'y'), shape = 1:25),
  mpg %>% plotly.scatter(x = 'cty', y = list(cyl = 'hwy'), shape = list(shape = 'cyl'))
)


# Chart 3:

p <- plot_ly(mpg, x = ~cty, y = ~hwy, alpha = 0.3) 
subplot(
  add_markers(p, symbol = ~cyl, name = "A single trace"),
  add_markers(p, symbol = ~factor(cyl), color = I("black"))
)

# Translation:
subplot(
  # First chart skipped: Opacity not introduced yet!
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', shape = mpg$cyl %>% as.factor, color = 'black')
)


# Chart 4:

p <- plot_ly(mpg, x = ~cty, y = ~hwy, alpha = 0.5)
subplot(
  add_markers(p, color = ~cyl, showlegend = FALSE) %>% 
    colorbar(title = "Viridis"),
  add_markers(p, color = ~factor(cyl))
)

# todo: does not show viridis on the colorbar and the second legend is hidden under the colorbar
subplot(
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = list(viridis = 'cyl')), 
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = mpg$cyl %>% as.factor)
)


# Chart 5:

col1 <- c("#132B43", "#56B1F7")
col2 <- viridisLite::inferno(10)
col3 <- colorRamp(c("red", "white", "blue"))
subplot(
  add_markers(p, color = ~cyl, colors = col1) %>%
    colorbar(title = "ggplot2 default"),
  add_markers(p, color = ~cyl, colors = col2) %>% 
    colorbar(title = "Inferno"),
  add_markers(p, color = ~cyl, colors = col3) %>% 
    colorbar(title = "colorRamp")
) %>% hide_legend()

# Translation:
subplot(
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = 'cyl', config = list(colorPalette = col1)),
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = 'cyl', config = list(colorPalette = col2)),
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = 'cyl', config = list(colorPalette = col3))
)


# Chart 6:

col1 <- "Pastel1"
col2 <- colorRamp(c("red", "blue"))
col3 <- c(`4` = "red", `5` = "black", `6` = "blue", `8` = "green")
subplot(
  add_markers(p, color = ~factor(cyl), colors = col1),
  add_markers(p, color = ~factor(cyl), colors = col2),
  add_markers(p, color = ~factor(cyl), colors = col3)
) %>% hide_legend()


# Translation: 
subplot(
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = mpg$cyl %>% as.factor, config = list(colorPalette = col1)),
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = mpg$cyl %>% as.factor, config = list(colorPalette = col2)),
  mpg %>% plotly.scatter(x = 'cty', y = 'hwy', color = mpg$cyl %>% as.factor, config = list(colorPalette = col3))
) %>% hide_legend()

# Just for test:
# todo: We need multiple colorPalettes for different series! So later, add this feature and define multiple palettes in config
mpg %>% plotly.scatter(x = 'cty', y = list('hwy','displ'), color = list(mpg$cyl %>% as.factor, mpg$drv %>% as.factor), config = list(colorPalette = col1))
mpg %>% highcharter.scatter(x = 'cty', y = list('hwy','displ'), color = list(mpg$cyl %>% as.factor, mpg$drv %>% as.factor), config = list(colorPalette = col1))

# Chart 7:
subplot(
  add_markers(p, size = ~cyl, name = "default"),
  add_markers(p, size = ~cyl, sizes = c(1, 500), name = "custom")
)

# Translation:
subplot(
  mpg %>% plotly.scatter(x = 'cty', y = list(default = 'hwy'), size = 'cyl'),
  mpg %>% plotly.scatter(x = 'cty', y = list(custom = 'hwy'), size = 'cyl', config = list(minSize = 1, maxSize = 500))
)


# Chart 8:

plot_ly(mpg, x = ~cty, y = ~hwy, z = ~cyl) %>%
  add_markers(color = ~cyl)

# Translation:

mpg %>% plotly.scatter(x = 'cty', y = 'hwy', z = 'cyl', color = 'cyl')



# Chart 9:


m <- lm(Sepal.Length~Sepal.Width*Petal.Length*Petal.Width, data = iris)
# to order categories sensibly arrange by estimate then coerce factor 
d <- broom::tidy(m) %>% 
  arrange(desc(estimate)) %>%
  mutate(term = factor(term, levels = term))
plot_ly(d, x = ~estimate, y = ~term) %>%
  add_markers(error_x = ~list(value = std.error), symbol = I(1)) %>%
  layout(margin = list(l = 200))

# Translation:
# Maybe: plotly.error() or a special case of plotly.box()
# Let's see similar functions in other packages
# Currently, you can have this feature by adding markers to the plotly output:
d %>% plotly.scatter(x = 'estimate', y = d$term %>% as.character, shape = 'bar')


# The Layered Grammar of Graphics:
# Chart 10:
library(dplyr)
tx <- 
  # initiate a plotly object with date on x and median on y
  txhousing %>% group_by(city) %>%
  plot_ly(x = ~date, y = ~median) %>% 
  add_lines(alpha = 0.2, name = "Texan Cities", hoverinfo = "none") %>% 
  add_lines(name = "Houston", data = filter(txhousing, city == "Houston"))
# todo:  We need to add function: plotly.molten() to consider a new argument as group

# Chart 11:
allCities <- txhousing %>%
  group_by(city) %>%
  plot_ly(x = ~date, y = ~median) %>%
  add_lines(alpha = 0.2, name = "Texan Cities", hoverinfo = "none")

allCities %>%
  filter(city == "Houston") %>%
  add_lines(name = "Houston")

# Chart 12:

allCities %>%
  add_fun(function(plot) {
    plot %>% filter(city == "Houston") %>% add_lines(name = "Houston")
  }) %>%
  add_fun(function(plot) {
    plot %>% filter(city == "San Antonio") %>% 
      add_lines(name = "San Antonio")
  })

# ... To be continued ...

### lineAndScatter.R -------------------------------
# https://plot.ly/r/line-and-scatter/

library(magrittr)
library(highcharter)
library(plotly)


source('C:/Nicolas/RCode/packages/master/gener-master/R/gener.R')
source('C:/Nicolas/RCode/packages/master/viser-master/R/visgen.R')
source('C:/Nicolas/RCode/packages/master/viser-master/R/highcharter.R')
source('C:/Nicolas/RCode/packages/master/viser-master/R/plotly.R')
source('C:/Nicolas/RCode/packages/master/viser-master/R/rCharts.R')

# Plot 1:
p <- plot_ly(data = iris, x = ~Sepal.Length, y = ~Petal.Length,
             marker = list(size = 10,
                           color = 'rgba(255, 182, 193, .9)',
                           line = list(color = 'rgba(152, 0, 0, .8)',
                                       width = 2))) %>%
  layout(title = 'Styled Scatter',
         yaxis = list(zeroline = FALSE),
         xaxis = list(zeroline = FALSE))

# Translation:
iris %>% plotly.scatter(x = 'Sepal.Length', y = 'Petal.Length', color = 'rgba(255, 182, 193, .9)', 
                        config = list(point.size = 10, point.border.color = 'rgba(152, 0, 0, .8)', point.border.width = 2))

# with other packages:

iris %>% highcharter.scatter.molten(x = 'Sepal.Length', y = 'Petal.Length', color = 'pink', size = 10,
                                    config = list(point.size = 10, point.border.color = 'rgba(152, 0, 0, .8)', point.border.width = 2))

# todo: config arguments for point.border... dont work

iris %>% rCharts.scatter.molten(x = 'Sepal.Length', y = 'Petal.Length', color = 'pink', size = 10, shape = 'bubble',
                                config = list(point.size = 10, point.border.color = 'rgba(152, 0, 0, .8)', point.border.width = 2))

# todo: argument color does not work

# A different view:

iris %>% plotly.scatter(x = 'Sepal.Length', y = 'Petal.Length', color = 'Petal.Length', size = 'Petal.Width',
                        config = list(point.border.color = 'rgba(152, 0, 0, .8)', point.border.width = 2, minSize = 10, maxSize = 50))


# Plot 2:

library(plotly)

trace_0 <- rnorm(100, mean = 5)
trace_1 <- rnorm(100, mean = 0)
trace_2 <- rnorm(100, mean = -5)
x <- c(1:100)

data <- data.frame(x, trace_0, trace_1, trace_2)

p <- plot_ly(data, x = ~x, y = ~trace_0, name = 'trace 0', type = 'scatter', mode = 'lines') %>%
  add_trace(y = ~trace_1, name = 'trace 1', mode = 'lines+markers') %>%
  add_trace(y = ~trace_2, name = 'trace 2', mode = 'markers')


# Translation:
data %>% plotly.scatter(x = 'x', y = list('Trace 0' = 'trace_0', 'Trace 1' = 'trace_1', 'Trace 2' = 'trace_2'), shape = list('line', 'line.point', 'point'))


# Plot 3: Shapes

library(plotly)

p <- plot_ly(data = iris, x = ~Sepal.Length, y = ~Petal.Length, type = 'scatter',
             mode = 'markers', symbol = ~Species, symbols = c('circle','x','o'),
             color = I('black'), marker = list(size = 10))

iris %>% plotly.scatter(x = 'Sepal.Length', y = 'Petal.Length', shape = 'Species', color = 'black', 
                        config = list(palette.shape = c('circle','x','o'), point.size = 10))


# Plot 4: Tooltip

p <- plot_ly(
  d, x = ~carat, y = ~price,
  # Hover text:
  text = ~paste("Price: ", price, '$<br>Cut:', cut),
  color = ~carat, size = ~carat
)

d %>% plotly.scatter(x = 'carat', y = 'price', color = 'carat', size = 'carat', tooltip = paste("Price: ", d$price, '$<br>Cut:', d$cut))

### example1.R -------------------------------
# Examples in page:
# https://plot.ly/r/

library(magrittr)
library(dplyr)

library(highcharter)
library(plotly)

source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/highcharter.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/plotly.R')
# These examples are old and many of them don't work in the new version!!
# Example 1: diamonds scatter plot:
set.seed(100)
d <- diamonds[sample(nrow(diamonds), 1000), ]
plot_ly(d, x = ~carat, y = ~price, color = ~carat,
        size = ~carat, text = ~paste("Clarity: ", clarity))

# Translation:

d %>% viserPlot(x = 'carat', y = 'price', shape = 'point', color = 'carat', size = 'carat', plotter = 'plotly', type = 'scatter')
d %>% highcharter.scatter.molten(x = 'carat', y = 'price', color = list(colour = 'carat'), size = list(Material = 'carat'))


d %>% ggplot(aes(x = carat, y = price, color = carat)) + geom_point()



# Suitable for:
# TIME.SERIES: Scatter plot of two numeric figures (each point is a timestamp)
# TEXT.MINER:  Scatter plot of MDS or PCA plot of texts

# Example 2: diamonds ggplot:
p <- ggplot(data = d, aes(x = carat, y = price, color = cut)) +
  geom_point(aes(text = paste("Clarity:", clarity)), size = 4) +
  geom_smooth(aes(colour = cut, fill = cut)) + facet_wrap(~ cut)
gg <- ggplotly(p)


# Example 3: economics time series plot:

str(p <- plot_ly(economics, x = date, y = uempmed))
p <- p %>%  add_trace(x = date, y = fitted(loess(uempmed ~ as.numeric(date), data = economics)))
p <- p %>%  add_trace(x = date, y = 0.0001*economics$pop - 15)
p <- p %>%  layout(title = "Median duration of unemployment (in weeks)", showlegend = FALSE)
p <- p %>%  dplyr::filter(uempmed == max(uempmed)) %>%
  layout(annotations = list(x = date, y = uempmed, text = "Peak", showarrow = T))

# TIME.SERIES: History of a single or multiple numeric values together with their traces (like predicted values or mov. averages or seasonality components)


library(plotly)
now_ct <- as.POSIXct(Sys.time())
tm <- seq(0, 600, by = 10)
x <- now_ct - tm
y <- rnorm(length(x))
p <- plot_ly(x = ~x, y = ~y, text = paste(tm, "seconds from now in", Sys.timezone()), type = 'scatter', mode = 'bar')

data.frame(time = x, value = y) %>% plotly.scatter(x = 'time', y = 'value', shape = 'line')



### examples.R -------------------------------
# https://plot.ly/r/
### rGraphGallery.R -------------------------------
# http://www.r-graph-gallery.com/portfolio/interactive-r-graphics/
### canUexplainThis.R -------------------------------
library(magrittr)
library(highcharter)
dta = data.frame(x = 0:11, y = 0:11)

highchart() %>% hc_add_series(data = dta, name = "Hello", type = 'line')
dta[,1] = c(7.0,  8.5,  8.8,  1.1,  9.9,  7.7,  6.6,  2.2, 13.2, 12.1, 11.0,  3.3)
dta[,1] = c(7.0,  8.7,  8.8,  1.1,  9.9,  7.7,  6.6,  2.2, 13.2, 12.1, 11.0,  3.3)

### map.R -------------------------------
library(plotly)
df <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv")
df$hover <- with(df, paste(state, '<br>', "Beef", beef, "Dairy", dairy, "<br>",
                           "Fruits", total.fruits, "Veggies", total.veggies,
                           "<br>", "Wheat", wheat, "Corn", corn))
# give state boundaries a white border
l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'australia',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

p <- plot_geo(df, locationmode = 'USA-states') %>%
  add_trace(
    z = df$total.exports, text = df$hover, locations = df$code,
    color = df$total.exports, colors = 'Blues'
  ) %>%
  colorbar(title = "Millions USD") %>%
  layout(
    title = '2011 US Agriculture Exports by State<br>(Hover for breakdown)',
    geo = g
  )

# plotly map can only show US states and world countries and does not go into suburbs or even states of any countries other than US
### subplots.R -------------------------------
p <- economics %>%
  tidyr::gather(variable, value, -date) %>%
  transform(id = as.integer(factor(variable))) %>%
  plot_ly(x = ~date, y = ~value, color = ~variable, colors = "Dark2",
          yaxis = ~paste0("y", id)) %>%
  add_lines() %>%
  subplot(nrows = 5, shareX = TRUE)


### surface.R -------------------------------

library(plotly)

plot_ly(z = volcano, type = "surface")
###### Package rAmCharts ==================================

### bullet.R -------------------------------
library(rAmCharts)
library(tibble)
library(dplyr)

source('../../packages/master/gener-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/rAmCharts.R')


# plot. 1
amBullet(value = 65)

# viser translation

amCharts.bullet(y = 65)

### box.R -------------------------------
library(rAmCharts)
library(tibble)
library(dplyr)

source('../../packages/master/gener-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/rAmCharts.R')


# plot. 1
dataset <- get(x = "ChickWeight", pos = "package:datasets")
amBoxplot(weight~Diet, data=dataset)

# viser translation:

dataset %>% amCharts.box(y = 'Diet', x = 'weight')

### bar.R -------------------------------
library(rAmCharts)
library(tibble)
library(dplyr)

source('../../packages/master/gener-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/rAmCharts.R')


# plot. 1

data("data_bar")
head(data_bar)

a = amBarplot(x = "country", y = "visits", data = data_bar, labelRotation = -45) 

# Translation:
data_bar %>% rAmCharts.bar(x = "country", y = "visits", config = list(xLabelsRotation = -45))

# Colors are different, don't know why yet!


b = amBarplot(x = "country", y = "visits", data = data_bar, horiz = TRUE)
b

# Translation:
data_bar %>% rAmCharts.bar(y = "country", x = "visits")



# plot. 2

data("data_gbar")
head(data_gbar)

a = amBarplot(x = "year", y = c("income", "expenses"), data = data_gbar)

# Translation:

data_gbar %>% rAmCharts.bar(x = "year", y = list("income", "expenses"))



# plot. 3

dataset <- data.frame(get(x = "USArrests", pos = "package:datasets"))
a = amBarplot(y = c("Murder", "Assault", "UrbanPop", "Rape"), data = dataset, stack_type = "regular")
# good for: 
# TIME.SERIES: show multiple numeric figures on top of each other

# Translation:
dataset %>% rownames_to_column %>%
  rAmCharts.bar(x = 'rowname', y = list("Murder", "Assault", "UrbanPop", "Rape"), data = dataset, config = list(barMode = 'stack'))


### funnel.R -------------------------------
library(rAmCharts)

data("data_funnel")
head(data_funnel)

amFunnel(data = data_funnel, inverse = TRUE)

# viser translation:

data_funnel %>% amCharts.funnel(y = 'value', label = 'description', config = list(direction = 'down.up'))

### gauge.R -------------------------------
library(rAmCharts)

amAngularGauge(x = 25)

bands = data.frame(start = c(0, 40, 60), end = c(40, 60, 100), 
                   color = c("#00CC00", "#ffac29", "#ea3838"),
                   stringsAsFactors = FALSE)

amAngularGauge(x = 25, bands = bands)

# viser translation:

zone = list()
zone[[1]] = list(min = 0 , max = 40 , color = "#00CC00")
zone[[2]] = list(min = 40, max = 60 , color = "#ffac29")
zone[[3]] = list(min = 60, max = 100, color = "#ea3838")

amCharts.gauge(theta = 25, config = list(thetaAxis.zone = zone))



### tsline.R -------------------------------
library(rAmCharts)
library(dplyr)
library(tibble)
library(pipeR)

source('../../packages/master/gener-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/amCharts.R')


data('data_stock_2')

# Chart 1:

amTimeSeries(data_stock_2, 'date', c('ts1', 'ts2'), linetype = NULL, linewidth = 1, bulletSize = NULL)

# Translation:
data_stock_2 %>% amCharts.tsline(t = 'date', y = list('ts1', 'ts2'))



# Chart 2:
amTimeSeries(data_stock_2, 'date', c('ts1', 'ts2'), bullet = 'round',
             groupToPeriods = c('hh', 'DD', '10DD'),
             linewidth = c(3, 1))

# Translation:
data_stock_2 %>% rAmCharts.tsline(t = 'date', y = list('ts1', 'ts2'), shape = 'line.point', 
                                  config = list(line.width = c(3,1)), groupToPeriods = c('hh', 'DD', '10DD'))

# Chart 3:
data("data_stock_2")
data_stock_2 <- data_stock_2[1:50, ]
data_stock_2$ts1low <- data_stock_2$ts1-100
data_stock_2$ts1up  <- data_stock_2$ts1+100
amTimeSeries(data_stock_2, "date", list(c("ts1low", "ts1", "ts1up"), "ts2"), 
             color = c("red", "blue"), bullet = c("round", "square"))

# Translation:
data_stock_2 %>% rAmCharts.tsline(t = 'date', y = list('ts1', 'ts2'), shape = list('line.point', 'line.square'),
                                  low = 'ts1low', high = 'ts1up', color = list('red', 'blue'))


# Chart 4:
amTimeSeries(data_stock_2, 'date', c('ts1', 'ts2'), aggregation = 'Sum', legend = TRUE,
             maxSeries = 1300, group = 'a')

# Translation:
data_stock_2 %>% rAmCharts.tsline(t = 'date', y = list('ts1', 'ts2'), 
                                  aggregation = 'Sum', maxSeries = 1300, group = 'a', config = list(legend = T))



# Chart 5:
data('data_stock_2')
ZoomButton <- data.frame(Unit = c('DD', 'DD', 'MAX'), multiple = c(1, 10 ,1),
                         label = c('Day','10 days', 'MAX'))
amTimeSeries(data_stock_2, 'date', c('ts1', 'ts2'), bullet = 'round',
             ZoomButton = ZoomButton, main = 'My title',
             ylab = 'Interest', export = TRUE,
             creditsPosition = 'bottom-left', group = 'a')


# Translation:
data_stock_2 %>% rAmCharts.tsline(t = 'date', y = list('ts1', 'ts2'), shape = 'line.point', 
                                  config = list(title = 'My title', yAxis.label = 'Interest'),
                                  export = TRUE, ZoomButton = ZoomButton, creditsPosition = 'bottom-left', group = 'a')

### pie.R -------------------------------
library(rAmCharts)
library(dplyr)
library(tibble)
library(pipeR)

source('../../packages/master/gener-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/rAmCharts.R')

data("data_pie")
head(data_pie)

a = amPie(data = data_pie)

amPie(data = obj)

# Suitable objects:
# TIME.SERIES: Over a period, show counts of appearances of a categorical factor as percentages.
#              Total counts add up to the number of days(time intervals) in the selected period.
# TIME.SERIES: For a certain time (like current time), shows a set of numeric figures (in percentage or actual values)
#              The whole circle represents sum of those figures in a certain day
# TIME.SERIES: Over a period, shows the distribution of a numeric figure binned to equal or unequal intervals
# TEXT.MINER:  shows distribution of texts in clusters (Clusters can be labled)
# STORE.GROUP; shows a figure (demand, balance, order ..., tot.cost) over a set of store for a certain day

# All the 'certain day' cases can be applied to a period considering sum or mean of values of the numeric figures

# Translation:
data_pie %>% rAmCharts.pie(theta = 'value', label = 'label')


# Other packages:

data_pie %>% billboarder.pie(theta = 'value', label = 'label')

### example_piechart.R -------------------------------
library(rAmCharts)
library(dplyr)
library(tibble)
library(pipeR)

source('../../packages/master/viser-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/rAmCharts.R')

data("data_pie")
head(data_pie)

a = amPie(data = data_pie)

amPie(data = obj)

# Suitable objects:
# TIME.SERIES: Over a period, show counts of appearances of a categorical factor as percentages.
#              Total counts add up to the number of days(time intervals) in the selected period.
# TIME.SERIES: For a certain time (like current time), shows a set of numeric figures (in percentage or actual values)
#              The whole circle represents sum of those figures in a certain day
# TIME.SERIES: Over a period, shows the distribution of a numeric figure binned to equal or unequal intervals
# TEXT.MINER:  shows distribution of texts in clusters (Clusters can be labled)
# STORE.GROUP; shows a figure (demand, balance, order ..., tot.cost) over a set of store for a certain day

# All the 'certain day' cases can be applied to a period considering sum or mean of values of the numeric figures

# Translation:
data_pie %>% rAmCharts.pie(theta = 'value', label = 'label')



### example_multi_dataset.R -------------------------------
library(rAmCharts)
library(dplyr)
library(pipeR)

data(data_stock_3)
amStockMultiSet(data = data_stock_3)
# Use this for Time Series plot


###### Package rbokeh ==================================
### preview.R -------------------------------
# https://hafen.github.io/rbokeh/index.html#preview

library(rbokeh)
source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/rbokeh.R')

# Chart 1:
figure() %>%
  ly_points(x = 'Sepal.Length', y = 'Sepal.Width', data = iris,
            color = Species, glyph = Species,
            hover = list(Sepal.Length, Sepal.Width))


# Translation:

iris %>% rbokeh.scatter(x = 'Sepal.Length', y = 'Sepal.Width', color = 'Species', shape = 'Species', config = list(tooltip = c('Sepal.Length', 'Sepal.Width')))


# Chart 2:

z <- lm(dist ~ speed, data = cars)
figure(width = 600, height = 600) %>%
  ly_points(cars, hover = cars) %>%
  ly_lines(lowess(cars), legend = "lowess") %>%
  ly_abline(z, type = 2, legend = "lm")

# Translation:

cars %>% rbokeh.scatter(x = 'speed', y = list('dist', lowess = lowess(cars)$y), shape = list('bar', 'line'))
# Need to work on it

###### Package rChartsCalmap ==================================
### calendar.R -------------------------------

dat <- read.csv('widgets/rChartsCalmap/data/paul_george_rs_data.csv')[,c('date', 'pts')]

library(rChartsCalmap)

calheatmap(x = 'date', y = 'pts',
           data = dat, 
           domain = 'week',
           subDomain = 'day',
           subDomainTextFormat = "%d",
           start = "2012-10-27",
           legend = seq(10, 50, 10),
           cellSize = 50,
           cellPadding = 15,
           range = 3,
           domainLabelFormat= "%d/%m"
)


# viser translation:

source('../../packages/master/gener-master/R/gener.R')
source('../../packages/master/viser-master/R/visgen.R')
source('../../packages/master/viser-master/R/calheatmap.R')

dat %>% calheatmap.calendar(t = 'date', color = 'pts')





library(quantmod)
getSymbols("AAPL")
xts_to_df <- function(xt){
  data.frame(
    date = format(as.Date(index(xt)), '%Y-%m-%d'),
    coredata(xt)
  )
}

dat = xts_to_df(AAPL)
calheatmap('date', 'AAPL.Adjusted', 
           data = dat, 
           domain = 'month',
           legend = seq(500, 700, 40),
           start = '2014-01-01',
           itemName = '$$'
)

###### Package rhandsontable ==================================
### simpleExample.R -------------------------------
library(rhandsontable)
DF = data.frame(int = 1:10,
                numeric = rnorm(10),
                logical = TRUE,
                character = LETTERS[1:10],
                fact = factor(letters[1:10]),
                date = seq(from = Sys.Date(), by = "days", length.out = 10),
                time = seq(from = Sys.Date(), by = "days", length.out = 10) %>% as.POSIXct, # Remember: if you put a POSIXlt or POSIXct column type into rhandsontable(), function hot_to_r does not work and the value is shown as string
                stringsAsFactors = FALSE)

# add a sparkline chart
DF$chart = sapply(1:10, function(x) jsonlite::toJSON(list(values=rnorm(10))))

rhandsontable(DF, rowHeaders = NULL) %>%
  hot_col("chart", renderer = htmlwidgets::JS("renderSparkline"))


###### Package rHighcharts ==================================
### simple/ui.R -------------------------------
library(rHighcharts)
shinyUI(bootstrapPage(
  chartOutput("chart")
))


### simple/server.R -------------------------------
library(rHighcharts)
shinyServer(function(input, output) {
  output$chart <- renderChart({
    a <- rHighcharts:::Chart$new()
    a$title(text = "Fruits")
    a$data(x = c("Apples","Bananas","Oranges"), y = c(15, 20, 30), type = "pie", name = "Amount")
    return(a)
  })
})

###### Package sankeytreeR ==================================
### examples.R -------------------------------

library(d3r)
library(dplyr)
library(htmltools)
library(treemap)
library(sankeytreeR)

titan_tree <- as.data.frame(Titanic) %>%
  select(-Age) %>%
  group_by(Class, Sex, Survived) %>%
  summarise(Freq = sum(Freq)) %>%
  treemap(index=c("Class", "Sex", "Survived"), vSize="Freq", draw = F) %>%
  {.$tm} %>%
  rename(size = vSize) %>%
  mutate(color = mapply(
    function(Sex,Survived,color) {
      if(is.na(Sex)){ return("gray") }
      print(c(Sex,Survived,color))
      if(Sex=="Male" && is.na(Survived)){ return("cadetblue")}
      if(Sex=="Female" && is.na(Survived)){ return("pink")}
      if(!is.na(Survived)&&Survived=="No") {return("red")}
      if(!is.na(Survived)&&Survived=="Yes") {return("green")}
    },
    Sex,
    Survived,
    color,
    SIMPLIFY = FALSE
  )) %>%
  select(1:4, color) %>%
  d3_nest(value_cols=c("size","color"), root="Titanic", json = FALSE) %>%
  mutate(size = sum(Titanic), color="#F0F") %>%
  d3_json(strip=TRUE)

aa = sankeytree(titan_tree, maxLabelLength=15, treeColors=FALSE)

###### Package streamgraph ==================================
### tsarea.R -------------------------------

ggplot2movies::movies %>%
  select(year, Action, Animation, Comedy, Drama, Documentary, Romance, Short) %>%
  tidyr::gather(genre, value, -year) %>%
  group_by(year, genre) %>%
  tally(wt=value) -> dat

streamgraph(dat %>% as.data.frame, 'genre', 'n', 'year', interactive=TRUE) %>%
  sg_axis_x(20, "year", "%Y") %>%
  sg_fill_brewer("PuOr")


dat$year %<>% paste('01-01', sep = '-') %>% as.Date

dat %>% select(genre, n, year) %>% streamgraph.tsarea(x = 'year', y = 'n', group = 'genre') %>%
  sg_axis_x(20, "year", "%Y")

###### Package sunburstR ==================================
### app.R -------------------------------
server <- function(input,output,session){
  
  output$sunburst <- renderSunburst({
    #invalidateLater(1000, session)
    
    sequences <- sequences[sample(nrow(sequences),1000),]
    
    add_shiny(sunburst(sequences))
  })
  
  
  selection <- reactive({
    # input$sunburst_mouseover
    input$sunburst_click
  })
  
  output$selection <- renderText(selection())
}


ui<-fluidPage(
  sidebarLayout(
    sidebarPanel(
      
    ),
    
    # plot sunburst
    mainPanel(
      sunburstOutput("sunburst"),
      textOutput("selection")
    )
  )
)

shinyApp(ui = ui, server = server)

### click_event_handling.R -------------------------------
library(sunburstR)

# read in sample visit-sequences.csv data provided in source
#   https://gist.github.com/kerryrodden/7090426#file-visit-sequences-csv
sequences <- read.csv(
  system.file("examples/visit-sequences.csv",package="sunburstR")
  ,header = FALSE
  ,stringsAsFactors = FALSE
)

sb <- sunburst(sequences)

sb$x$tasks <- list(
  htmlwidgets::JS(
    "
    function(){
    //debugger;
    
    this.instance.chart.on('click',function(d){
    alert(d);
    });
    }
    "
  )
  )

sb

###### Package visNetwork ==================================
### examples.R -------------------------------
# minimal example
nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))

visNetwork(nodes, edges)

# add a title
visNetwork(nodes, edges, main = "visNetwork minimal example")
visNetwork(nodes, edges, main = list(text = "visNetwork minimal example",
                                     style = "font-family:Comic Sans MS;color:#ff0000;font-size:15px;text-align:center;"))

# and subtitle and footer
visNetwork(nodes, edges, main = "visNetwork minimal example",
           submain = "For add a subtitle", footer = "Fig.1 minimal example")

# customization adding more variables (see visNodes and visEdges)
nodes <- data.frame(id = 1:10, 
                    label = paste("Node", 1:10),                                 # labels
                    group = c("GrA", "GrB"),                                     # groups 
                    value = 1:10,                                                # size 
                    shape = c("square", "triangle", "box", "circle", "dot", "star",
                              "ellipse", "database", "text", "diamond"),         # shape
                    title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),         # tooltip
                    color = c("darkred", "grey", "orange", "darkblue", "purple"),# color
                    shadow = c(FALSE, TRUE, FALSE, TRUE, TRUE))                  # shadow

edges <- data.frame(from = sample(1:10,8), to = sample(1:10, 8),
                    label = paste("Edge", 1:8),                                 # labels
                    length = c(100,500),                                        # length
                    arrows = c("to", "from", "middle", "middle;to"),            # arrows
                    dashes = c(TRUE, FALSE),                                    # dashes
                    title = paste("Edge", 1:8),                                 # tooltip
                    smooth = c(FALSE, TRUE),                                    # smooth
                    shadow = c(FALSE, TRUE, FALSE, TRUE))                       # shadow

visNetwork(nodes, edges) 

# use more complex configuration : 
# when it's a list, you can use data.frame with specific notation like this
nodes <- data.frame(id = 1:3, color.background = c("red", "blue", "green"), 
                    color.highlight.background = c("red", NA, "red"), shadow.size = c(5, 10, 15))
edges <- data.frame(from = c(1,2), to = c(1,3),
                    label = LETTERS[1:2], font.color =c ("red", "blue"), font.size = c(10,20))

visNetwork(nodes, edges)


# highlight nearest
nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                    group = sample(LETTERS[1:3], 15, replace = TRUE))

edges <- data.frame(from = trunc(runif(15)*(15-1))+1,
                    to = trunc(runif(15)*(15-1))+1)

visNetwork(nodes, edges) %>% visOptions(highlightNearest = TRUE)

# try an id node selection 
visNetwork(nodes, edges) %>% 
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)

# or add a selection on another column
visNetwork(nodes, edges) %>% 
  visOptions(selectedBy = "group")

nodes$sel <- sample(c("sel1", "sel2"), nrow(nodes), replace = TRUE)
visNetwork(nodes, edges) %>% 
  visOptions(selectedBy = "sel")

# add legend
visNetwork(nodes, edges) %>% visLegend()

# directed network
visNetwork(nodes, edges) %>% 
  visEdges(arrows = 'from', scaling = list(min = 2, max = 2))

# custom navigation
visNetwork(nodes, edges) %>%
  visInteraction(navigationButtons = TRUE)

# data Manipulation
visNetwork(nodes, edges) %>% visOptions(manipulation = TRUE)

# Hierarchical Layout
visNetwork(nodes, edges) %>% visHierarchicalLayout()

# freeze network
visNetwork(nodes, edges) %>%
  visInteraction(dragNodes = FALSE, dragView = FALSE, zoomView = FALSE)

# use fontAwesome icons using groups or nodes options 
# font-awesome is not part of dependencies. use addFontAwesome() if needed
# http://fortawesome.github.io/Font-Awesome

nodes <- data.frame(id = 1:3, group = c("B", "A", "B"))
edges <- data.frame(from = c(1,2), to = c(2,3))

visNetwork(nodes, edges) %>%
  visGroups(groupname = "A", shape = "icon", icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", icon = list(code = "f007", color = "red")) %>%
  addFontAwesome()

nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))

visNetwork(nodes, edges) %>%
  visNodes(shape = "icon", icon = list( face ='FontAwesome', code = "f0c0")) %>%
  addFontAwesome()

# Save a network
## Not run: 
network <- visNetwork(nodes, edges) %>% 
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE,
             manipulation = TRUE) %>% visLegend()

network %>% visSave(file = "network.html")
# same as
visSave(network, file = "network.html")

## End(Not run)

# Export as png/jpeg (shiny or browser only)
## Not run: 
visNetwork(nodes, edges) %>% 
  visExport()

## End(Not run)

# DOT language
visNetwork(dot = 'dinetwork {1 -> 1 -> 2; 2 -> 3; 2 -- 4; 2 -> 1 }')

# gephi json file
## Not run: 
visNetwork(gephi = 'WorldCup2014.json') %>% visPhysics(stabilization = FALSE,   barnesHut = list(
  gravitationalConstant = -10000,
  springConstant = 0.002,
  springLength = 150
))

## End(Not run)

### edges.R -------------------------------
# http://datastorm-open.github.io/visNetwork/edges.html

## Example 1:

edges <- data.frame(from = sample(1:10,8), to = sample(1:10, 8),
                    
                    # add labels on edges                  
                    label = paste("Edge", 1:8),
                    
                    # length
                    length = c(100,500),
                    
                    # width
                    width = c(4,1),
                    
                    # arrows
                    arrows = c("to", "from", "middle", "middle;to"),
                    
                    # dashes
                    dashes = c(TRUE, FALSE),
                    
                    # tooltip (html or character)
                    title = paste("Edge", 1:8),
                    
                    # smooth
                    smooth = c(FALSE, TRUE),
                    
                    # shadow
                    shadow = c(FALSE, TRUE, FALSE, TRUE)) 

# head(edges)
#  from to  label length    arrows dashes  title smooth shadow
#    10  7 Edge 1    100        to   TRUE Edge 1  FALSE  FALSE
#     4 10 Edge 2    500      from  FALSE Edge 2   TRUE   TRUE

nodes <- data.frame(id = 1:10, group = c("A", "B"))
### nodes.R -------------------------------
# http://datastorm-open.github.io/visNetwork/nodes.html

library(visNetwork)
library(magrittr)
source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')

source('C:/Nicolas/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/visNetwork.R')


# Example 1:

nodes <- data.frame(id = 1:10,
                    # add labels on nodes
                    label = paste("Node", 1:10),
                    
                    # add groups on nodes 
                    group = c("GrA", "GrB"),
                    
                    # size adding value
                    value = 1:10,          
                    
                    # control shape of nodes
                    shape = c("square", "triangle", "box", "circle", "dot", "star",
                              "ellipse", "database", "text", "diamond"),
                    
                    # tooltip (html or character), when the mouse is above
                    title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),
                    
                    # color
                    color = c("darkred", "grey", "orange", "darkblue", "purple"),
                    
                    # shadow
                    shadow = c(FALSE, TRUE, FALSE, TRUE, TRUE))             

edges <- data.frame(from = c(1,2,5,7,8,10), to = c(9,3,1,6,4,7))

visNetwork(nodes, edges, height = "500px", width = "100%")

# Translation:
list(nodes = nodes, links = edges) %>% 
  visNetwork.graph(label = 'label', size = 'value', shape = 'shape', tooltip = 'title', color = 'color', source = 'from', target = 'to')

# Example 2:

nodes <- data.frame(id = 1:4)
edges <- data.frame(from = c(2,4,3,3), to = c(1,2,4,2))

visNetwork(nodes, edges, width = "100%") %>% 
  visNodes(shape = "square", 
           color = list(background = "lightblue", 
                        border = "darkblue",
                        highlight = "yellow"),
           shadow = list(enabled = TRUE, size = 10)) %>%
  visLayout(randomSeed = 12) # to have always the same network 

# Translation:
my_config = list(point.color = 'lightblue', 
                 point.shape = 'square',
                 point.border.color = 'darkblue',
                 point.highlight.color = 'yellow',
                 point.size = 10,
                 point.shadow.enabled = T,
                 point.shadow.size = 10)

list(nodes = nodes, links = edges) %>% 
  visNetwork.graph(source = 'from', target = 'to', config = my_config, width = "100%") %>%
  visLayout(randomSeed = 12)

# Example 3:

nodes <- data.frame(id = 1:3, 
                    color.background = c("red", "blue", "green"),
                    color.highlight.background = c("red", NA, "red"), 
                    shadow.size = c(5, 10, 15))

edges <- data.frame(from = c(1,2), to = c(1,3),
                    label = LETTERS[1:2], 
                    font.color =c ("red", "blue"), 
                    font.size = c(10,20))

visNetwork(nodes, edges)  

# Translation:
list(nodes = nodes, links = edges) %>% 
  visNetwork.graph(color = 'color.background', linkLabel = LETTERS[1:2], linkLabelColor = c('red', 'blue'), linkLabelSize = 'font.size', source = 'from', target = 'to', config = list(colorize = F))


### script/simpleExample.R -------------------------------

# Node Specifications:
# Example 1:

nodes <- data.frame(id = 1:10,
                    
                    # add labels on nodes
                    label = paste("Node", 1:10),
                    
                    # add groups on nodes 
                    group = c("GrA", "GrB"),
                    
                    # size adding value
                    value = 1:10,          
                    
                    # control shape of nodes
                    shape = c("square", "triangle", "box", "circle", "dot", "star",
                              "ellipse", "database", "text", "diamond"),
                    
                    # tooltip (html or character), when the mouse is above
                    title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),
                    
                    # color
                    color = c("darkred", "grey", "orange", "darkblue", "purple"),
                    
                    # shadow
                    shadow = c(FALSE, TRUE, FALSE, TRUE, TRUE))             

nodes <- data.frame(id = 1:10,
                    
                    # add labels on nodes
                    label = paste("Node", 1:10),
                    
                    # add groups on nodes 
                    group = c("GrA", "GrB"),
                    
                    # size adding value
                    size = c(1.0, 5.0, 7.0, 0.5, 15.0, as.numeric(1:5)),          
                    
                    # control shape of nodes
                    shape = 'dot',
                    
                    # tooltip (html or character), when the mouse is above
                    title = paste0("<p><b>", 1:10,"</b><br>Node !</p>"),
                    
                    # color
                    color = c("darkred", "grey", "orange", "darkblue", "purple"),
                    
                    # shadow
                    shadow = c(FALSE, TRUE, FALSE, TRUE, TRUE))             


# head(nodes)
# id  label group value    shape                     title    color shadow
#  1 Node 1   GrA     1   square <p><b>1</b><br>Node !</p>  darkred  FALSE
#  2 Node 2   GrB     2 triangle <p><b>2</b><br>Node !</p>     grey   TRUE

edges <- data.frame(from = c(1,2,5,7,8,10), to = c(9,3,1,6,4,7))

visNetwork(nodes, edges, height = "500px", width = "100%")



# Edge Specifications:
# Example 2:

edges <- data.frame(from = sample(1:10,8), to = sample(1:10, 8),
                    
                    # add labels on edges                  
                    label = paste("Edge", 1:8),
                    
                    # length
                    length = c(100,500),
                    
                    # width
                    width = c(4,1),
                    
                    # arrows
                    arrows = c("to", "from", "middle", "middle;to"),
                    
                    # dashes
                    dashes = c(TRUE, FALSE),
                    
                    # tooltip (html or character)
                    title = paste("Edge", 1:8),
                    
                    # smooth
                    smooth = c(FALSE, TRUE),
                    
                    # shadow
                    shadow = c(FALSE, TRUE, FALSE, TRUE))




nodes <- data.frame(id = c("a", "b", "c"), label = c("A", "B", "C"), value = c(0.1,0.5,0.8))
edges <- data.frame(from = c("a", "b", "c"), to = c("b","c", "a"), arrows = 'to')

visNetwork(nodes, edges) %>% visNodes(size = 30, title = "I'm a node", borderWidth = 3)

###### Package zingcharts ==================================
# ### test.html -------------------------------
# <!DOCTYPE html>
#   <html>
#   <head>
#   <!--Script Reference[1]-->
#   <script src="C:/Nicolas/RCode/packages/master/zingcharts-master/inst/htmlwidgets/lib/zing/zingchart.min.js"></script>
#   </head>
#   <body>
#   <!--Chart Placement[2]-->
#   <div id ='chartDiv'></div>
#   <script>
#   var chartData={
#     "type":"bar",  // Specify your chart type here.
#     "series":[  // Insert your series data here.
#                 { "values": [35, 42, 67, 89]},
#                 { "values": [28, 40, 39, 36]}
#                 ]
#   };
# zingchart.render({ // Render Method[3]
#   id:'chartDiv',
#   data:chartData,
#   height:400,
#   width:600
# });
# </script>
#   </body>
#   </html>
  

