
### interactive/D3TableFilter.R ------------------------
# Header
# Filename:       D3TableFilter.R
# Description:    Contains functions for plotting table charts from D3TableFilter package using standrad inputs.
# Author:         Nima Ramezani Taghiabadi
# Email :         nima.ramezani@cba.com.au
# Start Date:     26 April 2017
# Last Revision:  26 April 2017
# Version:        0.0.1
#

# Version History:

# Version   Date                Action
# ----------------------------------
# 0.0.1     26 April 2017       Initial issue


# Default settings for package DT:
D3TableFilter.table.defset = defset %<==>% 
  list(
    # Valid classes for all dimensions
    dimclass  = list(
      label = valid.classes,
      color = valid.classes),
    multiples = c('label', 'color'),
    withRowNames  = T,
    column.filter.enabled = TRUE)

D3TableFilter.addColumnTypes = function(config, obj){
  D3TableFilter.column_type = c(numeric = 'Number', character = 'String', Date = 'Date')
  types = apply(obj, 2, class) 
  names(types) = NULL
  types = D3TableFilter.column_type['type']
  types[is.na(types)] <- 'None'
  config$sort_config %<>% add.list(sort_types = types)
  return(config)
}

# Check here for complete reference:
# http://tablefilter.free.fr/doc.php

D3TableFilter.tableprops = function(config){
  config %>% list.extract('fixed_headers', 'tbody_height', 'filters_cell_tag', 'col_width',
                          'inf_div_css_class', 'left_div_css_class', 'right_div_css_class', 'middle_div_css_class',
                          'flts_row_css_class', 'flt_css_class', 'flt_small_css_class', 'flt_multi_css_class', 'single_flt_css_class',
                          'highlight_css_class', 'paging_slc_css_class', 'even_row_css_class', 'odd_row_css_class', 'btn_css_class', 'btn_reset_css_class',
                          'input_watermark_css_class', 'active_columns_css_class', 'nb_pages_css_class', 'paging_btn_css_class',
                          'on_keyup', 'on_keyup_delay',
                          'grid', 'search_type', 'refresh_filters', 'rows_always_visible',
                          'col_operation', 'exact_match', 'custom_cell_data', 
                          'btn', 'btn_text','btn_reset', 'btn_reset_text', 'btn_reset_html', 'btn_reset_target_id', 'btn_next_page_text', 'btn_prev_page_text', 'btn_last_page_text', 'btn_first_page_text', 
                          'btn_next_page_html', 'btn_prev_page_html', 'btn_last_page_html', 'btn_first_page_html',
                          'page_text', 'of_text', 
                          'sort', 'sort_select', 'sort_num_asc', 'sort_num_desc', 
                          'slc_filling_method', 'multiple_slc_tooltip', 
                          'rows_counter', 'rows_counter_text', 'col_number_format', 'sort_config', 'rows_always_visible',
                          paste('col', 1:10, sep = '_'), 'rows_always_visible', 
                          'sort_config', 'msg_sort', 'on_sort_loaded')
}

D3TableFilter.config.verify = function(config){
  config$withRowNames          %<>% verify('logical', domain = c(T,F), lengths = 1, default = T, varname = "config$withRowNames")
  config$column.filter.enabled %<>% verify('logical', domain = c(T,F), lengths = 1, default = T, varname = "config$column.filter.enabled")  
  config$selection.mode        %<>% verify('character', domain = c('single', 'multi'), lengths = 1, varname = 'config$selection.mode')
  config$selection.color       %<>% verify('character', domain = c('active', 'success', 'info', 'warning', 'danger'), default = 'info', lengths = 1, varname = 'config$selection.color')
  config$footer.font.weight    %<>% verify('character', domain = c('bold'), lengths = 1, varname = 'config$footer.font.weight')
  config$footer.font.adjust    %<>% verify('character', domain = c('left', 'right', 'center'), lengths = 1, varname = 'config$footer.font.adjust')
  config$footer.font.format    %<>% verify('character', domain = 1:9 %++% '.f', lengths = 1, varname = 'config$footer.font.format')
  # and many more ...
  return(config)
}

# Converts config$column.footer list to a data.frame 2b passed as argument 'footData' to function 'd3tf()'  
D3TableFilter.footData = function(obj, config){
  out = data.frame()
  rws = obj %>% D3TableFilter.filteredRows(config)
  for (col in names(config$column.footer)){
    nms = c('rownames', colnames(obj))
    if   (config$column.footer[[col]] %>% inherits('function')){val = obj[rws, col] %>% list %>% sapply(config$column.footer[[col]])}
    else {val = config$column.footer[[col]] %>% as.character}
    if(col == 'rownames'){col = 'Rownames'}
    if(!is.empty(val)){out[1, col] = val}
  }
  return(chif(out %>% is.empty, NULL, out))
}

D3TableFilter.rowStyles = function(obj, config){
  if(is.null(config$row.color) & is.null(config$selection.mode)){return(NULL)}
  
  if(!is.null(config$row.color)){
    out = config$row.color %>% verify('character', domain = c('', 'active', 'success', 'info', 'warning', 'danger'), varname = 'config$row.color') %>% vect.extend(nrow(obj))    
  } else {out = rep('', nrow(obj))}
  
  if(!is.null(config$selection.mode)){
    out[config$selected] = 'info'
  }
  return(out)
}

# Generates column.editable from config to be given to argument 'edit' when d3tf() is called
D3TableFilter.edit = function(colnames, config){
  if(is.empty(config$column.editable)){return(FALSE)}
  enacols = config$column.editable %>% verify('list', default = list()) %>% 
    unlist %>% coerce('logical') %>% which %>% names %>% intersect(c('rownames', colnames))
  
  nms = c('rownames', colnames %>% verify('character', default = character(), varname = 'colnames')) %>% unique
  out = character()
  for(i in enacols){
    w = which(nms == i) - 1
    for (j in w){out %<>% c('col_' %++% w)}
  }
  return(out)
}

D3TableFilter.lastEdits.empty <- data.frame(Row = c("", ""), Column = (c("", "")), Value = (c("", "")), stringsAsFactors = FALSE);
rownames(D3TableFilter.lastEdits.empty) <- c("Fail", "Success");


D3TableFilter.initialFilters = function(colnames, config){
  nms = c('rownames', colnames %>% verify('character', default = character(), varname = 'colnames')) %>% unique
  out = list()
  for(i in names(config$column.filter) %>% verify('character', domain = nms, default = character(), varname = 'names(config$column.filter)')){
    w = which (nms == i)
    for (j in w){out[['col_' %++% (w - 1)]] = config$column.filter[[i]]}
  }
  return(out)
}

D3TableFilter.applyFilterstr = function(v, fltstr){
  # todo: currently it can only work with four very simple filterstrs, "<, <=, >=, >" does not support "=" and combined conditions with and , or, not, ...
  if(v %>% inherits('character')){return(fltstr %>% tolower %>% grep(v %>% tolower))}
  parse(text = paste('v', fltstr)) %>% eval %>% which
}

D3TableFilter.filteredRows = function(obj, config){
  ff = obj %>% nrow %>% sequence
  for(i in names(config$column.filter)){
    if (i == 'rownames'){
      ff = ff %^% (rownames(obj) %>% D3TableFilter.applyFilterstr(config$column.filter[[i]]))
    } else {
      ff = ff %^% (obj[, i] %>% D3TableFilter.applyFilterstr(config$column.filter[[i]]))
    }
  }
  return(ff)
}

D3TableFilter.colNames = function(config){
  if(is.null(config$column.title)){return(NULL)}
  cn = character()
  for (cc in names(config$column.title)){
    if(cc == 'rownames'){cn['Rownames'] <- config$column.title[[cc]]} else {cn[cc] <- config$column.title[[cc]]}
  }
  return(cn)
}

D3TableFilter.bgColScales = function(obj, config){
  bgcs = list()
  nms  = c('rownames', colnames(obj))
  for (cc in names(config$column.color)){
    w = which(nms == cc) - 1
    config$column.color.auto[[cc]] %<>% verify('logical', domain = c(T,F), lengths = 1, default = F, varname = "config$column.color.auto['" %++% cc %++% "']")
    if(config$column.color[[cc]] %>% unique %>% length == 1){
      scr = D3TableFilter.color.single.js(config$column.color[[cc]] %>% unique)
    } else if(config$column.color.auto[[cc]]){
      scr = paste('auto', config$column.color[[cc]] %>% paste(collapse = ':'), sep = ':') 
    } else if(inherits(obj[, cc], valid.numeric.classes)){
      scr = D3TableFilter.color.numeric.js(domain = obj[, cc], range = config$column.color[[cc]])
    } else if (inherits(obj[, cc], valid.nominal.classes)){
      scr = D3TableFilter.color.nominal.js(domain = obj[, cc], range = config$column.color[[cc]])
    } else {scr = ''}
    if(!is.empty(scr)){for (i in w){bgcs[[paste0('col_', i)]] <- scr}}
  }
  return(bgcs)
}

D3TableFilter.table = function(obj, label = NULL, color = NULL, shape = NULL, config = NULL, ...){
  if (is.empty(obj)){return(NULL)}
  
  if (is.null(label)){label = as.list(names(obj))}  
  # Verifications:
  assert(require(D3TableFilter), "Package D3TableFilter is not installed!", err_src = match.call()[[1]])
  config = D3TableFilter.table.defset %<==>% (config %>% verify('list', default = list(), varname = 'config')) %>% 
    D3TableFilter.config.verify
  
  # Preparing Aesthetics:
  # Preparing Aesthetics:
  a = prepareAesthetics(label = label, color = color, shape = shape, extend = c('label','color', 'shape'))
  L = a$labels
  A = a$aesthetics %>% list.remove('shape')
  
  obj %<>% prepare4Plot(A, config)
  names(obj) <- names(obj) %>% make.unique('.1')
  
  # Specify background color from argument 'color':
  bgColScales = list()
  for(i in seq(L$color)){
    if(!is.empty(color[[i]])){
      if(L$color[i] %in% L$label){L$color[i] %<>% paste('1', sep = '.')}
      lin = paste0('col_', i)# list item name
      if (obj[, L$color[i]] %>% unique %>% length == 1){
        bgColScales[[lin]] = D3TableFilter.color.single.js(obj[1, L$color[i]])
      } else if (obj[, L$color[i]] %>% length == nrow(obj)){
        if(inherits(obj[,L$label[i]], valid.numeric.classes)){
          bgColScales[[lin]] = D3TableFilter.color.numeric.js(domain = obj[, L$label[i]], range = obj[, L$color[i]])
        } else {
          bgColScales[[lin]] = D3TableFilter.color.nominal.js(domain = obj[, L$label[i]], range = obj[, L$color[i]])
        }
      }
    }
  }  
  
  if(is.null(L$color)){bgColScales = D3TableFilter.bgColScales(obj, config)}
  
  if(is.null(L$shape)){
    if(!is.null(config$column.shape)){
      L$shape = rep('', length(L$label))
      for (i in names(config$column.shape)){
        w = which(L$label == i)
        L$shape[w] = config$column.shape[[i]]
      }
    }
  }
  # turn cell values into scaled SVG graphics from argument 'shape':
  cellFunctions = list()
  for(i in seq(L$shape)){
    shp = L$shape[i]
    if(!is.empty(shp)){
      lin = paste0('col_', i)# list item name
      if      (shp == 'bar'){cellFunctions[[lin]] = D3TableFilter.shape.bar.js()} 
      else if (shp %in% c('bubble', 'circle', 'point', 'dot')){cellFunctions[[lin]] = D3TableFilter.shape.bubble.js()}
    }
  }  
  
  footCellFunctions <- list(
    col_0 = D3TableFilter.font.js(side = 'left', format = NULL, weight = 'bold'),
    col_1 = D3TableFilter.font.js(side = 'left', format = '.1f', weight = 'bold'),
    col_2 = D3TableFilter.font.js(side = 'center', format = '.1f', weight = 'bold'),
    col_3 = D3TableFilter.font.js(side = 'right', format = '.1f', weight = 'bold')
  )
  
  wcb = which(L$shape == 'checkBox')
  wrb = which(L$shape == 'radioButtons')
  
  obj[, L$label] %>% D3TableFilter::d3tf(
    colNames     = D3TableFilter.colNames(config),
    bgColScales  = bgColScales, 
    cellFunctions = cellFunctions,
    footCellFunctions = footCellFunctions,
    showRowNames = config$withRowNames,
    enableTf     = config$column.filter.enabled,
    filterInput  = config$column.filter.enabled,
    edit         = L$label %>% D3TableFilter.edit(config),
    checkBoxes   = chif(is.empty(wcb), NULL, 'col_' %++% wcb),
    radioButtons = chif(is.empty(wcb), NULL, 'col_' %++% wrb),
    initialFilters = D3TableFilter.initialFilters(L$label, config),
    footData = D3TableFilter.footData(obj[, L$label], config),
    tableStyle = config$table.style,
    selectableRows = config$selection.mode,
    selectableRowsClass = config$selection.color,
    rowStyles = D3TableFilter.rowStyles(obj[, L$label], config),
    tableProps = config %>% D3TableFilter.tableprops,
    ...)
}
