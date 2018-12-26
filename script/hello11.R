# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

hello <- function() {
  print("Hello, world!")
}





################## FOLDER HTMLWIDGETS ===============================

### threejs.R -------------------------
library(threejs)

# Example 1: scatter 3D:
z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
scatterplot3js(x, y, z, color=rainbow(length(z)))

# Example 2: # Example 2:

data(ego)
graphjs(ego, bg="black")

# Example 3: 

library(threejs)
data(LeMis)
N  <- length(V(LeMis))

# Vertex page rank values
pr <- page_rank(LeMis)$vector
# order the page rank values
i <- order(pr, decreasing=TRUE)

# Vertex cluster membership
cl <- unclass(membership(cluster_louvain(LeMis)))

# Find the index of the highest page rank vertex in each cluster
idx <- aggregate(seq(1:N)[i], by=list(cl[i]), FUN=head, 1)$x
# Create a default force-directed layout for the whole network
l1 <- norm_coords(layout_with_fr(LeMis, dim=3))
# Collapse the layout to just the idx vertices
l0 <- Reduce(rbind,Map(function(i) l1[idx[i],], cl))

# Grouped vertex colors, setting all but idx vertices transparent
col <- rainbow(length(idx), alpha=0)[cl]
col[idx] <- rainbow(length(idx), alpha=1)

click <- Map(function(i)
{
  x <- l0
  x[cl == i, ] <- l1[cl == i, ]
  c <- col
  c[cl == i] <- rainbow(length(idx), alpha=1)[i]
  list(layout=x, vertex.color=c)
}, seq(idx))
names(click) <- paste(idx)

graphjs(LeMis, layout=l0, click=click, vertex.color=col, fps=20, font.main="78px Arial")



### pie.R -------------------------
library(magrittr)
library(dplyr)
library(plotly)
library(highcharter)
library(reshape2)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/c3.R')
source('../../packages/master/niravis-master/R/candela.R')
source('../../packages/master/niravis-master/R/dimple.R')
source('../../packages/master/niravis-master/R/dygraphs.R')
source('../../packages/master/niravis-master/R/highcharter.R')
source('../../packages/master/niravis-master/R/nvd3.R')
source('../../packages/master/niravis-master/R/pivot.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')

source('../../packages/master/niravis-master/R/googleVis.R')

source('../../packages/master/niravis-master/R/niraPlot.R')
source('../../packages/master/niravis-master/R/jscripts.R')

### Simple dataset:
tbl = USPersonalExpenditure

# Translation:
niraPlot(obj = tbl, x = 'Animals', y = list('', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'plotly', type = 'bar', config = list(yAxis.label = 'Count'))

# Other plotters:
# C3:
niraPlot(obj = tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'c3', type = 'bar', config = list(yAxis.label = 'Count'))

# candela
cndl = tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  candela.bar.molten(x = 'Animals', y = 'value', color = 'Group')
# candela does not show the chart in the viewer


# dimple:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dimple', type = 'combo')
# todo: check how you can set yAxis label
# todo: check group barchart rather than stack
# todo: legend?!

# dygraphs:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dygraphs', type = 'combo')

# highcharter:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', type = 'combo', plotter = 'highcharter')


# nvd3:
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  niraPlot(x = 'Animals', y = 'value', group = 'Group', shape = 'bar', type = 'bar.molten', plotter = 'nvd3')

# pivot
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  pivot(rows = 'Group', cols = 'Animals', aggregatorName = 'Sum', vals = 'value', rendererName = 'Bar Chart', )

# billboarder:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'billboarder', type = 'bar')
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  niraPlot(x = 'Animals', y = 'value', group = 'Group', shape = 'bar', type = 'bar.molten', plotter = 'billboarder')


# rAmCharts:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), type = 'bar', plotter = 'rAmCharts')


#r = rCharts.combo(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar')

# googleVis:
plot(googleVis.bar(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
# Does not show! Check it!


# plot(googleVis.gauge(tbl, theta = 'SF_Zoo', label = 'Animals'))
# plot(googleVis.gauge(tbl, theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
# plot(googleVis.gauge(tbl[2,], theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))

### lolipop.R -------------------------
library(magrittr)
library(dplyr)
library(mutsneedle)
library(reshape2)

source('C:/Nima/RCode/packages/master/niragen-master/R/niragen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')

source('C:/Nima/RCode/packages/master/niravis-master/R/niraPlot.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/jscripts.R')

### Simple dataset:
library(shiny)
library(mutsneedle)
library(htmlwidgets)

shinyApp(
  ui = mutsneedleOutput("id",width=800,height=500),
  server = function(input, output) {
    output$id <- renderMutsneedle(
      data <- exampleMutationData(),
      regiondata <- exampleRegionData(),
      mutsneedle(mutdata=data,domains=regiondata)
    )
  }
)

### bar.R -------------------------
library(magrittr)
library(dplyr)
library(plotly)
library(highcharter)
library(reshape2)

source('C:/Nima/RCode/packages/master/niragen-master/R/niragen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/plotly.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/c3.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/candela.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/dimple.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/dygraphs.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/highcharter.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/nvd3.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/pivot.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/billboarder.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/rAmCharts.R')

source('C:/Nima/RCode/packages/master/niravis-master/R/googleVis.R')

source('C:/Nima/RCode/packages/master/niravis-master/R/niraPlot.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/jscripts.R')

### Chart 1:
# This does not work!
Animals <- c("giraffes", "orangutans", "monkeys")
SF_Zoo <- c(20, 14, 23)
LA_Zoo <- c(12, 18, 29)
NY_Zoo <- c(15, 16, 21)
DR_Zoo <- c(13, 19, 7)
tbl <- data.frame(Animals, SF_Zoo, LA_Zoo, NY_Zoo, DR_Zoo)
# works in the fucking new version!

plot_ly(tbl, x = ~Animals, y = ~SF_Zoo, type = 'bar', name = 'SF Zoo') %>%
  add_trace(y = ~LA_Zoo, name = 'LA Zoo') %>%
  add_trace(y = ~NY_Zoo, name = 'NY Zoo') %>%
  add_trace(y = ~DR_Zoo, name = 'DR Zoo') %>%
  layout(yaxis = list(title = 'Count'), barmode = 'group')


# Translation:
niraPlot(obj = tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'plotly', type = 'bar', config = list(yAxis.label = 'Count'))

# Other plotters:
# C3:
niraPlot(obj = tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'c3', type = 'bar', config = list(yAxis.label = 'Count'))

# candela
cndl = tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  candela.bar.molten(x = 'Animals', y = 'value', color = 'Group')
# candela does not show the chart in the viewer


# dimple:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dimple', type = 'combo')
# todo: check how you can set yAxis label
# todo: check group barchart rather than stack
# todo: legend?!

# dygraphs:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dygraphs', type = 'combo')

# highcharter:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', type = 'combo', plotter = 'highcharter')


# nvd3:
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  niraPlot(x = 'Animals', y = 'value', group = 'Group', shape = 'bar', type = 'bar.molten', plotter = 'nvd3')

# pivot
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  pivot(rows = 'Group', cols = 'Animals', aggregatorName = 'Sum', vals = 'value', rendererName = 'Bar Chart', )

# billboarder:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), plotter = 'billboarder', type = 'bar')
tbl %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  niraPlot(x = 'Animals', y = 'value', group = 'Group', shape = 'bar', type = 'bar.molten', plotter = 'billboarder')


# rAmCharts:
niraPlot(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), type = 'bar', plotter = 'rAmCharts')


#r = rCharts.combo(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar')

# googleVis:
plot(googleVis.bar(tbl, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
# Does not show! Check it!


# plot(googleVis.gauge(tbl, theta = 'SF_Zoo', label = 'Animals'))
# plot(googleVis.gauge(tbl, theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))
# plot(googleVis.gauge(tbl[2,], theta = c('SF_Zoo', 'LA_Zoo', 'NY_Zoo')))

### imageR.R -------------------------

library(imageR)

tf <- tempfile()
png( file = tf, height = 400, width = 600 )
plot(1:50)
dev.off()
intense(base64::img(tf))

##########################################
library(shiny)
library(htmltools)
library(lattice)
library(imageR)

tf <- tempfile()
tf2 <- tempfile()
png( file = tf, height = 400, width = 1600 )
#example from ?lattice::cloud
cloud(Sepal.Length ~ Petal.Length * Petal.Width | Species, data = iris,
      screen = list(x = -90, y = 70), distance = .4, zoom = .6)
dev.off()

png( file = tf2, height = 1000, width = 1000)
#### example from http://www.cceb.med.upenn.edu/pages/courses/BSTA670/2012/R_3D_plot_ex.r
#--------------------------------
# persp plot of function
#--------------------------------
x <- seq(-10, 10, length= 30)
y <- x
f <- function(x,y) { r <- sqrt(x^2+y^2); 10 * sin(r)/r }
z <- outer(x, y, f)
z[is.na(z)] <- 1
op <- par(bg = "white")
persp(x, y, z, theta = 30, phi = 30, expand = 0.5, col = "lightblue")
dev.off()

html_print(fluidPage(
  tags$h1("Cloud and Wireframe from Lattice")
  ,fluidRow(style = "height:60%; overflow:hidden;"
            ,column(width = 6,  intense(base64::img(tf)))
            ,column(width = 6,  intense(base64::img(tf2)))
  )
))




##########################################

library(htmltools)
library(curl)
library(navr)
library(sortableR)
library(imageR)

n1 <- navr(
  selector = "#sortableR-toolbar"
  ,taglist = tagList(
    tags$ul(id = "sort-navr"
            ,style="line-height:120px; text-align:center; vertical-align:middle;"
            ,tags$li(
              style="border: solid 0.1em white;border-radius:100%;line-height:inherit;width:130px;height:130px;"
              , class="fa fa-binoculars fa-4x"
              #  attribution everywhere Creative Commons Flickr
              #  awesome picture by https://www.flickr.com/photos/12859033@N00/2288766662/
              , "data-image" = paste0(
                "data:image/jpg;base64,"
                ,base64enc::base64encode(
                  curl("https://farm4.staticflickr.com/3133/2288766662_c40c168b76_o.jpg","rb")
                )
              )
              , "data-title" = "Binoculars, a working collection"
              , "data-caption" = "awesome picture courtesy Flickr Creative Commons
              <a href = 'https://www.flickr.com/photos/12859033@N00/2288766662/'>jlcwalker</a>"
            )        
            ,tags$li(
              style="border: solid 0.1em white;border-radius:100%;line-height:inherit;width:130px;height:130px;"
              , class="fa fa-camera fa-4x"
              #  attribution everywhere Creative Commons Flickr
              #  awesome picture by https://www.flickr.com/photos/s58y/5607717791
              , "data-image" = paste0(
                "data:image/jpg;base64,"
                ,base64enc::base64encode(
                  curl("https://farm6.staticflickr.com/5309/5607717791_b030229247_o.jpg","rb")
                )
              )
              , "data-title" = "Leica IIIc converted to IIIf BD ST"
              , "data-caption" = "awesome picture courtesy Flickr Creative Commons
              <a href = 'https://www.flickr.com/photos/s58y/5607717791'>s58y</a>"
            )
            )
            )
)

html_print(tagList(
  tags$div(
    id = "sortableR-toolbar"
    ,style="width:300px;border: dashed 0.2em lightgray; float:left;"
    ,tags$h3("sortableR Icons for Intense Images")
    ,"These icons drag and drop. Click on them for an"
    ,tags$strong("intense")
    ,"result."
  )
  ,add_font_awesome(n1)
  ,sortableR("sort-navr")
  ,intense( selector = "#sort-navr li" )
))

### misexamples.R -------------------------
mtcars %>% group_by(cyl) %>% summarize(mpg = sum(mpg), disp = mean(disp)) %>% as.data.frame %>% 
  niraPlot(y = list('mpg', 'disp'), x = 'cyl', plotter = 'plotly', shape = list('bar', 'line')
           , type = 'bar', config = list(barMode = 'stack'))

mtcars %>% group_by(cyl) %>% summarize(mpg = sum(mpg), disp = mean(disp)) %>% as.data.frame %>% 
  niraPlot(theta = 'mpg', label = 'cyl', plotter = 'rAmCharts', type = 'pie')

mtcars %>% niraPlot(x = 'mpg', y = 'disp', plotter = 'nvd3', type = 'scatter')

###### Package: billboarder ===================================
### tsarea.R ----------------------------
library(magrittr)
library(dplyr)

library("billboarder")

source('C:/Nima/RCode/packages/master/niragen-master/R/niragen.R')

properties = read.csv('C:/Nima/RCode/packages/master/niravis-master/data/properties.csv' , as.is = T)
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/billboarder.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/jscripts.R')


source('C:/Nima/RCode/packages/master/niravis-master/R/c3.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/streamgraph.R')

# data
data("cdc_prod_filiere")

# area chart !
billboarder() %>% 
  bb_linechart(
    data = cdc_prod_filiere[, c("date_heure", "prod_eolien", "prod_hydraulique", "prod_solaire")], 
    type = "area"
  ) %>% 
  bb_subchart(show = TRUE, size = list(height = 30)) %>% 
  bb_data(
    groups = list(list("prod_eolien", "prod_hydraulique", "prod_solaire")),
    names = list("prod_eolien" = "Wind", "prod_hydraulique" = "Hydraulic", "prod_solaire" = "Solar")
  ) %>% 
  bb_legend(position = "inset", inset = list(anchor = "top-right")) %>% 
  bb_colors_manual(
    "prod_eolien" = "#238443", "prod_hydraulique" = "#225EA8", "prod_solaire" = "#FEB24C", 
    opacity = 0.8
  ) %>% 
  bb_y_axis(min = 0, padding = 0) %>% 
  bb_labs(title = "Renewable energy production (2017-06-12)",
          y = "In megawatt (MW)",
          caption = "Data source: RTE (https://opendata.rte-france.com)")


# niravis translation:
settings = list(title = "Renewable energy production (2017-06-12)", 
                subtitle = "Data source: RTE (https://opendata.rte-france.com)",
                legend.position = 'top-right',
                yAxis.label = "In megawatt (MW)",
                xAxis.tick.label.format = "%H O'clock",
                color = list(Wind = "#238443", Hydraulic = "#225EA8", Solar = "#FEB24C"),
                stack.enabled = T,
                aggregator = 'mean',
                opacity = 0.8)

cdc_prod_filiere %>% 
  billboarder.tsarea(x = "date_heure", y = list(Wind = "prod_eolien", Hydraulic = "prod_hydraulique", Solar = "prod_solaire"), config = settings)

# c3.tsline() and c3.tsarea() only work with Date as x axis, so POSIXct is converted to character. If config$aggregator is defined, it is aggregated automatically if key values (x axis) are not unique
cdc_prod_filiere %>% mutate(date_heure = format(date_heure, "%H")) %>% 
  c3.area(x = "date_heure", y = list(Wind = "prod_eolien", Hydraulic = "prod_hydraulique", Solar = "prod_solaire"), config = settings)


# streamgraph.tsarea

cdc_prod_filiere %>% mutate(date_heure = format(date_heure, "%H")) %>% 
  streamgraph.tsarea(x = "date_heure", y = list(Wind = "prod_eolien", Hydraulic = "prod_hydraulique", Solar = "prod_solaire"), config = settings)

### tsline.R ----------------------------
# Example 5: Pie charts:


library("billboarder")
source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/jscripts.R')

source('../../packages/master/niravis-master/R/dygraphs.R')
source('../../packages/master/niravis-master/R/c3.R')
source('../../packages/master/niravis-master/R/morrisjs.R')
source('../../packages/master/niravis-master/R/amCharts.R')


# tsline (Time Series):

# data
data("equilibre_mensuel")

# line chart
billboarder() %>% 
  bb_linechart(
    data = equilibre_mensuel[, c("date", "consommation", "production")], 
    type = "spline"
  ) %>% 
  bb_x_axis(tick = list(format = "%Y-%m", fit = FALSE)) %>% 
  bb_x_grid(show = TRUE) %>% 
  bb_y_grid(show = TRUE) %>% 
  bb_colors_manual("consommation" = "firebrick", "production" = "forestgreen") %>% 
  bb_legend(position = "right") %>% 
  bb_subchart(show = TRUE, size = list(height = 30)) %>% 
  bb_labs(title = "Monthly electricity consumption and production in France (2007 - 2017)",
          y = "In megawatt (MW)",
          caption = "Data source: RTE (https://opendata.rte-france.com)")

# niravis Translation:
settings = list(title = "Monthly electricity consumption and production in France (2007 - 2017)", 
                subtitle = "Data source: RTE (https://opendata.rte-france.com)",
                legend.position = 'right',
                yAxis.label = "In megawatt (MW)",
                xAxis.tick.label.format = "%Y",
                color = list(consommation = "firebrick", production = "forestgreen"))

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  billboarder.tsline(x = 'date', y = list("consommation", "production"), config = settings)

# Alternative way to apply colors:
settings$color = NULL
equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  billboarder.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

################# OTHER PLOTTERS:

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  dygraphs.tsline(x = 'date', y = list("consommation", "production"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  morrisjs.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  amCharts.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  c3.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  d3plus.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)


### bar.R ----------------------------
library("billboarder")
source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/jscripts.R')

# Example 1: Barchart

# data
data("prod_par_filiere")

# a bar chart !
billboarder() %>%
  bb_barchart(data = prod_par_filiere[, c("annee", "prod_hydraulique")], color = "#102246") %>%
  bb_y_grid(show = TRUE) %>%
  bb_y_axis(tick = list(format = suffix("TWh")),
            label = list(text = "production (in terawatt-hours)", position = "outer-top")) %>% 
  bb_legend(show = FALSE) %>% 
  bb_labs(title = "French hydraulic production",
          caption = "Data source: RTE (https://opendata.rte-france.com)")


# Translation:
cfg = list(
  yAxis.grid.enabled = T, 
  yAxis.tick.label.suffix = " TWh",
  yAxis.label = "production (in terawatt-hours)",
  yAxis.label.position = 'outer-top',
  legend.enabled = T,
  title = 'French hydraulic production',
  caption = 'Data source: RTE (https://opendata.rte-france.com)')

prod_par_filiere[, c("annee", "prod_hydraulique")] %>% 
  billboarder.bar(x = "annee", y = "prod_hydraulique", color = "#102246", 
                  config = cfg)

# want horizontal? swap x and y:
prod_par_filiere[, c("annee", "prod_hydraulique")] %>% 
  billboarder.bar(y = "annee", x = "prod_hydraulique", color = "#102246", 
                  config = cfg)



# trying dcr:
prod_par_filiere %>% dc.bar(x = 'annee', y = 'prod_bioenergies')


# Example 2: Barchart Multi-series:


data("prod_par_filiere")

# dodge bar chart !
billboarder() %>%
  bb_barchart(
    data = prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")]
  ) %>%
  bb_data(
    names = list(prod_hydraulique = "Hydraulic", prod_eolien = "Wind", prod_solaire = "Solar")
  ) %>% 
  bb_y_grid(show = TRUE) %>%
  bb_y_axis(tick = list(format = suffix("TWh")),
            label = list(text = "production (in terawatt-hours)", position = "outer-top")) %>% 
  bb_legend(position = "inset", inset = list(anchor = "top-right")) %>% 
  bb_labs(title = "Renewable energy production",
          caption = "Data source: RTE (https://opendata.rte-france.com)")


# Translation:
cfg = list(yAxis.grid.enabled = T, yAxis.tick.label.suffix = 'TWh', yAxis.label = 'production (in terawatt-hours)', yAxis.label.position = 'outer-top',
           legend.enabled = T, legend.position = 'top-right',
           title = 'Renewable energy production', caption = 'Data source: RTE (https://opendata.rte-france.com)')
prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")] %>%
  billboarder.bar(x = 'annee', y = list(Hydraulic = "prod_hydraulique", Wind = 'prod_eolien', Solar = 'prod_solaire'), config = cfg)


# Other packages:
prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")] %>%
  nvd3.bar(x = 'annee', y = list(Hydraulic = "prod_hydraulique", Wind = 'prod_eolien', Solar = 'prod_solaire'), config = cfg)


# Example 3: Stack Barchart Multi-series:
# data
data("prod_par_filiere")

# stacked bar chart !
billboarder() %>%
  bb_barchart(
    data = prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")], 
    stacked = TRUE
  ) %>%
  bb_data(
    names = list(prod_hydraulique = "Hydraulic", prod_eolien = "Wind", prod_solaire = "Solar"), 
    labels = TRUE
  ) %>% 
  bb_colors_manual(
    "prod_eolien" = "#41AB5D", "prod_hydraulique" = "#4292C6", "prod_solaire" = "#FEB24C"
  ) %>%
  bb_y_grid(show = TRUE) %>%
  bb_y_axis(tick = list(format = suffix("TWh")),
            label = list(text = "production (in terawatt-hours)", position = "outer-top")) %>% 
  bb_legend(position = "right") %>% 
  bb_labs(title = "Renewable energy production",
          caption = "Data source: RTE (https://opendata.rte-france.com)")

# Translation:
cfg$stack.enabled = T
cfg$legend.position = 'right'
prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")] %>%
  billboarder.bar(x = 'annee', y = list(Hydraulic = "prod_hydraulique", Wind = 'prod_eolien', Solar = 'prod_solaire'), config = cfg)



library("billboarder")

stars <- data.frame(
  package = c("billboarder", "ggiraph", "officer", "shinyWidgets", "visNetwork"),
  stars = c(1, 176, 42, 40, 166)
)

# Hide legend:
billboarder() %>%
  bb_barchart(data = stars) %>% 
  bb_legend(show = FALSE)

# niravis translation:
stars %>% billboarder.bar(x = 'package', y = 'stars', config = list(legend.enabled = F))



### pie.R ----------------------------
# Example 5: Pie charts:


library("billboarder")
source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niragen-master/R/visgen.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/jscripts.R')

# data
data("prod_par_filiere")
nuclear2016 <- data.frame(
  sources = c("Nuclear", "Other"),
  production = c(
    prod_par_filiere$prod_nucleaire[prod_par_filiere$annee == "2016"],
    prod_par_filiere$prod_total[prod_par_filiere$annee == "2016"] -
      prod_par_filiere$prod_nucleaire[prod_par_filiere$annee == "2016"]
  )
)

# pie chart !
billboarder() %>% 
  bb_piechart(data = nuclear2016) %>% 
  bb_labs(title = "Share of nuclear power in France in 2016",
          caption = "Data source: RTE (https://opendata.rte-france.com)")

nuclear2016 %>% billboarder.pie(
  label = 'sources', theta = 'production', 
  config = list(title    = "Share of nuclear power in France in 2016",
                subtitle = "Data source: RTE (https://opendata.rte-france.com)"))


### scatter.R ----------------------------
library("billboarder")


# Example 1: Scatter plot Multi-series:
billboarder() %>% 
  bb_scatterplot(data = iris, x = "Sepal.Length", y = "Sepal.Width", group = "Species") %>% 
  bb_axis(x = list(tick = list(fit = FALSE))) %>% 
  bb_point(r = 8)


# Translation:
iris %>% billboarder.scatter.molten(x = "Sepal.Length", y = "Sepal.Width", group = "Species", config = list(point.size = 8))


###### Package: bpexploder ===================================
### examples.R --------------------------

library(bpexploder)

bpexploder(data = iris,
           settings = list(
             groupVar = "Species",
             colorVar = "LO",
             levels = levels(iris$Species),
             yVar = "Petal.Length",
             tipText = list(
               Petal.Length = "Petal Length",
               Sepal.Width  = "Sepal Width"
             ),
             relativeWidth = 0.75)
)

# Translation:

iris %>% bpexploder.box.molten(
  group = 'Species', y = 'Petal.Width', 
  config = list(tooltip = list(
    Petal.Length = "Petal Length",
    Sepal.Width  = "Sepal Width"
  )))



# Chart 2

bpexploder(data = chickwts,
           settings = list(
             yVar = "weight",
             # default NULL would make make one plot for yVar
             groupVar = "feed",
             levels = levels(with(chickwts,
                                  reorder(feed, weight, median))),
             # you could adjust the group labels ...
             levelLabels = NULL,
             # ... and the colors for each group:
             levelColors = RColorBrewer::brewer.pal(6, "Set3"),
             yAxisLabel = "6-week weight (grams)",
             xAxisLabel = "type of feed",
             tipText = list(
               # as many os you like of:
               # variableName = "desired tool-tip label"
               # leave tipText at NULL for no tips
               weight = "weight"),
             # set width relative to grandarent element of svg image:
             relativeWidth = 0.75,
             # default alignment within containing div is "center"
             # "left" and "right" are other possible values"
             align = "center",
             # aspect = width/height, defaults to 1.25
             aspect = 1.5)
)


# Translate:

###### Package: bubbles ===================================
### simpleExample.R --------------------------
library(bubbles)
library(shiny)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/bubbles.R')

b = bubbles(value = rexp(26), label = LETTERS, tooltip = letters, color = rainbow(26, alpha=NULL)[sample(26)])

# Translate:

df = data.frame(Volume = rexp(26), bubName = LETTERS, bubLabel = letters, bubType = c(rep('Type 1',4), rep('Type 2', 12), rep('Type 3', 10)))
bubbles.bubble(df, color = rainbow(26, alpha=NULL)[sample(26)], size = 'Volume', label = 'bubName', labelColor = 'black', tooltip = 'bubLabel')
### shiny/server.R ------------------------------------
library(bubbles)
library(dplyr)
library(shinySignals)

function(input, output, session) {
  output$bubbles <- renderBubbles({b})
  output$bubbles2 <- renderBubbles({b2})
  output$summary <- renderPrint({paste(input$bubbles_click, input$bubbles2_click)})
}

### shiny/global.R ------------------------------------
library(bubbles)
library(shiny)

b = bubbles(value = rexp(26), label = LETTERS, tooltip = letters, color = rainbow(26, alpha=NULL)[sample(26)])
b2 = bubbles(value = rexp(16), label = letters[1:16], tooltip = LETTERS[1:16], color = rainbow(16, alpha=NULL)[sample(16)])

### shiny/ui.R ------------------------------------
library(bubbles)

fluidPage(
  h1("Live* CRAN downloads"),
  p("* 10080 minute delay"),
  sidebarLayout(
    sidebarPanel(
      selectInput("by", "Summarize by", c(
        "Package" = "package",
        "Country" = "country",
        "Client IP" = "ip_id",
        "R version" = "r_version",
        "Operating system" = "r_os"
      ), selected = "package"),
      radioButtons("scale", "Proportional to",
                   c("radius", "area"), selected = "radius"
      )    
    ),
    mainPanel(
      bubblesOutput("bubbles", width = "100%", height = 500),
      bubblesOutput("bubbles2", width = "100%", height = 500),
      verbatimTextOutput("summary")
    )
  )
)

# How to generate reactive shiny input for timevis package
# http://deanattali.com/blog/htmlwidgets-tips/#widget-to-r-data

### shiny/DESCRIPTION ------------------------------------
# Title: Live CRAN Downloads
# Type: Shiny
# DisplayMode: Showcase

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

####### Package: canvasExpress: ======================================

### tree.R ------------------------

library(canvasXpress)

y=read.table("http://www.canvasxpress.org/data/cX-tree-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-tree-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)

canvasXpress(
  data=y,
  smpAnnot=x,
  colorBy="Annot2",
  graphType="Tree",
  hierarchy=list("Level1", "Level2", "Level3"),
  showTransition=TRUE,
  title="Collapsible Tree",
  treeCircular=TRUE
)

### network.R ------------------------
library(canvasXpress)
nodes=read.table("http://www.canvasxpress.org/data/cX-wpapoptosis-nodes.txt", header=TRUE, sep="\t", quote="", fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
edges=read.table("http://www.canvasxpress.org/data/cX-wpapoptosis-edges.txt", header=TRUE, sep="\t", quote="", fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  nodeData=nodes,
  edgeData=edges,
  adjustBezier=FALSE,
  calculateLayout=FALSE,
  graphType="Network",
  networkFreeze=TRUE,
  networkNodesOnTop=FALSE,
  preScaleNetwork=FALSE,
  showAnimation=FALSE,
  showNodeNameThreshold=20000,
  title="Apoptosis"
)

### chord.R ------------------------
library(canvasXpress)

# Chart 1:

y=read.table("http://www.canvasxpress.org/data/cX-chord-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  circularArc=360,
  circularRotate=0,
  circularType="chord",
  colors=list("#000000", "#FFDD89", "#957244", "#F26223"),
  graphType="Circular",
  higlightGreyOut=TRUE,
  rAxisTickFormat=list("%sK", "val / 1000"),
  showTransition=TRUE,
  title="Simple Chord Graph",
  transitionStep=50,
  transitionTime=1500
)

### box.R ------------------------

library(niragen)
library(canvasXpress)
# Chart 1: Grouped boxplot

y=read.table("http://www.canvasxpress.org/data/cX-iris-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-iris-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  smpAnnot=x,
  axisTickFontStyle="bold",
  axisTitleFontStyle="italic",
  citation="R. A. Fisher (1936). The use of multiple measurements in taxonomic problems. Annals of Eugenics 7 (2) => 179-188.",
  citationFontStyle="italic",
  decorations=list(marker=list(list(sample="setosa", text="Species with\nlowest petal\nwidth", variable="Petal.Width", x=0.4, y=0.85))),
  fontStyle="italic",
  graphOrientation="vertical",
  graphType="Boxplot",
  legendBox=FALSE,
  showShadow=TRUE,
  showTransition=TRUE,
  smpLabelFontStyle="italic",
  smpLabelRotate=90,
  smpTitle="Species",
  title="Iris flower data set",
  xAxis2Show=FALSE,
  afterRender=list(list("groupSamples", list("Species")))
)




### bubble.R ------------------------


# Chart 1: Simple bubble chart:
y=read.table("http://www.canvasxpress.org/data/cX-tree-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-tree-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  smpAnnot=x,
  circularType="bubble",
  graphType="Circular",
  showTransition=TRUE,
  title="Simple Bubble Graph"
)



# Chart 2: Hierarchical bubblechart

y=read.table("http://www.canvasxpress.org/data/cX-tree-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-tree-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  smpAnnot=x,
  circularRotate=45,
  circularType="bubble",
  colorBy="Level1",
  graphType="Circular",
  hierarchy=list("Level1", "Level2", "Level3"),
  showTransition=TRUE,
  title="Hierarchical Colored Bubble Graph"
)

### combo.R ------------------------

library(niragen)
library(canvasXpress)
# Chart 1: Area-Line

y=read.table("http://www.canvasxpress.org/data/cX-arealine-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  colorScheme="Basic",
  graphOrientation="vertical",
  graphType="AreaLine",
  legendPosition="right",
  lineThickness=3,
  lineType="spline",
  smpLabelInterval=20,
  smpLabelRotate=45,
  smpTitle="Year",
  subtitle="gcookbook - uspopage",
  title="Age distribution of population in the United State",
  xAxis=list("<5", "5-14", "15-24", "25-34"),
  xAxis2=list("35-44", "45-54", "55-64", ">64"),
  xAxisTitle="Number of People (1000's)"
)


# CHart 2: Bar-line

y=read.table("http://www.canvasxpress.org/data/cX-generic-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-generic-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
z=read.table("http://www.canvasxpress.org/data/cX-generic-var.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  # smpAnnot=x,
  # varAnnot=z,
  backgroundGradient1Color="rgb(226,236,248)",
  backgroundGradient2Color="rgb(112,179,222)",
  backgroundType="gradient",
  graphOrientation="vertical",
  graphType="BarLine",
  legendBackgroundColor=FALSE,
  legendBox=FALSE,
  legendColumns=2,
  legendPosition="bottom",
  lineThickness=2,
  lineType="spline",
  showShadow=TRUE,
  showTransition=TRUE,
  smpLabelRotate=45,
  smpTitle="Collection of Samples",
  smpTitleFontStyle="italic",
  subtitle="Random Data",
  title="Bar-Line Graphs",
  xAxis=list("Variable1", "Variable2"),
  xAxis2=list("Variable3", "Variable4"),
  xAxis2TickFormat="%.0f T",
  xAxisTickColor="rgb(0,0,0)",
  xAxisTickFormat="%.0f M"
)

### bar.R ------------------------
library(canvasXpress)
y=read.table("http://www.canvasxpress.org/data/cX-stacked1-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-stacked1-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  smpAnnot=x,
  axisAlgorithm="rPretty",
  colorBy="GNI",
  decorations=list(marker=list(list(align="center", baseline="middle", color="red", sample="Norway", text="Norway is the country\nwith the largest GNI\naccording to 2014 census", variable="population", x=0.65, y=0.7), list(align="center", baseline="middle", color="red", sample="China", text="China is the country with\nthe largest population\naccording to 2014 census", variable="population", x=0.15, y=0.1))),
  graphOrientation="vertical",
  graphType="Stacked",
  legendInside=TRUE,
  legendPosition="top",
  showTransition=TRUE,
  smpLabelRotate=45,
  subtitle="2014 Census",
  title="Country Population colored by Gross National Income",
  treemapBy=list("ISO3"),
  widthFactor=4,
  xAxisMinorTicks=FALSE,
  afterRender=list(list("groupSamples", list("continent")))
)




# Example 2:

y=read.table("http://www.canvasxpress.org/data/cX-iris-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-iris-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  smpAnnot=x,
  axisTitleFontStyle="italic",
  decorations=list(marker=list(list(sample="setosa", text="Species with\nlowest petal\nwidth", variable="Petal.Width", x=0.4, y=0.85))),
  graphOrientation="vertical",
  graphType="Bar",
  legendBox=FALSE,
  legendColumns=2,
  legendPosition="bottom",
  showTransition=TRUE,
  smpLabelRotate=90,
  smpTitle="Species",
  title="Iris flower data set",
  xAxis2Show=FALSE,
  afterRender=list(list("groupSamples", list("Species")))
)

### area.R ------------------------
library(niragen)
library(canvasXpress)

source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')


#  Example chart 1:

y=read.table("http://www.canvasxpress.org/data/cX-area3-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  areaType="stacked",
  colorScheme="ColorSpectrum",
  colorSpectrum=list("blue", "cyan", "yellow", "red"),
  graphOrientation="vertical",
  graphType="Area",
  lineType="spline",
  showLegend=FALSE,
  showSampleNames=FALSE,
  showTransition=TRUE,
  subtitle="http://menugget.blogspot.com/2013/12/data-mountains-and-streams-stacked-area.html",
  title="Steam Plot"
)


# Chart 2:

y=read.table("http://www.canvasxpress.org/data/cX-area-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  colorScheme="RlatticeShingle",
  graphOrientation="vertical",
  graphType="Area",
  legendPosition="right",
  lineType="spline",
  showTransition=TRUE,
  smpLabelInterval=20,
  smpLabelRotate=45,
  smpTitle="Year",
  subtitle="gcookbook - uspopage",
  title="Age distribution of population in the United State",
  transparency=0.5,
  xAxis2Show=FALSE,
  xAxisTitle="Number of People (1000's)"
)





### examples.R ------------------------

library(niragen)
library(canvasXPress)

source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/googleVis.R')




###### Package coffeewheel ==================================
### examples.R ------------------------
# https://github.com/armish/coffeewheel
# example.R

library("coffeewheel");
library(magrittr);
library(tibble);
library(dplyr);
source('../../../../papckages/master/niravis-master/R/visgen.R')

# source('../niravis-master/R/visgen.R')


source('C:/Nima/RCode/projects/libraries/developing_packages/niraTree.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/coffeewheel.R')



coffeewheel(sampleWheelData, width=500, height=500, main="Sample Wheel Title", partitionAttribute="value")

a <- list(
  list(
    name="R",
    colour = "pink",
    children=list(
      list(name="R_1", colour="#110000"),
      list(name="R_3", colour="#330000"),
      list(name="R_5", colour="#550000"),
      list(name="R_7", colour="#770000"),
      list(name="R_9", colour="#990000"),
      list(name="R_b", colour="#bb0000"),
      list(name="R_d", colour="#dd0000"),
      list(name="R_f", colour="#ff0000")
    )
  ),
  list(
    name="G",
    children=list(
      list(name="G_1", colour="#001100"),
      list(name="G_3", colour="#003300"),
      list(name="G_5", colour="#005500"),
      list(name="G_7", colour="#007700"),
      list(name="G_9", colour="#009900"),
      list(name="G_b", colour="#00bb00"),
      list(name="G_d", colour="#00dd00"),
      list(name="G_f", colour="#00ff00")
    )
  ),
  list(
    name="B",
    children=list(
      list(name="B_1", colour="#000011"),
      list(name="B_3", colour="#000033"),
      list(name="B_5", colour="#000055"),
      list(name="B_7", colour="#000077"),
      list(name="B_9", colour="#000099"),
      list(name="B_b", colour="#0000bb"),
      list(name="B_d", colour="#0000dd"),
      list(name="B_f", colour="#0000ff")
    )
  )
);

coffeewheel(a, width=500, height=500, main="Sample Wheel Title", partitionAttribute="value")

# cwt = list(
#   list(
#     name  = 'Animals',
#     color = 3.5,
#     children = list(
#       list(
#         name  = 'Cats',
#         color = 2,
#         children = list(
#           list(name = 'Cat.1', color = 1),
#           list(name = 'Cat.2', color = 2),
#           list(name = 'Cat.3', color = 3)
#         )
#       ),
#       list(name = 'Dogs', color = 4),
#       list(name = 'Pigs', color = 6),
#       list(name = 'Sheep', color = 5),
#     )
#   ),
#   list(
#     name = 'Cars',
#     color = ...
#     childern = ...
#   )
# )

# Simple Example with niravis:

a = data.frame(x = c(rep('Animals',6), rep("Fruit",4), "Cars"),
               y = c(rep('Cats',3), 'Dogs', 'Sheep', 'Pigs', 'Apple', 'Banana', 'Mango', 'Strawberry', NA),
               z = c('Cat.1', 'Cat.2', 'Cat.3', rep(NA, 8)),
               value = 1:11)

a$colour = colorise(a$value, c('red', 'yellow', 'green'))

a %>% coffeewheel.pie(theta = 'value', color = 'colour', label = list('x', 'y', 'z'))

###### Package collapsibleTree ==================================
### examples.R ------------------------
# https://adeelk93.github.io/collapsibleTree/
library(data.tree)

library(collapsibleTree)

Geography = read.csv('data/Geography.csv')

head(Geography)


collapsibleTree(
  Geography,
  hierarchy = c("continent", "type", "country"),
  width = 800, 
  tooltip = T
)

###### Package d3plus ==================================
### examples.R ------------------------
library(d3plus)
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/d3plus.R')

# Network:

edges <- read.csv(system.file("data/edges.csv", package = "d3plus"))
nodes <- read.csv(system.file("data/nodes.csv", package = "d3plus"))
d3plus("rings",edges)
d3plus("rings", edges, focusDropdown = TRUE)
d3plus("rings", edges, nodes = nodes,focusDropdown = TRUE)

d3plus("network", edges)
d3plus("network",edges,nodes = nodes)


# scatter

countries <- read.csv(system.file("data/countries.csv", package = "d3plus"))
d3plus("scatter", countries)

# Translation:


d3plus.scatter(countries, x = 'CAB', y = 'INF', label = countries[,1])

# Grouping bubbles
bubbles <- read.csv(system.file("data/bubbles.csv", package = "d3plus"))
d3plus("bubbles", bubbles)

# Translation:
bubbles %>% d3plus.bubble.molten(label = 'name', size = 'value', group = 'group')

# Translation:
bubbles %>% dcast(name ~ group, value.var = 'value') %>% d3plus.bubble(size = list('group 1','group 2'), label = 'name')

# See also this:
b = bubbles %>% dcast(name ~ group, value.var = 'value')
b$name2 = b$name %+% '2'

b %>% d3plus.bubble(size = list('group 1','group 2'), label = list('name', 'name2'))

# Some treemaps
d3plus("tree", countries)
d3plus("tree", bubbles[c("name","value")])

# Translation:

countries %>% d3plus.tree(label = 'PaÃ.s', size = 'CAB', color = 'INF')


# Some lines
## Not working
#data <- read.csv(system.file("data/expenses", package = "d3plus"))
#d3plus("lines", data)

# Saving widgets
s <- d3plus("tree", countries)
htmlwidgets::saveWidget(s,"index.html", selfcontained = FALSE)
## Selfcontained= TRUE not working
# htmlwidgets::saveWidget(s,"index.html")


# A nice shiny app
library(shiny)
app <- shinyApp(
  ui = bootstrapPage(
    checkboxInput("swapNCols","Swap columns",value=FALSE),
    d3plusOutput("viz")
  ),
  server = function(input, output) {
    countries <- read.csv(system.file("data/countries.csv", package = "d3plus"))
    output$viz <- renderD3plus({
      d <- countries
      if(input$swapNCols){
        d <- d[c(1,3,2)]
      }
      d3plus("tree",d)
    })
  }
)
runApp(app)

###### Package d3plusR ==================================
### bar.R ------------------------
library(D3plusR)
library(dplyr)
library(magrittr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/d3plus.R')


data("trade_bra_chn")

# Fake shares
trade_bra_chn <- trade_bra_chn %>% 
  mutate(share = sample(100, nrow(trade_bra_chn), replace = TRUE))

dictionary <- list(TradeValue = "Trade Value", Period = "Year",
                   share = "Share")

attributes <- list(Trade.Flow = data.frame(Trade.Flow = c("Export", "Import"),
                                           hex = c("#344969", "#992234")))

d3plus(data = trade_bra_chn, id = "Trade.Flow",
       type = "stacked",
       dictionary = dictionary) %>% 
  d3plusX(value = "Period") %>% 
  d3plusY(value = "TradeValue") %>% 
  d3plusLegend(value = TRUE, size = 30, data = FALSE) %>% 
  d3plusTooltip(value = c("Period", "TradeValue", "share")) %>% 
  d3plusAttrs(value = attributes) %>% 
  d3plusColor(value = "hex") %>% 
  d3plusTitle("Brazilian Exports and Imports to/from China")



# niravis translation:

cfg = list(title = "Brazilian Exports and Imports to/from China",
           legend.enabled = T,
           legend.size = 30,
           legend.tooltip.enabled = F,
           color = list("Export" = "#344969", "Import" = "#992234"),
           tooltip = c("Year", "Trade Value", "Share"),
           additionalColumns = c(Share = 'share'))

trade_bra_chn %>% 
  d3plus.bar(x = list(Year = 'Period'), y = list('Trade Value' = 'TradeValue'), group = 'Trade.Flow', config = cfg)





### treemap.R ------------------------
library(D3plusR)
library(dplyr)
library(magrittr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/d3plus.R')


data("bra_exp_2015")
d3plus(data = bra_exp_2015,
       type = "tree_map",
       id = c("region", "Partner"),
       width = "100%",
       height = 500) %>% 
  d3plusSize(value = "Trade.Value..US..") %>% 
  d3plusLegend(value = TRUE, order = list(sort = "desc", value = "size")) %>% 
  d3plusColor("region") %>% 
  d3plusDepth(0) %>% 
  d3plusLabels(value = TRUE, valign = "top") %>% 
  d3plusUi(value = list(list(method = "color",
                             value = list(list(Region = "region"), list(Value = "Trade.Value..US.."), list(Country = "Partner"))),
                        list(method = "depth", type = "drop",
                             value = list(list(Continent = 0), list(Country = 1)))))


# niravis translation:
# todo: add multiple colors and correct the menu if more than one color is selected, same for depth with dimension label
bra_exp_2015 %>% d3plus.treemap(label = list('region', 'Partner'), size = 'Trade.Value..US..', color = 'region') %>%
  d3plusUi(value = list(list(method = "color",
                             value = list(list(Region = "region"), list(Value = "Trade.Value..US.."))),
                        list(method = "depth", type = "drop",
                             value = list(list(Continent = 0), list(Country = 1)))))

### tsline.R ------------------------
library(D3plusR)
library(dplyr)
library(magrittr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/d3plus.R')


data("bra_inflation")
# Date variables must have this format
bra_inflation$Date <- format(bra_inflation$Date, "%Y/%m/%d")
# dates to be passed in solo argument
date_filter <- bra_inflation$Date[bra_inflation$Date > "2013/01/01"]


d3plus(data = bra_inflation, id = "country",
       type = "rings",
       percent_var = "Rate",
       height = 400,
       width = "100%") %>% 
  d3plusX(value = "Date", grid = FALSE) %>% 
  d3plusY(value = "Rate") %>% 
  d3plusTime(value = "Date", solo = date_filter) %>% 
  d3plusTooltip(value = "Date") %>% 
  d3plusTitle("Brazilian Inflation (IPCA)")


# niravis translation:
cfg = list(
  title  = 'Brazilian Inflation (IPCA)',
  height = 400,
  width  = "100%",
  xAxis.min = as.Date("2013/01/01"),
  xAxis.grid.enabled = F,
  label.format = list('Rate' = 'percentage')
)

data("bra_inflation")
bra_inflation %>% d3plus.tsline.molten(x = 'Date', y = 'Rate', group = 'country', config = cfg)
bra_inflation %>% d3plus.tsbar.molten(x = 'Date', y = 'Rate', group = 'country', config = cfg)
bra_inflation %>% d3plus.tsarea.molten(x = 'Date', y = 'Rate', group = 'country', config = cfg)

### examples.R ------------------------
library(D3plusR)
library(dplyr)
library(magrittr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/d3plus.R')


data("trade_bra_chn")

# Fake shares
trade_bra_chn <- trade_bra_chn %>% 
  mutate(share = sample(100, nrow(trade_bra_chn), replace = TRUE))

dictionary <- list(TradeValue = "Trade Value", Period = "Year",
                   share = "Share")

attributes <- list(Trade.Flow = data.frame(Trade.Flow = c("Export", "Import"),
                                           hex = c("#344969", "#992234")))

d3plus(data = trade_bra_chn, id = "Trade.Flow",
       type = "bar",
       dictionary = dictionary,) %>% 
  d3plusX(value = "Period") %>% 
  d3plusY(value = "TradeValue") %>% 
  d3plusLegend(value = TRUE, size = 30, data = FALSE) %>% 
  d3plusTooltip(value = c("Period", "TradeValue", "share")) %>% 
  d3plusAttrs(value = attributes) %>% 
  d3plusColor(value = "hex") %>% 
  d3plusTitle("Brazilian Exports and Imports to/from China")

###### Package D3TableFilter ==================================
### staticTableWithD3TableFilter.R ------------------------
# ----------------------------------------------------------------------
# test script for interactive features of the d3tf widget outside of shiny
# ----------------------------------------------------------------------
library(htmlwidgets)
library(D3TableFilter)
library(magrittr)

source('C:/Nima/R/projects/tutorial/htmlwidget/scripts/D3TableFilter/genjscripts.R')
source('C:/Nima/R/projects/libraries/developing_packages/D3TableFilter.R')

data(mtcars);
mtcars <- mtcars[, 1:3];
mtcars$candidates <- FALSE;
mtcars$favorite <- FALSE;
myCandidates <- sample(nrow(mtcars), 5);
myFavorite <- sample(myCandidates, 1);
mtcars[myFavorite, "favorite"] <- TRUE;
mtcars[myCandidates, "candidates"] <- TRUE;

# define table properties. See http://tablefilter.free.fr/doc.php
# for a complete reference
tableProps <- list(
  btn_reset = TRUE,
  sort = TRUE,
  on_keyup = TRUE,  
  on_keyup_delay = 800,
  rows_counter = TRUE,  
  rows_counter_text = "Rows: ",
  col_number_format= c(NULL, "US", "US", "US", NULL, NULL), 
  sort_config = list(
    # alphabetic sorting for the row names column, numeric for all other columns
    sort_types = c("String", "Number", "Number", "Number", "none", "none")
  ),
  col_4 = "none",
  col_5 = "none",
  # exclude the summary row from filtering
  rows_always_visible = list(nrow(mtcars) + 2)
);

# columns are addressed in TableFilter as col_0, col_1, ..., coln
# the "auto" scales recalculate the data range after each edit
# to get the same behaviour with manually defined colour scales
# you can use the "colMin", "colMax", or "colExtent" functions,
# e.g .domain(colExtent("col_1")) or .domain([0, colMax(col_1)])
bgColScales <- list(
  col_3 = "auto:white:green",
  col_2 = "auto:white:red"
);

# apply D3.js functions to a column,
# e.g. to turn cell values into scaled SVG graphics
cellFunctions <- list(
  col_1 = js.bubblecol,
  col_2 = js.barcol
);

# apply D3.js functions to footer columns,
# e.g. to format them or to turn cell values into scaled SVG graphics
footCellFunctions <- list(col_0 = js.bold, col_1 = js.bold.1f, col_2 = js.bold.1f, col_3 = js.bold.right.1f);

initialFilters = list(col_1 = ">20");

colNames = c(Rownames = "Model", mpg = "Miles per gallon",	cyl = "Cylinders",	disp = "Displacement",	candidates = "Candidates",	favorite = "My favorite");
colNames = c(Rownames = "Model")

# add a summary row. Can be used to set values statically, but also to 
# make use of TableFilters "col_operation"
footData <- data.frame(Rownames = "Mean", mpg = mean(mtcars$mpg), cyl = mean(mtcars$cyl), disp = mean(mtcars$disp));

# the mtcars table output
tbl = d3tf(mtcars, tableProps = tableProps,
           showRowNames = TRUE,
           colNames = colNames,
           edit = c("col_1", "col_3"),
           checkBoxes = "col_4",
           radioButtons = "col_5",
           cellFunctions = cellFunctions,
           extensions = c('ColsVisibility', 'ColumnsResizer', 'FiltersRowVisibility'),
           tableStyle = "table table-bordered",
           bgColScales = bgColScales,
           filterInput = TRUE,
           initialFilters = initialFilters,
           footData = footData,
           footCellFunctions = footCellFunctions,
           height = 200)

# tbl %>%
#     saveWidget(file = "test.html", selfcontained = F)
# 
# d3tf(mtcars)


# Translation:

tbl = mtcars %>% D3TableFilter.table(label = list(MPG = 'mpg', Cylinders = 'cyl', 'hp', 'vs', 'am', 'gear'))

### color.R ------------------------
# https://github.com/rstudio  link to RStudio github containing many source code for packages, tutorials and examples

library(magrittr)
library(dplyr)
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')

source('C:/Nima/R/projects/libraries/developing_packages/d3TableFilter.R')


obj <- data.frame(AutoScale = round(seq(1, 200, length.out = 30), 1));
obj$LinearNumeric <- obj$AutoScale;
obj$LinearNumericHCL <- obj$LinearNumeric;
obj$LogScale <- rep(c(1, 2, 3, 10, 20, 30, 100, 200, 300, 1000, 2000, 3000, 10000, 20000, 30000), 2);
obj$Divergent <- round(seq(0, 14, length.out = 30), 1);
obj$OrdinalScale <- sample(LETTERS[1:14], nrow(obj), replace = TRUE);
obj$ColorBrewer.Set3 <- sample(LETTERS[1:9], nrow(obj), replace = TRUE);
obj$mycolor <- c("#FFFFFF","#342F28","#5DA369","#00FFFF","#F67A00","#0FB8D1","#9D1D1D","#101010","#494949","#838383","#BDBDBD","#F6F6F6","#1D1D1D","#575757","#909090","#C9C9C9","#F0FFF0","#A8A25E","#AAC1C1","#A7DDFD","#B100B1","#C11584","#FFA500","#A7E4E4","#D098D0","#5A424C","#87CEED","#00F278","#6E7666","#9ACD32")

table_Props <- list(
  # appearence
  btn_reset = TRUE,  
  btn_reset_text = "Clear",
  # behaviour
  on_change = TRUE,  
  btn = FALSE,  
  enter_key = TRUE,  
  on_keyup = TRUE,  
  on_keyup_delay = 1500,
  highlight_keywords = TRUE,  
  loader = TRUE,  
  loader_text = "Filtering data...",
  # sorting
  col_types = c("number", "number", "number","number", "number", "string", "string", "string"),
  # paging
  paging = FALSE
);



js0 = D3TableFilter.color.nomional.js(domain = c("A"      , "B"     , "C"    , "C"    , "D"   , "E"     , "F"   , "G"      , "H"      , "I"      , "J"      , "L"   , "M"  , "N"),
                                      range  = c("#FFFFFF", "yellow", "green", "black", "pink", "orange", "cyan", "#9D1D1D", "#101010", "#494949", "#838383", "blue", "red", "gray"))


js1 = "auto:white:green"
js3 = D3TableFilter.color.numeric.js(domain = obj$LinearNumericHCL, 
                                     range = obj$LinearNumericHCL %>% colorize(palette = c("white", "blue")))

js4 = D3TableFilter.color.numeric.js(domain = obj[,4], 
                                     range = obj[,4] %>% log %>% colorize(palette = c("white", "orangered")))

js5 = D3TableFilter.color.numeric.js(domain = obj[,5], 
                                     range = obj[,5] %>% log %>% colorize(palette = c("#f8766d", "white", "#00bfc4")))

js6 = D3TableFilter.color.nominal.js(domain = LETTERS[1:10], range = colours()[1:10])

js7 = JS('function ghablame(tbl, ii){
         var color = d3.scale.ordinal()
         .domain(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"])
         .range(colorbrewer.Set3[9]);
         return color(ii);
         }')
    

js8 = JS('function colorScale(obj,i){
         return(i)
         }')

# columns are addressed in TableFilter as col_0, col_1, ..., coln
bgColScales <- list(
  col_0 = js1,
  col_1 = js1,
  col_2 = js3,
  # don't include 0 in the range of a log scale
  col_3 = js4,
  col_4 = js5,
  col_5 = js0,
  col_6 = js7,
  col_7 = js8);

# invert font colour at a certain threshold
# to make it readable on darker background colour
fgColScales <- list(
  col_1 = JS('function colorScale(obj, i){
             var color = d3.scale.threshold()
             .domain([110, 110, 200.1])
             .range(["black", "black", "white"]);
             return color(i);
             }'),
      col_2 = JS('function colorScale(obj, i){
                 var color = d3.scale.threshold()
                 .domain([130, 130, 200.1])
                 .range(["black", "black", "white"]);
                 return color(i);
      }') 
    );

extensions <-  list(
  list(name = "sort")
);

tbl = 
  d3tf(obj, table_Props, enableTf = TRUE,
       showRowNames = FALSE, tableStyle = "table table-condensed", 
       bgColScales = bgColScales,
       fgColScales = fgColScales,
       extensions = extensions)


# Translate

tbl  = obj %>% D3TableFilter.table(label = names(obj) %>% as.list, color = 'OrdinalScale')

### minimal.R ------------------------
# https://github.com/ThomasSiegmund/D3TableFilter
# --------------------------------------------------------
# Minimal shiny app demonstrating the D3TableFilter widget

library(shiny)
library(htmlwidgets)
library(D3TableFilter)
library(magrittr)
library(dplyr)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')

source('C:/Nima/R/projects/libraries/developing_packages/d3TableFilter.R')

data(mtcars)

# ui.R
# --------------------------------------------------------
ui <- shinyUI(fluidPage(
  title = 'Basic usage of D3TableFilter in Shiny',
  fluidRow(
    column(width = 12, d3tfOutput('mtcars'))
  )
))

# server.R
# --------------------------------------------------------
server <- shinyServer(function(input, output, session) {
  output$mtcars <- renderD3tf({
    
    # Define table properties. See http://tablefilter.free.fr/doc.php
    # for a complete reference
    tableProps <- list(
      btn_reset = TRUE,
      # alphabetic sorting for the row names column, numeric for all other columns
      col_types = c("string", rep("number", ncol(mtcars)))
    );
    
    # d3tf(mtcars,
    #      tableProps = tableProps,
    #      extensions = list(
    #        list(name = "sort")
    #      ),
    #      showRowNames = TRUE,
    #      tableStyle = "table table-bordered");
    mtcars %>% D3TableFilter.table(tableProps = tableProps,
                                   extensions = list(
                                     list(name = "sort")
                                   ),
                                   config = list(withRowNames = TRUE),
                                   tableStyle = "table table-bordered")
  })
})


runApp(list(ui=ui,server=server))
### basic.R ------------------------
# https://thomassiegmund.shinyapps.io/basic/

library(magrittr)
library(dplyr)
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')



# Define table properties. See http://tablefilter.free.fr/doc.php
# for a complete reference
tableProps <- list(
  btn_reset = TRUE,
  sort = TRUE,
  sort_config = list(
    # alphabetic sorting for the row names column, numeric for all other columns
    sort_types = c("String", rep("Number", ncol(mtcars)))
  )
);

tbl <- 
  d3tf(mtcars,
       tableProps = tableProps,
       showRowNames = TRUE,
       tableStyle = "table table-bordered")

# Translation:

tbl = mtcars %>% arrange(cyl, disp) %>% D3TableFilter.table(label = names(mtcars) %>% as.list)

### server.R ------------------------
# --------------------------------------------------------
# Minimal shiny app demonstrating the D3TableFilter widget
# server.R
# --------------------------------------------------------
library(shiny)
library(htmlwidgets)
library(D3TableFilter)

data(mtcars);

shinyServer(function(input, output, session) {
  output$mtcars <- renderD3tf({
    
    # Define table properties. See http://tablefilter.free.fr/doc.php
    # for a complete reference
    tableProps <- list(
      btn_reset = TRUE,
      # alphabetic sorting for the row names column, numeric for all other columns
      col_types = c("string", rep("number", ncol(mtcars)))
    );
    
    # d3tf(mtcars,
    #      tableProps = tableProps,
    #      extensions = list(
    #       list(name = "sort")
    #      ),
    #      showRowNames = TRUE,
    #      tableStyle = "table table-bordered");
    tbl
  })
})

### ui.R ------------------------
# Shiny app to show the table:

# --------------------------------------------------------
# Minimal shiny app demonstrating the D3TableFilter widget
# ui.R
# --------------------------------------------------------
# --------------------------------------------------------
library(shiny)
library(htmlwidgets)
library(D3TableFilter)

shinyUI(fluidPage(
  title = 'Basic usage of D3TableFilter in Shiny',
  fluidRow(
    column(width = 12, d3tfOutput('mtcars', height = "auto"))
  )
))


### genjscripts.R ------------------------

js.barcol = JS('function makeGraph(selection){
                 
               // find out wich table and column
               var regex = /(col_\\d+)/;
               var col = regex.exec(this[0][0].className)[0];
               var regex = /tbl_(\\S+)/;
               var tbl = regex.exec(this[0][0].className)[1];
               var innerWidth = 117;
               var innerHeight = 14;
               
               // create a scaling function
               var max = colMax(tbl, col);
               var min = colMin(tbl, col);
               var wScale = d3.scale.linear()
               .domain([0, max])
               .range([0, innerWidth]);
               
               // text formatting function
               var textformat = d3.format(".1f");
               
               // column has been initialized before, update function
               if(tbl + "_" + col + "_init" in window) {
               var sel = selection.selectAll("svg")
               .selectAll("rect")
               .transition().duration(500)
               .attr("width", function(d) { return wScale(d.value)});
               var txt = selection
               .selectAll("text")
               .text(function(d) { return textformat(d.value); });
               return(null);
               }
               
               // can remove padding here, but still cant position text and box independently
               this.style("padding", "5px 5px 5px 5px");
               
               // remove text. will be added back later
               selection.text(null);
               
               var svg = selection.append("svg")
               .style("position",  "absolute")
               .attr("width", innerWidth)
               .attr("height", innerHeight);
               
               var box = svg.append("rect")
               .style("fill", "lightblue")
               .attr("stroke","none")
               .attr("height", innerHeight)
               .attr("width", min)
               .transition().duration(500)
               .attr("width", function(d) { return wScale(d.value); });
               
               // format number and add text back
               var textdiv = selection.append("div");
               textdiv.style("position",  "relative")
               .attr("align", "right");
               
               textdiv.append("text")
               .text(function(d) { return textformat(d.value); });
               window[tbl + "_" + col + "_init"] = true;
               }')

js.bubblecol = JS('function makeGraph(selection){
                  
                  // find out wich table and column
                  var regex = /(col_\\d+)/;
                  var col = regex.exec(this[0][0].className)[0];
                  var regex = /tbl_(\\S+)/;
                  var tbl = regex.exec(this[0][0].className)[1];
                  
                  // create a scaling function
                  var domain = colExtent(tbl, col);
                  var rScale = d3.scale.sqrt()
                  .domain(domain)
                  .range([8, 14]);
                  
                  // column has been initialized before, update function
                  if(tbl + "_" + col + "_init" in window) {
                  var sel = selection.selectAll("svg")
                  .selectAll("circle")
                  .transition().duration(500)
                  .attr("r", function(d) { return rScale(d.value)});
                  return(null);
                  }
                  
                  // remove text. will be added later within the svg
                  selection.text(null)
                  
                  // create svg element
                  var svg = selection.append("svg")
                  .attr("width", 28)
                  .attr("height", 28);
                  
                  // create a circle with a radius ("r") scaled to the 
                  // value of the cell ("d.value")
                  var circle = svg.append("g")
                  .append("circle").attr("class", "circle")
                  .attr("cx", 14)
                  .attr("cy", 14)
                  .style("fill", "orange")
                  .attr("stroke","none")
                  .attr("r", domain[0])
                  .transition().duration(400)
                  .attr("r", function(d) { return rScale(d.value); }); 
                  
                  // place the text within the circle
                  var text = svg.append("g")
                  .append("text").attr("class", "text")
                  .style("fill", "black")
                  .attr("x", 14)
                  .attr("y", 14)
                  .attr("dy", ".35em")
                  .attr("text-anchor", "middle")
                  .text(function (d) { return d.value; });
                  window[tbl + "_" + col + "_init"] = true;
                  
                  }')


js.bold = JS('function makeGraph(selection){selection.style("font-weight", "bold")}')

js.bold.1f = JS('function makeGraph(selection){
                // text formatting function
                var textformat = d3.format(".1f");
                selection.style("font-weight", "bold")
                .text(function(d) { return textformat(d.value); });}')

js.bold.right.1f = JS('function makeGraph(selection){
                      // text formatting function
                      var textformat = d3.format(".1f");
                      // make cell text right aligned
                      selection.classed("text-right", true)
                      .style("font-weight", "bold")
                      .text(function(d) { return textformat(d.value); });}')



### interactive/app.R ------------------------
# ----------------------------------------------------------------------
# Shiny app demonstrating interactive features of the tableFilter widget 
# This code is translated to niravis language from the original code:
# ----------------------------------------------------------------------

library(shiny)
library(htmlwidgets)
library(magrittr)

library(niragen)
library(niravis)

# source('C:/Nima/RCode/packages/niragen/R/niragen.R')
#source('C:/Nima/RCode/packages/niravis-master/R/visgen.R')
#source('C:/Nima/RCode/packages/niravis-master/R/jscripts.R')
#source('C:/Nima/RCode/packages/niravis-master/R/rscripts.R')
#source('C:/Nima/RCode/packages/niravis-master/R/dashboard.R')
#source('C:/Nima/RCode/packages/niravis-master/R/TFD3.R')

data(mtcars);
mtcars <- mtcars[, 1:3];
mtcars$candidates <- FALSE;
mtcars$favorite <- FALSE;
myCandidates <- sample(nrow(mtcars), 5);
myFavorite <- sample(myCandidates, 1);
mtcars[myFavorite, "favorite"] <- TRUE;
mtcars[myCandidates, "candidates"] <- TRUE;

filtering <- data.frame(Rows = c(nrow(mtcars), nrow(mtcars)), Indices = c(paste(1:nrow(mtcars), collapse = ', '), paste(1:nrow(mtcars), collapse = ', ')), stringsAsFactors = FALSE);
rownames(filtering) <- c("Before", "After")

cfg = list(column.shape = list(cyl = 'bubble', disp = 'bar', candidates = 'checkBox', favorite = 'radioButtons'),
           column.color = list(mpg = c('white', 'yellow', 'red')),
           column.color.auto = list(mpg = T),
           column.title = list(rownames = "Model", mpg = "Miles per gallon",	cyl = "Cylinders",	disp = "Displacement",	candidates = "Candidates",	favorite = "My favorite"),
           column.editable = list('mpg' = T, 'disp' = T),
           column.footer = list(rownames = 'Mean', mpg = mean, disp = mean, cyl = mean),
           table.style = 'table table-bordered',
           column.filter = list('rownames' = 'Da'),
           # Table properties:
           btn_reset = TRUE,
           sort = TRUE,
           on_keyup = TRUE,  
           on_keyup_delay = 800,
           rows_counter = TRUE,  
           rows_counter_text = "Rows: ",
           col_number_format= c(NULL, "US", "US", "US", NULL, NULL), 
           sort_config = list(
             # alphabetic sorting for the row names column, numeric for all other columns
             sort_types = c("String", "Number", "Number", "Number", "none", "none")
           ),
           col_4 = "none",
           col_5 = "none",
           # exclude the summary row from filtering
           rows_always_visible = list(nrow(mtcars) + 2),
           height = 2000
           
)

cfg2 = list(row.color = c('', 'danger', rep('', nrow(mtcars) - 2)),
            selected = c(1,  3,  5,  7,  9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31),
            selection.mode = 'multi',
            selection.color = 'info', 
            table.style = 'table table-bordered table-condensed',
            btn_reset = TRUE,
            rows_counter = TRUE,  
            rows_counter_text = "Rows: ",
            sort = TRUE,
            height = 500,
            on_keyup = TRUE,  
            on_keyup_delay = 800,
            sort_config = list(
              sort_types = c("Number", "Number")
            ),
            filters_row_index = 1,
            # adding a summary row, showing the column means
            rows_always_visible = list(nrow(mtcars) + 2),
            col_operation = list( 
              id = list("frow_0_fcol_1_tbl_mtcars2","frow_0_fcol_2_tbl_mtcars2"),    
              col = list(1,2),    
              operation = list("mean","mean"),
              write_method = list("innerhtml",'innerhtml'),  
              exclude_row = list(nrow(mtcars) + 2),  
              decimal_precision = list(1, 1)
            ))

###################################### Dashboard Design:
# Service Functions:

# Clothes

WP = list(type = 'wellPanel')


I = list()
O = list()
# Containers:
I$main      = list(type = 'fluidPage', title = 'Interactive features', layout = 'tabset')
I$tabset    = list(type = 'tabsetPanel', selected = "Editing and filtering", layout = c('tab1', 'tab2'))
I$tab1      = list(type = 'tabPanel' , title = "Editing and filtering", col.framed = T, layout = c('col11', 'col12', 'col13'))
I$tab2      = list(type = 'tabPanel' , title = "Row selection", layout = c('tab2Title', 'col21', 'col22', 'col23'))
I$col11     = list(type = 'column', weight = 2, layout = c('editingCol0', 'clearfilter', 'WP_fltr', 'cellVal', 'WP_fvr', 'summaryRow'))
I$col12     = list(type = 'column', weight = 5, layout = 'mtcars')
I$col13     = list(type = 'column', weight = 5, layout = c('edits', 'filters', 'filtering', 'filteredMtcars'))
I$col21     = list(type = 'column', weight = 2, layout = c('html', 'WP_hlp'))
I$col22     = list(type = 'column', weight = 5, layout = c('mtcars2'))
I$col23     = list(type = 'column', weight = 5, layout = 'mtcars2Output')
I$WP_fltr   = list(type = 'wellPanel', layout = c('filterString', 'dofilter'))
I$WP_fvr    = list(type = 'wellPanel', layout = c('candidate', 'favorite'))
I$WP_hlp    = list(type = 'wellPanel', layout = c('helpText', 'hornetClass'))
# Inputs:
I$editingCol0  = list(type = 'radioButtons'  , title = "Rownames editing", choices = c("Enable" = TRUE, "Disable" = FALSE), selected = FALSE)
I$clearfilter  = list(type = 'actionButton' , title = "Clear filters", service = "clearFilters(session, tbl = 'mtcars', doFilter = TRUE)")
I$dofilter     = list(type = 'actionButton' , title = "Set filter", isolate = T, service = "sync$mtcars_column.filter[['rownames']] = input$filterString")
I$filterString = list(type = 'textInput'    , title = "Filter rownames", value = "rgx:^D")
# Row address is based on the complete, unfiltered and unsorted table
# Column address is one based. In this case showRowNames is TRUE,
# rownames column is col 0, "cylinders" is col 2.
I$cellVal      = list(type = 'selectInput'  , title = "Merc 240D cylinders", choices = c(4, 6, 8, 10, 12), selected = 4, multiple = FALSE, cloth = WP, service = "setCellValue(session, tbl = 'mtcars', row = 8, col = 2, value = input$cellVal, feedback = TRUE)")
I$favorite     = list(type = 'actionButton' , title = "Make Datsun favorite")
I$summaryRow   = list(type = 'selectInput'  , title = "Summary row", choices = c("mean", "median"), multiple = FALSE)
I$hornetClass  = list(type = 'selectInput'  , title = "Set row class on 'Hornet Sportabout'", choices = c("none", "active", "success", "info", 'warning', "danger"), selected = "none")

# Outputs:
# O$candidateUi     = list(type = "uiOutput")
I$candidate       = list(type = "radioButtons", title = "Make Datsun candidate", choices = c("yes" = TRUE, "no" = FALSE), selected = T)
O$mtcars          = list(type = "TFD3Output", title = "mtcars" %>% h4, height = "auto", sync = T, config = cfg, data = mtcars)
O$mtcars2         = list(type = "TFD3Output", title = "", height = "2000px",  sync = T, config = cfg2, data = mtcars[ , 1:2])
O$mtcars2Output   = list(type = "tableOutput", title = "")
O$edits           = list(type = "tableOutput", title = h4("Last edits"), rownames = T) 
O$filters         = list(type = "tableOutput", title = h4("Filters")) 
O$filtering       = list(type = "tableOutput", title = h4("Filter results"), rownames = T) 
O$filteredMtcars  = list(type = "tableOutput", title = h4("mtcars after filtering and editing"), rownames = T) 
O$tab2Title       = list(type = 'static', object = h4("Row selection"))
O$html            = list(type = 'static', object = HTML("Click on the table to select a row. <code>Ctrl</code>  click for multiple selection."))
O$helpText        = list(type = 'static', object = helpText("This demonstrates the setRowClass to highlight a specific row using contextual classes from bootstrap. Can also be used to unselect a row"))

##### Server:

## Observers:
OB = character()

OB[1] = "
if(is.null(input$mtcars_filter)) return(NULL);
reval$filtering['After', 'Rows'] <- length(report$mtcars_filtered);
reval$filtering['After', 'Indices'] <- paste(report$mtcars_filtered, collapse = ', ');
reval$filters <- sync$mtcars_column.filter %>% as.data.frame %>% t %>% as.data.frame %>% rownames2Column('Column');
"

# server side editing of checkbox
I$candidate$service = 
  "  
if(is.null(input$candidate)) return(NULL);
# why do I get string values and not logicals here? Shiny bug?
if(input$candidate == 'TRUE') {
candidate = TRUE;
} else if (input$candidate == 'FALSE') {
candidate = FALSE;
} else {
candidate = input$candidate;
}
# setCellValue(session, tbl = 'mtcars', row = 3, col = 4, value = candidate, feedback = TRUE);
sync$mtcars[3, 4] = candidate
"

# I$favorite$service = "setCellValue(session, tbl = 'mtcars', row = 3, col = 5, value = TRUE, feedback = TRUE)"
I$favorite$service = "sync$mtcars[3, 5] = TRUE"
I$cellVal$service  = "sync$mtcars[8, 2] = input$cellVal %>% as.integer"
I$hornetClass$service = "if(is.null(sync$mtcars2_row.color)){sync$mtcars2_row.color = items[['mtcars2']]$config$row.color}; sync$mtcars2_row.color[5] = input$hornetClass; if(input$hornetClass == 'info'){sync$mtcars2_selected = 12:16}"
I$editingCol0$service = "sync$mtcars_column.editable[['rownames']] = input$editingCol0"
I$summaryRow$service = "func = chif(input$summaryRow == 'mean', mean, median); sync$mtcars_column.footer = list(rownames = input$summaryRow, mpg = func, mpg = func, cyl = func, disp = func)"
I$clearfilter$service = "sync$mtcars_column.filter = list()"

O$edits$service = "
if(is.null(report$mtcars_lastEdits)) return(invisible());
report$mtcars_lastEdits;
"
O$filtering$service = "
if(is.null(reval$filtering)) return(invisible());
reval$filtering;
"
O$filters$service = "
if(nrow(reval$filters) == 0) return(invisible());
reval$filters;
"

O$filteredMtcars$service = "
if(is.null(report$mtcars_filtered)) return(invisible());    
if(is.null(sync$mtcars)) return(invisible());
sync$mtcars[report$mtcars_filtered, ];
"

O$mtcars2Output$service = "
if(is.null(input$mtcars2_select)) return(NULL);
mtcars[input$mtcars2_select, 1:2];
"

dash = new('DASHBOARD', items = c(I, O), king.layout = list('main'), observers = OB)

dash$prescript = "
reval <- reactiveValues();
reval$filtering <- filtering;
reval$filters <- NULL;
reval$filters <- data.frame(Column = character(), Filter = character(), stringsAsFactors = FALSE);
"

ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)

### interactive/visgen.R ------------------------
# Header
# Filename:      visgen.R
# Description:   This module contains general functions and defines global variables used in package niravis
# Author:        Nima Ramezani Taghiabadi
# Email :        nima.ramezani@cba.com.au
# Start Date:    28 October 2016
# Last Revision: 31 March 2017
# Version:       1.2.4

# Version History:

# Version   Date               Action
# ----------------------------------
# 1.0.0     28 October 2016    Initial Issue
# 1.1.0     01 December 2016   Function visPrepare() added
# 1.1.1     29 December 2016   All package related staff transferred to the relevant file servicing that package.
# 1.1.2     10 February 2017   Some global variables like valid.plot.types and valid.plot.packages transferred from niraPlotter.R
# 1.1.3     01 March 2017      Function verifyPlotInputs() added. 
# 1.1.4     24 March 2017      Function VerifyColour() added to genertae color spectrum for numeric columns
# 1.1.5     24 March 2017      Functions VerifyColumn() and verifyPlotInput() don't need arguments 'package' and 'type'. Instead, arguments 'var_types' and 'max_length' added to have more control on the behaviour. 
#                              Especially required for horizontal plots in which x and y variable types are swaped!
# 1.2.0     26 March 2017      Functions addcol() and prepare4Plotble4Plot() added
# 1.2.1     27 March 2017      Argument var_types replaced by config. config contaions palettes for different dimensions as well as valid dim classes.
# 1.2.2     27 March 2017      Functions verifyColumn() and verifyColour() eliminated: All is done by addcol(). Function addcol() is not exported.
# 1.2.3     27 March 2017      Functions nameList() added. Renamed from previous function as.named.list()
# 1.2.4     31 March 2017      Function prepareAusthetics() added. 
# 1.2.5     11 April 2017      Function prepareAusthetics() renamed to prepareAesthetics() and modified: extends to max length of arguments

# Uncomment when compile
# assert(require(niragen), "Package niragen is not installed!", err_src = match.call()[[1]])

assert(require(magrittr), "Package magrittr is not installed!", err_src = match.call()[[1]])

colNamePrefix = 'X'

#' @export
valid.dim.names  = c('x', 'y', 'z', 't', 'high', 'low', 'color', 'size', 'shape', 'label', 'tooltip', 'labelColor', 
                     'borderColor', 'linkColor','theta', 'ySide', 'group', 'source', 'target', 
                     'linkWidth', 'linkLength', 'linkLabel', 'linkLabelColor', 'linkLabelSize')

#' @export
valid.plot.types = c('bar', 'calheat', 'line', 'motion', 'pie', 'tsline', 'gauge', 'bubble', 'combo', 'scatter')

#' @export
valid.plot.packages    = c('googleVis', 'dygraphs', 'rAmCharts', 'rCharts', 'highcharter', 'plotly', 'bubbles')

# General settings for all the plots
defset = list(
  
  palette= list(
    color = c("#FB1108", "#FA7806","#FBE426","#FCFB8F", "#F3F5E7", "#C7E4EA","#ABD6E6","#9AD2E1"),
    shape = c('circle', 'x', 'o', 'plus', 'square.hollow', 'rhombus.hollow')
  ),
  
  withRowNames = F,
  colorize     = T
)

# if a column name is convertable to numerics, it adds a prefix to it. Global variable 'colNamePrefix' will be used.
addPrefix = function(figures){
  if (is.null(figures)){return(NULL)}
  options(warn = -1)
  nms = !is.na(as.numeric(figures))
  options(warn = 0)
  figures[nms] = colNamePrefix %+% figures[nms]
  return(figures)
}

addcol = function(tbl, obj, col, dim, config, cln){
  if (is.empty(col)){return(tbl)}
  if (inherits(col, 'list')){
    nms   = names(col)
    added = c()
    for (i in seq(col)){
      if (!(nms[i] %in% added)){
        tbl %<>% addcol(obj, col[[i]], dim, config, cln = nms[i])
        added = c(added, nms[i])
      }
    }
    return(tbl)
  }
  assert(!is.null(cln))
  
  flag <- (col %<% names(obj)) %>% verify(err_msg = "Argument 'col' is of class " %+% class(col) %+% " which is not valid for any chart", err_src = match.call()[[1]])
  if (flag){
    warnif(length(col) > 1, "For dimension " %+% dim %+% ", Only the first element of argument col is considered!")
    col = col[1]
    if (!inherits(obj[,col], config$dimclass[[dim]])){obj[, col] <- try(obj[,col] %>% coerce(config$dimclass[[dim]][1]), silent = T) %>% verify()}
    if ((dim %in% c('color', 'labelColor', 'borderColor', 'linkColor')) & config$colorize){obj[, col] %<>% colorize(palette = config$palette[[dim]])}
    return(tbl %>% appendCol(obj[,col], cln))
  }
  
  if ((dim %in% c('color', 'labelColor', 'borderColor', 'linkColor')) & config$colorize){
    clr = try(col2rgb(col))
    if(inherits(clr, 'try-error')){
      tbl[, cln] <- colorize(col, palette = palette)
    } else {
      clr %<>% apply(2, vect.normalize) 
      tbl %<>% appendCol(rgb(red = clr['red', ], green = clr['green', ], blue = clr['blue', ]), cln)
    }
    return(tbl)  
  }
  
  if(!inherits(col, config$dimclass[[dim]])){col <- try(col %>% coerce(config$dimclass[[dim]][1]), silent = T) %>% verify()}
  
  tbl %<>% appendCol(col, cln)
  if (inherits(col,'character')){tbl[,cln] %<>% as.character}
  return(tbl)
}

nameList = function(l, defname = 'X'){
  if(is.null(l)){return(l)}
  if (!inherits(l,'list')){
    l %<>% list
    names(l) <- names(l[[1]])
  }
  nms = names(l)
  
  if(is.null(names(l))){names(l) <- rep('', length(l))}
  
  nms = names(l)
  for (i in seq(l)){
    if (nms[i] == ''){
      if (inherits(l[[i]],'character')){nms[i] = l[[i]][1]} else {nms[i] <- paste(defname, i, sep = '.')}
    }
  }
  
  names(l) <- nms
  return(l)
}

prepare4Plot = function(obj, aesthetics, config){
  
  # Verifications:
  if(inherits(obj, c('tbl','tbl_df'))){obj %<>% as.data.frame}
  obj     = verify(obj, 'data.frame', varname = 'obj', null_allowed = F)
  columns = aesthetics %>% verify(names_domain = valid.dim.names, varname = 'columns', err_src = 'prepare4Plot')
  
  # Table pre-modifications:
  # if(!is.null(config$presort)){
  #   config$presort %>% verify('character', domain = names(obj), varname = 'config$presort')
  #   obj %>% dplyr::arrange(config$presort)
  # }
  
  tbl = data.frame()
  for (i in names(columns)){
    # Verifications:
    if(!is.null(columns[[i]])){
      if(!is.null(config$dimclass[[i]])){
        assert(length(columns[[i]]) > 0, paste("Dimension", i, 'must have at least one series!'), 'prepare4Plot')
        if (!(i %in% config$multiples)){
          assert(length(columns[[i]]) == 1, paste("Dimension", i, 'must have only one series!'), 'prepare4Plot')
        }
      }
    }
    
    tbl %<>% addcol(obj, columns[[i]], i, config = config)
  }
  if (config$withRowNames){rownames(tbl) <- rownames(obj)}
  return(tbl)
}

#' @export
verifyPlotInputs = function(obj, x = NULL, y = NULL, z = NULL, t = NULL, color = NULL, size = NULL, 
                            shape = NULL, label = NULL, labelColor = NULL, theta = NULL, 
                            linkSource = NULL, linkTarget = NULL,
                            tooltip = NULL, palette.color = niraPalette, palette.labelColor = niraPalette, ...){
  obj     = verify(obj, 'data.frame', varname = 'obj', null_allowed = F)
  names(obj) %<>% addPrefix
  
  # Domain for colDim is: c('x', 'y', ...)
  data.frame() %>%
    verifyColumn(obj, x, 'x', ...) %>%
    verifyColumn(obj, y, 'y', ...) %>%
    verifyColumn(obj, z, 'z', ...) %>%
    verifyColumn(obj, t, 't', ...) %>%
    
    verifyColumn(obj, size,  'size',   ...) %>%
    verifyColour(obj, color, 'color', palette = palette.color, ...) %>%
    verifyColumn(obj, shape, 'shape', ...) %>%
    verifyColumn(obj, label, 'label', ...) %>%
    verifyColour(obj, labelColor, 'labelColor', palette = palette.labelColor, ...)  %>%
    verifyColumn(obj, theta, 'theta', ...)  %>%
    verifyColumn(obj, tooltip, 'tooltip', ...) %>%
    verifyColumn(obj, linkSource, 'linkSource', ...) %>%
    verifyColumn(obj, linkTarget, 'linkTarget', ...)
}

# Old function: should be removed later
#' @export
visPrepare = function(arg){
  # verifications:
  verify(arg, 'list', names_domain = c('table', valid.dim.names), names_include = 'table', varname = 'arg', null_allowed = F)
  verify(arg$table, 'data.frame', varname = 'table', null_allowed = F)
  # names(dims) <- tolower(names(dims))
  
  all.figs = names(arg$table)
  num.figs = numerics(arg$table)
  cat.figs = nominals(arg$table)
  tim.figs = datetimes(arg$table)
  
  nms = names(arg) %-% 'table'
  colNames = character()
  
  for (i in nms){
    # Verifications:
    verify(arg[[i]], 'list', names_include = c('type', 'colName'), varname = 'arg[[i]]')
    verify(arg[[i]]$type, 'character', domain = c('numeric', 'nominal', 'time'), varname = 'arg[[i]]$type')
    figs = switch(arg[[i]]$type, 'numeric' = {num.figs}, 'nominal' = {cat.figs}, 'time' = {tim.figs}, 'all' = {all.figs})
    verify(arg[[i]]$colName, 'character', domain = figs, varname = 'arg[[i]]$colName')
    
    colNames = c(colNames, arg[[i]]$colName)
  }
  
  return(arg$table[, colNames, drop = F])
}




# Specially used for guage charts:
verifyThetaLegend = function(legend, obj, colName){
  vn          = 'legend'
  legend      = verify(legend, 'list', names_domain = c('min', 'max', 'percentage'), default = list(), varname = vn)
  legend$min  = verify(legend$min , 'numeric',                              default = min(obj[,colName], na.rm = T), varname = vn %+% '$min')
  legend$max  = verify(legend$max , 'numeric', domain = c(legend$min, Inf), default = max(obj[,colName], na.rm = T), varname = vn %+% '$max')
  legend$percentage  = verify(legend$percentage , 'logical', domain = c(T, F), default = F, varname = vn %+% '$percentage')
  return(legend)
}

removePercentage = function(dim){
  if (is.null(dim)){return(NULL)} else {return(gsub('%', '', dim))}
}

# Adds a tooltip column to the given table containing values of selected columns
addTooltip = function(tbl, columns = names(tbl), units = NULL, addedColName = 'tooltip'){
  # Verifications:
  verify(tbl, c('data.frame', 'matrix'), varname = 'tbl')
  verify(columns, 'character', domain = c('%rownames', names(tbl)), varname = 'columns')
  units %<>% verify('character', lengths = length(columns), default = rep('', length(columns)), varname = 'columns')
  
  if (is.null(names(columns))){names(columns) = columns}
  names(units) <- names(columns)
  mxl = max(nchar(names(columns))) + 1
  
  if(is.empty(tbl)){return(tbl)}
  str = ''
  for (col in names(columns)){
    if (columns[col] == '%rownames'){colstr = rownames(tbl)} 
    else if (inherits(tbl[, columns[col]], 'numeric')) {colstr = prettyNum(tbl[,columns[col]], digits = 3)} 
    else {colstr = tbl[,columns[col]]}
    if (units[col] == ''){unitstr = ''} else {unitstr = paste0(' (', units[col], ') ')}
    ttlstr = extend.char(col %+% ':', mxl)
    str %<>% paste0(ttlstr, colstr, unitstr, '\n')
  }
  
  tbl[, addedColName] <- str
  return(tbl)
}


prepareAesthetics = function(extend = c(), ...){
  args = list(...)
  lbls = list()
  dims = names(args)
  M    = length(dims)
  # N    = args %>% sapply(length) %>% max
  N = 1
  for (i in sequence(M)){
    if(!is.null(args[[i]])){
      args[[i]] %<>% nameList(dims[i])
      N = max(N, length(args[[i]]))
    }
  }
  
  for (d in dims){
    if(d %in% extend){args[[d]] %<>% list.extend(N)}
    lbls[[d]] = names(args[[d]])
  }
  
  # names(lbls) <- dims[sequence(length(lbls))]
  
  list(aesthetics = args, labels = lbls)  
}
### interactive/rscripts.R ------------------------
# Header
# Filename:       rscripts.R
# Description:    Contains functions generating various R scripts.
# Author:         Nima Ramezani Taghiabadi
# Email :         nima.ramezani@cba.com.au
# Start Date:     23 May 2017
# Last Revision:  23 May 2017
# Version:        0.0.1
#

# Version History:

# Version   Date                Action
# ----------------------------------
# 0.0.1     23 May 2017         Initial issue for D3TableFilter syncing observers


# for a output object of type D3TableFilter, D3TableFilter generates an input
# "<chartID>_edit"
# this observer does a simple input validation and sends a confirm or reject message after each edit.
# Only server to client!
D3TableFilter.observer.column.footer.R = function(itemID){paste0("
                                                                 nms = c('rownames', colnames(sync$", itemID, "))
                                                                 for (col in names(sync$", itemID, "_column.footer)){
                                                                 wch = which(nms == col) - 1
                                                                 if   (inherits(sync$", itemID, "_column.footer[[col]], 'function')){val = sapply(list(sync$", itemID, "[report$", itemID, "_filtered, col]), sync$", itemID, "_column.footer[[col]])}
                                                                 else {val = sync$", itemID, "_column.footer[[col]] %>% as.character}
                                                                 for (cn in wch){if(!is.empty(val)){setFootCellValue(session, tbl = '", itemID, "', row = 1, col = cn, value = val)}}
                                                                 }
                                                                 
                                                                 ")}  

# server to client
D3TableFilter.observer.column.editable.R = function(itemID){paste0("
                                                                   
                                                                   #debug(check)
                                                                   #check(x = sync$", itemID, "_column.editable)
                                                                   
                                                                   enacols = sync$", itemID, "_column.editable %>% unlist %>% coerce('logical') %>% which %>% names %>% intersect(c('rownames', colnames(sync$", itemID, ")))
                                                                   discols = c('rownames', colnames(sync$", itemID, ")) %-% enacols
                                                                   for(col in enacols){
                                                                   if (col == 'rownames'){
                                                                   enableEdit(session, '", itemID, "', 'col_0')
                                                                   } else {
                                                                   w = which(names(sync$", itemID, ") == col)
                                                                   enableEdit(session, '", itemID, "', 'col_' %+% w);  
                                                                   }
                                                                   }
                                                                   
                                                                   for(col in discols){
                                                                   if (col == 'rownames'){
                                                                   disableEdit(session, '", itemID, "', 'col_0')
                                                                   } else {
                                                                   w = which(names(sync$", itemID, ") == col)
                                                                   disableEdit(session, '", itemID, "', 'col_' %+% w);  
                                                                   }
                                                                   }
                                                                   ")
}  

# client to server:
D3TableFilter.observer.edit.R = function(itemID) {paste0("
                                                         if(is.null(input$", itemID, "_edit)) return(NULL);
                                                         edit <- input$", itemID, "_edit;
                                                         
                                                         isolate({
                                                         # need isolate, otherwise this observer would run twice
                                                         # for each edit
                                                         id  <- edit$id;
                                                         row <- as.integer(edit$row);
                                                         col <- as.integer(edit$col);
                                                         val <- edit$val;
                                                         nms <- colnames(sync$", itemID, ")
                                                         
                                                         if(col == 0) {
                                                         oldval <- rownames(sync$", itemID, ")[row];
                                                         cellClass = 'character'
                                                         fltr = items[['", itemID, "']]$filter[['rownames']]} 
                                                         else {
                                                         oldval <- sync$", itemID, "[row, col];
                                                         fltr = items[['", itemID, "']]$filter[[nms[col]]]
                                                         cellClass = class(sync$", itemID, "[, col])[1]
                                                         }
                                                         val0   = val
                                                         val    = try(coerce(val, cellClass), silent = T)
                                                         accept = inherits(val, cellClass) & !is.empty(val)
                                                         
                                                         if(accept & inherits(fltr, 'list') & !is.empty(fltr)){
                                                         accept = parse(text = filter2R(fltr)) %>% eval
                                                         }
                                                         
                                                         
                                                         if (accept){
                                                         if(col == 0) {
                                                         rownames(sync$", itemID, ")[row] <- val;
                                                         rownames(report$", itemID, ")[row] <- val;
                                                         } else {
                                                         shp = items[['", itemID, "']]$config$column.shape[[nms[col]]]
                                                         if (!is.null(shp)){
                                                         if(shp == 'radioButtons'){
                                                         sync$", itemID, "[, col] <- FALSE;
                                                         report$", itemID, "[, col] <- FALSE;
                                                         }
                                                         }
                                                         sync$", itemID, "[row, col] <- val;
                                                         report$", itemID, "[row, col] <- val;
                                                         
                                                         }
                                                         # confirm edits
                                                         confirmEdit(session, tbl = '", itemID, "', row = row, col = col, id = id, value = val);
                                                         report$", itemID, "_lastEdits['Success', 'Row'] <- row;
                                                         report$", itemID, "_lastEdits['Success', 'Column'] <- col;
                                                         report$", itemID, "_lastEdits['Success', 'Value'] <- val;
                                                         } else {
                                                         rejectEdit(session, tbl = '", itemID, "', row = row, col = col,  id = id, value = oldval);
                                                         report$", itemID, "_lastEdits['Fail', 'Row'] <- row;
                                                         report$", itemID, "_lastEdits['Fail', 'Column'] <- col;
                                                         report$", itemID, "_lastEdits['Fail', 'Value'] <- val0;
                                                         }
                                                         })
                                                         ")}

# Use it later for creating the default footer:
# footer = list('Mean', object[[i]] %>% colMeans %>% as.matrix %>% t) %>% as.data.frame
# names(footer) = c('Rownames', colnames(object[[i]]))

# Client 2 Server: FOB1
D3TableFilter.observer.filter.C2S.R = function(itemID){
  paste0(" 
         if(is.null(input$", itemID, "_filter)){return(NULL)}
         isolate({
         report$", itemID, "_filtered <- unlist(input$", itemID, "_filter$validRows);
         sync$", itemID, "_column.filter = list()
         nms = c('rownames', colnames(sync$", itemID, "))
         # lapply(input$", itemID, "_filter$filterSettings, function(x) )
         for(flt in input$", itemID, "_filter$filterSettings){
         colnumb = flt$column %>% substr(5, nchar(flt$column)) %>% as.integer
         colname = nms[colnumb]
         if(!is.na(colname)){sync$", itemID, "_column.filter[[colname]] = chif(is.empty(flt$value), NULL, flt$value)}
         # debug(check)
         # check('FOB1', colnumb, colname, input$", itemID, "_filter$filterSettings, flt, sync$", itemID, "_column.filter)
         }
         # report$", itemID, "_column.filter = sync$", itemID, "_column.filter
         })
         ")
}


#  Server 2 Client: FOB2
D3TableFilter.observer.filter.S2C.R = function(itemID){
  paste0(" 
         if(is.null(sync$", itemID, "_column.filter)){sync$", itemID, "_column.filter = items[['", itemID, "']]$config$column.filter}
         isolate({
         for(flt in input$", itemID, "_filter$filterSettings){
         nms = c('rownames', colnames(sync$", itemID, "))
         
         colnumb = flt$column %>% substr(5, nchar(flt$column)) %>% as.integer
         colname = nms[colnumb]
         colnumb = colnumb - 1
         
         if (colname %in% names(sync$", itemID, "_column.filter)){
         if (!identical(flt$value, sync$", itemID, "_column.filter[[colname]])){
         # set filter
         setFilter(session, tbl = '", itemID, "', col = 'col_' %+% colnumb, filterString = sync$", itemID, "_column.filter[[colname]], doFilter = TRUE);
         }
         # else {do nothing}
         } else {
         setFilter(session, tbl = '", itemID, "', col = 'col_' %+% colnumb, filterString = '', doFilter = TRUE);
         }
         # debug(check)
         # check('FOB2', y = input$", itemID, "_filter$filterSettings, z = colnumb, t = colname, r = flt, s = sync$", itemID, "_column.filter)
         # report$", itemID, "_column.filter = sync$", itemID, "_column.filter
         }
         })
         ")
}  

# client to server: sob1
D3TableFilter.observer.selected.C2S.R = function(itemID){
  paste0("
         if(is.null(input$", itemID, "_select)){return(NULL)}
         isolate({
         sync$", itemID, "_selected = input$", itemID, "_select
         report$", itemID, "_selected = sync$", itemID, "_selected
         })
         ")
}


# server 2 client: sob2
D3TableFilter.observer.selected.S2C.R = function(itemID){
  paste0("
         if(is.null(sync$", itemID, "_selected)){sync$", itemID, "_selected = items[['", itemID, "']]$config$selected}
         isolate({
         if(is.null(report$", itemID, "_selected)){report$", itemID, "_selected = items[['", itemID, "']]$config$selected}
         if(is.null(sync$", itemID, "_row.color)){sync$", itemID, "_row.color = items[['", itemID, "']]$config$row.color}
         sel   = sync$", itemID, "_selected %-% report$", itemID, "_selected
         desel = report$", itemID, "_selected %-% sync$", itemID, "_selected
         for (i in sel){  setRowClass(session, tbl = '", itemID, "', row = i, class = items['", itemID, "']$config$selection.color)}
         for (i in desel){setRowClass(session, tbl = '", itemID, "', row = i, class = chif(sync$", itemID, "_row.color[i] == items['", itemID, "']$config$selection.color, '', items[['", itemID, "']]$config$row.color[i]))}
         report$", itemID, "_selected = sync$", itemID, "_selected
         })
         ")
}


# server 2 client: for row color: cob2
D3TableFilter.observer.color.S2C.R = function(itemID){
  paste0("
         if(is.null(sync$", itemID, "_row.color)){sync$", itemID, "_row.color = items[['", itemID, "']]$config$row.color}
         isolate({
         # debug(check)
         # check(x = 'cob2', y = sync$", itemID, "_row.color, z = report$", itemID, "_row.color, t = sync$", itemID, ")
         if(is.null(report$", itemID, "_row.color)){report$", itemID, "_row.color = items[['", itemID, "']]$config$row.color}
         w = which(sync$", itemID, "_row.color != report$", itemID, "_row.color)
         for (i in w){setRowClass(session, tbl = '", itemID, "', row = i, class = sync$", itemID, "_row.color[i])}
         report$", itemID, "_row.color = sync$", itemID, "_row.color
         })
         ")
}

# server to client: for table contents: tob2 
D3TableFilter.observer.table.S2C.R = function(itemID){
  paste0("
         if(is.null(sync$", itemID, ")){sync$", itemID, " = items[['", itemID, "']]$data}
         isolate({
         if(is.null(report$", itemID, ")){report$", itemID, " = items[['", itemID, "']]$data}
         # debug(check)
         # check(x = 'tob2', y = report$", itemID, ", z = sync$", itemID, ")
         for (i in sequence(ncol(sync$", itemID, "))){
         w = which(sync$", itemID, "[,i] != report$", itemID, "[,i])
         for (j in w) {
         setCellValue(session, tbl = '", itemID, "', row = j, col = i, value = sync$", itemID, "[j,i], feedback = TRUE)
         report$", itemID, "[j,i] = sync$", itemID, "[j,i]
         }
         }
         rnew = rownames(sync$", itemID, ")
         rold = rownames(report$", itemID, ")
         w  = which(rnew != rold)
         
         for (j in w) {
         setCellValue(session, tbl = '", itemID, "', row = j, col = 0, value = rnew[j], feedback = TRUE)
         rownames(report$", itemID, ")[j] = rnew[j]
         }
         })
         ")
}

D3TableFilter.service = function(itemID){
  paste0("items[['", itemID, "']]$data %>% D3TableFilter.table(config = items[['", itemID, "']]$config, width = items[['", itemID, "']]$width, height = items[['", itemID, "']]$height)")
}
### interactive/jscripts.R ------------------------
#### dimple:
dimple.js = function(field_name = 'group'){
  S1 =   
    '<script>
  myChart.axes.filter(function(ax){return ax.position == "x"})[0].titleShape.text(opts.xlab)
  myChart.axes.filter(function(ax){return ax.position == "y"})[0].titleShape.text(opts.ylab)
  myChart.legends = [];
  svg.selectAll("title_text")
  .data(["'
  S2 = ''
  S3 = 
    '"])
  .enter()
  .append("text")
  .attr("x", 499)
  .attr("y", function (d, i) { return 90 + i * 14; })
  .style("font-family", "sans-serif")
  .style("font-size", "10px")
  .style("color", "Black")
  .text(function (d) { return d; });
  var filterValues = dimple.getUniqueValues(data, "'
  S5 = '");
  l.shapes.selectAll("rect")
  .on("click", function (e) {
  var hide = false;
  var newFilters = [];
  filterValues.forEach(function (f) {
  if (f === e.aggField.slice(-1)[0]) {
  hide = true;
  } else {
  newFilters.push(f);
  }
  });
  if (hide) {
  d3.select(this).style("opacity", 0.2);
  } else {
  newFilters.push(e.aggField.slice(-1)[0]);
  d3.select(this).style("opacity", 0.8);
  }
  filterValues = newFilters;
  myChart.data = dimple.filterData(data, "'
  
  S6 = '", filterValues);
  myChart.draw(800);
  myChart.axes.filter(function(ax){return ax.position == "x"})[0].titleShape.text(opts.xlab)
  myChart.axes.filter(function(ax){return ax.position == "y"})[0].titleShape.text(opts.ylab)
  });
  </script>'
  return(paste0(S1,S2, S3, field_name, S5, field_name, S6))
}


#### D3TableFilter:
D3TableFilter.color.single.js = function(col){
  JS('function colorScale(obj, i){
     return "' %+% col %+% '"}')
  }

D3TableFilter.color.nominal.js = function(domain, range){
  range %<>% vect.extend(length(domain))
  dp = paste(domain, range) %>% duplicated
  domain = domain[!dp]
  range  = range[!dp]
  ss = 'function colorScale(obj,i){
  var color = d3.scale.ordinal().domain([' %+% 
    paste('"' %+% domain %+% '"', collapse = ',') %+% ']).range([' %+%
    paste('"' %+% range  %+% '"', collapse = ',') %+% ']);
  return color(i);}'
  return(JS(ss))
}

D3TableFilter.color.numeric.js = function(domain, range){
  N  = length(range) 
  q  = domain %>% quantile(probs = (0:(N-1))/(N-1))
  ss = 'function colorScale(obj,i){
  var color = d3.scale.linear().domain([' %+% 
    paste(q, collapse = ',') %+% ']).range([' %+%
    paste('"' %+% range  %+% '"', collapse = ',') %+% ']);
  return color(i);}'
  return(JS(ss))
  }


D3TableFilter.shape.bar.js = function(format = '.1f'){
  JS(paste0('function makeGraph(selection){
            // find out wich table and column
            var regex = /(col_\\d+)/;
            var col = regex.exec(this[0][0].className)[0];
            var regex = /tbl_(\\S+)/;
            var tbl = regex.exec(this[0][0].className)[1];
            var innerWidth = 117;
            var innerHeight = 14;
            
            // create a scaling function
            var max = colMax(tbl, col);
            var min = colMin(tbl, col);
            var wScale = d3.scale.linear()
            .domain([0, max])
            .range([0, innerWidth]);
            
            // text formatting function
            var textformat = d3.format("', format, '");
            
            // column has been initialized before, update function
            if(tbl + "_" + col + "_init" in window) {
            var sel = selection.selectAll("svg")
            .selectAll("rect")
            .transition().duration(500)
            .attr("width", function(d) { return wScale(d.value)});
            var txt = selection
            .selectAll("text")
            .text(function(d) { return textformat(d.value); });
            return(null);
            }
            
            // can remove padding here, but still cant position text and box independently
            this.style("padding", "5px 5px 5px 5px");
            
            // remove text. will be added back later
            selection.text(null);
            
            var svg = selection.append("svg")
            .style("position",  "absolute")
            .attr("width", innerWidth)
            .attr("height", innerHeight);
            
            var box = svg.append("rect")
            .style("fill", "lightblue")
            .attr("stroke","none")
            .attr("height", innerHeight)
            .attr("width", min)
            .transition().duration(500)
            .attr("width", function(d) { return wScale(d.value); });
            
            // format number and add text back
            var textdiv = selection.append("div");
            textdiv.style("position",  "relative")
            .attr("align", "right");
            
            textdiv.append("text")
            .text(function(d) { return textformat(d.value); });
            window[tbl + "_" + col + "_init"] = true;
}'))
} 

D3TableFilter.shape.bubble.js = function(){
  
  JS(paste0('function makeGraph(selection){
            
            // find out wich table and column
            var regex = /(col_\\d+)/;
            var col = regex.exec(this[0][0].className)[0];
            var regex = /tbl_(\\S+)/;
            var tbl = regex.exec(this[0][0].className)[1];
            
            // create a scaling function
            var domain = colExtent(tbl, col);
            var rScale = d3.scale.sqrt()
            .domain(domain)
            .range([8, 14]);
            
            // column has been initialized before, update function
            if(tbl + "_" + col + "_init" in window) {
            var sel = selection.selectAll("svg")
            .selectAll("circle")
            .transition().duration(500)
            .attr("r", function(d) { return rScale(d.value)});
            return(null);
            }
            
            // remove text. will be added later within the svg
            selection.text(null)
            
            // create svg element
            var svg = selection.append("svg")
            .attr("width", 28)
            .attr("height", 28);
            
            // create a circle with a radius ("r") scaled to the 
            // value of the cell ("d.value")
            var circle = svg.append("g")
            .append("circle").attr("class", "circle")
            .attr("cx", 14)
            .attr("cy", 14)
            .style("fill", "orange")
            .attr("stroke","none")
            .attr("r", domain[0])
            .transition().duration(400)
            .attr("r", function(d) { return rScale(d.value); }); 
            
            // place the text within the circle
            var text = svg.append("g")
            .append("text").attr("class", "text")
            .style("fill", "black")
            .attr("x", 14)
            .attr("y", 14)
            .attr("dy", ".35em")
            .attr("text-anchor", "middle")
            .text(function (d) { return d.value; });
            window[tbl + "_" + col + "_init"] = true;
            
}'))
}


D3TableFilter.font.bold.js = JS('function makeGraph(selection){selection.style("font-weight", "bold")}')

D3TableFilter.font.js = function(weight = 'bold', side = 'right', format = '.1f'){
  sidestr   = chif(is.null(side)  , '', paste0('.classed("text-', side, '", true)'))
  weightstr = chif(is.null(weight), '', paste0('.style("font-weight", "', weight ,'")'))
  formatstr2 = chif(is.null(format), '', paste0('.text(function(d) { return textformat(d.value); })'))
  formatstr1 = chif(is.null(format), '', paste0('var textformat = d3.format("', format, '");'))
  JS(paste0('function makeGraph(selection){', formatstr1, 'selection', sidestr , weightstr, formatstr2, ';}'))
}






# dygraphs:
dygraphs.shape.multibar.js = JS("
                                function multiColumnBarPlotter(e) {
                                // We need to handle all the series simultaneously.
                                function darkenColor(colorStr) {
                                // Defined in dygraph-utils.js
                                var color = Dygraph.toRGB_(colorStr);
                                color.r = Math.floor((255 + color.r) / 2);
                                color.g = Math.floor((255 + color.g) / 2);
                                color.b = Math.floor((255 + color.b) / 2);
                                return 'rgb(' + color.r + ',' + color.g + ',' + color.b + ')';
                                }
                                
                                if (e.seriesIndex !== 0) return;
                                var g = e.dygraph;
                                var ctx = e.drawingContext;
                                var sets = e.allSeriesPoints;
                                var y_bottom = e.dygraph.toDomYCoord(0);
                                // Find the minimum separation between x-values.
                                // This determines the bar width.
                                var min_sep = Infinity;
                                for (var j = 0; j < sets.length; j++) {
                                var points = sets[j];
                                for (var i = 1; i < points.length; i++) {
                                var sep = points[i].canvasx - points[i - 1].canvasx;
                                if (sep < min_sep) min_sep = sep;
                                }
                                }
                                var bar_width = Math.floor(2.0 / 3 * min_sep);
                                var fillColors = [];
                                var strokeColors = g.getColors();
                                for (var i = 0; i < strokeColors.length; i++) {
                                fillColors.push(darkenColor(strokeColors[i]));
                                }
                                for (var j = 0; j < sets.length; j++) {
                                ctx.fillStyle = fillColors[j];
                                ctx.strokeStyle = strokeColors[j];
                                for (var i = 0; i < sets[j].length; i++) {
                                var p = sets[j][i];
                                var center_x = p.canvasx;
                                var x_left = center_x - (bar_width / 2) * (1 - j/(sets.length-1));
                                ctx.fillRect(x_left, p.canvasy,
                                bar_width/sets.length, y_bottom - p.canvasy);
                                ctx.strokeRect(x_left, p.canvasy,
                                bar_width/sets.length, y_bottom - p.canvasy);
                                }}}
                                ")

dygraphs.shape.bar.js = JS("
                           // This function draws bars for a single series. See
                           // multiColumnBarPlotter below for a plotter which can draw multi-series
                           // bar charts.
                           function barChartPlotter(e) {
                           function darkenColor(colorStr) {
                           // Defined in dygraph-utils.js
                           var color = Dygraph.toRGB_(colorStr);
                           color.r = Math.floor((255 + color.r) / 2);
                           color.g = Math.floor((255 + color.g) / 2);
                           color.b = Math.floor((255 + color.b) / 2);
                           return 'rgb(' + color.r + ',' + color.g + ',' + color.b + ')';
                           }
                           var ctx = e.drawingContext;
                           var points = e.points;
                           var y_bottom = e.dygraph.toDomYCoord(0);
                           ctx.fillStyle = darkenColor(e.color);
                           // Find the minimum separation between x-values.
                           // This determines the bar width.
                           var min_sep = Infinity;
                           for (var i = 1; i < points.length; i++) {
                           var sep = points[i].canvasx - points[i - 1].canvasx;
                           if (sep < min_sep) min_sep = sep;
                           }
                           var bar_width = Math.floor(2.0 / 3 * min_sep);
                           // Do the actual plotting.
                           for (var i = 0; i < points.length; i++) {
                           var p = points[i];
                           var center_x = p.canvasx;
                           ctx.fillRect(center_x - bar_width / 2, p.canvasy,
                           bar_width, y_bottom - p.canvasy);
                           ctx.strokeRect(center_x - bar_width / 2, p.canvasy,
                           bar_width, y_bottom - p.canvasy);
                           }}
                           ")

dygraphs.shape.candle.js = JS("
                              function candlePlotter(e) {
                              // This is the officially endorsed way to plot all the series at once.
                              var BAR_WIDTH = 8;
                              if (e.seriesIndex !== 0) return;
                              var setCount = e.seriesCount;
                              if (setCount != 4) {
                              throw 'Exactly 4 prices each point must be provided for candle chart (open close high low)';
                              }
                              var prices = [];
                              var price;
                              var sets = e.allSeriesPoints;
                              for (var p = 0 ; p < sets[0].length; p++) {
                              price = {
                              open : sets[0][p].yval,
                              close : sets[1][p].yval,
                              high : sets[2][p].yval,
                              low : sets[3][p].yval,
                              openY : sets[0][p].y,
                              closeY : sets[1][p].y,
                              highY : sets[2][p].y,
                              lowY : sets[3][p].y
                              };
                              prices.push(price);
                              }
                              var area = e.plotArea;
                              var ctx = e.drawingContext;
                              ctx.strokeStyle = '#202020';
                              ctx.lineWidth = 0.6;
                              for (p = 0 ; p < prices.length; p++) {
                              ctx.beginPath();
                              price = prices[p];
                              var topY = area.h * price.highY + area.y;
                              var bottomY = area.h * price.lowY + area.y;
                              var centerX = area.x + sets[0][p].x * area.w;
                              ctx.moveTo(centerX, topY);
                              ctx.lineTo(centerX, bottomY);
                              ctx.closePath();
                              ctx.stroke();
                              var bodyY;
                              if (price.open > price.close) {
                              ctx.fillStyle ='rgba(244,44,44,1.0)';
                              bodyY = area.h * price.openY + area.y;
                              }
                              else {
                              ctx.fillStyle ='rgba(44,244,44,1.0)';
                              bodyY = area.h * price.closeY  + area.y;
                              }
                              var bodyHeight = area.h * Math.abs(price.openY - price.closeY);
                              ctx.fillRect(centerX - BAR_WIDTH / 2, bodyY, BAR_WIDTH,  bodyHeight);
                              }}
                              ")


#' @export
dygraphs.click.js = function(input_id){
  "function(e, x, points){
  var row = points[0].idx + 1;" %+%
    "Shiny.onInputChange('" %+% input_id %+% "', row)}"
}
### interactive/D3TableFilter.R ------------------------
# Header
# Filename:       D3TableFilter.R
# Description:    Contains functions for plotting table charts from D3TableFilter package using standrad inputs.
# Author:         Nima Ramezani Taghiabadi
# Email :         nima.ramezani@cba.com.au
# Start Date:     26 April 2017
# Last Revision:  26 April 2017
# Version:        0.0.1
#

# Version History:

# Version   Date                Action
# ----------------------------------
# 0.0.1     26 April 2017       Initial issue


# Default settings for package DT:
D3TableFilter.table.defset = defset %>% list.edit(
  # Valid classes for all dimensions
  dimclass  = list(
    label = valid.classes,
    color = valid.classes),
  multiples = c('label', 'color'),
  withRowNames  = T,
  column.filter.enabled = TRUE
)

D3TableFilter.addColumnTypes = function(config, obj){
  D3TableFilter.column_type = c(numeric = 'Number', character = 'String', Date = 'Date')
  types = apply(obj, 2, class) 
  names(types) = NULL
  types = D3TableFilter.column_type['type']
  types[is.na(types)] <- 'None'
  config$sort_config %<>% add.list(sort_types = types)
  return(config)
}

# Check here for complete reference:
# http://tablefilter.free.fr/doc.php

D3TableFilter.tableprops = function(config){
  config %>% list.extract('fixed_headers', 'tbody_height', 'filters_cell_tag', 'col_width',
                          'inf_div_css_class', 'left_div_css_class', 'right_div_css_class', 'middle_div_css_class',
                          'flts_row_css_class', 'flt_css_class', 'flt_small_css_class', 'flt_multi_css_class', 'single_flt_css_class',
                          'highlight_css_class', 'paging_slc_css_class', 'even_row_css_class', 'odd_row_css_class', 'btn_css_class', 'btn_reset_css_class',
                          'input_watermark_css_class', 'active_columns_css_class', 'nb_pages_css_class', 'paging_btn_css_class',
                          'on_keyup', 'on_keyup_delay',
                          'grid', 'search_type', 'refresh_filters', 'rows_always_visible',
                          'col_operation', 'exact_match', 'custom_cell_data', 
                          'btn', 'btn_text','btn_reset', 'btn_reset_text', 'btn_reset_html', 'btn_reset_target_id', 'btn_next_page_text', 'btn_prev_page_text', 'btn_last_page_text', 'btn_first_page_text', 
                          'btn_next_page_html', 'btn_prev_page_html', 'btn_last_page_html', 'btn_first_page_html',
                          'page_text', 'of_text', 
                          'sort', 'sort_select', 'sort_num_asc', 'sort_num_desc', 
                          'slc_filling_method', 'multiple_slc_tooltip', 
                          'rows_counter', 'rows_counter_text', 'col_number_format', 'sort_config', 'rows_always_visible',
                          paste('col', 1:10, sep = '_'), 'rows_always_visible', 
                          'sort_config', 'msg_sort', 'on_sort_loaded')
}

D3TableFilter.config.verify = function(config){
  config$withRowNames          %<>% verify('logical', domain = c(T,F), lengths = 1, default = T, varname = "config$withRowNames")
  config$column.filter.enabled %<>% verify('logical', domain = c(T,F), lengths = 1, default = T, varname = "config$column.filter.enabled")  
  config$selection.mode        %<>% verify('character', domain = c('single', 'multi'), lengths = 1, varname = 'config$selection.mode')
  config$selection.color       %<>% verify('character', domain = c('active', 'success', 'info', 'warning', 'danger'), default = 'info', lengths = 1, varname = 'config$selection.color')
  config$footer.font.weight    %<>% verify('character', domain = c('bold'), lengths = 1, varname = 'config$footer.font.weight')
  config$footer.font.adjust    %<>% verify('character', domain = c('left', 'right', 'center'), lengths = 1, varname = 'config$footer.font.adjust')
  config$footer.font.format    %<>% verify('character', domain = 1:9 %+% '.f', lengths = 1, varname = 'config$footer.font.format')
  # and many more ...
  return(config)
}

# Converts config$column.footer list to a data.frame 2b passed as argument 'footData' to function 'd3tf()'  
D3TableFilter.footData = function(obj, config){
  out = data.frame()
  rws = obj %>% D3TableFilter.filteredRows(config)
  for (col in names(config$column.footer)){
    nms = c('rownames', colnames(obj))
    if   (config$column.footer[[col]] %>% inherits('function')){val = obj[rws, col] %>% list %>% sapply(config$column.footer[[col]])}
    else {val = config$column.footer[[col]] %>% as.character}
    if(col == 'rownames'){col = 'Rownames'}
    if(!is.empty(val)){out[1, col] = val}
  }
  return(chif(out %>% is.empty, NULL, out))
}

D3TableFilter.rowStyles = function(obj, config){
  if(is.null(config$row.color) & is.null(config$selection.mode)){return(NULL)}
  
  if(!is.null(config$row.color)){
    out = config$row.color %>% verify('character', domain = c('', 'active', 'success', 'info', 'warning', 'danger'), varname = 'config$row.color') %>% vect.extend(nrow(obj))    
  } else {out = rep('', nrow(obj))}
  
  if(!is.null(config$selection.mode)){
    out[config$selected] = 'info'
  }
  return(out)
}

# Generates column.editable from config to be given to argument 'edit' when d3tf() is called
D3TableFilter.edit = function(colnames, config){
  if(is.empty(config$column.editable)){return(FALSE)}
  enacols = config$column.editable %>% verify('list', default = list()) %>% 
    unlist %>% coerce('logical') %>% which %>% names %>% intersect(c('rownames', colnames))
  
  nms = c('rownames', colnames %>% verify('character', default = character(), varname = 'colnames')) %>% unique
  out = character()
  for(i in enacols){
    w = which(nms == i) - 1
    for (j in w){out %<>% c('col_' %+% w)}
  }
  return(out)
}

D3TableFilter.lastEdits.empty <- data.frame(Row = c("", ""), Column = (c("", "")), Value = (c("", "")), stringsAsFactors = FALSE);
rownames(D3TableFilter.lastEdits.empty) <- c("Fail", "Success");


D3TableFilter.initialFilters = function(colnames, config){
  nms = c('rownames', colnames %>% verify('character', default = character(), varname = 'colnames')) %>% unique
  out = list()
  for(i in names(config$column.filter) %>% verify('character', domain = nms, default = character(), varname = 'names(config$column.filter)')){
    w = which (nms == i)
    for (j in w){out[['col_' %+% (w - 1)]] = config$column.filter[[i]]}
  }
  return(out)
}

D3TableFilter.applyFilterstr = function(v, fltstr){
  # todo: currently it can only work with four very simple filterstrs, "<, <=, >=, >" does not support "=" and combined conditions with and , or, not, ...
  if(v %>% inherits('character')){return(fltstr %>% tolower %>% grep(v %>% tolower))}
  parse(text = paste('v', fltstr)) %>% eval %>% which
}

D3TableFilter.filteredRows = function(obj, config){
  ff = obj %>% nrow %>% sequence
  for(i in names(config$column.filter)){
    if (i == 'rownames'){
      ff = ff %^% (rownames(obj) %>% D3TableFilter.applyFilterstr(config$column.filter[[i]]))
    } else {
      ff = ff %^% (obj[, i] %>% D3TableFilter.applyFilterstr(config$column.filter[[i]]))
    }
  }
  return(ff)
}

D3TableFilter.colNames = function(config){
  if(is.null(config$column.title)){return(NULL)}
  cn = character()
  for (cc in names(config$column.title)){
    if(cc == 'rownames'){cn['Rownames'] <- config$column.title[[cc]]} else {cn[cc] <- config$column.title[[cc]]}
  }
  return(cn)
}

D3TableFilter.bgColScales = function(obj, config){
  bgcs = list()
  nms  = c('rownames', colnames(obj))
  for (cc in names(config$column.color)){
    w = which(nms == cc) - 1
    config$column.color.auto[[cc]] %<>% verify('logical', domain = c(T,F), lengths = 1, default = F, varname = "config$column.color.auto['" %+% cc %+% "']")
    if(config$column.color[[cc]] %>% unique %>% length == 1){
      scr = D3TableFilter.color.single.js(config$column.color[[cc]] %>% unique)
    } else if(config$column.color.auto[[cc]]){
      scr = paste('auto', config$column.color[[cc]] %>% paste(collapse = ':'), sep = ':') 
    } else if(inherits(obj[, cc], valid.numeric.classes)){
      scr = D3TableFilter.color.numeric.js(domain = obj[, cc], range = config$column.color[[cc]])
    } else if (inherits(obj[, cc], valid.nominal.classes)){
      scr = D3TableFilter.color.nominal.js(domain = obj[, cc], range = config$column.color[[cc]])
    } else {scr = ''}
    if(!is.empty(scr)){for (i in w){bgcs[[paste0('col_', i)]] <- scr}}
  }
  return(bgcs)
}

D3TableFilter.table = function(obj, label = NULL, color = NULL, shape = NULL, config = NULL, ...){
  if (is.empty(obj)){return(NULL)}
  
  if (is.null(label)){label = as.list(names(obj))}  
  # Verifications:
  assert(require(D3TableFilter), "Package D3TableFilter is not installed!", err_src = match.call()[[1]])
  config = D3TableFilter.table.defset %<==>% (config %>% verify('list', default = list(), varname = 'config')) %>% 
    D3TableFilter.config.verify
  
  # Preparing Aesthetics:
  # Preparing Aesthetics:
  a = prepareAesthetics(label = label, color = color, shape = shape, extend = c('label','color', 'shape'))
  L = a$labels
  A = a$aesthetics %>% list.remove('shape')
  
  obj %<>% prepare4Plot(A, config)
  names(obj) <- names(obj) %>% make.unique('.1')
  
  # Specify background color from argument 'color':
  bgColScales = list()
  for(i in seq(L$color)){
    if(!is.empty(color[[i]])){
      if(L$color[i] %in% L$label){L$color[i] %<>% paste('1', sep = '.')}
      lin = paste0('col_', i)# list item name
      if (obj[, L$color[i]] %>% unique %>% length == 1){
        bgColScales[[lin]] = D3TableFilter.color.single.js(obj[1, L$color[i]])
      } else if (obj[, L$color[i]] %>% length == nrow(obj)){
        if(inherits(obj[,L$label[i]], valid.numeric.classes)){
          bgColScales[[lin]] = D3TableFilter.color.numeric.js(domain = obj[, L$label[i]], range = obj[, L$color[i]])
        } else {
          bgColScales[[lin]] = D3TableFilter.color.nominal.js(domain = obj[, L$label[i]], range = obj[, L$color[i]])
        }
      }
    }
  }  
  
  if(is.null(L$color)){bgColScales = D3TableFilter.bgColScales(obj, config)}
  
  if(is.null(L$shape)){
    if(!is.null(config$column.shape)){
      L$shape = rep('', length(L$label))
      for (i in names(config$column.shape)){
        w = which(L$label == i)
        L$shape[w] = config$column.shape[[i]]
      }
    }
  }
  # turn cell values into scaled SVG graphics from argument 'shape':
  cellFunctions = list()
  for(i in seq(L$shape)){
    shp = L$shape[i]
    if(!is.empty(shp)){
      lin = paste0('col_', i)# list item name
      if      (shp == 'bar'){cellFunctions[[lin]] = D3TableFilter.shape.bar.js()} 
      else if (shp %in% c('bubble', 'circle', 'point', 'dot')){cellFunctions[[lin]] = D3TableFilter.shape.bubble.js()}
    }
  }  
  
  footCellFunctions <- list(
    col_0 = D3TableFilter.font.js(side = 'left', format = NULL, weight = 'bold'),
    col_1 = D3TableFilter.font.js(side = 'left', format = '.1f', weight = 'bold'),
    col_2 = D3TableFilter.font.js(side = 'center', format = '.1f', weight = 'bold'),
    col_3 = D3TableFilter.font.js(side = 'right', format = '.1f', weight = 'bold')
  )
  
  wcb = which(L$shape == 'checkBox')
  wrb = which(L$shape == 'radioButtons')
  
  obj[, L$label] %>% D3TableFilter::d3tf(
    colNames     = D3TableFilter.colNames(config),
    bgColScales  = bgColScales, 
    cellFunctions = cellFunctions,
    footCellFunctions = footCellFunctions,
    showRowNames = config$withRowNames,
    enableTf     = config$column.filter.enabled,
    filterInput  = config$column.filter.enabled,
    edit         = L$label %>% D3TableFilter.edit(config),
    checkBoxes   = chif(is.empty(wcb), NULL, 'col_' %+% wcb),
    radioButtons = chif(is.empty(wcb), NULL, 'col_' %+% wrb),
    initialFilters = D3TableFilter.initialFilters(L$label, config),
    footData = D3TableFilter.footData(obj[, L$label], config),
    tableStyle = config$table.style,
    selectableRows = config$selection.mode,
    selectableRowsClass = config$selection.color,
    rowStyles = D3TableFilter.rowStyles(obj[, L$label], config),
    tableProps = config %>% D3TableFilter.tableprops,
    ...)
}


### interactive/dashboard_v1.9.0.R ------------------------


# Header
# Filename:      dashboard.R
# Description:   This project, aims to create a ref class containing multiple objects
#                that can issue a shiny dashboard
# Author:        Nima Ramezani Taghiabadi
# Email :        nima.ramezani@cba.com.au
# Start Date:    22 January 2016
# Last Revision: 23 May 2017
# Version:       1.9.0

# Version History:

# Version   Date                Action
# ---------------------------------------
# 1.6.0     04 July 2016        A number of changes made. Refer to dashboard.R (version 1.6)

# Changes from version 1.5:
# 1- method io.str() transferred from dash.tools.R
# 2- Starting letters of input and cloth types changed to lowercase to match shiny namespace: Example: radioButtons changed to radioButtons
# 3- Valid Container types separated from valid input types
# 4- class properties 'inputs' and 'outputs' consolidated to one single list called 'items' which must be a named list
# 5- layouts must be specified by item names not numbers
# 6- field ID removed and replaced by item name

# 1.6.2     08 September 2016   Argument inline added to checkboxGroupInput.
# 1.6.3     12 October 2016     Wordcloud2 plots added.
# 1.7.0     15 May 2017         tabPanel and many other containers can also get a list as layout
# 1.7.1     15 May 2017         textInput added
# 1.7.2     15 May 2017         D3TableFilterOutput added
# 1.7.3     15 May 2017         container tabsetPanel added
# 1.7.4     15 May 2017         tabPanel container can accept list as layout
# 1.7.4     15 May 2017         tabPanel added as cloth
# 1.7.5     15 May 2017         highcharterOutput added
# 1.7.6     15 May 2017         d3plusOutput added
# 1.7.7     15 May 2017         observers added as list (todo: named list items should become observeEvents)
# 1.7.8     15 May 2017         property 'prerun' added to the class
# 1.8.0     17 May 2017         Start adding syncing feature: property 'object' renamed to sync for synced items.
# 1.9.0     23 May 2017         syncing added for D3TableFilter: reactive list properties 'sync' and 'report' added.


valid.box.statuses = c('primary', # Blue (sometimes dark blue),
                       'success', # Green
                       'info',    # Blue
                       'warning', # Orange
                       'danger'  # Red
)
valid.colors = c('red', 'yellow', 'aqua', 'blue', 'light-blue', 'green', 'navy', 'teal', 'olive', 'lime', 'orange',
                 'fuchsia', 'purple', 'maroon', 'black')

valid.input.types = c("textInput", "radioButtons", "sliderInput", "actionButton", "checkboxInput", "checkboxGroupInput", "selectInput", "dateInput",
                      "dateRangeInput", "fileInput", "numericInput")

valid.output.types = c("uiOutput", "dynamicInput", "plotOutput", "verbatimTextOutput", "textOutput", "tableOutput", "dataTableOutput", "htmlOutput",
                       "gglVisChartOutput", "rChartsdPlotOutput", 'dygraphOutput', 'plotlyOutput', 'amChartsOutput',
                       "leafletOutput", "infoBoxOutput", "valueBoxOutput", "wordcloud2Output", 'bubblesOutput', 'd3plusOutput', 'plotlyOutput',
                       "highcharterOutput", "D3TableFilterOutput",
                       "static")

valid.container.types = c("column", "box", "fluidPage", "dashboardPage", "tabsetPanel",
                          "sidebarLayout", "navbarPage", "navbarMenu", "tabPanel", "wellPanel")


valid.cloth.types = c("box", "infoBox", "valueBox", "column", "wellPanel", "tabPanel")

valid.navbar.positions = c("static-top", "fixed-top", "fixed-bottom")

valid.dashboard.skins  = c("blue", "black", "purple", "green", "red", "yellow")

# Returns the number of elements of the given list which are either 'list' or 'character'
nListOrCharItems = function(lst){
  sum = 0
  for (i in lst){
    if (inherits(i, 'list') | inherits(i, 'character')){sum = sum + 1}
  }
  return(sum)
}


#' @exportClass DASHBOARD
DASHBOARD <- setRefClass("DASHBOARD",
                         fields = list(
                           name        = "character",
                           items       = "list",
                           king.layout = "list",
                           prerun      = 'character',
                           observers   = "list",
                           reactives   = "character"
                         ),
                         
                         methods = list(
                           # Class constructor
                           initialize = function(values = list(), name = "niravis.dashboard", ...){
                             callSuper(...)
                             # Field assignment:
                             name  <<- name
                             self.verify()
                             # then output[i]$title has priority, then output[i]$cloth$title
                           },
                           
                           self.verify = function(){
                             verify(items,  'list', varname = 'items')
                             for (i in items){
                               verify(i, 'list', names_in = c('type'), varname = "i")
                               verify(i$type, 'character', domain = c(valid.input.types, valid.container.types, valid.output.types), varname = i$type)
                             }
                           },
                           
                           io.str = function(i){
                             assert(i %in% names(items), "Element '" %+% i %+% "' has been mentioned but doesn't exist in the list of elements!", err_src = 'io.str')
                             if (items[[i]]$type %in% valid.output.types){
                               scr = paste0("items[['", i ,"']]$object")
                             } else if (items[[i]]$type %in% c(valid.input.types, valid.container.types)) {
                               scr = paste0("get.item.object('", i,"')")
                             } else {return("")}
                             return(scr)
                           },
                           
                           io.clothed.str = function(i, cloth = NULL){
                             s = io.str(i)
                             if (is.null(cloth)){return(s)}
                             
                             verify(cloth, "list")
                             verify(cloth$type, "character", domain = valid.cloth.types)
                             
                             cloth.str = "items[['" %+% i %+% "']]$cloth"
                             
                             switch(cloth$type,
                                    "box"       = {scr = "box("
                                    if (!is.null(cloth$title)){
                                      verify(cloth$title, 'character')
                                      scr = paste0(scr, "title = ", cloth.str, "$title,")
                                    }
                                    if (!is.null(cloth$footer)){
                                      verify(cloth$footer, 'character')
                                      scr = paste0(scr, "title = ", cloth.str, "$title,")
                                    }
                                    if (!is.null(cloth$status)){
                                      verify(cloth$status, 'character', domain = valid.box.statuses)
                                      scr = paste0(scr, "status = ", cloth.str, "$status,")
                                    }
                                    if (!is.null(cloth$solidHeader)){
                                      verify(cloth$solidHeader, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "solidHeader = ", cloth.str, "$solidHeader,")
                                    }
                                    if (!is.null(cloth$background)){
                                      verify(cloth$background, 'character', domain = valid.colors)
                                      scr = paste0(scr, "background = ", cloth.str, "$background,")
                                    }
                                    
                                    if (!is.null(cloth$weight)){
                                      verify(cloth$weight, c('numeric', 'integer'), domain = c(1,12))
                                      scr = paste0(scr, "width = ", cloth.str, "$weight,")
                                    }
                                    
                                    if (!is.null(cloth$height)){
                                      verify(cloth$height, 'character')
                                      scr = paste0(scr, "height = ", cloth.str, "$height,")
                                    }
                                    
                                    if (!is.null(cloth$collapsible)){
                                      verify(cloth$collapsible, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "collapsible = ", cloth.str, "$collapsible,")
                                    }
                                    if (!is.null(cloth$collapsed)){
                                      verify(cloth$collapsed, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "collapsed = ", cloth.str, "$collapsed,")
                                    }
                                    scr = scr %+% s %+% ")"},
                                    "tabPanel"  = {
                                      scr = "tabPanel(" %+% "title= '" %+%  verify(cloth$title, 'character', varname = "cloth$title") %+% "'"
                                      if (!is.null(cloth$icon)){
                                        verify(cloth$icon, 'character')
                                        scr   = paste0(scr, "icon = shiny::icon(", cloth.str, "$icon),")
                                      }
                                      scr = scr %+% list2Script(cloth, fields_remove = c('type', 'title', 'icon'), arguments = c(weight = 'width'))
                                    },
                                    "infoBox"   = {scr = "infoBox("
                                    ttl = verify(cloth$title, 'character', default = '')
                                    scr = paste0(scr, "title = ", "'", ttl, "', ")
                                    
                                    #if (!is.null(cloth$title)){
                                    #verify(cloth$title, 'character')
                                    #scr = paste0(scr, "title = ", cloth.str, "$title,")
                                    #} else {}
                                    if (!is.null(cloth$subtitle)){
                                      verify(cloth$subtitle, 'character')
                                      scr = paste0(scr, "subtitle = ", cloth.str, "$subtitle,")
                                    }
                                    if (!is.null(cloth$icon)){
                                      verify(cloth$icon, 'character')
                                      scr   = paste0(scr, "icon = shiny::icon(", cloth.str, "$icon),")
                                    }
                                    if (!is.null(cloth$color)){
                                      verify(cloth$color, 'character', domain = valid.colors)
                                      scr = paste0(scr, "color = ", cloth.str, "$color,")
                                    }
                                    if (!is.null(cloth$weight)){
                                      verify(cloth$weight, c('numeric', 'integer'), domain = c(1,12))
                                      scr = paste0(scr, "width = ", cloth.str, "$weight,")
                                    }
                                    if (!is.null(cloth$href)){
                                      verify(cloth$href, 'character')
                                      scr = paste0(scr, "href = ", cloth.str, "$href,")
                                    }
                                    if (!is.null(cloth$fill)){
                                      verify(cloth$fill, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "fill = ", cloth.str, "$fill,")
                                    }
                                    scr = paste0(scr, "value = ", s,")")},
                                    "valueBox"  = {scr = "valueBox("
                                    if (!is.null(cloth$title)){
                                      verify(cloth$subtitle, 'character')
                                      scr = paste0(scr, "subtitle = ", cloth.str, "$title,")
                                    } else {scr = paste0(scr, "subtitle = '',")}
                                    if (!is.null(cloth$icon)){
                                      verify(cloth$icon, 'character')
                                      scr   = paste0(scr, "icon = shiny::icon(", cloth.str, "$icon),")
                                    }
                                    if (!is.null(cloth$color)){
                                      verify(cloth$color, 'character', domain = valid.colors)
                                      scr = paste0(scr, "color = ", cloth.str, "$color,")
                                    }
                                    if (!is.null(cloth$weight)){
                                      verify(cloth$weight, c('numeric', 'integer'), domain = c(1,12))
                                      scr = paste0(scr, "width = ", cloth.str, "$weight,")
                                    }
                                    if (!is.null(cloth$href)){
                                      verify(cloth$href, 'character')
                                      scr = paste0(scr, "href = ", cloth.str, "$href,")
                                    }
                                    scr = paste0(scr, "value = ", s,")")},
                                    "column"    = {
                                      scr = paste0("column(", list2Script(cloth, fields = c('offset', 'align')),", ")
                                      if (!is.null(cloth$weight)){
                                        verify(cloth$weight, c('numeric', 'integer'), domain = c(1,12))
                                        scr = paste0(scr, "width = ", cloth.str, "$weight,")
                                      }
                                      scr = paste0(s, ")")
                                    },
                                    "wellPanel" = {scr = paste0("wellPanel(", s, ")")}
                             )
                             return(scr)
                           },
                           
                           # only row layout is supported for the sidebar
                           # lst.side is a vector of numerics
                           # lst.main is a vector of numerics
                           layscript.sidebar = function(s = '', lst.side, lst.main){
                             s = s %+% "sidebarLayout("
                             
                             N.side = length(lst.side)
                             N.main = length(lst.main)
                             
                             if (N.side > 0){
                               s = s %+% "sidebarPanel("
                               s = insert.io.strs(s, lst.side)
                               s = s %+% "),"
                             }
                             
                             if (N.main > 0){
                               s = s %+% "mainPanel("
                               s = insert.io.strs(s, lst.main)
                               s = s %+% ")"
                             }
                             s = s %+% ")"
                             return (s)
                           },
                           
                           layscript.dashboard = function(s = '', lst.head, lst.side, lst.body, header.title = NULL, header.titleWidth = NULL){
                             N.head = length(lst.head)
                             N.side = length(lst.side)
                             N.body = length(lst.body)
                             
                             s = s %+% "dashboardHeader("
                             if (!is.null(header.title)){
                               s = paste0(s, "title = '", header.title, "'")
                               if (N.head > 0 | !is.null(header.titleWidth)){s = s %+% ', '}
                             }
                             
                             if (!is.null(header.titleWidth)){
                               s = paste0(s, "titleWidth = ", header.titleWidth)
                               if (N.head > 0){s = s %+% ', '}
                             }
                             
                             if (N.head > 0){s = insert.io.strs(s, lst.head)} else if (is.null(header.title) & is.null(header.titleWidth)){s = s %+% "disable = TRUE"}
                             s = s %+% "),"
                             
                             s = s %+% "dashboardSidebar("
                             if (N.side > 0){s = insert.io.strs(s, lst.side)} else {s = s %+% "disable = TRUE"}
                             s = s %+% "),"
                             
                             s = s %+% "dashboardBody("
                             s = insert.io.strs(s, lst.body)
                             s = s %+% ")"
                             return (s)
                           },
                           
                           layscript = function(layout){
                             # todo: verify layout is a list of characters
                             N.item = length(layout)
                             s = ''
                             for (i in sequence(N.item)){
                               s = s %+% "get.item.object('" %+% layout[[i]] %+% "'"
                               if (i < N.item){s = s %+% ','}
                             }
                             return(s)
                           },
                           
                           layscript.RCPanel = function(s = "", lst, title = '', is.row = T, col.panel = F){
                             N.items = nListOrCharItems(lst)
                             for (i in sequence(length(lst))){
                               its.list = inherits(lst[[i]], 'list')
                               its.char = inherits(lst[[i]], 'character')
                               if (its.list | its.char){
                                 if (is.row){s = paste0(s, "fluidRow(")} else {
                                   if (its.list){
                                     if (is.null(lst[[i]]$weight)){
                                       ww = floor(12/N.items)
                                     } else {ww = lst[[i]]$weight}
                                     if (is.null(lst[[i]]$offset)){
                                       ofst = 0
                                     } else {ofst = lst[[i]]$offset}
                                   } else if (its.char) {
                                     if (is.null(items[[lst[[i]]]]$weight)){
                                       ww = floor(12/N.items)
                                     } else {
                                       ww = items[[lst[[i]]]]$weight
                                     }
                                     if (is.null(items[[lst[[i]]]]$offset)){
                                       ofst = 0
                                     } else {
                                       ofst = items[[lst[[i]]]]$offset
                                     }
                                   }
                                   
                                   s = paste0(s, "column(offset = ",as.character(ofst), ", ")
                                   s = paste0(s, "width  = ",as.character(ww), ", ")
                                   if (col.panel){s = paste0(s, 'wellPanel(')}
                                 }
                                 
                                 if (its.list){s = layscript.RCPanel(s, lst[[i]], is.row = !is.row, col.panel = col.panel)}
                                 else if (its.char) {s = insert.io.strs(s, lst[[i]])}
                                 s = paste0(s, ')')
                                 if (col.panel & !is.row){s = paste0(s, ')')}
                                 if (i < N.items){s = paste0(s, ',')}
                               }
                             }
                             return (s)
                           },
                           
                           insert.io.strs = function(s, vct){
                             # vct must be a vector of numerics or characters
                             M = length(vct)
                             for (j in sequence(M)){
                               s = s %+% io.clothed.str(vct[j], cloth = items[[vct[j]]]$cloth)
                               if (j < M){s = s %+% ','}
                             }
                             return(s)
                           },
                           
                           get.item.object = function(i){
                             if (is.null(items[[i]]$object)){
                               if (is.null(items[[i]]$type)){return(NULL)}
                               switch(items[[i]]$type,
                                      "radioButtons" = {
                                        chcs = verify(items[[i]]$choices,  c('character', 'factor', 'logical', 'integer'), varname = "items[['" %+% i %+% "']]$choices")
                                        sltd = verify(items[[i]]$selected, c('character', 'factor', 'logical', 'integer'), varname = "items[['" %+% i %+% "']]$selected")
                                        inl  = verify(items[[i]]$inline, 'logical', varname = "items[['" %+% i %+% "']]$inline", default = F)
                                        assert(length(chcs) > 1, "radioButtons input must have at least two choices!")
                                        if (is.null(names(chcs))){names(chcs) = chcs}
                                        obj = radioButtons(i, label = items[[i]]$title, choices = chcs, selected = sltd, inline = inl, width = items[[i]]$width)},
                                      
                                      "textInput" = {
                                        obj = textInput(i, 
                                                        label = items[[i]]$title %>% verify('character', default = "", varname = "items[['" %+% i %+% "']]$title"),
                                                        value = items[[i]]$value %>% verify('character', default = "", varname = "items[['" %+% i %+% "']]$value"),
                                                        width = items[[i]]$width %>% verify('character', varname = "items[['" %+% i %+% "']]$width"),
                                                        placeholder = items[[i]]$placeholder %>% verify('character', varname = "items[['" %+% i %+% "']]$placeholder"))},
                                      
                                      "sliderInput" = {
                                        xl   = verify(items[[i]]$min    , allowed = c("integer", "numeric"), default = 0)
                                        xh   = verify(items[[i]]$max    , allowed = c("integer", "numeric"), default = 1)
                                        x    = verify(items[[i]]$value  , allowed = c("integer", "numeric"), domain = c(xl, xh), default = 0.5*(xl+xh))
                                        an   = verify(items[[i]]$animate, allowed = c("list", "logical"), default = F)
                                        
                                        obj = sliderInput(i, label = items[[i]]$title,
                                                          min = xl, max = xh, value = x, step = items[[i]]$step,
                                                          sep  = items[[i]]$sep, pre = items[[i]]$pre, post = items[[i]]$post,
                                                          animate = an)},
                                      
                                      "actionButton"   = {obj = actionButton(i, label = items[[i]]$title, width = items[[i]]$width, icon = items[[i]]$icon)},
                                      "checkboxInput"  = {
                                        vlu = verify(items[[i]]$value, 'logical', varname = "items[['" %+% i %+% "']]$value", default = F)
                                        obj = checkboxInput(i, label = items[[i]]$title, value = vlu, width = items[[i]]$width)},
                                      "checkboxGroupInput" = {
                                        inl  = verify(items[[i]]$inline, 'logical', varname = "items[['" %+% i %+% "']]$inline", default = F)
                                        obj  = checkboxGroupInput(i, label = items[[i]]$title, choices = items[[i]]$choices, selected = items[[i]]$selected, inline = inl)},
                                      "selectInput"    = {
                                        mltpl = verify(items[[i]]$multiple, 'logical', varname = "items[['" %+% i %+% "']]$multiple", default = F)
                                        slctz = verify(items[[i]]$selectize, 'logical', varname = "items[['" %+% i %+% "']]$selectize", default = T)
                                        obj   = selectInput(i, label = items[[i]]$title, choices = items[[i]]$choices,
                                                            selected = items[[i]]$selected, multiple = mltpl, selectize = slctz)},
                                      "dateInput"      = {obj = dateInput(i, label = items[[i]]$title, value = items[[i]]$value, min = items[[i]]$min, max = items[[i]]$max)},
                                      "dateRangeInput" = {obj = dateRangeInput(i, label = items[[i]]$title, min = items[[i]]$min, max = items[[i]]$max)},
                                      "fileInput"      = {obj = fileInput(i, label = items[[i]]$title)},
                                      "numericInput"   = {
                                        if (is.null(items[[i]]$step)){items[[i]]$step <<- NA}
                                        if (is.null(items[[i]]$max)){items[[i]]$max <<- NA}
                                        if (is.null(items[[i]]$min)){items[[i]]$min <<- NA}
                                        obj = numericInput(i, label = items[[i]]$title, value = items[[i]]$value,
                                                           step = items[[i]]$step, min = items[[i]]$min, max = items[[i]]$max)},
                                      
                                      "column" = {
                                        scr = "column("
                                        wdth = verify(items[[i]]$weight, 'numeric' , default = 12)
                                        ofst = verify(items[[i]]$offset, 'numeric', default = 0)
                                        scr = paste0(scr,'width = ', wdth, ', offset = ',ofst, ',')
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %+% ")"
                                        obj = eval(parse(text = scr))},
                                      
                                      "wellPanel" = {
                                        scr = "wellPanel("
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %+% ")"
                                        obj = eval(parse(text = scr))},
                                      
                                      "box" = {
                                        scr = "box("
                                        wdth = verify(items[[i]]$weight, 'numeric' , default = 12, varname    = paste0("items[['",i,"']]$weight"))
                                        ttle = verify(items[[i]]$title, 'character' , default = '', varname  = paste0("items[['",i,"']]$title"))
                                        fotr = verify(items[[i]]$footer, 'character' , default = '', varname = paste0("items[['",i,"']]$footer"))
                                        stus = verify(items[[i]]$status, 'character' , domain = valid.box.statuses, varname = paste0("items[['",i,"']]$status"))
                                        shdr = verify(items[[i]]$solidHeader, 'logical' , default = 'F', domain = c(T, F), varname = paste0("items[['",i,"']]$solidHeader"))
                                        bgrd = verify(items[[i]]$background, 'character' , domain = valid.colors, varname = paste0("items[['",i,"']]$background"))
                                        cpbl = verify(items[[i]]$collapsible, 'logical' , default = 'F', domain = c(T, F), varname = paste0("items[['",i,"']]$collapsible"))
                                        cpsd = verify(items[[i]]$collapsed, 'logical' , default = 'F', domain = c(T, F), varname = paste0("items[['",i,"']]$collapsed"))
                                        
                                        if(!is.null(stus)){scr = paste0(scr,"status = '", stus, "',")}
                                        scr = paste0(scr,'width = ', wdth, ',')
                                        scr = paste0(scr,"title = '", ttle, "',")
                                        scr = paste0(scr,'footer = ', fotr, ',')
                                        scr = paste0(scr,'background = ', bgrd, ',')
                                        if (shdr){scr = paste0(scr,'solidHeader = T,')}
                                        if (cpbl){scr = paste0(scr,'collapsible = T,')}
                                        if (cpsd){scr = paste0(scr,'collapsed = T,')}
                                        
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %+% ")"
                                        obj = eval(parse(text = scr))},
                                      
                                      "fluidPage" = {
                                        scr = "fluidPage("
                                        if (!is.null(items[[i]]$title)){scr = paste0(scr, "titlePanel('", items[[i]]$title, "', windowTitle = '", items[[i]]$wintitle, "'),")}
                                        cpl = verify(items[[i]]$col.framed, 'logical', varname = paste0("items[['",i,"']]$col.framed"), domain = c(T,F), default = F)
                                        scr = layscript.RCPanel(s = scr, lst = items[[i]]$layout, col.panel = cpl)
                                        scr = scr %+% ')'
                                        obj = eval(parse(text = scr))},
                                      
                                      "dashboardPage" = {
                                        scr = "dashboardPage("
                                        ttl = verify(items[[i]]$title,  'character', varname = paste0("items[['",i,"']]$title"))
                                        clr = verify(items[[i]]$color, 'character', varname = paste0("items[['",i,"']]$color"), domain = valid.dashboard.skins)
                                        if (!is.null(ttl)){scr = scr %+% "title = '" %+% ttl %+% "', "}
                                        if (!is.null(clr)){scr = scr %+% "skin  = '" %+% clr %+% "', "}
                                        scr = layscript.dashboard(s = scr, lst.head = items[[i]]$layout.head, lst.side = items[[i]]$layout.side, lst.body = items[[i]]$layout.body, header.title = items[[i]]$header.title, header.titleWidth = items[[i]]$header.titleWidth)
                                        scr = scr %+% ')'
                                        obj = eval(parse(text = scr))},
                                      
                                      "sidebarLayout" = {
                                        scr = "fluidPage("
                                        if (!is.null(items[[i]]$title)){scr = paste0(scr, "titlePanel('", items[[i]]$title, "', windowTitle = '", items[[i]]$wintitle, "'),")}
                                        scr = layscript.sidebar(s = scr, lst.side = items[[i]]$layout.side, lst.main = items[[i]]$layout.main)
                                        scr = scr %+% ')'
                                        obj = eval(parse(text = scr))},
                                      
                                      "navbarPage" = {  # todo: write specific layscript for this type of container so that it creates tabPanels and menus based on a layout of type list
                                        scr = "navbarPage("
                                        if (is.null(items[[i]]$title)){items[[i]]$title <<- ''}
                                        scr = scr %+% "title = '" %+% verify(items[[i]]$title, 'character')  %+% "', "
                                        if (!is.null(items[[i]]$position)){scr = scr %+% "position = '" %+% verify(items[[i]]$position, 'character', domain = valid.navbar.positions)  %+% "', "}
                                        if (!is.null(items[[i]]$header)){scr = scr %+% "header = '" %+% verify(items[[i]]$header, 'character')  %+% "', "}
                                        if (!is.null(items[[i]]$footer)){scr = scr %+% "footer = '" %+% verify(items[[i]]$footer, 'character')  %+% "', "}
                                        if (!is.null(items[[i]]$wintitle)){scr = scr %+% "windowTitle = '" %+% verify(items[[i]]$wintitle, 'character')  %+% "', "}
                                        if (!is.null(items[[i]]$icon)){scr = scr %+% "icon = icon('" %+% verify(items[[i]]$icon, 'character')  %+% ")', "}
                                        if (!is.null(i)){scr = scr %+% "id = '" %+% verify(i, 'character')  %+% "', "}
                                        clp = verify(items[[i]]$collapsible, 'logical', domain = c(T,F), default = F)
                                        fld = verify(items[[i]]$fluid, 'logical', domain = c(T,F), default = T)
                                        if (clp) {scr = scr %+% "collapsible = TRUE, "}
                                        if (!fld){scr = scr %+% "fluid = FASLE, "}
                                        if (!is.null(items[[i]]$theme)){scr = scr %+% "theme = '" %+% verify(items[[i]]$theme, 'character')  %+% "', "}
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %+% ")"
                                        obj = eval(parse(text = scr))},
                                      
                                      "navbarMenu" = {
                                        scr = "navbarMenu("
                                        if (is.null(items[[i]]$title)){items[[i]]$title <<- ''}
                                        scr = scr %+% "title = '" %+% verify(items[[i]]$title, 'character')  %+% "', "
                                        if (!is.null(items[[i]]$icon)){scr = scr %+% "icon = icon('" %+% verify(items[[i]]$icon, 'character')  %+% ")', "}
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %+% ")"
                                        obj = eval(parse(text = scr))},
                                      
                                      "tabsetPanel" = {
                                        scr = "tabsetPanel("
                                        if (!is.null(items[[i]]$selected)){scr %<>% paste0("selected = '", items[[i]]$selected %>% verify('character', varname = 'selected'), "', ")}
                                        if (!is.null(items[[i]]$shape)){scr %<>% paste0("type = '", items[[i]]$shape %>% verify('character', domain = c("tabs", "pills"), varname = 'shape'), "', ")}
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %+% ")"
                                        obj = eval(parse(text = scr))},
                                      
                                      "tabPanel" = {
                                        scr = "tabPanel("
                                        scr = scr %+% "id = '" %+% i %+% "', "
                                        if (is.null(items[[i]]$title)){items[[i]]$title <<- i}
                                        scr = scr %+% "title = '" %+% verify(items[[i]]$title, 'character')  %+% "', "
                                        if (!is.null(items[[i]]$icon)){scr = scr %+% "icon = icon('" %+% verify(items[[i]]$icon, 'character')  %+% ")', "}
                                        cpl = verify(items[[i]]$col.framed, 'logical', varname = paste0("items[['",i,"']]$col.framed"), domain = c(T,F), default = F)
                                        if      (inherits(items[[i]]$layout, 'list')){scr = layscript.RCPanel(s = scr, lst = items[[i]]$layout, col.panel = cpl)} 
                                        else if (inherits(items[[i]]$layout, 'character')){scr = insert.io.strs(scr, items[[i]]$layout)} else {stop("Invalid type for argument 'layout'!")}
                                        
                                        scr = scr %+% ")"
                                        obj = eval(parse(text = scr))}
                                      
                               )
                               return(obj)
                             } else {return(items[[i]]$object)}
                           },
                           
                           dashboard.ui = function(){
                             
                             for (i in names(items)){
                               # Outputs:
                               if (items[[i]]$type %in% valid.output.types){
                                 if (!is.null(items[[i]]$type)){
                                   fields = names(items[[i]])
                                   vn.w = "items[['" %+% i %+% "']]$width"
                                   vn.h = "items[['" %+% i %+% "']]$height"
                                   if ('width'  %in% fields) {wdth  = items[[i]]$width} else {wdth = "100%"}
                                   if ('height' %in% fields){hght  = items[[i]]$height} else {hght = "400px"}
                                   switch(items[[i]]$type,
                                          "dynamicInput" = {
                                            items[[i]]$object <<- uiOutput(i, 
                                                                           inline = items[[i]]$inline %>% verify('logical' , domain = c(T,F), default = F , varname = "items[['" %+% i %+% "']]$inline"))
                                          },
                                          "uiOutput" = {
                                            items[[i]]$object <<- uiOutput(i)
                                            if (!is.null(items[[i]]$cloth)  &  !is.null(items[[i]]$title)){items[[i]]$cloth$title <<- items[[i]]$title}
                                          },
                                          "plotOutput" = {
                                            if ('brush' %in% fields) {brsh  = brushOpts(id = items[[i]]$brush)} else {brsh = NULL}
                                            items[[i]]$object <<- plotOutput(i, 
                                                                             width  = items[[i]]$width  %>% verify('character', lengths = 1, default = "auto", varname = vn.w), 
                                                                             height = items[[i]]$height %>% verify('character', lengths = 1, default = "400px", varname = vn.h),
                                                                             click  = items[[i]]$click,
                                                                             brush  = items[[i]]$brush)},
                                          "verbatimTextOutput" = {items[[i]]$object <<- verbatimTextOutput(i)},
                                          "textOutput"         = {items[[i]]$object <<- textOutput(i)},
                                          "tableOutput"        = {items[[i]]$object <<- tableOutput(i)},
                                          "dataTableOutput"    = {items[[i]]$object <<- DT::dataTableOutput(i)},
                                          "D3TableFilterOutput"= {items[[i]]$object <<- D3TableFilter::d3tfOutput(i,
                                                                                                                  width  = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%", varname = vn.w), 
                                                                                                                  height = items[[i]]$height %>% verify('character', lengths = 1, default = "400px", varname = vn.h))},
                                          "htmlOutput"         = {items[[i]]$object <<- htmlOutput(i)},
                                          "amChartsOutput"     = {items[[i]]$object <<- amChartsOutput(i)},
                                          "dygraphOutput"      = {items[[i]]$object <<- dygraphs::dygraphOutput(i)},
                                          "gglVisChartOutput"  = {items[[i]]$object <<- htmlOutput(i)},
                                          "leafletOutput"      = {items[[i]]$object <<- leafletOutput(i)},
                                          "wordcloud2Output"   = {items[[i]]$object <<- wordcloud2Output(i, 
                                                                                                         width  = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%", varname = vn.w), 
                                                                                                         height = items[[i]]$height %>% verify('character', lengths = 1, default = "400px", varname = vn.h))},
                                          "infoBoxOutput"      = {items[[i]]$object <<- infoBoxOutput(i,  width = items[[i]]$width)},
                                          "valueBoxOutput"     = {items[[i]]$object <<- valueBoxOutput(i, width = items[[i]]$width)},
                                          "plotlyOutput"       = {items[[i]]$object <<- plotlyOutput(i, 
                                                                                                     width  = items[[i]]$width %>%  verify('character', default = '100%' , varname = vn.w), 
                                                                                                     height = items[[i]]$height %>% verify('character', default = '400px', varname = vn.h))},
                                          "highcharterOutput"  = {items[[i]]$object <<- highchartOutput(i, 
                                                                                                        width  = items[[i]]$width %>%  verify('character', default = '100%' , varname = vn.w), 
                                                                                                        height = items[[i]]$height %>% verify('character', default = '400px', varname = vn.h))},
                                          "bubblesOutput"      = {items[[i]]$object <<- bubblesOutput(i, 
                                                                                                      width  = items[[i]]$width %>% verify('character', lengths = 1, default = '600px'),
                                                                                                      height = items[[i]]$height %>% verify('character', lengths = 1, default = '600px'))},
                                          "d3plusOutput" = {items[[i]]$object <<- d3plusOutput(i, 
                                                                                               width  = items[[i]]$width %>% verify('character', lengths = 1, default = '100%'),
                                                                                               height = items[[i]]$height %>% verify('character', lengths = 1, default = '500px'))},
                                          "rChartsdPlotOutput" = {items[[i]]$object <<- showOutput(i, "dimple")})
                                 }
                               }
                             }
                             
                             for (i in names(items)){
                               # Inputs & Containers
                               if (items[[i]]$type %in% c(valid.input.types, valid.container.types)){
                                 items[[i]]$object <<- get.item.object(i)
                               }
                             }
                             
                             scr.text = layscript(layout = king.layout) %+% ")"
                             
                             ui.obj <- eval(parse(text = scr.text))
                             return(ui.obj)
                           },
                           
                           dashboard.server = function(){
                             srv_func = function(input, output, session) {
                               # a list of objects which are synced with dashboard inputs and
                               # provide service for dashboard outputs
                               sync = reactiveValues()
                               report = reactiveValues()
                               itns = names(items) 
                               for (i in itns){
                                 if(inherits(items[[i]]$sync, c('logical', 'numeric', 'integer')) & !is.empty(items[[i]]$sync)){
                                   if(items[[i]]$sync){
                                     switch(items[[i]]$type, 
                                            "D3TableFilterOutput"  = 
                                            {   cfg_i = items[[i]]$config %>% D3TableFilter.config.verify
                                            tbl_i = items[[i]]$data %>% verify('data.frame', null_allowed = F, err_msg = "todo: Write something!")
                                            # reporting and commanding values both client to server and server to client:
                                            sync[[i]]   <- tbl_i
                                            report[[i]] <- tbl_i
                                            if(!is.null(cfg_i$column.footer)){
                                              sync[[i %+% '_column.footer']] = cfg_i$column.footer
                                              observers <<- c(observers, D3TableFilter.observer.column.footer.R(i))
                                            }
                                            if(!is.null(cfg_i$column.editable)){
                                              sync[[i %+% '_column.editable']] = cfg_i$column.editable
                                              report[[i %+% '_lastEdits']] = D3TableFilter.lastEdits.empty
                                              observers <<- c(observers, D3TableFilter.observer.edit.R(i), D3TableFilter.observer.column.editable.R(i))
                                            }  
                                            if(!is.null(cfg_i$selection.mode)){
                                              sync[[i %+% '_selected']]  = cfg_i$selected
                                              report[[i %+% '_selected']]  = cfg_i$selected
                                              observers <<- c(observers, D3TableFilter.observer.selected.C2S.R(i), D3TableFilter.observer.selected.S2C.R(i))
                                            }
                                            if (cfg_i$column.filter.enabled){
                                              sync[[i %+% '_column.filter']] = cfg_i$column.filter
                                              report[[i %+% '_filtered']]  = tbl_i %>% D3TableFilter.filteredRows(cfg_i)
                                              observers <<- c(observers, D3TableFilter.observer.filter.C2S.R(i), D3TableFilter.observer.filter.S2C.R(i))
                                            }
                                            sync[[i %+% '_row.color']] = cfg_i$row.color
                                            observers <<- c(observers, D3TableFilter.observer.color.S2C.R(i))
                                            observers <<- c(observers, D3TableFilter.observer.table.S2C.R(i))
                                            items[[i]]$service <<- D3TableFilter.service(i)
                                            }
                                     )
                                   }
                                 }
                               }
                               
                               if(!is.null(prerun)){eval(parse(text = prerun))}
                               
                               for (i in names(items)){
                                 if (items[[i]]$type %in% valid.output.types){
                                   if (items[[i]]$type != 'static'){
                                     arguments = ''
                                     switch(items[[i]]$type,
                                            "dynamicInput"       = {script.func = 'renderUI'},
                                            "uiOutput"           = {script.func = 'renderText'},
                                            "plotOutput"         = {script.func = 'renderPlot'},
                                            "verbatimTextOutput" = {script.func = 'renderPrint'},
                                            "textOutput"         = {script.func = 'renderText'},
                                            "tableOutput"        = {
                                              script.func = 'renderTable';
                                              arguments   = list2Script(items[[i]], fields = c('striped', 'hover', 'bordered', 'spacing', 'width', 'align', 'rownames', 'colnames', 'digits', 'na'))
                                            },
                                            "dataTableOutput"    = {script.func = 'DT::renderDataTable'},
                                            "D3TableFilterOutput"= {script.func = 'D3TableFilter::renderD3tf'},
                                            "htmlOutput"         = {script.func = 'renderUI'},
                                            "dygraphOutput"      = {script.func = 'dygraphs::renderDygraph'},
                                            "gglVisChartOutput"  = {script.func = 'renderGvis'},
                                            "leafletOutput"      = {script.func = 'renderLeaflet'},
                                            "wordcloud2Output"   = {script.func = 'renderWordcloud2'},
                                            "infoBoxOutput"      = {script.func = 'renderInfoBox'},
                                            "valueBoxOutput"     = {script.func = 'renderValueBox'},
                                            "amChartsOutput"     = {script.func = 'renderAmCharts'},
                                            "plotlyOutput"       = {script.func = 'plotly::renderPlotly'},
                                            "highcharterOutput"  = {script.func = 'highcharter::renderHighchart'},
                                            "bubblesOutput"      = {script.func = 'bubbles::renderBubbles'},
                                            "d3plusOutput"       = {script.func = 'd3plus::renderD3plus'},
                                            "rChartsdPlotOutput" = {script.func = 'renderChart2'}
                                     )
                                     script = paste0('output$', i, ' <- ', script.func, '({', items[[i]]$service, '}', chif(arguments == '', '', ','), arguments, ')')
                                     eval(parse(text = script))
                                   }
                                 }
                               }
                               
                               # observeEvents  (input service functions)
                               for (i in names(items)){
                                 if (items[[i]]$type %in% valid.input.types){
                                   if (!is.null(items[[i]]$service)){
                                     if(items[[i]]$isolate %>% verify('logical', domain = c(T,F), default = F, varname = 'isolate')){
                                       isop = 'isolate({'
                                       isoc = '})'
                                     } else {
                                       isop = ''
                                       isoc = ''
                                     }
                                     script = paste0('observeEvent(input$', i, ',{', isop, items[[i]]$service, isoc, '})')
                                     eval(parse(text = script))
                                   }
                                 }
                               }
                               
                               # observers
                               # for (obs in observers){eval(parse(text = "observe({" %+% pre.run %+% '\n' %+% obs %+% "})"))}
                               for (obs in observers){eval(parse(text = "observe({" %+% obs %+% "})"))}
                             }
                             return(srv_func)
                           }
                         )
)

# Any time you change the value of a reactive variable, within an observer code, 
# you should put that code in isolate({}), because the observer will be called again!


###### Package dc ==================================
### test.R ------------------------
library(dcr)
library(magrittr)
library(niragen)



dfx = data.frame(Name     = c('Mr A', 'Mr B', 'Mr C', 'Mr A', 'Mr B', 'Mr B', 'Mr C'),
                 Spent    = c(40 , 10 , 40 , 70 , 20 , 50 , 30),
                 SpentCat = c('Forty' , 'Ten' , 'Forty' , 'Seventy' , 'Twenty' , 'Fifty' , 'thirdy'),
                 Year     = c('2000-11'  , '2000-11'  , '2000-11'  , '2000-12'  , '2000-12'  , '2000-13'  , '2000-13'))


dfx %>% dc.bar(x = 'Year')
dfx %>% dcr::dcr(type = 'pie', label = 'SpentCat', theta = 'Spent', config = list(pie.innerRadius = 50))
dfx %>% dcr::dcr(type = 'bar', y = 'SpentCat')

I = list()

####################
M = read.csv('data/morley.csv')
M %>% dcr::dcr(type = 'box', x = 'Expt', y = 'Speed')
M %>% dcr::dcr(type = 'scatterLine', x = 'Run', y = 'Speed', group = 'Expt', config = list(barMode = 'stack', xnum = F, xAxis.min = 0, xAxis.max = 20))
M %>% dc.scatter(x = 'Run', y = 'Speed', group = 'Expt', shape = 'line', config = list(legend.enabled = T))
M %>% dc.scatter(type = 'scatter', x = 'Run', y = 'Speed', group = 'Expt')

####################
cat = read.csv('data/cat.csv')
cat %>% dcr::dcr(type = 'sunburst')

####################

ndx = read.csv('C:/Nima/RCode/projects/tutorials/data/ndx.csv')
ndx %<>% dplyr::mutate(Year = date %>% as.character %>% as.Date(format = '%m/%d/%Y') %>% format('%Y')) %>% 
  dplyr::mutate(Month = date %>% strptime(format = "%m/%d/%Y") %>% as.Date %>% cut(breaks = 'month') %>% as.Date) %>% 
  dplyr::mutate(absGain = close - open) %>% dplyr::mutate(fluctuation = abs(absGain), sindex = 0.5*(open + close)) %>% 
  dplyr::mutate(percentageGain = (absGain / sindex) * 100)  

ndx %>% dcr::dcr(type = 'bubble', key = 'Year', label = 'Year', x = 'absGain', y = 'percentageGain', size = 'fluctuation', config = list(size.min = 0, size.max = 100000, xAxis.padding = 500, yAxis.padding = 10, tooltip = c(Index = 'percentageGain', Fluctuation = 'fluctuation')))

ndx %>% dcr::dcr(type = 'area', x = 'Month')


ndx %>% dcr::dcr(type = 'sample', key = 'Year')

###### Package DiagrammeR ==================================
### getLayoutCoordinates.R ------------------------
library(visNetwork)
library(DiagrammeR)
library(DiagrammeRsvg)
library(xml2)
library(htmltools)
library(magrittr)

nodes <-
  create_node_df(n = 6,
                 nodes = c("a", "b", "c", "d", "e", "f"),
                 label = TRUE,
                 fillcolor = c("lightgrey", "red", "orange", "pink",
                               "cyan", "yellow"),
                 shape = "circle",
                 value = c(2, 1, 0.5, 1, 1.8, 1),
                 type = c("1", "1", "1", "2", "2", "2"),
                 x = c(1, 2, 3, 4, 5, 6),
                 y = c(-2, -1, 0, 6, 4, 1))

# Create an edge data frame
edges <-
  create_edge_df(from = c(1, 2, 3, 4, 6, 5),
                 to = c(4, 3, 1, 3, 1, 4),
                 color = c("green", "green", "grey", "grey",
                           "blue", "blue"),
                 rel = "leading_to")

# Create a graph object
graph <- create_graph(nodes_df = nodes,
                      edges_df = edges,
                      # change layout here
) %>%
  add_global_graph_attrs(attr = "rankdir", value = "TB",attr_type = "graph") %>%
  add_global_graph_attrs(attr = "layout", value = "dot", attr_type = "graph")



# Render the graph using Graphviz
svg <- export_svg(render_graph(graph))
# look at it to give us a visual check
browsable(HTML(svg))
# use html to bypass namespace problems
svgh <- read_html(paste0(strsplit(svg,"\\n")[[1]][-(1:6)],collapse="\\n"))

# Get positions
node_xy <- xml_find_all(svgh,"//g[contains(@class,'node')]") %>%
{
  data.frame(
    id = xml_text(xml_find_all(.,".//title")),
    x = xml_attr(xml_find_all(.,".//*[2]"), "cx"),
    y = xml_attr(xml_find_all(.,".//*[2]"), "cy"),
    stringsAsFactors = FALSE
  )
}

#  assuming same order
#   easy enough to do join with dplyr, etc.
graph$nodes_df$x <- as.numeric(node_xy$x)[order(node_xy$id)]
graph$nodes_df$y <- -as.numeric(node_xy$y)[order(node_xy$id)]

render_graph(graph, "visNetwork") %>%
  visInteraction(dragNodes = TRUE)

###### Package DT ==================================
### extensions.R ------------------------
# DT Extensions does not work at the moment
library(DT)
datatable(
  iris, rownames = FALSE,
  extensions = 'Buttons', options = list(
    dom = 'Bfrtip',
    buttons = list(list(extend = 'colvis', columns = c(2, 3, 4)))
  )
)


# Translation:

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')

source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/DT.R')

DT.table(iris, rownames = T)


###### Package dygraph ==================================
### examples.R ------------------------
library(htmlwidgets)
library(dygraphs)
library(shiny)
library(dplyr)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/dygraphs.R')


df = data.frame(Name = LETTERS, age = sin(0.5*(11 + 1:26)), score =  3.2 + 0.1*(26:1))
dygraphs.combo(df, x = 'Name', y = list('age', 'score'), shape = list('bar', NULL)) %>% dyRangeSelector

bubbles.bubble(df, size = 'score', label = 'Name', color = 'age')

plotly.combo(df, x = 'Name', y = list('age', 'score'), shape = list('bar', 'line'))

######################################################################################
library(quantmod)
getSymbols(c("MSFT", "HPQ"), from = "2014-06-01", auto.assign=TRUE)
## [1] "MSFT" "HPQ"
stocks <- cbind(MSFT[,2:4], HPQ[,2:4])
dygraph(stocks, main = "Microsoft and HP Share Prices") %>% 
  dySeries(c("MSFT.Low", "MSFT.Close", "MSFT.High"), label = "MSFT", axis = "y2", color = 'red', plotter = plotter[['bar']]) %>%
  dySeries(c("HPQ.Low", "HPQ.Close", "HPQ.High"), label = "HPQ", color = 'green', plotter = plotter[['bar']]) %>% dyRangeSelector

# Translation:
stocks = cbind(MSFT[,2:4], HPQ[,2:4])  %>% as.data.frame
stocks %>% mutate(time = rownames(stocks)) %>%
  dygraphs.combo(x = 'time', y = list(MSFT = 'MSFT.Close', HPQ = 'HPQ.Close'), color = list('magenta', NULL), shape = list('dashDotLine','bar'), ySide = list('left', 'right'), size = 5)

stocks %>% mutate(time = rownames(stocks)) %>%
  plotly.combo(x = 'time', y = list(MSFT = 'MSFT.Close', HPQ = 'HPQ.Close'), color = list('magenta', NULL), shape = list('line','bar'))

######################################################################################



### examples_xlabel.R ------------------------
dates    = c('2012-01-01', '2012-01-02', '2012-01-03', '2012-01-04', '2012-01-05', '2012-01-06')
ts.rmean = c(3.163478, 3.095909, 3.112000, 2.922800, 2.981154, 3.089167)
ts.rmax  = c(5.86, 4.67, 6.01, 5.44, 5.21, 5.26)

data.in = data.frame(ts.rmean, ts.rmax)
rownames(data.in) = dates

library(dygraphs)
library(xts)
library(htmlwidgets)

#the axis label is passed as a date, this function outputs only the month of the date
getMonth <- 'function(d){
var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
return monthNames[d.getMonth()];
}'

#the x values are passed as milliseconds, turn them into a date and extract month and day
getMonthDay <- 'function(d) {
var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
date = new Date(d);
return monthNames[date.getMonth()] + " " +date.getUTCDate(); }'

#set the value formatter function and axis label formatter using the functions above
#they are wrapped in JS() to mark them as javascript    
dygraph(data.in, main = "Title") %>%
  #dySeries("ts.rmean", drawPoints = TRUE, color = "blue") %>%
  #dySeries("ts.rmax", stepPlot = TRUE, fillGraph = TRUE, color = "red") %>%
  #dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  
  dyAxis("x",valueFormatter=JS(getMonthDay), axisLabelFormatter=JS(getMonth))

dygraph(data.in)

### example_1.R ------------------------

library(dygraphs)
browseURL2 = function(url, height){
  browseURL(url)
}
options(viewer = browseURL2)

# file.copy(tempfile(), file.path(tempdir(), "index.html"))
# viewer <- getOption("viewer")
# viewer("http://localhost:8000")
# browseURL(path)

lungDeaths <- cbind(mdeaths, fdeaths)
d = dygraph(lungDeaths)
d
# Suitable for:
# TIME.SERIES: show history data of multiple numeric figures (Started ...)



lungDeaths <- cbind(ldeaths, mdeaths, fdeaths)
d = dygraph(lungDeaths, main = "Deaths from Lung Disease (UK)") %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = FALSE)
###### Package echarts4R ==================================
### examples.R ------------------------

###### Package fusionr ==================================

###### Package highcharter ========# find many examples here:
# http://echarts.baidu.com/echarts2/doc/example-en.html


library(echarts4r)
library(niragen)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/echarts.R')


# with negative
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_area(Murder) %>%
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% # second y axis 
  e_mark_line("Sick basterd", data = list(type = "average")) %>% 
  e_mark_point("Murder", data = list(type = "max")) %>% 
  e_tooltip(trigger = "axis")

## polar charts:
df <- data.frame(x = 1:100, y = seq(1, 200, by = 2))

df %>% 
  e_charts(x) %>% 
  e_polar(FALSE) %>% 
  e_angle_axis(T) %>% 
  e_radius_axis(T) %>% 
  e_line(y, coord.system = "polar", smooth = TRUE) %>% 
  e_legend(show = TRUE)

# todo: niravis translation:
# df %>% echarts.polar(theta = 'x', r = 'y', shape = 'line.point') 


# animation:

mtcars %>% 
  e_charts(mpg) %>% 
  e_area(drat) %>% 
  e_animation(duration = 10000)

# Histogram & density
mtcars %>% 
  e_charts() %>% 
  e_histogram(mpg, name = "histogram") %>% 
  e_density(mpg, areaStyle = list(opacity = .4), smooth = TRUE, name = "density", y.index = 1) %>% 
  e_tooltip(trigger = "axis")

funnel <- data.frame(stage = c("View", "Click", "Come and \n Purchase", "Click"), value = c(80, 30, 20, 5))

funnel %>% 
  e_charts() %>% 
  e_funnel(value, stage)


# niravis translation:
# todo: You need to aggregate later
# todo: check for custom colors

funnel %>% nameColumns(list('Stager Built' = 'stage')) %>% echarts.funnel(label = 'Stager Built', size = 'value')


# word cloud:

words <- function(n = 5000) {
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}

tf <- data.frame(terms = words(100), 
                 freq = rnorm(100, 55, 10)) %>% 
  dplyr::arrange(-freq)

tf %>% 
  e_color_range(freq, color) %>% 
  e_charts() %>% 
  e_cloud(terms, freq, color, shape = "rectangle", sizeRange = c(3, 15))

# argument shape does not work
# niravis Translation:

tf %>% echarts.wordCloud(label = 'terms', size = 'freq', color = list(color = 'freq'), config = list(colorize = T))


# Gauge:

e_charts() %>% 
  e_gauge(57, "PERCENT", rm.x = F, rm.y = T, startAngle = 110, endAngle = 1)

# properties don't work

# Look for other properties:
# https://ecomfe.github.io/echarts-doc/public/en/option.html#series-gauge


# niravis Translation:
echarts.gauge(theta = 57, label = 'PERCENT', startAngle = 110, endAngle = 1, detail = list(formatter = '{value}%'))

### bar.R -----------------------
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_bar(Murder) %>% 
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% 
  e_animation(duration = 10000) # secondary x axis


# Niravis translation:

USArrests %>% dplyr::mutate(State = row.names(.), Rape = - Rape) %>% 
  echarts.bar(x = 'State', y = list('Murder', 'Sick basterd' = 'Rape')) %>% 
  e_animation(duration = 10000)

###### Package highchartsR ==================================
### examples.R -------------------------------
source('C:/Nima/R/packages/niravis/R/tools.R')
library(highchartR)

data = mtcars
x = 'wt'
y = 'mpg'
group = 'cyl'

h = highcharts(
  data = data,
  x = x,
  y = y,
  group = group,
  type = 'scatter'
)

plot.html(h)






library(data.table)
library(pipeR)
library(rlist)
library(quantmod)
library(dplyr)

symbols <- c("MSFT","C","AAPL")

symbols %>>%
  list.map(
    get(getSymbols(.))
  ) %>>%
  list.map(
    . %>>%
      as.data.frame %>>%
      mutate(
        name = .name,
        date = rownames(.)
      ) %>>%
      select(
        name,
        date,
        price = contains("close")
      ) %>>%
      data.table
  ) %>>%
  rbindlist ->
  data

highstocks(
  data = data,
  x = 'date',
  y = 'price',
  group = 'name'
)

###### Package leaflet ==================================
### examples.R -------------------------------
# http://www.r-graph-gallery.com/portfolio/maps/


library(leaflet)
m <- leaflet()
m <- m %>% addTiles() %>%
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")


m

###

df = data.frame(Lat = 1:10, Long = rnorm(10))
leaflet(df) %>% addTiles() %>% addCircles() 

###

m = leaflet() %>% addTiles()
df = data.frame(
  lat = rnorm(100),
  lng = rnorm(100),
  size = runif(100, 5, 20),
  color = sample(colors(), 100)
)
m = leaflet(df) %>% addTiles()
m %>% addCircleMarkers(radius = ~size, color = ~color, fill = FALSE)
m %>% addCircleMarkers(radius = runif(100, 4, 10), color = c('red'))


###

library(htmltools)

df <- read.csv(textConnection(
  "Name,Lat,Long
  Samurai Noodle,47.597131,-122.327298
  Kukai Ramen,47.6154,-122.327157
  Tsukushinbo,47.59987,-122.326726"
))

leaflet(df) %>% addTiles() %>%
  addMarkers(~Long, ~Lat, popup = ~htmlEscape(Name))
### shiny_examples.R -------------------------------
library(shiny)
library(leaflet)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

ui <- fluidPage(
  leafletOutput("mymap"),
  p(),
  actionButton("recalc", "New points")
)

server <- function(input, output, session) {
  
  points <- eventReactive(input$recalc, {
    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.TonerLite",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points())
  })
}

shinyApp(ui, server)

### shiny_example_II_proxy.R -------------------------------
library(shiny)
library(leaflet)
library(RColorBrewer)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
                            value = range(quakes$mag), step = 0.1
                ),
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                ),
                checkboxInput("legend", "Show legend", TRUE)
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2],]
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(input$colors, quakes$mag)
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(quakes) %>% addTiles() %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(radius = ~10^mag/10, weight = 1, color = "#777777",
                 fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag)
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = quakes)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~mag
      )
    }
  })
}

shinyApp(ui, server)

###### Package manipulateWidget ==================================
### examples.R -------------------------------

library(manipulateWidget)
library(plotly)

# Example 1: Single Charts dashboard:
data(iris)

plotClusters <- function(xvar, yvar, nclusters) {
  clusters <- kmeans(iris[, 1:4], centers = nclusters)
  clusters <- paste("Cluster", clusters$cluster)
  
  plot_ly(x = ~iris[[xvar]], y = ~iris[[yvar]], color = ~clusters,
          type = "scatter", mode = "markers") %>%
    layout(xaxis = list(title=xvar), yaxis = list(title=yvar))
}

plotClusters("Sepal.Width", "Sepal.Length", 3)


varNames <- names(iris)[1:4]

manipulateWidget(
  plotClusters(xvar, yvar, nclusters),
  xvar = mwSelect(varNames),
  yvar = mwSelect(varNames, value = "Sepal.Width"),
  nclusters = mwSlider(1, 10, value = 3)
)


# Example 2: Multiple Charts dashboard:


myPlotFun <- function(distribution, range, title) {
  randomFun <- switch(distribution, gaussian = rnorm, uniform = runif)
  myData <- data.frame(
    year = seq(range[1], range[2]),
    value = randomFun(n = diff(range) + 1)
  )
  combineWidgets(
    ncol = 2, colsize = c(2, 1),
    dygraph(myData, main = title),
    combineWidgets(
      plot_ly(x = myData$value, type = "histogram"),
      paste(
        "The graph on the left represents a random time series generated using a <b>",
        distribution, "</b>distribution function.<br/>",
        "The chart above represents the empirical distribution of the generated values."
      )
    )
  )
  
}

manipulateWidget(
  myPlotFun(distribution, range, title),
  distribution = mwSelect(choices = c("gaussian", "uniform")),
  range = mwSlider(2000, 2100, value = c(2000, 2100), label = "period"),
  title = mwText()
)


# Example 3: Use as a module in shiny:

if (interactive() & require("dygraphs")) {
  require("shiny")
  ui <- fillPage(
    fillRow(
      flex = c(NA, 1),
      div(
        textInput("title", label = "Title", value = "glop"),
        selectInput("series", "series", choices = c("series1", "series2", "series3"))
      ),
      mwModuleUI("ui", height = "100%")
    ))
  
  server <- function(input, output, session) {
    mydata <- data.frame(
      year = 2000+1:100,
      series1 = rnorm(100),
      series2 = rnorm(100),
      series3 = rnorm(100)
    )
    
    c <- manipulateWidget(
      {
        dygraph(mydata[range[1]:range[2] - 2000, c("year", series)], main = title)
      },
      range = mwSlider(2001, 2100, c(2001, 2050)),
      series = mwSharedValue(),
      title = mwSharedValue(), .runApp = FALSE,
      .compare = "range"
    )
    #
    mwModule("ui", c, title = reactive(input$title), series = reactive(input$series))
  }
  
  shinyApp(ui, server)
  
  
}



# Example 4: shared value:

if (require(plotly)) {
  # Plot the characteristics of a car and compare with the average values for
  # cars with same number of cylinders.
  # The shared variable 'subsetCars' is used to avoid subsetting multiple times
  # the data: this value is updated only when input 'cylinders' changes.
  colMax <- apply(mtcars, 2, max)
  
  plotCar <- function(cardata, carName) {
    carValues <- unlist(cardata[carName, ])
    carValuesRel <- carValues / colMax
    
    avgValues <- round(colMeans(cardata), 2)
    avgValuesRel <- avgValues / colMax
    
    plot_ly() %>%
      add_bars(x = names(cardata), y = carValuesRel, text = carValues,
               hoverinfo = c("x+text"), name = carName) %>%
      add_bars(x = names(cardata), y = avgValuesRel, text = avgValues,
               hoverinfo = c("x+text"), name = "average") %>%
      layout(barmode = 'group')
  }
  
  c <- manipulateWidget(
    plotCar(subsetCars, car),
    cylinders = mwSelect(c("4", "6", "8")),
    subsetCars = mwSharedValue(subset(mtcars, cylinders == cyl)),
    car = mwSelect(choices = row.names(subsetCars))
  )
}



###### Package morrisjs ==================================
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



###### Package msaR ==================================
### examples.R -------------------------------
library(msaR)

# read some sequences from a multiple sequence alignment file and display
seqfile <- system.file("sequences","AHBA.aln", package="msaR")
msaR(seqfile)


###### Package networkD3 ==================================
### sankey.R -------------------------------
library(networkD3)
library(magrittr)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/networkD3.R')
source('../../packages/master/niravis-master/R/googleVis.R')

fn <- 'data/energy.json'

Energy <- jsonlite::fromJSON(txt = fn)
# Plot

sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
              Target = "target", Value = "value", NodeID = "name",
              units = "TWh", fontSize = 12, nodeWidth = 30)

# Translation:
# Using niraVis:
x = Energy$links$source + 1
y = Energy$links$target + 1

rownames(Energy$nodes) <- Energy$nodes$name 
Energy$nodes$id        <- sequence(length(Energy$nodes$name))

if(inherits(Energy$links$source, 'integer')){
  Energy$links$source <- Energy$nodes$name[Energy$links$source + 1]
}

if(inherits(Energy$links$target, 'integer')){
  Energy$links$target <- Energy$nodes$name[Energy$links$target + 1]
}

xx = Energy$nodes[Energy$links$source ,'id']
yy = Energy$nodes[Energy$links$target ,'id']

assert(equal(xx,x))
assert(equal(yy,y))

list(links = Energy$links, nodes = Energy$nodes) %>%
  networkD3.sankey(source = "source", target = "target", linkWidth = "value")

visNetwork.graph(list(links = Energy$links, nodes = Energy$nodes), source = "source",
                 target = "target", linkWidth = "value", label = "name")

g = googleVis.sankey(obj = Energy$links, linkSource = "source",
                     linkTarget = "target", linkWidth = "value")

g = gvisSankey(Energy$links, from = "source", to = 'target', weight = 'value')

# 

Energy <- jsonlite::fromJSON(txt = fn)

Energy$links$source = as.integer(Energy$links$source + 1)
Energy$links$target = as.integer(Energy$links$target + 1)

visNetwork.graphChart(links = Energy$links, nodes = Energy$nodes, linkSource = "source",
                      linkTarget = "target", linkWidth = "value", label = "name")




###### Package plotly ==================================
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

### pie.R -------------------------------
library(magrittr)
library(dplyr)
library(niragen)

library(plotly)
library(billboarder)
library(morrisjs)
library(rCharts)

source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/coffeewheel.R')
source('../../packages/master/niravis-master/R/morrisjs.R')
source('../../packages/master/niravis-master/R/nvd3.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')

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



# niravis Translation:

data %>% plotly.scatter(x = 'Women', y = 'Men', size = 'Gap') # todo: 

### tsline.R -------------------------------
library(plotly)
library(dplyr)

source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/jscripts.R')

#####################################

today <- Sys.Date()
tm <- seq(0, 600, by = 10)
x <- today - tm
y <- rnorm(length(x))
p <- plot_ly(x = ~x, y = ~y, mode = 'lines', text = paste(tm, "days from today"))

# niravis translation:

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

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/highcharter.R')
source('../../packages/master/niravis-master/R/plotly.R')
source('../../packages/master/niravis-master/R/niraPlot.R')
source('../../packages/master/niravis-master/R/jscripts.R')
source('../../packages/master/niravis-master/R/dygraphs.R')


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
niraPlot(obj = data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'plotly', type = 'combo')

p = c3.combo(obj = data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar')

data %>% melt(id.var = 'Animals') %>% nameColumns(list(Group = 'variable'), classes = list()) %>%
  candela.bar.molten(x = 'Animals', y = 'value', color = 'Group')

p = niraPlot(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dimple', type = 'combo')

p = niraPlot(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', plotter = 'dygraphs', type = 'combo')

p %>% subplot(p, nrows = 3, shareY = T)  # What is this?!


# Other types and packages:
h = niraPlot(data, x = 'Animals', y = list('SF_Zoo', 'LA_Zoo', 'NY_Zoo', 'DR_Zoo'), shape = 'bar', type = 'combo', plotter = 'highcharter')
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

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/dygraphs.R')
source('C:/Nima/R/projects/libraries/developing_packages/plotly.R')


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


source('C:/Nima/RCode/packages/master/niragen-master/R/niragen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/highcharter.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/plotly.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/rCharts.R')

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

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/highcharter.R')
source('C:/Nima/R/projects/libraries/developing_packages/plotly.R')
# These examples are old and many of them don't work in the new version!!
# Example 1: diamonds scatter plot:
set.seed(100)
d <- diamonds[sample(nrow(diamonds), 1000), ]
plot_ly(d, x = ~carat, y = ~price, color = ~carat,
        size = ~carat, text = ~paste("Clarity: ", clarity))

# Translation:

d %>% niraPlot(x = 'carat', y = 'price', shape = 'point', color = 'carat', size = 'carat', plotter = 'plotly', type = 'scatter')
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

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')


# plot. 1
amBullet(value = 65)

# niravis translation

amCharts.bullet(y = 65)

### box.R -------------------------------
library(rAmCharts)
library(tibble)
library(dplyr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')


# plot. 1
dataset <- get(x = "ChickWeight", pos = "package:datasets")
amBoxplot(weight~Diet, data=dataset)

# niravis translation:

dataset %>% amCharts.box(y = 'Diet', x = 'weight')

### bar.R -------------------------------
library(rAmCharts)
library(tibble)
library(dplyr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')


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

# niravis translation:

data_funnel %>% amCharts.funnel(y = 'value', label = 'description', config = list(direction = 'down.up'))

### gauge.R -------------------------------
library(rAmCharts)

amAngularGauge(x = 25)

bands = data.frame(start = c(0, 40, 60), end = c(40, 60, 100), 
                   color = c("#00CC00", "#ffac29", "#ea3838"),
                   stringsAsFactors = FALSE)

amAngularGauge(x = 25, bands = bands)

# niravis translation:

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

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/amCharts.R')


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

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')

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

source('../../packages/master/niravis-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/rAmCharts.R')

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
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/rbokeh.R')

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


# niravis translation:

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/calheatmap.R')

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
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')

source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/visNetwork.R')


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
#   <script src="C:/Nima/RCode/packages/master/zingcharts-master/inst/htmlwidgets/lib/zing/zingchart.min.js"></script>
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
  

