###### Package coffeewheel ==================================
### examples.R ------------------------
# https://github.com/armish/coffeewheel
# example.R

library("coffeewheel");
library(magrittr);
library(tibble);
library(dplyr);
source('../../../../papckages/master/niravis-master/R/visgen.R')

# source('../niravis-master/R/visgen.R')


source('C:/Nima/RCode/projects/libraries/developing_packages/niraTree.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/RCode/projects/libraries/developing_packages/coffeewheel.R')



coffeewheel(sampleWheelData, width=500, height=500, main="Sample Wheel Title", partitionAttribute="value")

a <- list(
  list(
    name="R",
    colour = "pink",
    children=list(
      list(name="R_1", colour="#110000"),
      list(name="R_3", colour="#330000"),
      list(name="R_5", colour="#550000"),
      list(name="R_7", colour="#770000"),
      list(name="R_9", colour="#990000"),
      list(name="R_b", colour="#bb0000"),
      list(name="R_d", colour="#dd0000"),
      list(name="R_f", colour="#ff0000")
    )
  ),
  list(
    name="G",
    children=list(
      list(name="G_1", colour="#001100"),
      list(name="G_3", colour="#003300"),
      list(name="G_5", colour="#005500"),
      list(name="G_7", colour="#007700"),
      list(name="G_9", colour="#009900"),
      list(name="G_b", colour="#00bb00"),
      list(name="G_d", colour="#00dd00"),
      list(name="G_f", colour="#00ff00")
    )
  ),
  list(
    name="B",
    children=list(
      list(name="B_1", colour="#000011"),
      list(name="B_3", colour="#000033"),
      list(name="B_5", colour="#000055"),
      list(name="B_7", colour="#000077"),
      list(name="B_9", colour="#000099"),
      list(name="B_b", colour="#0000bb"),
      list(name="B_d", colour="#0000dd"),
      list(name="B_f", colour="#0000ff")
    )
  )
);

coffeewheel(a, width=500, height=500, main="Sample Wheel Title", partitionAttribute="value")

# cwt = list(
#   list(
#     name  = 'Animals',
#     color = 3.5,
#     children = list(
#       list(
#         name  = 'Cats',
#         color = 2,
#         children = list(
#           list(name = 'Cat.1', color = 1),
#           list(name = 'Cat.2', color = 2),
#           list(name = 'Cat.3', color = 3)
#         )
#       ),
#       list(name = 'Dogs', color = 4),
#       list(name = 'Pigs', color = 6),
#       list(name = 'Sheep', color = 5),
#     )
#   ),
#   list(
#     name = 'Cars',
#     color = ...
#     childern = ...
#   )
# )

# Simple Example with niravis:

a = data.frame(x = c(rep('Animals',6), rep("Fruit",4), "Cars"),
               y = c(rep('Cats',3), 'Dogs', 'Sheep', 'Pigs', 'Apple', 'Banana', 'Mango', 'Strawberry', NA),
               z = c('Cat.1', 'Cat.2', 'Cat.3', rep(NA, 8)),
               value = 1:11)

a$colour = colorise(a$value, c('red', 'yellow', 'green'))

a %>% coffeewheel.pie(theta = 'value', color = 'colour', label = list('x', 'y', 'z'))
