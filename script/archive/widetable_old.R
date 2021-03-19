################## WIDE TABLES: ##################
WIDETABLE = setRefClass(
  'WIDETABLE', 
  fields  = list(name = "character", path = "character", meta = 'data.frame', data = 'list', 
                 numrows = 'integer', numcols = 'integer', row_index = 'integer', size_limit = "numeric", 
                 cell_size = 'numeric'), 
  methods = list(
    initialize = function(...){
      callSuper(...)
      if(is.empty(name)){name <<- paste0('WT', sample(10000:99999, 1))}
      if(is.empty(size_limit)){size_limit <<- 10^9}
      if(is.empty(cell_size)){cell_size <<- 0}
      if(is.empty(numcols)){numcols <<- 0L}
      if(is.empty(numrows)){numrows <<- 0L}
      row_index <<- sequence(numrows)
      if(is.empty(path)){path <<- '.'}
      assert(file.exists(path), 'Given path does not exist!')
      tables_path = path %>% paste(name, sep = '/')
      if(file.exists(tables_path)){
        fls = tables_path %>% list.files
        for(tn in fls){
          path %>% paste(name, tn, sep = '/') %>% readRDS -> tbl
          add_table(tbl, table_name = tn %>% gsub(pattern = '.rds', replacement = ''), save = F)
        }
      }
    },
    
    save_table = function(tn){
      assert(!is.null(data[[tn]]), 'Given table name does not exist in memory.')
      tables_path = path %>% paste(name, sep = '/')
      if(file.exists(tables_path)){
        saveRDS(data[[tn]], paste0(tables_path, '/', tn, '.rds'))
      } else {
        dir.create(tables_path)
      }
    },
    
    add_table = function(df, table_name = NULL, save = T){
      "Adds a new table to the list of tables"
      if(is.empty(numrows) | (numrows == 0)){numrows <<- nrow(df); row_index <<- sequence(numrows)} else {assert(nrow(df) == numrows, paste('Added table must have exactly', numrows, 'rows,', 'but', 'has', nrow(df), '!'))}
      
      # (ctbr: columns to be removed)
      ctbr = colnames(df) %^% meta$column
      if(length(ctbr) > 0){
        cat('\n', 'Warning: ', length(ctbr), ' columns found among existing tables and removed!')
        df = df[colnames(df) %-% ctbr]
      }
      if(ncol(df) > 0){
        if(is.null(table_name)) {tblname = paste0('T', sample(10000:99999, 1))} else {tblname = table_name}
        classes  = colnames(df) %>% sapply(function(cn) df %>% pull(cn) %>% class %>% first) %>% unname
        n_unique = colnames(df) %>% sapply(function(cn) df %>% pull(cn) %>% unique %>% length) %>% unlist
        meta %>% rbind(
          data.frame(column = colnames(df), class = classes, n_unique = n_unique, table = tblname, filename = paste(tblname, 'rds', sep = '.'), stringsAsFactors = F)
        ) ->> meta
        data[[tblname]] <<- df
        cell_size <<- max(cell_size, object.size(df)/(nrow(df)*ncol(df)))
        numcols <<- numcols + ncol(df)
        if(save) save_table(tblname)
        control_size()
      }
    },
    
    load_table = function(tn){
      if(is.null(data[[tn]])){
        cols = meta %>% filter(table == tn) %>% pull(column) %>% unique
        readRDS(paste0(path, '/', name, '/', tn, '.rds'))[cols][row_index, , drop = F] ->> data[[tn]]
      }
      return(data[[tn]])
    },
    
    control_size = function(){
      while(object.size(data) > size_limit){
        data[[1]] <<- NULL
      }
      gc()
    },
    
    clear = function(){
      data <<- list()
    },
    
    rbind_dataframe = function(df){
      # For now:
      assert(colnames(df) %==% meta$column, 'Columns of the two table do not match!')
      
      tables = x$meta$table %>% unique %>% as.character
      
      row_index <<- sequence(numrows)
      for(tn in tables){
        tbl = load_table(tn)
        tbl %<>% rbind(df[colnames(tbl)])
        data[[tn]] <<- tbl
        save_table(tn)
        control_size()
      }
      numrows   <<- numrows + nrow(df)
      row_index <<- sequence(numrows)
    },
    
    leftjoin_dataframe = function(df, by = character()){
      
    },
    
    fill_na_with = function(val = 0, cols = unique(meta$column)){
      tables = meta %>% filter(column %in% cols) %>% pull(table) %>% unique
      for(tn in tables){
        tbl = load_table(tn)
        if(sum(is.na(tbl)) > 0){
          tbl[, colnames(tbl) %^% cols] %<>% na2value(val)
          data[[tn]] <<- tbl
          save_table(tn)
        }
        control_size()
      }
    }
  ))

load_widetable = function(name, path = '.', size_limit = 10^9){
  path %>% paste(name, sep = '/') %>% file.exists %>% 
    assert(sprintf("No wide table named as '%s' found in %s!", name, path))
  
  out = WIDETABLE(path = path, name = name)
  fls = path %>% paste(name, sep = '/') %>% list.files
  if('.meta.rds' %in% fls){
    path %>% paste(name, '.meta.rds', sep = '/') %>% readRDS -> mt
    assert(inherits(mt, 'data.frame'), "File '.meta.rds' is not a data.frame!")
    assert(colnames(mt) == c('column', 'class', 'table', 'filename'), "File '.meta.rds' has unknown column labels!")
    assert(numerics(mt) == colnames(mt), "File '.meta.rds' has unknown column types!")
    
    out$meta <- mt
    out$numcols <- mt$column %>% unique %>% length
    
  } else {
    for(tn in fls){
      path %>% paste(name, tn, sep = '/') %>% readRDS -> tbl
      
      if(is.empty(out$numrows)){out$numrows <- nrow(tbl)} else {assert(nrow(tbl) == out$numrows, sprintf('Added table must have exactly %s rows, but has $s!', out$numrows, nrow(tbl)))}
      ctbr = colnames(tbl) %^% meta$column
      if(length(ctbr) > 0){
        cat('\n', 'Warning: ', length(ctbr), ' columns found among existing tables and removed!')
        tbl = tbl[colnames(tbl) %-% ctbr]
      }
      
      classes = colnames(df) %>% sapply(function(cn) df %>% pull(cn) %>% class %>% first) %>% unname
      out$meta %>% rbind(
        data.frame(column = colnames(df), class = classes, table = tblname, filename = paste(tblname, 'rds', sep = '.'), stringsAsFactors = F)
      ) -> out$meta
      out$data[[tn]] <- tbl
      out$numcols <- out$numcols + ncol(tbl)
      out$control_size()
    }
  }
  return(out)
}

rbind_widetables= function(x, ...){
  valid_types = c('data.frame', 'tibble', 'matrix', 'data.table', 'WIDETABLE')
  args = list(...)
  for(arg in args){assert(inherits(arg, valid_types, 'Invalid argument type!'))}
  
  for(arg in args){x = rbind.WIDETABLE(x, arg)}
  return(x)
}

rbind.WIDETABLE = function(x, y){
  if(inherits(y, 'WIDETABLE')){
    x %>% rbind_widetable_with_widetable(y)
  } else {
    x %>% rbind_widetable_with_dataframe(y)
  }
  # todo: treat matrix accordingly
}

# Generic Functions:
setMethod("names", "WIDETABLE", function(x) x$meta$column %>% unique %>% as.character)
setMethod("colnames", "WIDETABLE", function(x) x$meta$column %>% unique %>% as.character)
setMethod("nrow", "WIDETABLE", function(x) length(x$row_index))
setMethod("ncol", "WIDETABLE", function(x) x$meta$column %>% unique %>% length)

# setMethod("head", "WIDETABLE", function(x, ...) head(x$data, ...))
# setMethod("tail", "WIDETABLE", function(x, ...) tail(x$data, ...))
setMethod("dim", "WIDETABLE", function(x) c(length(x$row_index), x$numcols))
# setMethod("colSums", "WIDETABLE", function(x) colSums(x$data))
# setMethod("rowSums", "WIDETABLE", function(x) rowSums(x$data))
# setMethod("length", "WIDETABLE", function(x) length(x$time))
# setMethod("show", "WIDETABLE", function(object) show(object$data))
setMethod("as.matrix", "WIDETABLE", function(x) {
  tables = x$meta$table %>% unique
  out    = NULL
  for(tn in tables){
    if(is.null(out)) {out = x$load_table(tn) %>% as.matrix}
    else {out %<>% cbind(x$load_table(tn) %>% as.matrix)}
    x$control_size()
  }
  return(out)
})

setMethod("as.data.frame", "WIDETABLE", function(x) {
  tables = x$meta$table %>% unique
  out    = NULL
  for(tn in tables){
    if(is.null(out)) {out = x$load_table(tn) %>% as.data.frame}
    else {out %<>% cbind(x$load_table(tn) %>% as.data.frame)}
    x$control_size()
  }
  return(out)
})


'[[.WIDETABLE' = function(obj, figure = NULL){
  figure %>% verify('character', domain = colnames(obj), lengths = 1)
  obj$meta %>% dplyr::filter(column == figure) %>% dplyr::pull(table) %>% unique -> tables
  assert(length(tables) == 1, 'Column found in more than one table!')
  out = obj$load_table(tables) %>% dplyr::pull(figure)
  obj$control_size()
  return(out)
}

'[.WIDETABLE'   = function(obj, rows = NULL, figures = NULL, drop = T){
  if(inherits(rows, 'logical')){rows = which(rows)}
  if(inherits(figures, 'logical')){figures = which(figures)}
  if(is.null(figures)){
    if(inherits(rows, 'character')){
      figures = rows
      rows  = NULL
    } else {
      figures = colnames(obj)
    }
  }
  if(inherits(figures, 'integer')){figures = obj$meta$column[figures]} 
  else figures = figures %>% unique %>% verify('character', domain = obj$meta$column)
  
  nrw = chif(is.null(rows), obj$numrows, length(rows))
  ncl = length(figures)
  
  if(obj$cell_size*nrw*ncl > obj$size_limit) {
    out = obj$copy()
    out$meta %<>% filter(column %in% figures)
    out$data <- list()
    out$numcols   <- out$meta$column %>% unique %>% length
    out$row_index <- chif(is.null(rows), obj$row_index, obj$row_index[rows])
    return(out)
  }
  
  obj$meta %>% filter(column %in% figures) %>% pull(table) %>% unique -> tables
  out = NULL
  for(tn in tables){
    df = obj$load_table(tn)
    df = df[colnames(df) %^% figures]
    if(!is.null(rows)){
      df = df[rows, , drop = F]
    }
    obj$control_size()
    if(is.null(out)) {out = df} else {out %<>% cbind(df)}
  }
  outcols = figures %^% colnames(out)
  
  if(drop){return(out[, outcols])} else {return(out[outcols])}
}
