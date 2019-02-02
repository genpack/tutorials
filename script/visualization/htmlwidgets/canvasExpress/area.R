
### area.R ------------------------
library(niragen)
library(canvasXpress)

source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')


#  Example chart 1:

y=read.table("http://www.canvasxpress.org/data/cX-area3-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  areaType="stacked",
  colorScheme="ColorSpectrum",
  colorSpectrum=list("blue", "cyan", "yellow", "red"),
  graphOrientation="vertical",
  graphType="Area",
  lineType="spline",
  showLegend=FALSE,
  showSampleNames=FALSE,
  showTransition=TRUE,
  subtitle="http://menugget.blogspot.com/2013/12/data-mountains-and-streams-stacked-area.html",
  title="Steam Plot"
)


# Chart 2:

y=read.table("http://www.canvasxpress.org/data/cX-area-dat.txt", header=TRUE, sep="\t", quote="", row.names=1, fill=TRUE, check.names=FALSE, stringsAsFactors=FALSE)
canvasXpress(
  data=y,
  colorScheme="RlatticeShingle",
  graphOrientation="vertical",
  graphType="Area",
  legendPosition="right",
  lineType="spline",
  showTransition=TRUE,
  smpLabelInterval=20,
  smpLabelRotate=45,
  smpTitle="Year",
  subtitle="gcookbook - uspopage",
  title="Age distribution of population in the United State",
  transparency=0.5,
  xAxis2Show=FALSE,
  xAxisTitle="Number of People (1000's)"
)




