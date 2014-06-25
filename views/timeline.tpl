%include header
<style>


.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.x.axis path {
  display: none;
}

.line {
  fill: none;
  stroke: steelblue;
  stroke-width: 1.5px;
}

</style>

<script type="text/javascript">

function add()
{
  $('.add_search').append('<input type="text" name="words[]" /> <br/><br/>')
}

</script>



  
  <h2>Word Frequency over Time</h2>
  
  <a href="#" onclick="add()" > Add Search Term </a>
  <form action="/timeline" method="post">

    <input type="text" name="words[]" /> <br/><br/>
    <span class="add_search"></span> <br/>

    Select Item List : 
    <select name="item_list_name">
      %for item in personal_item_list:
       <option value="{{ item['name'] }}">  {{ item['name'] }} </option>
      %end
    </select>

    <br/>

    <input type="submit" value="Submit" />
  </form>

%if len(rows) > 0:
  <graph></graph>
%end
<script src="http://d3js.org/d3.v3.js"></script>
<script>

var margin = {top: 20, right: 80, bottom: 30, left: 50},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var parseDate = d3.time.format("%Y").parse;

var x = d3.time.scale()
    .range([0, width]);

var y = d3.scale.linear()
    .range([height, 0]);

var color = d3.scale.category10();

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var line = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.date); })
    .y(function(d) { return y(d.frequency); });

var svg = d3.select("graph").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.tsv("/static/timeline.tsv", function(error, data) {
  color.domain(d3.keys(data[0]).filter(function(key) { return key !== "date"; }));

  data.forEach(function(d) {
    d.date = parseDate(d.date);
  });

  var cities = color.domain().map(function(name) {
    return {
      name: name,
      values: data.map(function(d) {
        return {date: d.date, frequency: +d[name]};
      })
    };
  });

  x.domain(d3.extent(data, function(d) { return d.date; }));

  y.domain([
    d3.min(cities, function(c) { return d3.min(c.values, function(v) { return v.frequency; }); }),
    d3.max(cities, function(c) { return d3.max(c.values, function(v) { return v.frequency; }); })
  ]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Frequency");

  var city = svg.selectAll(".city")
      .data(cities)
    .enter().append("g")
      .attr("class", "city");

  city.append("path")
      .attr("class", "line")
      .attr("d", function(d) { return line(d.values); })
      .style("stroke", function(d) { return color(d.name); });

  city.append("text")
      .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
      .attr("transform", function(d) { return "translate(" + x(d.value.date) + "," + y(d.value.frequency) + ")"; })
      .attr("x", 3)
      .attr("dy", ".35em")
      .text(function(d) { return d.name; });
});

</script>

<br/><br/>
<div class="col-md-6">
    <table class="table table-striped table-bordered">
      %for row in rows:
        <tr>
            %for col in row.split("\t"):
              <td> {{ col }} </td>
            %end
        </tr>

      %end
    </table>
  </div>


%include footer
