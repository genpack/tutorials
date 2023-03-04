# rmus
RMUSMOD = function(x, y){
  x - y*(x %/% y)
}

NOTES_SHARP = c('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')
NOTES_FLAT  = c('C', 'D_', 'D', 'E_', 'E', 'F', 'G_', 'G', 'A_', 'A', 'B_', 'B')
shift_note = function(input, halftunes = 2, sharp = T){
  if(length(input)>1){
    return(input %>% sapply(shift_note) %>% unlist)
  }
  ind = which(NOTES_SHARP == input)
  if(length(ind) == 0){
    ind = which(NOTES_FLAT == input)
    rutils::assert(length(ind) > 0, 'Unknown Note!')
  }
  
  ind = RMUSMOD(ind + halftunes, 12)
  ind[ind == 0] <- 12
  if(sharp) return(NOTES_SHARP[ind]) else return(NOTES_FLAT[ind])
}

chord_triad = function(input, major = T){
  
  rutils::chif(major, c(0, 4, 3), c(0, 3, 4)) -> nts
  
  input %>% shift_note(nts %>% cumsum)
}


