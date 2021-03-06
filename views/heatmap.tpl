%include header
<script type="text/javascript">

  function add()
  {
    $('.add_search').append('<input type="text" name="words[]" /> <br/><br/>')
  }

</script>


  <style>
      rect.bordered {
        stroke: #E6E6E6;
        stroke-width:2px;   
      }

      text.mono {
        font-size: 9pt;
        font-family: Consolas, courier;
        fill: #aaa;
      }

      text.axis-workweek {
        fill: #000;
      }

      text.axis-worktime {
        fill: #000;
      }
    </style>
    <script src="http://d3js.org/d3.v3.js"></script>

    
    <h3 class="center"> Collocation Heatmap </h3>
    Currently  it just considers a bigram collocation (collocation of two words) 
    <br/>

    <a href="/heatmap">Reload Default Heatmap</a>
    <br/>
    <div class="row">
      <div class="col-md-2">
        <h4> Custom Heatmap </h4>
        <a href="#" onclick="add()" > Add Term for Collocation Search </a>
        <form action="/heatmap" method="post">

          <input type="text" name="words[]" /> <br/><br/>
          <span class="add_search"></span> <br/>

          Select Item List : 
          <select name="item_list_name">
            %for item in personal_item_list:
             <option value="{{ item['name'] }}">  {{ item['name'] }} </option>
            %end
          </select>

          <br/><br/>

          <input type="submit" value="Submit" />
        </form>

      </div>

      <div class="col-md-10">
        <div id="chart"></div>
      </div>
    </div>
    

    

    <script type="text/javascript">


      var formatted_words = "{{ row_words }}".replace(/&quot;/g, "\"");
      formatted_words = formatted_words.replace(/&#039;/g, "\'");
      var row_words = JSON.parse(formatted_words);

      var formatted_words = "{{ col_words }}".replace(/&quot;/g, "\"");
      formatted_words = formatted_words.replace(/&#039;/g, "\'");
      var col_words = JSON.parse(formatted_words);

      

      var margin = { top: 50, right: 0, bottom: 100, left: 100 },
          width = 1600 - margin.left - margin.right,
          height = 1024 - margin.top - margin.bottom,
          gridSize = Math.floor(width / 50),
          legendElementWidth = gridSize*2,
          buckets = 9,
          colors = ["#ffffd9","#edf8b1","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#253494","#081d58"], // alternatively colorbrewer.YlGnBu[9]
          // days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"],
          days = row_words,
          // times = ["1a", "2a", "3a", "4a", "5a", "6a", "7a", "8a", "9a", "10a", "11a", "12a", "1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p", "10p", "11p", "12p"];
          times  = col_words;

      d3.tsv("/static/data.tsv",
        function(d) {
          return {
            day: +d.day,
            hour: +d.hour,
            value: +d.value
          };
        },
        function(error, data) {
          var colorScale = d3.scale.quantile()
              .domain([0, buckets - 1, d3.max(data, function (d) { return d.value; })])
              .range(colors);

          var svg = d3.select("#chart").append("svg")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
              .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          var dayLabels = svg.selectAll(".dayLabel")
              .data(days)
              .enter().append("text")
                .text(function (d) { return d; })
                .attr("x", 0)
                .attr("y", function (d, i) { return i * gridSize; })
                .style("text-anchor", "end")
                .attr("transform", "translate(-6," + gridSize / 1.5 + ")")
                .attr("class", function (d, i) { return ((i >= 0 && i <= 4) ? "dayLabel mono axis axis-workweek" : "dayLabel mono axis"); });

          var timeLabels = svg.selectAll(".timeLabel")
              .data(times)
              .enter().append("text")
                .text(function(d) { return d; })
                .attr("x", function(d, i) { return i * gridSize; })
                .attr("y", 0)
                .style("text-anchor", "middle")
                .attr("transform", "translate(" + gridSize / 2 + ", -6)")
                .attr("class", function(d, i) { return ((i >= 7 && i <= 16) ? "timeLabel mono axis axis-worktime" : "timeLabel mono axis"); });

          var heatMap = svg.selectAll(".hour")
              .data(data)
              .enter().append("rect")
              .attr("x", function(d) { return (d.hour - 1) * gridSize; })
              .attr("y", function(d) { return (d.day - 1) * gridSize; })
              .attr("rx", 4)
              .attr("ry", 4)
              .attr("class", "hour bordered")
              .attr("width", gridSize)
              .attr("height", gridSize)
              .style("fill", colors[0]);

          heatMap.transition().duration(1000)
              .style("fill", function(d) { return colorScale(d.value); });

          heatMap.append("title").text(function(d) { return d.value; });
              
          var legend = svg.selectAll(".legend")
              .data([0].concat(colorScale.quantiles()), function(d) { return d; })
              .enter().append("g")
              .attr("class", "legend");

          legend.append("rect")
            .attr("x", function(d, i) { return legendElementWidth * i; })
            .attr("y", height)
            .attr("width", legendElementWidth)
            .attr("height", gridSize / 2)
            .style("fill", function(d, i) { return colors[i]; });

          legend.append("text")
            .attr("class", "mono")
            .text(function(d) { return "≥ " + Math.round(d); })
            .attr("x", function(d, i) { return legendElementWidth * i; })
            .attr("y", height + gridSize);
      });
    </script>
  

%include footer