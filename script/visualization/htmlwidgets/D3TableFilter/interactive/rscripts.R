
### interactive/rscripts.R ------------------------
# Header
# Filename:       rscripts.R
# Description:    Contains functions generating various R scripts.
# Author:         Nima Ramezani Taghiabadi
# Email :         nima.ramezani@cba.com.au
# Start Date:     23 May 2017
# Last Revision:  23 May 2017
# Version:        0.0.1
#

# Version History:

# Version   Date                Action
# ----------------------------------
# 0.0.1     23 May 2017         Initial issue for D3TableFilter syncing observers


# for a output object of type D3TableFilter, D3TableFilter generates an input
# "<chartID>_edit"
# this observer does a simple input validation and sends a confirm or reject message after each edit.
# Only server to client!
D3TableFilter.observer.column.footer.R = function(itemID){paste0("
                                                                 nms = c('rownames', colnames(sync$", itemID, "))
                                                                 for (col in names(sync$", itemID, "_column.footer)){
                                                                 wch = which(nms == col) - 1
                                                                 if   (inherits(sync$", itemID, "_column.footer[[col]], 'function')){val = sapply(list(sync$", itemID, "[report$", itemID, "_filtered, col]), sync$", itemID, "_column.footer[[col]])}
                                                                 else {val = sync$", itemID, "_column.footer[[col]] %>% as.character}
                                                                 for (cn in wch){if(!is.empty(val)){setFootCellValue(session, tbl = '", itemID, "', row = 1, col = cn, value = val)}}
                                                                 }
                                                                 
                                                                 ")}  

# server to client
D3TableFilter.observer.column.editable.R = function(itemID){paste0("
                                                                   
                                                                   #debug(check)
                                                                   #check(x = sync$", itemID, "_column.editable)
                                                                   
                                                                   enacols = sync$", itemID, "_column.editable %>% unlist %>% coerce('logical') %>% which %>% names %>% intersect(c('rownames', colnames(sync$", itemID, ")))
                                                                   discols = c('rownames', colnames(sync$", itemID, ")) %-% enacols
                                                                   for(col in enacols){
                                                                   if (col == 'rownames'){
                                                                   enableEdit(session, '", itemID, "', 'col_0')
                                                                   } else {
                                                                   w = which(names(sync$", itemID, ") == col)
                                                                   enableEdit(session, '", itemID, "', 'col_' %+% w);  
                                                                   }
                                                                   }
                                                                   
                                                                   for(col in discols){
                                                                   if (col == 'rownames'){
                                                                   disableEdit(session, '", itemID, "', 'col_0')
                                                                   } else {
                                                                   w = which(names(sync$", itemID, ") == col)
                                                                   disableEdit(session, '", itemID, "', 'col_' %+% w);  
                                                                   }
                                                                   }
                                                                   ")
}  

# client to server:
D3TableFilter.observer.edit.R = function(itemID) {paste0("
                                                         if(is.null(input$", itemID, "_edit)) return(NULL);
                                                         edit <- input$", itemID, "_edit;
                                                         
                                                         isolate({
                                                         # need isolate, otherwise this observer would run twice
                                                         # for each edit
                                                         id  <- edit$id;
                                                         row <- as.integer(edit$row);
                                                         col <- as.integer(edit$col);
                                                         val <- edit$val;
                                                         nms <- colnames(sync$", itemID, ")
                                                         
                                                         if(col == 0) {
                                                         oldval <- rownames(sync$", itemID, ")[row];
                                                         cellClass = 'character'
                                                         fltr = items[['", itemID, "']]$filter[['rownames']]} 
                                                         else {
                                                         oldval <- sync$", itemID, "[row, col];
                                                         fltr = items[['", itemID, "']]$filter[[nms[col]]]
                                                         cellClass = class(sync$", itemID, "[, col])[1]
                                                         }
                                                         val0   = val
                                                         val    = try(coerce(val, cellClass), silent = T)
                                                         accept = inherits(val, cellClass) & !is.empty(val)
                                                         
                                                         if(accept & inherits(fltr, 'list') & !is.empty(fltr)){
                                                         accept = parse(text = filter2R(fltr)) %>% eval
                                                         }
                                                         
                                                         
                                                         if (accept){
                                                         if(col == 0) {
                                                         rownames(sync$", itemID, ")[row] <- val;
                                                         rownames(report$", itemID, ")[row] <- val;
                                                         } else {
                                                         shp = items[['", itemID, "']]$config$column.shape[[nms[col]]]
                                                         if (!is.null(shp)){
                                                         if(shp == 'radioButtons'){
                                                         sync$", itemID, "[, col] <- FALSE;
                                                         report$", itemID, "[, col] <- FALSE;
                                                         }
                                                         }
                                                         sync$", itemID, "[row, col] <- val;
                                                         report$", itemID, "[row, col] <- val;
                                                         
                                                         }
                                                         # confirm edits
                                                         confirmEdit(session, tbl = '", itemID, "', row = row, col = col, id = id, value = val);
                                                         report$", itemID, "_lastEdits['Success', 'Row'] <- row;
                                                         report$", itemID, "_lastEdits['Success', 'Column'] <- col;
                                                         report$", itemID, "_lastEdits['Success', 'Value'] <- val;
                                                         } else {
                                                         rejectEdit(session, tbl = '", itemID, "', row = row, col = col,  id = id, value = oldval);
                                                         report$", itemID, "_lastEdits['Fail', 'Row'] <- row;
                                                         report$", itemID, "_lastEdits['Fail', 'Column'] <- col;
                                                         report$", itemID, "_lastEdits['Fail', 'Value'] <- val0;
                                                         }
                                                         })
                                                         ")}

# Use it later for creating the default footer:
# footer = list('Mean', object[[i]] %>% colMeans %>% as.matrix %>% t) %>% as.data.frame
# names(footer) = c('Rownames', colnames(object[[i]]))

# Client 2 Server: FOB1
D3TableFilter.observer.filter.C2S.R = function(itemID){
  paste0(" 
         if(is.null(input$", itemID, "_filter)){return(NULL)}
         isolate({
         report$", itemID, "_filtered <- unlist(input$", itemID, "_filter$validRows);
         sync$", itemID, "_column.filter = list()
         nms = c('rownames', colnames(sync$", itemID, "))
         # lapply(input$", itemID, "_filter$filterSettings, function(x) )
         for(flt in input$", itemID, "_filter$filterSettings){
         colnumb = flt$column %>% substr(5, nchar(flt$column)) %>% as.integer
         colname = nms[colnumb]
         if(!is.na(colname)){sync$", itemID, "_column.filter[[colname]] = chif(is.empty(flt$value), NULL, flt$value)}
         # debug(check)
         # check('FOB1', colnumb, colname, input$", itemID, "_filter$filterSettings, flt, sync$", itemID, "_column.filter)
         }
         # report$", itemID, "_column.filter = sync$", itemID, "_column.filter
         })
         ")
}


#  Server 2 Client: FOB2
D3TableFilter.observer.filter.S2C.R = function(itemID){
  paste0(" 
         if(is.null(sync$", itemID, "_column.filter)){sync$", itemID, "_column.filter = items[['", itemID, "']]$config$column.filter}
         isolate({
         for(flt in input$", itemID, "_filter$filterSettings){
         nms = c('rownames', colnames(sync$", itemID, "))
         
         colnumb = flt$column %>% substr(5, nchar(flt$column)) %>% as.integer
         colname = nms[colnumb]
         colnumb = colnumb - 1
         
         if (colname %in% names(sync$", itemID, "_column.filter)){
         if (!identical(flt$value, sync$", itemID, "_column.filter[[colname]])){
         # set filter
         setFilter(session, tbl = '", itemID, "', col = 'col_' %+% colnumb, filterString = sync$", itemID, "_column.filter[[colname]], doFilter = TRUE);
         }
         # else {do nothing}
         } else {
         setFilter(session, tbl = '", itemID, "', col = 'col_' %+% colnumb, filterString = '', doFilter = TRUE);
         }
         # debug(check)
         # check('FOB2', y = input$", itemID, "_filter$filterSettings, z = colnumb, t = colname, r = flt, s = sync$", itemID, "_column.filter)
         # report$", itemID, "_column.filter = sync$", itemID, "_column.filter
         }
         })
         ")
}  

# client to server: sob1
D3TableFilter.observer.selected.C2S.R = function(itemID){
  paste0("
         if(is.null(input$", itemID, "_select)){return(NULL)}
         isolate({
         sync$", itemID, "_selected = input$", itemID, "_select
         report$", itemID, "_selected = sync$", itemID, "_selected
         })
         ")
}


# server 2 client: sob2
D3TableFilter.observer.selected.S2C.R = function(itemID){
  paste0("
         if(is.null(sync$", itemID, "_selected)){sync$", itemID, "_selected = items[['", itemID, "']]$config$selected}
         isolate({
         if(is.null(report$", itemID, "_selected)){report$", itemID, "_selected = items[['", itemID, "']]$config$selected}
         if(is.null(sync$", itemID, "_row.color)){sync$", itemID, "_row.color = items[['", itemID, "']]$config$row.color}
         sel   = sync$", itemID, "_selected %-% report$", itemID, "_selected
         desel = report$", itemID, "_selected %-% sync$", itemID, "_selected
         for (i in sel){  setRowClass(session, tbl = '", itemID, "', row = i, class = items['", itemID, "']$config$selection.color)}
         for (i in desel){setRowClass(session, tbl = '", itemID, "', row = i, class = chif(sync$", itemID, "_row.color[i] == items['", itemID, "']$config$selection.color, '', items[['", itemID, "']]$config$row.color[i]))}
         report$", itemID, "_selected = sync$", itemID, "_selected
         })
         ")
}


# server 2 client: for row color: cob2
D3TableFilter.observer.color.S2C.R = function(itemID){
  paste0("
         if(is.null(sync$", itemID, "_row.color)){sync$", itemID, "_row.color = items[['", itemID, "']]$config$row.color}
         isolate({
         # debug(check)
         # check(x = 'cob2', y = sync$", itemID, "_row.color, z = report$", itemID, "_row.color, t = sync$", itemID, ")
         if(is.null(report$", itemID, "_row.color)){report$", itemID, "_row.color = items[['", itemID, "']]$config$row.color}
         w = which(sync$", itemID, "_row.color != report$", itemID, "_row.color)
         for (i in w){setRowClass(session, tbl = '", itemID, "', row = i, class = sync$", itemID, "_row.color[i])}
         report$", itemID, "_row.color = sync$", itemID, "_row.color
         })
         ")
}

# server to client: for table contents: tob2 
D3TableFilter.observer.table.S2C.R = function(itemID){
  paste0("
         if(is.null(sync$", itemID, ")){sync$", itemID, " = items[['", itemID, "']]$data}
         isolate({
         if(is.null(report$", itemID, ")){report$", itemID, " = items[['", itemID, "']]$data}
         # debug(check)
         # check(x = 'tob2', y = report$", itemID, ", z = sync$", itemID, ")
         for (i in sequence(ncol(sync$", itemID, "))){
         w = which(sync$", itemID, "[,i] != report$", itemID, "[,i])
         for (j in w) {
         setCellValue(session, tbl = '", itemID, "', row = j, col = i, value = sync$", itemID, "[j,i], feedback = TRUE)
         report$", itemID, "[j,i] = sync$", itemID, "[j,i]
         }
         }
         rnew = rownames(sync$", itemID, ")
         rold = rownames(report$", itemID, ")
         w  = which(rnew != rold)
         
         for (j in w) {
         setCellValue(session, tbl = '", itemID, "', row = j, col = 0, value = rnew[j], feedback = TRUE)
         rownames(report$", itemID, ")[j] = rnew[j]
         }
         })
         ")
}

D3TableFilter.service = function(itemID){
  paste0("items[['", itemID, "']]$data %>% D3TableFilter.table(config = items[['", itemID, "']]$config, width = items[['", itemID, "']]$width, height = items[['", itemID, "']]$height)")
}
### interactive/jscripts.R ------------------------
#### dimple:
dimple.js = function(field_name = 'group'){
  S1 =   
    '<script>
  myChart.axes.filter(function(ax){return ax.position == "x"})[0].titleShape.text(opts.xlab)
  myChart.axes.filter(function(ax){return ax.position == "y"})[0].titleShape.text(opts.ylab)
  myChart.legends = [];
  svg.selectAll("title_text")
  .data(["'
  S2 = ''
  S3 = 
    '"])
  .enter()
  .append("text")
  .attr("x", 499)
  .attr("y", function (d, i) { return 90 + i * 14; })
  .style("font-family", "sans-serif")
  .style("font-size", "10px")
  .style("color", "Black")
  .text(function (d) { return d; });
  var filterValues = dimple.getUniqueValues(data, "'
  S5 = '");
  l.shapes.selectAll("rect")
  .on("click", function (e) {
  var hide = false;
  var newFilters = [];
  filterValues.forEach(function (f) {
  if (f === e.aggField.slice(-1)[0]) {
  hide = true;
  } else {
  newFilters.push(f);
  }
  });
  if (hide) {
  d3.select(this).style("opacity", 0.2);
  } else {
  newFilters.push(e.aggField.slice(-1)[0]);
  d3.select(this).style("opacity", 0.8);
  }
  filterValues = newFilters;
  myChart.data = dimple.filterData(data, "'
  
  S6 = '", filterValues);
  myChart.draw(800);
  myChart.axes.filter(function(ax){return ax.position == "x"})[0].titleShape.text(opts.xlab)
  myChart.axes.filter(function(ax){return ax.position == "y"})[0].titleShape.text(opts.ylab)
  });
  </script>'
  return(paste0(S1,S2, S3, field_name, S5, field_name, S6))
}


#### D3TableFilter:
D3TableFilter.color.single.js = function(col){
  JS('function colorScale(obj, i){
     return "' %+% col %+% '"}')
}

D3TableFilter.color.nominal.js = function(domain, range){
  range %<>% vect.extend(length(domain))
  dp = paste(domain, range) %>% duplicated
  domain = domain[!dp]
  range  = range[!dp]
  ss = 'function colorScale(obj,i){
  var color = d3.scale.ordinal().domain([' %+% 
    paste('"' %+% domain %+% '"', collapse = ',') %+% ']).range([' %+%
    paste('"' %+% range  %+% '"', collapse = ',') %+% ']);
  return color(i);}'
  return(JS(ss))
}

D3TableFilter.color.numeric.js = function(domain, range){
  N  = length(range) 
  q  = domain %>% quantile(probs = (0:(N-1))/(N-1))
  ss = 'function colorScale(obj,i){
  var color = d3.scale.linear().domain([' %+% 
    paste(q, collapse = ',') %+% ']).range([' %+%
    paste('"' %+% range  %+% '"', collapse = ',') %+% ']);
  return color(i);}'
  return(JS(ss))
}


D3TableFilter.shape.bar.js = function(format = '.1f'){
  JS(paste0('function makeGraph(selection){
            // find out wich table and column
            var regex = /(col_\\d+)/;
            var col = regex.exec(this[0][0].className)[0];
            var regex = /tbl_(\\S+)/;
            var tbl = regex.exec(this[0][0].className)[1];
            var innerWidth = 117;
            var innerHeight = 14;
            
            // create a scaling function
            var max = colMax(tbl, col);
            var min = colMin(tbl, col);
            var wScale = d3.scale.linear()
            .domain([0, max])
            .range([0, innerWidth]);
            
            // text formatting function
            var textformat = d3.format("', format, '");
            
            // column has been initialized before, update function
            if(tbl + "_" + col + "_init" in window) {
            var sel = selection.selectAll("svg")
            .selectAll("rect")
            .transition().duration(500)
            .attr("width", function(d) { return wScale(d.value)});
            var txt = selection
            .selectAll("text")
            .text(function(d) { return textformat(d.value); });
            return(null);
            }
            
            // can remove padding here, but still cant position text and box independently
            this.style("padding", "5px 5px 5px 5px");
            
            // remove text. will be added back later
            selection.text(null);
            
            var svg = selection.append("svg")
            .style("position",  "absolute")
            .attr("width", innerWidth)
            .attr("height", innerHeight);
            
            var box = svg.append("rect")
            .style("fill", "lightblue")
            .attr("stroke","none")
            .attr("height", innerHeight)
            .attr("width", min)
            .transition().duration(500)
            .attr("width", function(d) { return wScale(d.value); });
            
            // format number and add text back
            var textdiv = selection.append("div");
            textdiv.style("position",  "relative")
            .attr("align", "right");
            
            textdiv.append("text")
            .text(function(d) { return textformat(d.value); });
            window[tbl + "_" + col + "_init"] = true;
}'))
} 

D3TableFilter.shape.bubble.js = function(){
  
  JS(paste0('function makeGraph(selection){
            
            // find out wich table and column
            var regex = /(col_\\d+)/;
            var col = regex.exec(this[0][0].className)[0];
            var regex = /tbl_(\\S+)/;
            var tbl = regex.exec(this[0][0].className)[1];
            
            // create a scaling function
            var domain = colExtent(tbl, col);
            var rScale = d3.scale.sqrt()
            .domain(domain)
            .range([8, 14]);
            
            // column has been initialized before, update function
            if(tbl + "_" + col + "_init" in window) {
            var sel = selection.selectAll("svg")
            .selectAll("circle")
            .transition().duration(500)
            .attr("r", function(d) { return rScale(d.value)});
            return(null);
            }
            
            // remove text. will be added later within the svg
            selection.text(null)
            
            // create svg element
            var svg = selection.append("svg")
            .attr("width", 28)
            .attr("height", 28);
            
            // create a circle with a radius ("r") scaled to the 
            // value of the cell ("d.value")
            var circle = svg.append("g")
            .append("circle").attr("class", "circle")
            .attr("cx", 14)
            .attr("cy", 14)
            .style("fill", "orange")
            .attr("stroke","none")
            .attr("r", domain[0])
            .transition().duration(400)
            .attr("r", function(d) { return rScale(d.value); }); 
            
            // place the text within the circle
            var text = svg.append("g")
            .append("text").attr("class", "text")
            .style("fill", "black")
            .attr("x", 14)
            .attr("y", 14)
            .attr("dy", ".35em")
            .attr("text-anchor", "middle")
            .text(function (d) { return d.value; });
            window[tbl + "_" + col + "_init"] = true;
            
}'))
}


D3TableFilter.font.bold.js = JS('function makeGraph(selection){selection.style("font-weight", "bold")}')

D3TableFilter.font.js = function(weight = 'bold', side = 'right', format = '.1f'){
  sidestr   = chif(is.null(side)  , '', paste0('.classed("text-', side, '", true)'))
  weightstr = chif(is.null(weight), '', paste0('.style("font-weight", "', weight ,'")'))
  formatstr2 = chif(is.null(format), '', paste0('.text(function(d) { return textformat(d.value); })'))
  formatstr1 = chif(is.null(format), '', paste0('var textformat = d3.format("', format, '");'))
  JS(paste0('function makeGraph(selection){', formatstr1, 'selection', sidestr , weightstr, formatstr2, ';}'))
}



