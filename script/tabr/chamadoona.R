library(magrittr)
library(dplyr)
library(tabr)


read.csv('script/gm/data/chamadoona_v2.csv') -> mel
# mel %>% write.csv('script/gm/data/chamadoona.csv', row.names = F)

View(mel)

is_issue = mel %>% group_by(measure) %>% summarise(sumdur = sum(duration)) %>% 
  pull(sumdur) %>% {.!=8} %>% sum %>% as.logical
is_issue = is_issue & (is.na(mel$octave[mel$note != 'r']) %>% sum)

rutils::assert(!is_issue, "Ërror")



## tools:


#### For tabr:

df = mel
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

if(!is.null(df$tage)){
  # Apply tie tags:
  df$note[grep(x = df$tags, pattern = 'tie')] %<>% paste0('~') 
}

as_music(notes = paste0(df$note, df$octave),
         info  = df$durchr, lyrics = as_lyrics(df$lyrics),
         labels = df$chord,
         key = 'gm') -> x

x %>% render_music(file = 'out2.pdf')



