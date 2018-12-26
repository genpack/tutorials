### gauge.R: ------------------------------------------

library(googleVis)

Gauge <-  gvisGauge(CityPopularity, 
                    options=list(min=0, max=800, greenFrom=500,
                                 greenTo=800, yellowFrom=300, yellowTo=500,
                                 redFrom=0, redTo=300, width=400, height=300))
plot(Gauge)

# niravis Translation:
cfg = list(theta.min = 0, theta.max = 800, thetaAxis.tick.step = 100, aggrigator.function = mean,
           thetaAxis.zone = 
             list(list(min = 500, max = 800, color = 'green'))  %>% 
             list.add(list(min = 300, max = 500, color = 'yellow')) %>% 
             list.add(list(min = 0  , max = 300, color = 'red'))
)
CityPopularity %>% googleVis.gauge(theta = 'Popularity', label = 'City', config = cfg) %>% plot

# with rAmCharts:

CityPopularity %>% amCharts.gauge(theta = 'Popularity', label = 'City', config = cfg)

# Using old viser:

g = googleVis.gauge.old(CityPopularity, theta = 'Popularity', label = 'City')
plot(g)
