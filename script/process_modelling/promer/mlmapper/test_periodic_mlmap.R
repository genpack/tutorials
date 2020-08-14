library(magrittr)
library(dplyr)

# An example of featres list
features = list(
  list(name = 'totalCalls', aggregator = sum, eventTypes = 'Call Received', variables = 'Occurance'),
  list(name = 'totalDeclines', aggregator = length, eventTypes = 'Discount Request Declined', variables = 'Occurance'),
  list(name = 'maxLVR', aggregator = max, eventTypes = 'LVR Changed', variables = 'newRate'),
  list(name = 'minDesired', aggregator = min, eventTypes = 'Discount Request Lodged', variables = 'desiredRate'),
  list(name = 'rate', aggregator = last, eventTypes = 'Discount Request Lodged', variables = 'desiredRate')
)


EL = read.csv('eventlog.csv')
EL %>% MLMapper.periodic(features, period = 'day') %>% View
