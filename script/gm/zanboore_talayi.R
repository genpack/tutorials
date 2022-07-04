# Ey Zanboore Talayi
r1 = c(rep(8, 6), "q") %>% as.list
p1 = list('G4', 'G4','C5','E5','G5','G5','E5')
l1 = "EY ZANBOORE TALAYI"


p2 = list("E5", 'E5', 'C5', 'D5', 'E5', 'E5', 'D5')
l2 = "NISH MIZANI BALAYI"

p3 = list('E5','G5','E5','C5','D5','D5','D5')
l3 = "PASHO PASHO BAHARE"

# r4 = list('E5','G5','E5','G5','C5','C5','D5')
p4 = list('D5','F5','D5','G4','C5','C5','C5')
l4 = "GOL VA SHODE DOBAREH"

library(gm)

melody.pitches   = c(p1, p2, p3, p4)
melody.durations = rep(r1, 4)
melody = Line(pitches = melody.pitches, durations = melody.durations, name = 'Melody')

m = Music() + Meter(4,4) 
m = m + melody

show(m)
show(m, 'audio')
#######
