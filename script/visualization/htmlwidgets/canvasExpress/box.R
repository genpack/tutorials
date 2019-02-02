
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



