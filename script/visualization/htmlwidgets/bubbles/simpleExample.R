### simpleExample.R --------------------------
library(bubbles)
library(shiny)

source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')
source('C:/Nima/R/projects/libraries/developing_packages/bubbles.R')

b = bubbles(value = rexp(26), label = LETTERS, tooltip = letters, color = rainbow(26, alpha=NULL)[sample(26)])

# Translate:

df = data.frame(Volume = rexp(26), bubName = LETTERS, bubLabel = letters, bubType = c(rep('Type 1',4), rep('Type 2', 12), rep('Type 3', 10)))
bubbles.bubble(df, color = rainbow(26, alpha=NULL)[sample(26)], size = 'Volume', label = 'bubName', labelColor = 'black', tooltip = 'bubLabel')