library(htmlwidgets)
library(crosstalk)
library(d3scatter)

###### Chart 1:
d3scatter(iris, ~Petal.Length, ~Petal.Width, ~Species)

###### Chart 2:
shared_iris <- SharedData$new(iris)
bscols(
  d3scatter(shared_iris, ~Petal.Length, ~Petal.Width, ~Species, width="100%", height=300),
  d3scatter(shared_iris, ~Sepal.Length, ~Sepal.Width, ~Species, width="100%", height=300)
)


###### Small Dashboard:
shared_mtcars <- SharedData$new(mtcars)
bscols(widths = c(3,NA,NA),
       list(
         filter_checkbox("cyl", "Cylinders", shared_mtcars, ~cyl, inline = TRUE),
         filter_slider("hp", "Horsepower", shared_mtcars, ~hp, width = "100%"),
         filter_select("auto", "Automatic", shared_mtcars, ~ifelse(am == 0, "Yes", "No"))
       ),
       d3scatter(shared_mtcars, ~wt, ~mpg, ~factor(cyl), width="100%", height=250),
       d3scatter(shared_mtcars, ~hp, ~qsec, ~factor(cyl), width="100%", height=250)
)






###### Chart 3:

row.names(mtcars) <- NULL
sd_mtcars_all <- SharedData$new(mtcars, group = "mtcars_subset")
sd_mtcars_auto <- SharedData$new(mtcars[mtcars$am == 0,], group = "mtcars_subset")
sd_mtcars_manual <- SharedData$new(mtcars[mtcars$am == 1,], group = "mtcars_subset")

bscols(widths = c(8, 4),
       d3scatter(sd_mtcars_all, ~hp, ~mpg, ~factor(cyl),
                 x_lim = ~range(hp), y_lim = ~range(mpg),
                 width = "100%", height = 400),
       list(
         d3scatter(sd_mtcars_auto, ~hp, ~mpg, ~factor(cyl),
                   x_lim = range(mtcars$hp), y_lim = range(mtcars$mpg),
                   width = "100%", height = 200),
         d3scatter(sd_mtcars_manual, ~hp, ~mpg, ~factor(cyl),
                   x_lim = range(mtcars$hp), y_lim = range(mtcars$mpg),
                   width = "100%", height = 200)
       )
)
