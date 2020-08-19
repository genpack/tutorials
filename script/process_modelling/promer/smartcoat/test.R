##### Setup ####
library(magrittr)
library(dplyr)
library(viser)

path.data = paste(getwd(), 'script', 'process_modelling', 'promer', 'smartcoat', 'data', sep = '/')
path.promer = paste(getwd(), '..', '..', 'packages', 'promer', 'R', sep = '/')
path.gener = paste(getwd(), '..', '..', 'packages', 'gener', 'R', sep = '/')

source(path.promer %>% paste('tsvis.R', sep = '/'))
source(path.promer %>% paste('transys.R', sep = '/'))

source(path.gener %>% paste('gener.R', sep = '/'))
source(path.gener %>% paste('linalg.R', sep = '/'))
source(path.gener %>% paste('io.R', sep = '/'))
##### Read Data ####
read.csv(path.data %>% paste('SmartCoat_Eventlog_March_2016.csv', sep = '/')) %>% 
  mutate(Timestamp = as.character(Timestamp) %>% lubridate::dmy_hm()) -> data

x = TRANSYS()
x$feed.eventlog(dataset = data, caseID_col = 'Case.ID', status_col = 'Activity.description', startTime_col = 'Timestamp', 
                caseStartFlag_col = NULL, caseEndFlag_col = NULL, caseStartTags = NULL, caseEndTags = NULL, 
                sort_startTime = T, add_start = T, remove_sst = F, 
                extra_col = c("Resource", "Location", "Brand", "Customer", "Estimated.activity.cost"))

cfg = list(direction = 'left.right')
x$plot.process.map(config = cfg, width = "800px")

######
x$history$caseID[1]
x$filter.case(IDs = "Phone 3651")
plot_case_timeline(x)

pm4py::discovery_alpha(el) -> petrin

