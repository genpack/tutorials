
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
