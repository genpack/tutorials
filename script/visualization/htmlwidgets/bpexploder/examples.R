###### Package: bpexploder ===================================
### examples.R --------------------------

library(bpexploder)

bpexploder(data = iris,
           settings = list(
             groupVar = "Species",
             colorVar = "LO",
             levels = levels(iris$Species),
             yVar = "Petal.Length",
             tipText = list(
               Petal.Length = "Petal Length",
               Sepal.Width  = "Sepal Width"
             ),
             relativeWidth = 0.75)
)

# Translation:

iris %>% bpexploder.box.molten(
  group = 'Species', y = 'Petal.Width', 
  config = list(tooltip = list(
    Petal.Length = "Petal Length",
    Sepal.Width  = "Sepal Width"
  )))



# Chart 2

bpexploder(data = chickwts,
           settings = list(
             yVar = "weight",
             # default NULL would make make one plot for yVar
             groupVar = "feed",
             levels = levels(with(chickwts,
                                  reorder(feed, weight, median))),
             # you could adjust the group labels ...
             levelLabels = NULL,
             # ... and the colors for each group:
             levelColors = RColorBrewer::brewer.pal(6, "Set3"),
             yAxisLabel = "6-week weight (grams)",
             xAxisLabel = "type of feed",
             tipText = list(
               # as many os you like of:
               # variableName = "desired tool-tip label"
               # leave tipText at NULL for no tips
               weight = "weight"),
             # set width relative to grandarent element of svg image:
             relativeWidth = 0.75,
             # default alignment within containing div is "center"
             # "left" and "right" are other possible values"
             align = "center",
             # aspect = width/height, defaults to 1.25
             aspect = 1.5)
)


# Translate:
