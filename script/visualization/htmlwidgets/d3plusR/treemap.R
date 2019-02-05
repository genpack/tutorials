
### treemap.R ------------------------
library(D3plusR)
library(dplyr)
library(magrittr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/d3plus.R')


data("bra_exp_2015")
d3plus(data = bra_exp_2015,
       type = "tree_map",
       id = c("region", "Partner"),
       width = "100%",
       height = 500) %>% 
  d3plusSize(value = "Trade.Value..US..") %>% 
  d3plusLegend(value = TRUE, order = list(sort = "desc", value = "size")) %>% 
  d3plusColor("region") %>% 
  d3plusDepth(0) %>% 
  d3plusLabels(value = TRUE, valign = "top") %>% 
  d3plusUi(value = list(list(method = "color",
                             value = list(list(Region = "region"), list(Value = "Trade.Value..US.."), list(Country = "Partner"))),
                        list(method = "depth", type = "drop",
                             value = list(list(Continent = 0), list(Country = 1)))))


# niravis translation:
# todo: add multiple colors and correct the menu if more than one color is selected, same for depth with dimension label
bra_exp_2015 %>% d3plus.treemap(label = list('region', 'Partner'), size = 'Trade.Value..US..', color = 'region') %>%
  d3plusUi(value = list(list(method = "color",
                             value = list(list(Region = "region"), list(Value = "Trade.Value..US.."))),
                        list(method = "depth", type = "drop",
                             value = list(list(Continent = 0), list(Country = 1)))))
