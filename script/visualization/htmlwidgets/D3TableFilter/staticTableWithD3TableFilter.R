### staticTableWithD3TableFilter.R ------------------------
# ----------------------------------------------------------------------
# test script for interactive features of the d3tf widget outside of shiny
# ----------------------------------------------------------------------
library(htmlwidgets)
library(D3TableFilter)
library(magrittr)

source('C:/Nima/R/projects/tutorial/htmlwidget/scripts/D3TableFilter/genjscripts.R')
source('C:/Nima/R/projects/libraries/developing_packages/D3TableFilter.R')

data(mtcars);
mtcars <- mtcars[, 1:3];
mtcars$candidates <- FALSE;
mtcars$favorite <- FALSE;
myCandidates <- sample(nrow(mtcars), 5);
myFavorite <- sample(myCandidates, 1);
mtcars[myFavorite, "favorite"] <- TRUE;
mtcars[myCandidates, "candidates"] <- TRUE;

# define table properties. See http://tablefilter.free.fr/doc.php
# for a complete reference
tableProps <- list(
  btn_reset = TRUE,
  sort = TRUE,
  on_keyup = TRUE,  
  on_keyup_delay = 800,
  rows_counter = TRUE,  
  rows_counter_text = "Rows: ",
  col_number_format= c(NULL, "US", "US", "US", NULL, NULL), 
  sort_config = list(
    # alphabetic sorting for the row names column, numeric for all other columns
    sort_types = c("String", "Number", "Number", "Number", "none", "none")
  ),
  col_4 = "none",
  col_5 = "none",
  # exclude the summary row from filtering
  rows_always_visible = list(nrow(mtcars) + 2)
);

# columns are addressed in TableFilter as col_0, col_1, ..., coln
# the "auto" scales recalculate the data range after each edit
# to get the same behaviour with manually defined colour scales
# you can use the "colMin", "colMax", or "colExtent" functions,
# e.g .domain(colExtent("col_1")) or .domain([0, colMax(col_1)])
bgColScales <- list(
  col_3 = "auto:white:green",
  col_2 = "auto:white:red"
);

# apply D3.js functions to a column,
# e.g. to turn cell values into scaled SVG graphics
cellFunctions <- list(
  col_1 = js.bubblecol,
  col_2 = js.barcol
);

# apply D3.js functions to footer columns,
# e.g. to format them or to turn cell values into scaled SVG graphics
footCellFunctions <- list(col_0 = js.bold, col_1 = js.bold.1f, col_2 = js.bold.1f, col_3 = js.bold.right.1f);

initialFilters = list(col_1 = ">20");

colNames = c(Rownames = "Model", mpg = "Miles per gallon",	cyl = "Cylinders",	disp = "Displacement",	candidates = "Candidates",	favorite = "My favorite");
colNames = c(Rownames = "Model")

# add a summary row. Can be used to set values statically, but also to 
# make use of TableFilters "col_operation"
footData <- data.frame(Rownames = "Mean", mpg = mean(mtcars$mpg), cyl = mean(mtcars$cyl), disp = mean(mtcars$disp));

# the mtcars table output
tbl = d3tf(mtcars, tableProps = tableProps,
           showRowNames = TRUE,
           colNames = colNames,
           edit = c("col_1", "col_3"),
           checkBoxes = "col_4",
           radioButtons = "col_5",
           cellFunctions = cellFunctions,
           extensions = c('ColsVisibility', 'ColumnsResizer', 'FiltersRowVisibility'),
           tableStyle = "table table-bordered",
           bgColScales = bgColScales,
           filterInput = TRUE,
           initialFilters = initialFilters,
           footData = footData,
           footCellFunctions = footCellFunctions,
           height = 200)

# tbl %>%
#     saveWidget(file = "test.html", selfcontained = F)
# 
# d3tf(mtcars)


# Translation:

tbl = mtcars %>% D3TableFilter.table(label = list(MPG = 'mpg', Cylinders = 'cyl', 'hp', 'vs', 'am', 'gear'))
