# #pimatic-knmi-weather plugin config options
module.exports = {
  title: "pimatic-knmi-weather plugin config options"
  type: "object"
  properties:
    debug:
      description: "Debug mode. Writes debug messages to the pimatic log, if set to true."
      type: "boolean"
      default: false
    interval:
      description: "The time interval in minutes (minimum 10) at which the weather data will be queried"
      type: "number"
      default: 10
      minimum: 10
}
