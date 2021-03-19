###### ROOT FOLDER: =======================



### dash.R ---------------------
# Header
# Filename:       dash.R
# Description:    This file creates shiny UI for the SO project. 
# Author:         Nicolas Berta 
# Email:          nicolas.berta@abc.com
# Start Date:     10 May 2017
# Last Revision:  02 August 2018
# Version:        2.8.3

# Version History:

# Version   Date              Action
# ___________________________________________
# 0.0.1     10 May 2017       Initial Issue
# 0.2.0     02 June 2017      Changed Task Overview page based on discussion with Suraj on 02 June 2017
# 0.3.0     26 July 2017      Dashboard structure changed
# 0.4.0     26 July 2017      Dashboard structure changed
# 1.0.0     29 August 2017    Box of notes added under the metrics + all functionalities.!
# 1.0.1     29 August 2017    Only Non-CommSee tasks are added when new row pressed
# 1.1.0     29 August 2017    User selects agent and skill for the added row in Manual new and leftover task input
# 1.1.1     30 August 2017    Read form CSV file for CS tasks: feature added
# 1.1.2     30 August 2017    Icons for buttons and metric boxes
# 1.1.3     31 August 2017    Message notes updated.
# 1.1.4     11 September 2017 CommSee task read from CSV updated.
# 1.1.5     12 September 2017 CommSee task removal button added.
# From now on, the version of this file is the version of SO! Changes if any of these files change: dash.R, iotools.R, otavis.R, global.R
# 1.2.0     12 October 2017   otavis.R changed to version 1.1.9
# 1.2.1     12 October 2017   0.5 sec delay before some operations to make the notification change visible
# 1.2.2     16 October 2017   Pivot Table added as a new tab 
# 1.2.3     16 October 2017   Column utilized in APTable shows 2 decimal digits, 
# 1.2.4     16 October 2017   Bug in APUndo fixed.
# 1.2.5     23 October 2017   Calls agent.bar() function in otavis
# 1.2.6     24 October 2017   cloths removed from allocation overview plots, space issues fixed
# 1.2.8     30 October 2017   otavis.R changed to version 1.2.8
# 1.2.9     27 October 2017   package viser updated to ver 3.5.4
# 1.3.1     30 October 2017   iotools.R changed to version 2.4.1
# 1.3.2     30 October 2017   package gener updated to ver 2.2.4
# 1.3.3     30 October 2017   package promer updated to ver 1.7.1
# 1.3.4     01 Novemebr 2017  package gener updated to ver 2.2.5
# 1.3.5     01 November 2017  package promer updated to ver 1.7.2
# 1.3.6     01 November 2017  package viser updated to ver 3.5.5
# 1.3.7     06 November 2017  Selected team and date are updated when the app is running on more than one client
# 1.3.8     06 November 2017  Dropdown list for skills and agents are updated for Manual New Tasks and Manual Lefover tabs
# 1.3.9     06 November 2017  SLA added to SP Table
# 1.4.0     07 November 2017  SPApply.srv modified: SLA applied to the object as well as PRW
# 1.4.1     08 November 2017  MNTable: due date-time chanes automatically when start time changes according to the SLA time
# 1.4.4     14 November 2017  MNTable: due and start date-times are character columns now. iotools.R and otavis.R also modified to accommodate this change
# 1.5.0     14 November 2017  MLTable changed to matrix form: iotools.r and otavis.r changed accordingly. 
# 1.6.0     20 November 2017  Layout updated: Sidebar added. 
# 1.7.0     21 November 2017  Skin color and font styles can now be customized
# 1.7.1     06 November 2017  Date issues rectified, respecting public holidays by using diffTime() function from gener
# 1.7.2     06 November 2017  Saves session data on exit (logout) and reloads on login
# 1.7.3     08 November 2017  changed local to session$userData
# 1.7.4     12 February 2018  iotools.R changes to version 2.6.7
# 1.7.5     12 February 2018  Added custom-defined folder for saving session data
# 1.7.6     14 February 2018  otavis.R changes to version 1.4.4
# 1.7.7     16 February 2018  Different reactive varioable trigger.cs added for commsee table
# 1.7.8     16 February 2018  otavis.R changed to version 1.4.5
# 1.7.9     20 February 2018  sync$trigger is now an integer fired by adding 1 to it
# 1.8.0     20 February 2018  promer updated to version 2.0.1 (Version of other packages: gener: 2.4.4, viser: 4.2.0)
# 1.8.1     25 February 2018  Maximum for the Agent Table scheduled minutes 
# 1.8.3     26 February 2018  CommSee tasks table changed to DT (otavis.com changed accordingly)
# 1.8.4     28 February 2018  Commsee table shows 25 rows per page now
# 1.8.5     28 February 2018  tdy is replaced by Sys.Date()
# 1.8.6     05 March 2018     Filter added for the new DT CommSee table 
# 1.8.7     05 March 2018     A bug fixed: Logout issue when logout on Agent profile
# 1.8.8     06 March 2018     Save session after each allocation and automatically with a given time frequency
# 1.9.2     09 March 2018     gener updated to 2.4.7, promer updated to 2.2.0 and viser updated to 4.3.4
# 1.9.6     13 March 2018     gener updated to 2.4.8, promer updated to 2.2.3
# 1.9.7     13 March 2018     added bmoguest as a user
# 1.9.9     19 April 2018     otavis.R changed to version (1.4.7)
# 2.0.0     19 April 2018     Global variable SPLabels modified: Order of columns now matches the order of metric boxes
# 2.0.1     19 April 2018     Data Series named Backlog removed from stack bar charts
# 2.0.2     20 April 2018     iotools.R modified to version 2.6.9
# 2.2.7     07 May 2018       gener.R updated to 2.5.0, promer updated to 2.4.6
# 2.3.0     08 May 2018       otavis.R updated to 1.4.9, iotools.R updated to 2.7.1, promer updated to 2.4.9
# 2.3.1     08 May 2018       Service functions for items write, read, APApply, MNApply, MLApply and ASApply modified: Disables write button until the data has been written
# 2.3.2     28 May 2018       iotools.R changed to version 2.7.2
# 2.7.8     05 June 2018      otavis.R updated to 1.5.0, gener changed to 2.5.7, promer updated to 2.6.0, viser updated to 4.6.1
# 2.8.1     24 July 2018      Changes made by Tim Pope. iotools changed to version 2.8.1, promer changed to otar (ver 4.3.8) (gener updated to ver 2.6.8) (viser updated to ver 5.2.2)
# 2.8.2     01 August 2018    gener updated to 2.7.8, viser updated to 5.5.5
# 2.8.3     02 August 2018    hides MLTab if no skills are tagged as manual


######### Global Variables: #########
APLabels = list('Full Name' = 'agentName', 'Team Name' = 'teamName', 'Available Time (min)' = 'available',
                'Leftover' = 'LFTVRS', 'Assigned' = 'ASSGND', 'Total Allocated' = 'TOT.ALCTD', 'Utilized (min)' = 'utilized')

SPLabels = list('Skill Name' = 'skillName', 'Type' = 'skillType', 'Total Tasks' = 'Backlog',
                'Leftover', 'New Allocated' = 'newAllocated', 'Not Workable' = 'notWorkable', 'Unallocated')

######### Service Functions:#########
prescript      = "if(is.null(sync$trigger)){sync$trigger = 0}"

OTS.srv        = paste(prescript, "session$userData$ota$SP %>% viserPlot(label = SPLabels, config = list(withRowNames = T), plotter = 'DT', type = 'table')", sep = ';')
lovrInfo.srv   = paste(prescript, "session$userData$ota %>% leftover.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
backInfo.srv   = paste(prescript, "session$userData$ota %>% backlog.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')                            
unalInfo.srv   = paste(prescript, "session$userData$ota %>% unallocated.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
newInfo.srv    = paste(prescript, "session$userData$ota %>% assigned.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
nonInfo.srv    = paste(prescript, "session$userData$ota %>% nonworkable.count(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';')
utilInfo.srv   = paste(prescript, "session$userData$ota %>% overallUtilization", sep = ";")

APApply.srv   = paste("dash$disableItems('APUndo', 'APApply')",
                      "sync$message <<- 'In progress...'", "Sys.sleep(0.5)",
                      "ota = try(feedAgentSchedule(session$userData$ota, sync$APTable, scheduled_col = 'scheduled', utilFactor_col = 'utilFactor'), silent = T)",
                      "if(inherits(ota, 'OptimalTaskAllocator')){session$userData$ota = ota",
                      "sync$trigger = sync$trigger + 1",
                      "sync$message <<- messages['APTableApplied']",
                      "} else {sync$message <<- ota %>% as.character %>% cleanError}", 
                      "dash$enableItems('APUndo', 'APApply')", sep = ';')

SPApply.srv   = paste("sync$message <<- 'In progress...'", "Sys.sleep(0.5)",
                      "session$userData$ota$SP[rownames(sync$SPTable), 'PRW'] <<- sync$SPTable$PRW", 
                      "session$userData$ota$SP[rownames(sync$SPTable), 'SLA'] <<- sync$SPTable$SLA", 
                      "session$userData$ota = customizeTaskPriorities(session$userData$ota, skillPriorityWeight_column = 'PRW')", 
                      "sync$message <<- messages['SPTableApplied']", sep = ';')

ASApply.srv   = paste("sync$message <<- 'In progress...'" ,"dash$disableItems('ASUndo', 'ASApply')",
                      "Sys.sleep(0.5)",
                      "ota <- applyTAT2Obj(session$userData$ota, sync$APTable, sync$SPTable, sync$ASTable)",
                      "if(inherits(ota, 'OptimalTaskAllocator')){session$userData$ota = ota",
                      "sync$APTable = session$userData$ota$AP[ , c('agentName', 'teamID', 'teamName', 'scheduled', 'utilFactor', 'reserved', 'available')]",
                      "sync$trigger = sync$trigger + 1",
                      "sync$message <<- messages['ASTableApplied']",
                      "} else {sync$message <<- ota %>% as.character %>% cleanError}", 
                      "dash$enableItems('ASUndo', 'ASApply')", sep = ';')

MLApply.srv   = paste("sync$message <<- 'In progress...'", "dash$disableItems('MLUndo', 'MLApply')", "Sys.sleep(0.5)",
                      "ota <- applyML(session$userData$ota, sync$MLTable, sync$APTable, sync$SPTable, sync$ALCD)",
                      "if(inherits(ota, 'OptimalTaskAllocator')){session$userData$ota = ota",
                      "sync$trigger = sync$trigger + 1",
                      "sync$message <<- messages['MLTableApplied']",
                      "} else {sync$message <<- ota %>% as.character %>% cleanError}", 
                      "dash$enableItems('MLUndo', 'MLApply')", sep = ';')

MNApply.srv   = paste("sync$message <<- 'In progress...'", "dash$disableItems('MNAdd', 'MNDel', 'MNUndo', 'MNApply')", "Sys.sleep(0.5)",
                      "ota <- applyMN(session$userData$ota, sync$MNTable)",
                      "if(inherits(ota, 'OptimalTaskAllocator')){session$userData$ota = ota",
                      "sync$trigger = sync$trigger + 1",
                      "sync$message <<- messages['MNTableApplied']",
                      "} else {sync$message <<- ota %>% as.character %>% cleanError}", 
                      "dash$enableItems('MNAdd', 'MNDel', 'MNUndo', 'MNApply')", sep = ';')

MNAdd.srv     = paste("MNTable = addRow2MNTable(sync$MNTable, session$userData$ota, selected = input$MNSkill, alloc_date = sync$ALCD)",
                      "if(inherits(MNTable, 'try-error')){sync$message <<- MNTable %>% as.character %>% cleanError} else {sync$MNTable = MNTable}", sep = '\n')

SPUndo.srv    = paste("spt = try(session$userData$ota$SP[order(rownames(session$userData$ota$SP) %>% as.integer) , c('skillName', 'skillType', 'teamID', 'teamName', 'PRW', 'SLA')], silent = T)",
                      "if(inherits(spt, 'data.frame')){sync$SPTable = spt; sync$message <<- 'Skill profile retrieved from object.'} else {sync$message <<- spt %>% as.character %>% cleanError}",
                      sep = ';')

ASUndo.srv    = paste("ast = try(session$userData$ota %>% obj2ASTable, silent = T)",
                      "if(inherits(ast, 'data.frame')){sync$ASTable = ast; sync$message <<- messages['ASUndoSuccess']} else {sync$message <<- ast %>% as.character %>% cleanError}",
                      sep = ';')

APUndo.srv    = paste("apt = try(session$userData$ota %>% obj2APTable, silent = T)",
                      "if(inherits(apt, 'data.frame')){sync$APTable = apt; sync$message <<- messages['APUndoSuccess']} else {sync$message <<- apt %>% as.character %>% cleanError}",
                      sep = ';')

MNUndo.srv    = paste("sync$MNTable = session$userData$ota %>% obj2MNTable",
                      "sync$message <<- 'Non-CommSee open tasks retrieved from object.'", sep = ';')
MLUndo.srv    = paste("sync$MLTable = session$userData$ota %>% obj2MLTable",
                      "sync$message <<- 'Non-CommSee leftover tasks retrieved from object.'", sep = ';')
MNDel.srv     = "if(!is.null(input$MNTable_select)){sync$MNTable <- sync$MNTable[- input$MNTable_select, ]}"

CSLoad.srv    = paste("if(!is.null(input$CSLoad)){", 
                      "  # debug(readCommSeeTasks)",
                      "  # debug(check); check(x = 'Hi:-', y = input$CSLoad$datapath, z = input$CSLoad$name)",
                      "  sync$message <<- 'In Progress ...'",
                      "  Sys.sleep(0.5)",
                      "  tasks = try(readTaskFilesAndProcess(Team = sync$ALCT, files = input$CSLoad$datapath, names = input$CSLoad$name, tempPath = 'data/temp',skills=session$userData$ota$SP,AgentProfile=session$userData$ota$AP,Date=sync$ALCD), silent = F)", 
                      "  if(inherits(tasks, 'data.frame')){",
                      "    session$userData$ota = applyCSVTable2Obj(session$userData$ota, tasks)",
                      "    mm = nrow(tasks); nn = nrow(session$userData$ota$TSK[session$userData$ota$SP[session$userData$ota$TSK$skill, 'skillType'] == 'CommSee',])",
                      "    if( mm > nn){addmsg = ' ' %++% (mm - nn) %++% ' tasks were removed due to duplicated IDs or because either skill or agent IDs were not introduced!'} else {addmsg = ''}",
                      "    sync$trigger    = sync$trigger + 1",
                      "    sync$message <<- messages['CSTasksLoadedFromCSV'] %++% addmsg",
                      "  } else {",
                      "  sync$message <<- tasks %>% as.character %>% cleanError}",
                      "}" , sep = '\n')

CSClear.srv   = paste("session$userData$ota = clearCommSeeTasks(session$userData$ota)",
                      "sync$trigger    = sync$trigger + 1", 
                      "sync$message <<- messages['CSTasksCleared']", sep = '\n')

agentBar.srv = paste(prescript, "session$userData$ota %>% agent.bar", sep = "\n")

read.srv = 
  "  
sync$message <<- 'In Progress ...'
Sys.sleep(0.5)
dash$disableItems('read', 'write', 'export')
dataset = try(loadData(input$getDate, input$getTeam, dsn = 'SODEV', uid = 'rshinyuser', pwd = 'smrtoptmzr'), silent = T)
if(inherits(dataset, 'try-error')){
sync$message <<- as.character(dataset) %>% cleanError
} else {
ota <- try(dataset2Obj(dataset), silent = T)
if(inherits(ota, 'try-error')){sync$message <<- as.character(ota) %>% cleanError} else {
session$userData$ota = ota
sync$ALCD = input$getDate
sync$ALCT = input$getTeam
sync$trigger    = sync$trigger + 1
sync$message <<- 'Dataset successfully loaded for Team:' %>% paste(isolate(sync$ALCT), '[', teamTable[isolate(sync$ALCT), 'TEAMNAME'], '],', 'Allocation Date:', isolate(sync$ALCD))}
dash$enableItems('read', 'write', 'export')}
"

allocate.srv = 
  "
if((sync$ALCD >= Sys.Date() - 30) & (sync$ALCD < addDate(Sys.Date(), 6))){
sync$message <<- 'In Progress ...'
dash$disableItems('clear', 'allocate')
Sys.sleep(0.5)
ota = try(session$userData$ota %>% allocateTasks(input$balanced), silent = T)
if(inherits(ota, 'try-error')){sync$message <<- as.character(ota) %>% cleanError} 
else {
session$userData$ota = ota
saveRDS(list(local = list(ota = ota), sync = sync), 'data/' %++% sync$user %++% 'rds')
sync$message <<- messages['TasksAllocated']
sync$trigger    = sync$trigger + 1}
} else {sync$message <<- messages['notToday']}
dash$enableItems('clear', 'allocate')
"

clear.srv = 
  "
sync$message <<- 'In Progress ...'
Sys.sleep(0.5)
ota = try(clearAllocation(session$userData$ota), silent = T)
if(inherits(ota, 'try-error')){
sync$message <<- ota %>% as.character %>% cleanError
} else {
session$userData$ota = ota
sync$trigger = sync$trigger + 1

sync$message <<- messages['AllocationCleared']}
"  

write.srv = paste(
  "sync$message <<- 'In progress...'", 
  "dash$disableItems('read', 'write', 'export')",
  "sync$message <<- 'In Progress ...'",
  "Sys.sleep(0.5)",
  "res = try(exportToDatabase(session$userData$ota, sync$ALCD, sync$ALCT, dsn = 'SODEV', uid = 'rshinyuser', pwd = 'smrtoptmzr'), silent = T)",
  "if(inherits(res, 'try-error')){sync$message <<- 'Failed to write: ' %++% cleanError(as.character(res))} else {sync$message <<- messages['written'] %++% as.character(res)}", 
  "dash$enableItems('read', 'write', 'export')", sep = '\n')

# change this later to select filepath. currently saved in current working directory
export.srv = paste(
  "sync$message <<- 'In progress...'", 
  "dash$disableItems('export', 'read', 'write')",
  "Sys.sleep(0.5)",
  "res = try(writeAllocationReport(session$userData$ota, file), silent = T)",
  "flnm = paste(as.character(sync$ALCD), as.character(sync$ALCT), 'SO Allocation Report.xlsx')",
  "if(inherits(res, 'try-error')){sync$message <<- 'Failed to export: ' %++% cleanError(as.character(res))} else {sync$message <<- messages['exported'] %++% flnm}",
  "dash$enableItems('export', 'read', 'write')" , sep = '\n')

######### Load data, build reactive variables and define initial values: #########
teamTable = readTeams(dsn = 'SODEV', uid = 'rshinyuser', pwd = 'smrtoptmzr') %>% column2Rownames('TEAMID')
holidays  = readHolidays(dsn = 'SODEV', uid = 'rshinyuser', pwd = 'smrtoptmzr')[,'CALENDARDATE'] %>% as.Date
teams = rownames(teamTable)
names(teams) = teamTable[,'TEAMNAME']

val = list(ALCD = NULL, ALCT = NULL, trigger = 0)

dataset   = loadData(Sys.Date(), dsn = 'SODEV', uid = 'rshinyuser', pwd = 'smrtoptmzr')

logt = getLoginTable(dsn = 'SODEV', uid = 'rshinyuser', pwd = 'smrtoptmzr') %>% column2Rownames('USERNAME')
names(logt) %<>% tolower
logt$password %<>% as.character
logt['bmoguest', 'password'] <- "$2a$12$aWzJhXD8Kq.NgAVG569ABOfB.ptpOc7mxhiW7geW48e.BHxJqxxCa"

x = dataset %>% dataset2Obj

reactives = obj2Reactives(x)

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

# Todo: check to see how this jscode can be directly passed to the dashboard (without using a js file)
#hdrtxt = DT.links.click.js(list(mylink))
hdrtxt = '
$(document).on("click", ".go-map", function(e) {
e.preventDefault();
Shiny.onInputChange("goto", {
id : $(this).data("id")
});
});
'
# O$jsheader     = list(type = 'static', object = tags$head(includeScript(JS(hdrtxt))))
# O$jsheader     = list(type = 'static', object = tags$head(includeScript('www/gomap.js')))

######### Main Containers: #########

I$main       = list(type = 'dashboardPage', title = 'SO v 2.8.3', color = 'blue', layout.head = c() ,layout.body = c('shinyjs', 'flowPage'), sidebar.width = 300,
                    layout.side = c('caret','loginPanel', 'lhide' , 'getTeam', 'getDate', 'lhide', 'read', 'write', 'lhide', 'export'), header.title = 'SO v 2.8.3', header.title.width = 300, header.title.font = 'tahoma', header.title.font.weight = 'bold', header.title.font.size = 26)

I$loginPanel = list(type = 'loginInput')
# I$loginPanel = list(type = 'dynamicInput', service = loginPanel.srv)


I$flowPage   = list(type = 'fluidPage' , layout = list('metrics', 'message', 'menu'))

######### Metric Box:
I$metrics    = list(type = 'column'  , layout = c('backInfo', 'lovrInfo', 'newInfo', 'nonInfo', 'unalInfo', 'utilInfo'))
I$message    = list(type = 'column'  , layout = 'notif')
O$lovrInfo   = list(type = 'uiOutput', title = 'Leftover', cloth = lovrCloth   , service = lovrInfo.srv, weight = 2)
O$backInfo   = list(type = 'uiOutput', title = 'Total Tasks', cloth = backCloth     , service = backInfo.srv , weight = 2)
O$unalInfo   = list(type = 'uiOutput', title = 'Unallocated', cloth = unalCloth , service = unalInfo.srv , weight = 2)
O$newInfo    = list(type = 'uiOutput', title = 'New Allocated', cloth = newCloth, service = newInfo.srv, weight = 2)
O$nonInfo    = list(type = 'uiOutput', title = 'Not Workable', cloth = nonCloth , service = nonInfo.srv, weight = 2)
O$utilInfo   = list(type = 'uiOutput', title = 'Average Utilization', cloth = utilCloth , service = utilInfo.srv, weight = 2)

I$menu       = list(type = 'navbarPage', layout = c('EMTab','CSTab', 'MNTab', 'MLTab', 'SPTab', 'APTab', 'ASTab', 'TOTab', 'APTTab','AOTab'), cloth = list(type = 'column'))
# I$menu       = list(type = 'tabsetPanel', layout = c('CSTab', 'MNTab', 'MLTab', 'SPTab', 'APTab', 'ASTab', 'TOTab', 'APTTab','AOTab'))

I$notif      = list(type = 'uiOutput', cloth = noteCloth, service = "sync$message")

######### Sidebar: #########
I$getUser = list(type = 'textInput' , title = 'Username:')
I$getPass = list(type = 'static' , object = passwordInput("passwd", "Password"))
I$getDate = list(type = 'dateInput'   , title = 'Date:'    , value = Sys.Date(), min = Sys.Date() - 30, max = Sys.Date() + 30) 
# tutor.step   = 2, 
# tutor.lesson = "Select the date on which you would like to run allocations",
# tutor.hint   = "You can select dates within a range of 30 days from toda, however you can only allocate for today and future days")
I$getTeam = list(type = 'selectInput' , title = 'Team:'    , choices = teams, selected = 1) 
# tutor.step   = 1, 
# tutor.lesson = 'Select the team you want to load the data and run allocation for.')
I$read    = list(type = 'actionButton', title = 'Load Data', width = '90%', icon = icon('tasks', 'fa-2x'), service = read.srv)
I$write   = list(type = 'actionButton', title = 'Save Allocation', width = '90%' , icon = icon('hdd-o', 'fa-2x'), service = write.srv)
I$export  = list(type = 'downloadButton', title = 'Export to Excel', service = export.srv, 
                 filename = "paste(as.character(sync$ALCD), as.character(sync$ALCT), 'SO Allocation Report.xlsx')",
                 style = style.css(width = '300px', color = 'black'))

# I$help    = list(type = 'actionLink', title = 'Show me how the dashboard works', service = "rintrojs::introjs(session)")
I$EMTab   = list(type = 'tabPanel' , title = 'Info', layout = 'EMPage')
I$EMPage  = list(type = 'fluidPage', layout = list('information'))
I$information = list(type = 'static', object = column(12, includeMarkdown("readme.md")))

######### Skill Profile: #########
I$SPTab   = list(type = 'tabPanel' , title = 'Skill Profile', layout = 'SPPage')
I$SPPage  = list(type = 'fluidPage', layout = list(list('SPApply', 'SPUndo'), 'SPTable'))

O$SPTable = list(type = 'TFD3Output' , title = 'Skill Profile', height = '1000px', 
                 data = reactives$SPTable, config = spcfg, sync = T)
I$SPApply = list(type = 'actionButton'        , title = 'Apply Changes', icon = icon('check', 'fa-2x'),  width = '80%', service = SPApply.srv, cloth = centerAlign)
I$SPUndo  = list(type = 'actionButton'        , title = 'Undo Changes' , icon = icon('undo' , 'fa-2x') , width = '80%', service = SPUndo.srv , cloth = centerAlign)

######### Agent Profile: #########
I$APTab   = list(type = 'tabPanel', title = 'Agent Profile', layout = 'APPage')
# I$APPage  = list(type = 'fluidPage', layout = list(list('APTable', 'agentUtilBar')))
I$APPage  = list(type = 'fluidPage', layout = list(list('APApply', 'APUndo'), 'APTable'))

O$APTable = list(type = 'TFD3Output' , title = 'Agent Profile', height = '1000px', sync = T, data = reactives$APTable, config = apcfg)
I$APApply = list(type = 'actionButton' , title = 'Apply Changes', icon = icon('check', 'fa-2x'), width = '80%', service = APApply.srv, cloth = centerAlign)
I$APUndo  = list(type = 'actionButton' , title = 'Undo Changes' , icon = icon('undo', 'fa-2x') , width = '80%', service = APUndo.srv, cloth = centerAlign)

######### Agent-Skill Matrix: #########
I$ASTab   = list(type = 'tabPanel', title = 'Agent-Skill Matrix', layout = 'ASPage')
I$ASPage  = list(type = 'fluidPage', layout = list(list('ASApply', 'ASUndo'), 'ASTable'))

O$ASTable = list(type = 'TFD3Output' , title = 'Agent-Skill Matrix', weight = 9, height = '1000px', data = reactives$ASTable, config = ASConfig(x), sync = T)
I$ASApply = list(type = 'actionButton'        , title = 'Apply Changes', icon = icon('check', 'fa-2x'), width = '80%', service = ASApply.srv, cloth = centerAlign)
I$ASUndo  = list(type = 'actionButton'        , title = 'Undo Changes' , icon = icon('undo' , 'fa-2x'), width = '80%', service = ASUndo.srv, cloth = centerAlign)

######### CommSee Tasks: #########
I$CSTab      = list(type = 'tabPanel', title = 'CommSee Tasks', layout = 'CSPage')
#I$CSPage     = list(type = 'fluidPage', layout = list(list('CSApply', 'CSUndo', 'CSLoad'), 'CSTable'))
I$CSPage     = list(type = 'fluidPage', layout = list(list('CSLoad', 'CSClear'), 'CSTable'))

# O$CSTable = list(type = 'dataTableOutput', title = 'CommSee Task List', height = '1200px', service = prescript %++% " ; session$userData$ota %>% taskList.table(session$userData$ota$skills[session$userData$ota$SP$skillType == 'CommSee'], sessionobj = session)")
O$CSTable = list(type = 'dataTableOutput', title = 'CommSee Task List', height = '1200px', service = prescript %++% " ; session$userData$ota %>% taskList.table(session$userData$ota$skills[session$userData$ota$SP$skillType == 'CommSee'])")
I$CSClear = list(type = 'actionButton', title = 'Clear all CommSee tasks', icon = icon('eraser', 'fa-2x'), width = '80%',cloth = centerAlign, service = CSClear.srv)
I$CSUndo  = list(type = 'actionButton', title = 'Undo Changes' , icon = icon('undo' , 'fa-2x') , width = '80%' ,cloth = centerAlign)
I$CSLoad  = list(type = 'fileInput'   , title = 'Read from Excel or CSV', multiple = T, service = CSLoad.srv, cloth = centerAlign)

######### Manual New Tasks: #########

I$MNTab   = list(type = 'tabPanel' , title = 'Manual New Tasks', layout = 'MNPage')
I$MNPage  = list(type = 'fluidPage', layout = list(list('MNSkill', 'MNAdd', 'MNDel', 'MNApply', 'MNUndo'), 'MNTable'))

O$MNTable = list(type = 'TFD3Output' , title = 'Manual New Tasks', height = '1000px', data = reactives$MNTable, config = MNConfig(x), sync = T)
# O$MNTable = list(type = 'rHandsonTableOutput' , title = 'Manual New Tasks', height = '1000px', width = '100%', service = "sync$MNTable %>% MNTable.srvf(session$userData$ota)")

I$MNSkill = list(type = 'selectInput'  , title = 'Select Skill:', width = '80%', choices = x$SP$skillName[x$SP$skillType == 'Manual'], selected = 1)
I$MNAdd   = list(type = 'actionButton' , title = 'Add Row'      , icon = icon('plus' , 'fa-2x')  , width = '80%', service = MNAdd.srv , cloth = centerAlign)
I$MNDel   = list(type = 'actionButton' , title = 'Delete Row'   , icon = icon('trash' , 'fa-2x') , width = '80%', service = MNDel.srv , cloth = centerAlign)
I$MNApply = list(type = 'actionButton' , title = 'Apply Changes', icon = icon('check' , 'fa-2x') , width = '95%', service = MNApply.srv , cloth = centerAlign)
I$MNUndo  = list(type = 'actionButton' , title = 'Undo Changes' , icon = icon('undo' , 'fa-2x')  , width = '95%', service = MNUndo.srv, cloth = centerAlign)

######### Manual Leftover Tasks: #########
I$MLTab   = list(type = 'tabPanel' , title = 'Manual Leftovers', layout = 'MLPage')
I$MLPage  = list(type = 'fluidPage', layout = list(list('MLApply', 'MLUndo'), 'MLTable'))

O$MLTable = list(type = 'TFD3Output' , title = 'Manual Leftovers', height = '1000px', data = reactives$MLTable, config = MLConfig(reactives$MLTable), sync = T)

I$MLApply = list(type = 'actionButton' , title = 'Apply Changes', icon = icon('check' , 'fa-2x') , width = '95%', service = MLApply.srv, cloth = centerAlign)
I$MLUndo  = list(type = 'actionButton' , title = 'Undo Changes' , icon = icon('undo' , 'fa-2x')  , width = '95%', service = MLUndo.srv, cloth = centerAlign)

######### Task Overview: #########
I$TOTab   = list(type = 'tabPanel' , title = 'Task Overview', layout = 'TOPage')

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

I$allocate = list(type = 'actionButton', title = 'Allocate Tasks'  , icon = icon('user-plus' , 'fa-2x'), width = '80%', cloth = centerAlign, service = allocate.srv)
I$balanced = list(type = 'checkboxInput', title = 'Balance Utilization'  , value = F, width = '80%')
I$clear    = list(type = 'actionButton', title = 'Clear Allocation', icon = icon('eraser' , 'fa-2x')   , width = '80%', cloth = centerAlign, service = clear.srv)
# OTS Stands for Overall Task Summary
O$OTS        = list(type = 'dataTableOutput'   , title = 'Skill Profile', width = 'auto', height = '400px', service = OTS.srv, weight = 12)
O$ageBar     = list(type = 'highcharterOutput' , title = 'Age Bar'      , width = 'auto', height = '400px', service = paste(prescript, "session$userData$ota %>% age.bar(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';'))
O$dueAgeBar  = list(type = 'highcharterOutput' , title = 'Due Age Bar'  , width = 'auto', height = '400px', service = paste(prescript, "session$userData$ota %>% dueAge.bar(rownames(session$userData$ota$SP)[input$OTS_rows_selected])", sep = ';'))

######### Allocation Pivot Table: #########

I$APTTab   = list(type = 'tabPanel' , title = 'Allocation Pivot Table', layout = 'APTPage')

I$APTPage  = list(type = 'fluidPage', layout = 'pivot')

O$pivot      = list(type = 'pivotOutput'  , title = 'Pivot Table View', width = 'auto', height = '1000px', weight = 12, service = paste(prescript, "session$userData$ota %>% alloc.pivot", sep = ";"))

######### Allocation Overview 2: #########

I$AOTab   = list(type = 'tabPanel' , title = 'Allocation Overview', layout = 'AOPage')

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

#O$ACW        = list(type = 'coffeewheelOutput' , title = 'Allocation Wheel', width = 'auto', height = '750px', weight = 12, cloth = sunbox, service = paste(prescript, "session$userData$ota %>% allocation.coffeewheel", sep = ";"))
#O$agentBar   = list(type = 'highcharterOutput' , title = 'Agent Bar', width = 'auto', height = '750px', weight = 12, cloth = sunbox, service = agentBar.srv)
#O$skillBar   = list(type = 'highcharterOutput' , title = 'Skill Bar', width = 'auto', height = '750px', weight = 12, cloth = sunbox, service = paste(prescript, "session$userData$ota %>% skill.bar", sep = ';'))

O$ACW        = list(type = 'coffeewheelOutput' , title = 'Allocation Wheel', width = 'auto', height = '750px', weight = 12, service = paste(prescript, "session$userData$ota %>% allocation.coffeewheel", sep = ";"))
O$agentBar   = list(type = 'highcharterOutput' , title = 'Agent Bar', width = 'auto', height = '750px', weight = 12, service = agentBar.srv)
O$skillBar   = list(type = 'highcharterOutput' , title = 'Skill Bar', width = 'auto', height = '750px', weight = 12, service = paste(prescript, "session$userData$ota %>% skill.bar", sep = ';'))

######### Event Observers: #########
OB = character()
OB[1] = "
if(is.null(sync$user)){
isolate({
dash$hideItems('getTeam', 'getDate', 'read', 'write', 'export'); 
sync$ALCD = NULL; sync$ALCT = NULL;
sync$message  = messages['initial']; 
session$userData$ota %<>% clearAllTasks; 
sync$trigger = sync$trigger + 1
# debug(check);check(title = 'I am in OB1', session = session, sync = sync)
})
} else {
isolate({
dash$showItems('lhide','getDate', 'getTeam', 'read', 'write', 'export'); 
items[['ASTable']]$config <<- ASConfig(session$userData$ota)
items[['MLTable']]$config <<- MLConfig(sync$MLTable)
# sync$trigger = sync$trigger + 1})
sync$message <<- messages['loginSuccess']})
}"

OB[2] = "
if(!is.null(sync$ALCD) & !is.null(sync$ALCT)){
isolate({
sync$message <<- 'Dataset successfully loaded for Team:' %>% paste(teamTable[sync$ALCT, 'TEAMNAME'], 'Allocation Date:', sync$ALCD) 
dash$enableItems('write', 'export'); dash$hideItems('EMTab')
dash$showItems('CSTab', 'SPTab', 'APTab', 'ASTab', 'TOTab', 'APTTab','AOTab'); updateNavbarPage(session, 'menu', selected = 'CSTab')
if(sum(session$userData$ota$SP$skillType == 'Manual') > 0){dash$showItems('MLTab', 'MNTab')} else {dash$hideItems('MLTab', 'MNTab')}
updateSelectInput(session, 'getTeam', selected = sync$ALCT)
updateDateInput(session, 'getDate'  , value = sync$ALCD)
updateSelectInput(session, 'MNSkill', choices = session$userData$ota$SP$skillName[session$userData$ota$SP$skillType == 'Manual'])
})} else {isolate({
dash$disableItems('write', 'export'); dash$hideItems('lhide', 'CSTab', 'MNTab', 'MLTab', 'SPTab', 'APTab', 'ASTab', 'TOTab', 'APTTab','AOTab', 'getDate', 'getTeam', 'read', 'write', 'export')
dash$showItems('EMTab')
# debug(check);check(title = 'I am in OB2', session = session, sync = sync)
updateNavbarPage(session, 'menu', selected = 'EMTab')
})}
"

OB[3] = paste("avl = (sync$APTable$scheduled*sync$APTable$utilFactor - sync$APTable$reserved) %>% sapply(max, 0) %>% as.numeric",
              "if(!identical(sync$APTable$available, avl)){sync$APTable$available = avl}", sep = '\n')
OB[4] = paste("if(report$MNTable_lastEdits['Success','Column'] == 3){isolate({
              rw = report$MNTable_lastEdits['Success','Row'] %>% as.integer
              sync$MNTable$due[rw] = time2Char(as.time(sync$MNTable$start[rw], target_class = 'POSIXct') + 24*3600*session$userData$ota$SP[sync$MNTable[rw, 'skill'], 'SLA'])
              # debug(check); check(x = 'In obs3', s = sync, r = report, o = session$userData$ota)
              })}", sep = '\n')

OB[5] = paste("mnda = sync$MNTable$report %>% setTZ('GMT') %>% diffTime(sync$MNTable$due %>% as.time(target_class = 'POSIXct'), units = 'hours', holidays = holidays) %>% round(digits = 2) %>% as.numeric",
              "if(!identical(sync$MNTable$dueAge, mnda)){sync$MNTable$dueAge  <- mnda}", sep = '\n')
OB[6] = paste(prescript, "isolate({", 
              "reactives    = session$userData$ota %>% obj2Reactives",
              "sync$SPTable = reactives$SPTable",
              "sync$APTable = reactives$APTable",
              "items[['ASTable']]$config <<- ASConfig(session$userData$ota)",
              "items[['MLTable']]$config <<- MLConfig(reactives$MLTable)",
              "sync$ASTable = reactives$ASTable",
              "sync$MNTable = reactives$MNTable",
              "sync$MLTable = reactives$MLTable", 
              "})", sep = '\n')

OB[7] = "sync$MLTable$Total = rowSums(sync$MLTable[, - ncol(sync$MLTable), drop = F])"

# OB[8] = "print(input$goto)"

######### Build Dashboard: #########

dash   <- new('DASHBOARD', items = c(O, I), king.layout = list('main'), observers = OB, objects = list(ota = x), values = val, loginTable = logt, messages = messages, settings = list(savingPath = 'data/', passEncryption = 'bcrypt'))
ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()
app    <- shinyApp(ui, server)

######### Run: #########

# runApp(app)
# runApp(app, host = "0.0.0.0", port = 8080)

# options(browser = "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe")
# runApp(list(ui=ui, server=server), launch.browser = T)



### iotools.R ---------------------
# Header
# Filename:      iotools.R
# Description:   This module provides functions for extractiion and modfication of data
#                from GDW, datamart or any other source of data in abc required for SO project.
# Authors:       Nicolas Berta , Timothy Pope, Kelumi Harshika, Mustafizur Rahman
# Emails :       nicolas.berta@abc.com 
# Start Date:    25 January 2017
# Last Revision: 21 July 2018
# Version:       2.8.1

# Version   Date               Action
# -----------------------------------
# 1.0.0     25 January 2017    Initial issue
# 1.0.1     01 February 2017   Function to be written 
# 2.0.0     01 August  2017    Functions obj2Recatives(), reactives2Obj(), dataset2Obj(), ... added.
# 2.1.0     01 August  2017    read functions generalized by parametrised SQL to provide data for given date and set of teams.
# 2.1.1     01 August  2017    Functions readAgentHistCount(), readAgentHistCount.discharges(), readAgentRoster.discharges(), readTaskBacklog(), feedabc.OptimalTaskAllocator()
# 2.1.2     01 August  2017    extension '.Maneli' removed from function names. argument 'teamstr' added to all functions.
# 2.1.3     01 August  2017    Function loadData() modified: gets 'teamstr' as an argument. Currently only works for a single team!
# 2.1.4     29 August  2017    Function readTaskListFromCSV() added. Written by Kelumi
# 2.1.5     31 August  2017    Function loadData() modified: character class for argument Date is accepted as well
# 2.2.0     08 September 2017  Data input functions modified to pull data from the new SQL server: SODEV
# 2.2.1     11 September 2017  Function readTaskListFromCSV() updated to accommodate changes in the database
# 2.2.2     11 September 2017  Function applyCSVTable2Obj() added
# 2.2.3     12 September 2017  Function clearCommSeeTasks() added
# 2.2.4     13 September 2017  Function readTeams() added
# 2.2.5     22 September 2017  Function readCommSeeTasks added to read both csv and xls files for CommSee tasks
# 2.2.6     25 September 2017  Function exportToDatabase added with the upload functions to write dashboard data to database
# 2.3.0     26 September 2017  Functions readManualLOTasks(), readManualOpenTasks() and readOpenCommSeeTasks() added!
# 2.3.1     26 September 2017  argument teamstr renamed to teamID
# 2.3.2     11 October 2017    All arguments agent_col renamed to agentID_col
# 2.3.3     11 October 2017    All arguments skill_col renamed to skillID_col
# 2.3.4     12 October 2017    Rescheduled flag logic is implemented for Credit Card Verification Team
# 2.3.5     13 October 2017    allocateTeamInfo function is called inside readManualLOTasks(), readManualOpenTasks() and readOpenCommSeeTasks()
# 2.3.6     13 October 2017    Function readTaskListFromCSV() is deleted
# 2.3.7     16 October 2017    Function dataset2Obj() modified: Used to give wrong column names when AP and SP were empty
# 2.3.8     24 October 2017    Function readCommSeeTasks() modified: stops with adequate error messages 
# 2.3.9     24 October 2017    Function readCommSeeTasks() modified: Changed the logic for determining Workable flag
# 2.3.10    24 October 2017    Function readCommSeeTasks() modified: Report date issue fixed! 
# 2.3.11    24 October 2017    All dates are referenced to Sydney time(AEDT)
# 2.4.0     30 October 2017    Functions addRow2MNTable() and addRow2MLTable() transferred from otavis.R
# 2.4.1     30 October 2017    Function  addRow2MNTable() modified: Takes care of different levels in column skillName when inherits factor
# 2.4.2     01 November 2017   Skill ID and Agent ID columns are added to CSTable
# 2.4.3     01 November 2017   Skill ID and Agent ID are passed instead of skill name and agent name for CSTable write to server feature
# 2.4.4     06 November 2017   SLA column added to SPTable and Due date for ML and MN tasks are calculated based on start date and SLA days
# 2.4.5     06 November 2017   Workable Flag for CommSee task read from database logic is updated
# 2.4.6     08 November 2017   Utilisation factor value is read from database
# 2.4.7     08 November 2017   Start and Due dates are shown in AEDT on CommSee, ML and MN tables as all dates are referenced to GMT
# 2.4.8     14 November 2017   MNTable start and due times are presented as character
# 2.5.0     14 November 2017   MLTable changed to matrix form
# 2.6.0     21 November 2017   Export to excel file feature added by Fiz
# 2.6.1     21 November 2017   Export to excel prompts for selecting a directory for the file to be saved 
# 2.6.2     21 November 2017   Respects public holidays in computing time difference using function diffTime() from gener
# 2.6.3     11 December 2017   All date-times converted to GMT to avoid daylight change problem
# 2.6.4     19 December 2017   Fiz added more skills and changed the due date logic for those skills
# 2.6.5     08 January 2018    (due date = start date + sla) for HLX Sell skill for CCV team: logic is implemented
# 2.6.6     25 January 2018    export to excel file function now includes task breakdown for each skill in agent summary tab
# 2.6.7     12 February 2018   Function readCommSeeTasks() modified: Argument 'tempPath' added to specify a user-defined path for temporarily saving uploaded failes on the server
# 2.6.8     19 April 2018      Function readCommSeeTasks() modified: Verifies column names of the read table to make sure it contains list of required columns
# 2.6.9     20 April 2018      Function writeAllocationReport() modified: Only keeps newAllocated and leftover tasks in the excel report files
# 2.7.0     08 May 2018        Function uploadAllocations() modified: Only writes allocated tasks to the database 
# 2.7.1     08 May 2018        Function applMN() modified: clearAllocation is called with argument update = F because the following call of feedTasks() updates argent utilisation and task counts
# 2.7.2     28 May 2018        Function loadData() modified: Generates empty POSIXct in variable et
# 2.8.0     20 July 2018       Changes made by Tim Pope 
# 2.8.1     24 July 2018       Extension converted to lowercase
# -----------------------------------


library(gener)

support('magrittr', 'dplyr', 'RODBC', 'RODBCext', 'pracma', 'stringr', 'readxl', 'tools')

readAgents = function(date = Sys.Date(), teamID = NULL, ...){
  qry = "EXEC  rshiny.GETEMPLOYEELIST '" %>% paste0(teamID, "','", date %>% as.character, "'")  
  channel = odbcConnect(...)
  
  AG      = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(AG)  
}

readSkills = function(date = Sys.Date(), teamID = NULL, ...){
  qry = "EXEC  rshiny.GETSKILLLIST '" %>% paste0(teamID, "','", date %>% as.character, "'")  
  channel = odbcConnect(...)
  
  TBL      = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(TBL)  
}

readAgentSchedule = function(date = Sys.Date(), teamID = NULL, ...){
  qry = "EXEC  rshiny.GETEMPLOYEESCHEDULE '" %>% paste0(teamID, "','", date %>% as.character, "'")  
  channel = odbcConnect(...)
  
  TBL      = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(TBL)  
}

readAgentTAT = function(date = Sys.Date(), teamID = NULL, ...){
  qry = "EXEC  rshiny.GETSKILLMATRIX '" %>% paste0(teamID, "','", date %>% as.character, "'")  
  channel = odbcConnect(...)
  
  TBL      = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(TBL)  
}

readTaskFiles  = function(Team = NULL, files = character(), names = character(), tempPath = file.path(getwd(), 'temp'),Date=NULL, ...) {
  #Set our variables
  requiredColumnsCSE = c("Start","Due","Process.ID","Work.Item.Type","Assigned.To")#,"Self.Employed") #CommSee
  requiredColumnsCMSRBSDQI = c("Account" , "Customer.ID" , "Collateral.Address" , "CMS.CT" , "Cleansed.CT" , "Missing.Valuation" , 
                               "Property.Missing.CT" , "No.CMS.Data" , "Account.Balance" , "Account.Limit" , "DQI.Creation.Date" , "Age" ,
                               "Recurring.DQI." , "Status" , "Completion.Date" , "Allocated.To" , "Comments")
  validExtensions.xl <- c('xls','xlsx','xlsm') 
  validExtensions.FF <- c('csv')
  validExtensions <- c(validExtensions.xl,validExtensions.FF )
  # format the report date to AEDT
  # DateTime  <- Date %>% setTZ('GMT') %>% as.POSIXct(format="%d/%m/%Y %H:%M")
  DateTime  <- Date %>% as.character %>% as.time(tz = 'GMT')
  #Date <- as.POSIXct(Date, tz="GMT")
  # Copy the files from the tmp folder to a temp folder in working directory
  # It is required as the files in the tmp folder do not have any extension,
  # and renaming is not allowed in tmp folder.
  if (!file.exists(tempPath)){
    dir.create(tempPath)
  } 
  ow.orig <- data.frame()
  ## Reading Data 
  for (i in seq(files))
  {
    # Read CSV files
    extension <- file_ext(names[i]) %>% tolower
    #print(names[i])
    #print(extension)
    # Create the absolute path of the destination data file
    srcFile <- files[i]
    dstFile <- tempPath %>% file.path(names[i])
    # Copy the data file from tmp folder to destination folder
    file.copy(srcFile, dstFile, overwrite = TRUE)
    #print(dstFile)
    if(extension %in% validExtensions){
      if(extension %in% validExtensions.FF)
      {
        csvFile <- read.csv(file = dstFile, header=TRUE, sep=",")   
        ow.read <- data.frame(csvFile)  
        print("csv file loaded")
      }else if(extension %in% validExtensions.xl)
      {
        
        xlFile <- read_excel(path = dstFile) 
        ow.read <- data.frame(xlFile)
        print("excel file loaded")
        
      }
      # Delete the data file from the temp folder in working directory after loading
      file.remove(dstFile)
      if (requiredColumnsCMSRBSDQI %<% colnames(ow.read) & Team == 'CSETM1665680' ) {
        ow.read %<>% mutate(Datasource = 'CMS RBS DQI Report')
      } else if (requiredColumnsCSE %<% colnames(ow.read) ) {
        ow.read %<>% mutate(Datasource = 'CSE')  
        ## Add more data sources here as required  will need to add FCO
      } else {stop(paste0("There is an error processing file: ",names[i]),call.=F)}
      # We create a list of dataframes
      if (i==1) {
        df.collection <- list(ow.read)
      } else {
        df.collection[[i]] <- ow.read
      }
    } else{
      stop("The file format must be xls or csv", call. = F)
    }
  }
  return(df.collection)
}

CategoriseCommSeeTasks  = function(Date = NULL, Team = NULL, SourceDataFrame = NULL ,skills=NULL,...){
  skilldf <- transmute(skills,Skill_ID=row.names(skills),SKILL_M=skillName )
  SourceDataFrame$Skill_ID <- 0
  if (Team=="CSETM1078933"){
    #Add custom columns for processing if required!
    if (is.null(SourceDataFrame$Self.Employed)) {SourceDataFrame$"Self.Employed" =NA }
    #skill mappings!!
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CLI Document Verification"    & SourceDataFrame$Self.Employed=="Y" ,"Skill_ID"]   <-11
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CLI Document Verification"    & SourceDataFrame$Self.Employed=="N" ,"Skill_ID"]   <-12
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CLI Internal Verification"    & SourceDataFrame$Self.Employed=="Y" ,"Skill_ID"]   <-13
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CLI Internal Verification"    & SourceDataFrame$Self.Employed=="N" ,"Skill_ID"]   <-14
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC Document Verification"     & SourceDataFrame$Self.Employed=="Y" ,"Skill_ID"]   <-15
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC Document Verification"     & SourceDataFrame$Self.Employed=="N" ,"Skill_ID"]   <-16
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC Internal Verification"     & SourceDataFrame$Self.Employed=="Y" ,"Skill_ID"]   <-17
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC Internal Verification"     & SourceDataFrame$Self.Employed=="N" ,"Skill_ID"]   <-18
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC Docs Received Orphan"      & is.na(SourceDataFrame$Self.Employed) ,"Skill_ID"] <-19
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="Client Request"               & is.na(SourceDataFrame$Self.Employed) ,"Skill_ID"] <-20
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC Written Consent Exception" & is.na(SourceDataFrame$Self.Employed) ,"Skill_ID"] <-22
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC Pending Documents"         & is.na(SourceDataFrame$Self.Employed) ,"Skill_ID"] <-23
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CLI Pending Documents"        & is.na(SourceDataFrame$Self.Employed) ,"Skill_ID"] <-24
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="Client Follow Up"             & is.na(SourceDataFrame$Self.Employed) ,"Skill_ID"] <-55
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="CC HL Cross Sell Diary" ,"Skill_ID"]                                     <-56
  }
  if (Team=="CSETM1318950"){
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="TU After Care" ,"Skill_ID"]                                          <-4
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="Client Request" ,"Skill_ID"]                                         <-5
  }
  if (Team=="CSETM862624"){
    SourceDataFrame[SourceDataFrame$Work.Item.Type=="LM Update CMS" ,"Skill_ID"]                                          <-25
  }
  if (Team=="CSETM4419010"){
    if (is.null(SourceDataFrame$Request.Type)) {SourceDataFrame$"Request.Type" =NA }
    
    SourceDataFrame[SourceDataFrame$Assigned.To=="MORTGAGE SERVICES PROPRIETARY APPS & DOCS (PERTH)" & SourceDataFrame$Work.Item.Type=="HL Update CMS Details" ,"Skill_ID"] <- 49 #RBS Update CMS
    SourceDataFrame[SourceDataFrame$Assigned.To=="MORTGAGE SERVICES PROPRIETARY APPS & DOCS (PERTH)" & SourceDataFrame$Work.Item.Type=="TU Update CMS" ,"Skill_ID"] <- 50 #TU Update CMS
    SourceDataFrame[SourceDataFrame$Assigned.To %in% c("MORTGAGE SERVICES DISCH BRANCH AFTERCARE (SYD)","MORTGAGE SERVICES DISCH BRANCH AFTERCARE (QLD)","MORTGAGE SERVICES DISCH BRANCH AFTERCARE (ADL)","MORTGAGE SERVICES DISCH BRANCH AFTERCARE (MELB)") & SourceDataFrame$Work.Item.Type=="LM Update CMS" & SourceDataFrame$Request.Type=="Partial Discharge" ,"Skill_ID"] <- 51 #Partial Discharge CMS
    SourceDataFrame[SourceDataFrame$Assigned.To=="MORTGAGE SERVICES PROPRIETARY APPS & DOCS (PERTH)" & SourceDataFrame$Work.Item.Type=="TU Review CMS" ,"Skill_ID"] <- 52 #TU Review CMS
    
    SourceDataFrame[SourceDataFrame$Assigned.To=="MORTGAGE SERVICES DISCH BRANCH AFTERCARE (SYD)" & SourceDataFrame$Work.Item.Type=="LM Aftercare (Discharges, Switches)" & SourceDataFrame$Request.Type=="Full Discharge" ,"Skill_ID"] <- 42 # Full Discharge Aftercare NSW
    SourceDataFrame[SourceDataFrame$Assigned.To=="MORTGAGE SERVICES DISCH BRANCH AFTERCARE (QLD)" & SourceDataFrame$Work.Item.Type=="LM Aftercare (Discharges, Switches)" & SourceDataFrame$Request.Type=="Full Discharge" ,"Skill_ID"] <- 43 # Full Discharge Aftercare QLD
    SourceDataFrame[SourceDataFrame$Assigned.To=="MORTGAGE SERVICES DISCH BRANCH AFTERCARE (ADL)" & SourceDataFrame$Work.Item.Type=="LM Aftercare (Discharges, Switches)" & SourceDataFrame$Request.Type=="Full Discharge" ,"Skill_ID"] <- 44 # Full Discharge Aftercare SA
    SourceDataFrame[SourceDataFrame$Assigned.To=="MORTGAGE SERVICES DISCH BRANCH AFTERCARE (MELB)" & SourceDataFrame$Work.Item.Type=="LM Aftercare (Discharges, Switches)" & SourceDataFrame$Request.Type=="Full Discharge" ,"Skill_ID"] <- 45 # Full Discharge Aftercare VIC
    SourceDataFrame[SourceDataFrame$Assigned.To=="DISCH PARTIAL AFTERCARE ACTIONABLE WIM NSW" & SourceDataFrame$Work.Item.Type=="LM Aftercare (Discharges, Switches)" ,"Skill_ID"] <- 46 # Partial Discharge Aftercare
    SourceDataFrame[SourceDataFrame$Assigned.To=="BLSS DISCHARGES COMPLETION" & SourceDataFrame$Work.Item.Type=="Client Request"  ,"Skill_ID"] <- 47 # Commercial Discharge Aftercare
    SourceDataFrame[SourceDataFrame$Assigned.To=="BLSS DISCHARGES DAY 2 AFTERCARE" & SourceDataFrame$Work.Item.Type=="Client Request","Skill_ID"] <- 48 # Commercial Discharge Aftercare Follow Up 
    
  }
  if ('SKILL_M' %in% colnames(SourceDataFrame)) {SourceDataFrame = subset(SourceDataFrame,select = -c(SKILL_M))}
  print("before merge categorise")
  SourceDataFrame %<>% merge(skilldf,by='Skill_ID',all.x=TRUE) #Adds in the skill name
  print("after merge categorise")
  return(SourceDataFrame)
}  

CommSeeCMSLeftovers = function(Team = NULL, SourceDataFrame=NULL,skills=NULL,AgentProfile=NULL,...) {
  #no point doing it if everything has been classified
  if (Team=="CSETM4419010" & nrow(SourceDataFrame[SourceDataFrame$Skill_ID==0,])>0) {
    print("start CMS Leftover Calc")
    SourceDataFrame[SourceDataFrame$Assigned.To %in% AgentProfile$agentName & SourceDataFrame$Work.Item.Type=="LM Aftercare (Discharges, Switches)" & SourceDataFrame$Request.Type=="Partial Discharge" & SourceDataFrame$Skill_ID==0 ,"Skill_ID"] <- 46
    #We will assume all Client Requests are Commercial Discharge Aftercare and not follow ups as we can't identify and follow ups have lower unit time so we will be conservative!
    SourceDataFrame[SourceDataFrame$Assigned.To %in% AgentProfile$agentName & SourceDataFrame$Work.Item.Type=="Client Request" & SourceDataFrame$Skill_ID==0 ,"Skill_ID"] <- 47
    #Assume NSW as this takes the longest time
    SourceDataFrame[SourceDataFrame$Assigned.To %in% AgentProfile$agentName & SourceDataFrame$Work.Item.Type=="LM Aftercare (Discharges, Switches)" & SourceDataFrame$Request.Type=="Full Discharge" & SourceDataFrame$Skill_ID==0 ,"Skill_ID"] <- 42
    #
    SourceDataFrame[SourceDataFrame$Assigned.To %in% AgentProfile$agentName & SourceDataFrame$Work.Item.Type=="HL Update CMS Details" & SourceDataFrame$Skill_ID==0 ,"Skill_ID"] <- 49
    SourceDataFrame[SourceDataFrame$Assigned.To %in% AgentProfile$agentName & SourceDataFrame$Work.Item.Type=="TU Update CMS" & SourceDataFrame$Skill_ID==0 ,"Skill_ID"] <- 50
    SourceDataFrame[SourceDataFrame$Assigned.To %in% AgentProfile$agentName & SourceDataFrame$Work.Item.Type=="LM Update CMS" & SourceDataFrame$Request.Type=="Partial Discharge" &  SourceDataFrame$Skill_ID==0 ,"Skill_ID"] <- 51
    SourceDataFrame[SourceDataFrame$Assigned.To %in% AgentProfile$agentName & SourceDataFrame$Work.Item.Type=="TU Review CMS" & SourceDataFrame$Skill_ID==0 ,"Skill_ID"] <- 52
  }
  print("end CMS Leftover Calc") 
  return(SourceDataFrame)
  
}

CommSeeAssignedTo = function(SourceDataFrame = NULL,Team = NULL, AgentProfile = NULL,...){
  AgentsDF <- AgentProfile[,c("scheduled","agentName")] %>% mutate(agentID=row.names(.))
  print("before merge assignedto")
  ow <- merge(SourceDataFrame,AgentsDF,by.x="Assigned.To",by.y="agentName",all.x=TRUE)
  if (Team=="CSETM1078933"){
    ow %<>% mutate(agentID=ifelse(scheduled==0,NA,agentID)) 
  }
  ow <- ow[,!(names(ow) %in% c("scheduled"))]
  print("after merge assignedto")
  return(ow)
}


CommSeeOtherColumns = function(SourceDataFrame = NULL, Team = NULL, Date=NULL){
  DateTime  <- Date %>% as.character %>% as.time(tz = 'GMT')
  SourceDataFrame$Start %<>% as.time(tz = 'GMT')
  SourceDataFrame$Due   %<>% as.time(tz = 'GMT')
  #not sure if age due is actually used or if logic is replicated downstream!
  SourceDataFrame %<>% mutate(Age_Due = ifelse(as.Date(Due)==as.Date(DateTime),0,diffTime(Due, DateTime, units = "days", holidays = holidays)))
  SourceDataFrame %<>% mutate(ALLOCATED_FLAG = ifelse(agentID==NA,0,1))
  SourceDataFrame %<>% mutate(DUE_FLAG = as.Date(Due) <= as.Date(DateTime) )
  #legacy code for RSHD_FLAG
  RSHD_FLAG = SourceDataFrame$Start == SourceDataFrame$Start %>% as.Date %>% as.character %>% as.POSIXct(tz = 'GMT') 
  SourceDataFrame$RSHD_FLAG[RSHD_FLAG==TRUE] <- 1
  SourceDataFrame$RSHD_FLAG[RSHD_FLAG==FALSE]<- 0
  # after the merge Start and Due dates becomes numeric; so convert these to date format
  if(SourceDataFrame$Start %>% inherits('numeric')){SourceDataFrame$Start %<>% as.POSIXct(origin = '1970-01-01', tz = 'GMT')}
  if(SourceDataFrame$Due   %>% inherits('numeric')){SourceDataFrame$Due   %<>% as.POSIXct(origin = '1970-01-01', tz = 'GMT')}
  ## Report Date is allocation date
  if(is.empty(SourceDataFrame)){SourceDataFrame$Report_d = numeric()} else {SourceDataFrame$Report_d = Date}  
  SourceDataFrame$Workable = !(SourceDataFrame$RSHD_FLAG & !SourceDataFrame$DUE_FLAG)
  #bring in appl id through the related to column but strip out client details in CR
  if (is.null(SourceDataFrame$Related.To)) {SourceDataFrame$"Related.To" =NA }
  SourceDataFrame[SourceDataFrame$Work.Item.Type=="Client Request","Related.To"] <- NA
  #only carry through required columns
  SourceDataFrame %<>% dplyr::select(Process.ID,Skill_ID ,Start,Due ,Age_Due,Report_d,agentID,Workable,Related.To) %>% dplyr::rename(EMPLOYEEID=agentID)
  return(SourceDataFrame)
}



ProcessAllCommSeeTasks = function (SourceDataFrame = NULL,Team=NULL,skills=NULL,AgentProfile=NULL,Date=NULL) {
  #function maps all the Commsee functions together!
  SourceDataFrame %<>% CategoriseCommSeeTasks(Team=Team,SourceDataFrame=.,skills=skills) %>%
    #CommSeeCMSLeftovers(Team = Team, SourceDataFrame=.,skills=skills,AgentProfile=AgentProfile) %>%
    CommSeeAssignedTo(SourceDataFrame=.,Team=Team,AgentProfile=AgentProfile) %>%
    CommSeeOtherColumns(SourceDataFrame=.,Team=Team,Date=Date)    
  return(SourceDataFrame)
}


CombineAllTasks = function(TaskCollection = NULL,Team=NULL,skills=NULL,AgentProfile=NULL,Date=NULL){
  #df.collection
  for (i in 1:length(TaskCollection)) {
    ow <- TaskCollection[[i]] #I'm creating a duplicate so I don't get confused!
    if (ow[1,"Datasource"] =='CSE') {
      ow <- ProcessAllCommSeeTasks(SourceDataFrame = ow,Team=Team,skills=skills,AgentProfile=AgentProfile,Date=Date)
    } else { #do nonCommSee processing
      print("NonCommSee File!")
    }
    if (i==1) {
      CombinedTaskDF <- ow
    } else {
      CombinedTaskDF <- rbind(CombinedTaskDF,ow) 
    }
  }
  return(CombinedTaskDF)
}



readTaskFilesAndProcess = function(Team = NULL, files = character(), names = character(), tempPath = file.path(getwd(), 'temp'),skills=NULL,AgentProfile=NULL,Date=NULL,...) {
  
  CombinedTaskList<- readTaskFiles(Team = Team, files = files, names = names, tempPath = tempPath,Date=Date) %>%
    CombineAllTasks(TaskCollection = .,Team=Team,skills=skills,AgentProfile=AgentProfile,Date=Date)
  return(CombinedTaskList)
}

readManualLOTasks = function(date = Sys.Date(), teamID = NULL, alloc_id = NULL, ...){
  # Get the allocation id for a particular date and team
  if(is.null(alloc_id)){
    alloc_id = getAllocID(date, teamID, ...)
    allocateTeamInfo(alloc_id, teamID, ...)
  }
  
  qry = paste0("EXEC RSHINY.GETMANUALLOWIMS '" ,alloc_id,"'")  
  channel = odbcConnect(...)
  
  MLO      = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(MLO)  
}


readManualOpenTasks = function(date = Sys.Date(), teamID = NULL, alloc_id = NULL,...){
  # Get the allocation id for a particular date and team
  if(is.null(alloc_id)){
    alloc_id = getAllocID(date, teamID, ...)
    allocateTeamInfo(alloc_id, teamID, ...)
  }
  
  qry = paste0("EXEC RSHINY.GETMANUALOPENWIMS '" ,alloc_id,"'")  
  channel = odbcConnect(...)
  
  MOP      = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(MOP)  
}

readOpenCommSeeTasks = function(date = Sys.Date(), teamID = NULL, alloc_id = NULL,...){
  # Get the allocation id for a particular date and team
  if(is.null(alloc_id)){
    alloc_id = getAllocID(date, teamID, ...)
    allocateTeamInfo(alloc_id, teamID, ...)
  }
  
  qry = paste0("EXEC RSHINY.GETOPENCOMMSEEWIMS '" ,alloc_id,"'")  
  channel = odbcConnect(...)
  
  OCS      = sqlQuery(channel = channel, query = qry)
  close(channel)
  return(OCS)  
}

loadData = function(date = Sys.Date() - 1, teamID =  NULL, ...){
  
  if(!inherits(date, 'Date')){date %<>% as.Date}
  
  AP    = readAgents(date           , teamID = teamID, ...)
  gener::assert(inherits(AP, 'data.frame'), 'Loading list of agents failed! \n' %++% as.character(AP))
  SP    = readSkills(date           , teamID = teamID, ...)
  SP$RANK %<>% as.numeric 
  gener::assert(inherits(SP, 'data.frame'), 'Loading list of skills failed! \n' %++% as.character(SP))
  AA    = readAgentSchedule(date     , teamID = teamID, ...)
  gener::assert(inherits(AA, 'data.frame'), 'Loading agent schedule failed! \n' %++% as.character(AA))
  AS    = readAgentTAT(date         , teamID = teamID, ...)
  gener::assert(inherits(AS, 'data.frame'), 'Loading agent-skill matrix failed! \n' %++% as.character(AS))
  options(warn = -1)
  
  if(is.null(teamID)){
    MTS.L = data.frame()
    MTS   = data.frame()
    TL    = data.frame()
  } else {
    alloc_id = getAllocID(date, teamID, ...)
    allocateTeamInfo(alloc_id, teamID, ...)
    
    MTS.L = readManualLOTasks(alloc_id = alloc_id, ...)
    
    MTS = readManualOpenTasks(alloc_id = alloc_id, ...)
    
    TL  = readOpenCommSeeTasks(alloc_id = alloc_id, ...)
    
  }
  
  et = Sys.time()[-1]
  if(MTS.L %>% is.empty){
    MTS.L = data.frame(SKILLID = character(), SKILLNAME = character(), EMPLOYEEID = character(), AGE_DUE = numeric(), workable = logical(), 
                       START_DT   = et, DUE_DT = et, 
                       REPORT_D  = character() %>% as.Date, AGE = numeric(), WORK_UNITS = numeric())
  } else {
    MTS.L %<>% select(SKILLID, EMPLOYEEID, START_DT = STARTDATE, DUE_DT = DUEDATE, WORK_UNITS = WORKUNITS)    
    MTS.L$START_DT %<>% as.character %>% as.POSIXct(tz = 'GMT')
    MTS.L$DUE_DT   %<>% as.character %>% as.POSIXct(tz = 'GMT')
    MTS.L$REPORT_D    = date %>% as.Date
    MTS.L$workable   = T
  }
  
  if(MTS %>% is.empty){
    MTS   = data.frame(SKILLID = character(), SKILLNAME = character(), EMPLOYEEID = character(), AGE_DUE = numeric(), workable = logical(), 
                       START_DT  = et, DUE_DT = et, 
                       REPORT_D  = character() %>% as.Date, AGE = numeric(), WORK_UNITS = numeric())
  } else {
    MTS %<>% select(SKILLID, START_DT = STARTDATE, DUE_DT = DUEDATE, WORK_UNITS = WORKUNITS)    
    MTS$REPORT_D = date %>% as.Date
    MTS$START_DT %<>% as.character %>% as.POSIXct(tz = 'GMT')
    MTS$DUE_DT   %<>% as.character %>% as.POSIXct(tz = 'GMT')
    MTS$EMPLOYEEID = NA
    MTS$workable = T
  }
  
  if(is.empty(TL)){
    TL  = data.frame(SKILLID = character(), EMPLOYEEID = character(), PROCESS_ID = character(),
                     START_DT = et, END_DT = et, REPORT_D = character() %>% as.Date, 
                     DUE_DT   = et, AGE_DUE = numeric(), workable = logical())
  } else {
    TL %<>% select(SKILLID, EMPLOYEEID, PROCESS_ID = PROCESSID, START_DT = STARTDATE, DUE_DT = DUEDATE, STATUS = STATUS)  
    
    TL$START_DT %<>% as.POSIXct(tz = 'GMT') 
    TL$DUE_DT   %<>% as.POSIXct(tz = 'GMT') 
    
    TL$REPORT_D = date %>% as.Date
    TL$workable = TL$STATUS != 'notWorkable'
  }
  
  options(warn = 1)
  
  # Add Skill Priority Weights:
  # if(!('RANK' %in% names(SP))){SP$RANK = 0.0}
  
  # Mark Re-scheduled tasks which are not due as non-workable:
  # if(is.empty(TL)){TL$workable = logical()} else {TL$workable    = !TL$RSHD_FLAG | TL$DUE_FLAG}  
  # if(is.empty(MTS)){MTS$workable = logical()} else {MTS$workable   = !MTS$RSHD_FLAG | MTS$DUE_FLAG}
  # if(is.empty(MTS.L)){MTS.L$workable = logical()} else {MTS.L$workable = !MTS.L$RSHD_FLAG | MTS.L$DUE_FLAG}  
  # 
  # TL$AGE_DUE    %<>% as.numeric
  # MTS$AGE_DUE   %<>% as.numeric
  # MTS.L$AGE_DUE %<>% as.numeric
  
  out = list(SP = SP, AP = AP, AA = AA, AS = AS, CSTL = TL, MTS = MTS, MTS.L = MTS.L)
  return(out)
}

dataset2Obj = function(dataset){
  extra.sp = c(skillName = 'SKILLNAME', skillType = 'SKILLTYPE', teamID = 'TEAMID', teamName = 'TEAMNAME', PRW = 'RANK', SLA = 'SLATIME')
  extra.ap = c(agentName = 'EMPLOYEENAME', teamID = 'TEAMID', teamName = 'TEAMNAME')
  extra.cs = c(start = 'START_DT', due = 'DUE_DT', report = 'REPORT_D')
  extra.mn = c(start = 'START_DT', due = 'DUE_DT', report = 'REPORT_D')
  
  dataset$MTS$SKILLID    %<>% as.character
  dataset$MTS$EMPLOYEEID %<>% as.character
  dataset$MTS$START_DT   %<>% as.POSIXct
  dataset$MTS$DUE_DT     %<>% as.POSIXct
  dataset$MTS$REPORT_D   %<>% as.Date
  dataset$MTS$AGE_DUE    = dataset$MTS$REPORT_D %>% setTZ('GMT') %>% diffTime(dataset$MTS$DUE_DT, units = 'hours', holidays = holidays) %>% round(digits = 2)
  
  dataset$MTS.L$SKILLID    %<>% as.character
  dataset$MTS.L$EMPLOYEEID %<>% as.character
  dataset$MTS.L$START_DT %<>% as.POSIXct
  dataset$MTS.L$DUE_DT   %<>% as.POSIXct
  dataset$MTS.L$REPORT_D %<>% as.Date
  dataset$MTS.L$AGE_DUE  = dataset$MTS.L$REPORT_D %>% setTZ('GMT') %>% diffTime(dataset$MTS.L$DUE_DT,  units = 'hours', holidays = holidays) %>% round(digits = 2)
  
  dataset$CSTL$SKILLID    %<>% as.character
  dataset$CSTL$EMPLOYEEID %<>% as.character
  dataset$CSTL$START_DT %<>% as.POSIXct
  dataset$CSTL$DUE_DT   %<>% as.POSIXct
  dataset$CSTL$REPORT_D %<>% as.Date
  dataset$CSTL$AGE_DUE  = dataset$CSTL$REPORT_D %>% setTZ('GMT') %>% diffTime(dataset$CSTL$DUE_DT,  units = 'hours', holidays = holidays) %>% round(digits = 2)
  
  MTL   <- dataset$MTS   %>% taskSummary2TaskList(skillID_col = 'SKILLID', count_col = 'WORK_UNITS', priority_col = "AGE_DUE", agentID_col = 'EMPLOYEEID', extra_col = c('START_DT', 'DUE_DT', 'REPORT_D', 'workable'))
  MTL.L <- dataset$MTS.L %>% taskSummary2TaskList(skillID_col = 'SKILLID', count_col = 'WORK_UNITS', priority_col = "AGE_DUE", agentID_col = 'EMPLOYEEID', extra_col = c('START_DT', 'DUE_DT', 'REPORT_D', 'workable'), start_id = nrow(MTL) + 1)
  
  # This code is temporary! The values should change in the data
  # levels(dataset$SP$SKILLTYPE) = c('CommSee', 'Manual')
  
  x = 
    OptimalTaskAllocator() %>% 
    feedAgents(dataset$AP, agentID_col = 'EMPLOYEEID', extra_col = extra.ap) %>% 
    feedSkills(dataset$SP, skillID_col = 'SKILLID', extra_col = extra.sp) %>% 
    feedAgentSchedule(dataset$AA, agentID_col = 'EMPLOYEEID', scheduled_col = 'PRODUCTIONTIME', utilFactor_col = 'ALLOCATIONFACTOR') %>% 
    feedAgentTurnaroundTime(dataset$AS, agentID_col = 'EMPLOYEEID', skillID_col = 'SKILLID', tat_col = 'AUT') %>%
    feedTasks(dataset$CSTL, taskID_col = 'PROCESS_ID', skillID_col = 'SKILLID', priority_col = 'AGE_DUE', agentID_col = 'EMPLOYEEID', workable_col = 'workable', extra_col = extra.cs) %>% 
    feedTasks(MTL, skillID_col = 'skillID', priority_col = 'priority', agentID_col = 'alctdAgent', workable_col = 'workable', extra_col = extra.mn) %>%
    feedTasks(MTL.L, skillID_col = 'skillID', priority_col = 'priority', agentID_col = 'alctdAgent', workable_col = 'workable', extra_col = extra.mn) %>%
    addAgeProfiles %>% customizeTaskPriorities(skillPriorityWeight_column = 'PRW')
  
  if (is.empty(x$AP)){x$AP = data.frame(agentName = character(), teamID = character(), teamName = character(), 
                                        scheduled = numeric(), utilFactor = numeric(), reserved = numeric(), productive = numeric(), available = numeric(), utilized = numeric(),
                                        AUT = numeric(), Allocated = integer(), Leftover = integer(), newAllocated = integer(), notWorkable = integer(), stringsAsFactors = FALSE)}
  
  if (is.empty(x$SP)){x$SP = data.frame(skillName = character(), skillType = character(), teamID = character(), teamName = character(), 
                                        PRW = numeric(), SLA = numeric(), AUT = numeric(), Allocated = integer(), Unallocated = integer(), Leftover = integer(), 
                                        newAllocated = integer(), notWorkable = integer(), Backlog = integer(), stringsAsFactors = FALSE)}
  
  if (is.empty(x$TSK)){x$TSK = data.frame(skill = character(), agent = character(), priority = numeric(), workable = logical(), 
                                          start = .POSIXct(NA)[-1] %>% as.POSIXlt, due = .POSIXct(NA)[-1] %>% as.POSIXlt, report = character() %>% as.Date, age = numeric(), dueAge = numeric(), ageGroup = factor(), dueAgeGroup = factor(), LO = logical(), status = factor(), AUT = numeric(), stringsAsFactors = FALSE)}
  
  return(x)
}

obj2ASTable = function(obj){
  ASTable = obj$TAT %>% na2zero
  colnames(ASTable) = obj$SP[colnames(ASTable), 'skillName']
  rownames(ASTable) = obj$AP[rownames(ASTable), 'agentName']
  return(ASTable)
}

obj2APTable = function(obj){
  APTable = obj$AP[ , c('agentName', 'teamID', 'teamName', 'scheduled', 'utilFactor', 'reserved', 'available', 'utilized')]
  APTable$utilized = round(100*APTable$utilized/APTable$scheduled, digits = 2) %>% na2zero
  return(APTable)  
}

obj2Reactives = function(obj){
  SPTable = obj$SP[order(rownames(obj$SP) %>% as.integer) , c('skillName', 'skillType', 'teamID', 'teamName', 'PRW', 'SLA')]  
  APTable = obj %>% obj2APTable
  ASTable = obj %>% obj2ASTable
  
  CSTable = obj$TSK
  CSTable = CSTable[obj$SP[CSTable$skill, 'skillType'] == 'CommSee',]
  
  CSTable$skillName = obj$SP[CSTable$skill, 'skillName']
  CSTable$agentName = obj$AP[CSTable$agent, 'agentName']
  
  CSTable$start %<>% time2Char
  CSTable$due   %<>% time2Char
  
  CSTable = CSTable[,  c("skill", "skillName", "agent", "agentName", "priority", "start", "due", "report", "age", "dueAge", "ageGroup", "dueAgeGroup", "workable", "LO", "status", "AUT")]
  
  MNTable = obj %>% obj2MNTable
  MLTable = obj %>% obj2MLTable
  
  list(APTable = APTable, SPTable = SPTable, ASTable = ASTable, CSTable = CSTable, MNTable = MNTable, MLTable = MLTable)
}

obj2MLTable = function(obj){
  MLTable = obj$ALC[, obj$SP[colnames(obj$ALC), 'skillType'] == 'Manual', drop = F]
  MLTable[,] = 0
  MLT = obj$TSK %>%
    dplyr::filter(LO) %>%
    dplyr::filter(obj$SP[skill, 'skillType'] == 'Manual') 
  if(!is.empty(MLT)){
    MLT %<>% reshape2::dcast(agent ~ skill, value.var = 'AUT', fun.aggregate = length) %>% na.omit %>% column2Rownames('agent')
    MLTable[rownames(MLT), colnames(MLT)] = MLT
  }
  colnames(MLTable) = obj$SP[colnames(MLTable), 'skillName']
  rownames(MLTable) = obj$AP[rownames(MLTable), 'agentName']
  MLTable %<>% cbind(Total = rowSums(MLTable))
  return(MLTable)  
}


obj2MNTable = function(obj){
  MNTable = obj$TSK %>% 
    dplyr::filter(LO == 0) %>%
    dplyr::filter(obj$SP[skill, 'skillType'] == 'Manual') %>% mutate(start = start %>% time2Char) %>% mutate(due = due %>% time2Char) %>%
    dplyr::group_by(skill, start, due) %>% 
    dplyr::summarise(meanAge = mean(age), dueAge = mean(dueAge), report = mean(report), count = length(skill)) %>%
    dplyr::mutate(skillName = obj$SP[skill, 'skillName']) %>% as.data.frame
  
  MNTable[, c('skill', 'skillName', 'start', 'due', 'dueAge', 'count', 'report')]
}

reactives2Obj = function(reactives){
  extra.mn = c(start = 'start', due = 'due', report = 'report')
  
  agentmap = reactives$APTable[, 'agentName', drop = F] %>% rownames2Column('agentID') %>% column2Rownames('agentName')
  skillmap = reactives$SPTable[, 'skillName', drop = F] %>% rownames2Column('skillID') %>% column2Rownames('skillName')
  rownames(reactives$ASTable) = agentmap[rownames(reactives$ASTable),'agentID']
  colnames(reactives$ASTable) = skillmap[colnames(reactives$ASTable),'skillID']
  
  ATT   = reactives$ASTable %>% rownames2Column('agentID') %>% melt(id = 'agentID')
  
  CSTable = reactives$CSTable
  
  x = OptimalTaskAllocator() %>% 
    feedAgents(reactives$APTable) %>% 
    feedSkills(reactives$SPTable) %>% 
    feedAgentSchedule(reactives$APTable, scheduled_col = 'scheduled', utilFactor_col = 'utilFactor') %>% 
    feedAgentTurnaroundTime(ATT, agentID_col = 'agentID', skillID_col = 'variable', tat_col = 'value') %>%
    feedTasks(CSTable, agentID_col = 'agent', workable_col = 'workable', extra_col = extra.mn) %>% 
    applyMN(reactives$MNTable) %>% applyML(reactives$MLTable, reactives$APTable, reactives$SPTable)
  
  return(x)
}

applyTAT2Obj = function(obj, APTable, SPTable, ASTable){
  agentmap = APTable[, 'agentName', drop = F] %>% rownames2Column('agentID') %>% column2Rownames('agentName')
  skillmap = SPTable[, 'skillName', drop = F] %>% rownames2Column('skillID') %>% column2Rownames('skillName')
  
  rownames(ASTable) = agentmap[rownames(ASTable),'agentID']
  colnames(ASTable) = skillmap[colnames(ASTable),'skillID']
  
  obj %>% feedAgentTurnaroundTime(ASTable %>% rownames2Column('agentID') %>% melt(id = 'agentID'), 
                                  agentID_col = 'agentID', skillID_col = 'variable', tat_col = 'value')
}


applyCSVTable2Obj = function(obj, CSVTable){
  # CSVTable$Report = Sys.Date() # Temporary
  CSVTable$Report_d %<>% as.Date
  obj %>% feedTasks(CSVTable, taskID_col = 'Process.ID', skillID_col = 'Skill_ID', priority_col = 'Age_Due', agentID_col = 'EMPLOYEEID', workable_col = 'Workable', extra_col = c(start = 'Start', due = 'Due', report = 'Report_d')) %>% 
    addAgeProfiles %>% customizeTaskPriorities(skillPriorityWeight_column = 'PRW')  
}


clearCommSeeTasks = function(obj){
  cst = obj$SP[obj$TSK$skill, 'skillType'] == 'CommSee' 
  obj$TSK = obj$TSK[!cst,]
  obj %>% updateAgentUtilization %>% updateTaskCounts
}

clearAllTasks = function(obj){
  obj$TSK = obj$TSK[F,]  
  return(obj %>% updateTaskCounts)
}

# test:
#AP = readAgents(date = '2017-08-09', teamID = 'CSETM1078933')
#SP = readSkills(date = '2017-08-09', teamID = 'CSETM1078933')
#AA = readAgentSchedule(date = '2017-08-09', teamID = 'CSETM1078933')
#AS = readAgentTAT(date = '2017-08-09', teamID = 'CSETM1078933')
# DST = loadData(date = '2017-08-09', teamID = 'CSETM1078933')



readHolidays = function(...){
  channel = odbcConnect(...)
  TBL     = sqlQuery(channel = channel, query = "EXEC  RSHINY.GETHOLIDAYS")
  close(channel)
  return(TBL)  
}


readTeams = function(...){
  channel = odbcConnect(...)
  TBL     = sqlQuery(channel = channel, query = "EXEC  rshiny.GETTEAMLIST")
  close(channel)
  return(TBL)  
}


# Write back functions for 'export to database' functionality
library(reshape2)

##---------------------------------------------------------------------------------------------------------------------
##upload Function
uploadToSql = function(procname = NULL, dtframe=NULL, ...)
{
  channel = odbcConnect(...)
  n       = ncol(dtframe)
  qry     = paste("EXEC " ,procname , strcat(rep(" ? ,",n-1))," ? ", sep = "")
  rs      = sqlExecute (channel=channel,query=qry,data=dtframe)
  close(channel)
}

# Step 1: Get allocation id using selected allocation date and team name
##Allocation ID
getAllocID = function (date=NULL, team=NULL, ...)
{
  ##TEsT start
  #team <- "CSETM1078933"
  #date <- Sys.Date() -1
  #dsn <- "SODEV"
  ## TEST end
  channel = odbcConnect(...)
  dt <- data.frame(date,team)
  Alloc_ID <- sqlQuery(query= paste0("EXEC RSHINY.POSTALLOCATIONDETAILS '" ,date,"', '",team, "'"),channel =channel )
  return(Alloc_ID)
  close(channel)
}

# use this function to update team id information correspond to an allocation id
allocateTeamInfo = function (alloc_id=NULL, team=NULL, ...)
{
  channel = odbcConnect(...)
  sqlQuery(query= paste0("EXEC RSHINY.POSTALLOCATIONTEAMS '" ,alloc_id,"', '",team, "'"),channel =channel )
  close(channel)
}

# Step 2: skills details
uploadSkillRanks = function(obj = NULL, alloc_id=NULL,proc=NULL, ...)
{
  # COLUMNS: ALLOCATIONID, SKILLID, RANK
  dt = data.frame(rep(alloc_id),
                  rownames(obj$SPTable),
                  obj$SPTable$PRW
  )
  if(inherits(dt, 'data.frame'))
  {
    uploadToSql(procname=proc,dtframe=dt, ...)
  }
}

# Step 3: Employee details
## AgentProfile
uploadAgentProfile= function(obj = NULL, alloc_date = NULL, alloc_id=NULL,proc=NULL, ...)
{
  # COLUMNS: ALLOCATIONID, EMPLOYEEID, PRODUCTIONTIME, ALLOCATIONFACTOR, SCHEDULEDATE
  dt = data.frame(rep(alloc_id),
                  str_pad(rownames(obj$APTable),8, side="left", pad="0"),
                  obj$APTable$scheduled,
                  obj$APTable$utilFactor,
                  rep(alloc_date)
  )
  if(inherits(dt, 'data.frame'))
  {
    uploadToSql(procname=proc,dtframe=dt, ...)
  }
}

# Step 4: Agent Skill matrix
uploadSkillMatrix= function(obj = NULL, alloc_id=NULL,proc=NULL, ...)
{
  # COLUMNS: ALLOCATIONID, SKILLID, EMPLOYEEID, AUT
  
  df <- cbind(Row.Names = rownames(obj$TAT), obj$TAT)
  melted <- melt(df, id=c("Row.Names")) %>% na.omit
  dt = data.frame(rep(alloc_id),
                  melted$variable,                  
                  str_pad(melted$Row.Names,8, side="left", pad="0"),
                  melted$value
  )
  names(dt) <- c("ALLOCATIONID", "SKILLID", "EMPLOYEEID", "AUT")
  if(inherits(dt, 'data.frame'))
  {
    uploadToSql(procname=proc,dtframe=dt, ...)
  }
}


# Step 5: Manual Leftovers
uploadLOManualWims = function(obj = NULL, alloc_id = NULL, alloc_date = NULL, proc=NULL, ...)
{
  if(sum(obj$MLTable %>% as.matrix) > 0){
    MLT = obj$MLTable %>% MLTable2Summary(obj$APTable, obj$SPTable, alloc_date %>% verify('Date', default = Sys.Date(), varname = 'alloc_date'))
    # COLUMNS: ALLOCATIONID, EMPLOYEEID, SKILLID, STARTDATE, DUEDATE, WORKUNITS
    dt = try(data.frame(rep(alloc_id),
                        str_pad(MLT$agent,8, side = "left", pad = "0"),
                        MLT$skill,
                        MLT$start,
                        MLT$due,
                        MLT$count
    ), silent = T)
    if(inherits(dt, 'data.frame')){uploadToSql(procname=proc, dtframe = dt, ...)} else {print(dt %>% as.character)}
  }
}

# Step 5: Manual Additional tasks
uploadOpenManualWims= function(obj = NULL, alloc_id=NULL,proc=NULL, ...)
{
  # COLUMNS: ALLOCATIONID, SKILLID, STARTDATE, DUEDATE, WORKUNITS
  if (nrow(obj$MNTable)>0)
  {
    dt = data.frame(rep(alloc_id),
                    obj$MNTable$skill,
                    obj$MNTable$start %>% as.time(tz = 'GMT'),
                    obj$MNTable$due %>% as.time(tz = 'GMT'),
                    obj$MNTable$count
    )
    if(inherits(dt, 'data.frame'))
    {
      uploadToSql(procname=proc,dtframe=dt, ...)
    }
  }
}


# Step 6: CommSee tasks
uploadCommSeeTasks= function(obj = NULL, alloc_id=NULL, proc=NULL, ...)
{
  # COLUMNS: ALLOCATIONID,	PROCESSID,	LOADTIME,	WORKITEMTYPE,	STATUS,	ASSIGNEDTO,	STARTDATE,	DUEDATE,	RELATEDTO,	REQUESTCATEGORY,	REQUESTTYPE,	CONTACTATTEMPTS,	ACTIONCOUNT,	INITIALLYASSIGNEDTO,
  # TEMPLATESELECTED,	CLIENTNAME,	LOANTYPE,	BROKERAPPID,	APPLICATIONCHANNEL,	ORIGINATINGBRANCH,	EMPLOYEEID,	APPLICATIONSTATUS,	TRANSACTIONID,	SELFEMPLOYEED,	SKILLID
  if (nrow(obj$CSTable)>0)
  {
    obj$CSTable$skill <- as.numeric(as.character(obj$CSTable$skill))
    
    dt = data.frame(rep(alloc_id),
                    rownames(obj$CSTable),
                    rep("NA"),
                    obj$CSTable$status,
                    rep("NA"),
                    obj$CSTable$start %>% as.time(tz = 'GMT'),
                    obj$CSTable$due %>% as.time(tz = 'GMT'),
                    rep("NA"),
                    rep("NA"),
                    rep("NA"),
                    rep(999999999),
                    rep(999999999),
                    rep("NA"),
                    rep("NA"),
                    rep("NA"),
                    rep("NA"),
                    rep("NA"),
                    rep("NA"),
                    rep("NA"),
                    str_pad(obj$CSTable$agent,8, side="left", pad="0"),
                    rep("NA"),
                    rep("NA"),
                    rep("NA"),
                    obj$CSTable$skill
    )
    if(inherits(dt, 'data.frame'))
    {
      uploadToSql(procname=proc,dtframe=dt, ...)
    }
  }
}


# Step 7: Allocation Overview
uploadAllocations= function(obj = NULL, alloc_id=NULL,proc=NULL, ...)
{
  
  
  # COLUMNS: ALLOCATIONID, SKILLID, EMPLOYEEID, STARTDATE, DUEDATE, LEFTOVER, AUT, PRIORITY, PROCESSID
  tk = !is.na(obj$TSK$agent)
  
  if(sum(tk) > 0){
    dt = data.frame(rep(alloc_id),
                    obj$TSK$skill[tk],
                    str_pad(obj$TSK$agent[tk],8, side="left", pad="0"),
                    obj$TSK$start[tk] %>% as.time(tz = 'GMT'),
                    obj$TSK$due[tk] %>% as.time(tz = 'GMT'),
                    obj$TSK$LO[tk],
                    obj$TSK$AUT[tk],
                    obj$TSK$priority[tk],
                    rownames(obj$TSK)[tk]
    )
    if(inherits(dt, 'data.frame'))
    {
      uploadToSql(procname=proc,dtframe=dt, ...)
    }
  }
}


deleteAllocationsAndTasks = function(alloc_id=NULL, ...)
{
  channel = odbcConnect(...)
  
  qry = paste0("EXEC RSHINY.DELETEALLOCATIONS '" ,alloc_id,"'")  
  sqlQuery(query = qry, channel = channel)
  qry = paste0("EXEC RSHINY.DELETEMANUALLOWIMS '" ,alloc_id,"'")
  sqlQuery(query = qry, channel = channel)
  qry = paste0("EXEC RSHINY.DELETEMANUALOPENWIMS '" ,alloc_id,"'") 
  sqlQuery(query = qry, channel = channel)
  qry = paste0("EXEC RSHINY.DELETEOPENCOMMSEEWIMS '" ,alloc_id,"'") 
  sqlQuery(query = qry, channel = channel)
  
  close(channel)
}


## ExportToDatabase: This function upload (write) all the dashbaord data for a particular allocation to database
## It contains a set of write back functions.
exportToDatabase = function(obj = NULL, alloc_date=NULL, team_id=NULL, ...)
{
  # Get the allocation id for a particular date and team
  alloc_id = getAllocID(alloc_date,team_id, ...)
  allocateTeamInfo(alloc_id, team_id, ...)
  
  reactives = obj2Reactives(obj)
  if(!is.empty(reactives$CSTable)){reactives$CSTable[!reactives$CSTable$LO, 'agent'] = NA}
  
  uploadSkillRanks(reactives,alloc_id,proc="RSHINY.POSTSKILLRANK", ...)
  
  uploadAgentProfile(reactives,alloc_date = alloc_date, alloc_id = alloc_id, proc="RSHINY.POSTEMPLOYEESCHEDULE", ...)
  
  uploadSkillMatrix(obj,alloc_id,proc="RSHINY.POSTSKILLMATRIX", ...)
  
  # Delete existing tasks and allocations for this allocation id if exists
  deleteAllocationsAndTasks(alloc_id, ...)
  
  # Update the allocations and tasks for this allocation id
  uploadLOManualWims(reactives, alloc_id, alloc_date = alloc_date, proc="RSHINY.POSTMANUALLOWIMS", ...)
  
  uploadOpenManualWims(reactives,alloc_id,proc="RSHINY.POSTMANUALOPENWIMS", ...)
  
  uploadCommSeeTasks(reactives,alloc_id,proc="RSHINY.POSTOPENCOMMSEEWIMS", ...)
  
  uploadAllocations(obj,alloc_id,proc="RSHINY.POSTALLOCATIONS", ...)
  
  
  return(alloc_id)
}


addRow2MNTable = function(MNTable, obj, selected, alloc_date = Sys.Date()){
  if(!inherits(alloc_date, 'Date')){alloc_date %<>% as.Date}
  N = nrow(MNTable)
  
  flg = inherits(MNTable$skillName, 'factor')
  if(flg){flg = !(selected %<% levels(MNTable$skillName))}
  
  if (flg){
    MNTable$skill     %<>% as.character
    MNTable$skillName %<>% as.character
  }
  
  MNTable[N + 1, 'skillName'] <- selected
  MNTable[N + 1, 'skill']     <- obj$skills[which(obj$SP$skillName == selected)]
  MNTable$report[N + 1]       <- alloc_date 
  MNTable$start[N + 1]        <- alloc_date %>% time2Char
  MNTable$due[N + 1]          <- as.character(alloc_date %>% addDate(obj$SP[MNTable[N + 1, 'skill'], 'SLA'], holidays = holidays)) %>% paste('00:00:00')
  MNTable$count[N + 1]        <- 0
  
  if (flg){
    MNTable$skill     %<>% as.factor
    MNTable$skillName %<>% as.factor
  }
  return(MNTable)
}


MLTable2Summary = function(MLTable, APTable, SPTable, alloc_date){
  agentmap = APTable[, 'agentName', drop = F] %>% rownames2Column('agentID') %>% column2Rownames('agentName')
  skillmap = SPTable[, 'skillName', drop = F] %>% rownames2Column('skillID') %>% column2Rownames('skillName')
  MLTable %>% rownames2Column('agent') %>% mutate(Total = NULL) %>% melt(id.vars = 'agent', variable.name = 'skill', value.name = 'count') %>% zero.omit('count') %>%
    mutate(skillName = skill %>% as.character, agentName = agent %>% as.character) %>%
    mutate(skill = skillmap[skillName, 'skillID'], agent = agentmap[agentName, 'agentID']) %>% 
    mutate(report = alloc_date) %>%
    mutate(start = report %>% setTZ('GMT') %>% as.POSIXct, due = setTZ(report + SPTable[skill, 'SLA'], 'GMT') %>% as.POSIXct) %>% 
    mutate(dueAge = report %>% setTZ('GMT') %>% diffTime(due, units = 'hours', holidays = holidays) %>% round(digits = 2) %>% as.numeric)
}

applyML = function(obj, MLTable, APTable, SPTable, alloc_date){
  extra.mn = c(start = 'start', due = 'due', report = 'report')
  tbd      = obj$TSK$LO & obj$TSK$workable & (obj$SP[obj$TSK$skill, 'skillType'] == 'Manual') 
  obj$TSK  = obj$TSK[!tbd,]
  if(sum(MLTable %>% as.matrix) > 0){
    MLT =  MLTable %>% MLTable2Summary(APTable, SPTable, alloc_date) %>%
      taskSummary2TaskList(skillID_col = 'skill', count_col = 'count', priority_col = "dueAge", agentID_col = 'agent', extra_col = c('skillName', 'start', 'due', 'report'), prefix = 'MLT')
    
    obj %<>% feedTasks(MLT, skillID_col = 'skillID', priority_col = 'priority', agentID_col = 'alctdAgent', extra_col = extra.mn)
  }
  return(obj %>% clearAllocation %>% addAgeProfiles %>% customizeTaskPriorities(skillPriorityWeight_column = 'PRW'))
}

applyMN = function(obj, MNTable){
  MNTable$start %<>% as.time(tz = 'GMT')
  MNTable$due   %<>% as.time(tz = 'GMT')
  
  extra.mn = c(start = 'start', due = 'due', report = 'report')
  tbd      = !obj$TSK$LO & obj$TSK$workable & (obj$SP[obj$TSK$skill, 'skillType'] == 'Manual') 
  obj$TSK  = obj$TSK[!tbd,]
  MNT      = MNTable %>% taskSummary2TaskList(skillID_col = 'skill', count_col = 'count', priority_col = "dueAge", extra_col = c('skillName', 'start', 'due', 'report'), prefix = 'MNT')
  obj %>% clearAllocation(update = F) %>% feedTasks(MNT, skillID_col = 'skillID', priority_col = 'priority', extra_col = extra.mn) %>% 
    addAgeProfiles %>% customizeTaskPriorities(skillPriorityWeight_column = 'PRW')
}

# This function writes skill, agent and task summary to excel file
writeAllocationReport = function(obj = NULL, filename = "SO Allocation Report.xlsx"){
  
  #fileName = "SO Allocation Report.xlsx"
  #filepath = paste(choose.dir(default = "", caption = "Select folder"), '\\', sep = "")
  
  # generate data frame for allocation summary for each skill and agent, and allocation details for each task
  
  dfs = obj$SP %>% rownames2Column('skillID') %>% mutate(alloc = newAllocated + Unallocated, tt = newAllocated + Leftover + Unallocated, ta = Leftover + newAllocated) %>% 
    select("Skill ID" = skillID, "Skill Name" = skillName, "Tasks for Allocation" = alloc, "Tasks Carried Over" = Leftover, "Total Tasks" = tt,
           "New Allocations" = newAllocated, "Total Allocations" = ta, "Tasks Unallocated" = Unallocated)
  
  ALC = obj$ALC
  colnames(ALC) <- obj$SP[colnames(ALC), 'skillName']
  ALC %<>% rownames2Column("Employee ID")
  
  dfa = obj$AP %>% rownames2Column('agentID') %>% mutate(tta = newAllocated + Leftover, utilized = utilized %>% na2zero, esu = ifelse(productive == 0, NA, round(100*utilized/productive, digits = 2))) %>% 
    select("Employee ID" = agentID, "Employee Name" = agentName, "Planned Time in Production" = productive, "New Tasks Allocated" = newAllocated,
           "Tasks Carried Over" = Leftover, "Total Tasks Allocated" = tta, "Estimated Processing Time" = utilized,"Estimated Utilisation (%)" = esu) %>% 
    left_join(ALC, by = 'Employee ID')
  
  
  dft = obj$TSK %>% rownames2Column("taskID") %>% filter(status %in% c('newAllocated', 'Leftover')) %>% 
    mutate(skill = obj$SP[skill, "skillName"]) %>% mutate(agent = obj$AP[agent, "agentName"]) %>% 
    select("Task ID" = taskID, "Skill Name" = skill, "Agent Name" = agent, "Is Carried Over" = LO, 'AUT' = AUT, 
           "Start Date" = start, "Due Date" = due, "Report Date" = report, "Task Age" = age, "Task Due Age" = dueAge, "Task Status" = status) 
  
  
  dfw  = obj$TSK %>% mutate(WIPInterval=findInterval(dueAge,c(-24,0,24),left.open=TRUE),skill = obj$SP[skill, "skillName"]) %>%
    group_by(skill,WIPInterval) %>% summarise(Count=n()) %>% data.frame(.) %>% dplyr::filter(WIPInterval != 0) %>% 
    mutate(WIPInterval = case_when(WIPInterval ==1 ~ "Arrived",WIPInterval==2 ~"Day 2",WIPInterval==3 ~"Day 3+",TRUE ~ "Unknown"))
  
  # dft_temp <- dft
  # colnames(dft_temp)[colnames(dft_temp) == "Agent Name"] <- "Agent_Name"
  # colnames(dft_temp)[colnames(dft_temp) == "Task Status"] <- "Task_Status"
  # colnames(dft_temp)[colnames(dft_temp) == "Skill Name"] <- "Skill_Name"
  # 
  # dft_1 <- dft_temp %>% select(Agent_Name, Task_Status, Skill_Name) %>% filter(Task_Status %in% c("newAllocated", "Leftover")) 
  # dft_1$count <- rep(1,nrow(dft_1))
  # dfa_1 <- dft_1 %>% group_by(Agent_Name, Task_Status, Skill_Name) %>% summarise(count = sum(count)) 
  # dfa_2 <- dcast(dfa_1, Agent_Name ~ Task_Status + Skill_Name, fill = 0)        
  # colnames(dfa_2)[colnames(dfa_2) == "Agent_Name"] <- "Employee Name"
  
  # obj$AP %>% left_join()
  # dfa_all <- left_join(dfa, dfa_2, by = "Employee Name")
  # dfa_all[ is.na(dfa_all) ] <- 0 
  
  ## This is the file format for excel file, filename is already passed in this format. So the following line is not required.
  #filename_full = paste(as.character(alloc_date), as.character(team_id), filename, sep =" ") 
  
  if(file.exists(filename)){
    file.remove(filename)
  }
  outputWorkbook <- createWorkbook()
  
  outputSheet <- createSheet(wb=outputWorkbook,sheetName="Skill Summary")
  addDataFrame(dfs,outputSheet,row.names=FALSE)
  
  outputSheet <- createSheet(wb=outputWorkbook,sheetName="Agent Summary")
  addDataFrame(dfa,outputSheet,row.names=FALSE)
  
  outputSheet <- createSheet(wb=outputWorkbook,sheetName="WIP Report")
  addDataFrame(dfw,outputSheet,row.names=FALSE)
  
  if(nrow(dft) > 0){
    
    outputSheet <- createSheet(wb=outputWorkbook,sheetName="Task Details")
    addDataFrame(dft,outputSheet,row.names=FALSE)
  }
  dft %<>% dplyr::select(`Agent Name`,`Task ID`,`Skill Name`,`Due Date`) %>% arrange(`Due Date`)
  for (Aname in obj$AP$agentName) {
    if (obj$AP[obj$AP$agentName==Aname, "utilized"] >0) {
      outputSheet <- createSheet(wb=outputWorkbook,sheetName=Aname)
      addDataFrame(dft[dft$`Agent Name`==Aname,],outputSheet,row.names=FALSE)
      addAutoFilter(outputSheet,paste0("A:", cellranger::num_to_letter(NCOL(dft))))
      autoSizeColumn(outputSheet,1:NCOL(dft))
      
    }
  }
  saveWorkbook(outputWorkbook,filename) 
}  

write2excelSkill = function(df = data.frame(), filename = "", sheet_name = "", col_names = TRUE, row_names = FALSE, append = FALSE){    
  
  write.xlsx(x = df, file = filename, sheetName = sheet_name, col.names = col_names, row.names = row_names, append = append)
  
}

write2excelAgent = function(df = data.frame(), filename = "", sheet_name = "", col_names = TRUE, row_names = FALSE, append = FALSE){    
  
  write.xlsx(x = df, file = filename, sheetName = sheet_name, col.names = col_names, row.names = row_names, append = append)
  
}

write2excelTask = function(df = data.frame(), filename = "", sheet_name = "", col_names = TRUE, row_names = FALSE, append = FALSE){    
  
  write.xlsx(x = df, file = filename, sheetName = sheet_name, col.names = col_names, row.names = row_names, append = append)
  
}


# # This function is for customized justification of task priorities:
# customizeTaskPriorities.old = function(x, skillPriorityWeight_column){
#   x$TSK$priority %<>% scale(center = F) %>% as.numeric
#   x$TSK$priority = exp(3*x$TSK$priority)*x$SP[x$TSK$skill, skillPriorityWeight_column]
#   return(x)
# }

# This function is for customized justification of task priorities:
customizeTaskPriorities = function(x, skillPriorityWeight_column){
  x$TSK$priority %<>% as.numeric
  x$TSK$priority = x$TSK$priority + x$SP[x$TSK$skill, skillPriorityWeight_column]
  return(x)
}

allocateTasks = function(obj, balance = F){obj %<>% distributeTasks; if(balance){obj %>% balanceAgentUtilization %>% balanceAgentUtilization} else {obj}}

getLoginTable = function (...)
{
  qry = paste0("select * from RSHINY.USERPASSWORD")
  channel = odbcConnect(...)
  
  pass = sqlQuery(channel = channel, query = qry)
  close(channel)
  
  return(pass)
}



### otavis.R ---------------------

# Header
# Filename:     otavis.R
# Description:  Contains functions to generate visualisation components for task allocation
# Author:       Nicolas Berta 
# Email :       nicolas.berta@gmail.com
# Start Date:   26 May 2017
# Last change:  09 May 2018
# Version:      1.5.0

# Version   Date               Action
# -----------------------------------
# 0.0.1     26 May 2017        Initial Issue
# 0.0.2     19 July 2017       service function for SPTable added (TFD3): SPTable.srv function skill.sparkline() removed
# 0.0.5     10 August 2017     Tables configurations changed
# 0.0.6     10 August 2017     Functions addAgeProfiles(), tableAgeGroups() and tableDueAgeGroups() added
# 1.1.0     30 August 2017     Functions addRow2MNTable() and addRow2MLTable() added.
# 1.1.2     30 August 2017     Functions MNConfig() and MLConfig() modified
# 1.1.3     30 August 2017     Functions addAgeProfiles() modified: small bug rectified: 0 included in the range, global var ageTrans modified accordingly!
# 1.1.4     31 August 2017     Extensions added to CSTable 
# 1.1.5     31 August 2017     Messaage notes added. 
# 1.1.6     31 August 2017     Config for CSTable changed
# 1.1.7     12 September 2017  CSTasksCleared added to message list
# 1.1.8     12 September 2017  Functions addRow2MNTable() and addRow2MLTable() modified: converts factors to character before and vice versa after adding rows
# 1.1.9     12 October 2017    Functions APConfig() changed: Footer removed from agent profile table
# 1.2.0     23 October 2017    Function agent.bar() added
# 1.2.4     23 October 2017    Functions skill.bar(), agent.bar(), age.bar() and dueAge.bar() modified: Specific set of colors defined
# 1.2.5     24 October 2017    Function cleanError() added to split and return part of the message after the last colon
# 1.2.6     24 October 2017    pivot table removes non-workable tasks
# 1.2.7     30 October 2017    Functions addRow2MNTable() and addRow2MNTable() transferred to iotools.R.
# 1.2.8     30 October 2017    MNConfig and MLConfig modified: removed line withRowNames = F to be avoid column shift bug in the js package, added column title Row Number for rownames
# 1.2.9     01 November 2017   Agent id and Skill id column are added to ComSee task table
# 1.2.10    02 November 2017   Function cleanError() modified: removes '-' from any error message
# 1.3.0     06 November 2017   SLA column added to SPTable
# 1.3.1     14 November 2017   MNConfig() changed: MNTable start and due times are presented as character, so new validator function validateTime() is added.
# 1.4.0     14 November 2017   MLConfig() changed: MLTable configured as matrix format.
# 1.4.1     06 December 2017   Public holidays respected by using function timeDiff() from gener.
# 1.4.2     15 January 2018    TFD3 table configurations updated for CSTable, MLTable and MLTable: Numeric sorting issue fixed.
# 1.4.3     16 January 2018    Messages modified plus CSTable configuration changed: toggle filters removed.
# 1.4.4     14 February 2018   Sunburst(Coffeewheel) plot uses status rather than LO as the intermediate categorical column
# 1.4.5     16 February 2018   Message for download successful changed.
# 1.4.6     18 April 2018      Checks user-entered value and prevents it from being a number greater than 10,000 for manual skill volume and 2000 for manual leftover volume.
# 1.4.7     19 April 2018      Global variable dueAgeTrans modified: Category names and boundary values for dueAge changed 
# 1.4.8     08  May 2018       Function utilized.time() renamed to totalUtilizedTime()
# 1.4.9     08  May 2018       Function overallUtilization() added
# 1.5.0     04  June 2018      Function overallUtilization() modified: divides utilized time to productive time rather than scheduled time!
#                               

# C1: DT Table: Allocation Summary by skill
# C2: rAmCharts barChart: Age distribution bar
# C3: highcharter barChart: Skill Volume

ageTrans    = c("(-Inf,-24]" = "Future start","(-24, 0]" = "Starts today", "(0,24]" = "Less than 1 day", "(24,48]" = "1-2 days", "(48,120]" = "2-5 days", "(120,240]" = "5-10 days", "(240,Inf]" = "Over 10 days")
dueAgeTrans = c("(-Inf,-120]" = "Due in 1 week or more", "(-120,-48]" = "Due in 3-5 days", "(-48,-24]" = "Due in 2 days", "(-24,0]" = "Due in 1 day",
                "(0,24]" = "Due Today", "(24,48]" = "1 day Overdue", "(48,72]" = "2 days Overdue", "(72,144]" = "3-5 days Overdue", "(144, 264]" = "1 week Overdue", "(264, 360]" = "2 weeks Overdue", "(360, Inf]" = "> 2 weeks Overdue")
clrs = c(Leftover = 'grey', notWorkable = 'red', Unallocated = 'lightblue', newAllocated = 'lightgreen')


# Returns a data.frame showing volume of tasks in each age group:
addAgeProfiles = function(obj){
  gener::assert('report' %in% names(obj$TSK), "The task table does not contain report dates! A column of type Date or POSIXlt, labeled as 'report' is required.")
  # Add Task ages and due ages:
  # obj$TSK$age    = (obj$TSK$report %>% as.POSIXlt) - (obj$TSK$start %>% as.POSIXlt)
  # obj$TSK$dueAge = (obj$TSK$report %>% as.POSIXlt) - (obj$TSK$due %>% as.POSIXlt)
  # obj$TSK$age    %<>% round(digits = 2)
  # obj$TSK$dueAge %<>% round(digits = 2)
  obj$TSK$age    = obj$TSK$report %>% setTZ('GMT') %>% diffTime(obj$TSK$start, units = 'hours', holidays = holidays) %>% round(digits = 2)
  obj$TSK$dueAge = obj$TSK$report %>% setTZ('GMT') %>% diffTime(obj$TSK$due,   units = 'hours', holidays = holidays) %>% round(digits = 2)
  obj$TSK$ageGroup    = ageTrans[   obj$TSK$age    %>% as.numeric %>% cut(breaks = 24*c(-Inf, -1, 0, 1, 2, 5, 10, Inf), include.lowest = TRUE)]
  obj$TSK$dueAgeGroup = dueAgeTrans[obj$TSK$dueAge %>% as.numeric %>% cut(breaks = 24*c(-Inf, -10, -5, -2, -1, 0, 1, 2, 5, 10, Inf))]
  # obj$AGP  = obj$TSK %>% group_by(ageGroup) %>% dplyr::summarize(Allocated = sum(!is.na(agent)), Unallocated = sum(is.na(agent)), Leftover = sum(LO), Assigned = sum(!LO & !is.na(agent)), Backlog = length(skill)) %>% as.data.frame  %>% column2Rownames('ageGroup')
  # obj$DAGP = obj$TSK %>% group_by(dueAgeGroup) %>% dplyr::summarize(Allocated = sum(!is.na(agent)), Unallocated = sum(is.na(agent)), Leftover = sum(LO), Assigned = sum(!LO & !is.na(agent)), Backlog = length(skill)) %>% as.data.frame  %>% column2Rownames('dueAgeGroup')
  return(obj)
}

tableAgeGroups = function(obj, skills = NULL){
  if(is.empty(skills)){skills = obj$skills}
  AGP = obj$TSK[obj$TSK$skill %in% skills, ]
  if(is.empty(AGP)){return(data.frame(ageGroup = ageTrans, Leftover = 0, newAllocated = 0, notWorkable = 0, Unallocated = 0) %>% column2Rownames('ageGroup'))}
  AGP  %<>% dcast(ageGroup ~ status, fun.aggregate = length, value.var = 'status') %>% na.omit %>% column2Rownames('ageGroup')
  AGP  = AGP[ageTrans, , drop = F] %>% na2zero
  rownames(AGP) = ageTrans
  # AGP$Backlog = rowSums(AGP)
  return(AGP)
}

tableDueAgeGroups = function(obj, skills = NULL){
  if(is.empty(skills)){skills = obj$skills}
  DAGP = obj$TSK[obj$TSK$skill %in% skills, ]
  if(is.empty(DAGP)){return(data.frame(dueAgeGroup = dueAgeTrans, Leftover = 0, newAllocated = 0, notWorkable = 0, Unallocated = 0) %>% column2Rownames('dueAgeGroup'))}
  DAGP %<>% dcast(dueAgeGroup ~ status, fun.aggregate = length, value.var = 'status') %>% na.omit %>% column2Rownames('dueAgeGroup')
  DAGP = DAGP[dueAgeTrans, , drop = F] %>% na2zero
  rownames(DAGP) = dueAgeTrans
  # DAGP$Backlog = rowSums(DAGP)
  return(DAGP)
}


skill.bar = function(obj){obj$SP %>% viserPlot(y = 'skillName', x = c('Unallocated', 'Not Workable' = 'notWorkable', 'New Allocated' = 'newAllocated', 'Leftover') %>% intersect(names(obj$SP)) %>% as.list, 
                                              color = list('lightblue', 'red', 'lightgreen', 'grey'), config = list(barMode = 'stack', colorize = F), plotter = 'highcharter', type = 'bar')}

agent.bar = function(obj){
  obj$AP %>% mutate(Allocated = newAllocated + Leftover) %>% arrange(Allocated) %>% 
    viser::viserPlot(y = list('Agent Full Name' = 'agentName'), x = list('Leftover', 'New Allocated' = 'newAllocated'), color = list('grey', 'lightgreen'), shape = 'bar', config = list(barMode = 'stack', colorize = F), type = 'combo', plotter = 'highcharter')
}


# Cx: Donut chart showing allocated vs not-allocated
allocated.donut = function(obj, skill = NULL){
  if(is.null(skill)){skill = obj$skills}
  tbl = obj$SP[skill, c('Allocated', 'Unallocated'), drop = F] %>% colSums(na.rm = T) %>% as.data.frame %>% appendCol(c('green', 'red')) %>% zero.omit 
  names(tbl) = c('count', 'colour')
  tbl %>% viserPlot(label = rownames(tbl), theta = 'count', color = 'colour', type = 'pie', config = list(colorize = F), plotter = 'morrisjs')
}

# Cx: Generates donut chart showing age distribution
age.donut = function(obj, skill){
  obj %>% tableAgeGroups %>% rownames2Column('Age Group') %>% filter(Backlog > 0) %>% 
    viserPlot(label = 'Age Group', theta = 'Backlog', type = 'pie', plotter = 'morrisjs')
}

dueAge.donut = function(obj){
  obj %>% tableDueAgeGroups %>% rownames2Column('Due Age Group') %>% filter(Backlog > 0) %>% 
    viserPlot(label = 'Due Age Group', theta = 'Backlog', type = 'pie', plotter = 'morrisjs', color = list(AgeCol = "Backlog"), config = list(colorize = T))
}

# Cx: Generates barchart of Age
age.bar = function(obj, skills = NULL, plotter = 'highcharter'){
  AGP = obj %>% tableAgeGroups(skills = skills)
  AGP %>% rownames2Column('Age Group') %>% viserPlot(
    x = names(AGP) %>% as.list, y = 'Age Group', type = 'combo', shape = 'bar', color = clrs[names(AGP)] %>% unname %>% as.list,
    config = list(title = 'Age Distribution', barMode = 'stack', colorize = F), plotter = plotter)
}

dueAge.bar = function(obj, skills = NULL, plotter = 'highcharter'){
  DAGP = obj %>% tableDueAgeGroups(skills = skills)
  DAGP %>% rownames2Column('Due Age Group') %>% viserPlot(
    x = names(DAGP) %>% as.list, y = 'Due Age Group', shape = 'bar', type = 'combo', color = clrs[names(DAGP)] %>% unname %>% as.list,
    config = list(title = 'Due Age Distribution', barMode = 'stack'), plotter = plotter)
}

# C6: Generates bubble chart showing backlog as size (Each bubble represents a skill)
backlog.bubble = function(obj, skill){
  obj$SP %>% na.omit %>% zero.omit(colname = 'Backlog') %>% 
    viserPlot(size = 'Backlog', color = 'skillType', tooltip = 'skillName', label = 'skillName', config = list(labelThreshold = 0.1), plotter = 'bubbles', type = 'bubble')
}

# C7: Returns a stack barchart representing agent utilization and reserved time for Leftover
# As input, you should give agent profile table not the whole task allocator object
util.bar = function(tbl){
  tbl$Available = tbl$productive - tbl$reserved
  tbl$Available = ifelse(tbl$Available < 0, 0, tbl$Available)
  tbl %>% zero.omit('productive') %>% arrange(productive) %>% 
    viserPlot(x = list('Available', 'Required for Leftover' = 'reserved'),
             y = list('Agent Name' = 'agentName'), type = 'combo', plotter = 'highcharter',
             shape = list('bar','bar'), config = list(barMode = 'stack'))
}

# C8: Showslist of tasks filtered for the given skill
taskList.table = function(obj, skillset = rownames(obj$SP), ...){
  obj$TSK %>% filter(skill %in% skillset) %>% mutate(Skill = obj$SP[skill, 'skillName'], Agent = obj$AP[agent, 'agentName']) %>% 
    select(Skill, 'Assigned to' = Agent, 
           'Started at' = start, 'Due at' = 'due', 'Report Date' = 'report', 'Age (hrs)' = 'age', 'Due Age (hrs)' = 'dueAge', 
           'Age Group' = 'ageGroup', 'Due Age Group' = 'dueAgeGroup', 'Task Status' = 'status') %>% 
    viserPlot(plotter = 'DT', type = 'table', filter = 'top', config = list(paging.length = 25, autoWidth = T), ...)
  # viserPlot(plotter = 'DT', type = 'table', config = list(links = list(mylink)), ...)
}

# C9: generates a coffeewhee showing a complete overview of allocations
allocation.coffeewheel = function(obj){
  ft = function(tr){
    if(!is.null(tr$tree_name)){
      tr$tree_name %<>% paste0('(', tr$Count, ')')
      tr$tree_name = gsub(x =  tr$tree_name, pattern = ' ', replacement = '.')
    }
    if(!is.null(tr$leaf_name)){
      tr$leaf_name %<>% paste0('(', tr$Count, ')')
      tr$leaf_name = gsub(x =  tr$leaf_name, pattern = ' ', replacement = '.')
    }
    return(tr)
  }
  
  # debug(coffeewheel.pie)
  obj$TSK %>% 
    mutate(Agent = obj$AP[agent, 'agentName']) %>%
    mutate(Skill = obj$SP[skill, 'skillName'] %>% abbreviate) %>%
    dplyr::group_by(Skill, status, Agent) %>% dplyr::summarize(Count = length(AUT)) %>% as.data.frame %>% 
    viserPlot(label = list('Skill', 'status', 'Agent'), theta = 'Count', plotter = 'coffeewheel', type = 'sunburst', config = list(treeApplyFunction = ft))
}


# C10: Leftover Donut: Represents a donut chart showing leftover distribution over skills
# C11: Leftover Donut: Represents a donut chart showing leftover distribution over agents

# C12
#workable.coffeewheel

#allocated.skill.donut
#allocated.agent.donut

# C13: Generates histogram chart showing age distribution
age.histogram = function(obj, skill){}

task.scatter = function(obj){
  if(inherits(obj$SP$skillName, c('character', 'factor'))){
    obj$TSK$skillName = obj$SP[obj$TSK$skill, 'skillName']
  } else {obj$TSK$skillName = obj$TSK$skill}
  obj$TSK %>% viserPlot(x = 'skillName', y = 'priority', color = 'status', shape = 'bubble', type = 'scatter', plotter = 'plotly')
  # todo: adjust colors
}

# plot_ly(obj$TSK, obj = ~age, color = ~skill, type = "box")

# returns the count of leftover tasks which are workable (both CommSee and Manual)
leftover.count = function(obj, skill_set = NULL){
  if (is.empty(skill_set)){skill_set = obj$skills}
  obj$SP[skill_set, 'Leftover'] %>% sum(na.rm = T)
}


alloc.pivot = function(obj){
  obj$TSK %>% dplyr::filter(workable) %>% mutate(skill = obj$SP[skill, 'skillName'])  %>%  filter(!is.na(agent)) %>% mutate(agent = obj$AP[agent, 'agentName']) %>%
    select(Skill = skill, Agent = agent, Start = start, Due = due, Status = status, 
           Age = age, AgeGroup = ageGroup, ageDue = dueAge, AgeDueGroup = dueAgeGroup, Priority = priority) %>% 
    viserPlot(rows = 'Agent', cols = 'Skill', rendererName = 'Heatmap', plotter = 'pivot', type = 'table')
}

backlog.count = function(obj, skill_set = NULL){
  if (is.empty(skill_set)){skill_set = obj$skills}
  obj$SP[skill_set, 'Backlog'] %>% sum(na.rm = T)
}

unallocated.count = function(obj, skill_set = NULL){
  if (is.empty(skill_set)){skill_set = obj$skills}
  obj$SP[skill_set, 'Unallocated'] %>% sum(na.rm = T)
}

allocated.count = function(obj, skill_set = NULL){
  if (is.empty(skill_set)){skill_set = obj$skills}
  obj$SP[skill_set, 'Unallocated'] %>% sum(na.rm = T)
}

assigned.count = function(obj, skill_set = NULL){
  if (is.empty(skill_set)){skill_set = obj$skills}
  obj$SP[skill_set, 'newAllocated'] %>% sum(na.rm = T)
}

nonworkable.count = function(obj, skill_set = NULL){
  if (is.empty(skill_set)){skill_set = obj$skills}
  obj$SP[skill_set, 'notWorkable'] %>% sum(na.rm = T)
}

totalUtilizedTime = function(obj, skill_set = NULL){
  if (is.empty(skill_set)){skill_set = obj$skills}
  df = obj$TSK %>% filter(workable & (skill %in% skill_set) & (!is.na(agent))) %>% summarise(sum(AUT, na.rm = T))
  df[1,1]
}

overallUtilization = function(obj){
  ou = sum(ifelse(obj$AP$utilized > obj$AP$scheduled, obj$AP$productive, obj$AP$utilized), na.rm = T)/sum(obj$AP$productive, na.rm = T)
  ou = (100*ou) %>% round(digits = 2)
  if(is.na(ou)){ou = '--'} else {ou %<>% paste('%')} 
  return(ou)
}

# Agent Profile Table:
apcfg = list(column.shape    = list(available = 'bar'), withRowNames = T,
             column.title    = list(rownames = 'Agent ID', agentName = 'Agent Name',	teamID = 'Team ID', teamName = 'Team Name', scheduled = 'Production Time (min)', utilFactor = 'Utilisation Factor', reserved = 'Time Reserved (min)', available = "Available Time (min)", utilized = 'Utilization (%)'),
             column.editable = list(scheduled = T    , utilFactor = T),
             column.acceptor = list(scheduled = c('>= 0', '<= 720'), utilFactor = c('>=0', '<= 1.0')),
             column.color    = list(scheduled = 'white', utilFactor = 'white'),
             # column.footer   = list(utilFactor = 'Total:', reserved = sum, available = sum),
             # column.footer.font = list(utilFactor = list(weight = 'bold', adjust = 'right')),
             table.style     = 'table table-bordered',
             # column.filter   = list(available = '>0'),
             # Table properties:
             btn_reset       = TRUE,
             height          = 700,
             sort            = TRUE,
             on_keyup        = TRUE,  
             on_keyup_delay  = 800,
             rows_counter    = TRUE,  
             paging          = T,
             paging.length   = 20,
             rows_counter_text = "Count of agents: ",
             col_number_format= c(NULL, NULL, "US"), 
             sort_config = list(
               # alphabetic sorting for the row names column, numeric for all other columns
               sort_types = c("String", "String", "String", "String", "Number", "Number", "Number", "Number")
             ),
             col_0 = "select",
             col_1 = "select",
             col_2 = "select",
             col_3 = "select"
             # exclude the summary row from filtering
             # rows_always_visible = list(nrow(APTBL)+2)
)

# Configurations for the Skill Profile table:
spcfg = list(
  # column.shape    = list(PRW = 'bubble'),
  column.title    = list(rownames = "Skill ID", skillName = "Skill Name", skillType = "Skill Type", teamID = 'Team ID', teamName = 'Team Name', PRW = 'Due Age Offset (hours)', SLA = 'SLA (days)'),
  column.color    = list(PRW = c('white', rgb(red = 0, green = 0.8, blue = 0))),
  column.editable = list(PRW = T),
  column.acceptor = list(),
  table.style     = 'table table-bordered',
  btn_reset       = TRUE,
  height          = 700,
  sort            = TRUE,
  on_keyup        = TRUE,  
  on_keyup_delay  = 800,
  paging          = T,
  paging.length   = 20,
  
  extensions = list(
    list(name = "sort")
  ),  
  sort_config = list(
    # alphabetic sorting for the row names column, numeric for all other columns
    sort_types = c("String", "String", "String", "String", "String", "Number")
  ),
  col_0 = "select",
  col_1 = "select",
  col_2 = "select",
  col_3 = "select",
  col_4 = "select"
  # exclude the summary row from filtering
  # rows_always_visible = list(nrow(obj$AP))
)

ASConfig = function(obj){
  clmn.ttl   = list(rownames = 'Agent Name')
  
  clmn.shp   = rep('bubble', ncol(obj$TAT)) %>% as.list
  clmn.edtbl = rep(TRUE, ncol(obj$TAT)) %>% as.list
  clmn.accpt = rep('>= 0', ncol(obj$TAT)) %>% as.list
  clmn.clr   = list()
  #clmn.ftr   = list(rownames = 'Total')
  #for(i in obj$SP[colnames(obj$TAT), 'skillName']){clmn.ftr[[i]] = mean_narm}
  #for(i in obj$SP[colnames(obj$TAT), 'skillName']){clmn.ttl[[i]] = i}
  for(i in obj$SP[colnames(obj$TAT), 'skillName']){clmn.clr[[i]] = c('white', rgb(red = 0, green = 0.8, blue = 0))}
  
  names(clmn.shp)   <- obj$SP[colnames(obj$TAT), 'skillName']
  names(clmn.edtbl) <- obj$SP[colnames(obj$TAT), 'skillName']
  names(clmn.accpt) <- obj$SP[colnames(obj$TAT), 'skillName']
  
  ascfg = list(column.color    = clmn.clr,
               column.title    = clmn.ttl,
               column.editable = clmn.edtbl,
               column.acceptor = clmn.accpt,
               # column.footer   = clmn.ftr,
               table.style     = 'table table-bordered',
               column.filter   = list(),
               # Table properties:
               btn_reset       = TRUE,
               height          = 800,
               sort            = TRUE,
               on_keyup        = TRUE,  
               on_keyup_delay  = 800,
               paging          = T,
               paging.length   = 20,
               rows_counter    = TRUE,  
               rows_counter_text = "Count of agents: ",
               col_number_format= rep("US", ncol(obj$TAT)), 
               sort_config = list(
                 # alphabetic sorting for the row names column, numeric for all other columns
                 sort_types = rep("Number", ncol(obj$TAT))
               )
               # exclude the summary row from filtering
               # rows_always_visible = list(nrow(obj$AP))
  )
  return(ascfg)
}

is.skilled = function(row, col, ASTable, MLTable){
  agents = rownames(MLTable)
  skills = colnames(MLTable)
  ASTable[agents[row], skills[col]] > 0
}

MLConfig = function(MLTable){
  clnmsmntbl = colnames(MLTable) %-% 'Total'
  m          = length(clnmsmntbl)
  clmn.edtbl = rep(TRUE, m)   %>% as.list
  clmn.accpt = rep('>= 0', m) %>% as.list %>% lapply(function(x) x %>% c('<= chif(is.skilled(row, col, sync$ASTable, sync$MLTable), 2000, 0)'))
  # for(ii in seq(clmn.accpt)){clmn.accpt[[ii]] %<>% c()}
  clmn.ftr   = list(rownames = 'Total', Total = sum)
  clmn.clr   = list()
  for(i in clnmsmntbl){
    clmn.clr[[i]] = c('white', rgb(red = 0, green = 0.8, blue = 0))
    clmn.ftr[[i]] = sum
  }
  
  names(clmn.edtbl) <- clnmsmntbl
  names(clmn.accpt) <- clnmsmntbl
  
  mlcfg = list(column.color    = clmn.clr,
               column.title    = list(rownames = 'Agent Name'),
               column.editable = clmn.edtbl,
               column.acceptor = clmn.accpt,
               # column.footer   = clmn.ftr,
               table.style     = 'table table-bordered',
               column.filter   = list(),
               # Table properties:
               btn_reset       = TRUE,
               height          = 800,
               sort            = TRUE,
               on_keyup        = TRUE,  
               on_keyup_delay  = 800,
               paging          = T,
               paging.length   = 25,
               rows_counter    = TRUE,  
               rows_counter_text = "Count of agents: ",
               col_number_format= rep("US", ncol(MLTable)), 
               sort_config = list(
                 # alphabetic sorting for the row names column, numeric for all other columns
                 sort_types = c("String", rep("Number", ncol(MLTable)))
               )
  )
  return(mlcfg)
}

timeValidate = function(tt, ub = NULL, lb = NULL){
  tt = try(tt %>% as.time(target_class = 'POSIXct', tz = 'GMT'), silent = T)
  
  if(inherits(tt, 'POSIXct')){
    if(!is.null(ub)){flag = (tt < ub)} else {flag = T}
    if(!is.null(lb)){return(flag & (tt > lb))} else {return(flag)}
  } else {return(F)}
}

MNConfig = function(obj){
  mncfg = list(
    # withRowNames = F,
    column.title = list(rownames = 'Row Number', skill = 'Skill ID', skillName = 'Skill Name', start = 'Started at', due = 'Due at', dueAge = 'Due Age (hrs)', count = 'Work Units', report = 'Report Date'),
    column.acceptor = list(start = '%>% timeValidate(ub = as.POSIXct(sync$MNTable$report[row] + 1))', due = '%>% timeValidate(lb = as.POSIXct(sync$MNTable$start[row]))',count = c('>= 0', '<= 10000')),
    height = 700,
    sort   = T,
    paging = T,
    paging.length   = 20,
    table.style     = 'table table-bordered',
    column.editable = list(start = T, due = T, count = T),
    column.color    = list(start = 'white', due = 'white', count = 'white'),
    selection.mode  = 'multi',
    sort_config = list(
      # alphabetic sorting for the row names column, numeric for all other columns
      sort_types = c("Number", rep("String", 4), rep("Number",2), "String")
    ),
    col_1 = 'select',
    col_2 = 'select'
  )
  return(mncfg)  
}


cscfg = list(
  paging = T,
  paging.length   = 20,
  table.style = 'table table-bordered',
  column.title = list(rownames = 'Task ID', skillName = 'Skill Name', priority = 'Priority', agentName = 'Agent Name', workable = 'Workable', start = 'Started at', due = 'Due at', report = 'Report Date', LO = 'Leftover', age = 'Age (hrs)', dueAge = 'Due Age (hrs)', ageGroup = 'Age Group', dueAgeGroup = 'Due Age Group', status = 'Task Status', AUT = 'Average Unit Time'),
  column.shape = list(LO = 'checkBox', workable = 'checkBox'),
  selection.mode = 'multi',
  rows_counter    = TRUE,  
  sort = T,
  rows_counter_text = "Count of tasks: ",
  # showHide_cols_at_start = c(3,5),
  extensions = list(
    list(name = "sort"),
    list( name = "colsVisibility",
          at_start =  c(1,3, 5, 13, 14, 16),
          text = 'Hide columns: ',
          enable_tick_all =  TRUE
    )
  ),
  sort_config = list(
    # alphabetic sorting for the row names column, numeric for all other columns
    sort_types = c(rep("String", 5), "Number", rep("String", 3), rep("Number",2), rep("String", 5), "Number")
  ),
  
  col_2  = 'select',
  col_4  = 'select',
  col_11 = 'select',
  col_12 = 'select',
  col_15 = 'select'
)

is.true = function(v){
  v %<>% verify('logical', default = F, varname = 'v')
  if(is.na(v)){v = F}
  return(v)
}


MNTable.srvf = function(MNTable, obj){
  library(rhandsontable)
  DF = data.frame(val = 1:10,
                  bool = TRUE,
                  big = LETTERS[1:10],
                  small = factor(letters[1:10]),
                  dt = seq(from = Sys.Date(), by = "days", length.out = 10),
                  stringsAsFactors = FALSE)
  
  rhandsontable(DF)
  
  #if (!is.null(MNTable)){
  #  hsn = MNTable %>% viserPlot(config = list(width = 1200), plotter = 'rhandsontable', type = 'table', colHeaders = c('Skill ID', 'Skill Name', 'Started at', 'Due at', 'Due Age', 'Work Units', 'report'))
  # if (nrow(MNTable) > 0){hsn %<>% hot_col(col = "Skill", type = "dropdown", source = rownames(obj$SP)[obj$SP$skillType == 'Manual'], strict = T)}
  #   return(hsn)
  #}
}

messages = c(
  initial           = "Welcome to the SO! Please enter Username and Password to login.",
  loginFail         = "Sorry! Username or Password are entered incorrectly. Please try again.",
  loginSuccess      = "Welcome user! Please select a team and date, then click on 'Load Data'",
  MNTableAdded      = "One task is added to new non-CommSee Tasks table for the selected skill.",
  MNTable.Deleted   = "Selected rows are removed from the table.",
  ChangesApplied    = "All changes have been applied successfuly!",
  TasksAllocated    = "Task allocation is completed successfuly!",  
  AllocationCleared = "Task allocation is cleared successfuly!",
  APTableApplied    = "Agent profile changes are completed successfully!",
  SPTableApplied    = "Skill profile changes are completed successfully!",
  ASTableApplied    = "Changes to the agent-skill matrix are completed successfully!",
  MLTableApplied    = "Changes to the Manual Leftover Task matrix are completed successfully!",
  MNTableApplied    = "Changes to the Manual New Task table are completed successfully!",
  CSTasksLoadedFromCSV =  "CommSee Tasks are loaded successfully!",
  CSTasksCleared    = "All CommSee tasks are removed for allocation!",
  SPUndoSuccess     = "Skill profile is refreshed to initial state.",
  APUndoSuccess     = "Agent profile is refreshed to initial state.",
  ASUndoSuccess     = "Agent-Skill matrix is refreshed to initial state.",
  written           = "Allocation data are written to the database successfully with allocation ID: ",
  exported          = "Allocation summary saved in your download folder with filename: ",
  notToday          = "Can only allocate for today and the next five working days!"
)


cleanError = function(err_msg){
  err_msg = gsub("-", "", err_msg)
  if (grep(':', err_msg) %>% length == 1){
    ss = err_msg %>% strsplit(':')
    return(ss[[1]][length(ss[[1]])])
  } else {return(err_msg)}
}


#obj$TSK %>% mutate(skill = obj$SP[skill, 'skillName']) %>% highcharter.scatter(x = 'skill', y = 'dueAge', color = 'status', shape = 'status', config = list(point.size = 10, colorize = T, palette.color = c('red', 'blue', 'yellow')))


# Visualisations for promvis:

# Case-based: For selected cases (Cases can be selected from a table. Initially all tasks are selected).  
# filtered by selecting status from L2 process map:
#   process map L2 & L3 (for selected status), timevis
#   task timeline with timevis
#
#   Average case turnaround time
#   Count of reassigns/total reassigns/ average per case/ 



### global.R ---------------------

library(shiny)
library(shinyjs)
library(htmlwidgets) # Because coffeeweel does not import the package
library(shinydashboard)
library(reshape2)
library(tibble)
library(stringr)
library(magrittr)
# Required for CommSee tasks read

# Do something like this if faced problem installing package rJava
# a = Sys.getenv('path')
# a %<>% paste('C:\\Program Files\\Java\\jre1.8.0_161\\bin\\server', sep = ';')
# Sys.setenv(path = a)
# library(rJava)

library(plyr)
library(sqldf)
library(tcltk)
library(lubridate)
library(RODBC)
library(readxl)
library(xlsx)
library(tools)
library(cellranger)
library(lpSolve)

library(gener)
library(otar)
library(viser)

# from project
source('script/iotools.R')
source('script/otavis.R')
source('script/dash.R')

# mylink = list(class.name = 'go-map', column.name = 'select', href = '', inputs = c(id = 'Skill'), shinyInputName = 'goto', icon = 'fa fa-crosshairs', text = '')
# Todos:

# 1- (Done) Maximum for work units in all tables --> Done
# 2- (Done) undefined Columns selected should come with a more meaningful message--> Done  
# 3- (Done) Backlog appears in the diagram --> Done
# 4- The second sunburst
# 5- Balanced Utilisation
# 6- (Done) Change underdue to due at --> Done
# 7- (Done) Change order of task summary table columns --> Done
# 8- (Done) Manual Leftover limit 0 for number of tasks if the agent is not skilled --> Done
# 9- Column names in Excel output should match column names shown on the screen: --> which columns?

# 1- Add Case(Task) Ids to Commsee table
# 2- Eliminate unallocated taSKS FROM EXCEL EXPORT
# Backlog --> Total Tasks
# 


# abccran = 'https://artifactory.ai.abc/artifactory/cran-abc/2018-01-05/'
# nonabccran = 'https://artifactory.ai.abc/artifactory/mran-remote/2018-01-12/'
# 
# install.packages("RJDBC", repos = nonabccran)
# install.packages("rJava", repos = nonabccran)
# install.packages("progress", repos = nonabccran)
# install.packages("getPass", repos = nonabccran)
# 
# install.packages("teradata.abc", repos = abccran)
# install.packages("dbplyr", repos = nonabccran)
# install.packages("dplyr", repos = nonabccran)
# 
# library(dplyr)
# library(dbplyr)
# library(teradata.abc)
# # https://confluence.prod.abc/display/ADS/Dplyr+and+teradata.abc

# Connecting via teradata.abc:
# library(dplyr)
# library(dbplyr)
# library(teradata.abc)
# 
# con = gdw_connect(uid = 'SUOPSANA01', pwd = 'Service#15Connect', local = T)
# his = tbl(con, "APPT_STUS_HIST")
# 
# his %>% group_by()


### readme.md ---------------------

###### 
### script/Archive/parallelUpload.R ---------------------
library(foreach)
library(doSNOW)
library(RODBC)

# Function for uploading in parallel:
parUpload <- function(dataset, upload_destination, dsn_name, delete_query, chunks = 20, error_test=0){
  # An example of a call to this function is:
  # parUpload(dataset = TT, upload_destination = "udrbscms.bmo_ng_allocations_test", dsn_name = Teradata.Dsn, delete_query = alloc.Delete.qry, chunks = 20)
  # Create multiple additional R processes
  cl <- makeCluster(chunks)
  registerDoSNOW(cl)
  # Define the vector of rows to be uploaded by each chunk  
  chunking <- function(x, n){split(x, cut(seq_along(x), n, labels=FALSE))}
  chunkVector <- chunking(1:nrow(dataset), chunks)
  parallelUpload <- 0
  # Setup an inner function which can be put into a tryCatch function
  parallelLoop <- function(dataset, upload_destination, dsn_name, chunks, chunkVector){
    foreach(i=1:chunks, .packages='RODBC') %dopar% {
      # Ensure that a connection is established for each instance, but do not exceed 10 connection attempts
      connectionAttempts <- 0
      while(sum(tryCatch(odbcGetInfo(channel), error=function(c) return(1)) == 1) > 0 & connectionAttempts <= 10){
        channel  = odbcConnect(dsn = dsn_name)
        connectionAttempts <- connectionAttempts + 1
      }
      sqlSave(channel=channel, dat=dataset[chunkVector[[i]],], tablename=upload_destination, append=T, rownames=F, colnames=F, verbose=F, nastring=NULL, fast=T)
    }
    if(error_test == 1){
      stop("Test_Error")
    }
    return(1)
  }
  
  tryCatch(parallelUpload <- parallelLoop(dataset, upload_destination, dsn_name, chunks, chunkVector), error = function(c){
    channel  = odbcConnect(dsn = dsn_name);
    sqlQuery(channel = channel, query = delete_query);
    sqlSave(channel = channel, dat = dataset, tablename = upload_destination, append = T, rownames = F,colnames = F, verbose = T,nastring = NULL,fast =T);
    close(channel);
  }
  )
  
  stopCluster(cl)
  return(if(parallelUpload == 1){"Data Upload in Parallel Successfully"} else {"Data Uploaded Successfully"})
}

### testCA.R ---------------------
library(magrittr)
library(dplyr)

source('C:/Nicolas/RCode/packages/master/promer/R/ota.tools.R')
source('C:/Nicolas/RCode/packages/master/promer/R/ota.R')
source('C:/Nicolas/RCode/packages/master/gener-master/R/gener.R')


x = readRDS('data/x_object_20180525.RDS')

x2 = x %>% distributeTasks(flt2IntCnvrsn = 'round')




### bankwest.R ---------------------
# Test SO for BankWest:
library(magrittr)
library(dplyr)
library(gener)
library(promer)
library(lpSolve)

SP = read.csv('data/BW_HLT/skills.csv')
AP = read.csv('data/BW_HLT/agents.csv')
AS = read.csv('data/BW_HLT/agent_skill_molten.csv')
TS = read.csv('data/BW_HLT/tasks.csv')
TS$USR_ID[TS$USR_ID == 0] <- NA
AS$AUT = 1.0 + floor(AS$AUT/60)

TS$START_TIME %<>% as.POSIXct
TS$DUE_AGE = Sys.time() %>% difftime(TS$START_TIME, units = 'hours')
AP$USR_ID %<>% as.character
SP$PTS_ID %<>% as.character
TS$USR_ID %<>% as.character
TS$PTS_ID %<>% as.character
SP$PRW = 0

x = OptimalTaskAllocator() %>% 
  feedAgents(AP, agentID_col = 'USR_ID', extra_col = c(agentName = 'FULL_NAME')) %>% 
  feedSkills(SP, skillID_col = 'PTS_ID', score_col = 'CONVERSIONRATE', extra_col = c(skillName = 'QUEUENAME', PRW = 'PRW')) %>% 
  feedAgentSchedule(AP, agentID_col = 'USR_ID', scheduled_col = 'PRODUCTION_MINUTES') %>% 
  feedAgentTurnaroundTime(AS, agentID_col = 'USR_ID', skillID_col = 'PTS_ID', tat_col = 'AUT') %>%
  feedTasks(TS, taskID_col = 'CSE_ID', skillID_col = 'PTS_ID', priority_col = 'DUE_AGE', agentID_col = 'USR_ID',  
            extra_col = c(start = 'START_TIME'))


x1 = x %>% distributeTasks(Kf = 0.0)
x2 = x %>% distributeTasks(Kf = 1.0)
x3 = x %>% distributeTasks(Kf = 1.0) %>% balanceWeightedScores(Kf = 0.0, Ku = 0)


S1 = x1$TSK %>% mutate(score = x1$SP[skill, 'score'])  %>% filter(!is.na(agent)) %>% group_by(agent) %>% summarise(sumScore = sum(score)) 
S1$rate = 60*S1$sumScore/x1$AP[S1$agent,'scheduled']

S2 = x2$TSK %>% mutate(score = x2$SP[skill, 'score']) %>% group_by(agent) %>% summarise(sumScore = sum(score))
S2$rate = 60*S2$sumScore/x2$AP[S2$agent,'scheduled']


S3 = x3$TSK %>% mutate(score = x3$SP[skill, 'score']) %>% group_by(agent) %>% summarise(sumScore = sum(score))
S3$rate = 60*S3$sumScore/x3$AP[S3$agent,'scheduled']


sd(S1$rate, na.rm = T)
sd(S2$rate, na.rm = T)
sd(S3$rate, na.rm = T)

sum(x1$SP$newAllocated)
sum(x2$SP$newAllocated)
sum(x3$SP$newAllocated)


### estimate_AUT.R ---------------------
qry.1 = 
  "
SELECT 
TRUNC(TO_DATE(LEFT(scorecard_date,10),'YYYY-MM-DD')) AS SCDATE, 
empl_i AS agentID,
CAST(kpi_actual_value*27360.0 AS FLOAT) AS ProdTime 

FROM UDRBSCMS.VCC_PRODUCTIVITY AS vccp
WHERE Organization_Name IN ('|GLS-AFSP| RV Credit Card Verifications 1', '|GLS-AFSP| RV Credit Card Verifications 2')
AND kpi_name = '..07. Production Hours - FTE (d)' 
AND CAST(kpi_actual_value AS FLOAT) > 0
AND empl_i IS NOT NULL 
AND empl_i NOT IN ('00309982', 'NULL')
AND SCDATE BETWEEN TO_DATE('2017-05-01','YYYY-MM-DD') AND TO_DATE('2017-07-19','YYYY-MM-DD')
"
qry.2 =
  "
SELECT 
QNAME AS SkillID, 
TRUNC(updt_dt) AS SCDATE,
CAST('00' AS VARCHAR(20))  || CAST(empl_i  AS VARCHAR(20)) AS AgentID, 
SUM(EVNT_VAL) AS TaskCount
FROM UDRBSCMS.i360_Outcomes
WHERE empl_org IN  ('|GLS-AFSP| RV Credit Card Verifications 1', '|GLS-AFSP| RV Credit Card Verifications 2')
AND evnt_val > 0
AND TRUNC(updt_dt) BETWEEN TO_DATE('2017-05-01','YYYY-MM-DD') AND TO_DATE('2017-07-19','YYYY-MM-DD')
AND qname NOT LIKE '%inventory%' AND qname NOT LIKE '%incomplete%'
AND empl_i <> 309982
GROUP BY
QNAME, TRUNC(updt_dt),empl_i
"

library(RODBC)
library(magrittr)
library(gener)
library(mather)
library(promer)

channel  = odbcConnect(dsn = 'Teradata_Prod')
AUH        = sqlQuery(channel = channel, query = qry.1)
ACH        = sqlQuery(channel = channel, query = qry.2)
close(channel)

y = OptimalTaskAllocator() %>% 
  feedAgentUtilizationHistory(AUH, date_col = 'SCDATE', prodTime_col = 'ProdTime') %>%
  feedAgentCountHistory(ACH, date_col = 'SCDATE', agent_col = 'AgentID', skill_col = 'SkillID', taskCount_col = 'TaskCount') %>%
  calcAgentTAT

write.csv(y$TAT, 'tables/CCV_AUT.csv')
### for_eliot.R ---------------------
# Test SO for BankWest:
library(magrittr)
library(dplyr)
library(gener)
library(promer)
library(lpSolve)

x = readRDS('data/x_object.rds') %>% clearAllocation

x1 = x %>% distributeTasks
x2 = x1 %>% balanceWeightedScores(Kf = 100.0)
x3 = x %>% distributeTasks(Kf = 100.0)
x4 = x3 %>% balanceWeightedScores(Kf = 100.0)

x5 = x %>% distributeTasks(Kf = 1000.0)
x5 = x5 %>% promer::balanceWeightedScores(Kf = 1000.0)

S1 = x1$TSK %>% filter(!is.na(agent)) %>% group_by(agent) %>% summarise(sumScore = sum(score)) 
S1$rate = 100*S1$sumScore/x1$AP[S1$agent,'utilized']

S2 = x2$TSK %>% group_by(agent) %>% summarise(sumScore = sum(score))
S2$rate = 100*S2$sumScore/x2$AP[S2$agent,'utilized']

S3 = x3$TSK %>% group_by(agent) %>% summarise(sumScore = sum(score))
S3$rate = 100*S3$sumScore/x3$AP[S3$agent,'utilized']

S4 = x4$TSK %>% group_by(agent) %>% summarise(sumScore = sum(score))
S4$rate = 100*S4$sumScore/x4$AP[S4$agent,'utilized']

S5 = x5$TSK %>% group_by(agent) %>% summarise(sumScore = sum(score))
S5$rate = 100*S5$sumScore/x5$AP[S5$agent,'utilized']

sd(S1$rate, na.rm = T)
sd(S2$rate, na.rm = T)
sd(S3$rate, na.rm = T)
sd(S4$rate, na.rm = T)
sd(S5$rate, na.rm = T)

sum(x1$SP$newAllocated)
sum(x2$SP$newAllocated)
sum(x3$SP$newAllocated)
sum(x4$SP$newAllocated)
sum(x5$SP$newAllocated)

##############################################################################################################
x = readRDS('data/this.rds')
x$TSK$score = 1
x %<>% updateAgentUtilization %>% updateTaskCounts

x2 = x %>% distributeTasks(prioritization = 'timeAdjusted')





###### Old dashboards =============================
### dash.R --------------------------
# Header
# Filename:       dash.R
# Description:    This file creates the first shiny UI for the bextgen wfo project. 
# Author:         Nicolas Berta 
# Email:          nicolas.berta@abc.com
# Start Date:     10 May 2017
# Last Revision:  10 May 2017
# Version:        0.1.1

# Version History:

# Version   Date              Action
# ----------------------------------
# 0.0.1     10 May 2017       Initial Issue

# pre-code:
agentProfileLabels = list('Full Name' = 'EMPL_FULL_M', 'Team Name' = 'TEAM_I', 'Productive Time (min)' = 'prodTime',
                          'Leftovers' = 'LFTVRS', 'Assigned' = 'ASSGND', 'Total Allocated' = 'TOT.ALCTD', 'Utilized (min)' = 'Utilized')

skillProfileLabels = list('Skill Name' = 'SKILL_M', 'Type' = 'SKILL_TYPE',
                          'Leftovers', 'Assigned', 'Total Allocated' = 'Allocated', 'Backlog')

apcfg = list(column.shape    = list(prodTime = 'bar'),
             column.title    = list(rownames = "Agent ID", EMPL_FULL_M = "Agent Name",	prodTime = "Productive Time (min)"),
             column.editable = list(prodTime = T),
             column.footer   = list(rownames = 'Total', prodTime = sum),
             table.style     = 'table table-bordered',
             column.filter   = list(prodTime = '>0'),
             # Table properties:
             btn_reset       = TRUE,
             height          = 800,
             sort            = TRUE,
             on_keyup        = TRUE,  
             on_keyup_delay  = 800,
             rows_counter    = TRUE,  
             rows_counter_text = "Count of productive agents: ",
             col_number_format= c(NULL, NULL, "US"), 
             sort_config = list(
               # alphabetic sorting for the row names column, numeric for all other columns
               sort_types = c("String", "String", "String", "Number", "Number")
             ),
             # col_1 = "select",
             # col_2 = "select",
             # exclude the summary row from filtering
             rows_always_visible = list(nrow(x$AP))
)

metricloth = list(type = 'box', status = "primary", solidHeader = F, collapsible = F, weight = 12, title = 'Agent Profile', background = 'aqua')

# Service Functions:
service.task.profile.table  = "x$TSK %>% DT.table"
service.agent.profile.table = "x$AP %>% DT.table(label = agentProfileLabels)"
service.skill.profile.table = "x$SP %>% DT.table(label = skillProfileLabels, config = list(withRowNames = F))"
service.aut.table = "cbind('Agent Full Name' = x$AP$EMPL_FULL_M, x$TAT) %>% DT.table"
service.skill.bubble = paste(
  "x %<>% tableSkills",
  "x$SP %>% bubbles.bubble(size = 'Backlog', color = 'SKILL_TYPE', tooltip = 'SKILL_M', label = 'SKILL_M', config = list(labelThreshold = 0.05))",
  sep = "\n")
service.skill.bubble = paste(
  "x %<>% tableSkills",
  "x$SP %>% d3plus.bubble.molten(size = 'Backlog', label = 'SKILL_M', group = 'SKILL_TYPE')",
  sep = "\n")

service.agent.bar = paste(
  "x$AP %>% zero.omit('TOT.ALCTD') %>% na.omit %>% arrange(TOT.ALCTD) %>% plotly.combo(y = list('Agent Full Name' = 'EMPL_FULL_M'), x = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND'), shape = 'bar', config = list(barMode = 'stack'))",
  sep = "\n")

service.agent.bar = paste(
  "x$AP %>% zero.omit('Allocated') %>% na.omit %>% arrange(Allocated) %>% highcharter.combo(y = list('Agent Full Name' = 'EMPL_FULL_M'), x = list('Left Overs' = 'Leftovers', 'New Tasks Assigned' ='Assigned'), shape = 'bar', config = list(barMode = 'stack'))",
  sep = "\n")

tdy = Sys.Date()
ydy = tdy - 1
tmr = tdy + 1

val = reactiveValues()

val      = reactiveValues()
val$agent  = NULL
val$skill  = NULL

# Elements:

I = list()
O = list()

# Clothes:

# Containers:

I$main      = list(type = 'dashboardPage', title = 'BI&A nxtgn Workforce Optimization Toolbox', layout.head = c() ,layout.body = 'tabset', layout.side = c(), header.title = 'BI&A nxtgn Workforce Optimization Toolbox')

I$tabset    = list(type = 'tabsetPanel', selected = "Task Overview", layout = c('tab1', 'tab2', 'tab3'))
I$tab1      = list(type = 'tabPanel' , title = "Task Overview", layout = 'taskPage')
I$tab2      = list(type = 'tabPanel' , title = "Administration", layout = 'adminPage')
I$tab3      = list(type = 'tabPanel' , title = "Allocation Overview", layout = 'allocPage')

I$taskPage    = list(type = 'fluidPage', layout = list(list('filters', 'ageHist', 'ageDonut'), 'line', list('taskTable', 'skillBubble')))
I$adminPage   = list(type = 'fluidPage', layout = list('up', 'down'))
I$allocPage   = list(type = 'fluidPage', layout = list(list('allocDonut', 'allocHeatmap', 'alloabcrPie'), list('allocTable', 'allocCW')))

I$up   = list(type = 'fluidPage', layout = list(list('APBox', 'SPBox', 'ASBox', 'MLBox', 'MNBox')))  # Metric Boxes
I$down = list(type = 'navbarPage', layout = c('APTab', 'SPTab', 'ASTab', 'MLTab', 'MNTab'))

I$APTab = list(type = 'tabPanel', title = 'Agent Profile', layout = 'APPage')
I$SPTab = list(type = 'tabPanel', title = 'Skill Profile', layout = 'SPPage')
I$ASTab = list(type = 'tabPanel', title = 'Agent-Skill Matrix', layout = 'ASPage')
I$MLTab = list(type = 'tabPanel', title = 'manual Leftover Task Summary', layout = 'manual')
I$MNTab = list(type = 'tabPanel', title = 'manual New Task Summary', layout = 'MNPage')

I$APPage  = list(type = 'fluidPage', layout = list(list('APTable', 'agentUtilBar')))
I$SPPage  = list(type = 'fluidPage', layout = list(list('SPTable', 'skillPriorityBar')))
I$ASPage  = list(type = 'fluidPage', layout = list(list('MLTable', 'ASHeatmap')))
I$MNPage  = list(type = 'fluidPage', layout = list(list('AUTTable', 'MNDonut')))
I$manual  = list(type = 'fluidPage', layout = list(list('MNTable', 'Panda')))

# The table item AUTTable is not shown becasue of the name of the item beside it!!!!
##### STUPID!!!! change MNDonat to soroosh, Jingool, MLDonar, .... and it will work!!!!!!! 
## names that work: Panda, soroosh, Jingool, MLDonar, MLDonut, MLDonuts, ...
## names that don't work: MLDonut, Nicolas, looloo, ...

I$filters   = list(type = 'box' , title = 'Filters', width = 'auto', weight = 1, layout = 'getFilters')

# Inputs:

I$getFilters = list(type = 'checkboxGroupInput', title = 'Task Filters', choices =  c('Not Workable', 'Leftovers', 'Allocated', 'Unallocated', 'Rescheduled and due'), value = T)

# Outputs:
O$ageHist   = list(type = 'plotlyOutput'   , title = 'Age Histogram', width = 'auto', height = '350px', weight = 5, service = "x %>% backlog.bar")
O$ageDonut  = list(type = 'morrisjsOutput' , title = 'Age Distribution', width = 'auto', height = '350px', weight = 3, service = "x %>% age.donut")
O$dueAgeDonut  = list(type = 'morrisjsOutput' , title = 'Due Age Distribution', width = 'auto', height = '350px', weight = 3, service = "x %>% age.donut")

O$taskTable  = list(type = 'dataTableOutput' , title = 'Task List', service = service.task.profile.table)
O$SPTable    = list(type = 'dataTableOutput' , title = 'Skill Profile', service = service.skill.profile.table)
O$AUTTable   = list(type = 'dataTableOutput' , title = 'Agent-Skill Matrix', service = service.skill.profile.table)
O$MLTable    = list(type = 'dataTableOutput' , title = 'Manual Leftover Task Summary', service = service.aut.table)
O$MNTable    = list(type = 'dataTableOutput' , title = 'Manual New Task Summary', service = "MTS[,c(2,3, 4, 5,6)] %>% DT.table")
O$APTable    = list(type = 'D3TableFilterOutput' , title = 'Agent Profile', height = '800px', sync = T, data = x$AP[, (apcfg$column.title %>% names)[-1] ], config = apcfg)
O$allocTable = list(type = 'tableOutput' , title = 'Allocation Summary', weight = 6, service = "x$ALC")
O$allocCW    = list(type = 'coffeewheelOutput' , title = 'Allocation Wheel', width = 'auto', weight = 6, service = "x %>% allocation.coffeewheel")

O$skillBubble  = list(type = 'bubblesOutput' , title = 'Skill Bubble', width = 'auto', weight = 4, height = '500px', service = "x %>% backlog.bubble")
O$alloabcrPie  = list(type = 'highcharterOutput' , title = 'Agent Bar', width = 'auto', height = '350px', weight = 6, service = service.agent.bar)
O$allocDonut   = list(type = 'morrisjsOutput' , title = 'Allocated/Unallocated', width = 'auto', height = '350px', weight = 3, service = "x %>% age.donut")
O$Panda   = list(type = 'morrisjsOutput' , title = 'Age Distribution', service = "x %>% age.donut")
O$allocHeatmap = list(type = 'plotlyOutput' , title = 'Allocation Heatmap', width = 'auto', height = '350px', weight = 3, service = "x %>% backlog.bar")
O$ASHeatmap    = list(type = 'plotlyOutput' , title = 'Agent Skill Heatmap', width = 'auto', height = '350px', weight = 3, service = "x %>% backlog.bar")
O$agentUtilBar = list(type = 'highcharterOutput' , title = 'Agent Untilisation', width = 'auto', height = '600px', weight = 6, service = service.agent.bar)
O$skillPriorityBar = list(type = 'highcharterOutput' , title = 'Skill Priority', width = 'auto', height = '350px', weight = 6, service = service.agent.bar)
O$line        = list(type = 'static', object = hr())

O$APBox = list(type = 'uiOutput', cloth = metricloth)
O$SPBox = list(type = 'uiOutput', cloth = metricloth)
O$ASBox = list(type = 'uiOutput', cloth = metricloth)
O$MLBox = list(type = 'uiOutput', cloth = metricloth)
O$MNBox = list(type = 'uiOutput', cloth = metricloth)

O$MNDonut   = list(type = 'morrisjsOutput' , title = 'Due Age Distribution', service = "x %>% dueAge.donut")

# Observers:
OB = list()

dash = new('DASHBOARD', items = c(O, I), king.layout = list('main'), observers = OB)

ui     <- dash$dashboard.ui()
server <- dash$dashboard.server()


shinyApp(ui, server)

### dash.Rmd --------------------------
---
  title: "BI&A Workforce Optimization Toolbox"
author: "NIBESOFT"
date: "16 March 2017"
output: 
  flexdashboard::flex_dashboard:
  orientation: rows
social: menu
runtime: shiny
---
  
  ```{r setup, include=T}
knitr::opts_chunk$set(echo = F)

library(flexdashboard)
library(timeDate)
library(dygraphs)
library(plotly)
library(googleVis)
library(RODBC)
library(dplyr)
library(reshape2)
library(MASS)
library(nloptr)
library(lpSolve)
library(magrittr)

# prepare objects:
val      = reactiveValues()
val$AGID = NULL
val$TTID = NULL

```
Dashboard
=======================================================================
  
  <!-- Inputs {.sidebar} -->
  <!-- ------------------------------------- -->
  
  <!-- ```{r} -->
  <!-- # shiny inputs defined here -->
  <!-- ``` -->
  
  
  Metrics
-----------------------------------------------------------------------
  
  ### Task Type ID {.value-box}
  
  ```{r}
# Shows the average amount of time (per case) spent in this status
renderValueBox({
  valueBox(
    value = val$TTID,
    icon = "fa-task",
  )
})
```

### Total Backlog {.value-box}
```{r}
# Shows distribution to next statuses by a pie chart 
# Emit the user count
renderValueBox({
  val = sum(x$SP[val$TTID, 'Backlog'], na.rm = T)
  valueBox(value = val, icon = "credit-card", color = chif(val >= 2000, "warning", "primary"))
})
```

### Agent ID {.value-box}

```{r}
# Shows the average (per day) number of cases entered in this status or inter-arrival time
renderValueBox({
  valueBox(val$AGID, icon = "fa-user")
})
```

### Average Productive Time (Hrs) {.value-box}

```{r}
# Shows the average daily exit rate (number of cases emitted from the status per day)  
# icon domain for valueBox: fa-download, fa-user, fa-users, fa-area-chart
renderValueBox({
  valueBox(prettyNum(x$AP[val$AGID, 'prodTime']/3600, digits = 2), icon = "fa-time")
})
```


Bubbles
-----------------------------------------------------------------------
  
  ### Task Types {data-width=3}
  ```{r}
# fillCol(
#   selectInput('selTaskType', 'Selecet Task Type', x$skills),
#   bubblesOutput('tsktBub'),
#   flex = c(1, 5))
bubblesOutput('tsktBub')
output$tsktBub <- renderBubbles({
  # stop('\n \n agentID = ',val$AGID, 'taskType = ',val$TTID)
  x %<>% tableSkills
  x$SP %>% bubbles.bubble(size = 'Backlog', color = 'SKILL_TYPE', tooltip = 'SKILL_M', label = 'SKILL_M', config = list(labelThreshold = 0.01))})
# observeEvent(input$selTaskType, {val$TTID = input$selTaskType})
observeEvent(input$tsktBub_click , 
             {
               # debug(check)
               val$TTID = chif(input$tsktBub_click == 0, NULL, x$skills[input$tsktBub_click])
               # check(input$tsktBub_click, x$SP$SKILL_M[input$tsktBub_click], val$TTID)
             })
```

### Agents  {data-width=3}
```{r}
# fillCol(
#   selectInput('selAgentID', 'Selecet Agent ID', x$agents, selected = NULL, multiple = F),
#   bubblesOutput('agntBub'),
#   flex = c(1, 5))
bubblesOutput('agntBub')
output$agntBub <- renderBubbles({
  x %<>% tableAgents(skill_set = val$TTID)
  x$CAP %>% bubbles.bubble(size = 'C.TOT.ALCTD', label = 'AgentID', labelColor = 'black', color = 'speed', tooltip = 'AgentID', config = list(palette = list(color = c('red', 'yellow', 'green')), labelThreshold = 0.01))
})
```

Info {.tabset .tabset-fade data-height=350}
-----------------------------------------------------------------------
  ### Volume Time Series  {data-width=6} 
  
  ```{r}
dataTableOutput('agp')
renderDataTable({x$AP %>% DT.table()})
# renderDygraph({v$plot.history(period = 1:v$N.int, figures = x$agents[1:5])})
```

### Volume Time Series  {data-width=6} 

```{r}

#renderPlotly({v$plot.history(period = 1:v$N.int, figures = x$agents[1:5], package = 'plotly')})
```

### densityPlot.R --------------------------
X <- c(rep(65, times=5), rep(25, times=5), rep(35, times=10), rep(45, times=4))

# X = x$TSK[x$TSK$priority <21, 'priority']

# x %<>% smartMapTaskPriorities
hist(X, prob=TRUE, col="cyan", xlab = 'Due Age (day)', main = 'Probability Density Function (PDF) of task priorities')
lines(density(X, adjust=0.5), col="blue", lwd=3) # add a density estimate with defaults

xp = x$TSK[x$TSK$priority < 5, 'priority']
polygon(density(X, adjust=0.5), col = "gray")

lines(density(X, adjust=0.5), lty="dotted", col="darkgreen", lwd=2) 


### tavis.R --------------------------

# Header
# Filename:     tavis.R
# Description:  Contains functions to generate visualisation components for task allocation
# Author:       Nicolas Berta 
# Email :       nicolas.berta@gmail.com
# Start Date:   26 May 2017
# Last change:  26 May 2017
# Version:      0.0.1

# Version   Date               Action
# -----------------------------------
# 0.0.1     26 May 2016        Initial Issue

source('C:/Nicolas/RCode/projects/libraries/developing_packages/morrisjs.R')


# C1: Donut chart showing allocated vs not-allocated
allocated.donut = function(x, skill = NULL){
  if(is.null(skill)){skill = x$skills}
  tbl = x$SP[skill, c('Allocated', 'Unallocated'), drop = F] %>% colSums(na.rm = T) %>% as.data.frame %>% appendCol(c('green', 'red')) %>% zero.omit 
  names(tbl) = c('count', 'colour')
  tbl %>% morrisjs.pie(label = rownames(tbl), theta = 'count', color = 'colour', config = list(colorize = F))
}

# C2: Returns the number of tasks in the backlog
backlog.info = function(x, skill){x$SP[skill, 'Backlog']}

# C3: Returns the number of tasks allocated fresh by the models (allocated but not leftovers)
assigned.info = function(x, skill){}

# C4: Generates donut chart showing age distribution
age.donut = function(x, skill){
  trans = c("(0,24]" = "Less than 1 day", "(24,48]" = "1-2 days", "(48,120]" = "2-5 days", "(120,240]" = "5-10 days", "(240, Inf]" = "Over 10 days")
  x$TSK$age = (x$TSK$current %>% as.POSIXlt) - (x$TSK$start %>% as.POSIXlt)
  tbl = x$TSK$age %>% as.numeric %>% cut(breaks = 24*c(0, 1, 2, 5, 10, Inf)) %>% table %>% as.data.frame %>% column2Rownames
  tbl$Age <- trans[rownames(tbl)]
  tbl %>% morrisjs.pie(label = 'Age', theta = 'Freq')
}

dueAge.donut = function(x, skill){
  trans = c("(-Inf,-240]" = "More than 10 days underdue", "(-240,-120]" = "5-10 days underdue", "(-120,-48]" = "2-5 days underdue", "(-48,-24]" = "1-2 days underdue", "(-24,0]" = "due today", 
            "(0,24]" = "Less than 1 day overdue", "(24,48]" = "1-2 days overdue", "(48,120]" = "2-5 days overdue", "(120,240]" = "5-10 days overdue", "(240, Inf]" = "More than 10 days overdue")
  x$TSK$dueAge = (x$TSK$current %>% as.POSIXlt) - (x$TSK$due %>% as.POSIXlt)
  tbl = x$TSK$dueAge %>% as.numeric %>% cut(breaks = 24*c(-Inf, -10, -5, -2, -1, 0, 1, 2, 5, 10, Inf)) %>% table %>% as.data.frame %>% column2Rownames
  tbl$DueAge <- trans[rownames(tbl)]
  tbl %>% zero.omit(colname = 'Freq') %>% morrisjs.pie(label = 'DueAge', theta = 'Freq', color = list(AgeCol = "Freq"), config = list(colorize = T))
}

# C5: Generates barchart of backlog
backlog.bar = function(x){x$SP %>% plotly.combo(x = 'SKILL_M', y = 'Backlog')}

# C6: Generates bubble chart showing backlog as size (Each bubble represents a skill)
backlog.bubble = function(x, skill){
  x$SP %>% na.omit %>% zero.omit(colname = 'Backlog') %>% 
    bubbles.bubble(size = 'Backlog', color = 'SKILL_TYPE', tooltip = 'SKILL_M', label = 'SKILL_M', config = list(labelThreshold = 0.1))
}

# C7: Returns a stack barchart representing agent utilization and reserved time for leftovers
util.bar = function(x){
  x$AP %>% zero.omit('prodTime') %>% arrange(prodTime) %>% 
    highcharter.combo(y = list('Available' = (x$AP$prodTime - x$AP$reservedTime) %>% trim, 'Required for Leftovers' = 'reservedTime'),
                      x = list('Agent Name' = 'EMPL_FULL_M'),
                      shape = list('bar','bar'), config = list(barMode = 'stack'))
  
}

# C8: Showslist of tasks filtered for the given skill
taskList.table = function(x, skill){
  x$TSK$start %<>% as.character
  x$TSK$due   %<>% as.character
  lbl = list(Skill = x$SP[x$TSK$skill, 'SKILL_M'], 'Assigned to' = x$AP[x$TSK$agent, 'EMPL_FULL_M'],
             'Started at' = 'start', 'Due at' = 'due', 'Leftover' = 'LO', 'Age' = 'age', 'Due Age' = 'dueAge')
  x$TSK %>% 
    DT.table(label = lbl)
}

# C9: generates a coffeewhee showing a complete overview of allocations
allocation.coffeewheel = function(x){
  x$TSK %>% 
    mutate(Agent = x$AP[agent, 'EMPL_FULL_M']) %>%
    mutate(Skill = x$SP[skill, 'SKILL_M']) %>%
    mutate(Leftover  = LO %>% ifelse('Leftover', 'New')) %>% 
    dplyr::group_by(Skill, Leftover, Agent) %>% dplyr::summarize(Count = length(AUT)) %>% as.data.frame %>% 
    coffeewheel.pie(label = list('Skill', 'Leftover', 'Agent'), theta = 'Count')
}

# C10: Leftover Donut: Represents a donut chart showing leftover distribution over skills
# C11: Leftover Donut: Represents a donut chart showing leftover distribution over agents

# C12
#workable.coffeewheel

#allocated.skill.donut
#allocated.agent.donut

# C13: Generates histogram chart showing age distribution
age.histogram = function(x, skill){}


### test_suraj.R --------------------------
TB = read.csv('tables/backlog.csv')
names(TB) <- c('taskID', 'taskType', 'priorityWeight')
TB$priorityWeight <- vect.map(TB$priorityWeight, 0.1, 1.0)

AS = read.csv('tables/agentSkill.csv', rownames = 1)
AS[AS == 0] <- NA

TT = AS[,2:6]
rownames(TT) <- AS$agentID

util = AS$AvailableTime
names(util) <- rownames(TT)

X <- distribiuteTasks(agentSkill = TT, taskBacklog = TB, agentUtil = util)

# test utilization constraint:

write.csv(X, 'R_allocations.csv')

### genWFO.R -------------------

# 30 March 2017: Version 2.0.0 Initiated for Maneli's team

library(RODBC)
library(plyr)
library(tibble)
library(dplyr)
library(reshape2)
library(MASS)
library(nloptr)
library(lpSolve)
library(magrittr)

# gener:
source('C:/Nicolas/RCode/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/linalg.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/io.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/optim.R')

# time series
source('C:/Nicolas/RCode/projects/libraries/developing_packages/time.series.R')

# prom
source('C:/Nicolas/RCode/projects/libraries/developing_packages/wfo.tools.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/wfo.R')

# viser:
source('C:/Nicolas/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/rAmCharts.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/rCharts.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/highcharter.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/plotly.R')

# from project
source('C:/Nicolas/RCode/projects/abc/abc.nxtgn.wfo (Developing)/script/wfo.abc.tools.R')

extra.1 = c(start = 'START_DT', due = 'DUE_DT', current = 'report_d')
extra.2 = c(start = 'START_DT', due = 'DUE_DT', current = 'REPORT_D')

# Live data
date = Sys.Date()
# date = "2017-05-14" %>% as.Date

AP    = readAgents.Maneli()
AS    = readAgentSchedule.Maneli(date)
SP    = readSkills.Maneli(date)
AT    = readAgentTAT.Maneli(date)
TL    = readTaskList.Maneli(date) 
MTS   = readManualTaskSummary.Maneli(date) 
MTS.L = readManualTaskSummary.leftover.Maneli(date)


# Remove Re-scheduled tasks which are not due:
TL    = TL[!TL$RSHD_FLAG | TL$DUE_FLAG,] 
MTS   = MTS[!MTS$RSHD_FLAG | MTS$DUE_FLAG,]
MTS.L = MTS.L[!MTS.L$RSHD_FLAG | MTS.L$DUE_FLAG,]

MTL   <- MTS   %>% taskSummary2TaskList(skill_col = 'SKILL_ID', count_col = 'WORK_UNITS', priority_col = "AGE_DUE", agent_col = 'EMPL_I', extra_col = c('SKILL_M', 'START_DT', 'DUE_DT', 'REPORT_D'))
MTL.L <- MTS.L %>% taskSummary2TaskList(skill_col = 'SKILL_ID', count_col = 'WORK_UNITS', priority_col = "AGE_DUE", agent_col = 'EMPL_I', extra_col = c('SKILL_M', 'START_DT', 'DUE_DT', 'REPORT_D'), start_id = nrow(MTL) + 1)

# MTL$DUE_DT   = MTL$DUE_DT - rnorm(n = nrow(MTL), mean = 4*3600, sd = 2*3600)
# MTL$priority = ((MTL$REPORT_D %>% as.POSIXlt) - MTL$DUE_DT)/24

# MTL.L$DUE_DT = MTL.L$DUE_DT - rnorm(n = nrow(MTL.L), mean = 4*3600, sd = 2*3600)
# MTL.L$priority = ((MTL.L$REPORT_D %>% as.POSIXlt) - MTL.L$DUE_DT)/24

# Build the model
x = OptimalTaskAllocator() %>% 
  feedAgents(AP[,  -(5:7)], agentID_col = 'EMPL_I') %>% 
  feedSkills(SP[, -c(6,7)], skillID_col = 'SKILL_ID') %>% 
  feedAgentProductiveTime(AS, agent_col = 'EMPL_I', prodTime_col = 'prod_time_in_minutes') %>% 
  feedAgentTurnaroundTime(AT, agent_col = 'EMPL_I', skill_col = 'SKILL_ID', tat_col = 'AUT_IN_MINUTES') %>%
  feedTasks(TL, taskID_col = 'PROCESS_ID', skill_col = 'SKILL_ID', priority_col = 'AGE_DUE', agentID_col = 'EMPL_I', extra_col = extra.1) %>% 
  feedTasks(MTL, skill_col = 'skillID', priority_col = 'priority', agentID_col = 'alctdAgent', extra_col = extra.2) %>%
  feedTasks(MTL.L, skill_col = 'skillID', priority_col = 'priority', agentID_col = 'alctdAgent', extra_col = extra.2)

i2 = which(x$TSK$skill == '2')
i3 = which(x$TSK$skill == '3')
x$TSK$priority     = x$TSK$priority + 1
x$TSK$priority[i2] = x$TSK$priority[i2]*2.0
x$TSK$priority[i3] = x$TSK$priority[i3]*5.0

x %<>% distributeTasks

# Adding Start Date-Times:
x$TSK[TL$PROCESS_ID %>% as.character, 'Start_DT'] <-  TL$START_DT %>% as.character
x$TSK[rownames(MTL), 'Start_DT'] <-  MTL$START_DT %>% as.character
x$TSK[rownames(MTL.L), 'Start_DT'] <-  MTL.L$START_DT %>% as.character


# Adding task ages wrt the report date-time or load doate-time:

# t1 = x$TSK$start %>% as.POSIXlt
# t2 = x$TSK$due %>% as.POSIXlt
# Sys.time()
# tt = t2 - t1

# View(x$TSK)

# Save:

write.csv(x$TSK, 'allocated.csv')

saveRDS(x, 'data/wfo.rds')
x = readRDS('data/wfo.rds')

# Try writing it in the data-mart
channel  = odbcConnect(dsn = 'Teradata_Prod')
TT      = x$TSK
TT$Date = (date + 1) %>% as.character
TT = cbind(PID = rownames(x$TSK), TT)
rownames(TT) <- NULL

sqlSave(channel = channel, dat = TT, tablename = 'udrbscms.bmo_ng_allocations', append = T, rownames = F)
# sqlDrop(channel = channel, 'udrbscms.bmo_ng_allocations')
# sqlUpdate(channel = channel, dat = TT, tablename = 'udrbscms.bmo_ng_allocations', index = c('PID', 'Date'))
# sqlQuery(channel, "DELETE FROM udrbscms.bmo_ng_allocations WHERE \"Date\" = '2017-05-09'")
close(channel)


# Some Charts:
cfg = list(barMode = 'stack')

x$SP %>% highcharter.combo(x = 'SKILL_M', y = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND', 'Un-Allocated' = 'UNALCTD'), shape = 'bar', config = cfg)
x$SP %>% plotly.scatter(x = 'SKILL_M', y = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND', 'Un-Allocated' = 'UNALCTD'), shape = 'bar', config = cfg)
x$SP %>% rAmCharts.bar(x = 'SKILL_M', y = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND', 'Un-Allocated' = 'UNALCTD'), config = cfg)
x$SP %>% dygraphs.combo(x = 'SKILL_M', y = list('Backlog', 'Total Allocated' = 'TOT.ALCTD', 'Left Overs' ='LFTVR'), shape = 'bar', config = cfg)
x$SP %>% rCharts.combo(x = 'SKILL_M', y = list('Backlog', Total_Allocated = 'TOT.ALCTD', Left_Overs ='LFTVRS'), shape = 'bar', config = cfg)

x$AP %>% highcharter.combo(y = 'EMPL_FULL_M', x = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND'), shape = 'bar', config = cfg)
x$AP %>% plotly.combo(y = 'EMPL_FULL_M', x = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND'), shape = 'bar', config = cfg)
x$AP %>% rAmCharts.bar(y = 'EMPL_FULL_M', x = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND'), config = cfg)
x$AP %>% dimple.combo(y = 'EMPL_FULL_M', x = list('Left Overs' = 'LFTVRS', 'New Tasks Assigned' ='ASSGND'), shape = 'bar', config = cfg)


### global.R ------------------
library(RODBC)
library(dplyr)
library(reshape2)
library(MASS)
library(nloptr)
library(lpSolve)
library(magrittr)
library(highcharter)
library(shiny)
library(shinydashboard)
library(bubbles)
library(plotly)
library(d3plus)
library(highcharter)
library(morrisjs)
library(coffeewheel)
library(rCharts)
library(DT)
library(D3TableFilter)


# gener:
source('C:/Nicolas/RCode/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/linalg.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/io.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/optim.R')

# time series
source('C:/Nicolas/RCode/projects/libraries/developing_packages/time.series.R')

# prom
source('C:/Nicolas/RCode/projects/libraries/developing_packages/wfo.tools.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/wfo.R')

# viser:
source('C:/Nicolas/RCode/projects/libraries/developing_packages/visgen.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/jscripts.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/rscripts.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/dashboard.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/bubbles.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/d3plus.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/morrisjs.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/highcharter.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/plotly.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/dimple.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/DT.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/D3TableFilter.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/coffeewheel.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/nibeTree.R')

# from project
source('C:/Nicolas/RCode/projects/abc/abc.nxtgn.wfo (Developing) - Paradox/script/wfo.abc.tools.R')
source('C:/Nicolas/RCode/projects/abc/abc.nxtgn.wfo (Developing) - Paradox/script/tavis.R')






x = readRDS('data/wfo.rds')

# v = genAgentUtilTimeSeries(x)

# Generate Plots:

x %<>% tableAgents
x %>% bubbleAgents(config = list(labelThreshold = 0.01))



x %<>% tableSkills
x$SP %>% bubbles.bubble(size = 'Backlog', color = 'SKILL_TYPE', tooltip = 'SKILL_M', label = 'SKILL_M', config = list(labelThreshold = 0.01))




### testDash.R --------------------------
---
  title: "BI&A Workforce Optimization Toolbox"
author: "NIBESOFT"
date: "14 March 2017"
output: 
  flexdashboard::flex_dashboard:
  orientation: rows
social: menu
runtime: shiny
---
  
  ```{r setup, include=T}
knitr::opts_chunk$set(echo = F)

library(flexdashboard)
library(timeDate)
library(dygraphs)
library(plotly)
library(googleVis)
library(RODBC)
library(dplyr)
library(reshape2)
library(MASS)
library(nloptr)
library(lpSolve)
library(magrittr)

# prepare objects:

```
Dashboard
=======================================================================
  
  Inputs {.sidebar}
-------------------------------------
  
  ```{r}
# shiny inputs defined here
```

Metrics
-----------------------------------------------------------------------
  
  ### Entry Rate {.value-box}
  
  ```{r}
# Shows the average (per day) number of cases entered in this status or inter-arrival time
renderValueBox({
  valueBox(input$bub1_click, icon = "fa-download")
})
```

### Exit Rate {.value-box}

```{r}
# Shows the average daily exit rate (number of cases emitted from the status per day)  
renderValueBox({
  valueBox(123, icon = "fa-download")
})
```

### Average Service Time {.value-box}

```{r}
# Shows the average amount of time (per case) spent in this status
renderValueBox({
  rate <- formatC(5.2656565, digits = 1, format = "f")
  valueBox(
    value = rate,
    icon = "fa-area-chart",
    color = if (rate >= 5) "warning" else "primary"
  )
})
```

### Distribution to next destination {.value-box}
```{r}
# Shows distribution to next statuses by a pie chart 
# Emit the user count
renderValueBox({
  valueBox(value = 2.396, icon = "fa-users")
})
```

Bubbles
-----------------------------------------------------------------------
  
  ### Task Types {data-width=3}
  ```{r}
#renderBubbles({bub1})
```

### Agents  {data-width=3}
```{r}
# renderBubbles({b})
```

Info {.tabset .tabset-fade data-height=350}
-----------------------------------------------------------------------
  ### Volume Time Series  {data-width=6} 
  
  ```{r}
#renderDygraph({v$plot.history(period = 1:v$N.int, figures = x$agents[1:5])})
```{r}
fillRow(
  fillCol(height = 600, flex = c(NA, 1), 
          inputPanel(
            selectInput("region", "Region:", choices = c('one','two','three'))
          ),
          plotOutput("phonePlot", height = "100%")
  ),
  bubblesOutput('bub1'),
  bubblesOutput('bub2')
)

output$phonePlot <- renderPlot({
  barplot(exp(0.01*(1:100)), 
          ylab = "Number of Telephones", xlab = "Year")
})

output$bub1 <- renderBubbles({bub1})
output$bub2 <- renderBubbles({bub2})

```

### Volume Time Series  {data-width=6} 

```{r}
#renderPlotly({v$plot.history(period = 1:v$N.int, figures = x$agents[1:5], package = 'plotly')})
```

### testDash2.Rmd --------------------------
---
  title: "BI&A Workforce Optimization Toolbox"
author: "NIBESOFT"
date: "14 March 2017"
output: 
  flexdashboard::flex_dashboard:
  orientation: rows
social: menu
runtime: shiny
---
  
  ```{r setup, include=T}
knitr::opts_chunk$set(echo = F)

library(flexdashboard)
library(timeDate)
library(dygraphs)
library(plotly)
library(googleVis)
library(RODBC)
library(dplyr)
library(reshape2)
library(MASS)
library(nloptr)
library(lpSolve)
library(magrittr)

# prepare objects:

```
Dashboard
=======================================================================
  
  Inputs {.sidebar}
-------------------------------------
  
  ```{r}
# shiny inputs defined here
```

Metrics
-----------------------------------------------------------------------
  
  ### Entry Rate {.value-box}
  
  ```{r}
# Shows the average (per day) number of cases entered in this status or inter-arrival time
renderValueBox({
  valueBox(input$bub1_click, icon = "fa-download")
})
```

### Exit Rate {.value-box}

```{r}
# Shows the average daily exit rate (number of cases emitted from the status per day)  
renderValueBox({
  valueBox(123, icon = "fa-download")
})
```

### Average Service Time {.value-box}

```{r}
# Shows the average amount of time (per case) spent in this status
renderValueBox({
  rate <- formatC(5.2656565, digits = 1, format = "f")
  valueBox(
    value = rate,
    icon = "fa-area-chart",
    color = if (rate >= 5) "warning" else "primary"
  )
})
```

### Distribution to next destination {.value-box}
```{r}
# Shows distribution to next statuses by a pie chart 
# Emit the user count
renderValueBox({
  valueBox(value = 2.396, icon = "fa-users")
})
```

Bubbles
-----------------------------------------------------------------------
  
  ### Task Types {data-width=3}
  ```{r}
#renderBubbles({bub1})
```

### Agents  {data-width=3}
```{r}
# renderBubbles({b})
```

Info {.tabset .tabset-fade data-height=350}
-----------------------------------------------------------------------
  ### Volume Time Series  {data-width=6} 
  
  ```{r}
#renderDygraph({v$plot.history(period = 1:v$N.int, figures = x$agents[1:5])})
```{r}
fillRow(
  fillCol(height = 600, flex = c(NA, 1), 
          inputPanel(
            selectInput("region", "Region:", choices = c('one','two','three'))
          ),
          plotOutput("phonePlot", height = "100%")
  ),
  bubblesOutput('bub1'),
  bubblesOutput('bub2')
)

output$phonePlot <- renderPlot({
  barplot(exp(0.01*(1:100)), 
          ylab = "Number of Telephones", xlab = "Year")
})

output$bub1 <- renderBubbles({bub1})
output$bub2 <- renderBubbles({bub2})

```

### Volume Time Series  {data-width=6} 

```{r}
#renderPlotly({v$plot.history(period = 1:v$N.int, figures = x$agents[1:5], package = 'plotly')})
```

### wfo.abc.tools.R --------------------------
# Header
# Filename:      wfo.abc.tools.R
# Description:   This module provides functions for extractiion and modfication of data
#                from GDW, datamart or any other source of data in abc required for nxtgn Work-force optimization project.
# Author:        Nicolas Berta 
# Email :        nicolas.berta@abc.com
# Start Date:    25 January 2017
# Last Revision: 01 February 2017
# Version:       1.0.1

# Version   Date               Action
# -----------------------------------
# 1.0.0     25 January 2017    Initial issue
# 1.0.1     01 February 2017   Function to be written 

# Required tables:
# agentSkill, backlog, agentRoster

source('C:/Nicolas/RCode/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/RCode/projects/libraries/developing_packages/io.R')
library(dplyr)
library(RODBC)

# D = readODBC(tableName = 'BMO_HL_WIMS', fields = c('WIM_ACTV_TYPE_C', 'WIM_START_DT', 'WIM_COMT_DT', 'WIM_STUS_REAS_TYPE_C', 'PACT_EMPL_M'),
#                 filter = list(WIM_COMT_DT = list(min = '2017-01-01', max = '2017-01-02', na.rm = T, type = 'time'),
#                               PACT_EMPL_M = list(na.rm = T),
#                               WIM_STUS_REAS_TYPE_C = list(domain = 'COMT')))
# 
# D$WIM_STUS_REAS_TYPE_C = as.integer(1)
# 
# A = aggregate(STUS_REAS_TYPE_C ~ EVNT_ACTV_TYPE_C + EMPL_M, data = D, sum)
# 
# 


# need to write a function that returns history counts of various tasks done by various agents in a given time duration
readAgentHistCount = function(start = Sys.Date() - 1, end = Sys.Date(), tableName = 'BMO_HL_WIMS', activityCol = 'WIM_ACTV_TYPE_C', startTimeCol = 'WIM_START_DT', endTimeCol = 'WIM_COMT_DT', agentCol = 'PACT_EMPL_M', transResultCol = 'WIM_STUS_REAS_TYPE_C'){
  fltr = list()
  fltr[[endTimeCol]]       = list(min = start, max = end, na.rm = T, type = 'time')
  fltr[[agentCol]]         = list(na.rm = T)
  fltr[[transResultCol]]   = list(domain = 'COMT')
  
  D = readODBC(tableName = tableName, fields = c(activityCol, startTimeCol, endTimeCol, agentCol), filter = fltr)
  
  D$Count = as.integer(1)
  
  A = aggregate(Count ~ WIM_ACTV_TYPE_C + PACT_EMPL_M, data = D, sum)
  
  return(A)
}


readAgentHistCount.discharges = function(start = Sys.Date() - 100, end = Sys.Date(), dsn = 'Teradata_Prod'){
  start = as.character(as.Date(start))
  end   = as.character(as.Date(end))
  
  query = paste(
    "SELECT CAST(hm.wim_comt_dt AS DATE) AS \"Date\", --Processed date",
    "COALESCE(hm.pact_empl_i, hm.owng_empl_i) AS agentID,",
    "hm.wim_actv_type_c AS taskType,",
    "COUNT(*) AS \"Count\"  FROM udrbscms.bmo_hm_wims AS hm",
    "INNER JOIN (
    SELECT A.EMPL_IDNN_BK AS EMPL_I, A.EMPL_FULL_M, VC.ORGANIZATION_NAME,  A.EMPL_STUS_M,
    A.EMPL_POSN_X, A.WORK_L1_X, A.STAT_C, A.EMPL_TERM_VALU_C, A.EMPL_TERM_VALU_N,
    A.BUSN_STRT_D, A.BUSN_END_D
    
    FROM p_v_usr_std_0.dimn_empl AS a
    INNER JOIN (
    SELECT empl_i, Organization_Name 
    FROM  udrbscms.VCC_PRODUCTIVITY 
    WHERE (Organization_Name LIKE '|GLS-_-DIS| HL Dis%' OR Organization_Name LIKE '|GLS-S-ANC| HL Discharge Aftercare%')
    AND kpi_name = '..03. Observed - FTE (d) v 2.0' 
    AND empl_i is not null 
    AND empl_i <> 'NULL'
    QUALIFY    ROW_NUMBER() OVER (PARTITION BY empl_i ORDER  BY 
    TO_DATE(SUBSTR(SCORECARD_DATE,0,5) ||'-'|| SUBSTR(SCORECARD_DATE,6,2) ||'-'|| SUBSTR(SCORECARD_DATE,9,2)) desc) =1
    ) AS vc
    ON   a.empl_idnn_bk = vc.empl_i AND a.busn_end_d = '9999-12-31' AND a.empl_stus_m = 'Active'
  ) AS emp
    ON agentID = emp.empl_i
    
    WHERE appt_c in ('PADC', 'FLDC') 
    AND hm.wim_actv_type_c IS NOT NULL 
    AND COALESCE(hm.pact_empl_i, hm.owng_empl_i) IS NOT NULL 
    AND hm.wim_stus_reas_type_c IN ('COMT'/*, 'RESG', 'RSHD'*/)",
    paste0("AND CAST(hm.wim_comt_dt AS DATE) >= '", start, "'"),
    paste0("AND CAST(hm.wim_comt_dt AS DATE) <= '", end, "'"),  
    "GROUP BY 1,2,3", sep = "\n"
    )
  
  channel  = odbcConnect(dsn = dsn)
  AHC      = sqlQuery(channel = channel, query = query)
  close(channel)
  return(AHC)
}


readAgentRoster.discharges = function(start = Sys.Date() - 100, end = Sys.Date(), dsn = 'Teradata_Prod'){
  start = as.character(as.Date(start))
  end   = as.character(as.Date(end))
  
  query = paste(
    query = "
    SELECT             
    TO_DATE(SUBSTR(vc.SCORECARD_DATE,0,5) ||'-'|| SUBSTR(vc.SCORECARD_DATE,6,2) ||'-'|| SUBSTR(vc.SCORECARD_DATE,9,2)) AS \"Date\", --Processed date
    vc.empl_i AS agentID,
    CAST(vc.KPI_Actual_Value AS FLOAT) AS prodTime
    FROM udrbscms.vcc_productivity AS vc
    INNER JOIN 
    (
    SELECT A.EMPL_IDNN_BK AS EMPL_I, A.EMPL_FULL_M, VC.ORGANIZATION_NAME,  A.EMPL_STUS_M,
    A.EMPL_POSN_X, A.WORK_L1_X, A.STAT_C, A.EMPL_TERM_VALU_C, A.EMPL_TERM_VALU_N,
    A.BUSN_STRT_D, A.BUSN_END_D
    
    FROM p_v_usr_std_0.dimn_empl AS a
    INNER JOIN 
    (
    SELECT empl_i, Organization_Name 
    FROM  udrbscms.VCC_PRODUCTIVITY 
    WHERE (Organization_Name LIKE '|GLS-_-DIS| HL Dis%' OR Organization_Name LIKE '|GLS-S-ANC| HL Discharge Aftercare%')
    AND kpi_name = '..03. Observed - FTE (d) v 2.0' 
    AND empl_i is not null 
    AND empl_i <> 'NULL'
    QUALIFY    ROW_NUMBER() OVER (PARTITION BY empl_i ORDER  BY 
    TO_DATE(SUBSTR(SCORECARD_DATE,0,5) ||'-'|| SUBSTR(SCORECARD_DATE,6,2) ||'-'|| SUBSTR(SCORECARD_DATE,9,2)) desc) =1
    ) AS vc
    ON   a.empl_idnn_bk = vc.empl_i AND a.busn_end_d = '9999-12-31' AND a.empl_stus_m = 'Active'
    ) AS emp
    ON agentID = emp.empl_i
    WHERE vc.empl_i is not null 
    AND vc.empl_i <> 'NULL'
    AND vc.KPI_Name = '..07. Production Hours - FTE (d)'",
    paste0("AND TO_DATE(SUBSTR(vc.SCORECARD_DATE,0,5) ||'-'|| SUBSTR(vc.SCORECARD_DATE,6,2) ||'-'|| SUBSTR(vc.SCORECARD_DATE,9,2)) >= '", start, "'"),
    paste0("AND TO_DATE(SUBSTR(vc.SCORECARD_DATE,0,5) ||'-'|| SUBSTR(vc.SCORECARD_DATE,6,2) ||'-'|| SUBSTR(vc.SCORECARD_DATE,9,2)) <= '", end  , "'"),
    "ORDER BY agentID;", sep = "\n"
  )
  
  channel  = odbcConnect(dsn = dsn)
  AR       = sqlQuery(channel = channel, query = query)
  assert(inherits(AR, 'data.frame'), "SQL query implimentation failed! \n" %+% query, match.call()[[1]])
  close(channel)
  verify(AR, 'data.frame', names_include = c('Date', 'agentID', 'prodTime'), varname = 'AR')
  AR$prodTime =  AR$prodTime*7.6*3600
  return(AR)
}

readTaskBacklog = function(dsn = 'Teradata_Prod'){
  query = "
  SELECT hm.EVNT_GRUP_I AS caseID
  ,       hm.WIM_EVNT_I AS taskID
  ,       hm.WIM_ACTV_TYPE_C AS taskType
  ,       hm.WIM_START_DT AS startDT
  ,       hm.WIM_DUE_DT AS dueDT
  ,       CAST(DATE AS TIMESTAMP)/*+ INTERVAL '20' HOUR*/ AS currDT
  ,       (CAST((CAST(currDT AS DATE) - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM currDT) * 3600) + (EXTRACT(MINUTE FROM currDT) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM currDT)) 
  -
  CAST((CAST(hm.WIM_START_DT AS DATE) - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM hm.WIM_START_DT) * 3600) + (EXTRACT(MINUTE FROM hm.WIM_START_DT) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM hm.WIM_START_DT)) )/86400
  AS startAge
  
  ,       (CAST((CAST(currDT AS DATE) - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM currDT) * 3600) + (EXTRACT(MINUTE FROM currDT) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM currDT)) 
  -
  CAST((CAST(hm.WIM_DUE_DT AS DATE) - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM hm.WIM_DUE_DT) * 3600) + (EXTRACT(MINUTE FROM hm.WIM_DUE_DT) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM hm.WIM_DUE_DT)) )/86400
  AS dueAge
  --, CASE WHEN wi.digitalflag IS NULL THEN 0 ELSE 1 END AS DIGITAL_FLAG
  
  FROM udrbscms.bmo_hm_wims AS hm
  LEFT JOIN udrbscms.go_wims AS wi ON hm.wim_evnt_i = wi.reld_evnt_i
  WHERE hm.appt_c in ('PADC', 'FLDC') --discharge apps
  AND hm.wim_actv_type_c IN ('3736', '3737', '3755', '3665', '3758', '3674', '3666', '3744', '3749', '3671', '3763', '3756', '3752', '3741', '3745', '3757') --limited to GO WIMs
  AND hm.wim_stus_c = 'ICMP' --open WIMS
  AND hm.WIM_OWNG_DEPT_L5_M = 'Group Lending Services East' --WIMS owned by GLS East only included
  AND wi.digitalflag IS NULL --to remove PEXA apps, logic in GO_WIMS may not be correct, has to be checked;
  "
  channel  = odbcConnect(dsn = dsn)
  TB       = sqlQuery(channel = channel, query = query)
  close(channel)
  
  assert(inherits(TB, 'data.frame'), "SQL query implimentation failed! \n" %+% query, match.call()[[1]])
  verify(TB, 'data.frame', names_include = c('taskID', 'taskType','dueAge'), varname = 'TB')
  return(TB)
}

# Fills the given OptimalTaskAllocator object with the data read from abc terradata 
# and returns the filled object. Currently works for discharges only.
feedabc.OptimalTaskAllocator = function(obj, start = Sys.Date() - 100, end = Sys.Date(), dsn = 'Teradata_Prod'){
  assert(inherits(obj, 'OptimalTaskAllocator'), "Given object is not an instance of class 'OptimalTaskAllocator'!", match.call()[[1]])
  # Read Tables:
  obj$AHC = readAgentHistCount.discharges(start = start, end = end, dsn = dsn)
  obj$AR  = readAgentRoster.discharges(start = start, end = end, dsn = dsn)
  obj$TB  = readTaskBacklog(start = start, end = end, dsn = dsn)
  return(obj)
}

readAgents.Maneli = function(date = NULL, dsn = 'Teradata_Prod'){
  if (is.null(date)){datestr = 'DATE'} else {datestr = date %>% as.Date %>% as.character}
  query = "
  SELECT e.empl_i, e.empl_full_m, e.team_i, t.team_m, date as cal_date, e.efft_d, e.expy_d
  FROM udrbscms.bmo_ng_empl AS e
  LEFT JOIN (SELECT team_i, team_m FROM udrbscms.bmo_ng_team QUALIFY ROW_NUMBER() OVER (PARTITION BY team_i ORDER BY expy_d DESC) = 1)AS t ON e.team_i = t.team_i 
  WHERE e.productive_flag= 1 AND " %+% datestr %+% "+1 BETWEEN e.efft_d and e.expy_d;
  "
  channel  = odbcConnect(dsn = dsn)
  AG       = sqlQuery(channel = channel, query = query)
  close(channel)
  return(AG)
}

readAgentSchedule.Maneli = function(date = Sys.Date(), dsn = 'Teradata_Prod'){
  date %<>% as.Date
  fltr = sqlScript('bmo_ng_empl', filter = list(EFFT_D = list(max = date + 1, type = 'date', equal = T), EXPY_D = list(min = date + 1, type = 'date', equal = T), PRODUCTIVE_FLAG = list(domain = 1, type = 'nominal')))
  query = "
  SELECT sh.empl_i, e1.empl_full_m, sh.cal_date, sh.prod_time_in_minutes * sh.allocation_factor as prod_time_in_minutes
  FROM udrbscms.bmo_ng_empl_schdl AS sh  
  INNER JOIN (" %+% fltr %+% 
    ") AS e1 ON sh.empl_i = e1.empl_i
  WHERE sh.cal_date = '" %+% as.character(date+1) %+% "';
  "
  channel  = odbcConnect(dsn = dsn)
  AS       = sqlQuery(channel = channel, query = query)
  close(channel)
  return(AS)
}


readSkills.Maneli = function(date = Sys.Date(), dsn = 'Teradata_Prod'){
  date %<>% as.Date
  query = "
  SELECT s.skill_id, s.skill_m, s.skill_type, t.team_i, t.team_m, s.efft_d, s.expy_d
  FROM udrbscms.bmo_ng_skill AS s 
  LEFT JOIN (SELECT team_i, team_m FROM udrbscms.bmo_ng_team QUALIFY ROW_NUMBER() OVER (PARTITION BY TEAM_I ORDER BY EXPY_D DESC) = 1)AS t ON s.team_i = t.team_i 
  WHERE '"  %+% as.character(date + 1) %+% "' BETWEEN s.efft_d and s.expy_d;
  "
  channel  = odbcConnect(dsn = dsn)
  AS       = sqlQuery(channel = channel, query = query)
  close(channel)
  return(AS)
}

readAgentTAT.Maneli = function(date = Sys.Date(), dsn = 'Teradata_Prod'){
  date %<>% as.Date
  
  query = "
  SELECT es.empl_i, es.skill_id, es.proficiency_level, aut.aut_in_minutes, es.efft_d, es.expy_d
  FROM udrbscms.bmo_ng_empl_skill AS es 
  LEFT JOIN (SELECT * FROM udrbscms.bmo_ng_skill_aut WHERE '"  %+% as.character(date + 1) %+% "' BETWEEN efft_d AND expy_d) AS aut ON es.skill_id = aut.skill_id and es.proficiency_level = aut.proficiency_level
  WHERE '"  %+% as.character(date + 1) %+% "' BETWEEN es.efft_d and es.expy_d;
  "
  channel  = odbcConnect(dsn = dsn)
  AT       = sqlQuery(channel = channel, query = query)
  close(channel)
  return(AT)
}

readTaskList.Maneli = function(date = Sys.Date(), dsn = 'Teradata_Prod'){
  date %<>% as.Date
  query = "
  SELECT ow.process_id, ow.skill_id, s1.skill_m, ow.start_dt, ow.due_dt,    
  (CAST(( DATE '" %+% as.character(date + 1) %+% "' - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6))) * 3600) + (EXTRACT(MINUTE FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6))) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6)))) 
  -
  CAST((CAST(ow.due_dt AS DATE) - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM cast(ow.due_dt as timestamp(6))) * 3600) + (EXTRACT(MINUTE FROM cast(ow.due_dt as timestamp(6))) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM cast(ow.due_dt as timestamp(6)))) )/86400
  AS AGE_DUE,
  COUNT(*) OVER (PARTITION BY ow.process_id, ow.skill_id) AS WIM_COUNT_IN_PROCESS_ID,
  ow.assigned_to, e1.empl_i, e1.empl_full_m,
  --logic for allocated flag needs to be more robust can fall if queue name does not have the keyword Mortgage services in it, create a table to hold all queue names and refer to it or use the table pvdata.SRCE_SYST_USER_CURR  to map employees
  CASE WHEN POSITION('MORTGAGE SERVICES' IN ow.assigned_to) >0 THEN 0 ELSE 1 END AS ALLOCATED_FLAG,
  CASE WHEN CAST(ow.start_dt AS TIME) = '00:00:00' THEN 1 ELSE 0 END AS RSHD_FLAG,
  CASE WHEN CAST(ow.due_dt AS DATE) <= DATE '" %+% as.character(date + 1) %+% "' THEN 1 ELSE 0 END AS DUE_FLAG,
  CASE 
  WHEN allocated_flag = 0 AND rshd_flag = 0 THEN 'New Work – Unassigned'
  WHEN allocated_flag = 0 AND rshd_flag = 1 AND due_flag = 1 THEN 'Rescheduled- Unassigned and due (Rework)'
  WHEN allocated_flag = 0 AND rshd_flag = 1 AND due_flag = 0 THEN 'Rescheduled- Unassigned and not due (Non-workable)'
  WHEN allocated_flag = 1 AND rshd_flag = 0 THEN 'New Work- Assigned (Left over)'
  WHEN allocated_flag = 1 AND rshd_flag = 1 AND due_flag = 1 THEN 'Rescheduled – Assigned and due (Rework)'
  WHEN allocated_flag = 1 AND rshd_flag = 1 AND due_flag = 0 THEN 'Rescheduled – Assigned and not due (Non-workable)'
  END AS ALLOCATION_DESC,
  ow.load_date as report_d
  
  FROM udrbscms.bmo_ng_open_wims AS ow
  LEFT JOIN udrbscms.bmo_ng_skill AS s1 ON ow.skill_id = s1.skill_id AND DATE BETWEEN s1.efft_d AND s1.expy_d
  LEFT JOIN udrbscms.bmo_ng_empl AS e1 ON ow.assigned_to = e1.empl_full_m AND DATE BETWEEN e1.efft_d AND e1.expy_d
  WHERE ow.load_date = '" %+% as.character(date + 1) %+% "';
  "  
  channel  = odbcConnect(dsn = dsn)
  TL       = sqlQuery(channel = channel, query = query)
  close(channel)
  return(TL)
}

# Manual Task Summary
readManualTaskSummary.Maneli = function(date = Sys.Date(), dsn = 'Teradata_Prod'){
  date %<>% as.Date
  query = "
  SELECT mow.skill_id, s1.skill_m, mow.start_dt, mow.due_dt,    
  (CAST((DATE '" %+% as.character(date + 1) %+% "' - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6))) * 3600) + (EXTRACT(MINUTE FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6))) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6)))) 
  -
  CAST((CAST(mow.due_dt AS DATE) - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM cast(mow.due_dt as timestamp(6))) * 3600) + (EXTRACT(MINUTE FROM cast(mow.due_dt as timestamp(6))) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM cast(mow.due_dt as timestamp(6)))) )/86400
  AS AGE_DUE,
  mow.work_units,
  t1.team_m AS ASSIGNED_TO,
  CAST(NULL AS VARCHAR(8)) AS EMPL_I,
  CAST(NULL AS VARCHAR(80)) AS EMPL_FULL_M,
  0 AS ALLOCATED_FLAG,
  0 AS RSHD_FLAG,
  CASE WHEN CAST(mow.due_dt AS DATE) <= DATE '" %+% as.character(date + 1) %+% "' THEN 1 ELSE 0 END AS DUE_FLAG,
  CASE 
  WHEN allocated_flag = 0 AND rshd_flag = 0 THEN 'New Work – Unassigned'
  WHEN allocated_flag = 0 AND rshd_flag = 1 AND due_flag = 1 THEN 'Rescheduled- Unassigned and due (Rework)'
  WHEN allocated_flag = 0 AND rshd_flag = 1 AND due_flag = 0 THEN 'Rescheduled- Unassigned and not due (Non-workable)'
  WHEN allocated_flag = 1 AND rshd_flag = 0 THEN 'New Work- Assigned (Left over)'
  WHEN allocated_flag = 1 AND rshd_flag = 1 AND due_flag = 1 THEN 'Rescheduled – Assigned and due (Rework)'
  WHEN allocated_flag = 1 AND rshd_flag = 1 AND due_flag = 0 THEN 'Rescheduled – Assigned and not due (Non-workable)'
  END AS ALLOCATION_DESC,
  mow.report_d
  
  FROM udrbscms.BMO_NG_MANUAL_SKILLS_VOL_IN AS mow
  LEFT JOIN udrbscms.bmo_ng_skill AS s1 ON mow.skill_id = s1.skill_id AND '" %+% as.character(date + 1) %+% "' BETWEEN s1.efft_d AND s1.expy_d
  LEFT JOIN udrbscms.bmo_ng_team AS t1 ON s1.team_i = t1.team_i AND '" %+% as.character(date + 1) %+% "' BETWEEN t1.efft_d AND t1.expy_d
  --LEFT JOIN udrbscms.bmo_ng_empl AS e1 ON mow.assigned_to = e1.empl_full_m AND '" %+% as.character(date + 1) %+% "' BETWEEN e1.efft_d AND e1.expy_d
  WHERE mow.report_d = '" %+% as.character(date + 1) %+% "'
  "
  channel  = odbcConnect(dsn = dsn)
  MTS      = sqlQuery(channel = channel, query = query)
  close(channel)
  return(MTS)
}

readManualTaskSummary.leftover.Maneli = function(date = Sys.Date(), dsn = 'Teradata_Prod'){
  date %<>% as.Date
  query = "
  SELECT mow.skill_id, s1.skill_m, mow.start_dt, mow.due_dt,    
  (CAST((DATE '" %+% as.character(date + 1) %+% "' - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6))) * 3600) + (EXTRACT(MINUTE FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6))) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM CAST(DATE '" %+% as.character(date + 1) %+% "' AS TIMESTAMP(6)))) 
  -
  CAST((CAST(mow.due_dt AS DATE) - DATE '1970-01-01') * 86400+ (EXTRACT(HOUR FROM cast(mow.due_dt as timestamp(6))) * 3600) + (EXTRACT(MINUTE FROM cast(mow.due_dt as timestamp(6))) * 60) AS DECIMAL(18))
  + (EXTRACT(SECOND FROM cast(mow.due_dt as timestamp(6)))) )/86400
  AS AGE_DUE,
  mow.work_units,
  e1.EMPL_FULL_M AS ASSIGNED_TO,
  mow.empl_i AS EMPL_I,
  e1. EMPL_FULL_M,
  1 AS ALLOCATED_FLAG,
  0 AS RSHD_FLAG,
  CASE WHEN CAST(mow.due_dt AS DATE) <= DATE '" %+% as.character(date + 1) %+% "' THEN 1 ELSE 0 END AS DUE_FLAG,
  CASE 
  WHEN allocated_flag = 0 AND rshd_flag = 0 THEN 'New Work – Unassigned'
  WHEN allocated_flag = 0 AND rshd_flag = 1 AND due_flag = 1 THEN 'Rescheduled- Unassigned and due (Rework)'
  WHEN allocated_flag = 0 AND rshd_flag = 1 AND due_flag = 0 THEN 'Rescheduled- Unassigned and not due (Non-workable)'
  WHEN allocated_flag = 1 AND rshd_flag = 0 THEN 'New Work- Assigned (Left over)'
  WHEN allocated_flag = 1 AND rshd_flag = 1 AND due_flag = 1 THEN 'Rescheduled – Assigned and due (Rework)'
  WHEN allocated_flag = 1 AND rshd_flag = 1 AND due_flag = 0 THEN 'Rescheduled – Assigned and not due (Non-workable)'
  END AS ALLOCATION_DESC,
  mow.report_d
  
  FROM udrbscms.BMO_NG_MANUAL_SKILLS_LEFT_OVER_VOL AS mow
  LEFT JOIN udrbscms.bmo_ng_skill AS s1 ON mow.skill_id = s1.skill_id AND '" %+% as.character(date + 1) %+% "' BETWEEN s1.efft_d AND s1.expy_d
  --LEFT JOIN udrbscms.bmo_ng_team AS t1 ON s1.team_i = t1.team_i AND '" %+% as.character(date + 1) %+% "' BETWEEN t1.efft_d AND t1.expy_d
  LEFT JOIN udrbscms.bmo_ng_empl AS e1 ON mow.empl_i = e1.empl_i AND '" %+% as.character(date + 1) %+% "' BETWEEN e1.efft_d AND e1.expy_d
  WHERE mow.report_d = '" %+% as.character(date + 1) %+% "' AND mow.work_units >0;
  "
  channel  = odbcConnect(dsn = dsn)
  MTS      = sqlQuery(channel = channel, query = query)
  close(channel)
  return(MTS)
}

# Test Writing
# q = paste("update udrbscms.bmo_sankey_m", "set \"way of the walk\"='MAX' where \"way of the walk\"='Max'", sep = '\n') 
# channel  = odbcConnect(dsn = 'Teradata_Prod')
# a      = sqlQuery(channel = channel, query = q)
# close(channel)


### wfo.R --------------------------
# Header
# Filename:      wfo.R
# Description:   This module provides functions for the work-force optimization engine within the process manager.
#                There are functions for local optimal distribution of tasks(activities) among the resources.
# Author:        Nicolas Berta 
# Email :        nicolas.berta@abc.com
# Start Date:    25 January 2017
# Last Revision: 25 January 2017
# Version:       1.0.0

# Version   Date               Action
# -----------------------------------
# 1.0.0     25 January 2017    Initial issue

# Required tables:
# agentSkill, backlog, agentRoster

library(RODBC)
library(dplyr)
library(reshape2)
library(MASS)
library(nloptr)

source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
source('C:/Nicolas/R/projects/libraries/developing_packages/io.R')

# D = readODBC(tableName = 'BMO_HL_WIMS', fields = c('WIM_ACTV_TYPE_C', 'WIM_START_DT', 'WIM_COMT_DT', 'WIM_STUS_REAS_TYPE_C', 'PACT_EMPL_M'),
#                 filter = list(WIM_COMT_DT = list(min = '2017-01-01', max = '2017-01-02', na.rm = T, type = 'time'),
#                               PACT_EMPL_M = list(na.rm = T),
#                               WIM_STUS_REAS_TYPE_C = list(domain = 'COMT')))
# 
# D$WIM_STUS_REAS_TYPE_C = as.integer(1)
# 
# A = aggregate(STUS_REAS_TYPE_C ~ EVNT_ACTV_TYPE_C + EMPL_M, data = D, sum)
# 
# 
# genAgentSkillTable = function(agentHistCount, agentRoster) -->

# Reference Names:

#  Table: 'agentHistCount'
#  Column Names:  'date', 'agentID', 'taskType', 'count'
#  (The combination of 'date', 'agentID', 'taskType' must be unique)

# Table: 'agentRoster'
# Column Names: 'date', 'agentID', 'prodHours'
# (The combination of 'date' and 'agentID' must be unique)

# Table: 'agentSkill'
# Column Names: 'agentID', all task types ...
# ('agentID' must be unique)

# Table: 'backlog'
# Column Names: 'date', 'taskID', 'taskType', 'taskAge', 'caseID', 'maxAge'
# (The combination of 'date' and 'taskID' must be unique)

# Function: 'genAgentSkillTable'
# Input 1:  agentHistCount: data.frame
# Input 2:  agentRoster: data.frame
# Output:   agentSkill: data.frame

# Function: 'distributeTasks'
# Input 1:  agentSkillTable: data.frame
# Input 2:  backlogTable: data.frame
# Output 1:   distributedTaskTable: data.frame
# Output 2:   unAllocatedTasks : list

query.agentHistCount = "
SELECT             
CAST(hm.wim_comt_dt AS DATE) AS \"Date\", --Processed date
COALESCE(hm.pact_empl_i, hm.owng_empl_i) AS agentID,
hm.wim_actv_type_c AS taskType,
COUNT(*) AS \"count\"
FROM udrbscms.bmo_hm_wims AS hm
INNER JOIN 
(
  SELECT A.EMPL_IDNN_BK AS EMPL_I, A.EMPL_FULL_M, VC.ORGANIZATION_NAME,  A.EMPL_STUS_M,
  A.EMPL_POSN_X, A.WORK_L1_X, A.STAT_C, A.EMPL_TERM_VALU_C, A.EMPL_TERM_VALU_N,
  A.BUSN_STRT_D, A.BUSN_END_D
  
  FROM p_v_usr_std_0.dimn_empl AS a
  INNER JOIN 
  (
  SELECT empl_i, Organization_Name 
  FROM  udrbscms.VCC_PRODUCTIVITY 
  WHERE (Organization_Name LIKE '|GLS-_-DIS| HL Dis%' OR Organization_Name LIKE '|GLS-S-ANC| HL Discharge Aftercare%')
  AND kpi_name = '..03. Observed - FTE (d) v 2.0' 
  AND empl_i is not null 
  AND empl_i <> 'NULL'
  QUALIFY    ROW_NUMBER() OVER (PARTITION BY empl_i ORDER  BY 
  TO_DATE(SUBSTR(SCORECARD_DATE,0,5) ||'-'|| SUBSTR(SCORECARD_DATE,6,2) ||'-'|| SUBSTR(SCORECARD_DATE,9,2)) desc) =1
  ) AS vc
  ON   a.empl_idnn_bk = vc.empl_i AND a.busn_end_d = '9999-12-31' AND a.empl_stus_m = 'Active'
) AS emp
  ON agentID = emp.empl_i
  
  WHERE appt_c in ('PADC', 'FLDC') 
  AND hm.wim_actv_type_c IS NOT NULL 
  AND COALESCE(hm.pact_empl_i, hm.owng_empl_i) IS NOT NULL 
  AND hm.wim_stus_reas_type_c IN ('COMT'/*, 'RESG', 'RSHD'*/)
  AND CAST(hm.wim_comt_dt AS DATE) >= '2016-10-10'
  GROUP BY 1,2,3"
  
  channel     = odbcConnect(dsn = 'Teradata_Prod')
  AHC         = sqlQuery(channel = channel, query = query.agentHistCount)
  
  AHC$agentID = as.character(AHC$agentID)
  agents      = unique(AHC$agentID)
  
  #Pick the first agent:
  k    = agents[2]
  
  AHCk = AHC[AHC$agent == k,]
  A    = dcast(AHCk, Date ~ taskType, mean, value.var = 'count')
  A[is.na(A)] <- 0
  
  rownames(A) <- as.character(A$Date)
  A = A[, -1]  # This is HistCount matrix for agent k(casted matrix)
  
  # Preparing the number of hours worked by each agent per day (agentRoster)
  
  query.agentRoster = "
  SELECT             
  TO_DATE(SUBSTR(vc.SCORECARD_DATE,0,5) ||'-'|| SUBSTR(vc.SCORECARD_DATE,6,2) ||'-'|| SUBSTR(vc.SCORECARD_DATE,9,2)) AS \"Date\", --Processed date
  vc.empl_i AS agentID,
  CAST(vc.KPI_Actual_Value AS FLOAT) AS prodHours
  FROM udrbscms.vcc_productivity AS vc
  INNER JOIN 
  (
  SELECT A.EMPL_IDNN_BK AS EMPL_I, A.EMPL_FULL_M, VC.ORGANIZATION_NAME,  A.EMPL_STUS_M,
  A.EMPL_POSN_X, A.WORK_L1_X, A.STAT_C, A.EMPL_TERM_VALU_C, A.EMPL_TERM_VALU_N,
  A.BUSN_STRT_D, A.BUSN_END_D
  
  FROM p_v_usr_std_0.dimn_empl AS a
  INNER JOIN 
  (
  SELECT empl_i, Organization_Name 
  FROM  udrbscms.VCC_PRODUCTIVITY 
  WHERE (Organization_Name LIKE '|GLS-_-DIS| HL Dis%' OR Organization_Name LIKE '|GLS-S-ANC| HL Discharge Aftercare%')
  AND kpi_name = '..03. Observed - FTE (d) v 2.0' 
  AND empl_i is not null 
  AND empl_i <> 'NULL'
  QUALIFY    ROW_NUMBER() OVER (PARTITION BY empl_i ORDER  BY 
  TO_DATE(SUBSTR(SCORECARD_DATE,0,5) ||'-'|| SUBSTR(SCORECARD_DATE,6,2) ||'-'|| SUBSTR(SCORECARD_DATE,9,2)) desc) =1
  ) AS vc
  ON   a.empl_idnn_bk = vc.empl_i AND a.busn_end_d = '9999-12-31' AND a.empl_stus_m = 'Active'
  ) AS emp
  ON agentID = emp.empl_i
  WHERE vc.empl_i is not null 
  AND vc.empl_i <> 'NULL'
  AND vc.KPI_Name = '..07. Production Hours - FTE (d)'
  AND TO_DATE(SUBSTR(vc.SCORECARD_DATE,0,5) ||'-'|| SUBSTR(vc.SCORECARD_DATE,6,2) ||'-'|| SUBSTR(vc.SCORECARD_DATE,9,2)) >= '2016-10-10'
  
  ORDER BY agentID;
  "
  AR        = sqlQuery(channel = channel, query = query.agentRoster)
  
  
  B = AR[AR$agent == k,]
  B$prodHours =  B$prodHours*7.6*3600
  rownames(B) <- as.character(B$Date)
  
  dates        = rownames(B) %^% rownames(A)
  
  b = B[dates, 'prodHours']
  A = as.matrix(A[dates, ])
  
  A.inv = ginv(A)
  
  x = A.inv %*% b
  
  eval_f <- function( x ) {
    f = A %*% x - b
    return( list( "objective" = sum(f^2),
                  "gradient"  = 2*(t(A) %*% f)))
  }
  
  # eval_f <- function( x ) {
  #   return(A %*% x - b) 
  # }
  # 
  # eval_grad_f = function(x){
  #   f = A %*% x - b
  #   return( 2*(t(A) %*% f))
  # }
  # 
  
  local_opts <- list( "algorithm" = "NLOPT_LD_MMA",
                      "xtol_rel" = 1.0e-7 )
  opts <- list( "algorithm" = "NLOPT_LD_AUGLAG",
                "xtol_rel" = 1.0e-7,
                "maxeval" = 1000,
                "print_level" = 1,
                "local_opts" = local_opts )
  
  
  y = x
  y[y < 100]=100
  
  n = dim(A)[1]
  m = dim(A)[2]
  
  rep(sum(b)/sum(A), m)
  res = nloptr( x0 = y, eval_f = eval_f, eval_grad_f = eval_grad_f, lb = rep(100,m), opts = opts)  
  
  sum((A %*% res$solution - b)^2)
  
  sum((A %*% x - b)^2)
  
  
  
### wfo_test.R --------------------------
  
  # Required tables:
  # agentSkill, backlog, agentRoster
  
  library(RODBC)
  library(dplyr)
  library(reshape2)
  library(MASS)
  library(nloptr)
  library(lpSolve)
  library(magrittr)
  
  source('C:/Nicolas/R/projects/libraries/developing_packages/gener.R')
  source('C:/Nicolas/R/projects/libraries/developing_packages/io.R')
  source('C:/Nicolas/R/projects/libraries/developing_packages/optim.R')
  
  source('C:/Nicolas/R/projects/abc/abc.nxtgn.wfo/script/wfo.abc.tools.R')
  source('C:/Nicolas/R/projects/libraries/developing_packages/wfo.tools.R')
  source('C:/Nicolas/R/projects/libraries/developing_packages/wfo.R')
  
  # viser:
  source('C:/Nicolas/R/projects/libraries/developing_packages/bubbles.R')
  source('C:/Nicolas/R/projects/libraries/developing_packages/visgen.R')
  
  # Example:
  # Frequencies
  FF = matrix(nrow = 4, ncol = 7, dimnames = list(c('x','y','z','t'), c('a','b','c','d','e','f','g')))
  FF['x', 'a'] = 10
  FF['x', 'b'] = 50
  FF['x', 'c'] = 12
  FF['x', 'g'] = 6
  
  FF['y', 'b'] = 1
  FF['y', 'c'] = 20
  FF['y', 'd'] = 11
  FF['y', 'f'] = 23
  
  FF['z', 'a'] = 2
  FF['z', 'd'] = 16
  FF['z', 'e'] = 43
  FF['z', 'f'] = 35
  
  FF['t', 'g'] = 60
  
  # Agent Task Timing
  TT = matrix(nrow = 4, ncol = 7, dimnames = list(c('x','y','z','t'), c('a','b','c','d','e','f','g')))
  TT['x', 'a'] = 2
  TT['x', 'b'] = 5
  TT['x', 'c'] = 3
  TT['x', 'g'] = 1
  
  TT['y', 'b'] = 3
  TT['y', 'c'] = 1
  TT['y', 'd'] = 2
  TT['y', 'f'] = 7
  
  TT['z', 'a'] = 5
  TT['z', 'd'] = 6
  TT['z', 'e'] = 2
  TT['z', 'f'] = 3
  
  TT['t', 'g'] = 2
  
  SS = 1.0/TT
  
  skills = colnames(TT)
  tt = skills[sample(length(skills), 100, replace = T)]
  
  uu = c(x = 60, y = 65, z = 58, t = 45)
  ww = runif(100)
  
  tasks  = data.frame(id = seq(tt), type = tt, priority = ww)
  
  ##########################################
  
  
  # plotAgentSkill(x, rownames(x$agntPr)[1])
  # 
  # bubbleBacklog(x, agentID =  x$agents[42], baseColor = 'blue')
  # 
  # plotAgentSkill(x, taskType = '3763')
  # 
  # v$goto(v$N.int)
  # 
  # cal = v$plot.calendar(figure = '112608')
  # dyg = v$plot.history(figures = '112608')
  # 
  # colNamePrefix = 'AGNT'
  # atl = v$plot.history(period = (v$ctn - 7):v$ctn, figures = c('112608', '261662', '171873'), package = 'dygraphs', config = list(title = "WIP Volume", xLabel = "Date", yLabel = "Volume"))
  # 
  # ses = v$plot.seasonality(figures = 'AG112608', package = 'plotly')
  # tby = v$plot.timeBreak.yoy(figure = '112608', x.axis = 'doy', years = '2017')
  # 
  # write.csv(X, file = as.character(tdy) %+% '.csv', row.names = F)
  # 
  # # Test utilization for one agent:
  # myAgent = '210183'
  # typs = as.character(x$tsks$taskType[which(x$tsks$allocatedAgent == myAgent)])
  # sum(x$skls[myAgent, typs]) # Required time
  # x$agntPr[myAgent,'prodTime'] # Productive time
  
  
  ---
title: 'SO: An introduction to the optimal task allocatoe engine'
author: "Nicolas Berta "
date: "2 October 2018"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Introduction

<!-- Explain why this is required/ Current status in most businesses  -->

**SO** is a workforce optimisation system aiming to improve productivity and performance quality of business processes by optimal resource allocation.

Optimal Task Allocator (OTA) is currently, the main component of SO which allocates work items (tasks) to employees optimally based on the observed history of their performance on various task types. This product is provided as a R package (named **otar**) with a set of API functions which R developers can use to run task allocation for their data and requirements.
In this article, we will explain the methodology used in the provided optimal task allocator engine and show how package API functions can be used to run an appropriate task allocation. 

<!-- / background/ benefits -->


## Methodology

Skill level of an employee on a particular work type, can be represented by various measures like processing time, count of completed and incompleted tasks and ratio of them, frequency of repeated tasks, cost and/or a measure of positive or negative customer outcomes, ... 
However, in the methodology used in **otar**, employee skill is mainly measured by average processing time which means time elapsed from start of a task until completion.
Although, this measure alone cannot represent all aspects of skill, it can be the main and best measure if skill needs to be quantified by one scalar value.
Other measures can contribute to the decision on weather or not an employee is skilled in a type of work. For example, we can set a threshold for the proportion of tasks completed in the first touch over total tasks given where any ratios lower than the specified threshold can be considered as **Not Skilled**. Such metrics and thresholds depend on the nature of work items and business expectations of their employees.

### Inputs to the model
The purpose of this model is to allocated an existing backlog of tasks to a number of available resources. So it is assumed that a list of tasks (work items) and resources are available. This model works in a push workflow system where tasks are pre-allocated to individuals and employees have their own queue. This is different to **pull** system where work items are pulled by employees from a single queue when they are free to do a task. This system can be extended by considering multiple resources with similar skill levels into one group with which a queue is associated.   

#### Task Priority
Tasks have various priorities. Priority is a single numeric value by which urgency of tasks can be compared. In FIFO (First in first out) priority logic, __priority__ can be represented by task **age** which is the time elapsed from task arrival at the time of allocation. Priority can also be set to **due age** or **overdue age** which is the amount of time elapsed from the due time of a task. In this case, when a task is due in the future, its due age is negative and if a task is overdue, it has a positive due age. 

#### Task Type

Grouping tasks can be sone based on various features. 
For the purpose of task allocation, tasks should be grouped into categories based on employees' skills required to do the tasks. It is expected that one individual employee is using   
Therefore, we also refer to the task types as **skills** because it is supposed that all tasks of the same type should 


### Problem definition
The problem we are dealing with has a discrete nature. In simple words, we need an algorithm/solution to allocate each work item to an employee given the following input data:

* Set of tasks/work items with associated priority levels and skills required, 
* Set of resources or employees with known skill level in various types of work items 
* A look-up table containing which resources are skilled in which task types and if they are skilled, the average per-day frequency and average amount of time spent on those activities in the past.

The mathematical formulation of this problem can be denoted as:
Given:

$T = \{(t_i, p_i, s_i)\}$: Set of $n$𝑛 tasks with various priorities and skills required

$A = \{a_j\}$: Set of $m$ agents (Resources)

$S = \{s_k \}$: Set of $l$ skills (Task Types)

$\mathbf R_{m \times k} = [r_{ij}]$: Matrix of average processing times for agent $i$ in skill $j$ 

$\mathbf u_{m \times 1} = [u_j]$: Agent/Resource available utilisation time

Find $\mathbf X_{n \times m} =[ x_{ij} \in \{1, 0\}]$ 

to maximize the **priority−weighted task coverage** (sum of priorities of allocated tasks):

$\Sigma_{i = 1}^n p_i \cdot \left( \Sigma_{j = 1}^m x_{ij} \right)$

Subject to (constraints):

$\Sigma_{i = 1}^n y_{ij} \leq u_j$

and

$\Sigma_{j = 1}^m x_{ij} \leq 1$

Where:

$Y_{n \times n} = [y_{ij} = x_{ij} \cdot r_{j,s_i}]$


In this very simple example you can see parameters defined:
Consider 7 tasks of four types A,B,C and D and their associated priorities:

Task ID | Type   | Priority | 
------- | -----  | -------- | 
Task 1  | Type A | 2        | 
Task 2  | Type B | 7        | 
Task 3  | Type D | 4        | 
Task 4  | Type C | 6        | 
Task 5  | Type B | 1        | 
Task 6  | Type A | 5        | 
Task 7  | Type D | 3        | 

and three agents X, Y, Z.
The agent-skill AUT matrix is given as:

$R = \left( \begin{array}{cccc} 2 & 7 & 6 & \infty \\ \infty & 1 & 3 & 2 \\ 1 & 1& \infty & 3  \end{array} \right)$

Each column of this matrix corresponds to a task type (skill) and each row represents an agent. For example $r_{13} = 6$ says resource 1 (agent X) requires in average 6 time units (minutes,hours,seconds, ...) to perform a task of the third type (type C) and
$r_{33} = \infty$ means agent 3 (Z) is not skilled in task Type C. 
$\infty$ or missing value acts as a constraint and model will not allocate any task of a type to an agent for which the corresponding cell is marked as $\infty$ or missing.

The solution variable is matrix $X_{n \times m}$ with binary values where $x_{ij} = 1$ means task $i$ is allocated to agent {j} and $0$ otherwise. An example of a feasible solution is like:
$X = \left( \begin{array}{ccc} 1 & 0 & 0 \\ 0 & 0 & 1 \\ 0 & 1 & 0 \\  0 & 1 & 0 \\  1 & 0 & 0 \\  1 & 0 & 0 \\  0 & 0 & 0 \end{array} \right)$
Each column of the solution matrix corresponds to an agent and each row, represent a task. 
For example $x_{42} = 1$ means task 4 is allocated to agent 2. 
Constraint term $\Sigma_{j = 1}^m x_{ij} \leq 1$ indicates each task can only be allocated to one agent.
In the solution matrix shown above, all cells in row 7, are zero which means that task 7 is not allocated to any agent.

#### Why the above problem formulation does not work?

Since the target variables can only take two values of 0 or 1, the solution space is discrete. 
This formulation, defines a discrete optimization problem where the continuous gradients of variables cannot be evaluated.
Therefore, gradient-based algorithms like _Gradient descent_, _BFGS_, _Newton Raphson_ or _Levenberg–Marquardt_, ... do not work.

There are heuristic search algorithms which can be used for discrete solution spaces.
Examples of these techniques are:
_Hill climbing_, _Tabu search_, _Simulated annealing_, ...
These algorithms move from solution to solution in the space of feasible candidate solutions (the search space) by applying local changes, until a solution deemed optimal is found or a time bound is elapsed.
However, due to the numerous count of unknown variables, these algorithms often need a long time to find a solution for our problem. Even after that, the returned solution may be still far away from the absolute optimal one.
Consider that for a small-scaled case of 50 tasks and 5 agents, we should search among $5^{50}$ possible solutions which is almost impossible to cover in a feasible amount of time even for the fastest CPUs (It takes $2.8 \times 10^{21}$  years to search all the solution space if each solution is tested in 1 micro second).

To find the optimal solution in a reasonable amount of time, the formulation of the problem should change.
We made this change by defining a different (and much smaller) solution space with real values.
This change, brings challenges which needed to be overcome by some tricks and techniques, 
but at the end, it gives a solution which is very close to the absolute optimal one and can be even closer to that by applying some post treatments. 
We will first define the dual definition of the problem and then explain the challenges and techniques used to overcome those challenges:

#### Dual Problem definition:
Given the same set of tasks, agents and skills and average time units matrix ($T, A, S, R$) defined in the original problem definition,

find 

$X$: count of tasks of skill $i$ allocated to agent $j$

to maximize:

$\Sigma_{i = 1}^m \Sigma_{j = 1}^k P_{ij}(x_{ij})$: priority−weighted task coverage (sum of priorities of allocated tasks)

subject to constraints:

$\Sigma_{i = 1}^m r_{ij} \cdot x_{ij} \leq u_i$: Because each agent's total processing time required for allocated tasks should be less than his/her available utilisation time

and

$n_j = \Sigma_{i = 1}^m x_{ij} \leq N_j$: Because sum of allocated tasks of each skill should not exceed the total count of existing tasks.

where:

$u_i$ is the amount of available time of agent $i$.

$N_j$ is the count of existing tasks of skill $j$ in the backlog.

$P_{ij}(x)$: Priority-weighted coverage function returning sum of priorities of $x$ tasks of skill $j$ allocated to agent
$i$.

In the new definition of the problem, the solution space is reduced to a $m \times k$ matrix where $m$ is the count of agents and $k$ is the count of skills or different task types.
The value of each cell now specifies how many tasks of type corresponding to the cell column should be allocated to the agent corresponding to the cell row. As you can see, the formulation of the objective function and constraints have changed to suit the new unknown variable space.
Obviously, finding the solution in this form, does not map tasks to individuals, but provides a guide for such mapping.
In the next step, given how many tasks of each type should be allocated to each agent, we start to map the tasks.
Grouping tasks by type, after sorting each group descending by priority, we pick the top $n_j = \Sigma_{i = 1}^{m} x_{ij}$ out of total $N_j$ tasks of type $j$ to allocate them to the agents according to the model recommendation: $x_1j$ tasks to agent 1, $x_2j$ tasks to agent 2, and so on ....

#### Challenges:

The main challenge solving the dual problem is the Priority-weighted coverage function ($P_{ij}$). 
This function should return sum of priorities of $x$ tasks of skill $j$ allocated to agent $i$ and hence depends on $i$, $j$ and $x$.
In other words, it should tell us if we allocate $x$ tasks of a specific type to a particular agent, 
how much will the priorities of those tasks add up to. 

The value of this function depends on the distribution of priorities in each type of tasks and should be recursively computed as it also depends on which tasks of the given type have been picked for previous agents.

If all priorities were equal or we could change the objective function to just sum of allocated tasks, the dual problem would be solved by linear programming, but in that case, we cannot apply priorities to the allocation.

One simplification to the problem is to replace $P_{ij}(x)$ by $\bar{p_j} \cdot x_{ij}$ where $\bar{p_j}$ is the mean of priorities of all tasks of type $j$.
With this simplification, we convert the problem to a linear programming which can be solved by _Simplex_ algorithm.
However this simplification, brings considerable inaccuracy and deviates us significantly from the optimal solution due to two reasons:

* $\bar{p_j}$ does not represent the average priority of allocated tasks but all tasks of type $j$, becasue for the objective function to be linear, $\bar{p_j}$ must not depend on $x_{ij}$.

* All tasks of the same type are represented by a single priority value, while they may come from a wide range of priorities. This leads to some high-priority tasks not allocated while they should be, or some low-priority tasks allocated while they should not be. Obviously, this effect is intensified when the variance of priorities of each type is high.

To overcome this problem, we clustered tasks of each type based on their priorities and grouped them to sub-groups where priorities are almost equal with minimized variability. The optimal count of clusters are different for each type and is determined automatically from _elbow_ plot with a maximum of 25 clusters. More clusters augments complexity with little benefit.
After clustering, we treat each sub-group as a new group (virtual skill).
Now we can assume priorities of each sub-group are equal to the mean. 
The objective function becomes linear and _simplex_ algorithm can be applied to solve the problem.

## Developer's guide to the OTAR package
Now let's use the OTAR package to run allocation for tasks described in the simple example above. You will need to follow the following steps in order to build a model and run it.

#### Step 1: Prepare the data

Firstly, we need to prepare input data. The minimum input dataset required are:

* list of tasks with types and priorities
* list of employees and their scheduled time
* Average unit time of each agent for each task type (skill)    

Whether the data is extracted from a database platform or read from a csv text file, it needs to become a R data.frame object  and contain a minimum of specific required columns to be used by the model.
For this example, we generate some dummy data of 1000 work items of 10 types and 26 resources to 
show the structure of the input data. 
Minimum columns required for the task list are: __Task ID__, __skill(Task Type)__, __agent__, __workable__ and __Priority__: Table ```tasklist``` contains our generated list of tasks:

```{r }
library(magrittr)
library(dplyr)
library(gener)
library(otar)

tasklist = data.frame(taskID = 'Task' %>% paste(1:1000), taskType = 'Type' %>% paste(1:10) %>% sample(1000, replace = T) , priority = rnorm(1000), score = 1, agent = as.character(NA), workable = T, stringsAsFactors = F)
show(tasklist %>% as_tibble)
```

Now it's time to introduce agents and provide available scheduled utilization time for each agent. We name the agents simply with alphabet letters and give 450 minutes of available time to each of them:

```{r }
agentlist = data.frame(Name = LETTERS, scheduled = 450)
show(agentlist %>% as_tibble)
```

And finally, you need to let the model know which agents are skilled in which task types and how long each agent spends in average to perform each task type (turnaround time). For this, a long-format table is required showing average unit times, aggregated from history performance data. Required columns are: __agent__, __skill__, __turnaround time(tat)__.
Let's generate a dummy performance history table representing 20,000 of the most recent completed work items. We will the aggregate that table to find average unit times:

```{r }
TT = data.frame(agent = LETTERS %>% sample(20000, replace = T), skill = paste('Type', 1:10) %>% sample(20000, replace = T), duration = rexp(20000, rate = 0.1), stringsAsFactors = F) %>% group_by(agent, skill) %>% summarise(Count = length(duration), AUT = mean(duration)) %>% filter(Count > 80)
show(TT %>% as_tibble)
```

Durations are supposed to come from an exponential distribution. As you can see in the code, a frequency threshold of 80 has been applied as a criteria for whether or not an agent is skilled in a task type. In other words, if the total count of completed tasks of a type by an agent in the history is less than 80, that agent is considered not skilled in that task type. 

#### Step 2: Build an empty model object

To build a model, start from an abstract instance of class ```OptimalTaskAllocator``` introduced in package ```otar```. Function ```OptimalTaskAllocator()``` returns an abstract instance.

```{r }
x <- OptimalTaskAllocator()
class(x)
```

Now, we can start feeding data into the empty model object.

#### Step 3: Introduce Agents(Resources)

```{r }
x <- feedAgents(x, agents = LETTERS)
```

#### Step 4: Introduce Skills(Task Types)

Then introduce task types (skills):
```{r}
x <- feedSkills(x, skills = tasklist$taskType %>% as.character %>% unique)
```

#### Step 5: Add resource scheduled available time

Now add scheduled amount of time each resource is available for working. We pass table ```agentlist``` which contains such information:

```{r}
x <- feedAgentSchedule(x, agentSCH = agentlist, agentID_col = 'Name', scheduled_col = 'scheduled')
```

#### Step 6: Feed agent-skill average unit times

```{r}
x <- feedAgentTurnaroundTime(x, ATT = TT, agentID_col = 'agent', skillID_col = 'skill', tat_col = 'AUT')
```

#### Step 7: Feed task list data
You can feed tasks by calling function ```feedTasks()```. Tasks are expected to have unique IDs. If duplicated IDs are observed, they will be deleted and won't be added to the backlog. Similarly, task types are expected to be among the skills introduced by function ```feedSkills()```. If there are task types(skills) in the tasks which are not introduced before, those tasks will be deleted by default unless you set argument ```feedNewSkills``` to ```TRUE```. In this case, all tasks with unique IDs are added and new skilld will be added to the skill profile.
```{r}
x <- feedTasks(x, tasklist, taskID_col = 'taskID', skillID_col = 'taskType', priority_col = 'priority', agentID_col = 'agent', extra_col = 'score')
```

It is possible to call function ```feedTasks()``` multiple times to add more tasks to the backlog.

##### Leftover tasks

There might be some tasks (work items) leftover from before. 
The model treats these tasks that must be completed before any new tasks are taken into hand. 
So, the model reserves required time for these tasks and subtracts this time from the available time agents have.
If for an agent, the time required for leftover tasks exceeds available time, no new task will be allocated to that agent.
Leftover tasks can be specified in the tasklist when the value in the __agent__ column is not missing. 
The model expects the agent IDs of leftover tasks added be among the agents previously introduced in function ```feedAgents()```, otherwise those tasks are deleted (by default). If there might be agents in the list of leftover tasks that were not introduced before, you can add them to the model by setting argument ```feedNewAgents``` to ```TRUE```. This will keep all the tasks and adds new agents to the agent profile.

Here, we generate 100 dummy leftover tasks and add it to the backlog of tasks:

```{r }
leftovers = data.frame(taskID = 'Task' %>% paste(1001:1100), taskType = 'Type' %>% paste(1:10) %>% sample(100, replace = T) , priority = rnorm(100), score = 1, agent = LETTERS %>% sample(100, replace = T), workable = T, stringsAsFactors = F)
x = feedTasks(x, leftovers, taskID_col = 'taskID', skillID_col = 'taskType', priority_col = 'priority', extra_col = 'score', agentID_col = 'agent', workable_col = 'workable')
```

##### Workable/Non-workable tasks

There might be work items in the tasklist which are not be workable due to any reason. For example, some tasks may have been arrived previously but rescheduled to a date in the future, such tasks will not be workable before they are due for commencement even though they exist in the tasklist. Workability of tasks are specified by setting a logical value TRUE/FALSE to the flag column __workable__. Non-workable tasks are simply excluded from allocation.
Here, 20 dummy non-workable work items are added to the tasklist:
```{r }
nonworkables = data.frame(taskID = 'Task' %>% paste(1101:1120), taskType = 'Type' %>% paste(1:10) %>% sample(20, replace = T) , priority = rnorm(100), score = 1, agent = LETTERS %>% sample(20, replace = T), workable = F, stringsAsFactors = F)
```

#### Step 8: Run the allocation

Now it's time to start the engine to run allocations. But before, it's good to know about some tuning arguments by which you can customize allocation based on your requirements. Some of these arguments are:

* **Kf**: 

Sometimes you may want to allocate tasks so that agents receive almost equal quota of work load and/or benefit from the works they do. For example, some work items regardless of thir type may be tougher than others but bring little customer outcome, on the otherside there might be some easier tasks with higher outcomes or benefit for the agent so that more employees would prefer to do. It is important to distribute a balanced share of hardness and benefit among the agents to have a __fair__ allocation. By default, SO does not care about this and allocates tasks to maximize prioritised task coverage (productivity), but it is possible to have a fairer allocation considering a balanced benefit and load sahring. For this, first you need to give a score to each task. This score is a scalar value reflecting the amount of overall benefit/loss that agents receive by performing that task. It could be defined as a weighted combination of task priority, hardness or simplicity, customer outcome or employee benefit (in terms of income, KPIs or whatever else). By giving a weight to argument ```Kf``` you can encourage the optimisation model to allocate with a more balanced score sharing among the agents. It can take any value from 0(default) to $\infty$. Usually $Kf = 1$ provides a reasonable allocation, however you should try different values and find the one which best suits your requirements.

* **Ku**:

If count of tasks is far more than the team capacity and employees are cross-skilled, it is expected that 100% of their available time be utilized, but if the count of tasks is lower than capacity, then agents may not be 100% utilized. In this case, you may want to balance utilization of the agents' time. By default, the model does not care about this.
A balanced agent utilization can be done in two ways:

* Set a non-zero value to argument ```Ku``` when calling function ```otar::distributeTasks()```
* Call function ```otar::balanceAgentUtilization()``` after the allocation.

If tasks are less than capacity and balanced load sharing is not a concern, the second option should be preferred. Use the first option only when you want to have balanced agent utilization and balanced score sharing combined in one run.

_Please note that passing any non-zero value for Ku or Kf, deviates the allocation from optimal considering productivity as the main objective, so you should expect equal or less tasks allocated when passing any non-zero values to these arguments._

* **flt2IntCnvrsn**:

After running the allocation, there might be some time left free in the agents' schedule. The initial solution calculates float values for count of tasks allocated. For example 3.2 tasks of type x allocated to agent A! The model converts float values to integers in three ways: __floor__ to closest lower integer, __cieleing__ to closest higher integer and __round__ it to the closest lower or higher integer. You can choose this option by passing one of the values ```'floor', 'ceiling', 'round'``` to argument ```flt2IntCnvrsn```.
Consider that options ```'ceiling'``` and ```'round'``` may lead to exceeding 100% utilization time.

* **fill_gap_time** 

After running the allocation, there might be some time left free in the agents' schedule. By passing TRUE to argument ```fill_gap_time```, the model will search among all the unallocated tasks (ordered descending by priority) to see if any task can be fitted in the remained gap time. 

* **prioritization**

By this argument, you specify how task priorities change before being fed to the optimisation algorithm. It must be one of these options: 

+ ```'ZFactorExponential'``` (default): Standardise priority values to Z factors and map via exponential function. 

+ ```'rankBased'```: Modifies priority values so that the minimum priority within a cluster is higher than sum of of all priorities in the next lower ranked cluster. 

+ ```'timeAdjusted'```: Multiplies each task priority by the average processing time of its associated skill. 
This conversion, eliminates the impact of average unit time in allocation and gives higher weight to task priorities rather than processing time. 

After running the allocation, you may see some tasks with lower priorities have been preferred to tasks with higher priorities.
This is likely to happen when argument ```prioritization``` is set to ```'ZFactorExponential'``` and tasks with lower priority tasks require less processing time comparing to those of higher priorities. Consider for example two groups of work items: type A with priority 0.6 which require 10 minutes by an agent to complete and type B with priority 0.8 which require 15 minutes by the same agent. So if the agent has 60 minutes of available time, the model would allocate 6 work items of group A rather than 4 work items of group B even though group B has a higher priority, because with the first option, it gains $0.6 \times 6 = 3.6$ scores as sum of priorities to add to the objective function while in the second option, the score gained is $0.8 \times 4 = 3.2$ which is less than the first option. If you want to give a higher weight to priority and reduce the impact of processing time, you should better change prioritization to ```'timeAdjusted'```. In this case, priorities are multiplied by average processing times required, so in the above example, priority of group A is adjusted to $p_A = 0.6 \times 10 = 6.0$ and of group B to $p_B = 0.8 \times 15 = 12.0$.
Now, the total scores gained by option 1 becomes $6 \times 6.0 = 36.0$ and by option 2 becomes $12 \times 4 = 48.0$ which is higher than option 1, so option 2 will be preferred.

Note: This option, leads to a sub-optimal task distribution, but results in the impact of priority values in picking tasks to go superior to the impact of average processing times. 

* **maxClusters**
Sometimes after observing the allocation result, you may see that a few lower-priority tasks are still preferred to high-priority tasks even though their processing times are equal. This may happen rarely when the distribution of priorities is multi-modal with many modes (usually higher than 20). The model groups tasks to a maximum number of 25 clusters, however, sometimes the variability of priorities is so high therefore, even more clusters may be required to have the variability of each group reduced enough to avoid this to happen.
What happens is that within one cluster, there is still some variability in priorities and this may lead to some high-priority and low-priority tasks in the two extreme ends of the range to be all represented by the mean priority of the cluster in which those tasks have fallen. So this causes some lower-priority tasks in a cluster which have a higher mean priority, to be preferred to some higher-priority tasks in another cluster (of a different task type or skill) which has a lower mean priority. 

Increasing the count of clusters help to reduce variability but increases the complexity of the problem and hence running time.
You can set the maximum count of clusters with argument ```maxClusters```. The model selects the optimal count of clusters from the lbow plot automatically but upto a maximum number indicated by argument ```maxClusters```. The default value is 25. 
The more clusters you have, the lower variability in each cluster is observed and this is less likely to happen.

Now that you have learned about the tuning arguments, let's run the allocation. To run the allocation you need to pass the object to function ```otar::distributeTasks()```:
```{r}
x <- distributeTasks(x)
```

#### Step 9: Observe allocation result

##### Allocation Summary table ```x$ALC```:

You have done the job! Now, let's see how the allocation looks like.
Object ```x``` has tables which contain all information about the task allocation.
It is a matrix with the same structure as turnaround time (Average Unit Time ```x$TAT```).
Row names are agent IDs and column names are skills and the value in each cell shows the count of tasks of the corresponding skill allocated to the corresponding agent.
Look at table ```x$ALC``` to see how tasks of each type are distributed among the agents:
```{r}
show(x$ALC)
```

##### Task list table ```x$TSK```:

If you need more details, you may want to see table ```x$TSK``` which shows which tasks are allocated to who and which tasks are left unallocated. Columns are:

* **skill**: Task type (skill) of the task.
* **agent**: Agent to whom the task is allocated. ```NA``` means the task is unallocated.
* **priority**: Priority value of the task.
* **workable**: A logical glag showing whether or not the task is workable at the time of allocation.
* **score**: A numeric value showing task score. It can reflect work load, benefit, customer outcome, priority, ... or a weighted combination of them.
* **AUT**: Average unit time. This value depends on who the task is allocated to. If the agent is missing, this value is missing too. This column is updated automatically after running allocation.

```{r}
show(x$TSK %>% as_tibble)
```

##### Agent Profile table (```x$AP```):

Agent Profile gives an aggregated overview of the agents' time and tasks allocated. 
Have a look at table ```x$AP```. This tables shows count of leftover and  allocated tasks to each agent, as well as scheduled, reserved, productive and available time, utilization factor and total score gained. Agent Profile is automatically updated after feeding tasks, agent scheduled time, agent turnaround time and running the allocation. Rownames of agent profile are identical to the unique agent IDs. It contains the following columns:

* **scheduled**: Amount of agent's scheduled time
* **utilFactor**: Utilization factor: is a value between 0 and 1 and specifies what percentage of scheduled time the agent is productive
* **productive**: Amount of agent's productive time. Obtained by multiplying scheduled time by utilization factor.
* **reserved**: Amount of agent's time required for leftover tasks previously allocated to him/her. 
* **available**: Amount of agent's time available for new tasks. Obtained by subtracting reserved time from productive time. Negative values are trimmed to zero.
* **utilized**: Amount of agent's time being utilized for working on the allocated tasks. 
* **AUT**: Average unit time for tasks allocated to the agent
* **Allocated**: Overall count of tasks allocated to the agent including leftover and new allocated tasks.
* **Leftover**: Count of tasks previously allocated to the agent known as leftover tasks.
* **newAllocated**: Count of tasks allocated to the agent after running the optimisation model.
* **notWorkable**: Count of non-workable tasks allocated to the agent (These tasks are not considered as leftovers because no time is reserved for them).
* **score**: Total scores gained by the agent through tasks allocated to him/her (Including leftovers). 

##### Skill Profile table (```x$SP```):
Skill Profile (table ```x$SP```) provides an aggregated overview of the skills(task types) introduced. 
This tables shows count of leftover and  allocated tasks, non-workable tasks and total backlog of each type. 
Skill Profile is automatically updated after feeding tasks, agent turnaround time and running the allocation. It contains the following columns:

* **AUT**: Average unit time for tasks of each skill.
* **Allocated**: Overall count of tasks of each skill allocated.
* **Leftover**: Total count of leftover tasks of each skill previously allocated.
* **newAllocated**: Total count of tasks of each skill allocated after running the optimisation model.
* **notWorkable**: Count of non-workable tasks of each skill.
* **score**: Average score of tasks of each skill(type). 

#### Step 10: Post-allocation treatments
In most cases, the allocation results after running function ```distributeTasks()``` with proper arguments is acceptable, however
there might be still some tasks not allocated as expected. The two post-allocation treatment functions can be applied to bring the allocation closer to expectation:

##### ```otar::balanceAgentUtilization()```:

Since the objective function is defined as priority-weighted task coverage (sum of priorities of allocated tasks),
the optimization model does not care about balancing the utilized time of agents especially when tasks are less than capacity.
This may lead to some agents to have more than 80% of their time utilized just because they are faster while some agents may be allocated nothing. 
Such an allocation may not be acceptable if team leaders do not have any plan for the free available time of those slower agents after allocation, so you may want to balance utilization percentage as much as possible. As explained, you can have a more balanced utilization by giving a non-zero weight to argument ```Ku``` when calling function ```otar::distributeTasks()```. However, this will lead to a sub-optimal allocation as you will expect to see less tasks allocated comparing to when ```Ku``` is zero.
If balancing utilization is in the second rank of importance, you should better run ```distributeTasks(Ku = 0, ...)``` and then pass the allocated object to function ```balanceAgentUtilization()```. This function, changes the allocation, if possible, to reduce variability in utilization percentages among the agents by distributing tasks more evenly but does not impact overall count of allocated tasks. In other words, the treatment is performed within the framework of the initial optimal solution by changing the mapping of tasks to individuals and not selecting the allocated tasks.

##### ```otar::correctAllocation()```:

As explained before, setting argument ```prioritization``` to ```'timeAdjusted'```, enhances the impact of priorities in picking tasks for allocation, however, this may come with a trade-off as you will lose a bit of productivity by changing priority values. Calling post-treatment function ```correctAllocation()```, changes allocation by searching among non-allocated tasks to see if any of them can be replaced by a lower-priority task provided that the difference of processing time required for the replaced task and the previously allocated task, does not exceed the value passed to argument ```autTolerance```. 
This treatment will not reduce the total count of allocated tasks, but may lead to exceed 100% of utilization time for some agents but the increased overall agents' utilized time will never exceed the value set in ```autTolerance```.
The default value for this argument is 10 unit times.
By setting ```autTolerance``` to zero, the allocation is not expected to change so much because it is already optimized in using agent's time for maximum priority coverage. The only exception is when argument ```prioritization``` is set to ```'zFactorExponential'``` or count of clusters is lower than optimal for being trimmed to a maximum set by argument ```maxClusters```.

## Summary




# otar version 4.3.8


# Header
# Filename:      ota.R
# Version   Date               Action
# -----------------------------------
# 1.0.0     25 January 2017    Initial issue
# 1.1.0     06 March 2017      Definition of S3 class OPTIMAL.TASK.ALLOCATOR for workforce optimization
# 2.0.0     22 March 2017      A major change in the code: All tables reduced to two: taskList, AsM Agent-Skill Matrix, Many variable names changed!
# 2.0.1     30 March 2017      Functions feedAgentProfile() and feedSkillPrifile() added.
# 2.0.2     30 March 2017      Functions feedAgents() and feedSkills can now accept data.frames as well as character setrings
# 2.0.3     30 March 2017      Function feedTasks() adds new tasks to the existing task list and only creates a new task list if no prior task list is fed
# 2.0.4     11 April 2017      Function distributeTasks() modified: Now breaks task priorities to categories and genertaes classes of skill-priority level to be treated as virtual skills
# 2.0.5     09 May 2017        Function feedTasks() modified: Tasks with duplicated IDs are eliminated.
# 2.0.6     09 May 2017        Function feedAgentTurnaroundTime() modified: Agents which are not already fed will be eliminated!
# 2.1.0     26 May 2017        Columns Allocated, Unallocated, Leftover and Backlog added for both agent and skill profile tables before and after task distribution
# 2.1.1     03 July 2017       Argument workable_col added to function feedTasks()
# 2.1.3     03 July 2017       Functions feedTasks() and distributeTasks() modified: Aggregates on 'Unallocated', 'newAllocated', 'Leftover', 'Non-workable' and 'Backlog'
# 2.1.4     12 July 2017       Name changed to ota.R denoting: Optimal Task Allocator
# 2.1.5     24 July 2017       Function calcAgentTAT() exported
# 2.1.6     26 July 2017       Function updateAgentUtilization() added
# 2.1.8     26 July 2017       feedAgentProductiveTime() renamed to feedAgentSchedule() and modified: Argument utilFactor_col added
# 2.1.9     27 July 2017       Function updateTaskCounts() added
# 2.2.0     10 August 2017     Functions addAgeProfiles(), tableAgeGroups() and tableDueAgeGroups() removed
# 2.2.1     11 August 2017     Function updateAgentUtilization() modified: Small bug removed
# 2.2.2     16 August 2017     Function updateAgentUtilization() modified: Small bug removed
# 2.2.3     21 August 2017     Function updateAgentCounts() modified: Updates ALC as well! Alos, ALC update removed from distributeTasks()
# 2.2.4     29 August 2017     Function clearAllocation() added.
# 2.2.5     30 August 2017     Function feedAgentSchedule() modified: Calls updateAgentUtilization() before returning the object
# 2.2.7     31 August 2017     Bug in function distributeTasks() rectified! Did not allocate when only one skill with single priority level existd.
#                              Changes applied in accordance with modifications in functions optimTaskDistribute() and optimTaskAllocate.LP() in ota.tools.R
# 2.2.8     05 September 2017  Bug in function updateAgentUtilization() rectified! Used to keep reserved time for non-workable tasks!
# 2.2.9     06 September 2017  Function clearAllocation() exported!
# 2.3.0     12 September 2017  All feed functions modified! Arguments feedNewAgents and feedNewSkills added.
# 2.3.1     12 September 2017  Functions updateAgentUtilization() and updateTaskCounts() exported.
# 2.3.2     18 September 2017  Function updateAgentSchedule() modified: A bug was rectified: The whole agent schedule table was emptied when agent IDs are introduced as rownames!
#                              to rectify, check for feedNewAgents scripts moved to after converting agent ID column to rownames of agent_SCH. intersects agids with obj$agents
# 2.3.3     22 September 2017  Functions feedTasks() modified: Argument stringsAsFactors set to FALSE when calling data.frame to generate the task list
# 2.3.4     26 September 2017  Functions feedAgentTurnaroundTime() modified: Converts 0 values to NA
# 2.3.5     26 September 2017  Functions updateAgentUtilization() modified:In obj$TAT and obj$TSK$AUT, zero values are converted to NA
# 2.3.6     05 October 2017    Function distributeTasks() modified: passes argument 'prioritization' to function optimTaskDistribute() ota.tools.R
# 2.3.7     09 October 2017    Function feedTasks() modified: Argument feedNewAgents added.
# 2.3.8     10 October 2017    All agent_col arguments renamed to agentID_col, all skill_col renamed to skillID_col.
# 2.3.9     12 October 2017    Function clearAllocation() modified: Used to fail when obj$TSK was empty. Fixed now!
# 2.4.0    16 October 2017    Function updateAgentUtilization() modified! Does nothing if agent profile table is empty
# 2.4.2     17 October 2017    Function feedTasks() modified! Removing duplicates is implemented after removing tasks with unknown skills or agents
# 2.4.2     30 October 2017    Function feedTasks() modified! column agent comes before column priority
# 2.4.3     01 November 2017   Function updateTaskCounts() modified! Resets counts in SP if TSK is empty
# 2.4.4     02 November 2017   Function feedSkillProfile() modified! Ignores if rownames of given argument 'skill' is sequential
# 2.4.5     04 December 2017   Function feedTasks() modified! Uses simple rbind rather than dplyr::bind_rows() because bind_rows changes the time zone for POSIXct columns.
#                              This change, requires for the new task table, all the columns to be identical to the existing obj$TSK to be able to merge
# 2.4.6     04 December 2017   all calls to assert() changed to niragen::assert() to avoid conflict with package gtools
# 2.4.7     09 January 2018    Function distributeTasks() modified: passes coefficients to optimTaskDistribute for non-linear optimization
# 2.4.8     01 March 2018      Function feedSkills() modified: adds column 'score' to the skill profile table by default
# 2.4.9     08 March 2018      Function distributeTasks() modified: does not pass argument ss (skill scores) when calls optimTaskDistribute()
# 2.5.0     08 March 2018      Function updateAgentUtilisation() modified: Fills TSK$score from SO$score only if the column does not exist in TSK table. If any column exists, keeps it intact.
# 2.5.1     07 May 2018        Function updateAgentUtilisation() modified: Computes task AUT times in a more memory-efficient way to avoid high memory allocation.
# 2.5.2     08 May 2018        Function clearAllocation() modified: Only runs if there is any allocated non-leftover tasks.
# 2.5.3     08 May 2018        Function clearAllocation() modified: Argument 'update' added. If TRUE(default) runs updateUtilisation() and updateTaskCounts()
# 2.5.4     08 May 2018        Function feedTasks() modified: Argument 'update' added. If TRUE(default) runs updateUtilisation() and updateTaskCounts()
# 2.5.5     25 May 2018        Function correctAllocation() added. Not exported!
# 2.5.6     25 May 2018        Documentation added for functions OptimalTaskAllocator(), feedAgents(),  updateTaskCounts(), updateAgentUtilization() and feedSkills()
# 2.5.7     28 May 2018        Documentation added for functions feedTasks(), feedAgentSchedule() and feedAgentTurnaroundTime()
# 2.5.8     28 May 2018        Function correctAllocation() modified: Shows progress bar enabled with argument 'show_progress'
# 2.5.9     28 May 2018        Function distributeTasks() modified: Argument 'silent'. Shows consequent stages of allocation on the console. The argument is passed to functions optimTaskDistribute() and correctAllocation().
# 2.6.0     28 May 2018        Initial documentation draft added for function distributeTasks()
# 2.6.1     28 May 2018        Small syntax error in functions feedAgents() and feedSkills() rectified.
# 2.6.2     04 June 2018       Function updateAgentUtilization() modified: A bug rectified: task scores could not be set from skill profile for the second task feed. Now it sets the scores from SP if task score is missing. score
# 2.6.3     09 July 2018       Function distributeTasks() modified: does not call function correctAllocation after allocation of tasks.
# 2.6.4     09 July 2018       Function correctAllocation() modified: if no task is left unallocated, does not show progress_bar and writes a message.
# 2.6.5     09 July 2018       Documentation added for functions: correctAllocation() and clearAllocation()
# 2.6.6     13 July 2018       Function correctAllocation() modified: Runs faster as it breaks in the middle of the loop if max priority of unallocated tasks becomes lower than min priority of allocated ones
# 2.6.7     13 July 2018       Function shuffle() added: Respecting count of allocated tasks to each employee, shuffles the tasks requiring equal time among agents randomly to have a better mix of skills and priorities
# 2.6.8     13 July 2018       Function forceAllocation() added: Allocating from scratch, forces allocation of tasks only based on highest priority, ignoring time (very sub-optimal for productivity)



tltpCols4Agents  = c('Agent ID' = 'AgentID', 'Average Speed' = 'speed', 'Average TAT' = 'C.AUT', 'Allocated' = 'C.Allocated')
tltpUnits4Agents = c('', 'task/Hr', 'min', 'tasks')
tltpCols4Skills  = c('Task Type' = 'skillID', 'Total Backlog' = 'Backlog', 'Allocated' = 'C.Allocated', 'Coverge' = 'coverage', 'Average Speed' = 'speed', 'Average TAT' = 'C.AUT')
tltpUnits4Skills = c('', 'tasks', 'tasks', '%', 'task/Hr', 'min')

# Class Constructor:
#' Abstract constructor for S3 class \code{OptimalTaskAllocator}
#'
#' @param agents character vector: Should contain unique names or IDs of agents (resources or employees).
#' @param skills character vector: Should contain unique names or IDs of skills (task types)
#' @param vf boolean: Should input arguments be checked?
#' @return an object of class \code{OptimalTaskAllocator}
#' @examples
#' x = OptimalTaskAllocator()
#' class(x)
#'
#' @export
OptimalTaskAllocator = function(agents = NULL, skills = NULL, vf = TRUE){
  obj = list()
  class(obj) <- 'OptimalTaskAllocator'
  
  obj$AP = data.frame()
  obj$SP = data.frame()
  obj$TAT = data.frame()
  obj$ALC = data.frame()
  
  if(vf){
    agents %<>% verify('character') %>% unique
    skills %<>% verify('character') %>% unique
  }
  
  if (!is.null(agents)){obj %<>% feedAgents(agents)}
  if (!is.null(skills)){obj %<>% feedSkills(skills)}
  
  if (is.empty(obj$AP)){obj$AP = data.frame(scheduled = numeric(), utilFactor = numeric(), reserved = numeric(), productive = numeric(), available = numeric(), utilized = numeric(),
                                            AUT = numeric(), Allocated = integer(), Leftover = integer(), newAllocated = integer(), notWorkable = integer())}
  
  if (is.empty(obj$SP)){obj$SP = data.frame(PRW = numeric(), AUT = numeric(), Allocated = integer(), Unallocated = integer(), Leftover = integer(),
                                            newAllocated = integer(), notWorkable = integer(), Backlog = integer())}
  
  if (is.empty(obj$TSK)){obj$TSK = data.frame(skill = character(), agent = character(), priority = numeric(), workable = logical(), LO = logical(), status = factor(), AUT = numeric())}
  
  return(obj)
}

# Feeds list of Agents
#' Use this function to add a list of agents to the model
#'
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param agents character vector or data.frame: Should contain unique names or IDs of agents (resources or employees). If a data.frame is given,
#' it must have rownames which specify unique names or IDs of the agents. Columns of the given table will be added to the agent profile \code{obj$AP}
#' @param vf boolean: Should input arguments be checked?
#' @return an object of class \code{OptimalTaskAllocator} with given agents added
#' @examples
#' x = OptimalTaskAllocator() %>% feedAgents(c('Bill', 'Michael', 'Chris'))
#' x$agents
#'
#' @export
feedAgents = function(obj, agents, vf = T, ...){
  if(vf){agents %<>% verify(c('character', 'data.frame'), fix = T)}
  if (inherits(agents, 'character')){
    agents = agents %-% rownames(obj$AP)
    if (!is.empty(agents)){
      obj$AP[agents, ]  <- NA
      obj$TAT[agents, ] <- NA
      obj$ALC[agents, ] <- NA
    }
    obj$agents <- rownames(obj$AP)
    return(obj)
  } else if (inherits(agents, 'data.frame')){
    return(obj %>% feedAgentProfile(agents, ...))
  } else {stop("Invalid class for argument 'agents'!")}
}

#' @export
feedAgentProfile = function(obj, agents, agentID_col = NULL, extra_col = NULL){
  # Verifications
  verify(agents, 'data.frame', varname = 'agents')
  nms = names(agents)
  niragen::assert(!is.null(nms), 'Given table agents must have column labels', match.call()[[1]])
  
  agentID_col %<>% verify('character', domain = nms, lengths = 1, varname = 'agentID_col')
  extra_col   %<>% verify('character', domain = nms, default = nms %-% agentID_col, varname = 'extra_col')
  
  if (is.null(agentID_col)){
    agids = rownames(agents)
    niragen::assert(!is.null(agids) & !identical(agids, as.character(sequence(nrow(agents)))), 'Given table agents must have row labels. When argument agentID_col is not specified, agent IDs should be aspecified as rownames', match.call()[[1]])
  } else {
    agids  = agents[, agentID_col] %>% as.character
    keep   = !duplicated(agids)
    agids  = agids[keep]
    agents = agents[keep, ]
  }
  obj %<>% feedAgents(agids)
  
  if(extra_col %>% names %>% is.null){names(extra_col) <- extra_col}
  
  for (fig in names(extra_col)){
    obj$AP[agids, fig] <- agents[, extra_col[fig]]
  }
  return(obj)
}

#' Updates task counts in the object tables.
#'
#' Task statuses in \code{obj$TSK} and counts of various task statuses in tables: \code{obj$SP} and \code{obj$AP} are updated.
#' Also, updates the allocation matrix \code{obj$ALC}. This function should be called after any change in task allocation status.
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @return an object of class \code{OptimalTaskAllocator} with updated tables
#' @export
updateTaskCounts = function(obj){
  if(!is.empty(obj$TSK)){
    obj$TSK$status = 'newAllocated'
    obj$TSK$status[obj$TSK$agent %>% is.na] = 'Unallocated'
    obj$TSK$status[obj$TSK$LO] = 'Leftover'
    obj$TSK$status[!obj$TSK$workable] = 'notWorkable'
    
    sksum = obj$TSK %>% reshape2::dcast(skill ~ status, fun.aggregate = length, value.var = 'skill') %>% column2Rownames('skill')
    nms   = sksum %>% names
    
    obj$SP$Unallocated    = chif('Unallocated' %in% nms, sksum[obj$skills, 'Unallocated'], 0) %>% na2zero
    obj$SP$Leftover      = chif('Leftover' %in% nms, sksum[obj$skills, 'Leftover'], 0) %>% na2zero
    obj$SP$newAllocated   = chif('newAllocated' %in% nms, sksum[obj$skills, 'newAllocated'], 0) %>% na2zero
    obj$SP$notWorkable    = chif('notWorkable' %in% nms, sksum[obj$skills, 'notWorkable'], 0) %>% na2zero
    obj$SP$Backlog        = rowSums(sksum)[obj$skills] %>% na2zero
    obj$SP$Allocated      = obj$SP$Leftover + obj$SP$newAllocated
    
    agsum = obj$TSK %>% filter(!is.na(agent)) %>% group_by(agent) %>% dplyr::summarize(Allocated = sum(!is.na(agent)), Leftover = sum(LO & workable), newAllocated = sum(!LO & workable), notWorkable = sum(!workable)) %>% as.data.frame %>% column2Rownames('agent')
    
    obj$AP$Allocated     = agsum[obj$agents , 'Allocated'] %>% na2zero
    obj$AP$Leftover      = agsum[obj$agents , 'Leftover'] %>% na2zero
    obj$AP$newAllocated  = agsum[obj$agents , 'newAllocated'] %>% na2zero
    obj$AP$notWorkable   = agsum[obj$agents , 'notWorkable'] %>% na2zero
    
    asal = reshape2::dcast(obj$TSK, agent ~ skill, value.var = 'AUT', fun.aggregate = length) %>% na.omit %>% column2Rownames('agent') # asal: agent skill allocated
    ags  = obj$agents %^% rownames(asal)
    sks  = obj$skills %^% colnames(asal)
    obj$ALC[ , ] <- 0
    obj$ALC[ags, sks] = asal[ags, sks]
    obj$ALC[obj$ALC %>% is.na] <- 0
  } else {
    if(!is.empty(obj$SP)){
      obj$SP$Allocated    = 0
      obj$SP$Unallocated  = 0
      obj$SP$Leftover     = 0
      obj$SP$newAllocated = 0
      obj$SP$notWorkable  = 0
      obj$SP$Backlog      = 0
    }
    if(!is.empty(obj$AP)){
      obj$AP$Allocated    = 0
      obj$AP$Leftover     = 0
      obj$AP$newAllocated = 0
      obj$AP$notWorkable  = 0
    }
  }
  return(obj)
}

#' Updates agent utilization measures in table \code{obj$AP}
#'
#' These measures include: scheduled time, productive time, reserved time, utilized time, available time.
#' Also updates column \code{score} in the agent profile table \code{obj$AP}.
#' Also updates column \code{AUT} in the task list \code{obj$TSK} containing average processing unit times.
#' If utilization factor is not already given (via function \code{feedAgentSchedule()}), it will be set as \code{1.0} for all agents.
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @return an object of class \code{OptimalTaskAllocator} with updated tables
#' @export
updateAgentUtilization = function(obj){
  if(obj$AP %>% is.empty){
    obj$AP$reserved  = numeric()
    obj$AP$utilized  = numeric()
    obj$AP$available = numeric()
    obj$AP$score     = numeric()
    return(obj)
  }
  obj$AP$scheduled  %<>% na2zero
  obj$AP$utilFactor[is.na(obj$AP$utilFactor)] <- 1.0
  obj$AP$productive = obj$AP$scheduled*obj$AP$utilFactor
  
  if(is.empty(obj$TSK)){
    obj$AP$reserved = 0
    obj$AP$score    = 0
  } else {
    obj$TSK$AUT   = obj$TSK %>% apply(1, function(xx){obj$TAT[xx['agent'], xx['skill']]})
    if(is.null(obj$TSK$score)){stc = obj$TSK %>% nrow %>% sequence} else {stc = which(is.na(obj$TSK$score))}
    obj$TSK$score[stc] = obj$SP[obj$TSK$skill[stc] %>% as.character, 'score']
    RSVD = obj$TSK %>% filter(LO & workable) %>% dplyr::group_by(agent) %>% dplyr::summarise(AUT = sum(AUT, na.rm = T)) %>% as.data.frame %>% column2Rownames('agent')
    UTLD = obj$TSK %>% filter(!is.na(agent) & workable) %>% dplyr::group_by(agent) %>% dplyr::summarise(AUT = sum(AUT, na.rm = T)) %>% as.data.frame %>% na2zero %>% column2Rownames('agent')
    SCRS = obj$TSK %>% filter(!is.na(agent) & workable) %>% dplyr::group_by(agent) %>% dplyr::summarise(score = sum(score, na.rm = T)) %>% as.data.frame %>% na2zero %>% column2Rownames('agent')
    
    obj$AP$reserved = RSVD[obj$agents, 'AUT'] %>% na2zero
    obj$AP$utilized = UTLD[obj$agents, 'AUT'] %>% na2zero
    obj$AP$score    = SCRS[obj$agents, 'score'] %>% na2zero
  }
  
  obj$AP$available = obj$AP$productive - obj$AP$reserved
  obj$AP$available[obj$AP$available < 0] <- 0
  
  obj$TAT[obj$TAT == 0] <- NA
  obj$TSK$AUT[obj$TSK$AUT == 0] <- NA
  
  return(obj)
}

#' Use this function to add a list of skills (task types) to the model
#'
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param skills character vector or data.frame: Should contain unique names or IDs of skills (task types). If a data.frame is given,
#' it must have rownames which specify unique names or IDs of the skills. Columns of the given table will be added to the skill profile \code{obj$SP}
#' @param vf boolean: Should input arguments be checked?
#' @return an object of class \code{OptimalTaskAllocator} with given skills added
#' @examples
#' x = OptimalTaskAllocator() %>% feedSkills(c('Document Verification', 'Certification', 'Aftercare Sealing'))
#' x$skills
#'
#' @export
feedSkills = function(obj, skills, vf = T, ...){
  if(vf){skills %<>% verify(c('character', 'data.frame'), fix = T)}
  if (inherits(skills, 'character')){
    skills = skills %-% rownames(obj$SP)
    if (!is.empty(skills)){
      obj$SP[skills,]   <- NA
      obj$SP[skills, 'score'] = 1.0
      obj$TAT[, skills] <- NA
      obj$ALC[, skills] <- NA
    }
    obj$skills <- rownames(obj$SP)
    return(obj)
  } else if (inherits(skills, 'data.frame')){
    return(obj %>% feedSkillProfile(skills, ...))
  } else {stop("Invalid class for argument 'skills'!")}
}

#' @export
feedSkillProfile = function(obj, skills, skillID_col = NULL, score_col = NULL, extra_col = NULL){
  # Verifications
  verify(skills, 'data.frame', varname = 'skills')
  nms = names(skills)
  niragen::assert(!is.null(nms), 'Given table skills must have column labels', match.call()[[1]])
  
  skillID_col %<>% verify('character', domain = nms, lengths = 1, varname = 'skillID_col')
  score_col   %<>% verify('character', domain = nms, lengths = 1, varname = 'score_col')
  extra_col   %<>% verify('character', domain = nms, default = nms %-% c(skillID_col, score_col), varname = 'extra_col')
  
  if (is.null(skillID_col)){
    skids = rownames(skills)
    niragen::assert(!is.null(skids), 'Given table skills must have row labels. When argument skillID_col is not specified, skill IDs should be aspecified as rownames', match.call()[[1]])
  } else {
    skids  = skills[, skillID_col] %>% as.character
    keep   = !duplicated(skids)
    skids  = skids[keep]
    skills = skills[keep, ]
  }
  
  obj %<>% feedSkills(skids)
  
  if(extra_col %>% names %>% is.null){names(extra_col) <- extra_col}
  
  for (fig in names(extra_col)){
    obj$SP[skids, fig] <- skills[, extra_col[fig]]
  }
  
  if (is.null(score_col)){obj$SP$score = chif(is.empty(obj$SP), numeric(), 1.0)} else {obj$SP[skids, 'score'] = skills[, score_col]}
  
  return(obj)
}

#' @export
feedAgentCountHistory = function(obj, agentCH, date_col = 'date', agentID_col = 'agentID', skillID_col = 'skill', taskCount_col = 'count', feedNewAgents = F, feedNewSkills = F){
  verify(agentCH, 'data.frame', names_include = c(date_col, agentID_col, skillID_col, taskCount_col), varname = 'agentCH')
  
  if(feedNewAgents){obj %<>% feedAgents((agentCH[, agentID_col] %>% unique %>% as.character) %-% obj$agents)} else {
    keep    = agentCH[, agentID_col] %in% obj$agents
    agentCH = agentCH[keep,]
    ndel    = sum(!keep)
    warnif(ndel > 0, ndel %++% ' records were removed because their agent IDs were not defined!')
  }
  
  if(feedNewSkills){obj %<>% feedSkills((agentCH[, skillID_col] %>% unique %>% as.character) %-% obj$skills)} else {
    keep    = agentCH[, skillID_col] %in% obj$skills
    agentCH = agentCH[keep,]
    ndel    = sum(!keep)
    warnif(ndel > 0, ndel %++% ' records were removed because their skill IDs were not defined!')
  }
  
  obj$ACH = data.frame(date = agentCH[,date_col], agentID = agentCH[, agentID_col], skill =  agentCH[, skillID_col], count = agentCH[, taskCount_col], stringsAsFactors = F)
  
  obj$ACH$date    %<>% as.Date
  obj$ACH$agentID %<>% as.character
  obj$ACH$skill   %<>% as.character
  obj$ACH$count   %<>% as.integer
  
  return(obj)
}

#' Use this function to feed tasks to the model (including leftover tasks).
#'
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param tasks data.frame: Should contain list of tasks to be allocated. The table must contain task IDs, skill(task types), agent (resource or employee ID) for leftover tasks
#' task priority, and a workable flag specifying whether the task is workable or not.
#' @param taskID_col Single character: Specifies the column name containing task IDs in the table passed o argument \code{tasks}.
#' If NULL, rownames of the table must contain task IDs.
#' @param skillID_col Single character: Specifies the column name containing skill IDs or skill names in the table passed o argument \code{tasks}.
#' @param priority_col Single character: Specifies the column name containing task priority values in the table passed o argument \code{tasks}.
#' @param agentID_col Single character: Specifies the column name containing agent(resource) IDs or names in the table passed o argument \code{tasks}.
#' If agent is not specified for a task (Value NA in column agent) means the task is not allocated and needs to be allocated by the allocator engine as a result of optimization.
#' @param workable_col Single character: Specifies the column name containing logical flags for the tasks which determines whether the task is workable or not.
#' @param extra_col character vector: Which other columns of table \code{tasks} should be added to the task list?
#' @param feedNewSkills logical: If there are new skills in the given task list that are not already fed to the model, should they be added to the skill profile?
#' If \code{FALSE} (default), tasks with unknown skills will be eliminated from the list.
#' @param feedNewAgents logical: If there are new agents in the given task list that are not already fed, should they be added to the agent profile?
#' If \code{FALSE} (default), tasks with unknown agents will be eliminated from the list.
#' @param vf boolean: Should input arguments be checked?
#' @return an object of class \code{OptimalTaskAllocator} with given tasks added to the task list (table \code{obj$TSK}).
#'
#' @export
feedTasks = function(obj, tasks, taskID_col = NULL, skillID_col = 'skill', priority_col = 'priority', agentID_col = NULL, workable_col = NULL, extra_col = NULL, feedNewSkills = F, feedNewAgents = F, update = T){
  verify(tasks, 'data.frame', names_include = c(taskID_col, skillID_col, priority_col, agentID_col, workable_col), varname = 'tasks')
  # todo: use function nameColumns from niragen
  if(!is.null(taskID_col)){tasks[,taskID_col]   %<>% as.character}
  if(!is.null(agentID_col)){tasks[,agentID_col] %<>% as.character}
  if(!is.null(workable_col)){tasks[,workable_col] %<>% as.logical}
  tasks[,skillID_col] %<>% as.character
  tasks[,priority_col] %<>% as.numeric %>% verify(err_msg = "Argument priority must refer to a numeric column", err_src = match.call()[[1]])
  
  nms = names(tasks)
  extra_col %<>% verify('character', domain = nms, default = nms %-% c(taskID_col, skillID_col, priority_col, agentID_col, workable_col), varname = 'extra_col')
  
  if(feedNewSkills){obj %<>% feedSkills((tasks[, skillID_col] %>% unique %>% as.character) %-% obj$skills)} else {
    keep  = tasks[, skillID_col] %in% obj$skills
    tasks = tasks[keep,]
    ndel  = sum(!keep)
    warnif(ndel > 0, ndel %++% ' tasks were removed because their skills were not defined!')
  }
  
  newAgents = (tasks[, agentID_col] %>% na.omit %>% unique %>% as.character) %-% obj$agents
  if(length(newAgents) > 0){
    if(feedNewAgents){obj %<>% feedAgents(newAgents)} else {
      tbd   = tasks[, agentID_col] %in% newAgents
      tasks = tasks[!tbd,]
      ndel  = sum(tbd)
      warnif(ndel > 0, ndel %++% ' tasks were removed because their agents were not defined!')
    }
  }
  
  if (is.null(taskID_col)){
    rnmstsks = rownames(tasks)
    niragen::assert(!is.null(rnmstsks), "When argument 'taskID_col' is not specified, task IDs should be specified as rownames of argument 'tasks'!", match.call()[[1]])
  } else {
    dps = duplicated(tasks[, taskID_col])
    ndp = sum(dps)
    warnif(ndp > 0, 'Warning: There are ' %++% ndp  %++% ' tasks with duplicated IDs which are removed!')
    tasks = tasks[!dps,]
    rownames(tasks) <- tasks[, taskID_col]
  }
  
  if(is.empty(tasks)){
    tt = data.frame(skill = character(), agent = character(), priority = numeric(), workable = logical(), stringsAsFactors = FALSE)
  } else {
    tt = data.frame(skill    = tasks[, skillID_col],
                    agent    = chif(is.empty(agentID_col), NA, tasks[, agentID_col]),
                    priority = tasks[, priority_col],
                    workable = chif(is.empty(workable_col),T, tasks[, workable_col]),
                    stringsAsFactors = F)
  }
  
  
  if(extra_col %>% names %>% is.null){names(extra_col) <- extra_col}
  
  tt %<>% appendCol(tasks[, extra_col], names(extra_col))
  rownames(tt) <- rownames(tasks)
  
  tt$skill    %<>% as.character
  tt$priority %<>% as.numeric
  options(warn = -1)
  if(is.null(obj$TSK)){obj$TSK = tt}
  else {
    # P = bind_rows(tibble::rownames_to_column(tt), tibble::rownames_to_column(obj$TSK)) %>%
    #   distinct(rowname, .keep_all = T)
    # obj$TSK <- tibble::column_to_rownames(P) %>% as.data.frame
    obj$TSK = tt %>% rownames2Column('TaskID') %>% bind_rows(obj$TSK %>% rownames2Column('TaskID')) %>%
      distinct(TaskID, .keep_all = T) %>% column2Rownames('TaskID')
  }
  options(warn = 1)
  
  loindx = !is.na(obj$TSK$agent)
  obj$TSK$LO[ loindx] <- TRUE
  obj$TSK$LO[!loindx] <- FALSE
  
  if(update){obj %<>% updateAgentUtilization %>% updateTaskCounts}
  
  return(obj)
}

#' @export
feedAgentUtilizationHistory = function(obj, agentUH, date_col = 'date', agentID_col = 'agentID', prodTime_col = 'prodTime', feedNewAgents = F){
  verify(agentUH, 'data.frame', names_include = c(date_col, agentID_col, prodTime_col), varname = 'agentUH')
  
  if(feedNewAgents){obj %<>% feedAgents((agentUH[, agentID_col] %>% unique %>% as.character) %-% obj$agents)} else {
    keep    = agentUH[, agentID_col] %in% obj$agents
    agentUH = agentUH[keep,]
    ndel    = sum(!keep)
    warnif(ndel > 0, ndel %++% ' records were removed because their agent IDs were not defined!')
  }
  
  obj$AUH = agentUH[, c(date_col, agentID_col, prodTime_col)]
  names(obj$AUH) <- c('date', 'agentID', 'prodTime')
  return(obj)
}

#' Use this function to feed scheduled time for the agents(resources).
#'
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param agentSCH data.frame: Should contain list of agents (resources or employees) with scheduling information.
#' The table must contain agent IDs, scheduled time and utilisation factors. Scheduled time must be given in minutes and
#' utilisation factor is a value between \code{0} and \code{1} specifying for each agent, what percentatge of the scheduled time they are productive and can be utilised.
#' @param agentID_col single character: Specifies the column name containing agent(resource) IDs or names in the table passed o argument \code{agentSCH}.
#' @param scheduled_col single character: Specifies the column name containing values of scheduled time in minutes.
#' @param utilFactor_col single character: Which column in table \code{agentSCH} contains utilisation factor values?
#' @param feedNewAgents logical: If there are new agents in the given table \code{agentSCH} that are not already fed, should they be added to the agent profile?
#' If \code{FALSE} (default), rows with unknown agents will be eliminated from the table.
#' @param vf boolean: Should input arguments be checked?
#' @return an object of class \code{OptimalTaskAllocator} with scheduling information added to the agent profile table (\code{obj$AP}).
#'
#' @export
feedAgentSchedule = function(obj, agentSCH, agentID_col = NULL, scheduled_col = NULL, utilFactor_col = NULL, feedNewAgents = F, vf = T){
  if(vf){
    verify(agentID_col    , 'character', domain = names(agentSCH), varname = 'agentID_col')
    verify(scheduled_col, 'character', domain = names(agentSCH), varname = 'scheduled_col', null_allowed = F)
    verify(utilFactor_col, 'character', domain = names(agentSCH), varname = 'utilFactor_col')
  }
  if(is.empty(agentSCH)){return(obj)}
  if(is.null(utilFactor_col)){
    utilFactor_col     = 'utilFactor'
    agentSCH$utilFactor = 1.0
  }
  
  if(!is.null(agentID_col)){
    agentSCH <- agentSCH[!duplicated(agentSCH[, agentID_col]),]
    rownames(agentSCH) <- agentSCH[, agentID_col]
    agentSCH[, agentID_col] <- NULL
  } else {
    niragen::assert(!is.null(rownames(agentSCH)), "Agent IDs should be aspecified as rownames of table 'agentSCH'!", match.call()[[1]])
  }
  
  agids = rownames(agentSCH)
  
  if(feedNewAgents){obj %<>% feedAgents(agids %-% obj$agents)} else {
    keep     = agids %in% obj$agents
    agentSCH = agentSCH[keep,]
    ndel     = sum(!keep)
    warnif(ndel > 0, ndel %++% ' records were removed because their agent IDs were not defined!')
    agids    = agids %^% obj$agents
  }
  
  obj$AP[agids, 'scheduled']  <- agentSCH[, scheduled_col]
  obj$AP[agids, 'utilFactor'] <- agentSCH[, utilFactor_col]
  
  return(obj %>% updateAgentUtilization)
}

#' Use this function to add agent-skill average turnaround time (processing time) data.
#'
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param ATT data.frame: Should contain list of agent turnaround times. This table specifies the average time each agent has spent on each skill (task type).
#' The table must contain agent IDs, skill ids and average processing time (turnaround time) values in minutes.
#' @param agentID_col single character: Specifies the column name containing agent(resource) IDs or names in the table passed o argument \code{ATT}.
#' Rows with new agents not in the agent profile, will be eliminamted.
#' @param skillID_col single character: Specifies the column name containing skill IDs or names in the table passed to argument \code{ATT}.
#' Rows with new skills not in the skill profile, will be eliminamted.
#' @param tat_col single character: Which column in table \code{TAT} contains average processing time values?
#' @return an object of class \code{OptimalTaskAllocator} with updated agent-skill processing time matrix (\code{obj$TAT}).
#'
#' @export
feedAgentTurnaroundTime = function(obj, ATT, agentID_col, skillID_col, tat_col){
  # todo: new skills/agents?
  if(is.empty(ATT)){return(obj)}
  # Verifications
  verify(ATT, 'data.frame', varname = 'ATT')
  verify(agentID_col, 'character', domain = names(ATT), lengths = 1, varname = 'agentID_col')
  verify(skillID_col, 'character', domain = names(ATT), lengths = 1, varname = 'skillID_col')
  verify(tat_col, 'character'  , domain = names(ATT), lengths = 1, varname = 'tat_col')
  
  ATT %<>% reshape2::dcast(as.formula(paste(agentID_col, '~', skillID_col)), value.var = tat_col, fun.aggregate = mean)
  rownames(ATT)    <- ATT[, agentID_col] %>% as.character
  ATT[, agentID_col] <- NULL
  agnts = obj$agents %^% rownames(ATT)
  sklls = obj$skills %^% colnames(ATT)
  obj$TAT[agnts, sklls] = ATT[agnts, sklls]
  obj$TAT[obj$TAT == 0] <- NA
  obj$AP$AUT = (obj$TAT %>% rowMeans(na.rm = T))
  obj$SP$AUT = (obj$TAT %>% colMeans(na.rm = T))
  
  obj %<>% updateAgentUtilization
  return(obj)
}
### 2- Adding computed data:

smartMapTaskPriorities = function(obj, n = 10){
  niragen::assert(!is.null(obj$TSK), "Task list (backlog data) is not fed!", match.call()[[1]])
  
  obj$TSK$priority <- smartMap(obj$TSK$priority, n = n)
  return(obj)
}

#' @export
calcAgentTAT = function(obj){
  niragen::assert(!is.null(obj$ACH), "Agent task count history data is not fed! Call method  feedAgentCountHistory() with data to feed first.", match.call()[[1]])
  niragen::assert(!is.null(obj$AUH), "Agent utilization history data is not fed! Call method  feedAgentUtilizationHistory() with data to feed first.", match.call()[[1]])
  
  agents           = obj$ACH$agentID %^% obj$AUH$agentID
  
  AHC.DateChar = as.character(obj$ACH$date)
  AR.DateChar  = as.character(obj$AUH$date)
  dates        = AHC.DateChar %^% AR.DateChar
  
  obj$ACH  = obj$ACH[(AHC.DateChar %in% dates) & (obj$ACH$agentID %in% agents),]
  obj$AUH = obj$AUH[(AR.DateChar %in% dates) & (obj$AUH$agentID %in% agents),]
  
  agents       = unique(obj$ACH$agentID)
  # Over all the agents: Average time spent on each task:
  landa = sum(obj$AUH$prodTime)/sum(obj$ACH$count)
  
  X = data.frame()
  
  #Generate agentSkillTable
  for (k in agents){
    cat('Agent ', k, ' started ... \n \n \n')
    
    ACHk = obj$ACH[obj$ACH$agentID == k,]
    ACHk = reshape2::dcast(ACHk, date ~ skill, mean, value.var = 'count')
    ACHk[is.na(ACHk)] <- 0
    rownames(ACHk) <- as.character(ACHk$date)
    ACHk = ACHk[, -1, drop = F]  # This is Count History matrix for agent k(casted matrix) and is the first input to function agentTaskTimeEstimate()
    
    ARk = obj$AUH[obj$AUH$agent == k,]
    rownames(ARk) <- as.character(ARk$date)
    
    a     = colSums(ACHk)
    b     = sum(ARk$prodTime)
    x0    = rep(landa, length(a))
    names(x0) <- names(a)
    xk    = findNearestVect(x0, a, b , lb = rep(landa, length(a)))
    warnif((sum(b) == 0) & (sum(a) > 0), paste("Agent ID", k, "had totally zero utilization time but has done", sum(a), "tasks! The global average skill has been set for this agent."))
    for (tsk in names(xk)){X[k, tsk] <- xk[tsk]}
  }
  
  obj$TAT[rownames(X), colnames(X)] = X
  
  obj$SP$AUT <- colMeans(obj$TAT, na.rm = T)
  obj$AP$AUT <- rowMeans(obj$TAT, na.rm = T)
  
  a = obj$ALC > 0
  a[is.na(a)]<- F
  t = obj$TAT
  t[!a] <- NA
  
  obj$AP$AUT.Allocated <- rowMeans(t, na.rm = T) # Average Turn-around time in allocated tasks for each agent
  obj$SP$AUT.Allocated <- colMeans(t, na.rm = T) # Average Turn-around time in allocated tasks for each skill
  
  return(obj)
}

#' This function runs the main task allocation engine. Call this function to distribute unallocated tasks to the agents (resources).
#'
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param prioritization single character: Specifies how task priorities change before being fed to the optimisation algorithm. Must be one of these options: \cr
#' \code{'ZFactorExponential'} (default): Standardise priority values to Z factors and map via exponential function. \cr
#' \code{'rankBased'}: Modifies priority values so that the minimum priority within a cluster is higher than sum of of all priorities in the next lower ranked cluster. \cr
#' \code{'timeAdjusted'}: Multiplies each task priority by the average processing time of its skill.
#' This conversion, eliminates the impact of average unit time in allocation and gives higher weight to task priorities rather than processing time.
#' Note: This option, leads to a sub-optimal task distribution, however,
#' ensures each task is allocated when all other tasks in the list with higher priorities are not left unallocated. \cr
#' @param silent single logical: If \code{FALSE}, consequent steps in task allocation will be shown on the console.
#' @param flt2IntCnvrsn single character: Specifies how optimal count of allocated tasks should be converted from float to integer. Must be one of these three options:
#' \code{ceiling}: Convert float values to the next higher integer
#' \code{round} (default): Convert float values to the closest integer
#' \code{floor}:  Convert float values to the next lower integer
#' @param fill_gap_time single logical: If \code{TRUE}, tries to find tasks to fill the gap time to increase utilisation. Default is \code{TRUE}.
#' @param Kf single numeric: Specifies weight of fairness of score sharing. Default is \code{0}
#' @param Ku single numeric: Specifies weight of balanced utilisation. Default is \code{0}
#' @return an object of class \code{OptimalTaskAllocator} with allocated tasks.
#'
#' @export
distributeTasks = function(obj, prioritization = 'ZFactorExponential', silent = F, ...){
  
  if(!silent){
    cat('Task allocation procedure started.', '\n')
    cat('Preparing data for allocation ...')
  }
  newt = obj$TSK[!obj$TSK$LO & obj$TSK$workable, ]
  
  # maxcnt = 0
  # for(e in unique(obj$TSK$agent) %>% na.omit){
  #   maxcnt = maxcnt + ceiling(obj$AP[e, 'productive'] / min(obj$TAT[e,], na.rm = T))
  # }
  #
  # newt = newt[order(newt$priority, decreasing = T)[min(maxcnt, nrow(newt)) %>% sequence], ]
  
  agentUtil        <- obj$AP$available
  names(agentUtil) <- obj$agents
  agentUtil0       <- obj$AP$reserved
  names(agentUtil0) <- obj$agents
  
  
  skills = newt$skill %-% names(which(colSums(!is.na(obj$TAT)) == 0))
  niragen::assert(length(skills) > 0, "No agent with required skills found!", match.call()[[1]])
  
  agents = obj$agents[which(agentUtil > 0)] %-% names(which(rowSums(!is.na(obj$TAT[, skills, drop = F])) == 0))
  niragen::assert(length(agents) > 0, "Not any agent with free time has the required skills!", match.call()[[1]])
  
  agentSkill  = obj$TAT[agents, skills, drop = F]
  taskBacklog = newt[newt$skill %in% skills,]
  agentUtil   = agentUtil[agents]
  agentUtil0  = agentUtil0[agents]
  agentScore0 = obj$AP[agents, 'score']
  names(agentScore0) = agents
  
  if(!silent){cat(' Done!', '\n')}
  
  taskBacklog %<>% optimTaskDistribute(aut = agentSkill, u0 = agentUtil0, u = agentUtil, as0 = agentScore0, prioritization = prioritization, silent = silent, ...)
  
  obj$TSK[rownames(taskBacklog), 'agent'] <- taskBacklog$agent
  
  # Adding count of Allocated, Loftovers and Assigned and Unallocateds to the Skill Profile and Agent Profile
  
  
  obj %<>% updateAgentUtilization %>% updateTaskCounts
  
  if(!silent){cat('Task allocation procedure ended.', '\n')}
  return(obj)
}

#' Corrects allocation of tasks by replacing some higher-priority unallocated tasks with lower-priority allocated ones.
#'
#' This treatment makes the allocation sub-optimal, but ensures higher priority tasks are not left unallocated.
#' Note that this treatment can leed to exceeding 100% utilization of some agents.
#' You can control this effect by argument 'autTolerance'.
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param autTolerance single numeric: Specifies maximum allowed tolerance in AUT time (in minutes).
#' Tasks are swapped only if the average unit times (AUT) difference between them
#' are lower than the value in this argument. Default value is 10 minutes.
#' @param show_progress single logical: If \code{FALSE}, progress is not shown in the console.
#' @return an object of class \code{OptimalTaskAllocator} with allocated tasks.
#'
#' @export
correctAllocation = function(obj, autTolerance = 10, show_progress = F){
  # For all allocated tasks, check and see if the agent can do any task with higher priority?
  obj$TSK = obj$TSK[order(obj$TSK$priority, decreasing = T),]
  al      = which(!is.na(obj$TSK$agent) & !obj$TSK$LO) %>% rev
  if(length(al) > 0){
    if(show_progress){
      cat('Correcting allocations for perfect priority alignment ...', '\n')
      pb = txtProgressBar(min = 0, max = length(al), style = 3)
      cnt = 0
    }
    N = length(al); i = 1; j = 1
    while((length(j) > 0) & i <= N){
      if(show_progress){cnt = cnt + 1; setTxtProgressBar(pb, cnt)}
      # pick a subset of unallocated tasks with priorities higher than task i:
      j = which(is.na(obj$TSK$agent) & !obj$TSK$LO & obj$TSK$priority > obj$TSK$priority[al[i]])
      if (length(j) > 0){
        e     = obj$TSK$agent[al[i]] # who is the agent?
        # what skill(s) he/she has which require almost equal time to the task he/she has been allocated?
        cando = obj$skills[obj$TAT[e, ] %>% niragen::equal(obj$TAT[e, obj$TSK$skill[al[i]]], tolerance = autTolerance) %>% which]
        # which of the unallocated tasks can be replaced with this task? Pick the one with highest priority:
        # jj contains index of the unallocated task with highest priority which can be done by the agent in question
        jj = j %^% which(obj$TSK$skill %in% cando) %>% first
        if(!is.na(jj)){
          # replace tasks:
          obj$TSK$agent[jj] = e
          obj$TSK$agent[al[i]]  = NA
        }
      }
      i = i + 1
    }
    if(show_progress){cat(' Done!', '\n')}
    obj %<>% updateAgentUtilization %>% updateTaskCounts
  } else {
    if(show_progress){
      cat('No task is left unallocated! Correction skipped.', '\n')
    }
  }
  return(obj)
}

genAgentUtilTimeSeries = function(obj){
  niragen::assert(!is.null(obj$AUH), "Agent history utilities data is not fed! Call method  feedAgentHistoryUtil() with data to feed first.", match.call()[[1]])
  
  v = reshape2::dcast(obj$AUH, date ~ agentID, mean, value.var = 'prodTime')
  
  TIME.SERIES(v, time_col = 'date')
}

# Bins the agent skill values (durations) to n bins based on quantiles
# If breaks are not unique, duplicated quantiles will be eliminated!
# For example if minimum, 1st Quartile and median are the same, then only min, 3rd quartile and max will remain as cut breaks.
binAgentSkills = function(obj, n = 4){
  if (is.null(obj$sklvl)){
    u = obj %>% getSkillMatrix %>% as.matrix %>% as.numeric
    q = quantile(u, probs = seq(0, 1, 1/n), na.rm = T) %>% unique
    niragen::assert(length(q) > 1, 'Number of bins too low!', err_src = match.call()[[1]])
    obj$sklvl = u %>% cut(breaks = q, labels = sequence(length(q) - 1)) %>%
      matrix(nrow = nrow(obj$skls), dimnames = list(rownames(obj$skls), colnames(obj$skls))) %>% as.data.frame
  }
  return(obj)
}

#' Clears allocation for the given object
#'
#' @param update single logical: Should tables agent profile \code{(obj$AP)}, skill profile \code{(obj$SP)} and allocation matrix \code{(obj$ALC)}
#' @return an object of class \code{OptimalTaskAllocator} with allocated tasks.
#' be updated?
#'
#' @export
clearAllocation = function(obj, update = T){
  tbc = which(!obj$TSK$LO & !is.na(obj$TSK$agent))
  if(length(tbc) > 0){
    obj$TSK[tbc, 'agent'] = NA
    if(update){obj %<>% updateAgentUtilization %>% updateTaskCounts}
  }
  return(obj)
}

#' @export
shuffle = function(obj){
  # make a copy of the tasks:
  TSK = obj$TSK[obj$TSK$workable & !obj$TSK$LO & !is.na(obj$TSK$agent),]
  
  for(NN in unique(TSK$AUT)){
    alNN = which(TSK$AUT == NN)
    APNN = TSK[alNN,] %>% group_by(agent) %>% summarise(count = length(agent)) %>% as.data.frame %>% column2Rownames('agent')
    #skills involved in alNN group:
    sk = TSK[alNN, 'skill'] %>% unique
    # agents involved in alNN group:
    ag = TSK[alNN, 'agent'] %>% unique
    
    TSK$agent[alNN] = NA
    for (agi in ag){
      # For agent agi:
      # Which skills among the tasks in group alNN does this agent have?
      subsk = obj$skills[which(obj$TAT[agi, ] == NN)] %^% sk
      # take unallocated tasks with skills in subsk:
      tl = TSK[TSK$skill %in% subsk & is.na(TSK$agent),]
      tlids = rownames(tl)
      # How many tasks can this agent have? APNN[agi, 'count']
      # choose APNN[agi, 'count'] tasks from alNN randomly to give to agi:
      tsk4agi = sample(tlids, size = min(length(tlids), APNN[agi, 'count']))
      # allocate these tasks to agi:
      TSK[tsk4agi, 'agent'] <- agi
    }
  }
  
  obj$TSK[rownames(TSK), 'agent'] = TSK$agent
  
  obj %>% updateAgentUtilization %>% updateTaskCounts
  
}

#' @export
forceAllocation = function(obj){
  TL = obj$TSK[which(is.na(obj$TSK$agent) & (!obj$TSK$LO) & obj$TSK$workable),]
  ord = order(TL$priority, decreasing = T)
  for (i in ord){
    # cat(i, '-')
    # which agents are able to do it?
    ag = rownames(obj$TAT)[which(!is.na(obj$TAT[, TL$skill[i]]))]
    # which agents have time?
    ag = ag[which(obj$AP[ag,'available'] > obj$TAT[ag, TL$skill[i]])]
    if(length(ag) > 1){
      # Among these agents, which one(s) has the lowest score?
      minscore = min(obj$AP[ag, 'score'])
      ag = ag[which(obj$AP[ag, 'score'] == minscore)]
    }
    # if more than one agent have lowest scores, which of them is the fastest?
    if(length(ag) > 1){
      mintime = min(obj$TAT[ag, TL$skill[i]])
      ag = ag[which(obj$TAT[ag, TL$skill[i]] == mintime)][1]
    }
    # Allocate the task to the agent:
    if(length(ag) == 1){
      obj$TSK$agent[i] <- ag
      # Correct available time:
      obj$AP[ag, 'available'] = obj$AP[ag, 'available'] - obj$TAT[ag, TL$skill[i]]
      obj$AP[ag, 'utilized']  = obj$AP[ag, 'utilized'] + obj$TAT[ag, TL$skill[i]]
      obj$AP[ag, 'score']     = obj$AP[ag, 'score']    + obj$TSK[i, 'score']
    }
  }
  
  return(obj %>% updateAgentUtilization %>% updateTaskCounts)
}




# Header
# Filename:      otatools.R
# Version   Date               Action
# -----------------------------------
# 1.0.0     25 January 2017    Initial issue renamed from wfo.tools.R
# 1.0.1     27 July 2017       Function taskSummary2TaskList() modified: timediff objects converted to numeric!
# 1.0.2     28 July 2017       Function customizeTaskPriorities() modified: Priorities are scaled and converted by exponential function
# 1.0.3     28 July 2017       Function optimTaskDistribute() modified: Priority level is now based on logarithm of task priorities
# 1.0.4     21 August 2017     Function customizeTaskPriorities() modified: Rounding priorities to 2 digits deactivated to avoid changing very small values to zero
# 1.1.0     21 August 2017     Function balanceAgentUtilization() added: Re-distributed the tasks to balance utilization time. Requires a bit  more work!
# 1.1.1     21 August 2017     Function balanceAgentUtilization() works reliably: Just need to take care of a few unallocated tasks due to rounding non-integer allocation values to integer
# 1.1.3     21 August 2017     functions distVertical() and distHorizontal() added: Currently only distVertical() is used for task allocation
# 1.1.4     22 August 2017     functions balanceAgentUtilization() modified: A big bug is rectified! Used to allocate tasks to agents with no productive time. Maximum available time added as an inequality constraint to the quadratic optimization model.
# 1.1.6     31 August 2017     An important bug rectified: Could not allocate in case there is only one skill and one priority level. Functions optimTaskDistribute() and optimTaskDistribute.LP() modified.
# 1.2.0     20 September 2017  Uses clustering to determine priority level
# 1.2.1     21 September 2017  function customizeTaskPriorities() modified again: removes exponential change
# 1.2.2     25 September 2017  function optimTaskDistribute() modified: tl$priority is computed as exponentials of Z factors to avoid large values
# 1.2.3     26 September 2017  function balanceAgentUtilization() modified: A small problem rectified: When re-distributing for each skill, agents with zero available time were be eliminated even though they had been allocated some tasks of the skill for which re-distribution is being implemented!
#                              Now, if an agent is allocated with at least one task of the skill for which we want to redistribute, that agent is included for re-distribution even though his/her available time is zero!
# 1.3.0     05 October 2017    function optimTaskDistribute() modified: A new method of priority mapping is introduced:
#                              Argument prioritization added specifying priority mapping method. Two options are:
#                              'ZFactorExponential' (default) and 'rankBased' in which the priority of each rank is higher than sum of priorities of all tasks in the lower rank
# 1.3.1     09 October 2017    function optimTaskDistribute() modified: Skips clustering if all priorities are equal (single cluster)
# 1.3.2     09 October 2017    function optimTaskDistribute() modified: Bug fixed! Clustering and static split come to unique prLevels and Cluster centers (CCenters)
# 1.3.3     09 October 2017    function optimTaskAllocate.LP() modified: Bug fixed! When there is only one skill-priority level, the matrix changed class to numeric! Problem fixed!
# 1.3.4     10 October 2017    All agent_col arguments renamed to agentID_col, all skill_col renamed to skillID_col.
# 1.3.5     14 November 2017   Function taskSummary2TaskList() modified: Argument 'prefix' added.
# 1.3.6     28 November 2017   Function customizeTaskPriorities() removed!
# 1.3.8     08 January 2018    Function optimTaskAllocate.NLP() added: Non-linear programming optimization added to maximize a non-linear weigheted ojective function based on: Fairness of allocation and Balanced Utilization percentage
# 1.3.9     09 January 2018    Function optimTaskDistribute() modified: Non-linear optimization is called when coefficients Kf and/or Ku are non-zero
# 1.4.0     11 January 2018    Function optimTaskAllocate.NLP() modified: Added appropriate weghting to the main objective function
# 1.4.2     19 January 2018    Function optimTaskAllocate.NLP() modified: Balances score rates rather than absolute score values. Score rate: score per minute = total score/total scheduled time (if the denominator is utilized time, it would be better but adds much complexity)
# 1.4.3     19 January 2018    Function optimTaskAllocate.NLP() modified: floors all the allocations rather than round.
# 1.4.4     19 January 2018    Function optimTaskDistribute() modified: Corrects allocations by balancing score rates to improve fairness
# 1.4.5     25 January 2018    Function optimTaskAllocate.NLP() modified: Respects scores and utilization time from pre-allocated tasks in calculating score rates. Two input arguments added.
# 1.4.6     25 January 2018    Function dist.vertical() modified: Allocates some unallocated tasks if any time is left
# 1.4.7     29 January 2018    Function optimTaskAllocate.NLP() modified: A warning added when non-linear optimisation fails for any reason!
# 1.4.8     30 January 2018    Function dist.vertical() modified: A bug rectified: free agent time (variables utt and frt) are now being updated in the loop
# 1.4.9     19 February 2018   Function optimTaskDistribute() modified: In the post allocation correction, takes care of the bug when scj is empty
# 1.5.0     19 February 2018   Function optimTaskDistribute() modified: Uses multiplication of score rate and utilisation rate as objective value to be balanced for the post allocation algorithm
# 1.5.1     07 March 2018      Function swapImpact() added: returns the impact of swapping two tasks on the variance of the total agent weighted scores
# 1.5.2     08 March 2018      Function balanceWeightedScores() added. Minimizes variance of weighted Scores distributed among the agents
# 1.5.3     08 March 2018      Function optimTaskDistribute() does not require argument ss to be passed by its caller optimTaskDistribute(). Calculates ss(skill scores) itself from tasklist scores.
# 1.5.5     09 March 2018      Functions swapImpact() and balanceWeightedScores() modified: A bug rectified. Thre was an error in calculating the impact of swapping tasks on the variance of the weighted scores
# 1.5.6     12 March 2018      Functions optimTaskDistribute() modified: rankBased prioritization changed. priorities are sent to smartMap to be mapped to range (0,1)
# 1.5.7     13 March 2018      Functions optimTaskDistribute() modified: timeAdjusted prioritization added.
# 1.5.8     10 April 2018      Functions optimTaskAllocate.NLP() and optimTaskAllocate.LP() modified. A bug removed: Used for loop to build tmr vector rather than using diag() function which sometimes runs memory error if the built matrix is huge
# 1.5.9     10 April 2018      Functions balanceWeightedScores() modified: Argument Ksa added to balance the average scores rather than score rates
# 1.6.0     04 May 2018        Functions optimTaskAllocate.NLP() renamed to optimTaskAllocate(): Runs non-linear optimisation if either Kf or Ku are non-zero
# 1.6.1     05 May 2018        Functions optimTaskDistribute() modified: If clustering fails, binning is applied to the Z factors of the property rather than to itself. split points changed
# 1.6.2     28 May 2018        Argument 'silent' added to function optimTaskDistribute() to show consequent steps of allocation. The argument is passed to function distVertical(). Todo: should be passed to function optimTaskAllocate() as well.
# 1.6.3     28 May 2018        Arguments 'fill_gap_time' and 'flt2IntCnvrsn' can now be transferred from function distributeTasks(). 'fill_gap_time' is disabled if 'flt2IntCnvrsn' is set to 'ceiling'.
# 1.6.4     05 June 2018       Function distVertical() modified: skips filling gap time procedure if all tasks are allocated.
# 1.6.5     09 July 2018       Function optimTaskDistribute() modified: Argument 'swap' added. Skips swapping the tasks after allocation for unweighted score rate and utilisation balancing if argument 'swap' is FALSE.
# 1.6.6     09 July 2018       Documentation added for function balanceWeightedScores()
# 1.6.8     10 July 2018       Functions balanceWeightedScores() and swapImpact() modified: Argument Ksv added for sum of score variability metric
# 1.7.0     11 July 2018       Functions balanceWeightedScores() and swapImpact() modified: Argument max_utilization added


if (!require(niragen)){
  cat(paste("\n", "Package 'niragen' is not available! Please install it before using 'otar'!", "\n", "\n"))
  stop()
}

niragen::support('magrittr','tibble', 'dplyr', 'reshape2')

# This function computes the average time required for each task by one agent
# input 1: Count of tasks completed by the agent in each day
# input 2: total time spent for the tasks on each day for the agent or Productive Time per day (in seconds)
# output: returns a named vector (same colnames of given table taskCount) containing average time spent by each agent
agentTaskTimeEstimate = function(taskCount, prodTime, dateColName = 'Date'){
  # Verifications:
  # Check taskCount and prodTime are numeric matrices
  # Check the rownames of both taskCount and prodTime are convertible to Date
  # Make sure Date column does not have any duplicated values
  # Make sure number of common dates are sufficient (higher than # columns of taskCount)
  # Make sure the first column of 'prodTime' is a numeric column. This column contains task time (usually in seconds)
  n = dim(taskCount)[1]
  m = dim(taskCount)[2]
  
  dates = rownames(prodTime) %^% rownames(taskCount)
  
  b = as.numeric(prodTime[dates, 1])
  A = as.matrix(taskCount[dates, ])
  
  # A.inv = ginv(A)
  # x0 = A.inv %*% b
  
  eval_f <- function( x ) {
    f = A %*% x - b
    return( list( "objective" = sum(f^2),
                  "gradient"  = 2*(t(A) %*% f)))
  }
  
  local_opts <- list( "algorithm" = "NLOPT_LD_MMA",
                      "xtol_rel" = 1.0e-7 )
  opts <- list( "algorithm" = "NLOPT_LD_AUGLAG",
                "xtol_rel" = 1.0e-7,
                "maxeval" = 1000,
                "print_level" = 1,
                "local_opts" = local_opts )
  
  x0 = rep(max(sum(b)/sum(A), 100), m)
  
  res = nloptr( x0 = x0, eval_f = eval_f, eval_grad_f = eval_grad_f, lb = rep(100,m), opts = opts)
  x   = res$solution
  names(x) <- names(taskCount)
  return(x)
}


# Given:
#   matrix  F (n x m) (Frequencies),
#   matrix  S (n x m)(Speed),
#   vector  w (k) (Priority Weights) = 1/rank
#   vector  t (k) tasks types
#   vector  u (n) (total utilization time)
# Where:
# m: Number of task types/skilles/ques
# n: Number of agents
# k: Number of tasks/WIMs/activities
# Step 1: find matrix X (n x m) (Allocations)
# Step 2: Distribute X[each agent, each task] through the tasks

# to Maximize: sigma colSums(X) or
# to maximize coverage: sum(X)
#
# subject to:  rowSums(X/S) <= u
# and:         rowSums(F^2)*rowSums(X^2) = rowSums(X*F)^2
# and:         X[is.na(F)] = 0
# and:         0 < X[, j] <= B[j] where B[j] = sum[t == j]
optimTaskAllocate.simple = function(FF,SS, ww, util){
  assert(identical(is.na(FF), is.na(SS)), "Given matrices FF and SS are not compatible!")
  agents = rownames(SS)
  skills = colnames(SS)
  tasks  = cbind(id = seq(tt), type = tt, priority = ww)
  tasks  = tasks[order(tasks[, 'priority'], decreasing = T),]
  assert(skills %==% colnames(SS))
  
  # This gives agents for each task sorted by their skill:
  task.skilled = t(apply(SS, 2, function(x){agents[order(x, decreasing = T)]}))
  AGENT = list()
  avail = rep(T, length(agents))
  names(avail) <- agents
  for (i in agents){AGENT[[i]] = list(q = numeric(), t = 0)}
  nTask = nrow(tasks)
  i     = 0
  while ((i < nTask) & (sum(avail) > 0)){
    i = i + 1
    cat(i, '...')
    # Find the most skillful agent:
    f = !is.na(TT[,tasks[i, 'type']]) & avail
    if (sum(f) > 0){
      a = names(which(avail[task.skilled[tasks[i,'type'], ]])[1])
      AGENT[[a]]$q = c(AGENT[[a]]$q, tasks[i,'id'])
      AGENT[[a]]$t = AGENT[[a]]$t + TT[a, tasks[i, 'type']]
      avail[a]     =  AGENT[[a]]$t < util[a]
    }
  }
  return(AGENT)
  # rn  = integer()
  # cn  = integer()
  # XX  = matrix()
  # cnt = 0
  # for (i in nrow(FF)){
  #   for (j in ncol(FF)){
  #     if(!is.na(FF[i,j])){
  #       cnt = cnt + 1
  #       rn[cnt] = i
  #       cn[cnt] = j
  #       XX[i,j] = cnt
  #     }
  #   }
  # }
  
}

# scores : skill scores: Conversion Rate, probability of customer outcome
# as0    : total agent scores coming from pre-allocated(leftover) tasks
# util0  : total agent utilized time from pre-allocated(leftover) tasks
# util   : total agent available time
# Assert that names(as0), names(util), rownames(TT) and names(as0) are identical.

optimTaskAllocate = function(TT, tasks, util0, util, scores0, scores, Ku = 0, Kf = 0, Ks = 0, flt2IntCnvrsn = 'round'){
  agents = rownames(TT)
  skills = colnames(TT)
  tasks  = tasks[order(tasks[, 'priority'], decreasing = T),]
  
  n = length(agents)
  m = length(skills)
  
  SW = aggregate(priority ~ skill, data = tasks, FUN = mean)
  sw = SW$priority
  names(sw) <- SW$skill
  
  p   = sum(!is.na(TT)) # Number of unknown variables to be determined through optimization
  sp  = sequence(p)
  x   = rep(0,p) # vector of unknown variables pre-filled by zeros
  VN  = TT
  VN[!is.na(TT)] <- sp # matrix returning variable number given row number and column number
  I   = matrix(sequence(m*n), nrow = n, dimnames = list(agents, skills)) # matrix of variable indexes (returns variable index given row number and column number)
  iu  = I[!is.na(TT)] # vector returning index given the variable number
  rnu = agents[rep(sequence(n),m)] # vector returning row number given variable index
  cnu = c()
  for (i in sequence(m)){cnu = c(cnu, rep(i, n))} # vector returning column number given variable index
  cnu = skills[cnu]
  rn  = rnu[iu[sp]] # vector returning row    number given variable number
  cn  = cnu[iu[sp]] # vector returning column number given variable number
  
  # Check for i in 1:p    VN[rn[i], cn[i]] = i
  
  tms = numeric()
  for(ii in sp){tms[ii] = TT[rn[ii], cn[ii]]}
  
  const.mat.1 = matrix(rep(tms, n), nrow = n, byrow = T, dimnames = list(agents, paste(rn[sp], cn[sp], sep = '-')))
  for (i in agents){
    const.mat.1[i, which(rn[sp] != i)] <- 0
  }
  const.mat.2 = matrix(1, nrow = m, ncol = p, dimnames = list(skills, colnames(const.mat.1)))
  for (i in skills){
    const.mat.2[i, which(cn[sp] != i)] <- 0
  }
  
  const.rhs.2 = rep(0, m)
  names(const.rhs.2) <- skills
  tbl = table(tasks$skill)
  const.rhs.2[names(tbl)] <- tbl
  
  support('lpSolve')
  res = lp(direction = "max", objective.in = sw[cn[sp]], const.mat = rbind(const.mat.1, const.mat.2),
           const.dir = rep("<=", n + m), const.rhs = c(util, const.rhs.2))
  
  if((Kf != 0) | (Ku != 0)){
    # Allocation for Fairness
    convrate = scores %>% verify('numeric', lengths = m, default = rep(1.0, m), varname = 'scores')
    names(convrate) = skills
    crext = convrate[cn[sp]] %>% unname
    swext = sw[cn[sp]] %>% unname
    const.mat = rbind(const.mat.1, const.mat.2)
    const.rhs = c(util, const.rhs.2)
    PWC0  = sum(res$solution*swext)
    ec0   = numeric()
    
    for (j in agents){
      cnt = VN[j, skills] %>% na.omit %>% as.integer
      xx0 = res$solution[cnt]
      ec0[j] = (sum(xx0*crext[cnt]) + scores0[j])/(util[j] + util0[j])  # This is nothing but the score rate
    }
    
    ec0bar = mean(ec0)
    Ff0    = mean((ec0 - ec0bar)^2)
    
    
    objFunList   = function(x, Ku = 0, Kf = 0){
      # Priority Weighted Coverage:
      
      PWC   = sum(x*swext)/PWC0
      PWC_G = swext/PWC0
      
      eco = numeric()
      UUU = numeric()
      
      for (j in agents){
        cnt = VN[j, skills] %>% na.omit %>% as.integer
        xxx = x[cnt]
        eco[j] = (sum(xxx*crext[cnt]) + scores0[j])/(util[j] + util0[j])
        UUU[j] = (sum(xxx*tms[cnt]) + util0[j])/(util[j] + util0[j])
      }
      ecobar = mean(eco)
      UUUbar = mean(UUU)
      
      # Fairness:
      Ff   = mean((eco - ecobar)^2)/Ff0
      Ff_G = 2*crext*(eco[rn[sp]] - ecobar)/(n*Ff0*(util[rn[sp]] + util0[rn[sp]]))
      
      # Balanced Utilization:
      Fu   = mean((UUU - UUUbar)^2)
      Fu_G = 2*tms*(UUU[rn[sp]] - UUUbar)/(n*util[rn[sp]])
      
      list(objective = Ku*Fu + Kf*Ff - PWC, gradient = Ku*Fu_G + Kf*Ff_G - PWC_G)
    }
    
    objFunDetail = function(x, Ku = 0, Kf = 0){
      PWC   = sum(x*swext)/PWC0
      PWC_G = swext/PWC0
      
      eco = numeric()
      UUU = numeric()
      
      for (j in agents){
        cnt = VN[j, skills] %>% na.omit %>% as.integer
        xxx = x[cnt]
        eco[j] = (sum(xxx*crext[cnt]) + scores0[j])/(util[j] + util0[j])
        UUU[j] = (sum(xxx*tms[cnt]) + util0[j])/(util[j] + util0[j])
      }
      ecobar = mean(eco)
      UUUbar = mean(UUU)
      
      # Fairness:
      Ff   = mean((eco - ecobar)^2)/Ff0
      Ff_G = 2*crext*(eco[rn[sp]] - ecobar)/(n*Ff0*(util[rn[sp]] + util0[rn[sp]]))
      
      # Balanced Utilization:
      Fu   = mean((UUU - UUUbar)^2)
      Fu_G = 2*tms*(UUU[rn[sp]] - UUUbar)/(n*util[rn[sp]])
      
      list(Objective = PWC - Kf*Ff - Ku*Fu, SUM = sum(x), PWC = sum(x*swext), Fu = Fu, Ff = Ff, ECO = eco, Util = UUU)
    }
    
    inqFunList  = function(x, Ku = 0, Kf = 0){
      list(constraints = (const.mat %*% x - const.rhs) %>% as.numeric, jacobian = const.mat)
    }
    
    support('nloptr')
    fit = try(nloptr(x0 = res$solution,
                     eval_f = objFunList,
                     lb = rep(0.0, length(x)),
                     eval_g_ineq = inqFunList,
                     opts = list(algorithm = "NLOPT_LD_MMA", check_derivatives = F, maxeval = 200, maxtime = 10),
                     Kf = Kf, Ku = Ku), silent = T)
    
    if(inherits(fit, 'nloptr')){
      fitsol = fit$solution}
    else {
      warnif(T, 'Non-linear Optimisation failed!' %++% as.character(fit) %++% 'Linear programming method used instead. Non-linear objectives are ignored!')
      fitsol = res$solution}
    
    sol    = fitsol
    
  } else {sol = res$solution}
  
  flt2IntCnvrsn %<>% verify('character', domain = c('floor', 'round', 'ceiling'), default = 'round')
  if(flt2IntCnvrsn == 'round'){sol %<>% round} else if (flt2IntCnvrsn == 'floor'){sol %<>% round} else if(flt2IntCnvrsn == 'ceiling'){sol %<>% ceiling}
  
  # if(avucr){ # Forces satisfaction of utilization constraint after rounding: Avoid violation of utilization constraint due to rounding AVUCR
  #   fitinq = sol %>% inqFunList
  #   thr    = 0 # threshould
  #   cns    = sequence(n) # floor rather than round to make sure these constraints are satisfied
  #   while (sum(fitinq$constraint[cns] >= 1) > 0 & thr < 1){
  #     thr = thr + 0.1
  #     w = which(fitsol - floor(fitsol) < thr)
  #     sol = fitsol
  #     sol[w] <- floor(sol[w])
  #     sol    <- round(sol)
  #     fitinq = sol %>% inqFunList
  #   }
  # }
  #
  
  return(sol[VN] %>% matrix(nrow = n, dimnames = list(agents, skills)))
}

optimTaskAllocate.LP  = function(TT, tasks, util){
  agents = rownames(TT)
  skills = colnames(TT)
  tasks  = tasks[order(tasks[, 'priority'], decreasing = T),]
  
  n = length(agents)
  m = length(skills)
  
  SW = aggregate(priority ~ skill, data = tasks, FUN = mean)
  sw = SW$priority
  names(sw) <- SW$skill
  
  p   = sum(!is.na(TT)) # Number of unknown variables to be determined through optimization
  sp  = sequence(p)
  x   = rep(0,p) # vector of unknown variables pre-filled by zeros
  VN  = TT
  VN[!is.na(TT)] <- sp # matrix returning variable number given row number and column number
  I   = matrix(sequence(m*n), nrow = n, dimnames = list(agents, skills)) # matrix of variable indexes (returns variable index given row number and column number)
  iu  = I[!is.na(TT)] # vector returning index given the variable number
  rnu = agents[rep(sequence(n),m)] # vector returning row number given variable index
  cnu = c()
  for (i in sequence(m)){cnu = c(cnu, rep(i, n))} # vector returning column number given variable index
  cnu = skills[cnu]
  rn  = rnu[iu[sp]] # vector returning row    number given variable number
  cn  = cnu[iu[sp]] # vector returning column number given variable number
  
  # Check for i in 1:p    VN[rn[i], cn[i]] = i
  
  # tms         = diag(TT[rn[sp], , drop = F][,cn[sp], drop = F])
  tms = numeric()
  for(ii in sp){tms[ii] = TT[rn[ii], cn[ii]]}
  
  const.mat.1 = matrix(rep(tms, n), nrow = n, byrow = T, dimnames = list(agents, paste(rn[sp], cn[sp], sep = '-')))
  for (i in agents){
    const.mat.1[i, which(rn[sp] != i)] <- 0
  }
  const.mat.2 = matrix(1, nrow = m, ncol = p, dimnames = list(skills, colnames(const.mat.1)))
  for (i in skills){
    const.mat.2[i, which(cn[sp] != i)] <- 0
  }
  
  const.rhs.2 = rep(0, m)
  names(const.rhs.2) <- skills
  tbl = table(tasks$skill)
  const.rhs.2[names(tbl)] <- tbl
  
  res = lp(direction = "max", objective.in = sw[cn[sp]], const.mat = rbind(const.mat.1, const.mat.2),
           const.dir = rep("<=", n + m), const.rhs = c(util, const.rhs.2))
  X = res$solution[VN] %>% round %>% matrix(nrow = n, dimnames = list(agents, skills))
  return(X)
}

# aut: agent-skill matrix
# u  : agents' available time for new tasks
# u0 : agents' reserved time for leftover(pre-allocated) tasks
# ss0: agents' pre-allocated scores
# ss : skill scores
optimTaskDistribute = function(tl, aut, u0, u, as0, Ku = 0, Kf = 0, prioritization = 'ZFactorExponential', silent = F, flt2IntCnvrsn = 'round', fill_gap_time = T, swap = F){
  if(!silent){cat('Clustering priority levels ...')}
  aut %<>% as.matrix
  
  tl$skill  %<>% as.character
  tl$taskID <- rownames(tl)
  
  agents = names(u) %^% rownames(aut)
  skills = tl$skill %^% colnames(aut)
  
  aut  = aut[agents, skills, drop = F]
  tl   = tl[tl$skill %in% skills,]
  u    = u[agents]
  
  #
  MNC = tl$priority %>% table %>% length %>% min(25)
  if (MNC > 1){
    res = try(suppressWarnings(tl$priority %>% elbow(MNC, doPlot = F)), silent = T)
    if(inherits(res, c('try-error', 'NULL'))){
      rng = max(tl$prLevel) - min(tl$prLevel)
      tl$prLevel = cut(tl$priority %>% scale, breaks = c(-Inf,-3, -2, -1, 0, 1, 2, 3, Inf)) %>% as.factor %>% droplevels %>% as.numeric
      CCenters   = aggregate(tl$priority, by = list(tl$prLevel), FUN = mean)$x
    } else {
      tl$prLevel = res$clst[[res$bnc]]$cluster
      CCenters   = res$clst[[res$bnc]]$centers
    }
    
    if(prioritization == 'rankBased'){
      nt = tl$prLevel %>% table
      pv = numeric()
      ord = CCenters %>% order
      nc  = length(CCenters)
      for(j in sequence(nc)){
        if(j == 1){pv[ord[j]] = 0.0000001} else {
          pv[ord[j]] = pv[ord[j-1]]*nt[ord[j-1]] + 0.0000001
        }
      }
      tl$priority = pv[tl$prLevel] %>% smartMap(n = 25)
    } else if (prioritization == 'ZFactorExponential'){
      tl$priority = CCenters[tl$prLevel] %>% scale %>% as.numeric %>% exp
    } else if(prioritization == 'timeAdjusted'){
      skillaut = aut %>% colMeans(na.rm = T) %>% na2zero
      tl$AUT = skillaut[tl$skill]
      tl$priority = smartMap(tl$priority, n = 25)*tl$AUT
    }
    else {stop('Given prioritization not known!')}
  } else {
    tl$prLevel  = 1
    tl$priority = 1.0
  }
  tl$tsktp   = tl$skill
  tl$skill   = paste(tl$prLevel, tl$tsktp, sep = '-') %>% as.factor
  tType <- data.frame(tsktp = tl$tsktp, skill = tl$skill, stringsAsFactors = F) %>% distinct(skill, .keep_all = T) %>% column2Rownames('skill')
  # vTAT  <- matrix(nrow = length(agents), ncol = nrow(tType), dimnames = list(agents, rownames(tType)))
  vTAT  <- aut[agents, tType$tsktp, drop = F] %>% as.matrix
  vSkills    = rownames(tType)
  colnames(vTAT) <- vSkills
  
  SC = tl %>% group_by(skill) %>% summarise(score = mean(score)) %>% as.data.frame
  ss = SC$score; names(ss) <- SC$skill
  
  if(!silent){cat(' Done!', '\n', 'Run optimization engine ...')}
  
  AT = optimTaskAllocate(TT = vTAT, tasks = tl, util0 = u0, util = u, scores0 = as0, scores = ss, Kf = Kf, Ku = Ku, flt2IntCnvrsn = flt2IntCnvrsn)
  
  if(!silent){cat(' Done!', '\n')}
  
  scores = ss # Virtual-Skill Scores
  # Loop start:
  
  if(swap){
    if(!silent){cat('Swapping tasks for unweighted simultaneous score rate and utilisation balancing ...')}
    # Initial values of metrics:
    utt = rowSums(AT*vTAT, na.rm = T)  # total utilized time
    utr = (utt+u0)/(u + u0)
    frt = u - utt
    tsc = apply(AT, 1, function(x) {ss = x*scores; return(ss %>% sum(na.rm = T))}) + as0 # Total Scores new allocated to each agent + pre-allocated scores
    # scr = sort(tsc/(utt + u0), decreasing = T) #  Score Rates for each agent
    scr = tsc/(u + u0)  #  Score Rates for each agent
    obf = sort(scr*utr, decreasing = T) #  Value of the objective function for each agent (sorted descending)
  }
  
  allowed = swap
  while(allowed){
    sdobf = sd(obf)
    j = names(obf)[1]
    scj = (AT[j, ] > 0)*scores*vTAT[j,]
    scj = scj[!is.na(scj) & scj > 0] %>% sort(decreasing = T) # scj cannot be empty. (can it?) Yes it can be! If all tasks are taken from an agent and that agent still has the highest score rate due to high scored pre-allocated (leftover) tasks, this can happen!
    if(length(scj) > 0){
      hvsj = names(scj)[1] # is the v-skill with the highest score allocated to agent j (Highest Virtual Skill j)
      avag = scr[which(vTAT[, hvsj] > 0 & frt >= vTAT[, hvsj]) %>% names] %>% sort %>% names  # Which agents can also do this vskill and have free time to do it (sorted ascending by score rate currently gained)?
      if (length(avag) > 0){
        nttj  = min(AT[j, hvsj], length(avag)) # Number of tasks taken from agent j to be re-distributed
        nttjs = sequence(nttj)
        AT[j, hvsj] = AT[j, hvsj] - nttj # Take nttj tasks from agent j
        AT[avag[nttjs], hvsj] = AT[avag[nttjs], hvsj] + 1 # add one task to nttj agents each
        # cat(nttj, ' tasks taken from ', j, ' given to: ', paste(avag[nttjs], collapse = ' & '), ' sd = ', sdscr ,'\n')
        # Update metrics:
        utt = rowSums(AT*vTAT, na.rm = T)  # utilized time
        utr = (utt+u0)/(u + u0)
        frt = u - utt
        tsc = apply(AT, 1, function(x) {ss = x*scores; return(ss %>% sum(na.rm = T))}) + as0 # Total Scores for each agent
        # scr = sort(tsc/(utt + u0), decreasing = T)  # Score Rates for each agent
        scr = tsc/(u + u0)  #  Score Rates for each agent
        obf = sort(scr*utr, decreasing = T) #  Value of the objective function for each agent (sorted descending)
      }
    }
    allowed = sd(obf) < sdobf
  }
  
  # Todos: Leftover scores are not computed ... Done!
  # Todos: Leftover utilization is not respected in the rates ... Done!
  # Todos: Balancing utilization must be parallel (respecting leftovers) ... Done!
  
  if(!silent & swap){cat(' Done!', '\n')}
  
  return(tl %>% distVertical(AT, agents, vSkills, vTAT, u0, u, as0, scores, fill_gap_time = fill_gap_time, silent = silent))
  # avl = (x$AP[, 'available', drop = F] %>% toVectorList)[['available']]
  # return(tl %>% distHorizontal(AT, agents, vSkills, vTAT, avl))
}

distVertical = function(tl, AT, agents, vSkills, vTAT, u0, u, as0, scores, fill_gap_time = T, silent = F){
  if(!silent){cat('Distributing skills among agents ...')}
  tl$agent = NA
  for (j in vSkills){
    for (i in agents[order(vTAT[,j], na.last = NA)]){
      if (AT[i,j] > 0){
        ind = which(tl$skill == j & is.na(tl$agent))
        prs = tl$priority[ind]
        ord = order(prs, decreasing = T)
        tba = ind[ord[sequence(AT[i,j])]] %>% na.omit #Indexes of tasks 2b allocated to agent i
        tl[tba, 'agent'] <- i
      }
    }
  }
  
  if(!silent){cat(' Done!', '\n')}
  
  # Additional allocations to fill remained time:
  if(fill_gap_time){
    tl$skill %<>% as.character
    
    tl2 = tl[is.na(tl$agent),]
    
    nrtl2 = nrow(tl2)
    
    if(nrtl2 > 0){
      if(!silent){
        cat(' Additional allocations to fill gap time ...', '\n')
        pb = txtProgressBar(min = 0, max = nrow(tl2), style = 3)
        cnt = 0
      }
      
      tl2 = tl2[order(tl2$priority, decreasing = T),]
      for(i in nrtl2 %>% sequence){
        if(!silent){cnt = cnt + 1; setTxtProgressBar(pb, cnt)}
        # Who can do task i?
        utt = rowSums(AT*vTAT, na.rm = T)  # utilized time
        frt = u - utt
        cando = which(vTAT[, tl2$skill[i]] < frt) %>% names
        if(length(cando) > 0){
          # What is the value of fairness(the objective) if any of these agents do task i?
          tsc = apply(AT, 1, function(x) {ss = x*scores; return(ss %>% sum(na.rm = T))}) + as0 # Total Scores for each agent
          obval = numeric()
          for(ag in cando){
            tscag = tsc
            tscag[ag] = tscag[ag] + scores[tl2$skill[i]]
            scrag     = sort(tscag/(u + u0), decreasing = T)  # Score Rates for each agent when agent ag has been given task i
            obval     = c(obval, sd(scrag))
          }
          names(obval) = cando
          
          winner = (obval %>% sort %>% names)[1]
          # Allocate task i to the winner:
          tl2[i, 'agent'] = winner
          AT[winner, tl2$skill[i]] = AT[winner, tl2$skill[i]] + 1
        }
      }
      tl = tl[!is.na(tl$agent),] %>% rbind(tl2)
      if(!silent){cat(' Done!', '\n')}
    } else {if(!silent){cat('All workable tasks already allocated. No need to fill gap time.', '\n')}}
  }
  
  return(tl)
}

distHorizontal = function(tl, AT, agents, vSkills, vTAT, avl){
  tl$agent = NA
  
  for (j in vSkills){
    ind  = which(tl$skill == j & is.na(tl$agent))
    prs  = tl$priority[ind]
    ord  = order(prs, decreasing = T)
    tba  = ind[ord[sequence(AT[,j] %>% sum(na.rm = T))]] %>% na.omit #Indexes of tasks 2b allocated to agents for task j
    
    agsj = agents[order(vTAT[,j], na.last = NA)]
    avlj = avl[agsj]
    avlj = avlj[avlj > 0]
    agsj = names(avlj)
    # avl = x$AP[, 'available', drop = F]
    M   = length(agsj)
    N   = length(tba)
    if(M > 0){
      k = 1
      i = 1
      while(i <= N){
        if(!is.empty(avlj)){
          agsj = agsj[order(avlj, decreasing = T)]
          if(avl[agsj[k]] - vTAT[agsj[k], j] > 0){
            tl[tba[i],'agent'] = agsj[k]
            avl[agsj[k]]  = avl[agsj[k]] - vTAT[agsj[k], j]
            avlj[agsj[k]] = avl[agsj[k]]
          }
          i = i + 1
        }
      }
    }
  }
  return(tl)
}

# cc = sw[cn[sp]]
# bb = c(util, const.rhs.2)
# A  = rbind(const.mat.1, const.mat.2)
# x0 = rep(1,p)

#' @export
taskSummary2TaskList = function(TS, skillID_col, count_col, priority_col, agentID_col = NULL, extra_col = NULL, prefix = '', start_id = 1, id_length = 5, vf = T){
  # Verifications
  if(vf){
    nms = names(TS)
    start_id %<>% as.integer %>% verify('integer', lengths = 1, err_msg = 'Argument start_id must be convertible to integer', err_src = match.call()[[1]])
    verify(skillID_col, 'character', lengths = 1, domain = nms, varname = 'skillID_col', null_allowed = F)
    verify(count_col, 'character', lengths = 1, domain = nms, varname = 'count_col', null_allowed = F)
    verify(priority_col, 'character', lengths = 1, domain = nms, varname = 'priority_col', null_allowed = F)
    verify(agentID_col, 'character', lengths = 1, domain = nms, varname = 'agentID_col')
    verify(extra_col, 'character', domain = nms, varname = 'extra_col')
  }
  
  TS[, skillID_col]    %<>% coerce('character')
  TS[, agentID_col]    %<>% coerce('character')
  TS[, count_col]    %<>% coerce('integer')
  TS[, priority_col] %<>% coerce('numeric')
  
  if(!is.null(agentID_col)){TS[, agentID_col] %<>% as.character}
  TL = data.frame(taskID = character(), skillID = character(), priority = numeric(), alctdAgent = character(), workable = logical())
  if(!is.null(extra_col)){TL %<>% cbind(TS[c(),extra_col])}
  
  cnt = max(start_id %>% as.integer, 1)
  for (i in sequence(nrow(TS))){
    N = TS[i, count_col] %>% as.integer
    if(N > 0){
      A = data.frame(
        taskID     = sequence(N) + cnt  - 1,
        skillID    = TS[i,skillID_col],
        priority   = TS[i,priority_col] %>% as.numeric
      )
      if(!is.null(agentID_col)){A$alctdAgent <- TS[i, agentID_col]}
      if(!is.empty(extra_col)){A = cbind(A, TS[rep(i, nrow(A)), extra_col])}
      TL = chif(is.empty(TL), A, TL %>% rbind(A))
      
      cnt <- cnt + N
    }
  }
  rownames(TL)  <- TL$taskID %>% as.character %>% extend.char(id_length, fillChar = '0', left = F)
  if(nrow(TL) > 0){rownames(TL) <-  prefix %++% rownames(TL)}
  TL[,'taskID'] <- NULL
  return (TL)
}

#' @export
balanceAgentUtilization = function(obj){
  assert(require(nloptr), "Package 'nloptr' is not installed. Please install before running this function.", err_src = 'niraprom::balanceAgentUtilization')
  AAA = reshape2::dcast(obj$TSK %>% filter(!LO), agent ~ skill, value.var = 'AUT', fun.aggregate = length) %>% na.omit %>% column2Rownames('agent') # asal: agent skill allocated
  ALC.all = obj$ALC
  ALC.new = obj$ALC
  ALC.new[,] = 0
  agents = rownames(AAA) %^% obj$agents
  skills = colnames(AAA) %^% obj$skills
  ALC.new[agents, skills] = AAA[agents, skills]
  ALC.lvr = obj$ALC - ALC.new
  avl = (obj$AP[, 'productive', drop = F] %>% toVectorList)[['productive']]
  
  AUT.all = ALC.all*obj$TAT
  AUT.new = ALC.new*obj$TAT   # Total time required for new allocated tasks
  # obj$AUT = obj$ALC*obj$TAT
  # among skills from which we have at least one new task:
  for(sk in colnames(ALC.new)[colSums(ALC.new) > 0]){
    # Which agents are skilled in sk?
    skilledAgents = (obj$agents[which(avl > 0)] %U% obj$agents[which(ALC.new[,sk] > 0)]) %^% obj$agents[which(!is.na(obj$TAT[ ,sk]))]
    skn = which(names(obj$ALC) == sk)
    
    # How much time required for new allocated(non-leftovers) of skill sk?
    util = rowSums(AUT.all, na.rm = T)[skilledAgents]
    b    = util - AUT.new[skilledAgents, sk]
    names(b) = skilledAgents
    
    a = obj$TAT[skilledAgents, sk]
    names(a) <- skilledAgents
    objfun = function(x){
      u  = a*x + b
      ub = mean(u)
      sum((u - ub)^2)
    }
    grad = function(x){
      u  = a*x + b
      ub = mean(u)
      N  = length(x)
      2*(N - 1)*a*(u - ub)/N
    }
    
    equality = function(x){sum(x) - sum(ALC.new[, sk])}
    # inequality = function(x){u  = a*x + b - avl[skilledAgents]}
    # ineq_grad  = function(x){a}
    
    local_opts <- list("algorithm" = "NLOPT_LD_MMA", "xtol_rel" = 1.0e-7 )
    opts <- list( "algorithm" = "NLOPT_LD_AUGLAG",
                  "xtol_rel" = 1.0e-7,
                  "maxeval" = 1000,
                  "print_level" = 0,
                  "local_opts" = local_opts )
    
    ub  = round((avl[skilledAgents] - b)/a)
    x0  = ALC.new[skilledAgents, sk]
    tch = which(ub < x0)
    ub[tch] = x0[tch]
    
    fit = try(nloptr(x0 = ALC.new[skilledAgents, sk],
                     eval_f = objfun,
                     eval_grad_f = grad,
                     lb = rep(0, length(a)),
                     ub = ub,
                     eval_g_eq = equality,
                     eval_jac_g_eq = function(x){rep(1.0, length(x))},
                     opts = opts), silent = T)
    if(fit %>% inherits('nloptr')){
      ALC.new.2 = ALC.new
      ALC.new.2[skilledAgents, sk] = fit$solution %>% round
      diff = (ALC.new[skilledAgents, sk] %>% na2zero %>% sum) - (ALC.new.2[skilledAgents, sk] %>% sum)
      diff %<>% as.integer
      if (diff > 0){
        w    = which(ub > ALC.new.2[skilledAgents, sk])
        if(length(w) >= diff){w = w[diff]}
        ALC.new.2[skilledAgents[w], sk] = ALC.new.2[skilledAgents[w], sk] + 1
      }
      diff = (ALC.new[skilledAgents, sk] %>% na2zero %>% objfun) - (ALC.new.2[skilledAgents, sk] %>% objfun)
      if (diff > 1){
        ALC.new = ALC.new.2
        AUT.new = ALC.new*obj$TAT
        ALC.all = ALC.lvr + ALC.new
        AUT.all = ALC.all*obj$TAT
      }
    }
  }
  
  t2ba = which(obj$TSK$workable & !obj$TSK$LO)
  tl   = obj$TSK[t2ba, ]
  tl$agent = NA
  
  ALC.new %<>% na2zero
  # assert(nrow(tl) == sum(ALC.new), "May happen?!")
  
  for (j in obj$skills){
    for (i in obj$agents[order(obj$TAT[,j], na.last = NA)]){
      if (ALC.new[i,j] > 0){
        ind = which(tl$skill == j & is.na(tl$agent))
        prs = tl$priority[ind]
        ord = order(prs, decreasing = T)
        tba = ind[ord[sequence(ALC.new[i,j])]] %>% na.omit #Indexes of tasks 2b allocated to agent i
        tl[tba, 'agent'] <- i
      }
    }
  }
  
  obj$TSK$agent[t2ba] = tl$agent
  
  obj %<>% updateAgentUtilization
  obj %<>% updateTaskCounts
  
  # assert(sum(obj$ALC != ALC.all, na.rm = T) == 0)
  return(obj)
}

# tij: process time of task i for agent aj

old.swapImpact = function(row, a1, s1, sk1, t11, S, TAT, Kf, Ku, Ksa){
  var1 = mean((S$objFunValue - mean(S$objFunValue, na.rm = T))^2, na.rm = T)
  a2  = row[1]
  if(a1 == a2){return(0)}
  sk2 = row[2]
  s2  = as.numeric(row[3])
  t22 = as.numeric(row[4])
  
  t21 = TAT[a1, sk2]
  t12 = TAT[a2, sk1]
  
  S[a1, 'score']    = S[a1, 'score'] - s1 + s2
  S[a2, 'score']    = S[a2, 'score'] - s2 + s1
  S[a1, 'utilized'] = S[a1, 'utilized'] - t11 + t21
  S[a2, 'utilized'] = S[a2, 'utilized'] - t22 + t12
  
  S[a1, 'utilisation'] = 100*S[a1, 'utilized']/S[a1, 'scheduled']
  S[a2, 'utilisation'] = 100*S[a2, 'utilized']/S[a2, 'scheduled']
  
  S$scoreRate   = 100*S$score/S$utilized
  S$scoreAvg    = 100*S$score/S$Allocated
  S$objFunValue = Kf*S$scoreRate + Ku*S$utilisation + Ksa*S$scoreAv
  
  var2 = mean((S$objFunValue - mean(S$objFunValue, na.rm = T))^2, na.rm = T)
  if(S[a2, 'utilisation'] > 110 | S[a1, 'utilisation'] > 110)(return(NA))
  return(var2 - var1)
}



old.balanceWeightedScores = function(obj, silent = F, Kf = 1.0, Ku = 0.0, Ksa = 0.0, improvement_threshold = 0.01){
  Kf = abs(Kf)
  Ku = abs(Ku)
  if(Kf + Ku + Ksa == 0){return(obj)}
  AP = obj$AP
  TL = obj$TSK %>% rownames2Column('taskID') %>% mutate(taskID = as.character(taskID), scoreRate = 100*score/AP[agent,'utilized'], scoreAvg = 100*score/AP[agent,'Allocated']) %>% mutate(utilRate = 100*AUT/AP[agent,'scheduled']) %>%
    mutate(objFunValue = Kf*scoreRate + Ku*utilRate + Ksa*scoreAvg) %>% column2Rownames('taskID', remove = F)
  
  AP$utilisation = 100*AP$utilized/AP$scheduled
  AP$scoreRate   = 100*AP$score/AP$utilized
  AP$scoreAvg    = 100*AP$score/AP$Allocated
  AP$objFunValue = Kf*AP$scoreRate + Ku*AP$utilisation + Ksa*AP$scoreAvg
  
  # todo: modify updateAgentUtilisation to add util percentage and ofun. Weights can be determined in settings
  improvement = 1
  of1  = sd(AP$objFunValue, na.rm = T)
  cnt  = 1
  go   = T
  while(go & improvement > improvement_threshold){
    # WHICH AGENT HAS THE HIGHEST OFUN VALUE?
    agord = order(AP$objFunValue, decreasing = T)
    
    suc = F
    # i is counting agents from agord
    i = 1
    while(!suc & i < length(agord)){
      e = obj$agents[agord[i]] # This is the id of agent i
      
      # what skills does agent e have?
      skillse = obj$skills[which(obj$TAT[e, ] > 0)]
      
      # extract his/her tasks:
      TLi = TL[which(TL$agent == e & !TL$LO & TL$workable),] %>% arrange(desc(objFunValue))
      
      # from tasks of agent i, starting from the task with the highest ofun value:
      # ii is counting tasks of agent i from TLi
      ii  = 1
      while(!suc & ii < nrow(TLi)){
        # Which agents can also do this task?
        w = which(obj$TAT[, TLi[ii, 'skill']] > 0)
        # sort them ascending by scoreRate and convert to ids:
        w = obj$agents[w[order(AP[w, 'objFunValue'])]]
        # k counts agents who can do task i from w
        k   = 1
        while(!suc & k < length(w)){
          # which tasks from agent k can be swapped by agent e?
          # must be not a leftover, must be workable and its skill must be in skills of e
          wk  = which((TL$agent == w[k])  & (!TL$LO) & TL$workable & (TL$skill %in% skillse))
          TLk = TL[wk, c('agent', 'skill', 'score', 'AUT')]
          suc = nrow(TLk) > 0
          if(suc){
            imp = TLk %>% apply(1, swapImpact, e, TLi$score[ii], TLi$skill[ii], TLi$AUT[ii], AP, obj$TAT, Kf = Kf, Ku = Ku, Ksa = Ksa)
            
            ord = order(imp)[1]
            low = imp[ord]
            suc = (!is.na(low))
            if(suc){suc = low < 0}
            if(suc){
              jj  = wk[ord] # jj contains the index of task allocated to agent k that needs to be swaped with task ii allocated to agent i, counts from TL
              ### swap Tasks:
              ai = TLi[ii, 'agent'] # must be the same as e
              ti = TLi[ii, 'AUT']
              si = TLi[ii, 'score']
              
              aj = TL[jj, 'agent']  # must be the same as w[k]
              tj = TL[jj, 'AUT']
              sj = TL[jj, 'score']
              
              TL[TLi$taskID[ii], 'agent'] = aj
              TL[TLi$taskID[ii], 'AUT']   = obj$TAT[aj, TLi$skill[ii]]
              TL[jj, 'agent'] = ai
              TL[jj, 'AUT']   = obj$TAT[ai, TL$skill[jj]]
              
              AP[ai, 'score']    = AP[ai, 'score'] - si + sj
              AP[aj, 'score']    = AP[aj, 'score'] - sj + si
              AP[ai, 'utilized'] = AP[ai, 'utilized'] - ti + obj$TAT[ai, TL$skill[jj]]
              AP[aj, 'utilized'] = AP[aj, 'utilized'] - tj + obj$TAT[aj, TLi$skill[ii]]
              
              AP[ai, 'utilisation'] = 100*AP[ai, 'utilized']/AP[ai, 'scheduled']
              AP[aj, 'utilisation'] = 100*AP[aj, 'utilized']/AP[aj, 'scheduled']
              
              AP[ai, 'scoreRate']   = 100*AP[ai, 'score']/AP[ai, 'utilized']
              AP[aj, 'scoreRate']   = 100*AP[aj, 'score']/AP[aj, 'utilized']
              
              AP[ai, 'scoreAvg']   = 100*AP[ai, 'score']/AP[ai, 'Allocated']
              AP[aj, 'scoreAvg']   = 100*AP[aj, 'score']/AP[aj, 'Allocated']
              
              AP[ai,'objFunValue'] = Kf*AP[ai, 'scoreRate'] + Ku*AP[ai, 'utilisation'] + Ksa*AP[ai, 'scoreAvg']
              AP[aj,'objFunValue'] = Kf*AP[aj, 'scoreRate'] + Ku*AP[aj, 'utilisation'] + Ksa*AP[aj, 'scoreAvg']
              
              TL[TLi$taskID[ii], 'scoreRate'] <- 100*si/AP[aj, 'utilized']
              TL[jj, 'scoreRate']             <- 100*sj/AP[ai, 'utilized']
              
              TL[TLi$taskID[ii], 'scoreAvg']  <- 100*si/AP[aj, 'Allocated']
              TL[jj, 'scoreAvg']              <- 100*sj/AP[ai, 'Allocated']
              
              TL[TLi$taskID[ii], 'utilRate'] <- 100*tj/AP[aj, 'scheduled']
              TL[jj, 'utilRate']             <- 100*ti/AP[ai, 'scheduled']
              
              TL[TLi$taskID[ii], 'objFunValue'] <- Kf*TL[TLi$taskID[ii], 'scoreRate'] + Ku*TL[TLi$taskID[ii], 'utilRate'] + Ksa*TL[TLi$taskID[ii], 'scoreAvg']
              TL[jj, 'objFunValue']             <- Kf*TL[jj, 'scoreRate'] + Ku*TL[jj, 'utilRate'] + Ksa*TL[jj, 'scoreAvg']
            }
          }
          k = k + 1
        }
        ii = ii + 1
      }
      i = i + 1
    }
    go = suc
    cnt = cnt + 1
    of2 = sd(AP$objFunValue, na.rm = T)
    improvement = of1 - of2
    of1 = of2
    if(!silent){cat('Iteration: ', cnt, ' sd = ', of2, '\n')}
  }
  
  cols = colnames(TL) %^% colnames(obj$TSK)
  obj$TSK[TL$taskID, cols] = TL[,cols]
  return(obj %>% updateAgentUtilization %>% updateTaskCounts)
}


swapImpact = function(row, a1, s1, sk1, t11, S, TAT, Kf, Ku, Ksa, Ksv, mul){
  
  var1  = Kf*sd(S$scoreRate, na.rm = T) + Ku*sd(S$utilisation, na.rm = T) + Ksa*sd(S$scoreAvg, na.rm = T) + Ksv*mean(S$scoreSD, na.rm = T)
  a2  = row[1]
  if(a1 == a2){return(0)}
  sk2 = row[2]
  s2  = as.numeric(row[3])
  t22 = as.numeric(row[4])
  
  t21 = TAT[a1, sk2]
  t12 = TAT[a2, sk1]
  
  S[a1, 'score']    = S[a1, 'score'] - s1 + s2
  S[a2, 'score']    = S[a2, 'score'] - s2 + s1
  
  S[a1, 'scoreSQ']    = S[a1, 'scoreSQ'] - s1^2 + s2^2
  S[a2, 'scoreSQ']    = S[a2, 'scoreSQ'] - s2^2 + s1^2
  
  S[a1, 'utilized'] = S[a1, 'utilized'] - t11 + t21
  S[a2, 'utilized'] = S[a2, 'utilized'] - t22 + t12
  
  S[a1, 'utilisation'] = S[a1, 'utilized']/S[a1, 'scheduled']
  S[a2, 'utilisation'] = S[a2, 'utilized']/S[a2, 'scheduled']
  
  S[a1, 'scoreRate'] = S[a1, 'score']/S[a1, 'utilized']
  S[a2, 'scoreRate'] = S[a2, 'score']/S[a2, 'utilized']
  
  S[a1, 'scoreAvg'] = S[a1, 'scoreAvg'] + (s2 - s1)/S[a1, 'Allocated']
  S[a2, 'scoreAvg'] = S[a2, 'scoreAvg'] + (s1 - s2)/S[a2, 'Allocated']
  
  if(S[a1, 'Allocated'] > 1){S[a1, 'scoreSD'] = sqrt((S[a1, 'scoreSQ'] - S[a1, 'score']^2/S[a1, 'Allocated'])/(S[a1, 'Allocated'] - 1)) %>% na2zero} else {S[a1, 'scoreSD'] = 0}
  if(S[a2, 'Allocated'] > 1){S[a2, 'scoreSD'] = sqrt((S[a2, 'scoreSQ'] - S[a2, 'score']^2/S[a2, 'Allocated'])/(S[a2, 'Allocated'] - 1)) %>% na2zero} else {S[a2, 'scoreSD'] = 0}
  
  
  S[a1,'objFunValue'] = Kf*S[a1, 'scoreRate'] + Ku*S[a1, 'utilisation'] + Ksa*S[a1, 'scoreAvg'] + Ksv*S[a1, 'scoreSD']
  S[a2,'objFunValue'] = Kf*S[a2, 'scoreRate'] + Ku*S[a2, 'utilisation'] + Ksa*S[a2, 'scoreAvg'] + Ksv*S[a2, 'scoreSD']
  
  var2  = Kf*sd(S$scoreRate, na.rm = T) + Ku*sd(S$utilisation, na.rm = T) + Ksa*sd(S$scoreAvg, na.rm = T) + Ksv*mean(S$scoreSD, na.rm = T)
  # if swapping tasks leads to exceeding more than 110% utilization, ignore it!
  if(S[a2, 'utilisation'] > mul | S[a1, 'utilisation'] > mul)(return(NA))
  return(var2 - var1)
}

#' Changes allocation by reducing or increasing variability of a weighted combination of metrics among agents.
#'
#' These metrics are:
#' \itemize{
#'   \item{Score Rate : Total scores gained by agents per unit time. Giving higher weight to this metric, leads to a fairer task allocation which has a balanced load sharing (weighted by argument \code{Kf})}
#'   \item{Utilization Rate: Utilized time as a percentage of schedule time (weighted by argument \code{Ku})}
#'   \item{Score Average: Mean of task scores gained by agents (weighted by argument \code{Ksa})}
#'   \item{Score Variability: Sum of standard deviations of task scores gained by each agent (weighted by argument \code{Ksv})}
#' }
#' Note that this treatment leads to a sub-optimal allocation but can provide a customized distribution of tasks like
#' more balanced load sharing and utilization among employees. A positive coefficient decreases variability and a positive one increases variability.
#' @param obj input object: Should be an object of class \code{OptimalTaskAllocator},
#' @param Kf single numeric: Weighting Coefficient for score rate variability (fair load sharing)
#' @param Ku single numeric: Weighting Coefficient for utilization rate variability
#' @param Ksa single numeric: Weighting Coefficient for average score variability
#' @param Ksv single numeric: Weighting Coefficient for sum of score variabilities
#' @param improvement_threshold Iterations stop if improvement in reducing the standard deviation of the weighted objective function is less than this value.
#' @param max_utilization Single numeric: specifies maximum utilization percentage.
#' The swapping will not be done if it leads to a utilization ratio higher than this, .
#' @return an object of class \code{OptimalTaskAllocator} with modified allocated tasks.
#'
#' @export
balanceWeightedScores = function(obj, silent = F, Kf = 0.0, Ku = 0.0, Ksa = 0.0, Ksv = 0.0, max_utilization = 1.1, improvement_threshold = 0.0001){
  if(abs(Kf) + abs(Ku) + abs(Ksa) + abs(Ksv) == 0){return(obj)}
  AP  = obj$AP[obj$AP$productive > 0, ]
  TL  = obj$TSK %>% rownames2Column('taskID') %>% mutate(taskID = as.character(taskID)) %>% filter(!is.na(agent) & !LO & workable)
  SCL = TL %>% dplyr::group_by(agent) %>% dplyr::summarise(scoresum = sum(score, na.rm = T), scoresq = sum(score^2, na.rm = T), scorevar = sd(score, na.rm = T)) %>% as.data.frame %>% column2Rownames('agent')
  AP$scoreSQ     = SCL[rownames(AP), 'scoresq']  %>% na2zero
  AP$scoreSD     = SCL[rownames(AP), 'scorevar'] %>% na2zero
  AP$utilisation = AP$utilized/AP$scheduled
  AP$scoreRate   = AP$score/AP$utilized
  AP$scoreAvg    = AP$score/AP$Allocated
  AP$objFunValue = Kf*AP$scoreRate + Ku*AP$utilisation + Ksa*AP$scoreAvg + Ksv*AP$scoreSD
  
  TL %<>%
    mutate(scoreRate = score/AP[agent,'utilized'], scoreAvg = score/AP[agent,'Allocated'], scoreSQ = score^2, scoreSD = AP[agent,'scoreSD']) %>%
    mutate(utilRate = AUT/AP[agent,'scheduled']) %>%
    mutate(objFunValue = Kf*scoreRate + Ku*utilRate + Ksa*scoreAvg + Ksv*scoreSD) %>% column2Rownames('taskID', remove = F)
  
  # todo: modify updateAgentUtilisation to add util percentage and ofun. Weights can be determined in settings
  improvement = 1
  of1  = Kf*sd(AP$scoreRate, na.rm = T) + Ku*sd(AP$utilisation, na.rm = T) + Ksa*sd(AP$scoreAvg, na.rm = T) + Ksv*mean(AP$scoreSD, na.rm = T)
  cnt  = 1
  go   = T
  while(go & improvement > improvement_threshold){
    # WHICH AGENT HAS THE HIGHEST OFUN VALUE?
    agord = order(AP$objFunValue, decreasing = T)
    
    suc = F
    # i is counting agents from agord
    i = 1
    while(!suc & i < length(agord)){
      e = rownames(AP)[agord[i]] # This is the id of agent i
      
      # what skills does agent e have?
      skillse = obj$skills[which(obj$TAT[e, ] > 0)]
      
      # extract his/her tasks:
      TLi = TL[which(TL$agent == e),] %>% arrange(desc(objFunValue))
      
      # from tasks of agent i, starting from the task with the highest ofun value:
      # ii is counting tasks of agent i from TLi
      ii  = 1
      while(!suc & ii < nrow(TLi)){
        # Which agents other than e can also do this task and are in AP (means have available time because AP is already filtered)?
        w = which(obj$TAT[, TLi[ii, 'skill']] > 0)
        w = (rownames(obj$TAT)[w] %^% rownames(AP)) %-% e
        # sort them ascending by scoreRate and convert to ids:
        w = w[order(AP[w, 'objFunValue'])]
        # k counts agents who can do task i from w
        k   = 1
        while(!suc & k <= length(w)){
          # which tasks from agent k can be swapped by agent e?
          # must be not a leftover, must be workable and its skill must be in skills of e
          wk  = which((TL$agent == w[k]) & (TL$skill %in% skillse))
          # shrink the tasks even more:
          # if score-rate and utilization are not to be balanced, then swapping tasks with equal scores to task ii won't help! so remove them from TLk:
          if((abs(Kf) == 0) & (abs(Ku) == 0)){
            wk  = wk %^% which(TL$score != TLi$score[ii])
          }
          suc = length(wk) > 0
          if(suc){
            TLk = TL[wk, c('agent', 'skill', 'score', 'AUT')]
            options(warn = -1)
            imp = TLk %>% apply(1, swapImpact, e, TLi$score[ii], TLi$skill[ii], TLi$AUT[ii], AP, obj$TAT, Kf = Kf, Ku = Ku, Ksa = Ksa, Ksv = Ksv, mul = max_utilization)
            options(warn = 1)
            
            ord = order(imp)[1]
            low = imp[ord]
            suc = (!is.na(low))
            if(suc){suc = low < 0}
            if(suc){
              jj  = wk[ord] # jj contains the index of task allocated to agent k that needs to be swaped with task ii allocated to agent i, counts from TL
              ### swap Tasks:
              ai = TLi[ii, 'agent'] # must be the same as e
              ti = TLi[ii, 'AUT']
              si = TLi[ii, 'score']
              
              aj = TL[jj, 'agent']  # must be the same as w[k]
              tj = TL[jj, 'AUT']
              sj = TL[jj, 'score']
              
              TL[TLi$taskID[ii], 'agent'] = aj
              TL[TLi$taskID[ii], 'AUT']   = obj$TAT[aj, TLi$skill[ii]]
              TL[jj, 'agent'] = ai
              TL[jj, 'AUT']   = obj$TAT[ai, TL$skill[jj]]
              
              AP[ai, 'score']    = AP[ai, 'score'] - si + sj
              AP[aj, 'score']    = AP[aj, 'score'] - sj + si
              
              AP[ai, 'scoreSQ']    = AP[ai, 'scoreSQ'] - si^2 + sj^2
              AP[aj, 'scoreSQ']    = AP[aj, 'scoreSQ'] - sj^2 + si^2
              
              AP[ai, 'utilized'] = AP[ai, 'utilized'] - ti + obj$TAT[ai, TL$skill[jj]]
              AP[aj, 'utilized'] = AP[aj, 'utilized'] - tj + obj$TAT[aj, TLi$skill[ii]]
              
              AP[ai, 'utilisation'] = AP[ai, 'utilized']/AP[ai, 'scheduled']
              AP[aj, 'utilisation'] = AP[aj, 'utilized']/AP[aj, 'scheduled']
              
              AP[ai, 'scoreRate']   = AP[ai, 'score']/AP[ai, 'utilized']
              AP[aj, 'scoreRate']   = AP[aj, 'score']/AP[aj, 'utilized']
              
              AP[ai, 'scoreAvg']   = AP[ai, 'score']/AP[ai, 'Allocated']
              AP[aj, 'scoreAvg']   = AP[aj, 'score']/AP[aj, 'Allocated']
              
              options(warn = -1)
              if(AP[ai, 'Allocated'] > 1){AP[ai, 'scoreSD']    = sqrt((AP[ai, 'scoreSQ'] - AP[ai, 'score']^2/AP[ai, 'Allocated'])/(AP[ai, 'Allocated'] - 1)) %>% na2zero} else {AP[ai, 'scoreSD'] = 0}
              if(AP[aj, 'Allocated'] > 1){AP[aj, 'scoreSD']    = sqrt((AP[aj, 'scoreSQ'] - AP[aj, 'score']^2/AP[aj, 'Allocated'])/(AP[aj, 'Allocated'] - 1)) %>% na2zero} else {AP[aj, 'scoreSD'] = 0}
              options(warn = 1)
              
              AP[ai,'objFunValue'] = Kf*AP[ai, 'scoreRate'] + Ku*AP[ai, 'utilisation'] + Ksa*AP[ai, 'scoreAvg'] + Ksv*AP[ai, 'scoreSD']
              AP[aj,'objFunValue'] = Kf*AP[aj, 'scoreRate'] + Ku*AP[aj, 'utilisation'] + Ksa*AP[aj, 'scoreAvg'] + Ksv*AP[aj, 'scoreSD']
              
              TL[TLi$taskID[ii], 'scoreRate'] <- si/AP[aj, 'utilized']
              TL[jj, 'scoreRate']             <- sj/AP[ai, 'utilized']
              
              TL[TLi$taskID[ii], 'scoreAvg']  <- si/AP[aj, 'Allocated']
              TL[jj, 'scoreAvg']              <- sj/AP[ai, 'Allocated']
              
              TL[TLi$taskID[ii], 'utilRate']  <- tj/AP[aj, 'scheduled']
              TL[jj, 'utilRate']              <- ti/AP[ai, 'scheduled']
              
              TL[TLi$taskID[ii], 'objFunValue'] <- Kf*TL[TLi$taskID[ii], 'scoreRate'] + Ku*TL[TLi$taskID[ii], 'utilRate'] + Ksa*TL[TLi$taskID[ii], 'scoreAvg'] + Ksv*TL[TLi$taskID[ii], 'scoreSD']
              TL[jj, 'objFunValue']             <- Kf*TL[jj, 'scoreRate'] + Ku*TL[jj, 'utilRate'] + Ksa*TL[jj, 'scoreAvg'] + Ksv*TL[jj, 'scoreSD']
            }
          }
          k = k + 1
        }
        ii = ii + 1
      }
      i = i + 1
    }
    go = suc
    cnt = cnt + 1
    of2 = Kf*sd(AP$scoreRate, na.rm = T) + Ku*sd(AP$utilisation, na.rm = T) + Ksa*sd(AP$scoreAvg, na.rm = T) + Ksv*mean(AP$scoreSD, na.rm = T)
    improvement = of1 - of2
    of1 = of2
    if(!silent){cat('iteration: ', cnt, ' obj. fun. value = ', of2, ' improvement: ', improvement, '\n')}
  }
  
  cols = colnames(TL) %^% colnames(obj$TSK)
  obj$TSK[TL$taskID, cols] = TL[,cols]
  return(obj %>% updateAgentUtilization %>% updateTaskCounts)
}


# otavis.R


#' OTAR: Optimal Task Allocation with R
#'
#' otar is a workforce optimisation tool using advanced optimisation techniques to improve operational efficiency of teams
#' by optimal allocation of work (tasks) to available employees(agents). It aims to maximize productivity while respects for additional constraints
#' like balanced load sharing or employee utilization. The package has defined S3 class \code{OptimalTaskAllocator} inheriting a list which holds all required tables as data-frames.
#' These tables are:
#' \itemize{
#'  \item{'AP' (data.frame)}{ Agent Profile: Contains all information about agents like their IDs, names, scheduled time, productive time,
#'  time reserved for leftover tasks, count of leftoves, allocated tasks, utilized time and total scores gained from allocation}
#'  \item{'SP' (data.frame)}{ Skill Profile: Contains all information about skills.}
#'  \item{'TAT' (data.frame)}{ Turn-Around Time: This is the agent-skill matrix containing average unit times (AUT).}
#'  \item{'ALC' (data.frame)}{ Allocation Matrix: An agent-skill matrix showing total count of allocated tasks.}
#'  \item{'TSK' (data.frame)}{ List of all fed tasks}
#'  \item{'agents' (character)}{ Contains names or IDs of the agents fed to the model.}
#'  \item{'skills' (character)}{ Contains names or IDs of the skills fed to the model.}
#' }
#' @docType package

#' @name otar
#'
#' @include ota.R
#' @include otatools.R

# Current Version: 4.3.8
# Issue Date: 04 April 2017
# Last Issue: 13 July 2018

# Version     Date                 Action
# --------------------------------------------------------------------
# 0.1.0       04 April 2017        Initial issue
# 0.2.0       20 April 2017        wfo.R & wfo.tools.R added. These are part of the work-force optimization plugins within the niraprom package
# 1.0.0       12 July 2017         wfo.R & wfo.tools.R updated and renamed to ota.R and otatools.R
# 2.1.5       24 July 2017         ota.R modified to version 2.1.5: Function calcAgentTAT() exported
# 3.1.8       27 July 2017         otatools.R modified to version 1.0.3
# 3.2.3       10 August 2017       ota.R modified to version 2.2.0
# 3.2.4       11 August 2017       ota.R modified to version 2.2.1
# 3.2.5       16 August 2017       ota.R modified to version 2.2.2
# 3.3.2       21 August 2017       otatools.R modified to version 1.1.0
# 3.3.3       21 August 2017       ota.R modified to version 2.2.3
# 3.3.6       21 August 2017       otatools.R modified to version 1.1.3
# 3.3.7       22 August 2017       otatools.R modified to version 1.1.4
# 3.3.9       31 August 2017       otatools.R modified to version 1.1.6
# 3.4.3       31 August 2017       ota.R modified to version 2.2.7
# 3.4.4       05 September 2017    ota.R modified to version 2.2.8
# 3.5.5       06 September 2017    ota.R modified to version 2.2.9
# 3.4.6       12 September 2017    ota.R modified to version 2.3.0
# 3.4.7       12 September 2017    ota.R modified to version 2.3.1
# 3.4.8       18 September 2017    ota.R modified to version 2.3.2
# 3.5.3       21 September 2017    otatools.R modified to version 1.2.1
# 3.5.4       22 September 2017    ota.R modified to version 2.3.3
# 3.5.5       25 September 2017    otatools.R modified to version 1.2.2
# 3.5.7       26 September 2017    ota.R modified to version 2.3.5
# 3.5.8       26 September 2017    otatools.R modified to version 1.2.3
# 3.6.3       05 October 2017      otatools.R modified to version 1.3.0
# 3.6.6       05 October 2017      ota.R modified to version 2.3.6
# 3.6.7       09 October 2017      ota.R modified to version 2.3.7
# 3.6.8       09 October 2017      otatools.R modified to version 1.3.2
# 3.6.9       09 October 2017      otatools.R modified to version 1.3.3
# 3.7.1       10 October 2017      ota.R modified to version 2.3.8
# 3.7.2       10 October 2017      otatools.R modified to version 1.3.4
# 3.7.3       12 October 2017      ota.R modified to version 2.3.9
# 3.7.4       16 October 2017      ota.R modified to version 2.4.0
# 3.7.5       17 October 2017      ota.R modified to version 2.4.1
# 3.7.6       30 October 2017      ota.R modified to version 2.4.2
# 3.7.7       01 November 2017     ota.R modified to version 2.4.3
# 3.7.8       02 November 2017     ota.R modified to version 2.4.4
# 3.7.9       14 November 2017     otatools.R modified to version 1.3.5
# 3.8.0       28 November 2017     otatools.R modified to version 1.3.6
# 3.8.2       04 Decemebr 2017     ota.R modified to version 2.4.6
# 3.8.5       09 January 2018      otatools.R modified to version 1.3.9
# 3.8.6       09 January 2018      ota.R modified to version 2.4.7
# 3.8.7       11 January 2018      otatools.R modified to version 1.4.0
# 3.9.1       19 January 2018      otatools.R modified to version 1.4.4
# 3.9.3       25 January 2018      otatools.R modified to version 1.4.6
# 3.9.4       29 January 2018      otatools.R modified to version 1.4.7
# 3.9.5       30 January 2018      otatools.R modified to version 1.4.8
# 3.9.6       19 February 2018     otatools.R modified to version 1.4.9
# 3.9.7       19 February 2018     otatools.R modified to version 1.5.0
# 4.0.2       08 March 2018        otatools.R modified to version 1.5.3 & ota.R to version 2.4.9
# 4.0.6       13 March 2018        otatools.R modified to version 1.5.7
# 4.0.8       10 April 2018        otatools.R modified to version 1.5.9
# 4.1.0       05 May 2018          otatools.R modified to version 1.6.1
# 4.1.7       25 May 2018          ota.R modified to version 2.5.6
# 4.2.1       28 May 2018          ota.R modified to version 2.6.0
# 4.2.3       28 May 2018          otatools.R modified to version 1.6.3
# 4.2.5       04 June 2018         ota.R modified to version 2.6.2
# 4.2.6       05 June 2018         otatools.R modified to version 1.6.4
# 4.3.1       09 July 2018         otatools.R modified to version 1.6.6, ota.R modified to ver 2.6.5
# 4.3.5       11 July 2018         otatools.R modified to version 1.7.0
# 4.3.8       13 July 2018         ota.R modified to version 2.6.8

NULL
#> NULL

