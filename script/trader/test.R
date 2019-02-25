# Test trader package:
library(magrittr)

source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/trader/R/fxpro.R')
source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/trader/R/genlib.R')
source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/trader/R/virtual_trader.R')


fxpro.data.path = 'C:/Users/nima_/OneDrive/Documents/data/fxpro'

# from package foxer: read currency data for EURUSD:
vt  = prepare.environment(currency_pair = 'EURUSD', from_date = "2000.01.01 00:00", until_date = "2014.04.01 00:00", period = 'D')


# to see the current time:
vt$current.time

# to see the current price(rate):
vt$current.price

# to see the current time number (in time series):
vt$current.time.number


# to see the current balance:
vt$balance

# to see the latest status of your positions:
vt$position

# to go to a particular time number:
vt$goto(12)


# a = vt$goto('2010-02-04')


# today is:
vt$current.time
# Let's take 0.1 lot buystop at 1.3650 with 50 pip TP and 100 pip SL:
vt$take.buy.stop(price = 1.3650, tp = 50, sl = 100, label = "my_first_position")
# and jump to next month:
vt$jump(30)

# today is:
vt$current.time
# positions status is:
vt$position

## oops, we failed!
# What's the price now?
vt$current.price
# Let's take a sell limit at 1.3600, 200 pip tp, 500 pip sl:
vt$take.sell.limit(price = 1.3600, tp = 200, sl = 500, label = "next_position")
# one week later:
vt$jump(7); vt$current.time
vt$position
# nothing happened!
# one month later:
vt$jump(30); vt$current.time
vt$position


# Apply price will leave strategy with default parameters:
default.parameters('prc_wll_lve')
#vt %>% prc_wll_lve.start(pm = default.parameters('prc_wll_lve'))
vt %>% prc_wll_lve
vt$equity()
vt$position$profit %>% sum


