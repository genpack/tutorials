m <- Music() + Meter(4,4) +
  Line(list("E5", "F5", "C6"), list(1, 0.5, 1), name = "a") +
  Line(list("C#4", "B3", "E-3"), list(1, 1, 1), name = "b", as = "staff")

show(m)

show(m + Key(2, to = "b") + Clef("F", to = "b"))
show(m + Key(-2) + Clef("F", to = "b"))
     
l <- Line(rep(list(NA), 3) %>% c('C5'), list("q/3", "q/3", "q/3"))


l <- Line(
  pitches = list(c("C5", "E5"), c("C5", "E5"), c("C5", "E5"), c("C5", "E5")),
  durations = list("quarter", "quarter", "quarter", "quarter"),
  tie = list(c(1, 1), c(2, 2), 3)
)

m <- Music() + Meter(4, 4) + l
show(m)


vignette('gm')



# create a Music object
m <- Music() + Meter(4, 4) + Line(list("C4"), list(8), name = "a")

# create a Line object
l <- Line(
  pitches = list("C5", "C5", "C5"),
  durations = list(1, 1, 1),
  
  # tie the first two notes
  tie = list(1),
  
  # add the Line as a voice
  as = "voice",
  
  # with Line "a" as reference
  to = "a",
  
  # before Line "a"
  after = FALSE,
  
  # insert the Line to bar 2 with offset 1
  bar = 2,
  offset = 1
)
l

# add the Line object to the Music object
m <- m + l
m
show(m)
