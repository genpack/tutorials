### test.R -----------------------
library(dashboard)

dashboard_open(data=iris) # other options: pathoutput=getwd() ...
dcpiechart(x=names(iris)[5])
dcbarchart(x=names(iris)[1] , gap=75)
dcpiechart(x=names(iris)[2])
dctable(index=names(iris)[5])
dashboard_launch(browse = FALSE) # Just generates files. Server is not launched

