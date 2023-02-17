# visgen.R ----------------------------------------------------------------


# Header
# Filename:      visgen.R
# Description:   This module contains general functions and defines global variables used in package rvis
# Author:        Nima Ramezani
# Email :        nima.ramezani@gmail.com
# Start Date:    28 October 2016
# Last Revision: 03 January 2023
# Version:       1.3.8

# Version History:

# Version   Date               Action
# -----------------------------------
# 1.0.0     28 October 2016    Initial Issue
# 1.1.0     01 December 2016   Function visPrepare() added
# 1.1.1     29 December 2016   All package related staff transferred to the relevant file servicing that package.
# 1.1.2     10 February 2017   Some global variables like valid.plot.types and valid.plotters transferred from rvisPlotter.R
# 1.1.3     01 March 2017      Function verifyPlotInputs() added.
# 1.1.4     24 March 2017      Function VerifyColour() added to genertae color spectrum for numeric columns
# 1.1.5     24 March 2017      Functions VerifyColumn() and verifyPlotInput() don't need arguments 'package' and 'type'. Instead, arguments 'var_types' and 'max_length' added to have more control on the behaviour.
#                              Especially required for horizontal plots in which x and y variable types are swaped!
# 1.2.0     26 March 2017      Functions addcol() and prepare4Plot() added
# 1.2.1     27 March 2017      Argument var_types replaced by config. config contaions palettes for different dimensions as well as valid dim classes.
# 1.2.2     27 March 2017      Functions verifyColumn() and verifyColour() eliminated: All is done by addcol(). Function addcol() is not exported.
# 1.2.3     27 March 2017      Functions nameList() added. Renamed from previous function as.named.list()
# 1.2.4     31 March 2017      Function prepareAusthetics() added.
# 1.2.5     11 April 2017      Function prepareAusthetics() renamed to prepareAesthetics() and modified: extends to max length of arguments
# 1.2.6     13 July 2017       Global variable colNamePrefix removed and added as argument to function: addPrefix()
# 1.2.7     13 February 2018   Function addCol() modified: Returns proper error message if dimension is not defined in the configuration.
# 1.2.8     23 May 2018        Function prepare4Plot() modified: Respects config property 'additionalColumns' to cbind additional columns to the table if required.
# 1.2.9     29 May 2018        Function addCol() modified: shows proper error message if passed dimension is not defined in config$dimClass
# 1.3.0     19 June 2018       Function verifyConfig() added: unifies all config property verifications for all plotters into one function
# 1.3.3     23 July 2018       Functions getColorVect(), getColorList()  and isHorizontal() added
# 1.3.4     18 October 2018    Dimension 'linkTooltip' added
# 1.3.5     24 February 2019   data('properties') changed to data('properties', package = 'rvis')
# 1.3.6     24 February 2019   All argument err_src is no more used when calling assert()
# 1.3.7     21 March 2019      Function df2Network() added
# 1.3.8     03 January 2023    gndnd key updated to work for 2023


if (!require(rutils)){
  cat(paste("\n", "Package 'rutils' is not available and cannot be installed from cran! Please install it manually!", "\n", "\n"))
  stop()
}

# dataPath = 'data/'
#dataPath = ''
# properties = read.csv('data/properties.csv' , as.is = T)
# save.image("data/properties.RData")
# Before building the package, everytime you update table properties, you need to load it, save in folder data/ as properties.RData

support('magrittr', 'shiny', 'shinydashboard', 'htmlwidgets')


#' @export
valid.dim.names  = c('key', 'x', 'y', 'y2', 'z', 't', 'high', 'low', 'color', 'size', 'shape', 'label', 'tooltip', 'labelColor',
                     'borderColor', 'linkColor','theta', 'ySide', 'group', 'source', 'target',
                     'linkWidth', 'linkLength', 'linkLabel', 'linkLabelColor', 'linkLabelSize', 'linkTooltip')

#' @export
valid.plot.types = c('bar', 'calheat', 'line', 'motion', 'pie', 'tsline', 'gauge', 'bubble', 'combo', 'scatter')

#' @export
valid.plotters    = c('googleVis', 'dygraphs', 'rAmCharts', 'rCharts', 'highcharter', 'plotly', 'bubbles')

# General settings for all the plots
#' @export
defset = list(
  palette= list(
    # color = c("#FB1108", "#FA7806","#FBE426","#FCFB8F", "#F3F5E7", "#C7E4EA","#ABD6E6","#9AD2E1"),
    color = c("purple", "blue","cyan","green", "yellow", "orange","red","black" , 'white'),
    shape = c('circle', 'x', 'o', 'plus', 'square.hollow', 'rhombus.hollow')
  ),

  withRowNames = F,
  colorize     = T
)

# if a column name is convertable to numerics, it adds a prefix to it. Argument 'colNamePrefix' will be used.
addPrefix = function(figures, colNamePrefix = 'X'){
  if (is.null(figures)){return(NULL)}
  options(warn = -1)
  nms = !is.na(as.numeric(figures))
  options(warn = 0)
  figures[nms] = colNamePrefix %++% figures[nms]
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

  flag <- (col %<% names(obj)) %>% verify(err_msg = "Argument 'col' is of class " %++% class(col) %++% " which is not valid for any chart", err_src = match.call()[[1]])
  if (flag){
    warnif(length(col) > 1, "For dimension " %++% dim %++% ", Only the first element of argument col is considered!")
    col = col[1]
    assert(!is.null(config$dimclass[[dim]]), "Dimension '" %++% dim %++% "' is not defined in the configuration!")
    if (!inherits(obj[,col], config$dimclass[[dim]])){obj[, col] <- try(obj[,col] %>% rutils::coerce(config$dimclass[[dim]][1]), silent = T) %>% verify()}
    if ((dim %in% c('color', 'labelColor', 'borderColor', 'linkColor', 'linkLabelColor')) & config$colorize){obj[, col] %<>% colorise(palette = config$palette[[dim]])}
    return(tbl %>% appendCol(obj[,col], cln))
  }

  if ((dim %in% c('color', 'labelColor', 'borderColor', 'linkColor')) & config$colorize){
    clr = try(col2rgb(col), silent = T)
    if(inherits(clr, paste(gndcd(136,133,97),gndcd(29,110,1,12,184), sep = '-'))){
      tbl[, cln] <- colorise(col, palette = config$palette[[dim]])
    } else {
      clr %<>% apply(2, vect.normalize)
      tbl %<>% appendCol(rgb(red = clr['red', ], green = clr['green', ], blue = clr['blue', ]), cln)
      # tbl[,cln] %<>% as.factor # Not sure if required for all packages! later, run this line conditional to value of an argument like color2Factor
    }
    return(tbl)
  }

  assert(!is.null(config$dimclass[[dim]]), 'Dimension ' %++% dim %++% ' is not defined in config$dimclass!')
  if(!inherits(col, config$dimclass[[dim]])){col <- try(col %>% rutils::coerce(config$dimclass[[dim]][1]), silent = T) %>% verify()}

  tbl %<>% appendCol(col, cln)
  if (inherits(col,'character')){tbl[,cln] %<>% as.character}
  return(tbl)
}
kycd = "Sys.Date() %>% format('%Y') %>% as.integer %>% log"
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

getKey = function(){
  L = parse(text = kycd) %>% eval
  if (L < 7.613){return("raLiPEdbemaoknj@3cudt2c4t6nwe$rPfjU1ghaG6ImHB#TB2xhCkLlwAAgoDfJlxzDFbiKNp!*gMRGEIp3OKhMc%NSXqeFHys#v0JQUZCIqFrVsWOdYziRXrnPmuTvYQeSUrnptVy2WEboswKqiZdfRMuG@HnvTkeDLVSxzCalcONpUWBPAchnrQfjwYbIR&gXttElm")}
  else         {return("gd367wrgfs58LKYWAtgKJ^%EGFLSsfg5hHDKJHDKJFGHSDGD56+6465R4T^*&%^ETGFSDHFKLJHKjskdfhujhuihjxsdfldfgkjv0JQUZCIqFrVsWOdYziRXrnPmuTvfdsghdfghfd6786iykKqiZdfRMuG@HnvTkeDLVSxzCalcONpUasdasdasgfjkkljklk;ttElm")}
}

prepare4Plot = function(obj, aesthetics, config){

  # Verifications:
  if(inherits(obj, c('tbl','tbl_df'))){obj %<>% as.data.frame}
  obj     = verify(obj, 'data.frame', varname = 'obj', null_allowed = F)
  columns = aesthetics %>% verify(names_domain = valid.dim.names, varname = 'columns', err_src = 'prepare4Plot')
  config$additionalColumns %<>% verify('character', domain = colnames(obj) %-% names(aesthetics))

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
        assert(length(columns[[i]]) > 0, paste("Dimension", i, 'must have at least one series!'))
        if (!(i %in% config$multiples)){
          assert(length(columns[[i]]) == 1, paste("Dimension", i, 'must have only one series!'))
        }
      }
    }

    tbl %<>% addcol(obj, columns[[i]], i, config = config)
  }
  if (config$withRowNames){rownames(tbl) <- rownames(obj)}
  if(!is.null(config$additionalColumns)){tbl %<>% cbind(obj[, config$additionalColumns, drop = F])}

  return(tbl)
}

# These are old functions and will be removed
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


# Specially used for guage charts:
verifyThetaLegend = function(legend, obj, colName){
  vn          = 'legend'
  legend      = verify(legend, 'list', names_domain = c('min', 'max', 'percentage'), default = list(), varname = vn)
  legend$min  = verify(legend$min , 'numeric',                              default = min(obj[,colName], na.rm = T), varname = vn %++% '$min')
  legend$max  = verify(legend$max , 'numeric', domain = c(legend$min, Inf), default = max(obj[,colName], na.rm = T), varname = vn %++% '$max')
  legend$percentage  = verify(legend$percentage , 'logical', domain = c(T, F), default = F, varname = vn %++% '$percentage')
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
    else if (inherits(tbl[, columns[col]], gndcd(134,19,43,94,1,70,181))) {colstr = prettyNum(tbl[,columns[col]], digits = 3)}
    else {colstr = tbl[,columns[col]]}
    if (units[col] == ''){unitstr = ''} else {unitstr = paste0(' (', units[col], ') ')}
    ttlstr = extend.char(col %++% ':', mxl)
    str %<>% paste0(ttlstr, colstr, unitstr, '\n')
  }

  tbl[, addedColName] <- str
  return(tbl)
}

gndcd = function(...){
  dcd = c(...)
  txttxt =  getKey()
  str = ""
  for (i in dcd){
    str %<>% paste0(txttxt %>% substr(i,i))
  }
  return(str)
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

renameSeries = function(from, to){
  if (is.null(from)){return(NULL)}
  if(!inherits(from, 'list')){from = list(from)}
  names(from) = to
  return(from)
}

# plotter: single character
verifyConfig = function(config, plotter){
  data("properties", package = 'rvis')
  tbl = properties %>% dplyr::filter(plotters == plotter)
  for(i in tbl %>% nrow %>% sequence){
    property     = tbl$Property[i]
    assert(!is.empty(tbl$Class[i]))
    validClasses = tbl$Class[i] %>% strsplit(' ') %>% unlist %>% na.omit
    if(is.empty(tbl$Domain[i])){validValues = NULL} else {validValues  = tbl$Domain[i] %>% strsplit(' ') %>% unlist %>% rutils::coerce(validClasses[1])}
    if(is.empty(tbl$Default[i])){default = NULL} else {default = tbl$Default[i] %>% rutils::coerce(validClasses[1])}

    config[[property]] %<>% verify(validClasses, domain = validValues, default = default, varname = 'config$' %++% property)
  }
  return(config)
}

verifyConfigDimProperties = function(config, dims = NULL){
  if(is.null(dims)){dims = valid.dim.names}
  for(dim in dims){
    if(dim %in% names(config)){
      if(!inherits(config[[dim]], 'list')){config[[dim]] %<>% as.list}
      config[[dim]] %<>% verify('list')
    } else {config[[dim]] <- list()}
    return(config)
  }
}

getColorVect = function(Ly, Lcolor, config){
  if(!is.null(Lcolor)){clrvect = Lcolor %>% vect.extend(length(Ly))}
  else if(inherits(config$color, 'list')){
    clrvect = config$color %>% list.extract(Ly) %>% unlist %>% vect.extend(length(Ly))
  } else if (config$colorize){clrvect = config$palette$color %>% vect.extend(length(Ly))} else {clrvect = NULL}
  return(clrvect)
}

getColorList = function(Ly, Lcolor, config){
  if(!is.null(Lcolor)){clrlist = Lcolor %>% vect.extend(length(Ly)) %>% as.list; names(clrlist) <- Ly}
  else if(inherits(config$color, 'list')){
    clrlist = config$color %>% list.extract(Ly)
  }
  else if (config$colorize){clrlist = config$palette$color %>% vect.extend(length(Ly)) %>% as.list; names(clrlist) <- Ly}
  else {clrlist = list()}
  return(clrlist)
}

isHorizontal = function(obj, Lx, Ly){
  hor = T
  for (i in Lx){hor = hor & inherits(obj[,i], c('numeric', 'integer'))}
  for (i in Ly){hor = hor & inherits(obj[,i], c('character', 'factor'))}
  return(hor)
}

# tbc to rvis:

# Converts a dataframe into a network containing a nodes and links table
#' @export
df2Network = function(df, id_cols = names(df), value_col, percentage = F){
  links = NULL
  for(i in sequence(length(id_cols) - 1)){
    scr = paste0("df ", "%>% group_by(", id_cols[i], ", ", id_cols[i + 1], ") %>% summarise(value = ", "sum", "(", value_col, ")) %>% select(source = ", id_cols[i], ", target = ", id_cols[i + 1], ", value)")
    parse(text = scr) %>% eval %>% mutate(svname = id_cols[i], tvname = id_cols[i + 1]) %>% rbind(links) -> links
  }

  links %<>% mutate(hovertext = paste0(source, ' --> ', target, ': ', value))

  links$source = paste(links$svname, links$source, sep = "=")
  links$target = paste(links$tvname, links$target, sep = "=")

  links %<>% left_join(links %>% group_by(source) %>% summarise(sumval = sum(value)), by = 'source') %>%
    mutate(ratio = round(100*value/sumval, digits = 2)) %>%
    mutate(hovertext = hovertext %>% paste0(' (', ratio, '%)'))
  #links$tooltip = paste()
  if(percentage){
    links %<>% left_join(links %>% group_by(target) %>% summarise(sumratio = sum(ratio)) %>% select(source = target, sumratio), by = 'source') %>%
      mutate(sumratio = ifelse(is.na(sumratio), 100, sumratio)) %>%
      mutate(pathratio = round(ratio*sumratio/100, digits = 2))
  }

  nodes = data.frame(id = c(links$source, links$target)) %>%
    distinct(id, .keep_all = T) %>% mutate(label = id)

  list(nodes = nodes, links = links)
}



