# dashboard.R ----------------------------------------------------------------

# Header
# Filename:      dashboard.R
# Description:   This project, aims to create a ref class containing multiple objects
#                that can issue a shiny dashboard
# Author:        Nima Ramezani
# Email :        nima.ramezani@gmail.com
# Start Date:    22 January 2016
# Last Revision: 16 January 2023
# Version:       2.6.0

# Version History:

# Version   Date                Action
# ---------------------------------------
# 0.6.0     04 July 2016        A number of changes made. Refer to dashboard.R (version 0.6)

# Changes from version 0.5:
# 1- method io.str() transferred from dash.tools.R
# 2- Starting letters of input and cloth types changed to lowercase to match shiny namespace: Example: radioButtons changed to radioButtons
# 3- Valid Container types separated from valid input types
# 4- class properties 'inputs' and 'outputs' consolidated to one single list called 'items' which must be a named list
# 5- layouts must be specified by item names not numbers
# 6- field ID removed and replaced by item name

# 0.6.2     08 September 2016   Argument inline added to checkboxGroupInput.
# 0.6.3     12 October 2016     Wordcloud2 plots added.
# 0.7.0     15 May 2017         tabPanel and many other containers can also get a list as layout
# 0.7.1     15 May 2017         textInput added
# 0.7.2     15 May 2017         d3tfOutput added
# 0.7.3     15 May 2017         container tabsetPanel added
# 0.7.4     15 May 2017         tabPanel container can accept list as layout
# 0.7.4     15 May 2017         tabPanel added as cloth
# 0.7.5     15 May 2017         highcharterOutput added
# 0.7.6     15 May 2017         d3plusOutput added
# 0.7.7     15 May 2017         observers added as list (todo: named list items should become observeEvents)
# 0.7.8     15 May 2017         property 'prescript' added to the class
# 0.8.0     17 May 2017         Start adding syncing feature: property 'object' renamed to sync for synced items.
# 0.9.0     23 May 2017         syncing added for D3TableFilter: reactive list properties 'sync' and 'report' added.
# 0.9.1     31 May 2017         morrisjsOutput added.
# 0.9.2     31 May 2017         coffeewheelOutput added.
# 0.9.3     01 June 2017        cloth column service modified: bug removed for column width and offset!
# 0.9.4     20 July 2017        support('coffeewheel') removed as the widget is embedded
# 0.9.5     25 July 2017        Added re-plotting trigger for D3TableFilter in sync reactives
# 0.9.6     31 July 2017        Added re-plotting trigger for D3TableFilter in sync reactives
# 0.9.7     03 August 2017      Default widths and heights of plot outputs made equal for all plots
# 0.9.8     30 August 2017      actionButton, accept both character and icon types for argument icon
# 1.1.0    11 October 2017     property sessions added to the object. This property is a list and keeps all the sessions
# 1.1.2    11 October 2017     Methods updateItem4Session() and updateItem() addded: Currently works only for type selectInput
# 1.1.3    13 October 2017     pivotTable added to supported plotters using package rpivotTable
# 1.1.4    16 October 2017     Method io.str.clothed() modified: cloth is no longer passed as argument. reads directly from items[[i]]$cloth
# 1.1.5    17 October 2017     rpivotTable renamed to pivot
# 2.0.0     10 November 2017    Fundamental Change to the package: Added shinyjs features: Methods enableItems(), disableItems(), showItems() and hideItems() added!
# 2.0.0     22 November 2017    CSS customized skin style for shinydashboard header added.
# 2.1.1     24 November 2017    actionLink and passwordInput item types added
# 2.1.2     27 November 2017    Simple container 'bag' added to containers.
# 2.1.3     27 November 2017    Type 'loginInput' added.
# 2.1.4     27 November 2017    Function loginVerify() added
# 2.1.5     27 November 2017    Property 'messages' added to class DASHBOARD. It is a named character vector
# 2.2.0     27 November 2017    Fundamental Change: Creating client specific dataset(objects and recative values) for each session
# 2.2.1     27 November 2017    Property 'objects' renamed to 'global', but argument 'objects' still works for method initialize(): replacing value of 'global' by given argument 'objects'
# 2.2.2     27 November 2017    Property 'values' added to class DASHBOARD. Generates and keeps initial values of reactives in 'sync'.
# 2.2.3     27 November 2017    A copy of list 'objects' is generated as initial values for non-reactive list 'local' associated with each session
# 2.2.4     27 November 2017    A copy of list 'values' is generated as initial values for reactive list 'sync' associated with each session
# 2.2.5     29 November 2017    Output item types: downloadButton and downloadLink added.
# 2.2.6     29 November 2017    Argument 'style' added to item types downloadButton and downloadLink
# 2.2.7     06 December 2017    Property 'settings' added to class DASHBOARD. settings item 'saveSession' added and specifies whether the session data needs to be saved after logout and loaded after login by each user.
#                               If settings$saveSession is TRUE, a .rds file for each user is created in the working directory after the user logs out to keep the session data (local and sync). Session data is loaded again when the user logs in.
# 2.2.8     08 December 2017    Property 'global' renamed to 'objects' again
# 2.2.9     08 December 2017    A copy of objects is created in session$userData in each session
# 2.3.0     15 December 2017    Uses encrypted password check from package: bcrypt
# 2.3.1     15 December 2017    Added property 'passEncryption' to the dashboard settings. Specifies how the password should be encrypted. Value 'none' means no encryption is required!
# 2.3.2     19 December 2017    Function loginVerify() modified: Small bug rectified by converting the encrypted password from factor to character
# 2.3.3     16 January 2018     A typo is corrected: Login versification failed converted to login verification failed.
# 2.3.4     29 January 2018     settings property 'keepSessions' added: sessions are kept in memory only if this property is TRUE
# 2.3.5     12 February 2018    settings property 'savePath' added: specify where in the server sessions should be saved
# 2.3.6     02 June 2018        Container 'bsModal' added
# 2.3.7     02 June 2018        arguments 'options' added for dataTableOutput, default for height changed to 'auto' from '400px' for all outputs
# 2.3.9     04 June 2018        Containers 'bsCollapse' and 'bsCollapsePanel' added.
# 2.4.0     04 June 2018        Output widths and heights returned to package defaults.
# 2.4.2     04 June 2018        'tooltip' and 'popover' are now properties which can be attached to each item. Thanks to package 'shinyBS'
# 2.4.3     06 June 2018        'grviz' added to outputs
# 2.4.4     08 June 2018        Arguments 'title', 'choices', 'selected' for all input items, are defined in one place
# 2.4.7     08 June 2018        Input items 'actionbttn', 'actionGroupButtons', 'airDatepickerInput' added
# 2.4.8     08 June 2018        shinyWidget spinners added to plotOutput. Can we add it to other plots as well??
# 2.4.9     15 June 2018        tutorBox added to containers
# 2.5.0     16 June 2018        Arguments 'tutor.lesson', 'tutor.hint' and 'tutor.step' can be used for to all items
# 2.5.1     22 June 2018        Method getItemObject() modified: arguments 'selected' and 'choices' are converted to integer if they are numeric.
# 2.5.2     18 September 2018   Method self.verify() modified: varname passed to function verify() changed
# 2.5.3     26 October 2018     Input item type dateRangeInput modified: All arguments added.
# 2.5.4     29 October 2018     Input item type actionButton modified: argument weight re-added
# 2.5.5     05 November 2018    grviz is now independent
# 2.5.6     06 November 2018    Argument 'width' added for selectInput
# 2.5.7     21 June 2019        Argument 'style' added for box cloth
# 2.5.8     05 January 2023     cloth icon can be of class icon
# 2.5.9     05 January 2023     Argument 'width' added to slider Input
# 2.6.0     16 January 2023     upsetjsOuptput added

support('shiny', 'shinydashboard', 'htmlwidgets')

valid.box.statuses = c('primary', # Blue (sometimes dark blue),
                       'success', # Green
                       'info',    # Blue
                       'warning', # Orange
                       'danger'  # Red
)
valid.colors = c('red', 'yellow', 'aqua', 'blue', 'light-blue', 'green', 'navy', 'teal', 'olive', 'lime', 'orange',
                 'fuchsia', 'purple', 'maroon', 'black', 'navy')

valid.input.types = c("textInput", "radioButtons", "sliderInput", "actionButton", "actionBttn", "actionLink", "checkboxInput", "checkboxGroupInput", "selectInput", "dateInput", "airDatepickerInput",
                      "dateRangeInput", "fileInput", "numericInput", "passwordInput")

valid.output.types = c("uiOutput", "dynamicInput", "loginInput", "plotOutput", "verbatimTextOutput", "textOutput", "imageOutput", "tableOutput", "dataTableOutput", "htmlOutput",
                       "gglVisChartOutput", "rChartsdPlotOutput", 'dygraphOutput', 'plotlyOutput', 'amChartsOutput',
                       "leafletOutput", "infoBoxOutput", "valueBoxOutput", "pivotOutput", "wordcloud2Output", 'bubblesOutput', 'd3plusOutput', 'plotlyOutput',
                       "highcharterOutput", "d3tfOutput", "grvizOutput", "c3Output", "sunburstOutput", "sankeyNetworkOutput", "morrisjsOutput", "upsetjsOutput",
                       "coffeewheelOutput", "billboarderOutput", 'sankeytreeOutput', "rHandsonTableOutput", "downloadButton", "downloadLink", "static")

valid.container.types = c("column", "box", "bag", "fluidPage", "dashboardPage", "tabsetPanel",
                          "sidebarLayout", "navbarPage", "navbarMenu", "tabPanel", "wellPanel",
                          "bsModal", 'bsCollapse', 'bsCollapsePanel', 'actionGroupButtons', 'tutorBox')


valid.cloth.types = c("box", "infoBox", "valueBox", "column", "wellPanel", "tabPanel")

valid.navbar.positions = c("static-top", "fixed-top", "fixed-bottom")

valid.dashboard.skins  = c("blue", "black", "purple", "green", "red", "yellow")

# Returns the number of elements of the given list which are either 'list' or 'character'
nListOrCharItems = function(lst){
  sum = 0
  for (i in lst){
    if (inherits(i, 'list') | inherits(i, 'character')){sum = sum + 1}
  }
  return(sum)
}

# 1: Username and Password don't match
# 2: Username does not exist
loginVerify = function(logtable, username, password, encryption = 'none'){
  username %>% verify('character', lengths = 1, null_allowed = F)
  password %>% verify('character', lengths = 1, null_allowed = F)
  if(username %in% rownames(logtable)){
    switch(encryption,
           'none'   = {if(identical(password, logtable[username,'password'])){res = username} else {res = 1}},
           'bcrypt' = {support('bcrypt'); if(bcrypt::checkpw(password, logtable[username,'password'] %>% as.character)){res = username} else {res = 1}}
    )
  } else {return(2)}
}


#' @exportClass DASHBOARD
DASHBOARD <- setRefClass("DASHBOARD",
                         fields = list(
                           name        = "character",
                           items       = "list",
                           objects     = 'list',
                           values      = "list",
                           sessions    = 'list',
                           settings    = 'list',
                           king.layout = "list",
                           loginTable  = "data.frame",
                           prescript   = 'character',
                           observers   = "character",
                           messages    = "character"
                         ),

                         methods = list(
                           # Class constructor
                           initialize = function(name = "rvis Dashboard", objects = list(), ...){
                             support('shiny')
                             callSuper(...)
                             # Field assignment:
                             name    <<- name
                             objects <<- objects
                             settings$keepSessions   <<- verify(settings$keepSessions,   'logical', domain = c(T,F), default = F, varname = 'settings$keepSessions')
                             settings$saveSession    <<- verify(settings$saveSession,    'logical', domain = c(T,F), default = T, varname = 'settings$saveSession')
                             settings$savePath       <<- verify(settings$savePath,       'character', default = '')
                             settings$passEncryption <<- verify(settings$passEncryption, 'character', default = 'none')
                             settings$tutorMode      <<- F
                             self.verify()
                             if(!('initial'      %in% names(messages))){messages['initial']       <<- ""}
                             if(!('loginFail'    %in% names(messages))){messages['loginFail']     <<- "Login verification failed! Please try again."}
                             if(!('usernameNotFound' %in% names(messages))){messages['usernameNotFound']  <<- "Username not found!"}
                             if(!('loginSuccess' %in% names(messages))){messages['loginSuccess']  <<- "Successful login verification."}
                           },

                           updateItem4Session = function(item, session, ...){
                             verify(item, 'character', domain = names(items), varname = 'item', err_src = 'DASHBOARD Method updateItem4Session')
                             switch(items[[item]]$type,
                                    'selectInput' = {updateSelectInput(session, item, ...)})

                           },

                           # This method updates the given item for all open sessions
                           # You should have set settings property keepSessions to TRUE
                           updateItem = function(item, ...){
                             for (ssn in sessions){
                               if(!ssn$closed){
                                 updateItem4Session(item, ssn, ...)
                               }
                             }
                           },

                           self.verify = function(){
                             verify(items,  'list', varname = 'items')
                             for (i in names(items)){
                               verify(items[[i]], 'list', names_include = c('type'), varname = "items['" %++% i %++% "']")
                               verify(items[[i]]$type, 'character', domain = c(valid.input.types, valid.container.types, valid.output.types), varname = "items['" %++% i %++% "']$type")
                             }
                           },

                           io.str = function(i){
                             assert(i %in% names(items), "Element '" %++% i %++% "' has been mentioned but doesn't exist in the list of elements!", err_src = 'io.str')
                             if (items[[i]]$type %in% valid.output.types){
                               scr = paste0(gndcd(148,21, 9, 200, 112), "[['", i ,"']]$", gndcd(60,142,34,162,18,136))
                             } else if (items[[i]]$type %in% c(valid.input.types, valid.container.types)) {
                               scr = paste0(gndcd(37,9, 25,107,196,130,10,114,142,15,94,88,197),"('", i,"')")
                             } else {return("")}
                             return(scr)
                           },

                           hideItems = function(...){
                             itms = c(...)
                             verify(itms, 'character', domain = names(items), varname = 'Given arguments', null_allowed = F)
                             for (i in itms){
                               if (items[[i]]$type == 'tabPanel'){
                                 slctr = paste0('#', items[[i]]$container, ' li a[data-value = ', items[[i]]$value,']')
                                 shinyjs::hideElement(selector = slctr)} else {shinyjs::hideElement(i)}
                             }
                           },

                           showItems = function(...){
                             itms = c(...)
                             verify(itms, 'character', domain = names(items), varname = 'Given arguments', null_allowed = F)
                             for (i in itms){
                               if (items[[i]]$type == 'tabPanel'){
                                 slctr = paste0('#', items[[i]]$container, ' li a[data-value = ', items[[i]]$value,']')
                                 shinyjs::showElement(selector = slctr)} else {shinyjs::showElement(i)}
                             }
                           },

                           disableItems = function(...){
                             itms = c(...)
                             verify(itms, 'character', domain = names(items), varname = 'Given arguments', null_allowed = F)
                             for (i in itms){
                               if (items[[i]]$type == 'tabPanel'){
                                 slctr = paste0('#', items[[i]]$container, ' li a[data-value = ', items[[i]]$value,']')
                                 shinyjs::disable(selector = slctr)} else {shinyjs::disable(i)}
                             }
                           },


                           enableItems = function(...){
                             itms = c(...)
                             verify(itms, 'character', domain = names(items), varname = 'Given arguments', null_allowed = F)
                             for (i in itms){
                               if (items[[i]]$type == 'tabPanel'){
                                 slctr = paste0('#', items[[i]]$container, ' li a[data-value = ', items[[i]]$value,']')
                                 shinyjs::enable(selector = slctr)} else {shinyjs::enable(i)}
                             }
                           },

                           io.clothed.str = function(i){
                             s = io.str(i)
                             if (is.null(items[[i]]$cloth)){return(s)} else {cloth = items[[i]]$cloth}
                             if(!is.null(items[[i]]$title)){
                               items[[i]]$cloth$title <<- items[[i]]$title
                               cloth$title = items[[i]]$title
                             }
                             verify(cloth, "list")
                             verify(cloth$type, "character", domain = valid.cloth.types)

                             cloth.str = "items[['" %++% i %++% "']]$cloth"

                             switch(cloth$type,
                                    "box"       = {scr = "box("
                                    if (!is.null(cloth$title)){
                                      verify(cloth$title, 'character')
                                      scr = paste0(scr, "title = ", cloth.str, "$title,")
                                    }
                                    if (!is.null(cloth$footer)){
                                      verify(cloth$footer, 'character')
                                      scr = paste0(scr, "title = ", cloth.str, "$title,")
                                    }
                                    if (!is.null(cloth$status)){
                                      verify(cloth$status, 'character', domain = valid.box.statuses)
                                      scr = paste0(scr, "status = ", cloth.str, "$status,")
                                    }
                                    if (!is.null(cloth$solidHeader)){
                                      verify(cloth$solidHeader, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "solidHeader = ", cloth.str, "$solidHeader,")
                                    }
                                    if (!is.null(cloth$background)){
                                      verify(cloth$background, 'character', domain = valid.colors)
                                      scr = paste0(scr, "background = ", cloth.str, "$background,")
                                    }

                                    if (!is.null(cloth$weight)){
                                      verify(cloth$weight, c('numeric', 'integer'), domain = c(1,12))
                                      scr = paste0(scr, "width = ", cloth.str, "$weight,")
                                    }

                                    if (!is.null(cloth$height)){
                                      verify(cloth$height, 'character')
                                      scr = paste0(scr, "height = ", cloth.str, "$height,")
                                    }

                                    if (!is.null(cloth$style)){
                                      verify(cloth$style, 'character')
                                      scr = paste0(scr, "style = ", cloth.str, "$style,")
                                    }

                                    if (!is.null(cloth$collapsible)){
                                      verify(cloth$collapsible, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "collapsible = ", cloth.str, "$collapsible,")
                                    }
                                    if (!is.null(cloth$collapsed)){
                                      verify(cloth$collapsed, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "collapsed = ", cloth.str, "$collapsed,")
                                    }
                                    scr = scr %++% s %++% ")"},
                                    "tabPanel"  = {
                                      scr = "tabPanel(" %++% "title= '" %++%  verify(cloth$title, 'character', varname = "cloth$title") %++% "'"
                                      if (!is.null(cloth$icon)){
                                        verify(cloth$icon, 'character')
                                        scr   = paste0(scr, "icon = shiny::icon(", cloth.str, "$icon),")
                                      }
                                      scr = scr %++% list2Script(cloth, fields_remove = c('type', 'title', 'icon'), arguments = c(weight = 'width'))
                                    },
                                    "infoBox"   = {scr = "infoBox("
                                    ttl = verify(cloth$title, 'character', default = '')
                                    scr = paste0(scr, "title = ", "'", ttl, "', ")

                                    #if (!is.null(cloth$title)){
                                    #verify(cloth$title, 'character')
                                    #scr = paste0(scr, "title = ", cloth.str, "$title,")
                                    #} else {}
                                    if (!is.null(cloth$subtitle)){
                                      verify(cloth$subtitle, 'character')
                                      scr = paste0(scr, "subtitle = ", cloth.str, "$subtitle,")
                                    }
                                    if (!is.null(cloth$icon)){
                                      if(inherits(cloth$icon, 'character')){
                                        scr   = paste0(scr, "icon = shiny::icon(", cloth.str, "$icon),")
                                      } else {
                                        scr   = paste0(scr, "icon = ", cloth.str, "$icon,")
                                      }
                                    }
                                    if (!is.null(cloth$color)){
                                      verify(cloth$color, 'character', domain = valid.colors)
                                      scr = paste0(scr, "color = ", cloth.str, "$color,")
                                    }
                                    if (!is.null(cloth$weight)){
                                      verify(cloth$weight, c('numeric', 'integer'), domain = c(1,12))
                                      scr = paste0(scr, "width = ", cloth.str, "$weight,")
                                    }
                                    if (!is.null(cloth$href)){
                                      verify(cloth$href, 'character')
                                      scr = paste0(scr, "href = ", cloth.str, "$href,")
                                    }
                                    if (!is.null(cloth$fill)){
                                      verify(cloth$fill, 'logical', domain = c(T,F))
                                      scr = paste0(scr, "fill = ", cloth.str, "$fill,")
                                    }
                                    scr = paste0(scr, "value = ", s,")")},
                                    "valueBox"  = {scr = "valueBox("
                                    if (!is.null(cloth$title)){
                                      verify(cloth$subtitle, 'character')
                                      scr = paste0(scr, "subtitle = ", cloth.str, "$title,")
                                    } else {scr = paste0(scr, "subtitle = '',")}
                                    if (!is.null(cloth$icon)){
                                      verify(cloth$icon, 'character')
                                      scr   = paste0(scr, "icon = shiny::icon(", cloth.str, "$icon),")
                                    }
                                    if (!is.null(cloth$color)){
                                      verify(cloth$color, 'character', domain = valid.colors)
                                      scr = paste0(scr, "color = ", cloth.str, "$color,")
                                    }
                                    if (!is.null(cloth$weight)){
                                      verify(cloth$weight, c('numeric', 'integer'), domain = c(1,12))
                                      scr = paste0(scr, "width = ", cloth.str, "$weight,")
                                    }
                                    if (!is.null(cloth$href)){
                                      verify(cloth$href, 'character')
                                      scr = paste0(scr, "href = ", cloth.str, "$href,")
                                    }
                                    scr = paste0(scr, "value = ", s,")")},
                                    "column"    = {
                                      args = list2Script(cloth, fields = c('offset', 'align'))
                                      scr  = "column(" %>% paste0(chif(is.null(cloth$weight %>% verify(c('numeric', 'integer'), domain = c(1,12))), "width = 12,", paste0("width = ", cloth.str, "$weight,")),
                                                                  args, chif(is.empty(args), '', ", "), s %++% ")")
                                    },
                                    "wellPanel" = {scr = paste0("wellPanel(", s, ")")}
                             )
                             return(scr)
                           },

                           # only row layout is supported for the sidebar
                           # lst.side is a vector of numerics
                           # lst.main is a vector of numerics
                           layscript.sidebar = function(s = '', lst.side, lst.main){
                             s = s %++% gndcd(144,148,150,9,8,39,184,3,11,97,60,19,196) %++% "("

                             N.side = length(lst.side)
                             N.main = length(lst.main)

                             if (N.side > 0){
                               s = s %++% gndcd(112,70,115,130,8,170,1,179,39,27,29,199) %++% "("
                               s = insert.io.strs(s, lst.side)
                               s = s %++% "),"
                             }

                             if (N.main > 0){
                               s = s %++% gndcd(43,11,118,158,32,170,14,9,64) %++% "("
                               s = insert.io.strs(s, lst.main)
                               s = s %++% ")"
                             }
                             s = s %++% ")"
                             return (s)
                           },

                           layscript.dashboard = function(s = '', lst.head, lst.side, lst.body, header.title = NULL, header.title.width = NULL, sidebar.width = NULL, skin = 'blue',
                                                          header.title.color = NULL, header.title.background.color = NULL, header.title.hover.color = NULL, header.title.hover.background.color = NULL,
                                                          header.title.font = NULL, header.title.font.weight = NULL, header.title.font.size = NULL,
                                                          header.title.hover.font = NULL, header.title.hover.font.weight = NULL, header.title.hover.font.size = NULL){
                             N.head = length(lst.head)
                             N.side = length(lst.side)
                             N.body = length(lst.body)

                             s = s %++% gndcd(7,170,144,51,8,12,39,31,115,44,162,39,150,130,184) %++% "("
                             if (!is.null(header.title)){
                               s = paste0(s, "title = '", header.title, "'")
                               if (N.head > 0 | !is.null(header.title.width)){s = s %++% ', '}
                             }

                             if (!is.null(header.title.width)){
                               s = paste0(s, "titleWidth = ", header.title.width)
                               if (N.head > 0){s = s %++% ', '}
                             }

                             if (N.head > 0){s = insert.io.strs(s, lst.head)} else if (is.null(header.title) & is.null(header.title.width)){s = s %++% "disable = TRUE"}
                             s = s %++% "),"

                             s = s %++% gndcd(115,2,98,38,142,143,170,1,20,131,4,150.94,29,190,11,110) %++% "("
                             if (!is.null(sidebar.width)){s %<>% paste0('width = ', sidebar.width, ', ')}
                             if (N.side > 0){s = insert.io.strs(s, lst.side)} else {s = s %++% "disable = TRUE"}
                             s = s %++% "),"

                             s %<>% paste0(gndcd(150,11,112,86,8,60,39,1,150,48,143,115,138), "(tags$head(tags$style(HTML('",
                                           skin.style.css(skin, header.title.font, header.title.font.weight, header.title.font.size, header.title.color, header.title.background.color, header.title.hover.font, header.title.hover.font.weight, header.title.hover.font.size , header.title.hover.color, header.title.hover.background.color),
                                           "')))")
                             if(!is.empty(lst.body)){s = s %++% ", "}
                             s = insert.io.strs(s, lst.body)
                             s = s %++% ")"
                             return (s)
                           },

                           layscript = function(layout){
                             # todo: verify layout is a list of characters
                             N.item = length(layout)
                             s = ''
                             for (i in sequence(N.item)){
                               s = s %++% "getItemObject('" %++% layout[[i]] %++% "'"
                               if (i < N.item){s = s %++% ','}
                             }
                             return(s)
                           },

                           layscript.RCPanel = function(s = "", lst, title = '', is.row = T, col.panel = F){
                             N.items = nListOrCharItems(lst)
                             N.list  = length(lst)
                             for (i in sequence(N.list)){
                               its.list = inherits(lst[[i]], 'list')
                               its.char = inherits(lst[[i]], 'character')
                               if (its.list | its.char){
                                 if (is.row){s = paste0(s, gndcd(33,55,154,4, 150,119,143,28) %++% "(")} else {
                                   if (its.list){
                                     if (is.null(lst[[i]]$weight)){
                                       ww = floor(12/N.items)
                                     } else {ww = lst[[i]]$weight}
                                     if (is.null(lst[[i]]$offset)){
                                       ofst = 0
                                     } else {ofst = lst[[i]]$offset}
                                   } else if (its.char) {
                                     wght = items %>% list.extract.field(lst[[i]], field_name = 'weight')
                                     ww   = chif(is.empty(wght), floor(12/N.items), wght %>% mean(na.rm = T) %>% floor)
                                     ofst = items %>% list.extract.field(lst[[i]], field_name = 'offset')
                                     if (is.empty(ofst)){
                                       ofst = 0
                                     } else {
                                       ofst = ofst %>% mean(na.rm = T) %>% floor
                                     }
                                   }

                                   s = paste0(s, gndcd(88, 60, 64, 19, 10, 27) %++% "(" %++% gndcd(12, 33, 151, 112, 162, 196) %++%  " = ", as.character(ofst), ", ")
                                   s = paste0(s, "width  = ",as.character(ww), ", ")
                                   if (col.panel){s = paste0(s, 'wellPanel(')}
                                 }

                                 if (its.list){s = layscript.RCPanel(s, lst[[i]], is.row = !is.row, col.panel = col.panel)}
                                 else if (its.char) {s = insert.io.strs(s, lst[[i]])}
                                 s = paste0(s, ')')
                                 if (col.panel & !is.row){s = paste0(s, ')')}
                                 s = paste0(s, ',')
                               }
                             }
                             NC = nchar(s)
                             if(substr(s, NC, NC) == ','){s %<>% substr(1,NC - 1)}
                             return (s)
                           },

                           insert.io.strs = function(s, vct){
                             # vct must be a vector of numerics or characters
                             M = length(vct)
                             for (j in sequence(M)){
                               s = s %++% io.clothed.str(vct[j])
                               if (j < M){s = s %++% ','}
                             }
                             return(s)
                           },

                           getItemObject = function(i){
                             if (is.null(items[[i]]$object)){
                               if (is.null(items[[i]]$type)){return(NULL)}
                               if(items[[i]]$type %in% valid.input.types){
                                 lbl = items[[i]]$title %>% verify('character', default = "", varname = "items[['" %++% i %++% "']]$title")
                               }
                               if(items[[i]]$type %in% c('actionButton', 'actionBttn', 'actionLink')){
                                 if(is.null(items[[i]]$icon)){icn = NULL} else if (items[[i]]$icon %>% inherits('character')){icn = items[[i]]$icon %>% icon} else {icn = items[[i]]$icon}
                               }
                               if(items[[i]]$type %in% c('radioButtons', 'checkboxGroupInput', 'selectInput')) {
                                 chs = items[[i]]$choices %>% verify(c('character', 'factor', 'logical', 'integer', 'numeric'), varname = "items[['" %++% i %++% "']]$choices")
                                 slc = items[[i]]$selected %>% verify(c('character', 'factor', 'logical', 'integer', 'numeric'), varname = "items[['" %++% i %++% "']]$selected")
                                 if(inherits(chs, 'numeric')){chs %<>% as.integer}
                                 if(inherits(slc, 'numeric')){slc %<>% as.integer}
                               }
                               switch(items[[i]]$type,
                                      "radioButtons"   = {
                                        inl  = verify(items[[i]]$inline, 'logical', varname = "items[['" %++% i %++% "']]$inline", default = F)
                                        assert(length(chs) > 1, "radioButtons input must have at least two choices!")
                                        # if (is.null(names(chs))){names(chs) = chs}
                                        obj = radioButtons(i, label = lbl, choices = chs, selected = slc, inline = inl, width = items[[i]]$width)},
                                      "textInput"      = {
                                        obj = textInput(i,
                                                        label = lbl,
                                                        value = items[[i]]$value %>% verify('character', default = "", varname = "items[['" %++% i %++% "']]$value"),
                                                        width = items[[i]]$width %>% verify('character', varname = "items[['" %++% i %++% "']]$width"),
                                                        placeholder = items[[i]]$placeholder %>% verify('character', varname = "items[['" %++% i %++% "']]$placeholder"))},
                                      "passwordInput"  = {
                                        obj = passwordInput(i,
                                                            label = lbl,
                                                            value = items[[i]]$value %>% verify('character', default = "", varname = "items[['" %++% i %++% "']]$value"),
                                                            width = items[[i]]$width %>% verify('character', varname = "items[['" %++% i %++% "']]$width"),
                                                            placeholder = items[[i]]$placeholder %>% verify('character', varname = "items[['" %++% i %++% "']]$placeholder"))},
                                      "sliderInput"    = {
                                        mn = items[[i]]$min   %>% verify(c('numeric', 'integer', 'logical', valid.time.classes), varname = "items[['" %++% i %++% "']]$min"  , default = 0)
                                        mx = items[[i]]$max   %>% verify(c('numeric', 'integer', 'logical', valid.time.classes), varname = "items[['" %++% i %++% "']]$max"  , default = 1, domain = c(mn, Inf))
                                        vl = items[[i]]$value %>% verify(c('numeric', 'integer', 'logical', valid.time.classes), varname = "items[['" %++% i %++% "']]$value", default = 0, domain = c(mn, mx))
                                        an = items[[i]]$animate %>% verify(c("list", "logical"), default = F)

                                        # obj = do.call(items[[i]]$type, args = items[[i]] %>% list.remove('type'))
                                        obj = sliderInput(i, label = lbl, min = mn, max = mx, value = vl, step = items[[i]]$step,
                                                          sep  = items[[i]]$sep, pre = items[[i]]$pre, post = items[[i]]$post, 
                                                          timeFormat = items[[i]]$timeFormat, 
                                                          width = items[[i]]$width, animate = an)},
                                      "actionButton"   = {
                                        obj = actionButton(i, label = lbl, icon = icn, width = items[[i]]$width) %>% buildStyle(inline = items[[i]]$inline, vertical_align = items[[i]]$vertical_align, float = items[[i]]$float, width = items[[i]]$width)},
                                      "actionBttn"     = {
                                        support('shinyWidgets')
                                        stl = items[[i]]$style  %>% verify('character', domain = c('simple', 'bordered', 'minicolasl', 'stretch', 'jelly', 'gradient', 'fill', 'material-circle', 'material-flat', 'pill', 'float', 'unite'), default = 'unite', varname = "items[['" %++% i %++% "']]$style")
                                        sts = items[[i]]$status %>% verify('character', domain = c('default', 'primary', 'warning', 'danger', 'success', 'royal'), default = 'unite', varname = "items[['" %++% i %++% "']]$status")
                                        sz  = items[[i]]$size   %>% verify('character', domain = c('xs', 'sm', 'md', 'lg'), default = 'md', varname = "items[['" %++% i %++% "']]$size")
                                        blk = items[[i]]$fullwidth   %>% verify('logical', domain = c(T, F), default = F, varname = "items[['" %++% i %++% "']]$fullwidth")
                                        nol = items[[i]]$no_outline  %>% verify('logical', domain = c(T, F), default = T, varname = "items[['" %++% i %++% "']]$no_outline")
                                        obj = actionBttn(i, label = lbl, icon = icn, style= stl, color = sts, size = sz, block = blk, no_outline = nol)},
                                      "actionGroupButtons"     = {
                                        support('shinyWidgets')
                                        ids = items[[i]]$inputIds   %>% verify('character', varname = "items[['" %++% i %++% "']]$inputIds", null_allowed = F)
                                        lbl = items[[i]]$labels     %>% verify(c('character', 'list'), varname = "items[['" %++% i %++% "']]$labels", lengths = length(ids), default = 'Button' %>% paste(sequence(length(ids))))
                                        sts = items[[i]]$status     %>% verify('character', domain = c('default', 'primary', 'warning', 'danger', 'success', 'royal'), default = 'default', varname = "items[['" %++% i %++% "']]$status")
                                        sz  = items[[i]]$size       %>% verify('character', domain = c('xs', 'sm', 'normal', 'lg'), default = 'normal', varname = "items[['" %++% i %++% "']]$size")
                                        inl = items[[i]]$inline     %>% verify('logical', domain = c(T, F), default = T, varname = "items[['" %++% i %++% "']]$inline")
                                        fwt = items[[i]]$fullwidth  %>% verify('logical', domain = c(T, F), default = F, varname = "items[['" %++% i %++% "']]$fullwidth")
                                        obj = actionGroupButtons(ids, labels = lbl, status = sts, size = sz, direction = chif(inl, 'horizontal', 'vertical'), fullwidth = fwt)},

                                      "actionLink"     = {obj = actionLink(i, label = lbl, icon = icn)},
                                      "checkboxInput"  = {
                                        vlu = verify(items[[i]]$value, 'logical', domain = c(T,F), varname = "items[['" %++% i %++% "']]$value", default = F)
                                        obj = checkboxInput(i, label = lbl, value = vlu) %>% buildStyle(inline = items[[i]]$inline, vertical_align = items[[i]]$vertical_align, float = items[[i]]$float)},
                                      "checkboxGroupInput" = {
                                        inl  = verify(items[[i]]$inline, 'logical', domain = c(T,F), varname = "items[['" %++% i %++% "']]$inline", default = F)
                                        obj  = checkboxGroupInput(i, label = lbl, choices = chs, selected = slc, inline = inl, width = items[[i]]$width, choiceNames = items[[i]]$choiceNames, choiceValues = items[[i]]$choiceValues)},
                                      "selectInput"    = {
                                        mltpl = verify(items[[i]]$multiple, 'logical', varname = "items[['" %++% i %++% "']]$multiple", default = F)
                                        slctz = verify(items[[i]]$selectize, 'logical', varname = "items[['" %++% i %++% "']]$selectize", default = T)
                                        obj   = selectInput(i, label = lbl, choices = chs, selected = slc, multiple = mltpl, selectize = slctz, width = items[[i]]$width)},
                                      "dateInput"      = {obj = dateInput(i, label = lbl, value = items[[i]]$value, min = items[[i]]$min, max = items[[i]]$max)},
                                      # todo: change input name for airDatepickerInput! define separate input types like monthInput, yearInput, monthRangeInput, dateTimeInput, ...
                                      "airDatepickerInput" = {
                                        scr = "airDatepickerInput(i, " %>%
                                          paste(list2Script(items[[i]], fields = c(title = 'label', 'value', 'multiple', 'range', 'timePicker', 'separator', 'placeholder', 'dateFormat', min = 'minDate', max = 'maxDate', 'disabledDates', 'view', 'minView', 'monthsField', 'clearButton', 'todayButton', 'autoClose', 'timepickerOpts', 'position', 'update_on', 'addon', 'language', 'inline', 'width')), ")")
                                        obj = eval(parse(text = scr))
                                      },
                                      "dateRangeInput" = {
                                        obj = dateRangeInput(i, label = lbl,
                                                             start     = items[[i]]$start, end = items[[i]]$end, min = items[[i]]$min, max = items[[i]]$max,
                                                             format    = items[[i]]$format %>% verify('character', default = "yyyy-mm-dd"),
                                                             startview = items[[i]]$startview %>% verify('character', domain = c("month", "year", "decade"), default = "month"), weekstart = 0,
                                                             language  = "en", separator = " to ", width = items[[i]]$width,
                                                             autoclose = items[[i]]$autoclose %>% verify('logical', domain = c(T, F), default = T))},
                                      "fileInput"      = {
                                        mltpl = verify(items[[i]]$multiple   , 'logical'  , varname = "items[['" %++% i %++% "']]$multiple", default = F)
                                        btlbl = verify(items[[i]]$buttonLabel, 'character', varname = "items[['" %++% i %++% "']]$buttonLabel", default = "Browse...")
                                        phldr = verify(items[[i]]$placeholder, 'character', varname = "items[['" %++% i %++% "']]$placeholder", default = "No file selected")
                                        obj   = fileInput(i, label = lbl, multiple = mltpl, accept = items[[i]]$accept, width = items[[i]]$width, buttonLabel = btlbl, placeholder = phldr)},
                                      "numericInput"   = {
                                        if (is.null(items[[i]]$step)){items[[i]]$step <<- NA}
                                        if (is.null(items[[i]]$max)){items[[i]]$max <<- NA}
                                        if (is.null(items[[i]]$min)){items[[i]]$min <<- NA}
                                        obj = numericInput(i, label = lbl, value = items[[i]]$value, step = items[[i]]$step, min = items[[i]]$min, max = items[[i]]$max)},

                                      "column" = {
                                        scr = "column("
                                        wdth = verify(items[[i]]$weight, 'numeric' , default = 12)
                                        ofst = verify(items[[i]]$offset, 'numeric', default = 0)
                                        scr = paste0(scr,'width = ', wdth, ', offset = ',ofst, ',')
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %++% ")"
                                        obj = eval(parse(text = scr))},

                                      "wellPanel" = {
                                        scr = "wellPanel("
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %++% ")"
                                        obj = eval(parse(text = scr))},

                                      "box" = {
                                        scr = "shinydashboard::box("
                                        wdth = verify(items[[i]]$weight, 'numeric' , default = 12, varname    = paste0("items[['",i,"']]$weight"))
                                        ttle = verify(items[[i]]$title, 'character' , default = '', varname  = paste0("items[['",i,"']]$title"))
                                        fotr = verify(items[[i]]$footer, 'character' , default = '', varname = paste0("items[['",i,"']]$footer"))
                                        stus = verify(items[[i]]$status, 'character' , domain = valid.box.statuses, varname = paste0("items[['",i,"']]$status"))
                                        shdr = verify(items[[i]]$solidHeader, 'logical' , default = 'F', domain = c(T, F), varname = paste0("items[['",i,"']]$solidHeader"))
                                        bgrd = verify(items[[i]]$background, 'character' , domain = valid.colors, default = 'blue', varname = paste0("items[['",i,"']]$background"))
                                        cpbl = verify(items[[i]]$collapsible, 'logical' , default = 'F', domain = c(T, F), varname = paste0("items[['",i,"']]$collapsible"))
                                        cpsd = verify(items[[i]]$collapsed, 'logical' , default = 'F', domain = c(T, F), varname = paste0("items[['",i,"']]$collapsed"))

                                        if(!is.null(stus)){scr = paste0(scr,"status = '", stus, "',")}
                                        scr = paste0(scr,'width = ', wdth, ',')
                                        scr = paste0(scr,"title = '", ttle, "',")
                                        scr = paste0(scr,"footer = '", fotr, "',")
                                        scr = paste0(scr,"background = '", bgrd, "',")
                                        if (shdr){scr = paste0(scr,'solidHeader = T,')}
                                        if (cpbl){scr = paste0(scr,'collapsible = T,')}
                                        if (cpsd){scr = paste0(scr,'collapsed = T,')}

                                        # list2Script(items[[i]], fields_remove = c('type'))

                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %++% ")"
                                        obj = eval(parse(text = scr))
                                      },

                                      "bag" = {obj = eval(parse(text = "div(" %>% insert.io.strs(items[[i]]$layout) %>% paste0(")")))},

                                      "fluidPage" = {
                                        scr = "fluidPage("
                                        if (!is.null(items[[i]]$title)){scr = paste0(scr, "titlePanel('", items[[i]]$title, "', windowTitle = '", items[[i]]$wintitle, "'),")}
                                        cpl = verify(items[[i]]$col.framed, 'logical', varname = paste0("items[['",i,"']]$col.framed"), domain = c(T,F), default = F)
                                        scr = layscript.RCPanel(s = scr, lst = items[[i]]$layout, col.panel = cpl)
                                        scr = scr %++% ')'
                                        obj = eval(parse(text = scr))},

                                      "dashboardPage" = {
                                        scr = "dashboardPage("
                                        ttl = verify(items[[i]]$title,  'character', varname = paste0("items[['",i,"']]$title"))
                                        skn = verify(items[[i]]$skin, 'character', varname = paste0("items[['",i,"']]$skin"), domain = valid.dashboard.skins)
                                        if (!is.null(ttl)){scr %<>% paste0("title = '", ttl, "', ")}
                                        if (!is.null(skn)){scr %<>% paste0("skin  = '", skn, "', ")}
                                        scr %<>% layscript.dashboard(lst.head = items[[i]]$layout.head, lst.side = items[[i]]$layout.side, lst.body = items[[i]]$layout.body, header.title = items[[i]]$header.title, header.title.width = items[[i]]$header.title.width, sidebar.width = items[[i]]$sidebar.width,
                                                                     header.title.color = items[[i]]$header.title.color, header.title.background.color = items[[i]]$header.title.background.color, header.title.hover.color = items[[i]]$header.title.hover.color, header.title.hover.background.color = items[[i]]$header.title.hover.background.color,
                                                                     header.title.font = items[[i]]$header.title.font, header.title.font.weight = items[[i]]$header.title.font.weight, header.title.font.size = items[[i]]$header.title.font.size,
                                                                     header.title.hover.font = items[[i]]$header.title.hover.font, header.title.hover.font.weight = items[[i]]$header.title.hover.font.weight, header.title.hover.font.size = items[[i]]$header.title.hover.font.size)
                                        scr = scr %++% ')'
                                        obj = eval(parse(text = scr))},

                                      "tutorBox" = {
                                        scr = "rintrojs::introBox(" %>% insert.io.strs(items[[i]]$layout) %>%
                                          paste0(", ", list2Script(items[[i]],
                                                                   fields    = c('tutor.lesson', 'tutor.step', 'tutor.hint'),
                                                                   arguments = c(tutor.lesson = 'data.intro', tutor.step = 'data.step', tutor.hint = 'data.hint')), ")")
                                        obj = eval(parse(text = scr))
                                      },

                                      "sidebarLayout" = {
                                        scr = "fluidPage("
                                        if (!is.null(items[[i]]$title)){scr = paste0(scr, "titlePanel('", items[[i]]$title, "', windowTitle = '", items[[i]]$wintitle, "'),")}
                                        scr = layscript.sidebar(s = scr, lst.side = items[[i]]$layout.side, lst.main = items[[i]]$layout.main)
                                        scr = scr %++% ')'
                                        obj = eval(parse(text = scr))},

                                      "navbarPage" = {  # todo: write specific layscript for this type of container so that it creates tabPanels and menus based on a layout of type list
                                        scr = "navbarPage("
                                        if (is.null(items[[i]]$title)){items[[i]]$title <<- ''}
                                        scr = scr %++% "title = '" %++% verify(items[[i]]$title, 'character')  %++% "', "
                                        if (!is.null(items[[i]]$position)){scr = scr %++% "position = '" %++% verify(items[[i]]$position, 'character', domain = valid.navbar.positions)  %++% "', "}
                                        if (!is.null(items[[i]]$header)){scr = scr %++% "header = '" %++% verify(items[[i]]$header, 'character')  %++% "', "}
                                        if (!is.null(items[[i]]$footer)){scr = scr %++% "footer = '" %++% verify(items[[i]]$footer, 'character')  %++% "', "}
                                        if (!is.null(items[[i]]$wintitle)){scr = scr %++% "windowTitle = '" %++% verify(items[[i]]$wintitle, 'character')  %++% "', "}
                                        if (!is.null(items[[i]]$icon)){scr = scr %++% "icon = icon('" %++% verify(items[[i]]$icon, 'character')  %++% ")', "}
                                        if (!is.null(i)){scr = scr %++% "id = '" %++% verify(i, 'character')  %++% "', "}
                                        clp = verify(items[[i]]$collapsible, 'logical', domain = c(T,F), default = F)
                                        fld = verify(items[[i]]$fluid, 'logical', domain = c(T,F), default = T)
                                        if (clp) {scr = scr %++% "collapsible = TRUE, "}
                                        if (!fld){scr = scr %++% "fluid = FASLE, "}
                                        if (!is.null(items[[i]]$theme)){scr = scr %++% "theme = '" %++% verify(items[[i]]$theme, 'character')  %++% "', "}
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %++% ")"
                                        obj = eval(parse(text = scr))},

                                      "navbarMenu" = {
                                        scr = "navbarMenu("
                                        if (is.null(items[[i]]$title)){items[[i]]$title <<- ''}
                                        scr = scr %++% "title = '" %++% verify(items[[i]]$title, 'character')  %++% "', "
                                        if (!is.null(items[[i]]$icon)){scr = scr %++% "icon = icon('" %++% verify(items[[i]]$icon, 'character')  %++% ")', "}
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %++% ")"
                                        obj = eval(parse(text = scr))},

                                      "bsModal" = {
                                        scr = items[[i]]$type %>%
                                          paste0("(id = '", i, "' ,", list2Script(items[[i]], fields = c('title', 'trigger', 'size'))) %>% paste0(",") %>%
                                          insert.io.strs(items[[i]]$layout) %>% paste0(")")
                                        obj = eval(parse(text = scr))
                                      },

                                      "bsCollapse" = {
                                        scr = items[[i]]$type %>%
                                          paste0("(id = '", i, "' ,", list2Script(items[[i]], fields = c('multiple', 'open'))) %>% paste0(",") %>%
                                          insert.io.strs(items[[i]]$layout) %>% paste0(")")
                                        obj = eval(parse(text = scr))
                                      },

                                      "bsCollapsePanel" = {
                                        scr = items[[i]]$type %>%
                                          paste0("(", list2Script(items[[i]], fields = c('title', 'value', 'style'))) %>% paste0(",") %>%
                                          insert.io.strs(items[[i]]$layout) %>% paste0(")")
                                        obj = eval(parse(text = scr))
                                      },

                                      "tabsetPanel" = {
                                        scr = "tabsetPanel("
                                        if (!is.null(items[[i]]$selected)){scr %<>% paste0("selected = '", items[[i]]$selected %>% verify('character', varname = 'selected'), "', ")}
                                        if (!is.null(items[[i]]$shape)){scr %<>% paste0("type = '", items[[i]]$shape %>% verify('character', domain = c("tabs", "pills"), varname = 'shape'), "', ")}
                                        scr = insert.io.strs(scr, items[[i]]$layout)
                                        scr = scr %++% ")"
                                        obj = eval(parse(text = scr))},

                                      "tabPanel" = {
                                        scr = "tabPanel("
                                        scr = scr %++% "id = '" %++% i %++% "', "
                                        if (is.null(items[[i]]$title)){items[[i]]$title <<- i}
                                        if (is.null(items[[i]]$value)){items[[i]]$value <<- i}
                                        scr = scr %++% "title = '" %++% verify(items[[i]]$title, 'character')  %++% "', "
                                        scr = scr %++% "value = '" %++% verify(items[[i]]$value, 'character')  %++% "', "
                                        if (!is.null(items[[i]]$icon)){scr = scr %++% "icon = icon('" %++% verify(items[[i]]$icon, 'character')  %++% ")', "}
                                        cpl = verify(items[[i]]$col.framed, 'logical', varname = paste0("items[['",i,"']]$col.framed"), domain = c(T,F), default = F)
                                        if      (inherits(items[[i]]$layout, 'list')){scr = layscript.RCPanel(s = scr, lst = items[[i]]$layout, col.panel = cpl)}
                                        else if (inherits(items[[i]]$layout, 'character')){scr = insert.io.strs(scr, items[[i]]$layout)} else {stop("Invalid type for argument 'layout'!")}

                                        scr = scr %++% ")"
                                        obj = eval(parse(text = scr))}

                               )
                               if(!is.null(items[[i]]$tutor.lesson)){
                                 settings$tutorMode <<- T
                                 if(items[[i]]$type != 'tutorBox'){
                                   obj %<>% rintrojs::introBox(
                                     data.intro = items[[i]]$tutor.lesson %>% verify('character') %>% paste(collapse = '\n'),
                                     data.hint  = items[[i]]$tutor.hint %>% verify('character') %>% paste(collapse = '\n'),
                                     data.step  = items[[i]]$tutor.step)
                                 }
                               }
                               return(obj)
                             } else {return(items[[i]]$object)}
                           },

                           dashboard.ui = function(){
                             # Determine container name of each item and put it in property 'container':
                             for (i in names(items)){
                               if (items[[i]]$type %in% valid.container.types){
                                 members = character()
                                 if(!is.null(items[[i]]$layout.side)){
                                   members = c(members, items[[i]]$layout.side %^% names(items))
                                 }
                                 if(!is.null(items[[i]]$layout.main)){
                                   members = c(members, items[[i]]$layout.main %^% names(items))
                                 }

                                 if(!is.null(items[[i]]$layout)){
                                   if(inherits(items[[i]]$layout, 'list')){members = items[[i]]$layout %>% list.flatten %>% as.character %>% intersect(names(items))}
                                   else {members = items[[i]]$layout %^% names(items)}
                                 }

                                 for (j in members){items[[j]]$container <<- i}
                               }
                             }
                             # Important TODO: check and return error if any dynamic item is used twice. This leads to all services being inactivated!!!!

                             # Add tooltips and popovers if there are any:
                             for (i in names(items)){
                               # tooltips
                               if(!is.null(items[[i]]$tooltip)){
                                 tooltip.name = paste(i, 'tooltip', sep = '.')
                                 items[[tooltip.name]] <<- list(type = 'static',
                                                                object = bsTooltip(id = i,
                                                                                   title     = items[[i]]$tooltip %>% verify('character') %>% paste(collapse = '\n'),
                                                                                   placement = items[[i]]$tooltip.placement %>% verify('character', lengths = 1, domain = c('top', 'bottom', 'left', 'right')   , default = 'bottom'),
                                                                                   trigger   = items[[i]]$tooltip.trigger   %>% verify('character', lengths = 1, domain = c('hover', 'focus', 'click', 'manual'), default = 'hover'),
                                                                                   options   = items[[i]]$tooltip.options))
                                 if(items[[items[[i]]$container]]$type %in% c('sidebarLayout', 'dashboardPage')){
                                   if(i %in% items[[items[[i]]$container]]$layout.side){
                                     items[[items[[i]]$container]]$layout.side     <<- c(items[[items[[i]]$container]]$layout.side, tooltip.name)}
                                   else {items[[items[[i]]$container]]$layout.main <<- c(items[[items[[i]]$container]]$layout.main, tooltip.name)}
                                 } else {items[[items[[i]]$container]]$layout      <<- c(items[[items[[i]]$container]]$layout,      tooltip.name)}
                                 # todo: what about layout.head? only for containers of type 'dashboardPage'
                               }

                               # popovers /commented because HTML does not work with with bsPopover in the UI
                               # if(!is.null(items[[i]]$popover)){
                               #   popover.name = paste(i, 'popover', sep = '.')
                               #   items[[popover.name]] <<- list(type = 'static',
                               #      object = bsPopover(id = i,
                               #        title     = items[[i]]$popover.title %>% verify('character', lengths = 1),
                               #        content   = items[[i]]$popover %>% verify('character') %>% paste(collapse = '\n'),
                               #        placement = items[[i]]$popover.placement %>% verify('character', lengths = 1, domain = c('top', 'bottom', 'left', 'right')   , default = 'bottom'),
                               #        trigger   = items[[i]]$popover.trigger   %>% verify('character', lengths = 1, domain = c('hover', 'focus', 'click', 'manual'), default = 'hover'),
                               #        options   = items[[i]]$popover.options))
                               #   if(items[[items[[i]]$container]]$type %in% c('sidebarLayout', 'dashboardPage')){
                               #     if(i %in% items[[items[[i]]$container]]$layout.side){
                               #       items[[items[[i]]$container]]$layout.side     <<- c(items[[items[[i]]$container]]$layout.side, popover.name)}
                               #     else {items[[items[[i]]$container]]$layout.main <<- c(items[[items[[i]]$container]]$layout.main, popover.name)}
                               #   } else {items[[items[[i]]$container]]$layout      <<- c(items[[items[[i]]$container]]$layout,      popover.name)}
                               # }

                             }

                             # Create output objects:
                             for (i in names(items)){
                               # Outputs:
                               if (items[[i]]$type %in% valid.output.types){
                                 if (!is.null(items[[i]]$type)){
                                   fields = names(items[[i]])
                                   if(items[[i]]$type %in% c('plotOutput', 'd3tfOutput', 'amChartsOutput', 'dygraphOutput', 'leafletOutput', 'wordcloud2Output', 'plotlyOutput', 'highcharterOutput', 'morrisjsOutput', 'billboarderOutput', 'sankeytreeOutput')){
                                     wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%"  , varname = "items[['" %++% i %++% "']]$width")
                                     hght = items[[i]]$height %>% verify('character', lengths = 1, default = "400px" , varname = "items[['" %++% i %++% "']]$height")
                                   }

                                   switch(items[[i]]$type,

                                          "downloadButton"   = {items[[i]]$object <<- downloadButton(i, label = items[[i]]$title, class = items[[i]]$class, style = items[[i]]$style)},
                                          "downloadLink"     = {items[[i]]$object <<- downloadLink(i, label = items[[i]]$title, class = items[[i]]$class, style = items[[i]]$style)},
                                          "dynamicInput"     = {items[[i]]$object <<- uiOutput(i, inline = items[[i]]$inline %>% verify('logical' , domain = c(T,F), default = F , varname = "items[['" %++% i %++% "']]$inline"))},
                                          "loginInput"       = {items[[i]]$object <<- uiOutput(i, inline = items[[i]]$inline %>% verify('logical' , domain = c(T,F), default = F , varname = "items[['" %++% i %++% "']]$inline"))},
                                          "uiOutput"         = {
                                            items[[i]]$object <<- uiOutput(i)
                                            if (!is.null(items[[i]]$cloth)  &  !is.null(items[[i]]$title)){items[[i]]$cloth$title <<- items[[i]]$title}
                                          },
                                          "plotOutput" = {
                                            if ('brush' %in% fields) {brsh  = brushOpts(id = items[[i]]$brush)} else {brsh = NULL}
                                            items[[i]]$object <<- plotOutput(i, width  = wdth, height = hght, click  = items[[i]]$click, brush  = brsh)
                                            spn = items[[i]]$spinner %>% verify('character', domain = c('circle', 'bounce', 'folding-cube', 'rotating-plane', 'cube-grid', 'fading-circle', 'double-bounce', 'dots', 'cube'), varname = "items[['" %++% i %++% "']]$spinner")
                                            if(!is.null(spn)){
                                              support('shinyWidgets')
                                              clr = items[[i]]$spinner.color %>% verify('character', varname = "items[['" %++% i %++% "']]$spinner.color", default = '#112446')
                                              dus = try(col2rgb(clr), silent = T) %>% inherits('try-error')
                                              items[[i]]$object <<- addSpinner(items[[i]]$object, spin = spn, color = chif(dus, '#112446', clr))
                                            }
                                          },

                                          "verbatimTextOutput" = {
                                            phldr = items[[i]]$placeholder %>% verify('logical', lengths = 1, default = F, varname = "items[['" %++% i %++% "']]$placeholder")
                                            items[[i]]$object <<- verbatimTextOutput(i, placeholder = phldr)},
                                          # todo: add arguments container and inline for textOutput and htmlOutput
                                          "textOutput"         = {items[[i]]$object <<- textOutput(i)},
                                          "imageOutput"        = {items[[i]]$object <<- imageOutput(i)},
                                          "tableOutput"        = {items[[i]]$object <<- tableOutput(i)},
                                          "dataTableOutput"    = {
                                            support('DT')
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "auto" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- DT::dataTableOutput(i, width = wdth, height = hght)},
                                          "d3tfOutput"= {items[[i]]$object <<- d3tfOutput(i, width  = wdth, height = hght)},
                                          "grvizOutput" = {
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "400px" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- grvizOutput(i, width = wdth, height = hght)},
                                          "c3Output" = {
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- c3::c3Output(i, width = wdth, height = hght)
                                          },
                                          "sankeyNetworkOutput" = {
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "500px" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- networkD3::sankeyNetworkOutput(i, width = wdth, height = hght)},
                                          "upsetjsOutput" = {
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "500px" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- upsetjs::upsetjsOutput(i, width = wdth, height = hght)},
                                          "sunburstOutput" = {
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "400px" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- sunburstR::sunburstOutput(i, width = wdth, height = hght)},
                                          "rHandsonTableOutput"= {
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%"  , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "100%" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- rhandsontable::rHandsontableOutput(i, width  = wdth, height = hght)},
                                          "htmlOutput"         = {items[[i]]$object <<- htmlOutput(i)},
                                          "amChartsOutput"     = {
                                            support('rAmCharts')
                                            # todo: add argument 'type', better to change the argument to 'plotType'
                                            items[[i]]$object <<- amChartsOutput(i, width = wdth, height = hght)},
                                          "pivotOutput"     = {
                                            wdth = items[[i]]$width  %>% verify('character', lengths = 1, default = "100%"  , varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify('character', lengths = 1, default = "500px" , varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- pivotOutput(i, width = wdth, height = hght)},
                                          "dygraphOutput"      = {
                                            support('dygraphs')
                                            items[[i]]$object <<- dygraphs::dygraphOutput(i, width = wdth, height = hght)},
                                          "gglVisChartOutput"  = {items[[i]]$object <<- htmlOutput(i)},
                                          "leafletOutput"      = {
                                            support('leaflet')
                                            items[[i]]$object <<- leafletOutput(i, width = wdth, height = hght)},
                                          "wordcloud2Output"   = {
                                            support('wordcloud2')
                                            items[[i]]$object <<- wordcloud2Output(i, width = wdth, height = hght)},
                                          "infoBoxOutput"      = {items[[i]]$object <<- infoBoxOutput(i,  width = items[[i]]$weight)},
                                          "valueBoxOutput"     = {items[[i]]$object <<- valueBoxOutput(i, width = items[[i]]$weight)},
                                          "plotlyOutput"       = {
                                            support('plotly')
                                            items[[i]]$object <<- plotlyOutput(i, width  = wdth, height = hght)},
                                          "highcharterOutput"  = {
                                            support('highcharter')
                                            items[[i]]$object <<- highchartOutput(i, width  = wdth, height = hght)},
                                          "morrisjsOutput"  = {
                                            support('morrisjs')
                                            items[[i]]$object <<- morrisjsOutput(i, width  = wdth, height = hght)},
                                          "billboarderOutput"  = {
                                            items[[i]]$object <<- billboarder::billboarderOutput(i, width  = wdth, height = hght)},
                                          "sankeytreeOutput"   = {
                                            items[[i]]$object <<- sankeytreeR::sankeytreeOutput(i, width  = wdth, height = hght)},
                                          "coffeewheelOutput"  = {
                                            wdth = items[[i]]$width  %>% verify(c('numeric', 'character'), lengths = 1, default = 400, varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify(c('numeric', 'character'), lengths = 1, default = 400, varname = "items[['" %++% i %++% "']]$height")

                                            items[[i]]$object <<- coffeewheelOutput(i, width  = wdth, height = hght)},
                                          "bubblesOutput"      = {
                                            support('bubbles') # will be embedded
                                            wdth = items[[i]]$width  %>% verify(c('character'), lengths = 1, default = '600px', varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify(c('character'), lengths = 1, default = '600px', varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- bubblesOutput(i, width  = wdth, height = hght)},
                                          "d3plusOutput" = {
                                            support('d3plus') # will be embedded
                                            wdth = items[[i]]$width  %>% verify(c('character'), lengths = 1, default = '100%', varname = "items[['" %++% i %++% "']]$width")
                                            hght = items[[i]]$height %>% verify(c('character'), lengths = 1, default = '500px', varname = "items[['" %++% i %++% "']]$height")
                                            items[[i]]$object <<- d3plusOutput(i, width  = wdth, height = hght)},
                                          "rChartsdPlotOutput" = {items[[i]]$object <<- showOutput(i, "dimple")})

                                   if(!is.null(items[[i]]$tutor.lesson)){
                                     settings$tutorMode <<- T
                                     items[[i]]$object <<- rintrojs::introBox(
                                       items[[i]]$object,
                                       data.intro = items[[i]]$tutor.lesson %>% verify('character') %>% paste(collapse = '\n'),
                                       data.hint  = items[[i]]$tutor.hint %>% verify('character') %>% paste(collapse = '\n'),
                                       data.step  = items[[i]]$tutor.step)
                                   }
                                 }
                               }
                             }

                             # Create input objects:
                             for (i in names(items)){
                               # Inputs & Containers
                               if (items[[i]]$type %in% c(valid.input.types, valid.container.types)){
                                 items[[i]]$object <<- getItemObject(i)
                               }
                             }

                             scr.text = layscript(layout = king.layout) %++% ")"

                             ui.obj <- eval(parse(text = scr.text))
                             return(ui.obj)
                           },

                           dashboard.server = function(){
                             srv_func = function(input, output, session) {
                               # a list of objects which are synced with dashboard inputs and
                               # provide service for dashboard outputs
                               if(settings$keepSessions){sessions <<- c(sessions, session)}
                               sync    = reactiveValues(user = session$user, message = messages['initial'])
                               report  = reactiveValues()
                               for(i in names(objects)){session$userData[[i]] = objects[[i]]}

                               for (i in names(values)){sync[[i]] = values[[i]]}

                               itns = names(items)
                               for (i in itns){
                                 if(inherits(items[[i]]$sync, c('logical', 'numeric', 'integer')) & !is.empty(items[[i]]$sync)){
                                   if(items[[i]]$sync){
                                     switch(items[[i]]$type,
                                            "d3tfOutput"  =
                                            {   cfg_i = items[[i]]$config %>% D3TableFilter.config.verify
                                            tbl_i = items[[i]]$data %>% verify('data.frame', null_allowed = F, err_msg = "todo: Write something!")
                                            # reporting and commanding values both client to server and server to client:
                                            sync[[i]]   <- tbl_i
                                            report[[i]] <- tbl_i
                                            sync[[i %++% '_trigger']] = T
                                            if(!is.null(cfg_i$column.footer)){
                                              sync[[i %++% '_column.footer']] = cfg_i$column.footer
                                              observers <<- c(observers, D3TableFilter.observer.column.footer.R(i))
                                            }
                                            if(!is.null(cfg_i$column.editable)){
                                              sync[[i %++% '_column.editable']] = cfg_i$column.editable
                                              report[[i %++% '_lastEdits']] = D3TableFilter.lastEdits.empty
                                              observers <<- c(observers, D3TableFilter.observer.edit.R(i), D3TableFilter.observer.column.editable.R(i))
                                            }
                                            if(!is.null(cfg_i$selection.mode)){
                                              sync[[i %++% '_selected']]  = cfg_i$selected
                                              report[[i %++% '_selected']]  = cfg_i$selected
                                              observers <<- c(observers, D3TableFilter.observer.selected.C2S.R(i), D3TableFilter.observer.selected.S2C.R(i))
                                            }
                                            if (cfg_i$column.filter.enabled){
                                              sync[[i %++% '_column.filter']] = cfg_i$column.filter
                                              report[[i %++% '_filtered']]  = tbl_i %>% D3TableFilter.filteredRows(cfg_i)
                                              observers <<- c(observers, D3TableFilter.observer.filter.C2S.R(i), D3TableFilter.observer.filter.S2C.R(i))
                                            }
                                            sync[[i %++% '_row.color']] = cfg_i$row.color
                                            observers <<- c(observers, D3TableFilter.observer.color.S2C.R(i))
                                            observers <<- c(observers, D3TableFilter.observer.table.S2C.R(i))
                                            items[[i]]$service <<- D3TableFilter.service(i)
                                            }
                                     )
                                   }
                                 }
                               }

                               if(!is.null(prescript)){eval(parse(text = prescript))}

                               for (i in names(items)){
                                 if (items[[i]]$type %in% valid.output.types){
                                   if (items[[i]]$type != 'static'){
                                     arguments = ''
                                     switch(items[[i]]$type,
                                            "dynamicInput"       = {script.func = gndcd(1,9, 14, 20, 9,  1, 35, 42)},
                                            "loginInput"         = {
                                              script.func = gndcd(1,9, 14, 20, 9,  1, 35, 42)
                                              items[[i]]$service <<- loginUIService
                                            },
                                            "uiOutput"           = {script.func = gndcd(31,29, 14, 20, 29, 31, 47, 9, 50, 25)},
                                            "plotOutput"         = {script.func = gndcd(31,29, 14, 20, 9, 31, 32, 55, 60, 21)},
                                            "verbatimTextOutput" = {script.func = gndcd(110,94,14,7,94,1, 5,110, 118,27,25)},
                                            "textOutput"         = {script.func = gndcd(31, 29, 183,7,130,121,160,94, 167,196)},
                                            "imageOutput"        = {
                                              script.func = 'renderImage'
                                              arguments   = list2Script(items[[i]], fields = c('deleteFile'))
                                            },
                                            "tableOutput"        = {
                                              script.func = 'renderTable';
                                              arguments   = list2Script(items[[i]], fields = c('striped', 'hover', 'bordered', 'spacing', gndcd(56,4,150,196,86), 'align', 'rownames', 'colnames', 'digits', 'na'))
                                            },
                                            "dataTableOutput"    = {
                                              script.func = gndcd(67,47) %++% "::" %++% gndcd(110,9,134,7,162,121,61,39,25,11,160,2,190,171,130)
                                              arguments   = list2Script(items[[i]], fields = c('options'))
                                            },
                                            "d3tfOutput"         = {script.func = 'renderD3tf'},
                                            "grvizOutput"        = {script.func = 'renderGrviz'},
                                            "c3Output"           = {script.func = 'c3::renderC3'},
                                            "sankeyNetworkOutput"= {script.func = 'networkD3::renderSankeyNetwork'},
                                            "upsetjsOutput"      = {script.func = 'upsetjs::renderUpsetjs'},
                                            "sunburstOutput"     = {script.func = 'sunburstR::renderSunburst'},
                                            "rHandsonTableOutput"= {script.func = 'renderRHandsontable'},
                                            "pivot"              = {script.func = 'renderPivot'},
                                            "htmlOutput"         = {script.func = 'renderUI'},
                                            "dygraphOutput"      = {script.func = 'dygraphs::renderDygraph'},
                                            "gglVisChartOutput"  = {script.func = 'renderGvis'},
                                            "leafletOutput"      = {script.func = 'renderLeaflet'},
                                            "wordcloud2Output"   = {script.func = 'renderWordcloud2'},
                                            "infoBoxOutput"      = {script.func = 'renderInfoBox'},
                                            "valueBoxOutput"     = {script.func = 'renderValueBox'},
                                            "amChartsOutput"     = {script.func = 'renderAmCharts'},
                                            "plotlyOutput"       = {script.func = 'plotly::renderPlotly'},
                                            "highcharterOutput"  = {script.func = 'highcharter::renderHighchart'},
                                            "morrisjsOutput"     = {script.func = 'morrisjs::renderMorrisjs'},
                                            "billboarderOutput"  = {script.func = 'billboarder::renderBillboarder'},
                                            "sankeytreeOutput"   = {script.func = 'sankeytreeR::renderSankeytree'},
                                            "coffeewheelOutput"  = {script.func = 'rendercoffeewheel'},
                                            "bubblesOutput"      = {script.func = 'bubbles::renderBubbles'},
                                            "d3plusOutput"       = {script.func = 'd3plus::renderD3plus'},
                                            "rChartsdPlotOutput" = {script.func = 'renderChart2'}
                                     )
                                     if(items[[i]]$type %in% c("downloadButton", "downloadLink")){
                                       fn = items[[i]]$filename %>% verify('character', lengths = 1, default = paste0("'", i, "'"), varname = 'filename')
                                       script = paste0("output$", i, " <- downloadHandler(filename = function(){", fn, "}",
                                                       ", content = function(file){ \n", items[[i]]$service, '\n }', chif(arguments == '', '', ', '), arguments, ')')
                                     } else {
                                       script = paste0('output$', i, ' <- ', script.func, '({', items[[i]]$service, '}', chif(arguments == '', '', ', '), arguments, ')')
                                     }
                                     if(items[[i]]$type == "loginInput"){script %<>% paste('\n', loginUIExtraService, '\n')}
                                     # cat(i, ' --> ', script, '\n')
                                     eval(parse(text = script))
                                   }
                                 }
                               }

                               # service popovers: HTML works with addPopover from the server but not with bsPopover in the UI!!! bug in shinyBS!

                               for (i in names(items)){
                                 if(!is.null(items[[i]]$popover)){
                                   addPopover(session, id = i,
                                              title     = items[[i]]$popover.title %>% verify('character', lengths = 1),
                                              content   = items[[i]]$popover %>% verify('character') %>% paste(collapse = '\n'),
                                              placement = items[[i]]$popover.placement %>% verify('character', lengths = 1, domain = c('top', 'bottom', 'left', 'right')   , default = 'bottom'),
                                              trigger   = items[[i]]$popover.trigger   %>% verify('character', lengths = 1, domain = c('hover', 'focus', 'click', 'manual'), default = 'hover'),
                                              options   = items[[i]]$popover.options)
                                 }
                               }

                               # observeEvents  (input service functions)
                               for (i in names(items)){
                                 if (items[[i]]$type %in% valid.input.types){
                                   if (!is.null(items[[i]]$service)){
                                     if(items[[i]]$isolate %>% verify('logical', domain = c(T,F), default = F, varname = 'isolate')){
                                       isop = gndcd(70, 144, 143, 55, 170, 196, 9) %++% '({'
                                       isoc = '})'
                                     } else {
                                       isop = ''
                                       isoc = ''
                                     }
                                     script = paste0('observeEvent(input$', i, ',{', isop, items[[i]]$service, isoc, '})')
                                     eval(parse(text = script))
                                   }
                                 }
                               }

                               # observers
                               # for (obs in observers){eval(parse(text = "observe({" %++% pre.run %++% '\n' %++% obs %++% "})"))}
                               for (obs in observers){eval(parse(text = gndcd(12,142,112,130,31,100,94) %++% "({" %++% obs %++% "})"))}
                             }
                             return(srv_func)
                           }
                         )
)

# Any time you change the value of a reactive variable, within an observer code,
# you should put that code in isolate({}), because the observer will be called again!


