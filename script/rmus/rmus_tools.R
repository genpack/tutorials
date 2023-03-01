##

cpitchRythm2pitchDuration = function(cpitch, rythm, target_unit = 1/8){
  rsplit = rythm %>% strsplit('_') %>% unlist
  rsplit[1] %>% strsplit('') %>% unlist %>% 
    strtoi(32L) %>% {.[.==0]<-32;.} -> duration
  rythm_unit = 1.0/sum(duration)
  rutils::assert(rythm_unit %in% c(1,1/2,1/4,1/8,1/16,1/32), "Durations dont fit a measure!")
  duration = duration*rythm_unit/target_unit
  rutils::assert(sum(duration)*target_unit == 1.0, "Durations dont fit a measure!")
  isrest = rsplit[2] %>% strsplit('') %>% 
    unlist %>% as.integer %>% as.logical %>% {!.}
  nn = length(cpitch)
  rutils::assert(sum(!isrest) == nn, 'Check Error!')
  pitch = rep('r', nn)
  pitch[!isrest] <- cpitch
  return(list(pitch = pitch, duration = duration))
}


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
