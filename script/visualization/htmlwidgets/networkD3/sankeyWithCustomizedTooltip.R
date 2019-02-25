library(magrittr)
library(networkD3)

value <-  c(12,21,41,12,81)
source <- c(4,1,5,2,1)
target <- c(0,0,1,3,3)

edges2 <- data.frame(cbind(value,source,target))

names(edges2) <- c("value","source","target")
indx  <- c(0,1,2,3,4,5)
ID    <- c('CITY1','CITY2','CITY3','CITY4','CITY5','CITY6')
State <- c( 'IL','CA','FL','NW','GL','TX')
nodes <-data.frame(cbind(ID,indx,State))

sn <- sankeyNetwork(Links = edges2, Nodes = nodes,
                    Source = "source", Target = "target",
                    Value = "value",  NodeID = "ID" 
                    ,units = " " )

sn$x$nodes$State <- nodes$State
sn$x$links$Hover <- 'Value = ' %>% paste0(sn$x$links$value %>% as.character)

sn <- htmlwidgets::onRender(sn,
  "function(el, x) {
    d3.selectAll('.node').select('title foreignObject body pre')
    .text(function(d) { return d.State; });}"
)

sn <- htmlwidgets::onRender(sn,
  "function(el, x) {
    d3.selectAll('.link').select('title foreignObject body pre')
    .text(function(d) { return d.Hover; });}"
)


sn


# viser translation:

library(gener)
library(viser)
library(dplyr)

edges2$Hover <- 'Value = ' %>% paste0(edges2$value %>% as.character)

sn = list(nodes = nodes, links = edges2) %>% 
  viserPlot(key = 'indx', label = 'ID', source = 'source', tooltip = 'State', linkTooltip = 'Hover', target = 'target', linkWidth = 'value', plotter = 'networkD3', type = 'sankey')
