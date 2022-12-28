### interactive/app.R ------------------------
# ----------------------------------------------------------------------
# Shiny app demonstrating interactive features of the tableFilter widget 
# This code is translated to niravis language from the original code:
# ----------------------------------------------------------------------

library(shiny)
library(htmlwidgets)
library(magrittr)

library(rutils)
library(rvis)

# source('C:/Nima/RCode/packages/niragen/R/niragen.R')
#source('C:/Nima/RCode/packages/niravis-master/R/visgen.R')
#source('C:/Nima/RCode/packages/niravis-master/R/jscripts.R')
#source('C:/Nima/RCode/packages/niravis-master/R/rscripts.R')
#source('C:/Nima/RCode/packages/niravis-master/R/dashboard.R')
#source('C:/Nima/RCode/packages/niravis-master/R/TFD3.R')

data(mtcars);
mtcars <- mtcars[, 1:3];
mtcars$candidates <- FALSE;
mtcars$favorite <- FALSE;
myCandidates <- sample(nrow(mtcars), 5);
myFavorite <- sample(myCandidates, 1);
mtcars[myFavorite, "favorite"] <- TRUE;
mtcars[myCandidates, "candidates"] <- TRUE;

filtering <- data.frame(Rows = c(nrow(mtcars), nrow(mtcars)), Indices = c(paste(1:nrow(mtcars), collapse = ', '), paste(1:nrow(mtcars), collapse = ', ')), stringsAsFactors = FALSE);
rownames(filtering) <- c("Before", "After")

cfg = list(column.shape = list(cyl = 'bubble', disp = 'bar', candidates = 'checkBox', favorite = 'radioButtons'),
           column.color = list(mpg = c('white', 'yellow', 'red')),
           column.color.auto = list(mpg = T),
           column.title = list(rownames = "Model", mpg = "Miles per gallon",	cyl = "Cylinders",	disp = "Displacement",	candidates = "Candidates",	favorite = "My favorite"),
           column.editable = list('mpg' = T, 'disp' = T),
           column.footer = list(rownames = 'Mean', mpg = mean, disp = mean, cyl = mean),
           table.style = 'table table-bordered',
           column.filter = list('rownames' = 'Da'),
           # Table properties:
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
           rows_always_visible = list(nrow(mtcars) + 2),
           height = 2000
           
)

cfg2 = list(row.color = c('', 'danger', rep('', nrow(mtcars) - 2)),
            selected = c(1,  3,  5,  7,  9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31),
            selection.mode = 'multi',
            selection.color = 'info', 
            table.style = 'table table-bordered table-condensed',
            btn_reset = TRUE,
            rows_counter = TRUE,  
            rows_counter_text = "Rows: ",
            sort = TRUE,
            height = 500,
            on_keyup = TRUE,  
            on_keyup_delay = 800,
            sort_config = list(
              sort_types = c("Number", "Number")
            ),
            filters_row_index = 1,
            # adding a summary row, showing the column means
            rows_always_visible = list(nrow(mtcars) + 2),
            col_operation = list( 
              id = list("frow_0_fcol_1_tbl_mtcars2","frow_0_fcol_2_tbl_mtcars2"),    
              col = list(1,2),    
              operation = list("mean","mean"),
              write_method = list("innerhtml",'innerhtml'),  
              exclude_row = list(nrow(mtcars) + 2),  
              decimal_precision = list(1, 1)
            ))

###################################### Dashboard Design:
# Service Functions:

# Clothes

WP = list(type = 'wellPanel')


I = list()
O = list()
# Containers:
I$main      = list(type = 'fluidPage', title = 'Interactive features', layout = 'tabset')
I$tabset    = list(type = 'tabsetPanel', selected = "Editing and filtering", layout = c('tab1', 'tab2'))
I$tab1      = list(type = 'tabPanel' , title = "Editing and filtering", col.framed = T, layout = c('col11', 'col12', 'col13'))
I$tab2      = list(type = 'tabPanel' , title = "Row selection", layout = c('tab2Title', 'col21', 'col22', 'col23'))
I$col11     = list(type = 'column', weight = 2, layout = c('editingCol0', 'clearfilter', 'WP_fltr', 'cellVal', 'WP_fvr', 'summaryRow'))
I$col12     = list(type = 'column', weight = 5, layout = 'mtcars')
I$col13     = list(type = 'column', weight = 5, layout = c('edits', 'filters', 'filtering', 'filteredMtcars'))
I$col21     = list(type = 'column', weight = 2, layout = c('html', 'WP_hlp'))
I$col22     = list(type = 'column', weight = 5, layout = c('mtcars2'))
I$col23     = list(type = 'column', weight = 5, layout = 'mtcars2Output')
I$WP_fltr   = list(type = 'wellPanel', layout = c('filterString', 'dofilter'))
I$WP_fvr    = list(type = 'wellPanel', layout = c('candidate', 'favorite'))
I$WP_hlp    = list(type = 'wellPanel', layout = c('helpText', 'hornetClass'))
# Inputs:
I$editingCol0  = list(type = 'radioButtons'  , title = "Rownames editing", choices = c("Enable" = TRUE, "Disable" = FALSE), selected = FALSE)
I$clearfilter  = list(type = 'actionButton' , title = "Clear filters", service = "clearFilters(session, tbl = 'mtcars', doFilter = TRUE)")
I$dofilter     = list(type = 'actionButton' , title = "Set filter", isolate = T, service = "sync$mtcars_column.filter[['rownames']] = input$filterString")
I$filterString = list(type = 'textInput'    , title = "Filter rownames", value = "rgx:^D")
# Row address is based on the complete, unfiltered and unsorted table
# Column address is one based. In this case showRowNames is TRUE,
# rownames column is col 0, "cylinders" is col 2.
I$cellVal      = list(type = 'selectInput'  , title = "Merc 240D cylinders", choices = c(4, 6, 8, 10, 12), selected = 4, multiple = FALSE, cloth = WP, service = "setCellValue(session, tbl = 'mtcars', row = 8, col = 2, value = input$cellVal, feedback = TRUE)")
I$favorite     = list(type = 'actionButton' , title = "Make Datsun favorite")
I$summaryRow   = list(type = 'selectInput'  , title = "Summary row", choices = c("mean", "median"), multiple = FALSE)
I$hornetClass  = list(type = 'selectInput'  , title = "Set row class on 'Hornet Sportabout'", choices = c("none", "active", "success", "info", 'warning', "danger"), selected = "none")

# Outputs:
# O$candidateUi     = list(type = "uiOutput")
I$candidate       = list(type = "radioButtons", title = "Make Datsun candidate", choices = c("yes" = TRUE, "no" = FALSE), selected = T)
O$mtcars          = list(type = "TFD3Output", title = "mtcars" %>% h4, height = "auto", sync = T, config = cfg, data = mtcars)
O$mtcars2         = list(type = "TFD3Output", title = "", height = "2000px",  sync = T, config = cfg2, data = mtcars[ , 1:2])
O$mtcars2Output   = list(type = "tableOutput", title = "")
O$edits           = list(type = "tableOutput", title = h4("Last edits"), rownames = T) 
O$filters         = list(type = "tableOutput", title = h4("Filters")) 
O$filtering       = list(type = "tableOutput", title = h4("Filter results"), rownames = T) 
O$filteredMtcars  = list(type = "tableOutput", title = h4("mtcars after filtering and editing"), rownames = T) 
O$tab2Title       = list(type = 'static', object = h4("Row selection"))
O$html            = list(type = 'static', object = HTML("Click on the table to select a row. <code>Ctrl</code>  click for multiple selection."))
O$helpText        = list(type = 'static', object = helpText("This demonstrates the setRowClass to highlight a specific row using contextual classes from bootstrap. Can also be used to unselect a row"))

##### Server:

## Observers:
OB = character()

OB[1] = "
if(is.null(input$mtcars_filter)) return(NULL);
reval$filtering['After', 'Rows'] <- length(report$mtcars_filtered);
reval$filtering['After', 'Indices'] <- paste(report$mtcars_filtered, collapse = ', ');
reval$filters <- sync$mtcars_column.filter %>% as.data.frame %>% t %>% as.data.frame %>% rownames2Column('Column');
"

# server side editing of checkbox
I$candidate$service = 
  "  
if(is.null(input$candidate)) return(NULL);
# why do I get string values and not logicals here? Shiny bug?
if(input$candidate == 'TRUE') {
candidate = TRUE;
} else if (input$candidate == 'FALSE') {
candidate = FALSE;
} else {
candidate = input$candidate;
}
# setCellValue(session, tbl = 'mtcars', row = 3, col = 4, value = candidate, feedback = TRUE);
sync$mtcars[3, 4] = candidate
"

# I$favorite$service = "setCellValue(session, tbl = 'mtcars', row = 3, col = 5, value = TRUE, feedback = TRUE)"
I$favorite$service = "sync$mtcars[3, 5] = TRUE"
I$cellVal$service  = "sync$mtcars[8, 2] = input$cellVal %>% as.integer"
I$hornetClass$service = "if(is.null(sync$mtcars2_row.color)){sync$mtcars2_row.color = items[['mtcars2']]$config$row.color}; sync$mtcars2_row.color[5] = input$hornetClass; if(input$hornetClass == 'info'){sync$mtcars2_selected = 12:16}"
I$editingCol0$service = "sync$mtcars_column.editable[['rownames']] = input$editingCol0"
I$summaryRow$service = "func = chif(input$summaryRow == 'mean', mean, median); sync$mtcars_column.footer = list(rownames = input$summaryRow, mpg = func, mpg = func, cyl = func, disp = func)"
I$clearfilter$service = "sync$mtcars_column.filter = list()"

O$edits$service = "
if(is.null(report$mtcars_lastEdits)) return(invisible());
report$mtcars_lastEdits;
"
O$filtering$service = "
if(is.null(reval$filtering)) return(invisible());
reval$filtering;
"
O$filters$service = "
if(nrow(reval$filters) == 0) return(invisible());
reval$filters;
"

O$filteredMtcars$service = "
if(is.null(report$mtcars_filtered)) return(invisible());    
if(is.null(sync$mtcars)) return(invisible());
sync$mtcars[report$mtcars_filtered, ];
"

O$mtcars2Output$service = "
if(is.null(input$mtcars2_select)) return(NULL);
mtcars[input$mtcars2_select, 1:2];
"

dash = new('DASHBOARD', items = c(I, O), king.layout = list('main'), observers = OB)

dash$prescript = "
reval <- reactiveValues();
reval$filtering <- filtering;
reval$filters <- NULL;
reval$filters <- data.frame(Column = character(), Filter = character(), stringsAsFactors = FALSE);
"

ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)
