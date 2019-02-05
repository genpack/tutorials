
### bar.R ----------------------------
library("billboarder")
source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/jscripts.R')

# Example 1: Barchart

# data
data("prod_par_filiere")

# a bar chart !
billboarder() %>%
  bb_barchart(data = prod_par_filiere[, c("annee", "prod_hydraulique")], color = "#102246") %>%
  bb_y_grid(show = TRUE) %>%
  bb_y_axis(tick = list(format = suffix("TWh")),
            label = list(text = "production (in terawatt-hours)", position = "outer-top")) %>% 
  bb_legend(show = FALSE) %>% 
  bb_labs(title = "French hydraulic production",
          caption = "Data source: RTE (https://opendata.rte-france.com)")


# Translation:
cfg = list(
  yAxis.grid.enabled = T, 
  yAxis.tick.label.suffix = " TWh",
  yAxis.label = "production (in terawatt-hours)",
  yAxis.label.position = 'outer-top',
  legend.enabled = T,
  title = 'French hydraulic production',
  caption = 'Data source: RTE (https://opendata.rte-france.com)')

prod_par_filiere[, c("annee", "prod_hydraulique")] %>% 
  billboarder.bar(x = "annee", y = "prod_hydraulique", color = "#102246", 
                  config = cfg)

# want horizontal? swap x and y:
prod_par_filiere[, c("annee", "prod_hydraulique")] %>% 
  billboarder.bar(y = "annee", x = "prod_hydraulique", color = "#102246", 
                  config = cfg)



# trying dcr:
prod_par_filiere %>% dc.bar(x = 'annee', y = 'prod_bioenergies')


# Example 2: Barchart Multi-series:


data("prod_par_filiere")

# dodge bar chart !
billboarder() %>%
  bb_barchart(
    data = prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")]
  ) %>%
  bb_data(
    names = list(prod_hydraulique = "Hydraulic", prod_eolien = "Wind", prod_solaire = "Solar")
  ) %>% 
  bb_y_grid(show = TRUE) %>%
  bb_y_axis(tick = list(format = suffix("TWh")),
            label = list(text = "production (in terawatt-hours)", position = "outer-top")) %>% 
  bb_legend(position = "inset", inset = list(anchor = "top-right")) %>% 
  bb_labs(title = "Renewable energy production",
          caption = "Data source: RTE (https://opendata.rte-france.com)")


# Translation:
cfg = list(yAxis.grid.enabled = T, yAxis.tick.label.suffix = 'TWh', yAxis.label = 'production (in terawatt-hours)', yAxis.label.position = 'outer-top',
           legend.enabled = T, legend.position = 'top-right',
           title = 'Renewable energy production', caption = 'Data source: RTE (https://opendata.rte-france.com)')
prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")] %>%
  billboarder.bar(x = 'annee', y = list(Hydraulic = "prod_hydraulique", Wind = 'prod_eolien', Solar = 'prod_solaire'), config = cfg)


# Other packages:
prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")] %>%
  nvd3.bar(x = 'annee', y = list(Hydraulic = "prod_hydraulique", Wind = 'prod_eolien', Solar = 'prod_solaire'), config = cfg)


# Example 3: Stack Barchart Multi-series:
# data
data("prod_par_filiere")

# stacked bar chart !
billboarder() %>%
  bb_barchart(
    data = prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")], 
    stacked = TRUE
  ) %>%
  bb_data(
    names = list(prod_hydraulique = "Hydraulic", prod_eolien = "Wind", prod_solaire = "Solar"), 
    labels = TRUE
  ) %>% 
  bb_colors_manual(
    "prod_eolien" = "#41AB5D", "prod_hydraulique" = "#4292C6", "prod_solaire" = "#FEB24C"
  ) %>%
  bb_y_grid(show = TRUE) %>%
  bb_y_axis(tick = list(format = suffix("TWh")),
            label = list(text = "production (in terawatt-hours)", position = "outer-top")) %>% 
  bb_legend(position = "right") %>% 
  bb_labs(title = "Renewable energy production",
          caption = "Data source: RTE (https://opendata.rte-france.com)")

# Translation:
cfg$stack.enabled = T
cfg$legend.position = 'right'
prod_par_filiere[, c("annee", "prod_hydraulique", "prod_eolien", "prod_solaire")] %>%
  billboarder.bar(x = 'annee', y = list(Hydraulic = "prod_hydraulique", Wind = 'prod_eolien', Solar = 'prod_solaire'), config = cfg)



library("billboarder")

stars <- data.frame(
  package = c("billboarder", "ggiraph", "officer", "shinyWidgets", "visNetwork"),
  stars = c(1, 176, 42, 40, 166)
)

# Hide legend:
billboarder() %>%
  bb_barchart(data = stars) %>% 
  bb_legend(show = FALSE)

# niravis translation:
stars %>% billboarder.bar(x = 'package', y = 'stars', config = list(legend.enabled = F))


