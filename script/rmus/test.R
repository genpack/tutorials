# rmus
mod = function(x, y){
  x - y*(x %/% y)
}

notes_sharp = c('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')
notes_flat  = c('C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B')
add_note = function(input, halftunes = 2){
  ind = which(notes_sharp == input)
  if(length(ind) == 0){
    ind = which(notes_flat == input)
    rutils::assert(length(ind) > 0, 'Unknown Note!')
  }
  
  ind = mod(ind + halftunes, 12)
  ind[ind == 0] <- 12
  return(notes_sharp[ind])
}

chord = function(input, major = T){
  
  rutils::chif(major, c(0, 4, 3), c(0, 3, 4)) -> nts
  
  input %>% add_note(nts %>% cumsum)
}
