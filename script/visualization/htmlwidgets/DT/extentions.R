### extensions.R ------------------------
# DT Extensions does not work at the moment
library(DT)
datatable(
  iris, rownames = FALSE,
  extensions = 'Buttons', options = list(
    dom = 'Bfrtip',
    buttons = list(list(extend = 'colvis', columns = c(2, 3, 4)))
  )
)


# Translation:

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')

source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/DT.R')

DT.table(iris, rownames = T)

