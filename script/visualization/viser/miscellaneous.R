### misexamples.R -------------------------
mtcars %>% group_by(cyl) %>% summarize(mpg = sum(mpg), disp = mean(disp)) %>% as.data.frame %>% 
  niraPlot(y = list('mpg', 'disp'), x = 'cyl', plotter = 'plotly', shape = list('bar', 'line')
           , type = 'bar', config = list(barMode = 'stack'))

mtcars %>% group_by(cyl) %>% summarize(mpg = sum(mpg), disp = mean(disp)) %>% as.data.frame %>% 
  niraPlot(theta = 'mpg', label = 'cyl', plotter = 'rAmCharts', type = 'pie')

mtcars %>% niraPlot(x = 'mpg', y = 'disp', plotter = 'nvd3', type = 'scatter')
