
###### Package d3plusR ==================================
### bar.R ------------------------
library(D3plusR)
library(dplyr)
library(magrittr)

source('../../packages/master/niragen-master/R/niragen.R')
source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/d3plus.R')


data("trade_bra_chn")

# Fake shares
trade_bra_chn <- trade_bra_chn %>% 
  mutate(share = sample(100, nrow(trade_bra_chn), replace = TRUE))

dictionary <- list(TradeValue = "Trade Value", Period = "Year",
                   share = "Share")

attributes <- list(Trade.Flow = data.frame(Trade.Flow = c("Export", "Import"),
                                           hex = c("#344969", "#992234")))

d3plus(data = trade_bra_chn, id = "Trade.Flow",
       type = "stacked",
       dictionary = dictionary) %>% 
  d3plusX(value = "Period") %>% 
  d3plusY(value = "TradeValue") %>% 
  d3plusLegend(value = TRUE, size = 30, data = FALSE) %>% 
  d3plusTooltip(value = c("Period", "TradeValue", "share")) %>% 
  d3plusAttrs(value = attributes) %>% 
  d3plusColor(value = "hex") %>% 
  d3plusTitle("Brazilian Exports and Imports to/from China")



# niravis translation:

cfg = list(title = "Brazilian Exports and Imports to/from China",
           legend.enabled = T,
           legend.size = 30,
           legend.tooltip.enabled = F,
           color = list("Export" = "#344969", "Import" = "#992234"),
           tooltip = c("Year", "Trade Value", "Share"),
           additionalColumns = c(Share = 'share'))

trade_bra_chn %>% 
  d3plus.bar(x = list(Year = 'Period'), y = list('Trade Value' = 'TradeValue'), group = 'Trade.Flow', config = cfg)




