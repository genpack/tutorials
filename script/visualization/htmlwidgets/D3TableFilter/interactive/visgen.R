
### interactive/visgen.R ------------------------
# Header
# Filename:      visgen.R
# Description:   This module contains general functions and defines global variables used in package niravis
# Author:        Nima Ramezani Taghiabadi
# Email :        nima.ramezani@cba.com.au
# Start Date:    28 October 2016
# Last Revision: 31 March 2017
# Version:       1.2.4

# Version History:

# Version   Date               Action
# ----------------------------------
# 1.0.0     28 October 2016    Initial Issue
# 1.1.0     01 December 2016   Function visPrepare() added
# 1.1.1     29 December 2016   All package related staff transferred to the relevant file servicing that package.
# 1.1.2     10 February 2017   Some global variables like valid.plot.types and valid.plot.packages transferred from niraPlotter.R
# 1.1.3     01 March 2017      Function verifyPlotInputs() added. 
# 1.1.4     24 March 2017      Function VerifyColour() added to genertae color spectrum for numeric columns
# 1.1.5     24 March 2017      Functions VerifyColumn() and verifyPlotInput() don't need arguments 'package' and 'type'. Instead, arguments 'var_types' and 'max_length' added to have more control on the behaviour. 
#                              Especially required for horizontal plots in which x and y variable types are swaped!
# 1.2.0     26 March 2017      Functions addcol() and prepare4Plotble4Plot() added
# 1.2.1     27 March 2017      Argument var_types replaced by config. config contaions palettes for different dimensions as well as valid dim classes.
# 1.2.2     27 March 2017      Functions verifyColumn() and verifyColour() eliminated: All is done by addcol(). Function addcol() is not exported.
# 1.2.3     27 March 2017      Functions nameList() added. Renamed from previous function as.named.list()
# 1.2.4     31 March 2017      Function prepareAusthetics() added. 
# 1.2.5     11 April 2017      Function prepareAusthetics() renamed to prepareAesthetics() and modified: extends to max length of arguments

# Uncomment when compile
# assert(require(niragen), "Package niragen is not installed!", err_src = match.call()[[1]])

assert(require(magrittr), "Package magrittr is not installed!", err_src = match.call()[[1]])

colNamePrefix = 'X'

#' @export
valid.dim.names  = c('x', 'y', 'z', 't', 'high', 'low', 'color', 'size', 'shape', 'label', 'tooltip', 'labelColor', 
                     'borderColor', 'linkColor','theta', 'ySide', 'group', 'source', 'target', 
                     'linkWidth', 'linkLength', 'linkLabel', 'linkLabelColor', 'linkLabelSize')

#' @export
valid.plot.types = c('bar', 'calheat', 'line', 'motion', 'pie', 'tsline', 'gauge', 'bubble', 'combo', 'scatter')

#' @export
valid.plot.packages    = c('googleVis', 'dygraphs', 'rAmCharts', 'rCharts', 'highcharter', 'plotly', 'bubbles')

# General settings for all the plots
defset = list(
  
  palette= list(
    color = c("#FB1108", "#FA7806","#FBE426","#FCFB8F", "#F3F5E7", "#C7E4EA","#ABD6E6","#9AD2E1"),
    shape = c('circle', 'x', 'o', 'plus', 'square.hollow', 'rhombus.hollow')
  ),
  
  withRowNames = F,
  colorize     = T
)

# if a column name is convertable to numerics, it adds a prefix to it. Global variable 'colNamePrefix' will be used.
addPrefix = function(figures){
  if (is.null(figures)){return(NULL)}
  options(warn = -1)
  nms = !is.na(as.numeric(figures))
  options(warn = 0)
  figures[nms] = colNamePrefix %+% figures[nms]
  return(figures)
}

addcol = function(tbl, obj, col, dim, config, cln){
  if (is.empty(col)){return(tbl)}
  if (inherits(col, 'list')){
    nms   = names(col)
    added = c()
    for (i in seq(col)){
      if (!(nms[i] %in% added)){
        tbl %<>% addcol(obj, col[[i]], dim, config, cln = nms[i])
        added = c(added, nms[i])
      }
    }
    return(tbl)
  }
  assert(!is.null(cln))
  
  flag <- (col %<% names(obj)) %>% verify(err_msg = "Argument 'col' is of class " %+% class(col) %+% " which is not valid for any chart", err_src = match.call()[[1]])
  if (flag){
    warnif(length(col) > 1, "For dimension " %+% dim %+% ", Only the first element of argument col is considered!")
    col = col[1]
    if (!inherits(obj[,col], config$dimclass[[dim]])){obj[, col] <- try(obj[,col] %>% coerce(config$dimclass[[dim]][1]), silent = T) %>% verify()}
    if ((dim %in% c('color', 'labelColor', 'borderColor', 'linkColor')) & config$colorize){obj[, col] %<>% colorize(palette = config$palette[[dim]])}
    return(tbl %>% appendCol(obj[,col], cln))
  }
  
  if ((dim %in% c('color', 'labelColor', 'borderColor', 'linkColor')) & config$colorize){
    clr = try(col2rgb(col))
    if(inherits(clr, 'try-error')){
      tbl[, cln] <- colorize(col, palette = palette)
    } else {
      clr %<>% apply(2, vect.normalize) 
      tbl %<>% appendCol(rgb(red = clr['red', ], green = clr['green', ], blue = clr['blue', ]), cln)
    }
    return(tbl)  
  }
  
  if(!inherits(col, config$dimclass[[dim]])){col <- try(col %>% coerce(config$dimclass[[dim]][1]), silent = T) %>% verify()}
  
  tbl %<>% appendCol(col, cln)
  if (inherits(col,'character')){tbl[,cln] %<>% as.character}
  return(tbl)
}

nameList = function(l, defname = 'X'){
  if(is.null(l)){return(l)}
  if (!inherits(l,'list')){
    l %<>% list
    names(l) <- names(l[[1]])
  }
  nms = names(l)
  
  if(is.null(names(l))){names(l) <- rep('', length(l))}
  
  nms = names(l)
  for (i in seq(l)){
    if (nms[i] == ''){
      if (inherits(l[[i]],'character')){nms[i] = l[[i]][1]} else {nms[i] <- paste(defname, i, sep = '.')}
    }
  }
  
  names(l) <- nms
  return(l)
}

prepare4Plot = function(obj, aesthetics, config){
  
  # Verifications:
  if(inherits(obj, c('tbl','tbl_df'))){obj %<>% as.data.frame}
  obj     = verify(obj, 'data.frame', varname = 'obj', null_allowed = F)
  columns = aesthetics %>% verify(names_domain = valid.dim.names, varname = 'columns', err_src = 'prepare4Plot')
  
  # Table pre-modifications:
  # if(!is.null(config$presort)){
  #   config$presort %>% verify('character', domain = names(obj), varname = 'config$presort')
  #   obj %>% dplyr::arrange(config$presort)
  # }
  
  tbl = data.frame()
  for (i in names(columns)){
    # Verifications:
    if(!is.null(columns[[i]])){
      if(!is.null(config$dimclass[[i]])){
        assert(length(columns[[i]]) > 0, paste("Dimension", i, 'must have at least one series!'), 'prepare4Plot')
        if (!(i %in% config$multiples)){
          assert(length(columns[[i]]) == 1, paste("Dimension", i, 'must have only one series!'), 'prepare4Plot')
        }
      }
    }
    
    tbl %<>% addcol(obj, columns[[i]], i, config = config)
  }
  if (config$withRowNames){rownames(tbl) <- rownames(obj)}
  return(tbl)
}

#' @export
verifyPlotInputs = function(obj, x = NULL, y = NULL, z = NULL, t = NULL, color = NULL, size = NULL, 
                            shape = NULL, label = NULL, labelColor = NULL, theta = NULL, 
                            linkSource = NULL, linkTarget = NULL,
                            tooltip = NULL, palette.color = niraPalette, palette.labelColor = niraPalette, ...){
  obj     = verify(obj, 'data.frame', varname = 'obj', null_allowed = F)
  names(obj) %<>% addPrefix
  
  # Domain for colDim is: c('x', 'y', ...)
  data.frame() %>%
    verifyColumn(obj, x, 'x', ...) %>%
    verifyColumn(obj, y, 'y', ...) %>%
    verifyColumn(obj, z, 'z', ...) %>%
    verifyColumn(obj, t, 't', ...) %>%
    
    verifyColumn(obj, size,  'size',   ...) %>%
    verifyColour(obj, color, 'color', palette = palette.color, ...) %>%
    verifyColumn(obj, shape, 'shape', ...) %>%
    verifyColumn(obj, label, 'label', ...) %>%
    verifyColour(obj, labelColor, 'labelColor', palette = palette.labelColor, ...)  %>%
    verifyColumn(obj, theta, 'theta', ...)  %>%
    verifyColumn(obj, tooltip, 'tooltip', ...) %>%
    verifyColumn(obj, linkSource, 'linkSource', ...) %>%
    verifyColumn(obj, linkTarget, 'linkTarget', ...)
}

# Old function: should be removed later
#' @export
visPrepare = function(arg){
  # verifications:
  verify(arg, 'list', names_domain = c('table', valid.dim.names), names_include = 'table', varname = 'arg', null_allowed = F)
  verify(arg$table, 'data.frame', varname = 'table', null_allowed = F)
  # names(dims) <- tolower(names(dims))
  
  all.figs = names(arg$table)
  num.figs = numerics(arg$table)
  cat.figs = nominals(arg$table)
  tim.figs = datetimes(arg$table)
  
  nms = names(arg) %-% 'table'
  colNames = character()
  
  for (i in nms){
    # Verifications:
    verify(arg[[i]], 'list', names_include = c('type', 'colName'), varname = 'arg[[i]]')
    verify(arg[[i]]$type, 'character', domain = c('numeric', 'nominal', 'time'), varname = 'arg[[i]]$type')
    figs = switch(arg[[i]]$type, 'numeric' = {num.figs}, 'nominal' = {cat.figs}, 'time' = {tim.figs}, 'all' = {all.figs})
    verify(arg[[i]]$colName, 'character', domain = figs, varname = 'arg[[i]]$colName')
    
    colNames = c(colNames, arg[[i]]$colName)
  }
  
  return(arg$table[, colNames, drop = F])
}




# Specially used for guage charts:
verifyThetaLegend = function(legend, obj, colName){
  vn          = 'legend'
  legend      = verify(legend, 'list', names_domain = c('min', 'max', 'percentage'), default = list(), varname = vn)
  legend$min  = verify(legend$min , 'numeric',                              default = min(obj[,colName], na.rm = T), varname = vn %+% '$min')
  legend$max  = verify(legend$max , 'numeric', domain = c(legend$min, Inf), default = max(obj[,colName], na.rm = T), varname = vn %+% '$max')
  legend$percentage  = verify(legend$percentage , 'logical', domain = c(T, F), default = F, varname = vn %+% '$percentage')
  return(legend)
}

removePercentage = function(dim){
  if (is.null(dim)){return(NULL)} else {return(gsub('%', '', dim))}
}

# Adds a tooltip column to the given table containing values of selected columns
addTooltip = function(tbl, columns = names(tbl), units = NULL, addedColName = 'tooltip'){
  # Verifications:
  verify(tbl, c('data.frame', 'matrix'), varname = 'tbl')
  verify(columns, 'character', domain = c('%rownames', names(tbl)), varname = 'columns')
  units %<>% verify('character', lengths = length(columns), default = rep('', length(columns)), varname = 'columns')
  
  if (is.null(names(columns))){names(columns) = columns}
  names(units) <- names(columns)
  mxl = max(nchar(names(columns))) + 1
  
  if(is.empty(tbl)){return(tbl)}
  str = ''
  for (col in names(columns)){
    if (columns[col] == '%rownames'){colstr = rownames(tbl)} 
    else if (inherits(tbl[, columns[col]], 'numeric')) {colstr = prettyNum(tbl[,columns[col]], digits = 3)} 
    else {colstr = tbl[,columns[col]]}
    if (units[col] == ''){unitstr = ''} else {unitstr = paste0(' (', units[col], ') ')}
    ttlstr = extend.char(col %+% ':', mxl)
    str %<>% paste0(ttlstr, colstr, unitstr, '\n')
  }
  
  tbl[, addedColName] <- str
  return(tbl)
}


prepareAesthetics = function(extend = c(), ...){
  args = list(...)
  lbls = list()
  dims = names(args)
  M    = length(dims)
  # N    = args %>% sapply(length) %>% max
  N = 1
  for (i in sequence(M)){
    if(!is.null(args[[i]])){
      args[[i]] %<>% nameList(dims[i])
      N = max(N, length(args[[i]]))
    }
  }
  
  for (d in dims){
    if(d %in% extend){args[[d]] %<>% list.extend(N)}
    lbls[[d]] = names(args[[d]])
  }
  
  # names(lbls) <- dims[sequence(length(lbls))]
  
  list(aesthetics = args, labels = lbls)  
}