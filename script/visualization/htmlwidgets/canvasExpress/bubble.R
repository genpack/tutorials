
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
