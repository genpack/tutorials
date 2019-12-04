

######### Service Functions:#########
prescript      = "if(is.null(sync$trigger)){sync$trigger = 0}"

######### Load data, build reactive variables and define initial values: #########
companies = 'woolworths'

val = list(ALCD = NULL, ALCT = NULL, trigger = 0)

dataset   = load("~/Documents/software/R/projects/tutorials/script/texer/woolworth.RData")

logt = data.frame()
logt['guest', 'password'] <- "$2a$12$aWzJhXD8Kq.NgAVG569ABOfB.ptpOc7mxhiW7geW48e.BHxJqxxCa"

dat = all_reveiws_woolworth %>% unlist %>% as.data.frame
colnames(dat) = 'text'
dat$text %<>% as.character

I = list()
O = list()

######### Clothes and static objects: #########
tableCloth  = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = T, weight = 12, title = 'List of Tasks')
ageBoxcloth = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = T, weight = 12, title = 'Age Box Plot')
dueAgeBoxcloth = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = T, weight = 12, title = 'Due Age Box Plot')
sunbox         = list(type = 'box', status = "primary", solidHeader = T, collapsible = T, collapsed = F, weight = 11, title = 'Sunburst View')

centerAlign = list(type = 'column', align = 'center')

lovrCloth  = list(type = 'valueBox', icon = 'calendar-plus-o', subtitle = 'leftover tasks'     , weight = 2, fill = T, color = 'teal')
backCloth  = list(type = 'valueBox', icon = 'files-o'     , subtitle = 'total backlog'      , weight = 2, fill = T, color = 'teal')
unalCloth  = list(type = 'valueBox', icon = 'file-o'      , subtitle = 'unallocated tasks'  , weight = 2, fill = T, color = 'teal')
utilCloth  = list(type = 'valueBox', icon = 'clock-o'     , subtitle = 'Total Utilized Time', weight = 2, fill = T, color = 'teal')
nonCloth   = list(type = 'valueBox', icon = 'ban'         , subtitle = 'non-workable tasks' , weight = 2, fill = T, color = 'teal')
newCloth   = list(type = 'valueBox', icon = 'file'        , subtitle = 'new allocated tasks', weight = 2, fill = T, color = 'teal')
noteCloth  = list(type = 'box' , icon = 'comment-o', offset = 0.5, weight = 12, status = 'success', solidHeader = T)

O$line         = list(type = 'static', object = hr(id = 'line'))
O$lhide        = list(type = 'static', object = hr(id = 'lhide'))
O$caret        = list(type = 'static', object = br())

O$shinyjs      = list(type = 'static', object = useShinyjs())


######### Main Containers: #########

I$main       = list(type = 'dashboardPage', title = 'Dashboard Template v 1.0.0', color = 'blue', layout.head = c() ,layout.body = c('shinyjs', 'flowPage'), sidebar.width = 300,
                    layout.side = c('caret','loginPanel', 'lhide' , 'getTeam', 'lhide', 'read', 'write', 'lhide', 'export'), header.title = 'Dashboard Template v 1.0.0', header.title.width = 300, header.title.font = 'tahoma', header.title.font.weight = 'bold', header.title.font.size = 26)

I$loginPanel = list(type = 'loginInput')
# I$loginPanel = list(type = 'dynamicInput', service = loginPanel.srv)


I$flowPage   = list(type = 'fluidPage' , layout = list('metrics', 'message', 'menu'))

######### Metric Box:
I$metrics    = list(type = 'column'  , layout = c('backInfo', 'lovrInfo', 'newInfo', 'nonInfo', 'unalInfo', 'utilInfo'))
I$message    = list(type = 'column'  , layout = 'notif')
O$lovrInfo   = list(type = 'uiOutput', title = 'Metric 1', cloth = lovrCloth, weight = 2, service = "2.34")
O$backInfo   = list(type = 'uiOutput', title = 'Metric 2', cloth = backCloth , weight = 2, service = "1.23")
O$unalInfo   = list(type = 'uiOutput', title = 'Metric 3', cloth = unalCloth , weight = 2, service = "5.76")
O$newInfo    = list(type = 'uiOutput', title = 'Metric 4', cloth = newCloth, weight = 2, service = "'80 %'")
O$nonInfo    = list(type = 'uiOutput', title = 'Metric 5', cloth = nonCloth, weight = 2, service = "118")
O$utilInfo   = list(type = 'uiOutput', title = 'Metric 6', cloth = utilCloth, weight = 2, service = "8.6")

I$menu       = list(type = 'navbarPage', layout = c('EMTab','CSTab', 'MNTab', 'MLTab', 'SPTab', 'APTab', 'ASTab', 'TOTab'), cloth = list(type = 'column'))

I$notif      = list(type = 'uiOutput', cloth = noteCloth)

######### Sidebar: #########
I$getUser = list(type = 'textInput' , title = 'Username:')
I$getPass = list(type = 'static' , object = passwordInput("passwd", "Password"))
# I$getDate = list(type = 'dateInput'   , title = 'Date:'    , value = Sys.Date(), min = Sys.Date() - 30, max = Sys.Date() + 30) 
# tutor.step   = 2, 
# tutor.lesson = "Select the date on which you would like to run allocations",
# tutor.hint   = "You can select dates within a range of 30 days from toda, however you can only allocate for today and future days")
I$getTeam = list(type = 'selectInput' , title = 'Company:'    , choices = teams, selected = 1) 
# tutor.step   = 1, 
# tutor.lesson = 'Select the team you want to load the data and run allocation for.')
I$read    = list(type = 'actionButton', title = 'Load Data', width = '90%', icon = icon('tasks', 'fa-2x'))
I$write   = list(type = 'actionButton', title = 'Save', width = '90%' , icon = icon('hdd-o', 'fa-2x'))
I$export  = list(type = 'downloadButton', title = 'Export to Excel', 
                 filename = "paste(as.character(sync$ALCD), as.character(sync$ALCT), 'SO Allocation Report.xlsx')",
                 style = style.css(width = '300px', color = 'black'))

# I$help    = list(type = 'actionLink', title = 'Show me how the dashboard works', service = "rintrojs::introjs(session)")
I$EMTab   = list(type = 'tabPanel' , title = 'Info', layout = 'EMPage')
I$EMPage  = list(type = 'fluidPage', layout = list('information'))
I$information = list(type = 'static', object = column(12, includeMarkdown("readme.md")))

######### Skill Profile: #########
I$SPTab   = list(type = 'tabPanel' , title = 'Menu Item 1', layout = 'SPPage')
I$SPPage  = list(type = 'fluidPage', layout = list(list('SPApply', 'SPUndo'), 'SPTable'))

O$SPTable = list(type = 'wordcloud2Output' , title = 'Skill Profile', height = '1000px')
I$SPApply = list(type = 'actionButton'        , title = 'Apply Changes', icon = icon('check', 'fa-2x'),  width = '80%', cloth = centerAlign)
I$SPUndo  = list(type = 'actionButton'        , title = 'Undo Changes' , icon = icon('undo' , 'fa-2x') , width = '80%', cloth = centerAlign)

######### Agent Profile: #########
I$APTab   = list(type = 'tabPanel', title = 'Menu Item 2', layout = 'APPage')
# I$APPage  = list(type = 'fluidPage', layout = list(list('APTable', 'agentUtilBar')))
I$APPage  = list(type = 'fluidPage', layout = list(list('APApply', 'APUndo'), 'APTable'))

O$APTable = list(type = 'wordcloud2Output' , title = 'Menu Item 3', height = '1000px')
I$APApply = list(type = 'actionButton' , title = 'Item 3-Button 1', icon = icon('check', 'fa-2x'), width = '80%', cloth = centerAlign)
I$APUndo  = list(type = 'actionButton' , title = 'Item 3-Button 2' , icon = icon('undo', 'fa-2x') , width = '80%', cloth = centerAlign)

######### Agent-Skill Matrix: #########
I$ASTab   = list(type = 'tabPanel', title = 'Menu Item 4', layout = 'ASPage')
I$ASPage  = list(type = 'fluidPage', layout = list(list('ASApply', 'ASUndo'), 'ASTable'))

O$ASTable = list(type = 'wordcloud2Output' , title = 'Agent-Skill Matrix', weight = 9, height = '1000px')
I$ASApply = list(type = 'actionButton'        , title = 'Apply Changes', icon = icon('check', 'fa-2x'), width = '80%', cloth = centerAlign)
I$ASUndo  = list(type = 'actionButton'        , title = 'Undo Changes' , icon = icon('undo' , 'fa-2x'), width = '80%', cloth = centerAlign)

######### CommSee Tasks: #########
I$CSTab      = list(type = 'tabPanel', title = 'Menue Item 5', layout = 'CSPage')
#I$CSPage     = list(type = 'fluidPage', layout = list(list('CSApply', 'CSUndo', 'CSLoad'), 'CSTable'))
I$CSPage     = list(type = 'fluidPage', layout = list(list('CSLoad', 'CSClear'), 'CSTable'))

O$CSTable = list(type = 'dataTableOutput', title = 'Table 1', height = '1200px')
I$CSClear = list(type = 'actionButton', title = 'Item 5-Button 1', icon = icon('eraser', 'fa-2x'), width = '80%', cloth = centerAlign, service = CSClear.srv)
I$CSUndo  = list(type = 'actionButton', title = 'Item 5-Button 2' , icon = icon('undo' , 'fa-2x') , width = '80%' , cloth = centerAlign)
I$CSLoad  = list(type = 'fileInput'   , title = 'Item 5-fileInput 1', multiple = T, cloth = centerAlign)

######### Manual New Tasks: #########

I$MNTab   = list(type = 'tabPanel' , title = 'Menue Item 6', layout = 'MNPage')
I$MNPage  = list(type = 'fluidPage', layout = list(list('MNAdd', 'MNDel', 'MNApply', 'MNUndo'), 'MNTable'))

O$MNTable = list(type = 'wordcloud2Output' , title = 'Item 6-Wordcload', height = '1000px')
# O$MNTable = list(type = 'rHandsonTableOutput' , title = 'Manual New Tasks', height = '1000px', width = '100%', service = "sync$MNTable %>% MNTable.srvf(session$userData$ota)")

I$MNAdd   = list(type = 'actionButton' , title = 'Item 6-Button 1'      , icon = icon('plus' , 'fa-2x')  , width = '80%', cloth = centerAlign)
I$MNDel   = list(type = 'actionButton' , title = 'Item 6-Button 2'   , icon = icon('trash' , 'fa-2x') , width = '80%', cloth = centerAlign)
I$MNApply = list(type = 'actionButton' , title = 'Item 6-Button 3', icon = icon('check' , 'fa-2x') , width = '95%', cloth = centerAlign)
I$MNUndo  = list(type = 'actionButton' , title = 'Item 6-Button 4' , icon = icon('undo' , 'fa-2x')  , width = '95%', cloth = centerAlign)

######### Manual Average Stars Tasks: #########
I$MLTab   = list(type = 'tabPanel' , title = 'Menu Item 7', layout = 'MLPage')
I$MLPage  = list(type = 'fluidPage', layout = list(list('MLApply', 'MLUndo'), 'MLTable'))

O$MLTable = list(type = 'wordcloud2Output' , title = 'Item 7-Wordcloud', height = '1000px')

I$MLApply = list(type = 'actionButton' , title = 'Item 7-Button 1', icon = icon('check' , 'fa-2x') , width = '95%', cloth = centerAlign)
I$MLUndo  = list(type = 'actionButton' , title = 'Item 7-Button 2' , icon = icon('undo' , 'fa-2x')  , width = '95%', cloth = centerAlign)

######### Task Overview: #########
I$TOTab   = list(type = 'tabPanel' , title = 'Menu Item 8', layout = 'TOPage')

I$TOPage  = list(type = 'fluidPage', layout = 
                   list(
                     list( 'balanced', 'allocate', 'clear'),
                     'line',
                     list('OTS'), 
                     list(
                       list(weight = 6, 'ageBar'), 
                       list(weight = 6, 'dueAgeBar')
                     )
                   )
)

I$allocate = list(type = 'actionButton', title = 'Item 8-Button 1'  , icon = icon('user-plus' , 'fa-2x'), width = '80%', cloth = centerAlign)
I$balanced = list(type = 'checkboxInput', title = 'Item 8-Checkbox 1'  , value = F, width = '80%')
I$clear    = list(type = 'actionButton', title = 'Item 8-Button 2', icon = icon('eraser' , 'fa-2x')   , width = '80%', cloth = centerAlign)
# OTS Stands for Overall Task Summary
O$OTS        = list(type = 'dataTableOutput'   , title = 'Item 8-Table 1', width = 'auto', height = '400px', weight = 12)
O$ageBar     = list(type = 'highcharterOutput' , title = 'Item 8-Plot 1'      , width = 'auto', height = '400px')
O$dueAgeBar  = list(type = 'highcharterOutput' , title = 'Item 8-Plot 2'  , width = 'auto', height = '400px')

######### Allocation Pivot Table: #########

I$APTTab   = list(type = 'tabPanel' , title = 'Menu Item 9', layout = 'APTPage')

I$APTPage  = list(type = 'fluidPage', layout = 'pivot')

O$pivot      = list(type = 'pivotOutput'  , title = 'Item 9-Pivot 1', width = 'auto', height = '1000px', weight = 12)

######### Allocation Overview 2: #########

I$AOTab   = list(type = 'tabPanel' , title = 'Menu Item 10', layout = 'AOPage')

I$AOPage  = list(type = 'fluidPage', layout = 
                   list(
                     list(
                       list(weight = 3, 
                            list('agentBar') 
                       ),
                       list(weight = 3, 
                            list('skillBar')
                       ),
                       list(offset = 1, weight = 5, 'ACW')
                       
                     )
                   )
)

O$ACW        = list(type = 'coffeewheelOutput' , title = 'Item 10-Coffeewheel 1', width = 'auto', height = '750px', weight = 12)
O$agentBar   = list(type = 'highcharterOutput' , title = 'Item 10-Plot 1', width = 'auto', height = '750px', weight = 12)
O$skillBar   = list(type = 'highcharterOutput' , title = 'Item 10-Plot 2', width = 'auto', height = '750px', weight = 12)

######### Build Dashboard: #########

dash   <- new('DASHBOARD', items = c(O, I), king.layout = list('main'), objects = list(ota = x), values = val, loginTable = logt, messages = messages, settings = list(savingPath = 'data/', passEncryption = 'bcrypt'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
app    <- shinyApp(ui, server)

######### Run: #########

# runApp(app)
# runApp(app, host = "0.0.0.0", port = 8080)
