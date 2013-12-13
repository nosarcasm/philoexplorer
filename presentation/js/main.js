var margin = {top: 20, right: 15, bottom: 0, left: 15};

var width = 500 - margin.left - margin.right,
  height = $(".container-left").height() - 50 - margin.top - margin.bottom;

var outer = d3.select("#viz")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom);

outer.append("g")
  .attr("class", "grid")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var svg = outer.append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

svg.append("g")
  .attr("class", "group");
//svg.append("g")
  //.attr("class", "hidden");

outer.append("g")
  .attr("class", "axis")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var x = d3.time.scale.utc()
  .range([0, width]);

var axis = d3.svg.axis()
  .scale(x)
  .orient("top")
  .ticks(4)
  .tickSize(4);

var grid = d3.svg.axis()
  .scale(x)
  .orient("top")
  .ticks(8)
  .tickSize(-height)
  .tickFormat("");

var networks = ['CBS', 'ABC', 'NBC', 'TV38', 'FOX', 'CW', 'ESPN', 'CNN',
       'Comedy Central', 'Bravo!', 'TBS', 'Food Network', 'TNT',
       'Fox News', 'E!', 'FX', 'USA', 'ESPN2', 'MSNBC', 'MTV',
       'Cartoon Network', 'History Channel', 'AMC', 'National Geographic',
       'SyFy', 'VH1', 'CNBC']

var scale = d3.scale.category20()
    .domain(networks);
var color = function(d) { return scale(d.network); };

var tip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([-10, 0])
  .html(function(d) { return d['show'] + " (" + d['network'] + ")"});

svg.call(tip);

var data = [];
var bar_height = 4;

var date_start = new Date(2011, 12 - 1, 4, 21 - 5, 0, 0, 0);
var date_end = new Date(2011, 12 - 1, 4, 22 - 5, 0, 0, 0);
d3.json("data/nfl.json", load_data);

function load_data(raw_data) {
  data = raw_data;

  parse_data_dates();

  svg.selectAll(".user")
    .remove();

  svg.selectAll("g.group")
    .selectAll(".user")
      .data(data)
    .enter().append("g")
      .attr("class", "user")
      .selectAll("rect")
          .data(function(d) { return d.data; })
        .enter().append("rect");

  redraw();
}

function parse_data_dates() {
  // cast ints to Date objects
  for (var i = 0; i < data.length; i++) {
    for (var j = 0; j < data[i]['data'].length; j++) {
      data[i]['data'][j]['date'] = new Date(data[i]['data'][j]['date'] / 1000000);
    }
  }
}

function redraw() {
  bar_height = (height - (svg.selectAll("g.group")[0].length > 1 ? 80 : 0)) / svg.selectAll("g.group > .user")[0].length;

  x.domain([date_start, date_end]);

  outer.select("g.axis")
    .call(axis);

  outer.select("g.grid")
    .call(grid);

  var groups = svg.selectAll("g.group");

  groups.selectAll(".user")
    .transition()
    .attr("transform", function(d,i) { return "translate(0," + (bar_height * i) + ")"; })
    .selectAll("rect")
      .attr("height", bar_height)
      .attr("width", function(d) { return x(d3.time.second.offset(date_start, d.timed)); })
      .attr("x", function(d) { return x(d.date); })
      .attr("fill", color);

  d3.selectAll(".user").on("mouseenter", function(d) {
    var position = d3.transform(d3.select(this).attr("transform"))["translate"][1] / bar_height;

    d3.select(this)
      .selectAll("rect")
      .transition()
      .attr("height", 15);

    svg.selectAll("g.group")
      .selectAll(".user")
      .filter(function(_, i) { return i > position; })
      .transition()
      .attr("transform", function() {
        var pos = d3.transform(d3.select(this).attr("transform"))["translate"];
        return "translate(" + pos[0] + "," + (pos[1] + (15 - bar_height)) + ")";
      });

  }).on("mouseleave", function() {
    d3.select(this)
      .selectAll("rect")
      .transition()
      .attr("height", bar_height);

    svg.selectAll("g.group")
      .selectAll(".user")
      .transition()
      .attr("transform", function(d,i) {
        var pos = d3.transform(d3.select(this).attr("transform"))["translate"];
        return "translate(" + pos[0] + ", " + (bar_height * i) + ")";
      });

    d3.selectAll(".user > rect")
      .attr("opacity", null);
  });

  d3.selectAll(".user > rect").on("mouseover.highlight", function(d) {
    // make sure the selected element is at the top
    d3.select(this.parentNode)
      .selectAll("rect")
      .sort(function(a, b) { return a == d ? 1 : 0; });

    d3.selectAll(".user > rect")
      .filter(function(e) { return e.network !== d.network; })
      .attr("opacity", 0.25);

  }).on("mouseout.highlight", function() {
    d3.selectAll(".user > rect")
      .attr("opacity", null);
  }).on("mouseover.tip", tip.show)
    .on("mouseout.tip", tip.hide);
}

function sort(f) {
  svg.selectAll("g.group")
    .selectAll(".user")
    .sort(f)
    .transition()
    .attr("transform", function(d, i) { return "translate(0," + (bar_height * i) + ")"; })
}

d3.selectAll(".action-viewership").on("click", function() {
  d3.event.preventDefault();

  sort(function(a, b) { return d3.descending(timed_sum(a), timed_sum(b)); });
});

function timed_sum(d) {
  return d['data'].reduce(function(a, b) { return a + b.timed; }, 0);
}

d3.selectAll(".action-offset").on("click", function() {
  d3.event.preventDefault();
  sort(function(a, b) { return d3.ascending(min_offset(a), min_offset(b)); });
});

function min_offset(d) {
  return Math.min.apply(Math, d['data'].map(function(e) { return e.date; }));
}

d3.selectAll(".action-zappers").on("click", function() {
  d3.event.preventDefault();
  sort(function(a, b) { return d3.descending(a.data.length, b.data.length); });
});

d3.selectAll(".action-shows").on("click", function() {
  d3.event.preventDefault();

  var counts = [];
  networks.forEach(function(network) {
    counts.push([network, 0]);
  });

  d3.selectAll(".user > rect").data().forEach(function(d) {
    count = counts.filter(function(network) { return network[0] === d.network; })[0];
    count[1] += d.timed;
  });

  counts.sort(function(a, b) { return d3.descending(a[1], b[1]); });

  var rank = counts.map(function(d) { return d[0]; });

  svg.selectAll("g.group")
    .selectAll(".user")
    .sort(function(a, b) {
      return d3.ascending(rank.indexOf(biggest_network(a)), rank.indexOf(biggest_network(b)));
    })
    .transition()
    .attr("transform", function(d, i) { return "translate(0," + (bar_height * i) + ")"; })
});

function biggest_network(d) {
  return d['data'].sort(function(a, b) { return d3.descending(a.timed, b.timed); })[0]["network"];
}

d3.selectAll(".action-gender").on("click", function() {
  d3.event.preventDefault();

  var female = svg.append("g")
    .attr("class", "group")
    .node();

  //var hidden = svg.select("g.hidden").node();

  svg.selectAll(".user")
    .each(function(d) {
      if (!d['is_male'])
        female.appendChild(this);
    });

  redraw();

  d3.select(female)
    .attr("transform", "translate(0, " + (svg.selectAll("g.group:first-child > .user")[0].length * bar_height + 80) + ")")
});

d3.selectAll(".action-ungroup").on("click", function() {
  d3.event.preventDefault();

  var group = svg.select("g.group:first-child")
    .node();

  svg.selectAll(".user")
    .each(function(d) { group.appendChild(this); });

  svg.select("g.group:not(:first-child)")
    .remove();

  redraw();
});

d3.selectAll(".action-align").on("click", function() {
  d3.event.preventDefault();

  svg.selectAll(".user")
    .transition()
    .attr("transform", function(d) {
      var y = d3.transform(d3.select(this).attr("transform"))["translate"][1]
      return "translate(" + (-x(d['data'][0]['date'])) + "," + y + ")";
    });
    //.attr("transform", function(d, i) { return "translate(0," + (bar_height * i) + ")"; })
});

d3.selectAll(".action-dealign").on("click", function() {
  d3.event.preventDefault();

  svg.selectAll(".user")
    .transition()
    .attr("transform", function(d) {
      var y = d3.transform(d3.select(this).attr("transform"))["translate"][1]
      return "translate(0," + y + ")";
    });
});

d3.selectAll(".action-loadgrammy").on("click", function() {
  d3.event.preventDefault();

  color = function(d) { return scale(d.network); };

  date_start = new Date(2012, 2 - 1, 12, 20 - 5, 0, 0, 0);
  date_end = new Date(2012, 2 - 1, 12, 23 - 5, 30, 0, 0);
  d3.json("data/grammy.json", load_data);
});

d3.selectAll(".action-stickycolor").on("click", function() {
  d3.event.preventDefault();

  var extent = d3.extent(data, function(d) {
    return d3.extent(d.data, function(e) { return e['global_stickiness']; });
  });

  var sticky_scale = d3.scale.linear()
    .domain([extent[0][0], extent[1][0]])
    .range([d3.lab("#f7fcb9"), d3.lab("#31a354")]);
    //.range([d3.lab("#e0f3db"), d3.lab("#43a2ca")]);
    //.range([d3.lab("#e5f5f9"), d3.lab("#2ca25f")]);

  color = function(d) { return sticky_scale(d['global_stickiness']); };

  redraw();

  sort(function(a, b) { return d3.descending(stickiness_avg(a), stickiness_avg(b)); });
});

function stickiness_avg(d) {
  return d3.mean(d['data'], function(d) { return d['global_stickiness']; });
}

// for presentation
var event_index = 0
var events = [".action-shows", ".action-align", ".action-dealign", ".action-offset"]
d3.select("body").on("keydown", function() {
  if (d3.event.keyCode == 13) {
    console.log(svg.select(events[event_index]));
    d3.select(events[event_index]).on("click")();

    event_index++
  };
})

//
// Sigma.js graph visualization
//
$(function(){
  var startDateTextBox = $('#start');
  var endDateTextBox = $('#end');

  startDateTextBox.datetimepicker({
    stepHour: 1,
    stepMinute: 5,
    addSliderAccess: true,
    sliderAccessArgs: { touchonly: false },
    timeFormat: 'HH:mm',
    minDate: new Date(2011, 11, 1, 21, 0),
    maxDate: new Date(2012, 2, 7, 0, 0),
    onClose: function(dateText, inst) {
      if (endDateTextBox.val() != '') {
        var testStartDate = startDateTextBox.datetimepicker('getDate');
        var testEndDate = endDateTextBox.datetimepicker('getDate');
        if (testStartDate > testEndDate)
          endDateTextBox.datetimepicker('setDate', testStartDate);
      }
      else {
        endDateTextBox.val(dateText);
      }
    },
    onSelect: function (selectedDateTime){
      endDateTextBox.datetimepicker('option', 'minDate', startDateTextBox.datetimepicker('getDate') );
    }
  });
  endDateTextBox.datetimepicker({ 
    timeFormat: 'HH:mm',
    minDate: new Date(2011, 11, 1, 21, 0),
    maxDate: new Date(2012, 2, 7, 0, 0),
    stepHour: 1,
    stepMinute: 5,
    addSliderAccess: true,
    sliderAccessArgs: { touchonly: false },
    onClose: function(dateText, inst) {
      if (startDateTextBox.val() != '') {
        var testStartDate = startDateTextBox.datetimepicker('getDate');
        var testEndDate = endDateTextBox.datetimepicker('getDate');
        if (testStartDate > testEndDate)
          startDateTextBox.datetimepicker('setDate', testEndDate);
      }
      else {
        startDateTextBox.val(dateText);
      }
    },
    onSelect: function (selectedDateTime){
      startDateTextBox.datetimepicker('option', 'maxDate', endDateTextBox.datetimepicker('getDate') );
    }
  });

  $("#target").on("submit", (function(event){
    event.preventDefault();
    window.nodesactive = [];
    window.allnodes = [];
    $.getJSON('data/nodes.json', {}, function(data) {
      window.allnodes = data.nodes;
      for (n in window.allnodes) {
          try {
            window.sigInst.iterNodes(function(n)
                                     {n.hidden=1;},[allnodes[n]]);
          } catch(err) {
            continue;
          }
        }
    });

    $.getJSON("http://indynamics.org/cs109/", $("#target").serialize(), function(data) {
      window.nodesactive = data.nodes;
      for (n in window.nodesactive)
        {
          try{
            var nsize = window.nodesactive[n][1]
            window.sigInst.iterNodes(
              function(n){
              n.hidden=0;
              n.size=nsize;
            }, [window.nodesactive[n][0]]);
          }
          catch(err){
            continue;
          }
        }
        window.sigInst.draw();
    });
  }));
});

function init() {
  // Instanciate sigma.js and customize rendering :
  window.sigInst = sigma.init(document.getElementById('sigma-tvgraph')).drawingProperties({
    defaultLabelColor: '#000',
    defaultLabelSize: 14,
    defaultLabelBGColor: '#000',
    defaultLabelHoverColor: '#000',
    //fontStyle: 'bold',
    labelThreshold: 3,
    defaultEdgeType: 'curve'
  }).graphProperties({
    minNodeSize: 0.5,
    maxNodeSize: 5,
    minEdgeSize: 0
  }).mouseProperties({
    maxRatio: 8
  });

  // Parse a GEXF encoded file to fill the graph
  // (requires "sigma.parseGexf.js" to be included)
  sigInst.parseGexf('data/graph.gexf');

  // Bind events :
  var greyColor = '#666';
  sigInst.bind('overnodes',function(event){
    window.nodes = event.content;
    var neighbors = {};
    sigInst.iterEdges(function(e){
      if(nodes.indexOf(e.source)<0 && nodes.indexOf(e.target)<0){
        if(!e.attr['grey']){
          e.attr['true_color'] = e.color;
          e.color = greyColor;
          e.attr['grey'] = 1;
        }
      }else{
        e.color = e.attr['grey'] ? e.attr['true_color'] : e.color;
        e.attr['grey'] = 0;

        neighbors[e.source] = 1;
        neighbors[e.target] = 1;
      }
    }).iterNodes(function(n){
      if(!neighbors[n.id]){
        if(!n.attr['grey']){
          n.attr['true_color'] = n.color;
          n.color = greyColor;
          n.attr['grey'] = 1;
        }
      }else{
        n.color = n.attr['grey'] ? n.attr['true_color'] : n.color;
        n.attr['grey'] = 0;
      }
    }).draw(2,2,2);
  }).bind('outnodes',function(){
    sigInst.iterEdges(function(e){
      e.color = e.attr['grey'] ? e.attr['true_color'] : e.color;
      e.attr['grey'] = 0;
    }).iterNodes(function(n){
      n.color = n.attr['grey'] ? n.attr['true_color'] : n.color;
      n.attr['grey'] = 0;
    }).draw(2,2,2);
  });

  // Draw the graph :
  sigInst.draw();
}

if (document.addEventListener) {
  document.addEventListener("DOMContentLoaded", init, false);
} else {
  window.onload = init;
}
