
### color.R ------------------------
# https://github.com/rstudio  link to RStudio github containing many source code for packages, tutorials and examples

library(magrittr)
library(dplyr)
source('C:/Nima/R/projects/libraries/developing_packages/niragen.R')
source('C:/Nima/R/projects/libraries/developing_packages/linalg.R')
source('C:/Nima/R/projects/libraries/developing_packages/visgen.R')

source('C:/Nima/R/projects/libraries/developing_packages/d3TableFilter.R')


obj <- data.frame(AutoScale = round(seq(1, 200, length.out = 30), 1));
obj$LinearNumeric <- obj$AutoScale;
obj$LinearNumericHCL <- obj$LinearNumeric;
obj$LogScale <- rep(c(1, 2, 3, 10, 20, 30, 100, 200, 300, 1000, 2000, 3000, 10000, 20000, 30000), 2);
obj$Divergent <- round(seq(0, 14, length.out = 30), 1);
obj$OrdinalScale <- sample(LETTERS[1:14], nrow(obj), replace = TRUE);
obj$ColorBrewer.Set3 <- sample(LETTERS[1:9], nrow(obj), replace = TRUE);
obj$mycolor <- c("#FFFFFF","#342F28","#5DA369","#00FFFF","#F67A00","#0FB8D1","#9D1D1D","#101010","#494949","#838383","#BDBDBD","#F6F6F6","#1D1D1D","#575757","#909090","#C9C9C9","#F0FFF0","#A8A25E","#AAC1C1","#A7DDFD","#B100B1","#C11584","#FFA500","#A7E4E4","#D098D0","#5A424C","#87CEED","#00F278","#6E7666","#9ACD32")

table_Props <- list(
  # appearence
  btn_reset = TRUE,  
  btn_reset_text = "Clear",
  # behaviour
  on_change = TRUE,  
  btn = FALSE,  
  enter_key = TRUE,  
  on_keyup = TRUE,  
  on_keyup_delay = 1500,
  highlight_keywords = TRUE,  
  loader = TRUE,  
  loader_text = "Filtering data...",
  # sorting
  col_types = c("number", "number", "number","number", "number", "string", "string", "string"),
  # paging
  paging = FALSE
);



js0 = D3TableFilter.color.nomional.js(domain = c("A"      , "B"     , "C"    , "C"    , "D"   , "E"     , "F"   , "G"      , "H"      , "I"      , "J"      , "L"   , "M"  , "N"),
                                      range  = c("#FFFFFF", "yellow", "green", "black", "pink", "orange", "cyan", "#9D1D1D", "#101010", "#494949", "#838383", "blue", "red", "gray"))


js1 = "auto:white:green"
js3 = D3TableFilter.color.numeric.js(domain = obj$LinearNumericHCL, 
                                     range = obj$LinearNumericHCL %>% colorize(palette = c("white", "blue")))

js4 = D3TableFilter.color.numeric.js(domain = obj[,4], 
                                     range = obj[,4] %>% log %>% colorize(palette = c("white", "orangered")))

js5 = D3TableFilter.color.numeric.js(domain = obj[,5], 
                                     range = obj[,5] %>% log %>% colorize(palette = c("#f8766d", "white", "#00bfc4")))

js6 = D3TableFilter.color.nominal.js(domain = LETTERS[1:10], range = colours()[1:10])

js7 = JS('function ghablame(tbl, ii){
         var color = d3.scale.ordinal()
         .domain(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"])
         .range(colorbrewer.Set3[9]);
         return color(ii);
         }')
    

js8 = JS('function colorScale(obj,i){
         return(i)
         }')

# columns are addressed in TableFilter as col_0, col_1, ..., coln
bgColScales <- list(
  col_0 = js1,
  col_1 = js1,
  col_2 = js3,
  # don't include 0 in the range of a log scale
  col_3 = js4,
  col_4 = js5,
  col_5 = js0,
  col_6 = js7,
  col_7 = js8);

# invert font colour at a certain threshold
# to make it readable on darker background colour
fgColScales <- list(
  col_1 = JS('function colorScale(obj, i){
             var color = d3.scale.threshold()
             .domain([110, 110, 200.1])
             .range(["black", "black", "white"]);
             return color(i);
             }'),
      col_2 = JS('function colorScale(obj, i){
                 var color = d3.scale.threshold()
                 .domain([130, 130, 200.1])
                 .range(["black", "black", "white"]);
                 return color(i);
      }') 
    );

extensions <-  list(
  list(name = "sort")
);

tbl = 
  d3tf(obj, table_Props, enableTf = TRUE,
       showRowNames = FALSE, tableStyle = "table table-condensed", 
       bgColScales = bgColScales,
       fgColScales = fgColScales,
       extensions = extensions)


# Translate

tbl  = obj %>% D3TableFilter.table(label = names(obj) %>% as.list, color = 'OrdinalScale')
