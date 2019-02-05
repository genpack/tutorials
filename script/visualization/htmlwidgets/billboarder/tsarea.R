### tsarea.R ----------------------------

library(magrittr)
library(dplyr)

library("billboarder")

source('C:/Nima/RCode/packages/master/niragen-master/R/niragen.R')

properties = read.csv('C:/Nima/RCode/packages/master/niravis-master/data/properties.csv' , as.is = T)
source('C:/Nima/RCode/packages/master/niravis-master/R/visgen.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/billboarder.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/jscripts.R')


source('C:/Nima/RCode/packages/master/niravis-master/R/c3.R')
source('C:/Nima/RCode/packages/master/niravis-master/R/streamgraph.R')

# data
data("cdc_prod_filiere")

# area chart !
billboarder() %>% 
  bb_linechart(
    data = cdc_prod_filiere[, c("date_heure", "prod_eolien", "prod_hydraulique", "prod_solaire")], 
    type = "area"
  ) %>% 
  bb_subchart(show = TRUE, size = list(height = 30)) %>% 
  bb_data(
    groups = list(list("prod_eolien", "prod_hydraulique", "prod_solaire")),
    names = list("prod_eolien" = "Wind", "prod_hydraulique" = "Hydraulic", "prod_solaire" = "Solar")
  ) %>% 
  bb_legend(position = "inset", inset = list(anchor = "top-right")) %>% 
  bb_colors_manual(
    "prod_eolien" = "#238443", "prod_hydraulique" = "#225EA8", "prod_solaire" = "#FEB24C", 
    opacity = 0.8
  ) %>% 
  bb_y_axis(min = 0, padding = 0) %>% 
  bb_labs(title = "Renewable energy production (2017-06-12)",
          y = "In megawatt (MW)",
          caption = "Data source: RTE (https://opendata.rte-france.com)")


# niravis translation:
settings = list(title = "Renewable energy production (2017-06-12)", 
                subtitle = "Data source: RTE (https://opendata.rte-france.com)",
                legend.position = 'top-right',
                yAxis.label = "In megawatt (MW)",
                xAxis.tick.label.format = "%H O'clock",
                color = list(Wind = "#238443", Hydraulic = "#225EA8", Solar = "#FEB24C"),
                stack.enabled = T,
                aggregator = 'mean',
                opacity = 0.8)

cdc_prod_filiere %>% 
  billboarder.tsarea(x = "date_heure", y = list(Wind = "prod_eolien", Hydraulic = "prod_hydraulique", Solar = "prod_solaire"), config = settings)

# c3.tsline() and c3.tsarea() only work with Date as x axis, so POSIXct is converted to character. If config$aggregator is defined, it is aggregated automatically if key values (x axis) are not unique
cdc_prod_filiere %>% mutate(date_heure = format(date_heure, "%H")) %>% 
  c3.area(x = "date_heure", y = list(Wind = "prod_eolien", Hydraulic = "prod_hydraulique", Solar = "prod_solaire"), config = settings)


# streamgraph.tsarea

cdc_prod_filiere %>% mutate(date_heure = format(date_heure, "%H")) %>% 
  streamgraph.tsarea(x = "date_heure", y = list(Wind = "prod_eolien", Hydraulic = "prod_hydraulique", Solar = "prod_solaire"), config = settings)
