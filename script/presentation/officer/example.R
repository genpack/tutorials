###### Package Officer ======================================================================
### Example.R ---------------------------
library('mschart')
linec <- ms_linechart(data = iris, x = "Sepal.Length",
                      +                       y = "Sepal.Width", group = "Species")
linec <- chart_ax_y(linec, num_fmt = "0.00", rotation = -90)
linec
# https://davidgohel.github.io/officer/