library(magrittr)
library(gener)

source('~/Documents/software/R/packages/texer/R/tmtools.R')
source('~/Documents/software/R/packages/texer/R/textminer.R')
load("~/Documents/software/R/projects/tutorials/script/texer/woolworth.RData")


dat = all_reveiws_woolworth %>% unlist %>% as.data.frame
colnames(dat) = 'text'
dat$text %<>% as.character

ss = genDefaultSettings() %>% list.edit(tm_package = 'text2vec')
ss$stop_words %<>% c('woolworth', 'woolworths', 'woolies')

x = TEXT.MINER(dat, settings = ss)

x$clust(5)
x$plot.wordCloud(weighting = 'tfidf', cn = 5)
x$plot.wordCloud(weighting = 'freq', cn = 5)

x$plot.wordCloud(weighting = 'tfidf', cn = 4)
x$plot.wordCloud(weighting = 'freq', cn = 4)

x$plot.wordCloud(weighting = 'tfidf', cn = 3)
x$plot.wordCloud(weighting = 'freq', cn = 3)


x$plot.wordCloud(weighting = 'tfidf', cn = 2)
x$plot.wordCloud(weighting = 'freq', cn = 2)

x$plot.wordCloud(weighting = 'tfidf', cn = 1)
x$plot.wordCloud(weighting = 'freq', cn = 1)

lda = x$get.lda(4)
lda$plot()




