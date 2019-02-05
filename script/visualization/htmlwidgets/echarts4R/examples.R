library(echarts4r)
library(niragen)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/echarts.R')


# with negative
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_area(Murder) %>%
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% # second y axis 
  e_mark_line("Sick basterd", data = list(type = "average")) %>% 
  e_mark_point("Murder", data = list(type = "max")) %>% 
  e_tooltip(trigger = "axis")

## polar charts:
df <- data.frame(x = 1:100, y = seq(1, 200, by = 2))

df %>% 
  e_charts(x) %>% 
  e_polar(FALSE) %>% 
  e_angle_axis(T) %>% 
  e_radius_axis(T) %>% 
  e_line(y, coord.system = "polar", smooth = TRUE) %>% 
  e_legend(show = TRUE)

# todo: niravis translation:
# df %>% echarts.polar(theta = 'x', r = 'y', shape = 'line.point') 


# animation:

mtcars %>% 
  e_charts(mpg) %>% 
  e_area(drat) %>% 
  e_animation(duration = 10000)

# Histogram & density
mtcars %>% 
  e_charts() %>% 
  e_histogram(mpg, name = "histogram") %>% 
  e_density(mpg, areaStyle = list(opacity = .4), smooth = TRUE, name = "density", y.index = 1) %>% 
  e_tooltip(trigger = "axis")

funnel <- data.frame(stage = c("View", "Click", "Come and \n Purchase", "Click"), value = c(80, 30, 20, 5))

funnel %>% 
  e_charts() %>% 
  e_funnel(value, stage)


# niravis translation:
# todo: You need to aggregate later
# todo: check for custom colors

funnel %>% nameColumns(list('Stager Built' = 'stage')) %>% echarts.funnel(label = 'Stager Built', size = 'value')


# word cloud:

words <- function(n = 5000) {
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}

tf <- data.frame(terms = words(100), 
                 freq = rnorm(100, 55, 10)) %>% 
  dplyr::arrange(-freq)

tf %>% 
  e_color_range(freq, color) %>% 
  e_charts() %>% 
  e_cloud(terms, freq, color, shape = "rectangle", sizeRange = c(3, 15))

# argument shape does not work
# niravis Translation:

tf %>% echarts.wordCloud(label = 'terms', size = 'freq', color = list(color = 'freq'), config = list(colorize = T))


# Gauge:

e_charts() %>% 
  e_gauge(57, "PERCENT", rm.x = F, rm.y = T, startAngle = 110, endAngle = 1)

# properties don't work

# Look for other properties:
# https://ecomfe.github.io/echarts-doc/public/en/option.html#series-gauge


# niravis Translation:
echarts.gauge(theta = 57, label = 'PERCENT', startAngle = 110, endAngle = 1, detail = list(formatter = '{value}%'))

### bar.R -----------------------
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_bar(Murder) %>% 
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% 
  e_animation(duration = 10000) # secondary x axis


# Niravis translation:

USArrests %>% dplyr::mutate(State = row.names(.), Rape = - Rape) %>% 
  echarts.bar(x = 'State', y = list('Murder', 'Sick basterd' = 'Rape')) %>% 
  e_animation(duration = 10000)
library(echarts4r)
library(niragen)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/echarts.R')


# with negative
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_area(Murder) %>%
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% # second y axis 
  e_mark_line("Sick basterd", data = list(type = "average")) %>% 
  e_mark_point("Murder", data = list(type = "max")) %>% 
  e_tooltip(trigger = "axis")

## polar charts:
df <- data.frame(x = 1:100, y = seq(1, 200, by = 2))

df %>% 
  e_charts(x) %>% 
  e_polar(FALSE) %>% 
  e_angle_axis(T) %>% 
  e_radius_axis(T) %>% 
  e_line(y, coord.system = "polar", smooth = TRUE) %>% 
  e_legend(show = TRUE)

# todo: niravis translation:
# df %>% echarts.polar(theta = 'x', r = 'y', shape = 'line.point') 


# animation:

mtcars %>% 
  e_charts(mpg) %>% 
  e_area(drat) %>% 
  e_animation(duration = 10000)

# Histogram & density
mtcars %>% 
  e_charts() %>% 
  e_histogram(mpg, name = "histogram") %>% 
  e_density(mpg, areaStyle = list(opacity = .4), smooth = TRUE, name = "density", y.index = 1) %>% 
  e_tooltip(trigger = "axis")

funnel <- data.frame(stage = c("View", "Click", "Come and \n Purchase", "Click"), value = c(80, 30, 20, 5))

funnel %>% 
  e_charts() %>% 
  e_funnel(value, stage)


# niravis translation:
# todo: You need to aggregate later
# todo: check for custom colors

funnel %>% nameColumns(list('Stager Built' = 'stage')) %>% echarts.funnel(label = 'Stager Built', size = 'value')


# word cloud:

words <- function(n = 5000) {
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}

tf <- data.frame(terms = words(100), 
                 freq = rnorm(100, 55, 10)) %>% 
  dplyr::arrange(-freq)

tf %>% 
  e_color_range(freq, color) %>% 
  e_charts() %>% 
  e_cloud(terms, freq, color, shape = "rectangle", sizeRange = c(3, 15))

# argument shape does not work
# niravis Translation:

tf %>% echarts.wordCloud(label = 'terms', size = 'freq', color = list(color = 'freq'), config = list(colorize = T))


# Gauge:

e_charts() %>% 
  e_gauge(57, "PERCENT", rm.x = F, rm.y = T, startAngle = 110, endAngle = 1)

# properties don't work

# Look for other properties:
# https://ecomfe.github.io/echarts-doc/public/en/option.html#series-gauge


# niravis Translation:
echarts.gauge(theta = 57, label = 'PERCENT', startAngle = 110, endAngle = 1, detail = list(formatter = '{value}%'))

### bar.R -----------------------
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_bar(Murder) %>% 
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% 
  e_animation(duration = 10000) # secondary x axis


# Niravis translation:

USArrests %>% dplyr::mutate(State = row.names(.), Rape = - Rape) %>% 
  echarts.bar(x = 'State', y = list('Murder', 'Sick basterd' = 'Rape')) %>% 
  e_animation(duration = 10000)
library(echarts4r)
library(niragen)

source('../../packages/master/niravis-master/R/visgen.R')
source('../../packages/master/niravis-master/R/echarts.R')


# with negative
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_area(Murder) %>%
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% # second y axis 
  e_mark_line("Sick basterd", data = list(type = "average")) %>% 
  e_mark_point("Murder", data = list(type = "max")) %>% 
  e_tooltip(trigger = "axis")

## polar charts:
df <- data.frame(x = 1:100, y = seq(1, 200, by = 2))

df %>% 
  e_charts(x) %>% 
  e_polar(FALSE) %>% 
  e_angle_axis(T) %>% 
  e_radius_axis(T) %>% 
  e_line(y, coord.system = "polar", smooth = TRUE) %>% 
  e_legend(show = TRUE)

# todo: niravis translation:
# df %>% echarts.polar(theta = 'x', r = 'y', shape = 'line.point') 


# animation:

mtcars %>% 
  e_charts(mpg) %>% 
  e_area(drat) %>% 
  e_animation(duration = 10000)

# Histogram & density
mtcars %>% 
  e_charts() %>% 
  e_histogram(mpg, name = "histogram") %>% 
  e_density(mpg, areaStyle = list(opacity = .4), smooth = TRUE, name = "density", y.index = 1) %>% 
  e_tooltip(trigger = "axis")

funnel <- data.frame(stage = c("View", "Click", "Come and \n Purchase", "Click"), value = c(80, 30, 20, 5))

funnel %>% 
  e_charts() %>% 
  e_funnel(value, stage)


# niravis translation:
# todo: You need to aggregate later
# todo: check for custom colors

funnel %>% nameColumns(list('Stager Built' = 'stage')) %>% echarts.funnel(label = 'Stager Built', size = 'value')


# word cloud:

words <- function(n = 5000) {
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}

tf <- data.frame(terms = words(100), 
                 freq = rnorm(100, 55, 10)) %>% 
  dplyr::arrange(-freq)

tf %>% 
  e_color_range(freq, color) %>% 
  e_charts() %>% 
  e_cloud(terms, freq, color, shape = "rectangle", sizeRange = c(3, 15))

# argument shape does not work
# niravis Translation:

tf %>% echarts.wordCloud(label = 'terms', size = 'freq', color = list(color = 'freq'), config = list(colorize = T))


# Gauge:

e_charts() %>% 
  e_gauge(57, "PERCENT", rm.x = F, rm.y = T, startAngle = 110, endAngle = 1)

# properties don't work

# Look for other properties:
# https://ecomfe.github.io/echarts-doc/public/en/option.html#series-gauge


# niravis Translation:
echarts.gauge(theta = 57, label = 'PERCENT', startAngle = 110, endAngle = 1, detail = list(formatter = '{value}%'))

### bar.R -----------------------
USArrests %>% 
  dplyr::mutate(
    State = row.names(.),
    Rape = - Rape
  ) %>% 
  e_charts(State) %>% 
  e_bar(Murder) %>% 
  e_bar(Rape, name = "Sick basterd", x.index = 1) %>% 
  e_animation(duration = 10000) # secondary x axis


# Niravis translation:

USArrests %>% dplyr::mutate(State = row.names(.), Rape = - Rape) %>% 
  echarts.bar(x = 'State', y = list('Murder', 'Sick basterd' = 'Rape')) %>% 
  e_animation(duration = 10000)
