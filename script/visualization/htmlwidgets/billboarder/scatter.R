
### scatter.R ----------------------------
library("billboarder")


# Example 1: Scatter plot Multi-series:
billboarder() %>% 
  bb_scatterplot(data = iris, x = "Sepal.Length", y = "Sepal.Width", group = "Species") %>% 
  bb_axis(x = list(tick = list(fit = FALSE))) %>% 
  bb_point(r = 8)


# Translation:
iris %>% billboarder.scatter.molten(x = "Sepal.Length", y = "Sepal.Width", group = "Species", config = list(point.size = 8))

