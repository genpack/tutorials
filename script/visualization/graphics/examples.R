### art.R ------------------------------------
# http://www.r-graph-gallery.com/portfolio/data-art/

### graphics.R ------------------------------------
# http://www.r-graph-gallery.com/portfolio/circular-plot/

### likert.R ------------------------------------
# http://www.r-graph-gallery.com/202-barplot-for-likert-type-items/

### example1.R ------------------------------------
# http://www.r-graph-gallery.com/portfolio/basics/
### event_handler_example.R ------------------------------------
# This currently only works on the Windows
# and X11(type = "Xlib") screen devices...
## Not run: 
savepar <- par(ask = FALSE)
dragplot <- function(..., xlim = NULL, ylim = NULL, xaxs = "r", yaxs = "r") {
  plot(..., xlim = xlim, ylim = ylim, xaxs = xaxs, yaxs = yaxs)
  startx <- NULL
  starty <- NULL
  prevx <- NULL
  prevy <- NULL
  usr <- NULL
  
  devset <- function()
    if (dev.cur() != eventEnv$which) dev.set(eventEnv$which)
  
  dragmousedown <- function(buttons, x, y) {
    startx <<- x
    starty <<- y
    prevx <<- 0
    prevy <<- 0
    devset()
    usr <<- par("usr")
    eventEnv$onMouseMove <- dragmousemove
    NULL
  }
  
  dragmousemove <- function(buttons, x, y) {
    devset()
    deltax <- diff(grconvertX(c(startx, x), "ndc", "user"))
    deltay <- diff(grconvertY(c(starty, y), "ndc", "user"))
    if (abs(deltax-prevx) + abs(deltay-prevy) > 0) {
      plot(..., xlim = usr[1:2]-deltax, xaxs = "i",
           ylim = usr[3:4]-deltay, yaxs = "i")
      prevx <<- deltax
      prevy <<- deltay
    }
    NULL
  }
  
  mouseup <- function(buttons, x, y) {
    eventEnv$onMouseMove <- NULL
  }	
  
  keydown <- function(key) {
    if (key == "q") return(invisible(1))
    eventEnv$onMouseMove <- NULL
    NULL
  }
  
  setGraphicsEventHandlers(prompt = "Click and drag, hit q to quit",
                           onMouseDown = dragmousedown,
                           onMouseUp = mouseup,
                           onKeybd = keydown)
  eventEnv <- getGraphicsEventEnv()
}

x11()
dragplot(rnorm(1000), rnorm(1000))
getGraphicsEvent()
par(savepar)

## End(Not run)

### example2.R ------------------------------------
# This currently only works on the Windows
# and X11(type = "Xlib") screen devices...
## Not run: 
savepar <- par(ask = FALSE)
dragplot <- function(..., xlim = NULL, ylim = NULL, xaxs = "r", yaxs = "r") {
  plot(..., xlim = xlim, ylim = ylim, xaxs = xaxs, yaxs = yaxs)
  startx <- NULL
  starty <- NULL
  prevx <- NULL
  prevy <- NULL
  usr <- NULL
  
  devset <- function()
    if (dev.cur() != eventEnv$which) dev.set(eventEnv$which)
  
  dragmousedown <- function(buttons, x, y) {
    startx <<- x
    starty <<- y
    prevx <<- 0
    prevy <<- 0
    devset()
    usr <<- par("usr")
    eventEnv$onMouseMove <- dragmousemove
    NULL
  }
  
  dragmousemove <- function(buttons, x, y) {
    devset()
    deltax <- diff(grconvertX(c(startx, x), "ndc", "user"))
    deltay <- diff(grconvertY(c(starty, y), "ndc", "user"))
    if (abs(deltax-prevx) + abs(deltay-prevy) > 0) {
      plot(..., xlim = usr[1:2]-deltax, xaxs = "i",
           ylim = usr[3:4]-deltay, yaxs = "i")
      prevx <<- deltax
      prevy <<- deltay
    }
    NULL
  }
  
  mouseup <- function(buttons, x, y) {
    eventEnv$onMouseMove <- NULL
  }	
  
  keydown <- function(key) {
    if (key == "q") return(invisible(1))
    eventEnv$onMouseMove <- NULL
    NULL
  }
  
  setGraphicsEventHandlers(prompt = "Click and drag, hit q to quit",
                           onMouseDown = dragmousedown,
                           onMouseUp = mouseup,
                           onKeybd = keydown)
  eventEnv <- getGraphicsEventEnv()
}

dragplot(rnorm(1000), rnorm(1000))
getGraphicsEvent()
par(savepar)

## End(Not run)



## A function to use function identify() to select points, and overplot the
## points with another symbol as they are selected
identifyPch <- function(x, y = NULL, n = length(x), pch = 19, ...)
{
  xy <- xy.coords(x, y); x <- xy$x; y <- xy$y
  sel <- rep(FALSE, length(x)); res <- integer(0)
  while(sum(sel) < n) {
    ans <- identify(x[!sel], y[!sel], n = 1, plot = FALSE, ...)
    if(!length(ans)) break
    ans <- which(!sel)[ans]
    points(x[ans], y[ans], pch = pch)
    sel[ans] <- TRUE
    res <- c(res, ans)
  }
  res
}

