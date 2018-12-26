### motionchart.R ------------------------
Motion=gvisMotionChart(Fruits, 
                       idvar="Fruit", 
                       timevar="Year")
plot(Motion)


myStatusSettings  = '
{
  iconKeySettings":[{"key":{"dim0":"RDFN"}}, {"key":{"dim0":"FFPE"}}]  # specifies which items to be visible initially 
  "xLambda":1,
  "xZoomedIn":false,
  "xZoomedDataMin":0,  # min value of x axis
  "xZoomedDataMax":16, # max value of x axis
  "xAxisOption":"_ALPHABETICAL",  # Other options: "_TIME", 
  "orderedByX":true,
  
  "yLambda":0,   # dont know yet
  "yZoomedIn":false,  # dont know yet
  "yZoomedDataMin":0, # min value of y axis
  "yZoomedDataMax":40000, # max value of y axis
  "yAxisOption":"2",
  "orderedByY":false,
  
  "dimensions":{"iconDimensions":["dim0"]},
  "colorOption":"_UNIQUE_COLOR"
  "showTrails":false,
  "nonSelectedAlpha":0, # color intensity of non-selected items. If 0, non-selected items become invisible
  "uniColorForNonSelected":false,
  
  "iconType":"VBAR",
  "sizeOption":"_UNISIZE",
  "time":"2016-05-27", # which time to start with
  
  "playDuration":15000,
  "duration":{"timeUnit":"D","multiplier":1},
  "stateVersion":3 
}'
  
  #  ,"time":"notime","xAxisOption":"_NOTHING","playDuration":15,"iconType":"BUBBLE","sizeOption":"_NOTHING","xZoomedDataMin":null,"xZoomedIn":false,"duration":{"multiplier":1,"timeUnit":"none"},"yZoomedDataMin":null,"xLambda":1,"colorOption":"_NOTHING","nonSelectedAlpha":0.4,"dimensions":{"iconDimensions":[]},"yZoomedIn":false,"yAxisOption":"_NOTHING","yLambda":1,"yZoomedDataMax":null,"showTrails":true,"xZoomedDataMax":null};'
  
  
  # rmd example
  
  