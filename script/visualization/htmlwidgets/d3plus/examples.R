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
