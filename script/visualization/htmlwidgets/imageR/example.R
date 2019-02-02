
### imageR.R -------------------------

library(imageR)

tf <- tempfile()
png( file = tf, height = 400, width = 600 )
plot(1:50)
dev.off()
intense(base64::img(tf))



##########################################
library(shiny)
library(htmltools)
library(lattice)
library(imageR)

tf <- tempfile()
tf2 <- tempfile()
png( file = tf, height = 400, width = 1600 )
#example from ?lattice::cloud
cloud(Sepal.Length ~ Petal.Length * Petal.Width | Species, data = iris,
      screen = list(x = -90, y = 70), distance = .4, zoom = .6)
dev.off()

png( file = tf2, height = 1000, width = 1000)
#### example from http://www.cceb.med.upenn.edu/pages/courses/BSTA670/2012/R_3D_plot_ex.r
#--------------------------------
# persp plot of function
#--------------------------------
x <- seq(-10, 10, length= 30)
y <- x
f <- function(x,y) { r <- sqrt(x^2+y^2); 10 * sin(r)/r }
z <- outer(x, y, f)
z[is.na(z)] <- 1
op <- par(bg = "white")
persp(x, y, z, theta = 30, phi = 30, expand = 0.5, col = "lightblue")
dev.off()

html_print(fluidPage(
  tags$h1("Cloud and Wireframe from Lattice")
  ,fluidRow(style = "height:60%; overflow:hidden;"
            ,column(width = 6,  intense(base64::img(tf)))
            ,column(width = 6,  intense(base64::img(tf2)))
  )
))

##########################################

library(htmltools)
library(curl)
library(navr)
library(sortableR)
library(imageR)

n1 <- navr(
  selector = "#sortableR-toolbar"
  ,taglist = tagList(
    tags$ul(id = "sort-navr"
            ,style="line-height:120px; text-align:center; vertical-align:middle;"
            ,tags$li(
              style="border: solid 0.1em white;border-radius:100%;line-height:inherit;width:130px;height:130px;"
              , class="fa fa-binoculars fa-4x"
              #  attribution everywhere Creative Commons Flickr
              #  awesome picture by https://www.flickr.com/photos/12859033@N00/2288766662/
              , "data-image" = paste0(
                "data:image/jpg;base64,"
                ,base64enc::base64encode(
                  curl("https://farm4.staticflickr.com/3133/2288766662_c40c168b76_o.jpg","rb")
                )
              )
              , "data-title" = "Binoculars, a working collection"
              , "data-caption" = "awesome picture courtesy Flickr Creative Commons
              <a href = 'https://www.flickr.com/photos/12859033@N00/2288766662/'>jlcwalker</a>"
            )        
            ,tags$li(
              style="border: solid 0.1em white;border-radius:100%;line-height:inherit;width:130px;height:130px;"
              , class="fa fa-camera fa-4x"
              #  attribution everywhere Creative Commons Flickr
              #  awesome picture by https://www.flickr.com/photos/s58y/5607717791
              , "data-image" = paste0(
                "data:image/jpg;base64,"
                ,base64enc::base64encode(
                  curl("https://farm6.staticflickr.com/5309/5607717791_b030229247_o.jpg","rb")
                )
              )
              , "data-title" = "Leica IIIc converted to IIIf BD ST"
              , "data-caption" = "awesome picture courtesy Flickr Creative Commons
              <a href = 'https://www.flickr.com/photos/s58y/5607717791'>s58y</a>"
            )
            )
            )
)

html_print(tagList(
  tags$div(
    id = "sortableR-toolbar"
    ,style="width:300px;border: dashed 0.2em lightgray; float:left;"
    ,tags$h3("sortableR Icons for Intense Images")
    ,"These icons drag and drop. Click on them for an"
    ,tags$strong("intense")
    ,"result."
  )
  ,add_font_awesome(n1)
  ,sortableR("sort-navr")
  ,intense( selector = "#sort-navr li" )
))