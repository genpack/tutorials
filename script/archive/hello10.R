
###### Package sweave ===================

### examples.Rnw ------------------
#' \documentclass{article}
#' \usepackage{graphicx}
#' \usepackage{hyperref}
#' \usepackage{amsmath}
#' \usepackage{times}
#' 
#' \textwidth=6.2in
#' \textheight=8.5in
#' %\parskip=.3cm
#' \oddsidemargin=.1in
#' \evensidemargin=.1in
#' \headheight=-.3in
#' 
#' 
#' %------------------------------------------------------------
#'   % newcommand
#' %------------------------------------------------------------
#'   \newcommand{\scscst}{\scriptscriptstyle}
#' \newcommand{\scst}{\scriptstyle}
#' \newcommand{\Robject}[1]{{\texttt{#1}}}
#'   \newcommand{\Rfunction}[1]{{\texttt{#1}}}
#'     \newcommand{\Rclass}[1]{\textit{#1}}
#'       \newcommand{\Rpackage}[1]{\textit{#1}}
#'         \newcommand{\Rexpression}[1]{\texttt{#1}}
#'           \newcommand{\Rmethod}[1]{{\texttt{#1}}}
#'             \newcommand{\Rfunarg}[1]{{\texttt{#1}}}
#'               
#'               \begin{document}
#'               \SweaveOpts{concordance=TRUE}
#'               
#'               %------------------------------------------------------------
#'                 \title{Simple example of Sweave}
#'               %------------------------------------------------------------
#'                 \author{Aedin Culhane}
#'               %\date{}
#'               
#'               \SweaveOpts{highlight=TRUE, tidy=TRUE, keep.space=TRUE, keep.blank.space=FALSE, keep.comment=TRUE}
#'               \SweaveOpts{prefix.string=Fig}
#'               
#'               
#'               \maketitle
#'               \tableofcontents
#'               
#'               
#'               %-------------------------------------------
#'                 \section{Introduction}
#'               %--------------------------------------------
#'                 
#'                 Just a simple introduction to Sweave.
#'               
#'               <<test1>>=
#'                 a=1
#'                 b=4
#'                 a+b
#'                 print("hello")
#'                 @
#'                   
#'                   We can call R commands from the text. For example a+b= \Sexpr{a+b}
#'                 
#'                 %-------------------------------------------
#'                   \section{Including a Plot}
#'                 %--------------------------------------------
#'                   Now for a plot.  Note we include fig=TRUE, which prints the plot within the document
#'                 
#'                 
#'                 <<test2, fig=TRUE>>=
#'                   plot(1:10, col="red", pch=19)
#'                 @
#'                   
#'                   Thats it.... simple hey!
#'                   
#'                   
#'                   %------------------------------------
#'                   \subsection{More on Plots}
#'                 %-------------------------------------
#'                   
#'                   To make the plot a little nicer, we can add a caption. Also lets change the size of the plot to be 4" in height and 6" in width
#'                 
#'                 \begin{figure}
#'                 <<test3, fig=TRUE, height=4, width=6>>=
#'                   par(mfrow=c(1,2))
#'                 plot(1:10, col="green", pch=21)
#'                 barplot(height=sample(1:10,5), names=LETTERS[1:5], col=1:5)
#'                 @
#'                   
#'                   \caption{Plot of 1:10 and a bar plot beside it in a figure that is 4x6 inches}
#'                 
#'                 \end{figure}
#'                 
#'                 \newpage
#'                 %------------------------------------
#'                   \subsection{Creating a table}
#'                 %-------------------------------------
#'                   
#'                   Lets include a table using the dataset,  which is included in the default core installation of R. It contains the height and weight of 15 women.
#'                 
#'                 <<women>>=
#'                   require(xtable)
#'                 myTable<-summary(women)
#'                 @
#'                   
#'                   We can manually encode a table in latex
#'                 
#'                 
#'                 \begin{center}
#'                 \begin{tabular}{rrrrrrrr}
#'                 
#'                 <<manualtab, results=tex,echo=FALSE>>=
#'                   nr = nrow(myTable); nc = ncol(myTable)
#'                 for (i in 1:nr)
#'                   for(j in 1:nc) {
#'                     cat("$", myTable[i,j], "$")
#'                     if(j < nc)
#'                       cat("&")
#'                     else
#'                       cat("\\\\\n")
#'                   }
#'                 @
#'                   \end{tabular}
#'                 \end{center}
#'                 
#'                 But it is much easier to use the package \Rpackage{xtable}. We use the function \Rfunction{require} to load the package.
#'                 
#'                 <<xtable1, results=tex>>=
#'                   xtab<-xtable(myTable)
#'                 print(xtab, floating=FALSE)
#'                 @
#'                   
#'                   
#'                   %------------------------------------
#'                   \subsection{More on tables}
#'                 %-------------------------------------
#'                   
#'                   Let make the table nice.  Lets exclude the row numbers and include a caption on the table. We can also tag the table so we reference Table~\ref{Table:women} in the text
#'                 
#'                 
#'                 <<xtable2, results=tex>>=
#'                   xtab2<-xtable(myTable, caption="Summary of women data",  label="Table:women")
#'                 print(xtab2,include.rownames = FALSE)
#'                 @
#'                   
#'                   \newpage
#'                 %------------------------------------
#'                   %handy to include this at the end
#'                 %------------------------------------
#'                   \section{SessionInfo}
#'                 %-------------------------------------
#'                   
#'                   <<sessionInfo>>=
#'                   
#'                   sessionInfo();
#'                 
#'                 @
#'                   
#'                   \end{document}
#'                 
### cars.Rmd ------------------

###### Folder test.packages: =================================
                

### test.gener.optim.bubblesCoord.R -------------------
                
x0 = c(1,-1,3)
y0 = c(-1,2,7)
r  = c(1,2,3)

bubblesCoordCCD(x0,y0,r)


r = rnorm(n = 50, mean = 100, sd = 20)

x0 = r
y0 = r

N = length(r)
D = matrix(0, nrow = N, ncol = N)
for(i in 1:nrow(D)){
  D[i,] = r[i] + r
}

res = cmdscale(D, k = 2)
df = data.frame(x = res[,1], y = res[,2], z = r)

highcharter.scatter.molten(obj = df, x = 'x', y = 'y', size = 'z')

# Minimize (x - mean(x))^2 + (y - mean(y))^2
# S.T: 
# (x[i] - x[j])^2 +  (y[i] - y[j])^2 <= (r[i] + r[j])^2



### test.gener.scalarQP.R -------------------
# Minimize 3*x^2 - 41*x + 25
# S.t.:

# C1: (x - 1)(x - 3)  = x^2 - 4*x  + 3  >= 0
# C2: (x + 2)(x - 5)  = x^2 - 3*x  - 10 >= 0
# C3: (x - 7)(x - 12) = x^2 - 19*x + 84 >= 0
# C4: (x + 3)(x - 1)  = x^2 + 2*x  - 3  >= 0
# C5: (x + 6)(x - 2)  = x^2 + 4*x  - 12 >= 0
# C6: (x + 2)(x - 2)  = x^2        - 4  >= 0
# C7:                   x^2 + 2*x  + 5  >= 0
# C8:                       - 2*x  + 14 >= 0    

A = c(  1,   1,  1,    1,   1,  1, 1,  0)
B = c( -4,  -3, -19,   2,   4,  0, 2, -2)
C = c(  3, -10,  84,  -3, -12, -4, 5, 14)

source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/optim.R')

scalarQP(a = 3, b = -44, A = A, B = B, C = C)

### test.corpus2tdmConverter.R -------------------

tv  = c("I want to study and understand", "I am studying and understanding", "my brother and sister studies good", "Studying is really good")
dic = data.frame(input = c('want','study', 'studying', 'studies'), output = c('study','study', 'study', 'study'))

extra_stopwords = c('sister')

tdm = text.vect.to.term.document.matrix(tv, dictionary = dic)


crp = Corpus(VectorSource(tv))

for (j in seq(crp)){
  for (i in 1:(dim(dic)[1])){
    crp[[j]]$content <- gsub(dic[i,1], dic[i,2], crp[[j]]$content)  
  }
}

stoplist = c(stopwords('english'), letters, extra_stopwords)
ctrl     = list(removePunctuation = TRUE, stopwords = stoplist, removeNumbers = TRUE, tolower = TRUE,stemming = TRUE)

tdm      = TermDocumentMatrix(crp, control = ctrl)
tdm = as.matrix(tdm)

### predictorPowerOptimiser.R -------------------
opt.pred.power = function(x, y){
  p       = 1
  landa   = 1
  rsq.min = 1
  
  while (landa > 0.00001){
    x       = x^p
    reg     = lm( y ~ x)
    sum.reg = summary(reg)
    rsq     = sum.reg$r.squared
    if (rsq < rsq.min){
      rsq.min = rsq
      p.min   = p
      p       = p + landa
    } else {landa = landa*0.1}
  }
}
### predictorBooster.R -------------------


source("init.R")

lib.set = c()

# input files:
input.fname        = paste(data.path, 'sl_prediction', 'input_data.csv', sep='/')

D                  = read.csv(input.fname, as.is = TRUE)

D = D[D$FTE > 0, ]

Num.Preds          = D[, c(3,5,6)]
Cat.Preds          = D[, 2]
output             = D[, 4]

M                  = cbind(Num.Preds, output)

names(M)
res = evaluate(M, start = 1, history.intervals = dim(M)[1])


x  = M[,2]
y  = M[,4]

reg     = lm( y ~ x)
sum.reg = summary(reg)
rsq.min = sum.reg$r.squared


debug(opt.pred.power)
opt.pred.power(x,y)

###### Folder test.viser: ==========================

### 201_shinydashboard_boxes.R ------------------------
library(shiny)
library(shinydashboard)
source('C:/Nicolas/R/packages/viser/R/tools.R')
source('C:/Nicolas/R/packages/gener/R/gener.R')
source('C:/Nicolas/R/packages/viser/R/dashboard.R')


greenBox.1 = list(type = 'InfoBox', title = "Hello1", icon = 'credit-card', subtitle = 'SUBTITLE')
greenBox.2 = list(type = 'InfoBox', title = "Hello2", icon = 'line-chart' , subtitle = 'SUBTITLE', fill = T)
purpleBox  = list(type = 'InfoBox', title = "Hello3", icon = 'line-chart' , subtitle = 'SUBTITLE', fill = T, colour = 'purple')
cloth.1   = list(type = 'ValueBox', icon = 'credit-card', href = "http://google.com")
cloth.2   = list(type = 'ValueBox', icon = 'line-chart', href = "http://yahoo.com", title = 'Approval Rating', color = "green")
cloth.3   = list(type = 'ValueBox', icon = 'users', colour = "yellow")
cloth.4   = list(type = 'Box', status = "warning", solidHeader = TRUE, collapsible = TRUE)
cloth.5   = list(type = 'Box', status = "warning", background = 'green', width = 4)
cloth.6   = list(type = 'Box', background = 'red', width = 4)

# inputs:
in.1  = list(ID = 'orders'  , type = "SliderInput", label = "Orders"  , min = 1, max = 2000, value = 650)
in.2  = list(ID = 'progress', type = "SelectInput", label = "Progress", choices = c("0%" = 0, "20%" = 20, "40%" = 40, "60%" = 60, "80%" = 80, "100%" = 100))

# containers:
in.3 = list(ID = 'dashboard', type = 'DashboardPage', layout.head = c(), layout.side = c(), layout.body = -5)
in.4 = in.3
in.5 = list(ID = 'body'     , type = 'FluidRCPanel'  , layout = list(c(1,2,3), c(4,5,6), c(-6, 7), c(8,9)))
in.6 = list(ID = 'plotbox'  , type = 'Box'           , status = "primary", layout = c(-1, -2))

# outputs:
out.1 = list(ID = 'orderNum2', type = "uiOutput"  , label = "Orders"         , cloth = greenBox.1, srv.func = "prettyNum(input$orders, big.mark=',')")
out.2 = list(ID = 'apr'      , type = "static"    , label = "Approval Rating", cloth = greenBox.2, object = "%60")
out.3 = list(ID = 'progress2', type = "uiOutput"  , label = "Progress"       , cloth = purpleBox, srv.func = "paste0(input$progress, '%')")
out.4 = list(ID = 'orderNum' , type = "uiOutput"  , label = "New Orders"     , cloth = cloth.1, srv.func = "prettyNum(input$orders, big.mark=',')")
out.5 = list(ID = 'empty'    , type = "static"    , label = "Approval Rating", cloth = cloth.2, object = tagList("60", tags$sup(style="font-size: 20px", "%")))
out.6 = list(ID = 'progress' , type = "htmlOutput", label = "Progress"       , cloth = cloth.3, srv.func = "paste0(input$progress, '%')")
out.7 = list(ID = 'plot'     , type = "plotOutput", label = "Histogram box title", cloth = cloth.4, height = 250, srv.func = "hist(rnorm(input$orders))")
out.8 = list(ID = 'status'   , type = "textOutput", label = "Status summary",   cloth = cloth.5, 
             srv.func = "paste0('There are ', input$orders, ' orders, and so the current progress is ', input$progress, '%.')")
out.9 = list(ID = 'status2'  , type = "uiOutput"  , label = "Status summary 2", cloth = cloth.6, 
             srv.func = "p('Current status is: ', icon(switch(input$progress,'100' = 'ok','0' = 'remove','road'), lib = 'glyphicon'))")

inputs  = list(in.1 , in.2, in.3, in.4, in.5, in.6)
outputs = list(out.1, out.2, out.3, out.4, out.5, out.6, out.7, out.8, out.9)



dash = DASHBOARD(obj = NULL, inputs = inputs, outputs = outputs, layout = list(3))

ui <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)

### 052_navbar_example.R ------------------------
library(shiny)
library(shinydashboard)

source('C:/Nicolas/R/packages/viser/R/tools.R')
source('C:/Nicolas/R/packages/gener/R/gener.R')
source('C:/Nicolas/R/packages/viser/R/dashboard.R')

inputs  = list()
outputs = list()

# containers:
inputs[[1]]  = list(ID = 'main'  , type = 'NavbarPage'   , title = "viser:NAVBAR!", layout = c(-2, -3, -6)) 
inputs[[2]]  = list(ID = 'tab.1' , type = 'TabPanel'     , title = 'Plot'           , layout = -7)
inputs[[3]]  = list(ID = 'tab.2' , type = 'TabPanel'     , title = 'Summary'        , layout = 2)
inputs[[4]]  = list(ID = 'tab.3' , type = 'TabPanel'     , title = 'Table'          , layout = 3)
inputs[[5]]  = list(ID = 'tab.4' , type = 'TabPanel'     , title = 'About'          , layout = -8)
inputs[[6]]  = list(ID = 'menu.1', type = 'NavbarMenu'   , title = 'More'           , layout = c(-4, -5))
# inputs[[7]]  = list(ID = 'page.1', type = 'SidebarLayout', title = 'Plot of Cars'   , layout.side = -9, layout.main = 1)
inputs[[7]]  = list(ID = 'page.1', type = 'DashboardPage', title = 'Plot of Cars'   , layout.side = -9, layout.body = 1)
inputs[[8]]  = list(ID = 'page.2', type = 'FluidRCPanel' , title = 'About viser'  , layout = list(list(4, c(5,6))))

cloth.4   = list(type = 'Box', status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12, title = "This is your plot:")

# Inputs:

inputs[[9]] = list(ID = 'plotType', type = 'RadioButton', title = 'Plot type', choices = c("Scatter"="p", "Line"="l"))

# Outputs:

outputs[[1]] = list(ID = 'plot'   , type = 'plotOutput', srv.func = "plot(cars, type=input$plotType)", cloth = cloth.4)
# outputs[[1]] = list(ID = 'plot'   , type = 'plotOutput', srv.func = "plot(cars)")
outputs[[2]] = list(ID = 'summary', type = 'verbatimTextOutput', srv.func = "summary(cars)")
outputs[[3]] = list(ID = 'table'  , type = 'dataTableOutput', srv.func = "DT::datatable(cars)")
outputs[[4]] = list(ID = 'about'  , type = 'static', object = includeMarkdown("about.md"))
outputs[[5]] = list(ID = 'image'  , type = 'static', object = img(class="img-polaroid", src=paste0("http://upload.wikimedia.org/", "wikipedia/commons/9/92/", "1919_Ford_Model_T_Highboy_Coupe.jpg")))
outputs[[6]] = list(ID = 'link'   , type = 'static', object = tags$small("Source: Photographed at the Bay State Antique ", "Automobile Club's July 10, 2005 show at the ", "Endicott Estate in Dedham, MA by ", a(href="http://commons.wikimedia.org/wiki/User:Sfoskett", "User:Sfoskett")))

dash = DASHBOARD(obj = NULL, inputs = inputs, outputs = outputs, layout = list(1))

ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()

shinyApp(ui, server)


### app.R ------------------------
library(shiny)
library(ggplot2)
library(Cairo)   # For nicer ggplot2 output when deployed on Linux

# We'll use a subset of the mtcars data set, with fewer columns
# so that it prints nicely

obj <- DF.VIS(dataset = mtcars[, c("mpg", "cyl", "disp", "hp", "wt", "am", "gear")])

input.srv.func.1 = NA
input.srv.func.2 = NA

output.srv.func.1 = "objects[[1]]$ggplot.out()"
output.srv.func.2 = "nearPoints(objects[[1]]$data, input$plot1_click, addDist = TRUE)"
output.srv.func.3 = "brushedPoints(objects[[1]]$data, input$plot1_brush)"

layout = list(4)

# input ID must be unique
inputs  <<- list(list(ID    = "plot1_click", type  = "PlotClick", srv.func = input.srv.func.1), 
                 list(ID    = "plot1_brush", type  = "PlotBrush", srv.func = input.srv.func.2),
                 list(ID    = "mainPanel"  , type  = "FluidRowColumnPanel", title = 'MTCARS DASHBOARD', layout = list(c(1, 2), list(c(4,5,4,4,5), c(5,3)))),
                 list(ID    = "mainLayout" , type  = "SidebarLayout", title = 'MTCARS DASHBOARD', layout.side = c(4, 5), layout.main = c(-3)))

outputs <<- list(list(ID    = "plot1",      type   = "plotOutput", click = "plot1_click", brush = "plot1_brush", srv.func = output.srv.func.1),
                 list(ID    = "click_info", type   = "verbatimTextOutput",  srv.func = output.srv.func.2),
                 list(ID    = "brush_info", type   = "verbatimTextOutput",  srv.func = output.srv.func.3),
                 list(ID    = "Note.1"    , type   = "Static",        object = h4("This is the Row Title")),
                 list(ID    = "Note.2"    , type   = "Static",        object = h4("This is column Title"))
)

dash = DASHBOARD(obj, inputs = inputs, outputs = outputs, layout = layout, dash.title = "MTCARS DASHBOARD", win.title = "NIRAWIN")


ui <- dash$dashboard.ui()

server <- dash$dashboard.server()

shinyApp(ui, server)


### 081_widgets_gallery.R ------------------------

TXT.1 = p("For each widget below, the Current Value(s) window displays the value that the widget provides to shinyServer.
          Notice that the values change as you interact with the widgets.", style = "font-family: 'Source Sans Pro';")
TXT.2 = br()
TXT.3 = h3("Action button")
TXT.4 = hr()
TXT.5 = p("Current Value:", style = "color:#888888;")
TXT.6 = a("See Code", class = "btn btn-primary btn-md", href = "https://gallery.shinyapps.io/068-widget-action-button/")
TXT.7 = h3("Single checkbox")

in.1 = list(ID = 'action'  ,   type = "ActionButton"       , label = "Press me!")
in.2 = list(ID = 'checkbox',   type = "CheckboxInput"      , label = "Choice A", value = T)
in.3 = list(ID = 'checkGroup', type = "CheckboxGroupInput" , label = h3(), choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3), selected = 1)
in.4 = list(ID = 'date'      , type = "DateInput"          , label = h3("Date input"), value = "2014-01-01")
in.5 = list(ID = 'dates'     , type = "DateRangeInput"     , label = h3("Date range"))
in.6 = list(ID = 'file'      , type = "FileInput"          , label = h3("File input"))
in.7 = list(ID = 'num'       , type = "NumericInput"       , label = h3("Numeric input"), value = 1)
in.8 = list()
in.9 = list()
in.10 = list()

# Container Inputs
in.11 = list(ID = 'headnote',   type = "Column", width = 6, offset = 3, layout = 1)
in.12 = list(ID = 'headnote',   type = "FluidRCPanel", label = "Widgets Gallery",
             layout = list(-11, list( c(3,-1,4,5,11,6), c(7,-2,4,5,12,6), c(-3,4,5,13,6)), 
                           list( c(-4,4,5,14,6)  , c(-5,4,5,15,6)  , c(-6,4,5,16,6)),
                           list( c(-7,4,5,17,6))))

out.1  = list(ID = 'Note.1', type = "ConstantText", object = TXT.1)
out.2  = list(ID = 'Note.2', type = "ConstantText", object = TXT.2)
out.3  = list(ID = 'Note.3', type = "ConstantText", object = TXT.3)
out.4  = list(ID = 'Note.4', type = "ConstantText", object = TXT.4)
out.5  = list(ID = 'Note.5', type = "ConstantText", object = TXT.5)
out.6  = list(ID = 'Note.6', type = "ConstantText", object = TXT.6)
out.7  = list(ID = 'Note.7', type = "ConstantText", object = TXT.7)
out.8  = list()
out.9  = list()
out.10 = list()
out.11 = list(ID = 'action'    , type = "verbatimTextOutput", srv.func = 'input$action')
out.12 = list(ID = 'checkbox'  , type = "verbatimTextOutput", srv.func = 'input$checkbox')
out.13 = list(ID = 'checkGroup', type = "verbatimTextOutput", srv.func = 'input$checkGroup')
out.14 = list(ID = 'date'      , type = "verbatimTextOutput", srv.func = 'input$date')
out.15 = list(ID = 'dates'     , type = "verbatimTextOutput", srv.func = 'input$dates')
out.16 = list(ID = 'file'      , type = "verbatimTextOutput", srv.func = 'input$file')
out.17 = list(ID = 'num'       , type = "verbatimTextOutput", srv.func = 'input$num')

inputs  = list(in.1,in.2, in.3,in.4, in.5,in.6,in.7,in.8,in.9,in.10,in.11,in.12)
outputs = list(out.1,out.2, out.3,out.4, out.5,out.6,out.7,out.8,out.9,out.10,out.11,out.12,out.13,out.14,out.15,out.16,out.17)


dash = DASHBOARD(NULL, inputs = inputs, outputs = outputs, layout = list(12))

ui <- dash$dashboard.ui()

server <- dash$dashboard.server()

shinyApp(ui, server)


### 005_sliders.R ------------------------

sliderValues = function(x1, x2, x3, x4, x5){
  # Compose data frame
  data.frame(
    Name = c("Integer", 
             "Decimal",
             "Range",
             "Custom Format",
             "ANicolastion"),
    Value = as.character(c(x1, x2, paste(x3, collapse=' '), x4, x5)), 
    stringsAsFactors=FALSE)
}


inputs  <<- list(list(ID    = "integer"   , label = "Integer"      , type  = "SliderInput"  , min = 0, max = 1000 , value = 500                    ),      # 1
                 list(ID    = "decimal"   , label = "Decimal"      , type  = "SliderInput"  , min = 0, max = 1    , value = 0.5        , step = 0.1),      # 2
                 list(ID    = "range"     , label = "Range"        , type  = "SliderInput"  , min = 1, max = 1000 , value = c(200,500)             ),      # 3
                 list(ID    = "format"    , label = "Custom Format", type  = "SliderInput"  , min = 0, max = 10000, value = 0          , step = 2500, aNicolaste = T),      # 4
                 list(ID    = "aNicolastion" , label = "Looping ANicolastion", type  = "SliderInput"  , min = 1, max = 2000, value = 1       , step = 10  , aNicolaste = aNicolastionOptions(interval = 300, loop = TRUE)),# 5
                 list(ID    = "mainDash", type  = "SidebarLayout", title = 'Sliders' , layout.side = - c(1:5), layout.main = c(1)))                         # 6

service = "sliderValues(input$integer, input$decimal, input$range, input$format, 'This is viser !!!!!!')"

outputs  <<- list(list(ID    = "view"   , type  = "tableOutput", srv.func = service))  # Output 1

dash = DASHBOARD(obj = NULL, inputs = inputs, outputs = outputs, layout = list(6))

ui <- dash$dashboard.ui()

server <- dash$dashboard.server()

shinyApp(ui, server)

### slider.app.R ------------------------

inputs  <<- list(list(ID    = "integer" , type  = "sliderInput"  , min = 0, max = 1000, srv.func = NA),      # 1
                 list(ID    = "decimal" , type  = "sliderInput"  , min = 0, max = 1   , srv.func = NA),      # 2
                 list(ID    = "range"   , type  = "sliderInput"  , min = 1, max = 1000, srv.func = NA),      # 3
                 list(ID    = "format"  , type  = "sliderInput"  , min = 0, max = 1000, srv.func = NA),      # 4
                 list(ID    = "decimal" , type  = "sliderInput"  , min = 0, max = 1000, srv.func = NA),      # 5
                 list(ID    = "mainDash", type  = "SidebarLayout", title = 'Sliders' , layout.side = - c(1:5), layout.main = c(1)))      # 6
)

outputs  <<- list(list(ID    = "view"   , type  = "TableOutput"))

output.srv.func.1 = "objects[[1]]$ggplot.out()"
output.srv.func.2 = "nearPoints(objects[[1]]$data, input$plot1_click, addDist = TRUE)"
output.srv.func.3 = "brushedPoints(objects[[1]]$data, input$plot1_brush)"




dash$title = 'Sliders'


###### Folder: tmvis ===============================

### dash.R -------------------

# Think about using these packages: GLMnet, text2vec


clusters = c(Corpus = 0)
val      = reactiveValues()

val$triggerPC = T
val$triggerWC = T

WC.Cloth    = list(type = 'box', title = "Word Cloud", status = "primary", solidHeader = T, collapsible = T, weight = 12)
PC.Cloth    = list(type = 'box', title = "MDS Plot", status = "primary", solidHeader = T, collapsible = T, weight = 12)

I = list()

I$main      = list(type = 'dashboardPage', title = 'NIRA Text Miner', layout.head = c() ,layout.body = 'page', layout.side = c('getNC', 'refClust'))
I$page      = list(type = 'fluidPage', layout = list(list('WCBox', 'PCBox')))

I$WCBox     = list(type = 'fluidPage', layout  = list(list('WCWeight', 'WCCluster'), 'WC'), cloth = WC.Cloth)
I$PCBox     = list(type = 'fluidPage', layout  = list(list('PCWeight', 'PCMetric'), 'PC'), cloth = PC.Cloth)
I$PCMetric  = list(type = "radioButtons", title =  "Metric"     , choices = valid.metrics, inline = T, weight = 9, selected = 'spherical')
I$PCWeight  = list(type = "radioButtons", title =  "Weighting"  , choices = valid.weightings, weight = 3, selected = 'freq')
# I$WC        = list(type = "plotOutput" , height = '300px')
I$WC        = list(type = "wordcloud2Output")
I$PC        = list(type = "plotOutput")
I$WCWeight  = I$PCWeight
I$getNC     = list(type = "numericInput", title =  "Number of Clusters:" , value = 1, min = 1, max = 20)
I$refClust  = list(type = 'actionButton', title = "Refresh Clustering", offset = 1, width = '80%')
I$WCCluster = list(type = "selectInput" , title = "Cluster:"    , choices = clusters, inline = T, selected = '0')

I$WC$service = 
  "
if (is.null(val$triggerWC)){val$triggerWC = T}
if (val$triggerWC) {val$triggerWC = F}
if (input$WCCluster == '0'){x$plot.wordCloud(weighting = input$WCWeight, package = 'wordcloud2')} else {x$plot.wordCloud(weighting = input$WCWeight, cn = as.integer(input$WCCluster), package = 'wordcloud2')}
"

I$PC$service = "
if (is.null(val$triggerPC)){val$triggerPC = T}
if (val$triggerPC) {val$triggerPC = F}
x$plot.2D(input$PCWeight, input$PCMetric)
"

I$refClust$service = paste(
  "x$clust(as.integer(input$getNC))", 
  "clusters        = c(0, unique(x$data$CLS))",
  "names(clusters) = c('Corpus', paste('Cluster', unique(x$data$CLS)))",
  "updateSelectInput(session, 'WCCluster', choices = clusters, selected = '0')",
  "val$triggerPC = T"
  , sep = "\n")


dash = new('DASHBOARD', items = I, king.layout = list('main'), name = "TEXMIN")

###### Packages: text2vec ======================================
# ext2vec package provides the movie_review dataset. 
# It consists of 5000 movie reviews, each of which is marked as positive or negative. 
# We will also use the data.table package for data wrangling.

# First of all let's split out dataset into two parts - train and test. 
# We will show how to perform data manipulations on train set and then apply exactly the same manipulations on the test set:

library(text2vec)
library(data.table)
data("movie_review")
setDT(movie_review)
setkey(movie_review, id)
set.seed(2016L)
all_ids = movie_review$id
train_ids = sample(all_ids, 4000)
test_ids = setdiff(all_ids, train_ids)
train = movie_review[J(train_ids)]
test = movie_review[J(test_ids)]

# Vectorization:
# To represent documents in vector space, we first have to create mappings from terms to term IDS. 
# We call them terms instead of words because they can be arbitrary n-grams not just single words. 
# We represent a set of documents as a sparse matrix, where each row corresponds to a document and each column corresponds to a term. 
# This can be done in 2 ways: using the vocabulary itself or by feature hashing.

# Vocabulary-based vectorization
# Let's first create a vocabulary-based DTM. 
# Here we collect unique terms from all documents and mark each of them with a unique ID using the create_vocabulary() function. 
# We use an iterator to create the vocabulary.


# define preprocessing function and tokenization function
prep_fun = tolower
tok_fun = word_tokenizer

it_train = itoken(train$review, 
                  preprocessor = prep_fun, 
                  tokenizer = tok_fun, 
                  ids = train$id, 
                  progressbar = FALSE)

vocab = create_vocabulary(it_train)

# What was done here?

# We created an iterator over tokens with the itoken() function. 
# All functions prefixed with create_ work with these iterators. 
# R users might find this idiom unusual, but the iterator abstraction allows us to hide 
# most of details about input and to process data in memory-friendly chunks.
# We built the vocabulary with the create_vocabulary() function.


# Alternatively, we could create list of tokens and reuse it in further steps. 
# Each element of the list should represent a document, and each element should be a character vector of tokens:

train_tokens = train$review %>% prep_fun %>%  tok_fun # This is a list
it_train = itoken(train_tokens, ids = train$id, progressbar = FALSE)

vocab = create_vocabulary(it_train, stopwords)

# ote that text2vec provides a few tokenizer functions (see ?tokenizers). 
# These are just simple wrappers for the base::gsub() function and are not very fast or flexible. 
# If you need something smarter or faster you can use the tokenizers package which will cover most use cases, 
# or write your own tokenizer using the stringi package.

#Now that we have a vocabulary, we can construct a document-term matrix:

vectorizer = vocab_vectorizer(vocab)

t1 = Sys.time()
dtm_train = create_dtm(it_train, vectorizer)
print(difftime(Sys.time(), t1, units = 'sec'))

# http://text2vec.org/vectorization.html



# TF-IDF:
# define tfidf model
tfidf = TfIdf$new()
# fit model to train data and transform train data with fitted model
dtm_train_tfidf = fit_transform(dtm_train, tfidf)
# tfidf modified by fit_transform() call!
# apply pre-trained tf-idf transformation to test data
dtm_test_tfidf  = create_dtm(it_test, vectorizer) %>% 
  transform(tfidf)


# Note that here we first time touched model object in text2vec. 
# At this moment the user should remember several important things about text2vec models:
#   
# Models can be fitted on a given data (train) and applied to unseen data (test)
# Models are mutable - once you will pass model to fit() or fit_transform() function, model will be modifed by it.
# After model is fitted, it can be applied to a new data with fitted_model$transform(new_data) 
# method or equivalent S3 method: transform(new_data, fitted_model).
# You can find more detailed overview of models and models API in a separate vignette.


x = TEXT.MINER(movie_review, text_col = 'review')
D = x$get.dtm()
x$plot.2D()






###### Package: bupar ==============================
### pmap.examples.R ---------------------
library(magrittr)
library(dplyr)
library(gener)

# library(viser)
# library(promer)

# process Map Examples:

patients %>% process_map(type_nodes = performance('absolute'), type_edges = performance('absolute'))


D = read.csv('C:/Nicolas/RCode/projects/abc.hlp.simulation/data/full_discharges_mohammad_Sep_Dec 2016.csv')
D$APPT_I %<>% as.character
D$STUS_C %<>% as.character
D$STRT_S %<>% as.character %>% as.time(target_class = 'POSIXlt') %>% as.POSIXct  

D = D[D$Type == 'PADC',]

x = bupaR::isimple_eventlog(eventlog = D)
x %>% processmapR::process_map

# Translation:

obj = Process() %>% feedEventLog(D, caseID_col = 'APPT_I', skillID_col = 'STUS_C', time_col = 'STRT_S')

# obj = obj %>% addTaskHistory %>% addGraphTables %>% addDiagrammeRGraph

obj %<>% addTaskHistory %>% addGraphTables
obj %>% plot.process(plotter = 'diagramer', direction = 'left.right', node_colors = 'navy')


library(eventdataR)
library(processmapR)
library(edeaR)


obj$bupaobj %>% idle_time("resource", units = "hours")
obj$bupaobj %>% processing_time("activity") %>% head


### eda.examples.R ----------------------
library(bupaR)
library(eventdataR)
library(processmapR)
library(edeaR)
library(magrittr)
library(dplyr)
library(gener)

patients %>%
  idle_time("resource", units = "days")


patients %>% 
  processing_time("activity") %>% plot

patients %>% 
  processing_time("resource") %>% plot




###### Package: flexdashboard ===================================
### galayout.R ------------------
---
  title: "Google Analytics & Highcharter"
runtime: shiny
output: 
  flexdashboard::flex_dashboard:
  favicon: https://www.iconexperience.com/_img/o_collection_png/office/24x24/plain/chart_line.png
css: styles.css
orientation: rows
vertical_layout: fill
social: menu
source_code: embed
theme: lumen
---
  
  ```{r setup, include=FALSE}
# rm(list = ls())
knitr::opts_chunk$set(echo = FALSE)
library("flexdashboard")
library("RGA")
library("htmltools")
library("dplyr")
library("tidyr")
library("purrr")
library("stringr")
library("lubridate")
library("scales")
library("highcharter")
library("DT")
library("viridis")
```

Sidebar {.sidebar}
-----------------------------------------------------------------------
  ```{r}
```

Row
-----------------------------------------------------------------------
  
  ### Sessions  {.value-box}
  ```{r}
```

### Users {.value-box}
```{r}
```

### Page Views {.value-box}
```{r}
```


### Pages per Session {.value-box}
```{r}
```

### Avg Duration of Sessions {.value-box}
```{r}
```

### Bounce Rate {.value-box}
```{r}
```

### Percent New Sessions {.value-box}
```{r}
```


Row {data-height=200}
-----------------------------------------------------------------------
  ### Detailed View 
  ```{r}
```

Row {.tabset .tabset-fade data-height=350}
-----------------------------------------------------------------------
  ### Referral Path
  ```{r}
```

### Referral Source
```{r}
```

### dayOfWeek vs hour
```{r}
```



### Pages
```{r}
```


### Channels
```{r}
```

### Input (Internal)
```{r}
```


###### Package fmsb =========================

### radarchart.R ------------------
# Library
library(fmsb)


# Data must be given as the data frame, where the first cases show maximum.
maxmin <- data.frame(
  total=c(5, 1),
  phys=c(15, 3),
  psycho=c(3, 0),
  social=c(5, 1),
  env=c(5, 1))
# data for radarchart function version 1 series, minimum value must be omitted from above.
RNGkind("Mersenne-Twister")
set.seed(123)
dat <- data.frame(
  total=runif(3, 1, 5),
  phys=rnorm(3, 10, 2),
  psycho=c(0.5, NA, 3),
  social=runif(3, 1, 5),
  env=c(5, 2.5, 4))
dat <- rbind(maxmin,dat)
op <- par(mar=c(1, 2, 2, 1),mfrow=c(2, 2))
radarchart(dat, axistype=1, seg=5, plty=1, vlabels=c("Total\nQOL", "Physical\naspects", 
                                                     "Phychological\naspects", "Social\naspects", "Environmental\naspects"), 
           title="(axis=1, 5 segments, with specified vlabels)", vlcex=0.5)
radarchart(dat, axistype=2, pcol=topo.colors(3), plty=1, pdensity=c(5, 10, 30), 
           pangle=c(10, 45, 120), pfcol=topo.colors(3), 
           title="(topo.colors, fill, axis=2)")
radarchart(dat, axistype=3, pty=32, plty=1, axislabcol="grey", na.itp=FALSE,
           title="(no points, axis=3, na.itp=FALSE)")
radarchart(dat, axistype=1, plwd=1:5, pcol=1, centerzero=TRUE, 
           seg=4, caxislabels=c("worst", "", "", "", "best"),
           title="(use lty and lwd but b/w, axis=1,\n centerzero=TRUE, with centerlabels)")
par(op)




# Library
library(fmsb)

# Create data: note in High school for several students
set.seed(99)
data=as.data.frame(matrix( sample( 0:20 , 15 , replace=F) , ncol=5))
colnames(data)=c("math" , "english" , "biology" , "music" , "R-coding" )
rownames(data)=paste("mister" , letters[1:3] , sep="-")

# To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each topic to show on the plot!
data=rbind(rep(20,5) , rep(0,5) , data)





#==================
# Plot 1: Default radar chart proposed by the library:
radarchart(data)


#==================
# Plot 2: Same plot with custom features
colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9) )
colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4) , rgb(0.7,0.5,0.1,0.4) )
radarchart( data  , axistype=1 , 
            #custom polygon
            pcol=colors_border , pfcol=colors_in , plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
            #custom labels
            vlcex=0.8 
)
legend(x=0.7, y=1, legend = rownames(data[-c(1,2),]), bty = "n", pch=20 , col=colors_in , text.col = "grey", cex=1.2, pt.cex=3)

# Plot3: If you remove the 2 first lines, the function compute the max and min of each variable with the available data:
colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9) )
colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4) , rgb(0.7,0.5,0.1,0.4) )
radarchart( data[-c(1,2),]  , axistype=0 , maxmin=F,
            #custom polygon
            pcol=colors_border , pfcol=colors_in , plwd=4 , plty=1,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="black", cglwd=0.8, 
            #custom labels
            vlcex=0.8 
)
legend(x=0.7, y=1, legend = rownames(data[-c(1,2),]), bty = "n", pch=20 , col=colors_in , text.col = "grey", cex=1.2, pt.cex=3)

###### Pa

###### Folder Docker ==================
### Dockerfile -----------------
FROM docker.artifactory.ai.abc/aiaa/r-essential:3.4.2r1-mran

MAINTAINER Nicolas Berta "Nicolas.Berta@abc.com"
################################################################################

COPY shiny-server-1.5.4.869-amd64.deb /tmp/
  COPY gener_2.4.3.tar.gz /packages/
  COPY myShinyApp/* /projects/
  
  RUN R -e "install.packages('packages/gener_2.4.3.tar.gz', repos = NULL, type = 'source')" && \
R -e "install.packages(c('devtools', 'roxygen2', 'shiny', 'highcharter'), repos = 'http://cran.dev.abc/')"

EXPOSE 8080



### shiny-server.conf -----------------

# Define the user we should use when spawning R Shiny processes
run_as shiny;

# Define a top-level server which will listen on a port
server {
  # Instruct this server to listen on port 80. The app at dokku-alt need expose PORT 80, or 500 e etc. See the docs
  listen 80;
  
  # Define the location available at the base URL
  location / {
    
    # Run this location in 'site_dir' mode, which hosts the entire directory
    # tree at '/srv/shiny-server'
    site_dir /srv/shiny-server;
    
    # Define where we should put the log files for this location
    log_dir /var/log/shiny-server;
    
    # Should we list the contents of a (non-Shiny-App) directory when the user 
    # visits the corresponding URL?
    directory_index on;
  }
}

### shint-server.sh -----------------
#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

exec shiny-server >> /var/log/shiny-server.log 2>&1


########## testidea.R =======================
library(dplyr)

Di = data.frame(Xi = c(1.0, 3.0, 2.0, -1.0, 2.0), Yi = c(1,1,1,0,0)) %>% mutate(i = 1:length(Xi))
Dj = Di %>% select(Xj = Xi, Yj = Yi, j = i)


func = function(r){cbind(t(r), Dj)}
lstm = apply(Di, 1, func)
D    = data.frame()
for (e in lstm) {D = rbind(D, e)}

tbd = D[, c('i','j')] %>% apply(1, sort) %>% t %>% duplicated
D = D[!tbd, ]
D %<>% mutate(ID = ) %>% filter(i != j, Yi == Yj)
####
m = 3
for (p in 1:(m-1)){
  D %<>% mutate(newcol = 2*(Xi^(p + 1) - Xj^(p + 1))*(Xi - Xj))
  names(D)[which(colnames(D) == 'newcol')] <- paste('H', p, sep = '.')
  for(q in 1:(m-1)){
    D %<>% mutate(newcol = 2*(Xi^(p + 1) - Xj^(p + 1))*(Xi^(q + 1) - Xj^(q + 1)))
    names(D)[which(colnames(D) == 'newcol')] <- paste('S', p,q, sep = '.')
  }
}

build.S = function(D){
  d   = colSums(D)
  arr = c()
  for (p in 1:(m-1)){
    for(q in 1:(m-1)){
      colname = paste('S', p,q, sep = '.')
      arr = c(arr, d[colname])
    }
  }
  matrix(arr, m-1, m-1)
}

build.H = function(D){
  d   = colSums(D)
  arr = c()
  for (p in 1:(m-1)){
    colname = paste('H', p, sep = '.')
    arr = c(arr, d[colname])
  }
  arr
}

S = build.S(D)
H = build.H(D)

sum(H * solve(S,H))
