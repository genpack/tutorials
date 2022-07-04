# build_confif_from_mapper
fillna = function(df, items = ""){
  for(i in sequence(ncol(df))){
    wna = which(df[,i] %in% items)
    df[wna, i] <- NA
  }
  return(df)
}
mapper <- read.csv("Data/transactions_cba.csv", header = T, as.is = T) %>% fillna("")

if(file.exists('config.yml')){config = yaml::read_yaml('config.yml')} else {config = list()}

for (cat in unique(mapper$Category)){
  mers = mapper %>% filter(Category == cat) %>% pull(Merchant) %>% unique
  if(is.null(config[[cat]])){config[[cat]] <- list()}
  for(mer in mers){
    
    config[[cat]][[mer]] <- mapper %>% filter(Category == cat, Merchant == mer) %>% pull(Keyword) %>% unique
  }
}

config %>% yaml::write_yaml('config.yml')
