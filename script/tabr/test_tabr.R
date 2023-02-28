# test tabr
library(tabr)

x <- "a, c e g# a ac'e' ac'e'~ ac'e' a c' e' a'"
x <- as_noteworthy(x)
x
#> <Noteworthy string>
#>   Format: space-delimited time
#>   Values: a, c e g# a <ac'e'> <ac'e'~> <ac'e'> a c' e' a'

summary(x)
#> <Noteworthy string>
#>   Timesteps: 12 (9 notes, 3 chords)
#>   Octaves: tick
#>   Accidentals: sharp
#>   Format: space-delimited time
#>   Values: a, c e g# a <ac'e'> <ac'e'~> <ac'e'> a c' e' a'

y <- "a,8 c et8 g# a ac'e'4. ac'e'~8 ac'e'4 at4 c' e' a'1"
y <- as_music(y)
summary(y)
#> <Music string>
#>   Timesteps: 12 (9 notes, 3 chords)
#>   Octaves: tick
#>   Accidentals: sharp
#>   Key signature: c
#>   Time signature: 4/4
#>   Tempo: 2 = 60
#>   Lyrics: NA
#>   Format: space-delimited time
#>   Values: a,8 c8 et8 g#t8 at8 <ac'e'>4. <ac'e'~>8 <ac'e'>4 at4 c't4 e't4 a'1

plot_music(y)

############################

x <- "a#4-+ b_[staccato] c,x d''t8( e)( g_')- a4 c,e_,g, ce_g4. a~8 a1"
is_music(x)
musical(x)
x <- as_music(x)
is_music(x)
x
plot_music(x)
x %>% render_music(file = 'out_test.pdf')


as_music_df(x) -> df

m = as_music(notes = df$pitch, info = df$duration)
to_tabr(df)
x
m
############################


music_split(y)
#> $notes
#> <Noteworthy string>
#>   Format: space-delimited time
#>   Values: a, c e g# a <ac'e'> <ac'e'~> <ac'e'> a c' e' a'
#> 
#> $info
#> <Note info string>
#>   Format: space-delimited time
#>   Values: 8 8 t8 t8 t8 4. 8 4 t4 t4 t4 1
#> 
#> $lyrics
#> [1] NA
#> 
#> $key
#> [1] "c"
#> 
#> $time
#> [1] "4/4"
#> 
#> $tempo
#> [1] "2 = 60"




##############################################################################

### noteworthy class:
notes <- as_noteworthy("c d e d c r*3 e g c'")
class(notes)


### chord builder:
# builds a triad for each note given and returns a list of chords
chords = chord_maj(notes, key = "c", octaves = "tick")
class(chords)

### convert music to dataframe
x <- "a,8 c e r r c a, g#, a ac'e'"
music = as_music(x)
class(music) 
music %>% as_music_df() -> df



### Lyrics:

x <- "These are the ly- rics . . . to this song"
is_lyrics(x)
lyrical(x)
lyrics = as_lyrics(x)

class(lyrics)

# character vector; empty, period or NA for no lyric
x <- c("These", "are", "the", "ly-", "rics",
       "", ".", NA, "to", "this", "song") #
as_lyrics(x)

# generate empty lyrics object from noteworthy, noteinfo or music object
lyrics = lyrics_template(notes)



lyrics[1:5] <- strsplit("These are the ly- rics", " ")[[1]]
lyrics[9:11] <- c("to", "this", "song")

### 

plot_music(
  music = music,
  clef = "treble",
  tab = FALSE,
  tuning = "standard",
  string_names = NULL,
  header = NULL,
  paper = NULL,
  colors = NULL,
  transparent = FALSE,
  res = 300
)

#### Read midi files:

res = read_midi("C:/Users/nima_/Dropbox/music/nirasongsEthod/ETOD4APR20.mid")
View(res)

res %>% midi_notes(noteworthy = T)



