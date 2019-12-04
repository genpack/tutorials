# https://cran.r-project.org/web/packages/LTRCtrees/vignettes/LTRCtrees.html
## Adjust data & clean data
library(survival)
set.seed(0)
## Since LTRCART uses cross-validation to prune the tree, specifying the seed 
## guarantees that the results given here will be duplicated in other analyses
Data <- flchain
Data <- Data[!is.na(Data$creatinine),]
Data$End <- Data$age + Data$futime/365
DATA <- Data[Data$End > Data$age,]
names(DATA)[6] <- "FLC"


Train = DATA[1:500,]
Test  = DATA[1000:1020,]


library(LTRCtrees)
LTRCART.obj <- LTRCART(Surv(age, End, death) ~ sex + FLC + creatinine, Train)
LTRCIT.obj <- LTRCIT(Surv(age, End, death) ~ sex + FLC + creatinine, Train)
library(rpart.plot)

rpart.plot.version1(LTRCART.obj)
plot(LTRCIT.obj)


