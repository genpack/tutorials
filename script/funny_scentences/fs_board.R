library(shiny)
library(rvis)
library(rutils)
library(magrittr)

questions = c(X = 'Which of us?', Y = 'with who?', V = 'What were they doing?', P = 'OMG!, Where?', 'T' = 'When?', Z = 'and who saw that?', S = 'What did he/she say?') 
sinp  = read.csv('staff_inputs.csv', stringsAsFactors = F)

layout = list(
  'fontsize',
  list('reset', offset = 1),
  'lf',
  list('X_select','X_text', 'X_image', 'X_num',  offset = 1),
  list('Y_select','Y_text', 'Y_image', 'Y_num', offset = 1),
  list('V_select','V_text', 'V_image', 'V_num', offset = 1),
  list('P_select','P_text', 'P_image', 'P_num', offset = 1),
  list('T_select','T_text', 'T_image', 'T_num', offset = 1),
  list('Z_select','Z_text', 'Z_image', 'Z_num', offset = 1),
  list('S_select', 'S_text', 'S_num', offset = 1)
)

I = list(main = list(type = 'fluidPage', layout = layout),
         lf = list(type = 'static', object = shiny::HTML('<br>')),
         num_staff = list(type = 'textOutput', service = "paste0('(', length(sync$remained[['X']] %>% unique), ' left)')"))

# I$reset = list(type = 'actionButton', title = 'reset', service = "for(i in names(questions)){sync$remained[[i]] <- sinp[[i]]; sync$selected[[i]] <- 'blank'}")
I$reset = list(type = 'actionButton', title = 'Next Sentence', service = "for(i in names(questions)) {sync$selected[[i]] <- 'blank'}", width = '100%')

selected = list()
remained = list()

stl = paste0("#",names(questions), "_text{color: blue;font-size: 40px;font-style: italic;}") %>% paste(collapse = '')

I$fontsize = list(type = 'static', object = tags$head(tags$style(stl)))

for(i in names(questions)){
  # I[[paste(i, 'select', sep = '_')]] <- list(type = 'selectInput', title = questions[i], choices = sinp[[i]])
  remained[[i]] <- sinp[[i]] %-% 'blank'
  selected[[i]] <- 'blank'
  I[[paste(i, 'select', sep = '_')]] <- list(type = 'actionButton', title = questions[i], service = "if(length(sync$remained[['%s']]) > 0) {sync$selected[['%s']] <- sample(sync$remained[['%s']], size = 1); sync$remained[['%s']] <- setdiff(sync$remained[['%s']], sync$selected[['%s']])}" %>% sprintf(i,i,i,i,i,i))
  if(i != 'S'){
    # srv = "list(src = paste0('images/', stringr::str_remove(tolower(select_%s$input), '\\s'), '.jpg'), height = 240, width = 360)" %>% 
    #   sprintf(i)
    # srv = "list(src = paste0('images/', gsub(tolower(input$%s_select), pattern = ' ', replacement = '_'), '.jpg'), height = 240, width = 360)" %>% sprintf(i)
    srv = "list(src = paste0('images/', gsub(tolower(sync$selected[['%s']]), pattern = ' ', replacement = '_'), '.jpg'), height = 320, width = 460)" %>% sprintf(i)
    
    I[[paste(i, 'image', sep = '_')]]  <- list(type = 'imageOutput', deleteFile = F, service = srv)
  }
  
  I[[paste(i, 'text', sep = '_')]]  <- list(type = 'textOutput', service = "sync$selected[['%s']]" %>% sprintf(i))
  I[[paste(i, 'num', sep = '_')]]  <- list(type = 'textOutput', service = "paste0('(', unique(length(sync$remained[['%s']])), ' left)')" %>% sprintf(i))
}


board = new('DASHBOARD', items = I, king.layout = list('main'), values = list(selected = selected, remained = remained))
board$items$X_text$object = h3(board$items$X_text$object)
shinyApp(board$dashboard.ui(), board$dashboard.server())


