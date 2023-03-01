
###### BUILD SNOTE MAPPER #############################################
all_snotes = 'ormtslicdefgabCDEFGABORMTSLI' %>% strsplit('') %>% unlist
snote_mapper = list(
  C = 'cdefgabcdefgabcdefgabcdefgab' %>% strsplit('') %>% unlist  %>%
    {names(.)<-all_snotes;.})
  
for(key in c("Cm", "D", "Dm", "E", "Em", "F", "Fm", "G", "Gm", "Am", "B")){
  snote_mapper[[key]] <- snote_mapper[['C']]
}

snote_mapper[['A']] = snote_mapper[['C']]

snote_mapper[['Dm']][strsplit('biBI', '') %>% unlist] %<>% paste0('_')
snote_mapper[['F']] = snote_mapper[['Dm']]

snote_mapper[['G']][strsplit('gsGS','') %>% unlist] %<>% paste0('#')
snote_mapper[['Em']] = snote_mapper[['G']]

snote_mapper[['Gm']][strsplit('beimBEIM','') %>% unlist] %<>% paste0('_')
snote_mapper[['Bb']] = snote_mapper[['Gm']]

snote_mapper[['D']][strsplit('ftcoFTCO','') %>% unlist] %<>% paste0('#')
snote_mapper[['Bm']] = snote_mapper[['D']]

snote_mapper[['Cm']][strsplit('meEMibBIlaAL','') %>% unlist] %<>% paste0('_')
snote_mapper[['Eb']] = snote_mapper[['Cm']]

snote_mapper[['A']][strsplit('cfgotsCFGOTS','') %>% unlist] %<>% paste0('#')
snote_mapper[['Gbm']] = snote_mapper[['A']]

snote_mapper[['Fm']][strsplit('meEMibBIlaALdrDR','') %>% unlist] %<>% paste0('_')
snote_mapper[['Ab']] = snote_mapper[['Fm']]

snote_mapper[['E']][strsplit('cfgotsCFGOTSdrDR','') %>% unlist] %<>% paste0('#')
snote_mapper[['Dbm']] = snote_mapper[['E']]

# 5 or more signatures have not been supported yet.
start = 2
for(key in names(snote_mapper)){
  snote_mapper[[key]] %<>% paste0(c(rep(start,7), rep(start+1,7), rep(start+2,7), rep(start+3,7))) %>% 
    {names(.)<-all_snotes;.}
}

