

### example_1.R ------------------------

library(dygraphs)
browseURL2 = function(url, height){
  browseURL(url)
}
options(viewer = browseURL2)

# file.copy(tempfile(), file.path(tempdir(), "index.html"))
# viewer <- getOption("viewer")
# viewer("http://localhost:8000")
# browseURL(path)

lungDeaths <- cbind(mdeaths, fdeaths)
d = dygraph(lungDeaths)
d
# Suitable for:
# TIME.SERIES: show history data of multiple numeric figures (Started ...)



lungDeaths <- cbind(ldeaths, mdeaths, fdeaths)
d = dygraph(lungDeaths, main = "Deaths from Lung Disease (UK)") %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = FALSE)