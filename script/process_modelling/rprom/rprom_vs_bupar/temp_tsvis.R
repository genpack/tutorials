plot_process_map_tmp = function(obj, measure = c('freq', 'time', 'rate'), node_size = 'auto', link_size = 'auto', time_unit = c('second', 'minute', 'hour', 'day', 'week', 'year'), plotter = c('grviz', 'visNetwork'), config = NULL, remove_ends = F, ...){
  plotter   = match.arg(plotter)
  measure   = match.arg(measure)
  time_unit = match.arg(time_unit)
  nontime   = c('freq', 'rate')
  k         = chif(measure %in% nontime, as.integer(1), 1.0/timeUnitCoeff[time_unit])
  
  nodes = obj$get.nodes() %>% rutils::na2zero()
  links = obj$get.links() %>% rutils::na2zero()
  
  if(remove_ends){
    endstats = c('START', 'END', 'ENTER', 'EXIT')
    nodes = nodes[!(nodes$status %in% endstats),]
    links = links[(!(links$status %in% endstats)) & (!(links$nextStatus %in% endstats)),]
  } else {
    nodes %<>% dplyr::mutate(shape = ifelse(status %in% c('START', 'END'), 'circle', ifelse(status %in% c('ENTER', 'EXIT'), 'diamond', 'rectangle')))
    if(measure %in% nontime){
      nodes$totalEntryFreq[nodes$status == 'START'] <- nodes$totalEntryFreq[nodes$status == 'END'] %>% sum(na.rm = T)
    }
  }
  
  if(is.null(config)){config = list()}
  
  cfg = list(link.smooth = list(enabled = T, type = 'curvedCCW'),
             node.physics.enabled = T, layout = 'hierarchical', 
             direction = 'up.down', node.fixedSize = F) %<==>% config

  nodes %<>%
    dplyr::mutate(shape = ifelse(status %in% c('START', 'END'), 'circle', ifelse(status %in% c('ENTER', 'EXIT'), 'diamond', 'rectangle')))
  
  if(measure %in% nontime){
    nodes$totalEntryFreq[nodes$status == 'START'] <- nodes$totalEntryFreq[nodes$status == 'END'] %>% sum(na.rm = T)
    
    nodes %<>%
      dplyr::mutate(label = status %>% paste0('\n', '(', totalEntryFreq, ')')) %>%
      dplyr::mutate(id = status, color = totalEntryFreq)
    
    if(measure == 'freq'){
      links %<>% dplyr::mutate(linkLabel = ' ' %++% totalFreq)
    } else {
      links %<>% left_join(links %>% group_by(status) %>% summarise(den = sum(totalFreq)) %>% ungroup, by = 'status') %>% 
        dplyr::mutate(linkLabel = paste0(' ', round(100*totalFreq/den, 2), '%'))
    }
    links %<>%
      dplyr::mutate(linkTooltip = status %>% paste(nextStatus, sep = '-')) %>%
      dplyr::mutate(source = status, target = nextStatus, linkColor = totalFreq, linkWidth = totalFreq)

    arguments = list(key = 'status', shape = 'shape', label = 'label', color = list(color = 'totalDuration'), source = 'status', target = 'nextStatus', linkColor = list(color = 'totalTime'), linkLabel = 'linkLabel', linkTooltip = 'linkTooltip', tooltip = 'label', plotter = plotter, type = 'graph', ...)
    if(node_size == 'measure'){
      cfg = cfg %<==>% list(node.label.size = 40, node.size.min = 2, node.size.max = 4, node.size = 3, node.size.ratio = 0.6)
    }
    
    if(link_size == 'measure'){
      cfg = cfg %<==>% list(link.width.max = 12, link.width.min = 2, link.label.size = 35)
      arguments$linkWidth = 'totalFreq'
    }
    
    arguments$obj    = list(nodes = nodes, links = links)
    arguments$config = cfg
    do.call(rvis::rvisPlot, args = arguments)
  } else {
    cfg$palette$color = c('white', 'red')

    nodes %<>%
      dplyr::mutate(meanDuration = k*meanDuration) %>%
      dplyr::mutate(label = status %>% paste0('\n', '(', meanDuration %>% round(digits = 2), ' ', time_unit %>% substr(1,1), ')'))
    
    links %<>%
      dplyr::mutate(meanTime = k*meanTime) %>%
      dplyr::mutate(linkLabel = ' ' %++% (meanTime %>% round(digits = 2) %>% paste(time_unit %>% substr(1,1))), linkTooltip = status %>% paste(nextStatus, sep = '-'))
    
    arguments = list(key = 'status', shape = 'shape', label = 'label', color = list(color = 'totalDuration'), source = 'status', target = 'nextStatus', linkColor = list(color = 'totalTime'), linkLabel = 'linkLabel', linkTooltip = 'linkTooltip', tooltip = 'label', config = cfg, plotter = plotter, type = 'graph', ...)
    if(node_size == 'measure'){
      cfg = cfg %<==>% list(node.label.size = 40, node.size.min = 2, node.size.max = 4, node.size = 3, node.size.ratio = 0.6)
      arguments$size = 'totalDuration'
    }
    
    if(link_size == 'measure'){
      cfg = cfg %<==>% list(link.width.max = 12, link.width.min = 2, link.label.size = 35)
      arguments$linkWidth = 'totalTime'
    }
    arguments$obj = list(nodes = nodes, links = links)
    arguments$config = cfg
    do.call(rvis::rvisPlot, args = arguments)
  }
}
