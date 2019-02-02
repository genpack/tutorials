
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
