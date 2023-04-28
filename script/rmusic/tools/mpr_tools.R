# MPR Tools


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

mpr.add_duration = function(mpr, cpitch = 'cpitch', rythm = 'rythm', output = "duration", target_unit = 1/8, meter = 4/4){
  measures = which(!is.na(mpr[[rythm]]) & !is.na(mpr[[cpitch]]))
  for(i in measures){
    rythm2duration(mpr[i, rythm], target_unit = target_unit, meter = meter) %>% 
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
mpr2rmd = function(mpr, track = "melody", channel = 0, pitch = NULL, duration = NULL, chord = NULL){
  mpr %<>% as.data.frame()
  
  track     = rutils::verify(pitch, 'character', lengths = 1, default = "melody")
  # measure   = rutils::verify(pitch, c('numeric', 'integer'), domain = colnames(mpr), lengths = 1, default = "measure")
  pitch     = rutils::verify(pitch, 'character', domain = colnames(mpr), lengths = 1, default = paste(track, 'pitch', sep = '_'))
  duration  = rutils::verify(duration, 'character', domain = colnames(mpr), lengths = 1, default = paste(track, 'duration', sep = '_'))
  chord     = rutils::verify(chord, 'character', domain = colnames(mpr), lengths = 1, null_allowed = T)
  rmdf = NULL
  for(i in sequence(nrow(mpr))){
    # cat(i, '-')
    measure_pitches = strsplit(mpr[i, pitch], ';') %>% unlist
    if(length(measure_pitches) == 0){measure_pitches = 'r'}
    
    res = measure_pitches %>% pitch2note_octave()
    # measure_notes = measure_pitches %>% strsplit("[0-9]") %>% unlist
    # measure_octaves = measure_pitches %>% gsub(pattern = "[a-z,_#]", replacement = "")
    measure_notes = res$notes
    measure_octaves = res$octaves
    measure_notes = 
      data.frame(
        measure = i, 
        track = track,
        channel = channel,
        pitch = measure_pitches,
        note = measure_notes,
        octave = measure_octaves,
        duration = strsplit(mpr[i, duration], ';') %>% unlist %>% as.numeric
      ) -> rmdfi
    if(!is.null(chord)){
      chords = mpr[i, chord]
      # chords = mpr[i, chord] %>% strsplit("[/ ]") %>% unlist
      while(length(chords) < nrow(rmdfi)){chords = c(chords, "")}
      rmdfi$chord =  chords
    }
    rmdf %<>% rbind(rmdfi)
  }
  return(rmdf)
}



rmd2mpr = function(rmd){
  paste_semicolon = function(u) paste(u, collapse = ';')
  
  # rmd %>% reshape2::dcast(measure ~ track, value.var = 'duration', fun.aggregate = sum)
  rmd$pitch = note_octave2pitch(rmd$note, rmd$octave)
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
