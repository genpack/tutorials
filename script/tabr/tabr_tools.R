# tabr_tools

# todo: move to musicai_tools
is_musicai_df = function(df){
  is_issue = mel %>% group_by(measure) %>% summarise(sumdur = sum(duration)) %>% 
    pull(sumdur) %>% {.!=8} %>% sum %>% as.logical
  is_issue = is_issue & (is.na(mel$octave[mel$note != 'r']) %>% sum)
  return(!is_issue)
}

# todo: move to rutils
## converts given integer number to sum of powers of 2
# for example: 7 = 1 + 2 + 4
breaksum_p2 = function(x){
  b = 1
  set = c()
  for (i in as.integer(intToBits(x))){
    if(i > 0){
      set = c(set, b)
    }
    b = b*2
  }
  return(set)
}


# Convert a musicai data.frame into a tabr music object:
musicaidf2tabr = function(df, ...){
  rutils::assert(is_musicai_df(df), "Error (change later)")
  
  df$octave[df$note == 'r'] <- ''

  cf = 1
  while  (sum(as.integer(df$duration) != df$duration) != 0){
   cf = cf*2
   df$duration = df$duration*2
  }
  
  df$durint = 8.0*cf/df$duration
  df$durchr = as.character(df$durint)
  w = which(df$durint != as.integer(df$durint))
  df[w,]
  for (i in w){
   breaks = breaksum_p2(df$duration[i]) %>% rev
   suffix = rep('.', length(breaks) - 1) %>% paste(collapse = '')
   df$durchr[i] = as.integer(cf*8/breaks[1]) %>% paste0(suffix)
  }

  # Apply tags:
  if(!is.null(df$tage)){
    # Apply tie tags:
    df$note[grep(x = df$tags, pattern = 'tie')] %<>% paste0('~') 
  }

  # Apply lyrics:
  if(!is.null(df$lyrics)){
    lyrics = as_lyrics(df$lyrics)
  } else {lyrics = NA}
  

  as_music(notes = paste0(df$note, df$octave),
           info  = df$durchr, lyrics = lyrics, 
           labels = df$chord, ...)         
}
