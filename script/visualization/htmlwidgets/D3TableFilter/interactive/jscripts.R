# jscripts.R ----------------------------------------------------------------


# Header
# Filename:       jscripts.R
# Description:    Contains javascript function code for all htmlWidgets used in rvis package.
# Author:         Nicolas Berta
# Email :         nicolas.berta@gmail.com.au
# Start Date:     13 June 2017
# Last Revision:  23 February 2018
# Version:        0.0.3
#

# Version History:

# Version   Date               Action
# ----------------------------------
# 0.0.1     13 June 2017       Initial issue
# 0.0.2     23 February 2018   Function DT.link.click.js() added
# 0.0.3     23 February 2018   Function DT.links.click.js() added and exported

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
     return "' %++% col %++% '"}')
  }

D3TableFilter.color.nominal.js = function(domain, range){
  range %<>% vect.extend(length(domain))
  dp = paste(domain, range) %>% duplicated
  domain = domain[!dp]
  range  = range[!dp]
  ss = 'function colorScale(obj,i){
  var color = d3.scale.ordinal().domain([' %++%
    paste('"' %++% domain %++% '"', collapse = ',') %++% ']).range([' %++%
    paste('"' %++% range  %++% '"', collapse = ',') %++% ']);
  return color(i);}'
  return(JS(ss))
}

D3TableFilter.color.numeric.js = function(domain, range){
  N  = length(range)
  q  = domain %>% quantile(probs = (0:(N-1))/(N-1))
  ss = 'function colorScale(obj,i){
  var color = d3.scale.linear().domain([' %++%
    paste(q, collapse = ',') %++% ']).range([' %++%
    paste('"' %++% range  %++% '"', collapse = ',') %++% ']);
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

### DT:
DT.link.click.js = function(link){
  nms = names(link$inputs)
  listOfInputs = paste(nms, ': $(this).data("', nms, '")') %>% paste(collapse = ', \n')
  paste0('$(document).on("click", ".', link$class.name, '", function(e) {
         e.preventDefault();
         Shiny.onInputChange("', link$shinyInputName, '", {
         ', listOfInputs, '  });
});')
}

DT.links.click.js = function(links){
  scr = ''
  for (item in links){scr %<>% paste(DT.link.click.js(item), sep = '\n \n')}
  return(scr)
}

# dygraphs:
dygraphs.shape.multibar.js = JS("
                                function multiColumnBarPlotter(e) {
                                // We need to handle all the series simultaneously.
                                function darkenColor(colorStr) {
                                // Defined in dygraph-utils.js
                                var color = Dygraph.toRGB_(colorStr);
                                color.r = Math.floor((255 + color.r) / 2);
                                color.g = Math.floor((255 + color.g) / 2);
                                color.b = Math.floor((255 + color.b) / 2);
                                return 'rgb(' + color.r + ',' + color.g + ',' + color.b + ')';
                                }

                                if (e.seriesIndex !== 0) return;
                                var g = e.dygraph;
                                var ctx = e.drawingContext;
                                var sets = e.allSeriesPoints;
                                var y_bottom = e.dygraph.toDomYCoord(0);
                                // Find the minimum separation between x-values.
                                // This determines the bar width.
                                var min_sep = Infinity;
                                for (var j = 0; j < sets.length; j++) {
                                var points = sets[j];
                                for (var i = 1; i < points.length; i++) {
                                var sep = points[i].canvasx - points[i - 1].canvasx;
                                if (sep < min_sep) min_sep = sep;
                                }
                                }
                                var bar_width = Math.floor(2.0 / 3 * min_sep);
                                var fillColors = [];
                                var strokeColors = g.getColors();
                                for (var i = 0; i < strokeColors.length; i++) {
                                fillColors.push(darkenColor(strokeColors[i]));
                                }
                                for (var j = 0; j < sets.length; j++) {
                                ctx.fillStyle = fillColors[j];
                                ctx.strokeStyle = strokeColors[j];
                                for (var i = 0; i < sets[j].length; i++) {
                                var p = sets[j][i];
                                var center_x = p.canvasx;
                                var x_left = center_x - (bar_width / 2) * (1 - j/(sets.length-1));
                                ctx.fillRect(x_left, p.canvasy,
                                bar_width/sets.length, y_bottom - p.canvasy);
                                ctx.strokeRect(x_left, p.canvasy,
                                bar_width/sets.length, y_bottom - p.canvasy);
                                }}}
                                ")

dygraphs.shape.bar.js = JS("
                           // This function draws bars for a single series. See
                           // multiColumnBarPlotter below for a plotter which can draw multi-series
                           // bar charts.
                           function barChartPlotter(e) {
                           function darkenColor(colorStr) {
                           // Defined in dygraph-utils.js
                           var color = Dygraph.toRGB_(colorStr);
                           color.r = Math.floor((255 + color.r) / 2);
                           color.g = Math.floor((255 + color.g) / 2);
                           color.b = Math.floor((255 + color.b) / 2);
                           return 'rgb(' + color.r + ',' + color.g + ',' + color.b + ')';
                           }
                           var ctx = e.drawingContext;
                           var points = e.points;
                           var y_bottom = e.dygraph.toDomYCoord(0);
                           ctx.fillStyle = darkenColor(e.color);
                           // Find the minimum separation between x-values.
                           // This determines the bar width.
                           var min_sep = Infinity;
                           for (var i = 1; i < points.length; i++) {
                           var sep = points[i].canvasx - points[i - 1].canvasx;
                           if (sep < min_sep) min_sep = sep;
                           }
                           var bar_width = Math.floor(2.0 / 3 * min_sep);
                           // Do the actual plotting.
                           for (var i = 0; i < points.length; i++) {
                           var p = points[i];
                           var center_x = p.canvasx;
                           ctx.fillRect(center_x - bar_width / 2, p.canvasy,
                           bar_width, y_bottom - p.canvasy);
                           ctx.strokeRect(center_x - bar_width / 2, p.canvasy,
                           bar_width, y_bottom - p.canvasy);
                           }}
                           ")

dygraphs.shape.candle.js = JS("
                              function candlePlotter(e) {
                              // This is the officially endorsed way to plot all the series at once.
                              var BAR_WIDTH = 8;
                              if (e.seriesIndex !== 0) return;
                              var setCount = e.seriesCount;
                              if (setCount != 4) {
                              throw 'Exactly 4 prices each point must be provided for candle chart (open close high low)';
                              }
                              var prices = [];
                              var price;
                              var sets = e.allSeriesPoints;
                              for (var p = 0 ; p < sets[0].length; p++) {
                              price = {
                              open : sets[0][p].yval,
                              close : sets[1][p].yval,
                              high : sets[2][p].yval,
                              low : sets[3][p].yval,
                              openY : sets[0][p].y,
                              closeY : sets[1][p].y,
                              highY : sets[2][p].y,
                              lowY : sets[3][p].y
                              };
                              prices.push(price);
                              }
                              var area = e.plotArea;
                              var ctx = e.drawingContext;
                              ctx.strokeStyle = '#202020';
                              ctx.lineWidth = 0.6;
                              for (p = 0 ; p < prices.length; p++) {
                              ctx.beginPath();
                              price = prices[p];
                              var topY = area.h * price.highY + area.y;
                              var bottomY = area.h * price.lowY + area.y;
                              var centerX = area.x + sets[0][p].x * area.w;
                              ctx.moveTo(centerX, topY);
                              ctx.lineTo(centerX, bottomY);
                              ctx.closePath();
                              ctx.stroke();
                              var bodyY;
                              if (price.open > price.close) {
                              ctx.fillStyle ='rgba(244,44,44,1.0)';
                              bodyY = area.h * price.openY + area.y;
                              }
                              else {
                              ctx.fillStyle ='rgba(44,244,44,1.0)';
                              bodyY = area.h * price.closeY  + area.y;
                              }
                              var bodyHeight = area.h * Math.abs(price.openY - price.closeY);
                              ctx.fillRect(centerX - BAR_WIDTH / 2, bodyY, BAR_WIDTH,  bodyHeight);
                              }}
                              ")


dygraphs.click.js = function(input_id){
  "function(e, x, points){
  var row = points[0].idx + 1;" %++%
    "Shiny.onInputChange('" %++% input_id %++% "', row)}"
}


### billboarder:

billboarder.format.suffix.js = function(suffix){
  if(is.null(suffix)){return(NULL)}
  JS(paste0("function(x) {return x + '", suffix, "';}"))}

