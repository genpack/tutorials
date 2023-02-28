# gm_tools


## todo: add more arguments and customise defaults like Meter, key, Clef, ...
## todo: merge rows for gm to create ties
musicaidf2gm = function(df, key = -2){
  df %<>% filter(duration > 0)
  df$pitch = df$note %>% stringr::str_replace(pattern = '_', replacement = '-') %>% 
    toupper %>% paste0(df$octave)
  df$pitch[df$note == 'r'] <- NA

  if(is.null(df$track)){df$track = 'melody'}
  tracks = unique(df$track)  
  
  m = Music() + Meter(4,4) + Key(key)
  for(tr in tracks){
    dft = df %>% dplyr::filter(track == tr)
    m = m + Line(pitches = dft$pitch %>% as.list, 
                 durations = (dft$duration/2) %>% as.list,
                 name = tr) + Clef('G', to = tr)
  }

  return(m)  
}