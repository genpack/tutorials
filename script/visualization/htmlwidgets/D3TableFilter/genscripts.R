### genjscripts.R ------------------------

js.barcol = JS('function makeGraph(selection){
               
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
               var textformat = d3.format(".1f");
               
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
               }')

js.bubblecol = JS('function makeGraph(selection){
                  
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
                  
                  }')


js.bold = JS('function makeGraph(selection){selection.style("font-weight", "bold")}')

js.bold.1f = JS('function makeGraph(selection){
                // text formatting function
                var textformat = d3.format(".1f");
                selection.style("font-weight", "bold")
                .text(function(d) { return textformat(d.value); });}')

js.bold.right.1f = JS('function makeGraph(selection){
                      // text formatting function
                      var textformat = d3.format(".1f");
                      // make cell text right aligned
                      selection.classed("text-right", true)
                      .style("font-weight", "bold")
                      .text(function(d) { return textformat(d.value); });}')


