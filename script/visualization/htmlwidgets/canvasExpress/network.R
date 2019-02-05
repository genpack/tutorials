
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
