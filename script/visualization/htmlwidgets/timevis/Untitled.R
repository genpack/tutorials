library(timevis)

data <- data.frame(
  id      = c(1:4, 1),
  content = c("Item one", "Item two",
              "Ranged item", "Item four", "Item one"),
  start   = c("2016-01-10", "2016-01-11",
              "2016-01-20", "2016-02-14 15:00:00", "2016-02-14 18:00:00"),
  end     = c(NA, NA, "2016-02-04", NA, "2016-02-14 18:30:00")
)

timevis(data)
