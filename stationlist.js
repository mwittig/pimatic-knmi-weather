var list = require("./data.json");
// helper to create station list.
// station data needs to be downloaded first and saved as
// data.json

list.stations.sort(function(a, b) {
  if (a.station > b.station)
    return 1;
  else
    return -1;
});

var text = "";
list.stations.forEach(function(a, i) {

  if (i > 0) {
    if (i % 5 === 0)
      text += ",\n";
    else
      text += ", ";
  }
  text += a.station;
})

console.log(text)