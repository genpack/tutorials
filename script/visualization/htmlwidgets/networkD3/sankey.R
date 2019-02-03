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




