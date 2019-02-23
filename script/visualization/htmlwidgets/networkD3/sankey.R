### sankey.R -------------------------------
library(networkD3)
library(magrittr)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/networkD3.R')
source('../../packages/master/niravis-master/R/googleVis.R')

# Example 1:

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


## Example 2: (from: https://towardsdatascience.com/using-networkd3-in-r-to-create-simple-and-clear-sankey-diagrams-48f8ba8a4ace)
## load libraries
library(dplyr)
library(networkD3)
library(tidyr)
datapath = "~/Documents/data/miscellaneous/" 
# read in EU referendum results dataset
refresults <- read.csv(datapath %>% paste0("EU-referendum-result-data.csv"))
# aggregate by region
results <- refresults %>% 
  dplyr::group_by(Region) %>% 
  dplyr::summarise(Remain = sum(Remain), Leave = sum(Leave))

# format in prep for sankey diagram
results <- tidyr::gather(results, result, vote, -Region)
# create nodes dataframe
regions <- unique(as.character(results$Region))
nodes <- data.frame(node = c(0:13), 
                    name = c(regions, "Leave", "Remain"))
#create links dataframe
results <- merge(results, nodes, by.x = "Region", by.y = "name")
results <- merge(results, nodes, by.x = "result", by.y = "name")
links <- results[ , c("node.x", "node.y", "vote")]
colnames(links) <- c("source", "target", "value")

# draw sankey network
networkD3::sankeyNetwork(Links = links, Nodes = nodes, 
                         Source = 'source', 
                         Target = 'target', 
                         Value = 'value', 
                         NodeID = 'name',
                         units = 'votes')

library(magrittr)
library(gener)
library(viser)

# viser translation:
list(links = links, nodes = nodes) %>% viserPlot(key = 'node', label = 'name', source = 'source', target = 'target', linkWidth = 'value', type = 'sankey', plotter = 'networkD3')
