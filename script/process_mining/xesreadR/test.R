# Test trader package:
library(magrittr)
library(xesreadR)
library(bupaR)
library(gener)
library(dplyr)
library(promer)
library(viser)

path.win = 'C:/Users/nima_/OneDrive/Documents/data/tue/Sepsis Cases - Event Log.xes'
path.mac = '~/Documents/data/tue/Sepsis Cases - Event Log.xes'

el = read_xes(xesfile = path.mac)
cp = read_xes_cases(xesfile = path)

mapping(el)
el$lifecycle_id %>% head


ss = TRANSYS()

ss$feedStatusHistory(el, caseID_col = 'CASE_concept_name', status_col = 'activity_id', startTime_col = 'timestamp', caseStartFlag_col = NULL, caseEndFlag_col = NULL, caseStartTag = NULL, caseEndTag = NULL, sort_startTime = T, add_start = T, remove_sst = F)
  

plot.process.map(ss) -> map
plot.statuses.bar(ss, time_unit = 'hour')
plot.statuses.box(ss)


