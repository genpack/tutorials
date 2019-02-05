
### combo.R ------------------------

library(niragen)
library(canvasXpress)
# Chart 1: Area-Line

y=read.table("http://www.canvasxpress.org/data/cX-arealine-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  colorScheme="Basic",
  graphOrientation="vertical",
  graphType="AreaLine",
  legendPosition="right",
  lineThickness=3,
  lineType="spline",
  smpLabelInterval=20,
  smpLabelRotate=45,
  smpTitle="Year",
  subtitle="gcookbook - uspopage",
  title="Age distribution of population in the United State",
  xAxis=list("<5", "5-14", "15-24", "25-34"),
  xAxis2=list("35-44", "45-54", "55-64", ">64"),
  xAxisTitle="Number of People (1000's)"
)


# CHart 2: Bar-line

y=read.table("http://www.canvasxpress.org/data/cX-generic-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
x=read.table("http://www.canvasxpress.org/data/cX-generic-smp.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
z=read.table("http://www.canvasxpress.org/data/cX-generic-var.txt", header=TRUE, sep= "\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  # smpAnnot=x,
  # varAnnot=z,
  backgroundGradient1Color="rgb(226,236,248)",
  backgroundGradient2Color="rgb(112,179,222)",
  backgroundType="gradient",
  graphOrientation="vertical",
  graphType="BarLine",
  legendBackgroundColor=FALSE,
  legendBox=FALSE,
  legendColumns=2,
  legendPosition="bottom",
  lineThickness=2,
  lineType="spline",
  showShadow=TRUE,
  showTransition=TRUE,
  smpLabelRotate=45,
  smpTitle="Collection of Samples",
  smpTitleFontStyle="italic",
  subtitle="Random Data",
  title="Bar-Line Graphs",
  xAxis=list("Variable1", "Variable2"),
  xAxis2=list("Variable3", "Variable4"),
  xAxis2TickFormat="%.0f T",
  xAxisTickColor="rgb(0,0,0)",
  xAxisTickFormat="%.0f M"
)
