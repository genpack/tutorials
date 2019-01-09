# Load library and its dataset
library(smbinning) # Load package and its data
pop=chileancredit # Set population
train=subset(pop,rnd<=0.7) # Training sample

# Binning a factor variable on training data
result=smbinning.factor(train,x="home",y="fgood")

# Example: Append new binned characteristic to population
pop=smbinning.factor.gen(pop,result,"g1home")

# Split training
train=subset(pop,rnd<=0.7) # Training sample

# Check new field counts
table(train$g1home)
table(pop$g1home)





# Load library and its dataset
library(smbinning) # Load package and its data

# Binning a factor variable
result=smbinning.factor(chileancredit,x="inc",y="fgood", maxcat=11)
result$ivtable
