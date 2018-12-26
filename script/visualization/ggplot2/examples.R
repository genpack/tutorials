### ggplot2.R --------------------------------------

# Links:
# http://www.r-graph-gallery.com/portfolio/ggplot2-package/

# http://www.r-graph-gallery.com/portfolio/barplot/
# http://www.r-graph-gallery.com/portfolio/boxplot/
# http://www.r-graph-gallery.com/portfolio/histograms/
# A must-see website:
# http://www.r-graph-gallery.com/

# http://www.r-graph-gallery.com/all-graphs/

# http://tutorials.iq.harvard.edu/R/Rgraphics/Rgraphics.html
# http://ggplot2.tidyverse.org/reference/aes_group_order.html


# Circular Barplot:

library(ggplot2)

# make data
data=data.frame(group=c("A ","B ","C ","D ") , value=c(33,62,56,67) )

# Usual bar plot :
ggplot(data, aes(x = group, y = value ,fill = group )) + 
  geom_bar(width = 0.85, stat="identity")

# Circular one
ggplot(data, aes(x = group, y = value ,fill = group)) + 
  geom_bar(width = 0.85, stat="identity") +    
  
  # To use a polar plot and not a basic barplot
  coord_polar(theta = "y") +    
  
  #Remove useless labels of axis
  xlab("") + ylab("") +
  
  #Increase ylim to avoid having a complete circle
  ylim(c(0,75)) + 
  
  #Add group labels close to the bars :
  geom_text(data = data, hjust = 1, size = 3, aes(x = group, y = 0, label = group)) +
  
  #Remove useless legend, y axis ticks and y axis text
  theme(legend.position = "none" , axis.text.y = element_blank() , axis.ticks = element_blank())



# lolipop:

df <- read.csv(text="category,pct
               Other,0.09
               South Asian/South Asian Americans,0.12
               Interngenerational/Generational,0.21
               S Asian/Asian Americans,0.25
               Muslim Observance,0.29
               Africa/Pan Africa/African Americans,0.34
               Gender Equity,0.34
               Disability Advocacy,0.49
               European/European Americans,0.52
               Veteran,0.54
               Pacific Islander/Pacific Islander Americans,0.59
               Non-Traditional Students,0.61
               Religious Equity,0.64
               Caribbean/Caribbean Americans,0.67
               Latino/Latina,0.69
               Middle Eastern Heritages and Traditions,0.73
               Trans-racial Adoptee/Parent,0.76
               LBGTQ/Ally,0.79
               Mixed Race,0.80
               Jewish Heritage/Observance,0.85
               International Students,0.87", stringsAsFactors=FALSE, sep=",", header=TRUE)

# devtools::install_github("hrbrmstr/ggalt")
library(ggplot2)
library(scales)

gg <- ggplot(df, aes(y=reorder(category, pct), x=pct))
gg <- gg + geom_lollipop(point.colour="steelblue", point.size=3, horizontal=TRUE)
gg <- gg + scale_x_continuous(expand=c(0,0), labels=percent,
                              breaks=seq(0, 1, by=0.2), limits=c(0, 1))
# gg <- gg + coord_flip()
gg <- gg + labs(x=NULL, y=NULL, 
                title="SUNY Cortland Multicultural Alumni survey results",
                subtitle="Ranked by race, ethnicity, home land and orientation\namong the top areas of concern",
                caption="Data from http://stephanieevergreen.com/lollipop/")
gg <- gg + theme_minimal(base_family="Arial Narrow")
gg <- gg + theme(panel.grid.major.y=element_blank())
gg <- gg + theme(panel.grid.minor=element_blank())
gg <- gg + theme(axis.line.y=element_line(color="#2b2b2b", size=0.15))
gg <- gg + theme(axis.text.y=element_text(margin=margin(r=-5, l=0)))
gg <- gg + theme(plot.margin=unit(rep(30, 4), "pt"))
gg <- gg + theme(plot.title=element_text(face="bold"))
gg <- gg + theme(plot.subtitle=element_text(margin=margin(b=10)))
gg <- gg + theme(plot.caption=element_text(size=8, margin=margin(t=10)))
gg


# population categories by country
library(ggplot2)
library(reshape2)
library(grid)

this_base = "fig08-15_population-data-by-county"

my_data = data.frame(
  Race = c("White", "Latino", "Black", "Asian American", "All Others"),
  Bronx = c(194000, 645000, 415000, 38000, 40000),
  Kings = c(855000, 488000, 845000, 184000, 93000),
  New.York = c(703000, 418000, 233000, 143000, 39000),
  Queens = c(733000, 556000, 420000, 392000, 128000),
  Richmond = c(317000, 54000, 40000, 24000, 9000),
  Nassau = c(986000, 133000, 129000, 62000, 24000),
  Suffolk = c(1118000, 149000, 92000, 34000, 26000),
  Westchester = c(592000, 145000, 123000, 41000, 23000),
  Rockland = c(205000, 29000, 30000, 16000, 6000),
  Bergen = c(638000, 91000, 43000, 94000, 18000),
  Hudson = c(215000, 242000, 73000, 57000, 22000),
  Passiac = c(252000, 147000, 60000, 18000, 12000),
  newcounty = c(212000, 127000, 50000, 17000, 14000))

my_data_long = melt(my_data, id = "Race",
                    variable.name = "county", value.name = "population")

my_data_long$county = factor(
  my_data_long$county, c("New.York", "Queens", "Kings", "Bronx", "Nassau",
                         "Suffolk", "Hudson", "Bergen", "Westchester",
                         "Rockland", "Richmond", "Passiac"))

my_data_long$Race =
  factor(my_data_long$Race,
         rev(c("White", "Latino", "Black", "Asian American", "All Others")))

p = ggplot(my_data_long, aes(x = population / 1000, y = Race)) +
  geom_point() +
  facet_wrap(~ county, ncol = 3) +
  scale_x_continuous(breaks = seq(0, 1000, 200),
                     labels = c(0, "", 400, "", 800, "")) +
  labs(x = "Population (thousands)", y = NULL) +
  ggtitle("Fig 8.15 Population Data by County") +
  theme_bw() +
  theme(panel.grid.major.y = element_line(colour = "grey60"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        panel.margin = unit(0, "lines"),
        plot.title = element_text(size = rel(1.1), face = "bold", vjust = 2),
        strip.background = element_rect(fill = "grey80"),
        axis.ticks.y = element_blank())

p

ggsave(paste0(this_base, ".png"),
       p, width = 6, height = 8)



# https://plot.ly/ggplot2/aes/
# https://plot.ly/ggplot2/
# http://docs.ggplot2.org/current/
