### examples_xlabel.R ------------------------
dates    = c('2012-01-01', '2012-01-02', '2012-01-03', '2012-01-04', '2012-01-05', '2012-01-06')
ts.rmean = c(3.163478, 3.095909, 3.112000, 2.922800, 2.981154, 3.089167)
ts.rmax  = c(5.86, 4.67, 6.01, 5.44, 5.21, 5.26)

data.in = data.frame(ts.rmean, ts.rmax)
rownames(data.in) = dates

library(dygraphs)
library(xts)
library(htmlwidgets)

#the axis label is passed as a date, this function outputs only the month of the date
getMonth <- 'function(d){
var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
return monthNames[d.getMonth()];
}'

#the x values are passed as milliseconds, turn them into a date and extract month and day
getMonthDay <- 'function(d) {
var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
date = new Date(d);
return monthNames[date.getMonth()] + " " +date.getUTCDate(); }'

#set the value formatter function and axis label formatter using the functions above
#they are wrapped in JS() to mark them as javascript    
dygraph(data.in, main = "Title") %>%
  #dySeries("ts.rmean", drawPoints = TRUE, color = "blue") %>%
  #dySeries("ts.rmax", stepPlot = TRUE, fillGraph = TRUE, color = "red") %>%
  #dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
  
  dyAxis("x",valueFormatter=JS(getMonthDay), axisLabelFormatter=JS(getMonth))

dygraph(data.in)
