
### tsline.R ----------------------------
# Example 5: Pie charts:


library("billboarder")
source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/jscripts.R')

source('../../packages/master/niravis-master/R/dygraphs.R')
source('../../packages/master/niravis-master/R/c3.R')
source('../../packages/master/niravis-master/R/morrisjs.R')
source('../../packages/master/niravis-master/R/amCharts.R')


# tsline (Time Series):

# data
data("equilibre_mensuel")

# line chart
billboarder() %>% 
  bb_linechart(
    data = equilibre_mensuel[, c("date", "consommation", "production")], 
    type = "spline"
  ) %>% 
  bb_x_axis(tick = list(format = "%Y-%m", fit = FALSE)) %>% 
  bb_x_grid(show = TRUE) %>% 
  bb_y_grid(show = TRUE) %>% 
  bb_colors_manual("consommation" = "firebrick", "production" = "forestgreen") %>% 
  bb_legend(position = "right") %>% 
  bb_subchart(show = TRUE, size = list(height = 30)) %>% 
  bb_labs(title = "Monthly electricity consumption and production in France (2007 - 2017)",
          y = "In megawatt (MW)",
          caption = "Data source: RTE (https://opendata.rte-france.com)")

# niravis Translation:
settings = list(title = "Monthly electricity consumption and production in France (2007 - 2017)", 
                subtitle = "Data source: RTE (https://opendata.rte-france.com)",
                legend.position = 'right',
                yAxis.label = "In megawatt (MW)",
                xAxis.tick.label.format = "%Y",
                color = list(consommation = "firebrick", production = "forestgreen"))

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  billboarder.tsline(x = 'date', y = list("consommation", "production"), config = settings)

# Alternative way to apply colors:
settings$color = NULL
equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  billboarder.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

################# OTHER PLOTTERS:

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  dygraphs.tsline(x = 'date', y = list("consommation", "production"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  morrisjs.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  amCharts.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  c3.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

equilibre_mensuel[, c("date", "consommation", "production")] %>% 
  d3plus.tsline(x = 'date', y = list("consommation", "production"), color = list("firebrick", "forestgreen"), config = settings)

