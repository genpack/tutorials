
### bar.R ------------------------
library(canvasXpress)
y=read.table("http://www.canvasxpress.org/data/cX-stacked1-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-stacked1-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  smpAnnot=x,
  axisAlgorithm="rPretty",
  colorBy="GNI",
  decorations=list(marker=list(list(align="center", baseline="middle", color="red", sample="Norway", text="Norway is the country\nwith the largest GNI\naccording to 2014 census", variable="population", x=0.65, y=0.7), list(align="center", baseline="middle", color="red", sample="China", text="China is the country with\nthe largest population\naccording to 2014 census", variable="population", x=0.15, y=0.1))),
  graphOrientation="vertical",
  graphType="Stacked",
  legendInside=TRUE,
  legendPosition="top",
  showTransition=TRUE,
  smpLabelRotate=45,
  subtitle="2014 Census",
  title="Country Population colored by Gross National Income",
  treemapBy=list("ISO3"),
  widthFactor=4,
  xAxisMinorTicks=FALSE,
  afterRender=list(list("groupSamples", list("continent")))
)




# Example 2:

y=read.table("http://www.canvasxpress.org/data/cX-iris-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-iris-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  smpAnnot=x,
  axisTitleFontStyle="italic",
  decorations=list(marker=list(list(sample="setosa", text="Species with\nlowest petal\nwidth", variable="Petal.Width", x=0.4, y=0.85))),
  graphOrientation="vertical",
  graphType="Bar",
  legendBox=FALSE,
  legendColumns=2,
  legendPosition="bottom",
  showTransition=TRUE,
  smpLabelRotate=90,
  smpTitle="Species",
  title="Iris flower data set",
  xAxis2Show=FALSE,
  afterRender=list(list("groupSamples", list("Species")))
)
