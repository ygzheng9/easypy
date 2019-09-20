function goclick() {
  alert('正在爬取,整个过程大约10s,请稍等(￣▽￣)~*');
}

var dom = document.getElementById('container');
var myChart = echarts.init(dom);
var app = {};
option = null;

$.getJSON('./static/flights.json', function(data) {
  var airports = data.airports.map(function(item) {
    return {
      coord: [item[3], item[4]]
    };
  });

  function getAirportCoord(idx) {
    return [data.airports[idx][3], data.airports[idx][4]];
  }

  // Route: [airlineIndex, sourceAirportIndex, destinationAirportIndex]
  var routesGroupByAirline = {};
  data.routes.forEach(function(route) {
    var airline = data.airlines[route[0]];
    var airlineName = airline[0];
    if (!routesGroupByAirline[airlineName]) {
      routesGroupByAirline[airlineName] = [];
    }
    routesGroupByAirline[airlineName].push(route);
  });

  var pointsData = [];
  data.routes.forEach(function(airline) {
    pointsData.push(getAirportCoord(airline[1]));
    pointsData.push(getAirportCoord(airline[2]));
  });

  var series = data.airlines
    .map(function(airline) {
      var airlineName = ['China Eastern Airlines'];
      var routes = routesGroupByAirline[airlineName];
      //console.log(airlineName);
      if (!routes) {
        return null;
      }
      return {
        type: 'lines3D',
        name: airlineName,

        effect: {
          show: true,
          trailWidth: 2,
          trailLength: 0.15,
          trailOpacity: 0.3,
          trailColor: 'white'
        },

        lineStyle: {
          width: 1,
          //color: 'rgb(50, 50, 150)',
          color: 'black',
          opacity: 0.05
        },
        blendMode: 'lighter',

        data: routes.map(function(item) {
          return [airports[item[1]].coord, airports[item[2]].coord];
        })
      };
    })
    .filter(function(series) {
      return !!series;
    });
  series.push({
    type: 'scatter3D',
    coordinateSystem: 'globe',
    blendMode: 'lighter',
    symbolSize: 2,
    itemStyle: {
      color: 'red',
      opacity: 0.5
    },
    data: pointsData
  });
  myChart.setOption({
    legend: {
      selectedMode: 'single',
      left: 'left',
      data: Object.keys(routesGroupByAirline),
      orient: 'vertical',
      textStyle: {
        color: '#fff'
      }
    },
    globe: {
      environment: './static/starfield.jpg',
      baseTexture: './static/world.topo.bathy.200401.jpg',
      heightTexture: './static/bathymetry_bw_composite_4k.jpg',

      displacementScale: 0.1,
      shading: 'realistic',
      displacementQuality: 'high',

      //baseColor: '#000',

      shading: 'realistic',
      realisticMaterial: {
        roughness: 0.2,
        metalness: 0
      },

      postEffect: {
        enable: true,
        depthOfField: {
          enable: false,
          focalDistance: 200
        }
      },
      temporalSuperSampling: {
        enable: true
      },
      light: {
        ambient: {
          intensity: 0
        },
        main: {
          intensity: 0.1,
          shadow: true
        },
        ambientCubemap: {
          texture: './static/lake.hdr',
          exposure: 1,
          diffuseIntensity: 0.5,
          specularIntensity: 2
        }
      },
      viewControl: {
        autoRotate: true
      },
      silent: true
    },
    series: series
  });
  window.addEventListener('keydown', function() {
    series.forEach(function(series, idx) {
      myChart.dispatchAction({
        type: 'lines3DToggleEffect',
        seriesIndex: idx
      });
    });
  });
});
if (option && typeof option === 'object') {
  myChart.setOption(option, true);
}
