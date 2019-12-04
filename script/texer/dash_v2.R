
######### Global Variables: #########
APLabels = list('Full Name' = 'agentName', 'Team Name' = 'teamName', 'Available Time (min)' = 'available',
                'Leftover' = 'LFTVRS', 'Assigned' = 'ASSGND', 'Total Allocated' = 'TOT.ALCTD', 'Utilized (min)' = 'utilized')

SPLabels = list('Skill Name' = 'skillName', 'Type' = 'skillType', 'Total Tasks' = 'Backlog',
                'Leftover', 'New Allocated' = 'newAllocated', 'Not Workable' = 'notWorkable', 'Unallocated')

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

######### Main Containers: #########

I$main       = list(type = 'dashboardPage', title = 'Review Topics v 1.0.0', color = 'blue', layout.head = c() ,layout.body = c('shinyjs', 'flowPage'), sidebar.width = 300,
                    layout.side = c(), header.title = 'Review Topics v 1.0.0', header.title.width = 300, header.title.font = 'tahoma', header.title.font.weight = 'bold', header.title.font.size = 26)

I$flowPage   = list(type = 'fluidPage' , layout = list('metrics', 'message', 'menu'))
I$metrics    = list(type = 'column'  , layout = c('ncomment', 'meanstars', 'medianstars', 'metric4', 'metric5', 'metric6'))

######### Build Dashboard: #########

dash   <- new('DASHBOARD', items = c(O, I), king.layout = list('main'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
app    <- shinyApp(ui, server)

######### Run: #########

# runApp(app)
# runApp(app, host = "0.0.0.0", port = 8080)
