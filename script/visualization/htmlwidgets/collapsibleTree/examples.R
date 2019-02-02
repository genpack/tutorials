###### Package collapsibleTree ==================================
### examples.R ------------------------
# https://adeelk93.github.io/collapsibleTree/
library(data.tree)

library(collapsibleTree)

Geography = read.csv('data/Geography.csv')

head(Geography)


collapsibleTree(
  Geography,
  hierarchy = c("continent", "type", "country"),
  width = 800, 
  tooltip = T
)
