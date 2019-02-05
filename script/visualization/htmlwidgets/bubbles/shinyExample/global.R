
### shiny/global.R ------------------------------------
library(bubbles)
library(shiny)

b = bubbles(value = rexp(26), label = LETTERS, tooltip = letters, color = rainbow(26, alpha=NULL)[sample(26)])
b2 = bubbles(value = rexp(16), label = letters[1:16], tooltip = LETTERS[1:16], color = rainbow(16, alpha=NULL)[sample(16)])
