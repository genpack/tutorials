### examples.R -------------------------------
# http://www.r-graph-gallery.com/portfolio/maps/


library(leaflet)
m <- leaflet()
m <- m %>% addTiles() %>%
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")


m

###

df = data.frame(Lat = 1:10, Long = rnorm(10))
leaflet(df) %>% addTiles() %>% addCircles() 

###

m = leaflet() %>% addTiles()
df = data.frame(
  lat = rnorm(100),
  lng = rnorm(100),
  size = runif(100, 5, 20),
  color = sample(colors(), 100)
)
m = leaflet(df) %>% addTiles()
m %>% addCircleMarkers(radius = ~size, color = ~color, fill = FALSE)
m %>% addCircleMarkers(radius = runif(100, 4, 10), color = c('red'))


###

library(htmltools)

df <- read.csv(textConnection(
  "Name,Lat,Long
  Samurai Noodle,47.597131,-122.327298
  Kukai Ramen,47.6154,-122.327157
  Tsukushinbo,47.59987,-122.326726"
))

leaflet(df) %>% addTiles() %>%
  addMarkers(~Long, ~Lat, popup = ~htmlEscape(Name))
