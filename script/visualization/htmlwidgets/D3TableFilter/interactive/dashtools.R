
# dashtools.R ----------------------------------------------------------------


# Header
# Filename:      dash.tools.R
# Description:   An ensemble of functions required for creation of elegant plots for a shiny dashboard
# Author:        Nicolas Berta
# Email :        nicolas.berta@gmail.com
# Start Date:    22 January 2016
# Last Revision: 19 September 2018
# Version:       0.0.5

# Version History:

# Version     Date               Action
# ----------------------------------
# 0.0.1       22 January 2016    Initial issue with name tools.R
# 0.0.2       04 July 2016       Module renamed from tools.R to dashtools.R
# 0.0.3       04 July 2016       Function io.str() works as a method of class DASHBOARD and transferred to dashboard.R
# 0.0.4       07 September 2016  Functions map.zoom() and plot.sg.map() transferred to nibe.plotters.R and renamed.
# 0.0.5       19 September 2018  Functions buildStyle() added.


"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

"%|W|%" <- function(a, b) {
  if (!is.waive(a)) a else b
}

is.waive <- function(x) inherits(x, "waiver")

#' @export
plotHtml = function(obj){
  browseURL2 = function(url, height){
    browseURL(url)
  }
  options(viewer = browseURL2)
  show(obj)
}

buildStyle = function(object, inline = NULL, vertical_align = NULL, width = NULL, float = NULL){
  if(is.null(inline) & is.null(vertical_align) & is.null(width)){return(object)}

  style = "display:" %++%
    chif(inline %>% verify('logical', default = F), " inline-block;", "") %++%
    chif(is.null(vertical_align), "", " vertical-align:" %++% vertical_align %++% ";") %++%
    chif(is.null(float), "", " float:" %++% float %++% ";") %++%
    chif(is.null(width), "", " width:" %++% width %++% ";")

  div(style = style, object)
}


# obj = actionButton(i, label = lbl, icon = icn, width = items[[i]]$width) %>% buildStyle(inline = items[[i]]$inline, vertical_align = items[[i]]$vertical_align)},
