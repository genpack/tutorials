
### The input of this code is a data frame which has caseID, eventTime and some other features.
### It plots the monthly average of the feature for all, churners and active customers for all month or specifed month
### It plots the histogram or churner and non churnes. The churners and active customers are shown by orange and blue colors respectively
### It als produce a table which showws the fraction of NA and zero inputs for the feature seperately for all,churners and non-churner customers  
### At the end of all lots will be combined in one single file.

#### Setup #####
source('R_Pipeline/initialize.R')
load_package('rbig', version = rbig.version)

library(plotrix)
library(ggpubr)
library(gridExtra)
library(ggplot2)
library(pdftools)
library(staplr)
library(arrow)

source("R_Pipeline/libraries/ptools.R")
################ Inputs ################
eda_config = list(
  start_date = "2018-01-01",
  end_date   = "2021-03-01",
  target = 'ERPS',
  horizon = 3,
  output = 'eda_out.pdf'
)

################ Read Data ################
wt <- readRDS(sprintf("%s/wide.rds", path_ml))


catjson <- fromJSON(paste(readLines(path_ml %>% paste("categorical_encodings.json", sep = '/'), collapse="")))
categorical_features <- names(catjson)

eventTime <- as.Date(wt[['eventTime']])

ind_dat <- which(eventTime >= eda_config$start_date & eventTime <= eda_config$end_date)

wt <- wt[ind_dat,]

eventTime <- as.Date(wt[['eventTime']])
caseID    <- wt[['caseID']]
label     <- get_labels(wt, mc, target = eda_config$target, horizon = eda_config$horizon)

ind_1 <- which(label == 1)
ind_0 <- which(label == 0)

all_date <- sort(unique(eventTime))

features <- setdiff(colnames(wt),c("eventTime","caseID"))

out_path = mc$path_reports %>% paste(id_ml, sep = '/')
if(!file.exists(out_path)) {dir.create(out_path)}
out_path %<>% paste('eda', sep = '/')
if(!file.exists(out_path)) {dir.create(out_path)}
# out_path = out_path %>% paste(eda_config$output, sep = '/')

mytheme <- gridExtra::ttheme_default(
  core = list(fg_params=list(cex = 0.8)),
  colhead = list(fg_params=list(cex = .7)),
  rowhead = list(fg_params=list(cex = .7)))

for(k in 1:length(features)){
  feature <- features[k]
  s <- matrix(0,length(all_date),3)
  dat_all <- data.frame(eventTime= eventTime,data=wt[,feature])
  x <- dat_all$data
  no_unique <- length(unique(x))
  ind <- which(dat_all[,"data"]== -9999)
  if(length(ind)>0){
      dat_all[ind,"data"] <- NA
  }
  if( !(feature %in% categorical_features) &  no_unique > 3){
    x1 <- OutlierModification(dat_all[,"data"],4)
    dat_all[,"data"] <- x1
  }
  
  if(no_unique>=2){
    dat_churn <- dat_all[ind_1,]
    dat_active <- dat_all[ind_0,]
    
    for(i in 1:length(all_date)){
      ind <- which(dat_all$eventTime==all_date[i])
      s[i,1] <- mean(dat_all[ind,"data"],na.rm = TRUE)
      
      ind <- which(dat_active$eventTime==all_date[i])
      s[i,2] <- mean(dat_active[ind,"data"],na.rm = TRUE)
      
      ind <- which(dat_churn$eventTime==all_date[i])
      s[i,3] <- mean(dat_churn[ind,"data"],na.rm = TRUE)
      
    }
    s <- as.data.frame(s)
    ylim<- c(min(s,na.rm = TRUE),max(s,na.rm = TRUE))
    
    colnames(s) <- c("all","active","churn")
    s$date <- as.Date(all_date)
    
    
    p1 <-  ggplot(data = s, mapping = aes(x = date)) +
      geom_line(aes(y=all),size=1.1,col="black")+
      geom_line(aes(y=active),size=1.1,col="blue") +
      geom_line(aes(y=churn),size=1.1,col="red")+
      scale_y_continuous(name="average")+
      theme( plot.margin = margin(1, 2, 0, 1, "cm"))+
      ggtitle(feature)
    
    
    x <- dat_all[,"data"]
    x1 <- x[ind_1]
    x0 <- x[ind_0]
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
    
    mean_stat <- c(mean(dat_all[,"data"],na.rm = TRUE),mean(dat_active[,"data"],na.rm = TRUE),mean(dat_churn[,"data"],na.rm = TRUE))
    mean_stat <- round(mean_stat,4)
    NA_frac <- c(length(which(is.na(dat_all[,"data"])))/nrow(dat_all),length(which(is.na(dat_active[,"data"])))/nrow(dat_active),
                 length(which(is.na(dat_churn[,"data"])))/nrow(dat_churn))
    NA_frac <- round(NA_frac,4)
    
    zero_frac <- c(length(which((dat_all[,"data"]==0)))/nrow(dat_all),length(which((dat_active[,"data"]==0)))/nrow(dat_active),
                   length(which((dat_churn[,"data"]==0)))/nrow(dat_churn))
    zero_frac <- round(zero_frac,4)
    
    df <- data.frame(mean=mean_stat,NA_frac=NA_frac,zero_frac=zero_frac)
    row.names(df) <- c("All","Active","Churn")
    tbl <- gridExtra::tableGrob(df, theme = mytheme)
    tbl <- tableGrob(df)
    
    ggarrange(p1, p2,tbl, nrow = 3)
    fname <- paste0(out_path, '/', feature, ".pdf")
    ggsave(fname, width = 15, height = 20, units = "cm")
    "Chart for feature %s created." %>% sprintf(feature) %>% cat('\n')
  }
}
  
pdf_files <- paste0(out_path, "/", features, ".pdf") %^% paste(out_path, list.files(out_path), sep = '/')

file.rename(pdf_files[1], paste(out_path, 'Full1.pdf', sep = '/'))
"%s added to the report." %>% sprintf(pdf_files[1]) %>% cat('\n')

for(i in 2:length(pdf_files)){
  pdf_combine(c(paste0(out_path, "/Full",i-1,".pdf"), pdf_files[i]), output = paste0(out_path, "/Full",i,".pdf"))
  file.remove(paste0(out_path, "/Full",i-1,".pdf"))
  "%s added to the report." %>% sprintf(pdf_files[i]) %>% cat('\n')
}

file.rename(paste0(out_path, "/Full",i,".pdf"), paste(out_path, eda_config$output, sep = '/')) 


