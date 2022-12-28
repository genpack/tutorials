### examples.R -------------------
library(shinyFiles)
## Not run:
# File selections
ui <- shinyUI(bootstrapPage(
  shinyFilesButton('files', 'File select', 'Please select a file', FALSE)
))
server <- shinyServer(function(input, output) {
  shinyFileChoose(input, 'files', roots=c(wd='..'), filetypes=c('', 'R', 'txt', '*'))
})
runApp(list(
  ui=ui,
  server=server
))
## End(Not run)
## Not run:
# Folder selections
ui <- shinyUI(bootstrapPage(
  shinyDirButton('folder', 'Folder select', 'Please select a folder', FALSE)
))
server <- shinyServer(function(input, output) {
  shinyDirChoose(input, 'folder', roots=c(wd='..'), filetypes=c('', 'txt'))
})
runApp(list(
  ui=ui,
  server=server
))
## End(Not run)
## Not run:

# File selections
ui <- shinyUI(bootstrapPage(
  shinySaveButton('save', 'Save', 'Save as...')
))
server <- shinyServer(function(input, output) {
  shinyFileSave(input, 'save', roots=c(wd='..'))
})

runApp(list(
  ui=ui,
  server=server
))
## End(Not run)

app    <- shinyApp(ui, server)
runApp(app, host = "0.0.0.0", port = 8080)

