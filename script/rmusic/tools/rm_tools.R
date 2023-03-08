##
# rmus
library(magrittr)
library(dplyr)

RMUSMOD = function(x, y){
  x - y*(x %/% y)
}

NOTES_SHARP = c('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B') %>% tolower
NOTES_FLAT  = c('C', 'D_', 'D', 'E_', 'E', 'F', 'G_', 'G', 'A_', 'A', 'B_', 'B') %>% tolower
FLAT2SHARP  = NOTES_SHARP %>% {names(.)<-NOTES_FLAT;.}
SHARP2FLAT  = NOTES_FLAT  %>% {names(.)<-NOTES_SHARP;.}

NOTE_ORDER  <- c(1:12, 2, 4, 7, 9, 11)
names(NOTE_ORDER)<-union(NOTES_FLAT, NOTES_SHARP)

KEY2SCALE = rep('white', 60)  
names(KEY2SCALE) = NOTES_FLAT %>% toupper %>% 
  gsub(pattern = "_", replacement = 'b') %>% 
  c(paste0(.,'m'), paste0(.,7), paste0(., 'm7'), paste0(., 'dim'))

KEY2MODE = rep(3,12) %>% c(rep(1,12), rep(7,12), rep(1, 12), rep(2, 12))
names(KEY2MODE) = names(KEY2SCALE)

KEY2START = rep(NOTES_FLAT, 5)  
names(KEY2START) = names(KEY2MODE)

SCALE = list(
  white = c(0, 2, 1, 2, 2, 1, 2, 2),
  harmonic = c(0, 2, 1, 2, 2, 1, 3, 1),
  # chargah = c(0, 2, 1, 3, 1, 1, 3, 1))
  chargah = c(0, 1, 3, 1, 2, 1, 3, 1))

###############################################################################
rythm2duration = function(rythm, target_unit = 1/8){
  rsplit = rythm %>% strsplit('_') %>% unlist
  rsplit[1] %>% strsplit('') %>% unlist %>% 
    strtoi(32L) %>% {.[.==0]<-32;.} -> duration
  rythm_unit = 1.0/sum(duration)
  rutils::assert(rythm_unit %in% c(1,1/2,1/4,1/8,1/12,1/16,1/24,1/32), "Durations dont fit in a measure!")
  duration = duration*rythm_unit/target_unit
  rutils::assert(sum(duration)*target_unit == 1.0, "Durations dont fit a measure!")
  return(duration)
}

cpitch2pitch = function(cpitch, rythm){
  rsplit = rythm %>% strsplit('_') %>% unlist
  isrest = rsplit[2] %>% strsplit('') %>% 
    unlist %>% as.integer %>% as.logical %>% {!.}
  nn = length(cpitch)
  rutils::assert(
    sum(!isrest) == nn, 
    sprintf("Given rythm %s does not match number of notes in the given cpitch %s!", rythm, paste(cpitch, collapse = ';')))
  pitch = rep('r', nn)
  pitch[!isrest] <- cpitch
  return(pitch)
}

pitchDuration2rythm = function(pitch, duration){
  rutils::assert(length(pitch) == length(duration), 'Arguments `pitch` and `duration` have different lengths!')
  
  BASE32MAP <- c(as.character(1:9), letters[1:22], '0')
  
  paste(
    BASE32MAP[duration %>% as.numeric %>% {./min(.)}] %>% paste(collapse = ''), 
    as.integer(pitch != 'r') %>% paste(collapse = ''),
    sep = '_')
}


# Applies rythm and cpitch to each measure 
# input mpr is a Measure Per Row(MPR) dataframe where these columns are expected:
# `cpitch`, `rythm`
# combines cpitch and rythm into pitch and duration that matches the standard 
# rmus format for building a standard rmus music dataframe 
# This function generates vales in columns `pitch`` and `duration`
# and returns the data frame
# the values in `pitch` and `duration` columns are string character and contain 
# pitches and durations of each measure which are concatenated with separator semicolon.
apply_rythms = function(mpr, target_unit = 1/8){
  measures = which(!is.na(mpr$rythm) & !is.na(mpr$cpitch))
  for(i in measures){
    pitchdur = mpr$cpitch[i] %>% strsplit(";") %>% unlist %>% 
      cpitchRythm2pitchDuration(mpr$rythm[i], target_unit = target_unit)
    mpr$pitch[i] <- pitchdur$pitch %>% paste(collapse = ";")
    mpr$duration[i] <- pitchdur$duration %>% paste(collapse = ";")
  }
  return(mpr)
}

mpr2rmusdf = function(mpr){
  measures = which(!is.na(mpr$duration) & !is.na(mpr$pitch))
  out = NULL
  for(i in measures){
    out %<>% rbind(data.frame(duration = mpr$duration[i] %>% strsplit(';') %>% unlist, 
               pitch = mpr$pitch[i] %>% strsplit(';') %>% unlist,
               measure = i))
  }
  out$note = out$pitch %>% strsplit("[0-9]") %>% unlist
  out$octave = out$pitch %>% gsub(pattern = "[a-z,_#]", replacement = "") %>% unlist
  out$octave[out$octave == 'r'] <- NA
  return(out)
}



semitone = function(notes, octaves){
  octaves*12 + NOTE_ORDER[notes]
}


shift_note = function(input, halftunes = 2, sharp = T){
  if(length(input)>1){
    return(input %>% sapply(shift_note, halftunes = halftunes, sharp = sharp) %>% unlist)
  }
  ind = which(NOTES_SHARP == input)
  if(length(ind) == 0){
    ind = which(NOTES_FLAT == input)
    rutils::assert(length(ind) > 0, sprintf('Unknown Note! %s', input))
  }
  
  ind = RMUSMOD(ind + halftunes, 12)
  ind[ind == 0] <- 12
  if(sharp) return(NOTES_SHARP[ind]) else return(NOTES_FLAT[ind])
}

chord_triad = function(input, major = T){
  
  rutils::chif(major, c(0, 4, 3), c(0, 3, 4)) -> nts
  
  input %>% shift_note(nts %>% cumsum)
}

  
scale_mode_distances = function(scale = 'white', mode = 1){
  distances = SCALE[[scale]]
  c(distances[1], distances[- sequence(mode)], distances[1+sequence(mode-1)])
}

scale_notes = function(scale = 'white', mode = 1, start = "a", sharp = T){
  dst = scale_mode_distances(scale = scale, mode = mode)
  shift_note(start, dst %>% cumsum, sharp = sharp)
}


note_ocvtave2function = function(notes, octaves = NULL, scale = 'white', mode = 1, start = "a"){
  scale_steps_sharp = scale_notes(mode = mode, start = start, sharp = T)  
  scale_steps_flat  = scale_notes(mode = mode, start = start, sharp = F)  
  func = notes %>% sapply(function(i, sharp, flat) which(i == sharp | i == flat), sharp = scale_steps_sharp[-8], flat = scale_steps_flat[-8]) %>% unlist
  rutils::assert(length(func) == length(notes), "Some of the given notes are out of scale!")
  out = func %>% paste(collapse = '')
  if(!is.null(octaves)){
    rutils::assert(length(octaves == length(notes)), 'Arguments `octave` and `notes` have different lengths!')
    locations = semitone(notes, octaves) - semitone(start, min(octaves)) + 12
    locations = as.integer(locations/12)
    out %<>% paste(paste(locations - min(locations), collapse = ''), sep = '_')
  }
  return(out)
}

function2note_octave = function(func, scale = 'white', mode = 1, start = "a", starting_octave = 4){
  if(length(func) > 1){
    return(func %>% lapply(function2note_octave, scale = scale, mode = mode, start = start))
  }
  
  fsplit = func %>% strsplit('_') %>% unlist
  
  scale_notes = scale_notes(mode = mode, start = start, sharp = F)
  notes = scale_notes[fsplit[1] %>% strsplit('') %>% unlist %>% as.integer]
  
  offsets = fsplit[2] %>% strsplit('') %>% unlist %>% as.integer
  
  #a = semitone(notes, 4) - semitone(start, 4) 
  #a[a<0] = a[a<0]+12
  #octaves = starting_octave + as.integer((a + offsets*12)/12)
  
  octaves = starting_octave + as.integer((- semitone(notes, 4) + semitone(start, 4) - 1 + 12*(offsets+1))/12)
  return(list(note = notes, octave = octaves))
}

pitch2function = function(pitch, ...){
  pitch = pitch[pitch != 'r']
  if(length(pitch) == 0){return('_')}
  notes = pitch %>% strsplit("[0-9]") %>% unlist
  octaves = pitch %>% gsub(pattern = "[a-z,_#]", replacement = "") %>% 
    unlist %>% as.integer
  
  return(note_ocvtave2function(notes, octaves, ...))
}

function2pitch = function(func, ...){
  paster  = function(u) paste0(u$note, u$octave)
  noctave = function2note_octave(func = func, ...)
  if(length(func)==1){
    return(paster(noctave))
  } else {
    return(noctave %>% lapply(paster))
  }
}

# todo:
# function2pitch

# MPR Functions:

get_scale_mode_start = function(mpr, key = NULL, scale = NULL, mode = NULL, start = NULL){
  
  key    = rutils::verify(key, 'character', lengths = 1, null_allowed = T)
  scale  = rutils::verify(scale, 'character', lengths = 1, default = 'white')
  mode   = rutils::verify(mode, c('numeric', 'integer', 'character'), lengths = 1, default = 1)
  start  = rutils::verify(start, 'character', lengths = 1, default = 'a')
  
  if(!is.null(key)){
    if(key %in% names(KEY2MODE)){
      keys = rep(key, nrow(mpr))
    } else {
      rutils::assert(!is.null(mpr[[key]]), "Given mpr table has no column %s!" %>% sprintf(key))
      keys = mpr[[key]]
    }
    # assign scale, mode and start
    return(list(scales = KEY2SCALE[keys], modes = KEY2MODE[keys], starts = KEY2START[keys]))
  } else {
    if(is.null(mpr[[scale]])){
      scales = rep(scale, nrow(mpr))
    } else {
      scales = mpr[[scale]]
    }
    if(inherits(mode, 'character')){
      rutils::assert(!is.null(mpr[[mode]]), "Given mpr table has no column %s!" %>% sprintf(mode))
      modes = mpr[[mode]]
    } else {
      modes = rep(mode, nrow(mpr))
    }
    if(is.null(mpr[[start]])){
      starts = rep(start, nrow(mpr))
    } else {
      rutils::assert(!is.null(mpr[[start]]), "Given mpr table has no column %s!" %>% sprintf(start))
      starts = mpr[[start]]
    }
  }
  
  return(list(scales = scales, modes = modes, starts = starts))
}

mpr.add_function = function(mpr, pitch = 'pitch', output = 'function', key = NULL, scale = NULL, mode = NULL, start = NULL){
  sms = get_scale_mode_start(mpr, key = key, scale = scale, mode = mode, start = start)
  for(i in sequence(nrow(mpr))){
    p = mpr[i, pitch] %>% strsplit(";") %>% unlist
    f = try(pitch2function(p, scale = sms$scales[i], mode = sms$modes[i], start = sms$starts[i]), silent = T)
    if(inherits(f, 'try-error')){
      f = '!-!'
    }
    mpr[i, output] <- f
  }  
  # mpr[[pitch]] %>% 
  #   strsplit(";") %>% 
  #   lapply(function(u) try(pitch2function(u, ...), silent = T)) %>% 
  #   unlist -> mpr[[output]]
  return(mpr)
}

mpr.add_cpitch_from_function = function(mpr, func = 'function', output = 'cpitch', key = NULL, scale = NULL, mode = NULL, start = NULL, ...){
  sms = get_scale_mode_start(mpr, key = key, scale = scale, mode = mode, start = start)
  rws = which(!is.na(sms$scales) & !is.na(sms$modes) & !is.na(sms$starts))
  for(i in rws){
    mpr[i, func] %>% function2pitch(scale = sms$scales[i], mode = sms$modes[i], start = sms$starts[i], ...) %>% 
      paste(collapse = ";") -> mpr[i, output]
  }
  # mpr[[func]] %>% function2pitch(...) %>% lapply(paste, collapse = ";") -> mpr[[output]]
  return(mpr)
}

mpr.add_cpitch_from_snote = function(mpr, snote = 'snote', octave = 2, output = "cpitch", ...){
  mpr[[snote]] %>% 
    sapply(snote2cpitch, ...) %>% 
    lapply(paste, collapse = ";") %>% unlist -> mpr[[output]]
  return(mpr)
}

mpr.add_duration = function(mpr, cpitch = 'cpitch', rythm = 'rythm', output = "duration", target_unit = 1/8){
  measures = which(!is.na(mpr[[rythm]]) & !is.na(mpr[[cpitch]]))
  for(i in measures){
    rythm2duration(mpr[i, rythm], target_unit = target_unit) %>% 
      paste(collapse = ";") -> mpr[i, output]
  }
  return(mpr)
}

mpr.add_pitch = function(mpr, cpitch = 'cpitch', rythm = 'rythm', output = "pitch"){
  measures = which(!is.na(mpr[[rythm]]) & !is.na(mpr[[cpitch]]))
  for(i in measures){
    pitch = mpr[i, cpitch] %>% strsplit(";") %>% unlist %>% 
      cpitch2pitch(rythm = mpr[i, rythm])
    mpr[i, output] <- pitch %>% paste(collapse = ";")
  }
  return(mpr)

}

# single track
mpr2rmd = function(mpr, pitch = NULL, duration = NULL, chord = NULL, track = "melody", channel = 0){
  pitch     = rutils::verify(pitch, 'character', domain = colnames(mpr), lengths = 1, null_allowed = F)
  duration  = rutils::verify(duration, 'character', domain = colnames(mpr), lengths = 1, null_allowed = F)
  chord     = rutils::verify(chord, 'character', domain = colnames(mpr), lengths = 1, null_allowed = T)
  
  rmdf = NULL
  for(i in sequence(nrow(mpr))){
    measure_pitches = strsplit(mpr[i, pitch], ';') %>% unlist
    if(length(measure_pitches) == 0){measure_pitches = 'r'}
    measure_notes = measure_pitches %>% strsplit("[0-9]") %>% unlist
    measure_octaves = measure_pitches %>% gsub(pattern = "[a-z,_#]", replacement = "")
      
    measure_notes = 
    data.frame(
      measure = i, 
      track = track,
      channel = channel,
      pitch = measure_pitches,
      note = measure_notes,
      octave = measure_octaves %>% as.integer,
      duration = strsplit(mpr[i, duration], ';') %>% unlist %>% as.numeric
    ) -> rmdfi
    if(!is.null(chord)){
      rdmi$chord = mpr[i, chord]
    }
    rmdf %<>% rbind(rmdfi)
  }
  return(rmdf)
}


rmd2mpr = function(rmd){
  paste_semicolon = function(u) paste(u, collapse = ';')
  
  # rmd %>% reshape2::dcast(measure ~ track, value.var = 'duration', fun.aggregate = sum)
  rmd$pitch = rmd$note %>% tolower %>% paste0(rmd$octave)
  rmd$pitch[rmd$note == 'r'] <- "r"
  pitches   = rmd %>% reshape2::dcast(measure ~ track, value.var = 'pitch', fun.aggregate = paste_semicolon)
  durations = rmd %>% reshape2::dcast(measure ~ track, value.var = 'duration', fun.aggregate = paste_semicolon)
  colnames(pitches)[-1] %<>% paste('pitch', sep = '_')  
  colnames(durations)[-1] %<>% paste('duration', sep = '_')  
  out = pitches %>% left_join(durations, by = 'measure')

  if(!is.null(rmd$part)){
    paste_unique = function(u) paste(unique(u), collapse = '-')
    parts   = rmd %>% reshape2::dcast(measure ~ track, value.var = 'part', fun.aggregate = paste_unique)
    colnames(parts)[-1] %<>% paste('part', sep = '_')  
    out %<>% left_join(parts, by = 'measure')
  }
  if(!is.null(rmd$chord)){
    paste_unique = function(u) paste(unique(u[nchar(u)>0]), collapse = '/')
    chords   = rmd %>% reshape2::dcast(measure ~ track, value.var = 'chord', fun.aggregate = paste_unique)
    colnames(chords)[-1] %<>% paste('chord', sep = '_')  
    out %<>% left_join(chords, by = 'measure')
  }

  if(!is.null(rmd$lyrics)){
    paste_space = function(u) paste(u, collapse = ' ')
    lyrics   = rmd %>% reshape2::dcast(measure ~ track, value.var = 'lyrics', fun.aggregate = paste_space)
    colnames(lyrics)[-1] %<>% paste('lyrics', sep = '_')  
    out %<>% left_join(lyrics, by = 'measure')
  }
  
  return(out)
  
}


# todo: move to musicai_tools
is_rmd = function(df){
  is_issue = df %>% group_by(measure) %>% summarise(sumdur = sum(duration)) %>% 
    pull(sumdur) %>% {.!=8} %>% sum %>% as.logical
  is_issue = is_issue & (is.na(df$octave[df$note != 'r']) %>% sum)
  return(!is_issue)
}

