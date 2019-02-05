
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
