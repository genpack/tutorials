PrecAndRecall <- function(TrueLabel,Res,Thresh){
  
  Ind1 <- which(TrueLabel==1)
  Ind0 <- which(TrueLabel==0)
  Positive <- which(Res >= Thresh)
  Negative <- which(Res < Thresh)
    
  TP <- length(intersect(Positive,Ind1))
  FP <- length(setdiff(Positive,Ind1))
  TN <- length(intersect(Negative,Ind0))
  FN <- length(setdiff(Negative,Ind0))
  Precision <- TP/(TP+FP)
  Recall <- TP/(TP+FN)
  Out <- data.frame(Precision=Precision,Recall=Recall)
  return(Out)
}

OutlierModification <- function(X,Thresh){
    SD <- sd(unique(X),na.rm = TRUE)
    Z <- (X -mean(X,na.rm = TRUE))/SD
    M <- max(abs(Z),na.rm = TRUE)
    
    while(M > Thresh){
      Ind <- which(Z>Thresh)
      if(length(Ind)>0){
        X[Ind] <- max(X[-Ind],na.rm = TRUE)
      }
      
      Ind <- which(Z < -Thresh)
      if(length(Ind)>0){
        X[Ind] <- min(X[-Ind],na.rm = TRUE)
      }
      SD <- sd(unique(X),na.rm = TRUE)
      Z <- (X -mean(X,na.rm = TRUE))/SD
      M <- max(abs(Z),na.rm = TRUE)
    }
    
    return(X)
  }

Normalize01 <- function(X){
  Max <- apply(X,2,max)
  Min <- apply(X,2,min)
  MaxMat <- matrix(rep(Max,nrow(X),ncol=ncol(X)),ncol=ncol(X),byrow = TRUE)
  MinMat <- matrix(rep(Min,nrow(X),ncol=ncol(X)),ncol=ncol(X),byrow = TRUE)
  X01 <- (X - MinMat)/(MaxMat-MinMat)
  
}


FindWord <- function(Pattern,Text){
  Temp <- gregexpr(Pattern,Text,ignore.case = TRUE)
  LL <- numeric()
  for(i in 1:length(Temp)){
    LL[i] <- (Temp[[i]][1])
  }
  Ind <- which(LL>-1)
  return(Text[Ind])
}


identical_cat_features <- function(DatCat,CatIdenticalFrac){
  n <- ncol(DatCat)
  EqualFrac <- matrix(NA,n,n)
  NObs <- nrow(DatCat)
  for(i in 1:(n-1)){
    for(j in (i+1):(n)){
      Temp1 <- length(which(DatCat[,i]==DatCat[,j]))
      EqualFrac[i,j] <- Temp1/NObs
    }
    print(i)
  }
  
  colnames(EqualFrac) <- colnames(DatCat)
  rownames(EqualFrac) <- colnames(DatCat)
  
  Ind <- c()
  for(i in 1:ncol(EqualFrac)){
    Ind <- c(Ind,which(EqualFrac[i,]>CatIdenticalFrac))
    
    print(i)
  }
  
  
  
  
  to_remove <- colnames(EqualFrac)[unique(Ind)]
  return(to_remove)
}


high_correlated_features <- function(dat_num,Cor){
  
  CorNum <- as.matrix(cor(dat_num))
  
  CorNum <- CorNum * upper.tri(CorNum,diag = FALSE)
  
  
  colnames(CorNum) <- colnames(dat_num)
  rownames(CorNum) <- colnames(dat_num)
  
  
  Ind <- c()
  for(i in 1:ncol(CorNum)){
    Ind <- c(Ind,which(CorNum[i,]>Cor))
  }
  
  
  to_remove <- colnames(CorNum)[unique(Ind)]
  return(to_remove)
}


PlotClassDist <- function(Prob,TrueLabel,Main=""){
  
  Ind1 <- which(TrueLabel==1)
  Ind0 <- which(TrueLabel==0)
  
  A1 <- density(Prob[Ind1])
  A0 <- density(Prob[Ind0])
  
  plot(A0$x,A0$y)
  plot(A0$x,A0$y/max(A0$y),type="l",ylab = "Density", xlab = "Probability",col="blue",lwd=2)
  lines(A1$x,A1$y/max(A1$y),col="red",lwd=2)
  
  
}

KFoldData <- function(Folds,k,X,Y){
  IndXTest <- which(Folds==k)
  IndXTrain <- c(1:nrow(X))[-IndXTest]
  XTrainFold <- X[IndXTrain,]
  YTrainFold <- Y[IndXTrain]
  XTestFold <- X[IndXTest,]
  YTestFold <- Y[IndXTest]
  Out <- list()
  Out$XTrain <- XTrainFold
  Out$YTrain <- YTrainFold
  
  Out$XTest <- XTestFold
  Out$YTest<- YTestFold
  return(Out)
}

FitTreeAndSVM <- function(Dat){
  label <- Dat$label
  Keep <- setdiff(colnames(Dat),"label")
  X <- Dat[,Keep]
  LL <- numeric()
  for(i in 1:ncol(X)){
    LL[i] <- sd(X[,i])
  }
  
  Ind <- which(LL<=.001)
  if(length(Ind)>0){
    X <- X[,-Ind]
  }
  
  
  AAA <- cor(X)
  BBB <- AAA*  upper.tri(AAA,diag = FALSE)
  LL <- which(abs(BBB)>=.98,arr.ind = TRUE)
  Ind <- unique(LL[,2])
  if (length(Ind)>0){
    X <- X[,-Ind]
  }
  
  X$label <- as.factor(label)
  ################################################################################
  ###############  Fit a decision tree ###########################################
  ################################################################################
  
  fit <- rpart(label ~ .,data=X ,parms = list(split = "auc"),
               method  =  "class",control = rpart.control(minsplit=2000,minbucket=1000,maxdepth=20,cp=-1))

  #################################################################################
  ########################## Fit another model for each leaf ######################
  
  Class <- unique(fit$where)
  ClassObs <- list()
  
  
  for(i in 1:length(Class)){
    ClassObs[[i]] <- which(fit$where==Class[i])
  }
  
  MM <- numeric()
  for(i in 1:length(Class)){
    # LL[i] <- length(ClassObs[[i]])
    MM[i] <- mean(label[ClassObs[[i]]])
  }
  
  Keep <- setdiff(colnames(X),"label")
  
  AllModels <- list()
  
  ZeroClasses <- Class[which(MM<="A small fraction")] ### Zero classes
  
  AllRes <- numeric(nrow(X)) +NA
  
  IndA <- which(MM > "A small fraction")
  
  for(i in IndA){
    Obs <- X[ClassObs[[i]],]
    Keep <- setdiff(colnames(Obs),"label")
    Obs1 <- Obs[,Keep]
    LL <- numeric()
    for(j in 1:ncol(Obs1)){
      LL[j] <- sd((Obs1[,j]))
    }
    
    Ind <- which(LL<= "A small fraction")
    
    if (length(Ind)>0){
      Obs1 <- Obs1[,-Ind]
    }
    
    
    AAA <- cor(Obs1)
    BBB <- AAA*  upper.tri(AAA,diag = FALSE)
    LL <- which(abs(BBB)>=.95,arr.ind = TRUE)
    Ind <- unique(LL[,2])
    if (length(Ind)>0){
      Obs1 <- Obs1[,-Ind]
    }
    Obs1$label <- Obs$label
    Keep1 <- setdiff(colnames(Obs1),"label")
    y1 <- as.numeric(paste(Obs1$label))
    
    ########################################## SVM ############################
    XX <- table(Obs1$label)
    wts <- XX/min(XX)
    AllC <- c(3)
    AllSig <- seq(0.05,.3,by=.1)
    
    AllCSig <- expand.grid(AllC,AllSig)
    
    AllErr <- matrix(0,nrow(AllCSig),2)
    
    AllATemp <- list()
    for(k1 in 1:nrow(AllCSig)){
      A <- ksvm(label~.,data=Obs1,kernel="rbfdot",C=AllCSig[k1,1],prob.model=TRUE,class.weights=wts,
                scale=FALSE,kpar=list(sigma=AllCSig[k1,2]),cross=4) #,cross=10
      AllErr[k1,] <- c(A@error,A@cross)
      AllATemp[[k1]] <- A
    }
    Temp <- AllErr[,2]
    Temp1 <- which(Temp==min(Temp,na.rm = TRUE))[1]
    AllModels[[Class[i]]] <- AllATemp[[Temp1]]

  }
  Out <- list()
  Out$ZeroClasses <- ZeroClasses
  Out$tree <- fit
  Out$LeafSVM <- AllModels
  return(Out)
  
}

GetLift <- function(TrueLabel,Res,Q){
  N <- length(Res)
  Base <- mean(TrueLabel)
  Temp <- sort(Res,decreasing = TRUE,index.return=TRUE)
  Ind <- Temp$ix[1:round(Q*N)]
  Prob <- Res[Ind]
  Label <- TrueLabel[Ind]
  Temp1 <-  PrecAndRecall(TrueLabel = Label,Res = Prob,Thresh = 0)
  Lift <- Temp1$Precision/Base
  return(Lift)
}

GetCumulativeGain <- function(TrueLabel,Res,Q){
  N <- length(Res)
  Temp <- sort(Res,decreasing = TRUE,index.return=TRUE)
  Gain <- numeric()
  N1 <- length(which(TrueLabel==1))
  for(i in 1:length(Q)){
    Ind <- Temp$ix[1:round(Q[i]*N)]
    Prob <- Res[Ind]
    Label <- TrueLabel[Ind]
    Gain[i] <- length(which(Label==1))/N1
  } 
  return(Gain)
}
 
connect_to_spark = function(){  
  config <- spark_config()
  config$spark.executor.memory <- "32G"
  config[['sparklyr.shell.driver-memory']] <- "32G"
  config[['sparklyr.shell.executor-memory']] <- "32G"
  config[['spark.driver.maxResultSize']] <- "4G"
  config$spark.yarn.executor.memoryOverhead <- "16g"
  spark_connect(master = "local", config = config)
}




get_mean_hist_plot <- function(dat_all,feature){

  mytheme <- gridExtra::ttheme_default(
    core = list(fg_params=list(cex = 0.8)),
    colhead = list(fg_params=list(cex = .7)),
    rowhead = list(fg_params=list(cex = .7)))
  
  dat_all$val <- OutlierModification(dat_all$val,Thresh = 3)
  
  
  all_date <- sort(unique(dat_all$eventTime))
  
  s <- matrix(0,length(all_date),3)
  ind_0 <- which(dat_all$label==0)
  dat_active <- dat_all[ind_0,]
  
  ind_1 <- which(dat_all$label==1)
  dat_churn <- dat_all[ind_1,]
  
  
  
  for(i in 1:length(all_date)){
    ind <- which(dat_all$eventTime==all_date[i])
    s[i,1] <- mean(dat_all$val[ind],na.rm = TRUE)
    
    ind <- which(dat_active$eventTime==all_date[i])
    s[i,2] <- mean(dat_active$val[ind],na.rm = TRUE)
    
    ind <- which(dat_churn$eventTime==all_date[i])
    s[i,3] <- mean(dat_churn$val[ind],na.rm = TRUE)
    
  }
  s <- as.data.frame(s)
  ylim<- c(min(s,na.rm = TRUE),max(s,na.rm = TRUE))
  
  colnames(s) <- c("all","active","churn")
  s$date <- all_date
  
  
  p1 <-  ggplot(data = s, mapping = aes(x = date)) +
    geom_line(aes(y=all),size=1.1,col="black")+
    geom_line(aes(y=active),size=1.1,col="blue") +
    geom_line(aes(y=churn),size=1.1,col="red")+
    scale_y_continuous(name="average")+
    theme( plot.margin = margin(1, 2, 0, 1, "cm"))+
    ggtitle(feature)
  
  
  x <- dat_all$val
  x1 <- dat_active$val
  x0 <- dat_churn$val
  x <- as.data.frame(x)
  x$x <- as.numeric(x$x)
  x$churn <- as.character(0)
  x$churn[ind_1] <- as.character(1)
  
  bin_width <- ((max(x$x,na.rm = TRUE)-min(x$x,na.rm = TRUE ))/50)
  p2 <- ggplot(x, aes(x, fill=churn)) +
    geom_histogram( aes(y=..density..),alpha=0.5, 
                    position="identity", lwd=0.2,binwidth = bin_width) +
    theme( plot.margin = margin(1, 1, 0, 1, "cm"))+
    scale_fill_manual(values=c("#0000FF","#FF0000"))
  
  mean_stat <- c(mean(dat_all$val,na.rm = TRUE),mean(dat_active$val,na.rm = TRUE),mean(dat_churn$val,na.rm = TRUE))
  mean_stat <- round(mean_stat,4)
  NA_frac <- c(length(which(is.na(dat_all$val)))/nrow(dat_all),length(which(is.na(dat_active$val)))/nrow(dat_active),
               length(which(is.na(dat_churn$val)))/nrow(dat_churn))
  NA_frac <- round(NA_frac,4)
  
  NA_churn_rate <- c(mean(dat_all$label[which(is.na(dat_all$val))]),NA,NA)
  
  NA_churn_rate <- round(NA_churn_rate,4)
  
  
  zero_frac <- c(length(which((dat_all$val==0)))/nrow(dat_all),length(which((dat_active$val==0)))/nrow(dat_active),
                 length(which((dat_churn$val==0)))/nrow(dat_churn))
  zero_frac <- round(zero_frac,4)
  
  zero_churn_rate <- c(mean(dat_all$label[which(dat_all$val==0)]),NA,NA)
  zero_churn_rate <- round(zero_churn_rate,4)
  
  df <- data.frame(mean=mean_stat,NA_frac=NA_frac,NA_churn_rate= NA_churn_rate,zero_frac=zero_frac,zero_churn_rate)
  row.names(df) <- c("All","Active","Churn")
  tbl <- gridExtra::tableGrob(df, theme = mytheme)
  tbl <- tableGrob(df)
  
  return(ggarrange(p1, p2,tbl, nrow = 3))

}


get_xgb_ensemble <- function(dat_train,dat_test,Params,n_ensemble,nthread){
  all_xgb_res <- list()
  all_train_prob <- list()
  all_feature_importance <- list()
  features <- setdiff(colnames(dat_train),c("caseID","eventTime","label"))
  dat_train_1 <- as.matrix(dat_train[,features])
  label_train <- dat_train$label                       
  dtrain <- xgb.DMatrix(dat_train_1, label = label_train)
  dat_test_1 <- dat_test[,features]
  label_test <- dat_test$label
  Z <- xgb.DMatrix(as.matrix(dat_test[,features]))
  n_row <- nrow(dat_train_1)
  n_col <- ncol(dat_train_1)
  
  for(i in 1:n_ensemble){
    Model <- xgboost(data = dtrain,
                       nrounds = Params[1],
                       max.depth = round(Params[2]),
                       min_child_weight = Params[3],
                       gamma = Params[4],
                       subsample = Params[5], #,
                       colsample_bytree = Params[6], #,
                       eta = Params[7],
                       objective = "binary:logistic",
                       eval_metric = "auc",
                       scale_pos_weight = 1,  
                       sigma= 8, 
                       nthread=nthread,
                       verbose = 0)
    
    all_feature_importance[[i]] <- xgb.importance(feature_names = Model$feature_names, model = Model)
    
    pred_res <- predict(Model,Z)
    a <- PrecAndRecall(TrueLabel = dat_test$label,Res = pred_res,Thresh = quantile(pred_res,1-mean(dat_test$label)))
    print(a)
    all_xgb_res[[i]] <- pred_res
    print(i)
    fname <- paste("results/XGB/test_res",i,".RData",sep="")
    gc()
  }
  
  x <- matrix(0,length(pred_res),n_ensemble)
  for(j in 1:length(all_xgb_res)){
    x[,j] <- all_xgb_res[[j]]
  }
  
  prrec <- numeric()
  AllGini <- numeric()
  AllLift2 <- numeric()
  for(i in 1:ncol(x)){
    temp <- x[,i]
    temp1 <- PrecAndRecall(TrueLabel = dat_test$label,Res = temp,Thresh = quantile(temp,1-mean(dat_test$label)))
    prrec[i] <- as.numeric(temp1[1])
    AllLift2[i] <- GetLift(TrueLabel = dat_test$label,Res = temp,Q = .02)
  }
  if(ncol(x)==1){
    AllRes1 <- x
  }else{
    AllRes1 <- apply(x[,],1,mean)
    
  }
  
  Res <- data.frame(label = dat_test$label,prob = AllRes1)
  
  prec_and_recall <- PrecAndRecall(TrueLabel = dat_test$label,Res = AllRes1,Thresh = quantile(AllRes1,1-mean(dat_test$label)))
  
  A <- pROC::roc(dat_test$label,as.numeric(AllRes1))
  Test <- pROC::auc(A)
  Gini <- 2 * Test -1
  
  Lift5 <- GetLift(TrueLabel = dat_test$label,Res = AllRes1,Q = .05)
  Lift2 <- GetLift(TrueLabel = dat_test$label,Res = AllRes1,Q = .02)
  Lift1 <- GetLift(TrueLabel = dat_test$label,Res = AllRes1,Q = .01)
  lift_churn_rate <- GetLift(TrueLabel = dat_test$label,Res = AllRes1,Q = mean(dat_test$label))
  res_final <- list()
  res_final$features <- colnames(dtrain)
  res_final$params <- Params
  res_final$res <- data.frame(caseID = dat_test$caseID, eventTime=dat_test$eventTime,prob=x)
  res_final$prec_and_recall_churn_rate <- prec_and_recall
  res_final$all_lift_2 <- AllLift2
  res_final$lift1 <- Lift1
  res_final$lift2 <- Lift2
  res_final$lift5 <- Lift5
  res_final$lift_churn_rate <- lift_churn_rate
  res_final$Gini <- Gini
  res_final$all_train_prob <- all_train_prob
  return(res_final)
}


get_data_for_xgb <- function(test_date,features_final,feature_folder){
  features_file <- paste(feature_folder,features_final,".RData",sep="")
  date_train_end <- as.character(mondate(test_date) - 3)
  date_train_start <- as.character(mondate(date_train_end) - 12)
  
  load(paste(feature_folder,"eventTime.RData",sep=""))
  event_time <- as.Date(z[,1])
  
  load(paste(feature_folder,"label.RData",sep=""))
  label <- z$label
  
  load(paste(feature_folder,"caseID.RData",sep=""))
  caseID <- z$caseID
  
  ind_test <- which(event_time == test_date)
  ind_train <- which(event_time <= date_train_end & event_time >= date_train_start)
  
  caseid_train <- caseID[ind_train]
  
  caseid_test <- caseID[ind_test]
  
  event_time_train <- event_time[ind_train]
  event_time_test <- event_time[ind_test]
  

  ###################################################################################
  ####################### data ##################################################
  
  
  dat_train <- matrix(0,length(ind_train),length(features_final))
  dat_test <- matrix(0,length(ind_test),length(features_final))
  
  n_unique <- numeric()
  for(i in 1:length(features_final)){
    load(features_file[i])
    ind <- which(z[,1]== -9999)
    if(length(ind)>0){
      z[ind,1] <- NA
    }
    z1 <- z[ind_train,1]
    n_unique[i] <- length(unique(z1))
    dat_train[,i] <- z1
    dat_test[,i] <- z[ind_test,1]
    print(i)
  }
  
  dat_train <- as.data.frame(dat_train)
  dat_test <- as.data.frame(dat_test)
  
  colnames(dat_train) <- features_final
  colnames(dat_test) <- features_final
  
  dat_train$eventTime <- event_time[ind_train]
  dat_test$eventTime <- event_time[ind_test]
  
  dat_train$caseID <- caseid_train
  dat_test$caseID <- caseid_test
  
  dat_train$label <- as.numeric(label[ind_train])
  dat_test$label <- as.numeric(label[ind_test])
  
  res <- list()
  res$dat_train <- dat_train
  res$dat_test <- dat_test
  return(res)
}

WeightedKNN <- function(Weight,XNew,XPool,NoNeighb,LabelPool,LabelNew){
  ### The input is a dataframe which has label and features. Data should be normalized
  NNew <- nrow(XNew)
  
  if(all(Weight==1)==1){
    XPoolW <- XPool
    XNewW <- XNew } else{ 
      NPool <- nrow(XPool)
      W1 <- matrix(rep(Weight,NPool),nrow=NPool,byrow = TRUE)
      XPoolW <- W1 * XPool
      
      W2 <- matrix(rep(Weight,NNew),nrow=NNew,byrow = TRUE)
      XNewW <- W2 * XNew  
    }
  
  
  DistMat <- as.matrix(pdist(XNewW,XPoolW))
  Res <- numeric()
  for(i in 1:NNew){
    Temp <- DistMat[i,]
    Temp1 <- sort(Temp,index.return=TRUE)
    Temp2 <- Temp1$x[2:(NoNeighb+1)]
    Res[i] <- sum(((1/Temp2)/sum(1/Temp2))* LabelPool[Temp1$ix[2:(NoNeighb+1)]])
  }
  Ind1 <- which(LabelNew==1)
  Ind0 <- which(LabelNew==0)
  
  A1 <- ecdf(Res[Ind1])
  A0 <- ecdf(Res[Ind0])
  
  X <- sort(Res)
  X1 <- A1(X)
  X0 <- A0(X)
  Out <-  -1 * sum(X0-X1)
  print(Out)
  return(Out)
}


dummify <- function(x,feature_name){
  UniqueVals <- sort(unique(x))
  temp <- matrix(0,length(x),length(UniqueVals))
  
  for(j in 1:length(UniqueVals)){
    ind <- which(x==UniqueVals[j])
    temp[ind,j] <- 1
  }
  names_f <- paste(feature_name,as.character(c(1:length(UniqueVals))),sep="_")
  colnames(temp) <- names_f
  return(temp)
}


