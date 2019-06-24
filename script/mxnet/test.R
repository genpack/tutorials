## Loading required package: mxnet
# Installation of mxnet:
# Preparation in OS
# :~ brew install opencv
# :~ brew install openblas
# :~ ln -sf /usr/local/opt/openblas/lib/libopenblas.dylib /usr/local/opt/openblas/lib/libopenblasp-r0.3.1.dylib
if (!require(mxnet)) {
  cran <- getOption("repos")
  cran["dmlc"] <- "https://apache-mxnet.s3-accelerate.dualstack.amazonaws.com/R/CRAN/"
  options(repos = cran)
  install.packages("mxnet")
}

if (!require(mlbench)) {
  install.packages('mlbench')
}

data(Sonar, package="mlbench")

Sonar[,61] = as.numeric(Sonar[,61])-1
train.ind = c(1:50, 100:150)
train.x = data.matrix(Sonar[train.ind, 1:60])
train.y = Sonar[train.ind, 61]
test.x = data.matrix(Sonar[-train.ind, 1:60])
test.y = Sonar[-train.ind, 61]

mx.set.seed(0)
model <- mx.mlp(train.x, train.y, hidden_node=10, out_node=2, out_activation="softmax",
                num.round=20, array.batch.size=15, learning.rate=0.07, momentum=0.9,
                eval.metric=mx.metric.accuracy)bag[[20]]
