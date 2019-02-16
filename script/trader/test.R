# Test trader package:


source('C:/Users/nima_/Dropbox/software/R/packages/master/nirasoft/foxer/R/fxpro.R')
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


a = vt$goto('2010-02-04')


