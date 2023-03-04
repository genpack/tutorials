# option for function:
# "-3.1.2.3.2.1.-1"
# 5123217_0111110

## 1-Eulian mode (minor):
# abcdefg
distances = c(0, 2, 1, 2, 2, 1, 2, 2)

## 3-Eunian mode (major):
# cdefgab
distances = c(0, 2, 2, 1, 2, 2, 2, 1)

mode = 3
c(distances[1], distances[- sequence(mode)], distances[1+sequence(mode-1)])
c(distances[1], distances[c(-1, -2, -3)], distances[c(2, 3)])

SCALE = list(
  white = c(0, 2, 1, 2, 2, 1, 2, 2),
  harmonic = c(0, 2, 1, 2, 2, 1, 3, 1),
  chargah = c(0, 2, 1, 3, 1, 1, 3, 1))


mode  = 1
start = 'G'
scale = 'white'
scale_mode_distances = function(scale = 'white', mode = 1){
  distances = SCALE[[scale]]
  c(distances[1], distances[- sequence(mode)], distances[1+sequence(mode-1)])
}

scale_notes = function(scale = 'white', mode = 1, start = "A", sharp = T){
  dst = scale_mode_distances(scale = scale, mode = mode)
  shift_note(start, dst %>% cumsum, sharp = sharp)
}
  
fnotes = scale_notes(mode = 1, start = "A", sharp = F) 

fnotes = c("A", "D", "B_", "A#")

  
scale_steps_sharp = scale_notes(mode = 1, start = "D", sharp = T)  
scale_steps_flat  = scale_notes(mode = 1, start = "D", sharp = F)  

# fnotes %>% sapply(grep, x = scale_steps[-8])

get_function = function(notes, octaves = NULL, scale = 'white', mode = 1, start = "A"){
  scale_steps_sharp = scale_notes(mode = mode, start = start, sharp = T)  
  scale_steps_flat  = scale_notes(mode = mode, start = start, sharp = F)  
  func = notes %>% sapply(function(i, sharp, flat) which(i == sharp | i == flat), sharp = scale_steps_sharp[-8], flat = scale_steps_flat[-8]) %>% unlist
  rutils::assert(length(func) == length(notes), "Some of the given notes are out of scale!")
  out = func %>% paste(collapse = '')
  if(!is.null(octaves)){
    rutils::assert(length(octaves == length(notes)), 'Arguments `octave` and `notes` have different lengths!')
    locations = semitone(notes, octaves) - semitone(start, min(octaves)) + 12
    out %<>% paste(paste(as.integer(locations/12) - 1, collapse = ''), sep = '_')
  }
  return(out)
}


semitone = function(notes, octaves){
  octaves*12 + NOTE_ORDER[notes]
}


# What is the function of the given notes in F minor?
notes = c("c", "c", "e_", "d_", "a_", "b_", "c")
octaves = c(5,5,5,5,4,4,5)
func = get_function(notes, octaves , start = "f")


# inverse mapping:
func = "5576345_0000201"
fsplit = func %>% strsplit('_') %>% unlist

scale_notes = scale_notes(mode = mode, start = start, sharp = F)
starting_octave = 4
notes = scale_notes[fsplit[1] %>% strsplit('') %>% unlist %>% as.integer]
offsets = fsplit[2] %>% strsplit('') %>% unlist %>% as.integer
starting_octave + as.integer((- semitone(notes, 4) + semitone(start, 4) + 12*(offsets+1))/12)



function2note_octave(func = "5576345_0000000", mode = 1, start = "G")
