
### pie.R ----------------------------
# Example 5: Pie charts:


library("billboarder")
source('../../packages/master/niragen-master/R/niragen.R')

source('../../packages/master/niragen-master/R/visgen.R')
source('../../packages/master/niravis-master/R/billboarder.R')
source('../../packages/master/niravis-master/R/jscripts.R')

# data
data("prod_par_filiere")
nuclear2016 <- data.frame(
  sources = c("Nuclear", "Other"),
  production = c(
    prod_par_filiere$prod_nucleaire[prod_par_filiere$annee == "2016"],
    prod_par_filiere$prod_total[prod_par_filiere$annee == "2016"] -
      prod_par_filiere$prod_nucleaire[prod_par_filiere$annee == "2016"]
  )
)

# pie chart !
billboarder() %>% 
  bb_piechart(data = nuclear2016) %>% 
  bb_labs(title = "Share of nuclear power in France in 2016",
          caption = "Data source: RTE (https://opendata.rte-france.com)")

nuclear2016 %>% billboarder.pie(
  label = 'sources', theta = 'production', 
  config = list(title    = "Share of nuclear power in France in 2016",
                subtitle = "Data source: RTE (https://opendata.rte-france.com)"))

