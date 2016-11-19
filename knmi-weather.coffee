# KNMI Weather plugin
module.exports = (env) ->

  events = require 'events'
  Promise = env.require 'bluebird'
  types = env.require('decl-api').types
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)
  FtpClient = require 'jsftp'

  # ###KnmiWeatherPlugin class
  class KnmiWeatherPlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      @debug = @config.debug || false
      @interval = 60000 * Math.max @config.__proto__.interval, @config.interval
      @base = commons.base @, 'Plugin'
      # register devices
      deviceConfigDef = require("./device-config-schema")
      @base.debug "Registering device class KnmiWeather"
      @framework.deviceManager.registerDeviceClass("KnmiWeather", {
        configDef: deviceConfigDef.KnmiWeather,
        createCallback: (config, lastState) =>
          return new KnmiWeather(config, @, lastState)
      })

    getData: () ->
      new Promise (resolve, reject) =>
        ftp = new FtpClient
          host: 'ftp.knmi.nl',
          debugMode: false

        finalize = (error, result) =>
          clearTimeout @timeoutId if @timeoutId?
          @timeoutId = null
          ftp.destroy()
          unless error?
            resolve result
          else
            @base.rejectWithErrorString reject, error

        @timeoutId = setTimeout =>
          finalize new Error "No response from server (timeout)"
        , 60000

        ftp.once 'timeout', () =>
          finalize new Error "No response from server (connection timeout)"

        ftp.once 'connect', () =>
          result = ''
          ftp.get('/pub_weerberichten/tabel_10Min_data.json', (error, socket) =>
            unless error?
              socket.on 'data', (data) => result += data.toString()
              socket.on 'error', (socketError) =>
                finalize socketError
              socket.once 'close', (hadError) =>
                unless hadError
                  try
                    json = JSON.parse result
                    finalize null, json
                  catch parseError
                    finalize parseError
              socket.resume()
            else
              finalize error
          )

    requestUpdate: () ->
      @base.debug "#{@listenerCount 'weatherUpdate'} event listeners"
      if @__timeoutObject? and @lastWeatherData?
        @emit 'weatherUpdate', @lastWeatherData
      else
        @base.cancelUpdate()
        @base.debug "Requesting weather data update"
        @getData().then (@lastWeatherData) =>
          @emit 'weatherUpdate', @lastWeatherData
        .catch (error) =>
          @base.error "Error:", error
        .finally () =>
          unless @listenerCount 'weatherUpdate' is 0
            @base.scheduleUpdate(@requestUpdate, @interval)
          else
            @base debug "No more listeners for status updates. Stopping update cycle"

  class AttributeContainer extends events.EventEmitter
    constructor: () ->
      @values = {}

  class KnmiWeather extends env.devices.Device
    attributeTemplates =
      clouds:
        description: "Cloudyness"
        type: types.string
        acronym: 'CLOUDS'
      temperature:
        description: "Air temperature"
        type: types.number
        unit: '°C'
        acronym: 'T'
      windChill:
        description: "Wind chill temperature"
        type: types.number
        unit: '°C'
        acronym: 'WCT'
      humidity:
        description: "The actual degree of Humidity"
        type: types.number
        unit: '%'
        acronym: 'RH'
      windDirection:
        description: "Direction from which the wind is blowing."
        type: types.string
        acronym: 'WD'
      windSpeed:
        description: "Wind speed"
        type: types.number
        unit: 'm/s'
        acronym: 'WS'
      visibility:
        description: "Visibility"
        type: types.number
        unit: 'm'
        acronym: 'VIS'
      pressure:
        description: "Air pressure"
        type: types.number
        unit: 'mbar'
        acronym: 'P'

    constructor: (@config, @plugin, lastState) ->
      @id = @config.id
      @name = @config.name
      @debug = @plugin.debug || false
      @base = commons.base @, @config.class
      @attributeValues = new AttributeContainer()
      @attributes = _.cloneDeep(@attributes)
      @attributeHash = {}
      for attributeName in @config.attributes
        do (attributeName) =>
          if attributeTemplates.hasOwnProperty attributeName
            @attributeHash[attributeName] = true
            properties = attributeTemplates[attributeName]
            @attributes[attributeName] =
              description: properties.description
              type: properties.type
              unit: properties.unit if properties.unit?
              acronym: properties.acronym if properties.acronym?

            defaultValue = null # if properties.type is types.number then 0.0 else '-'
            @attributeValues.values[attributeName] = lastState?[attributeName]?.value or defaultValue

            @attributeValues.on attributeName, ((value) =>
              @base.debug "Received update for attribute #{attributeName}: #{value}"
              if value?
                @attributeValues.values[attributeName] = value
                @emit attributeName, value
            )

            @_createGetter(attributeName, =>
              return Promise.resolve @attributeValues.values[attributeName]
            )
          else
            @base.error "Configuration Error. No such attribute: #{attributeName} - skipping."
      super()
      if @config.station?
        @weatherUpdateHandler = @createWeatherUpdateHandler()
        @plugin.on 'weatherUpdate', @weatherUpdateHandler
        @plugin.requestUpdate()

    destroy: () ->
      @plugin.removeListener 'weatherUpdate', @weatherUpdateHandler
      super

    createWeatherUpdateHandler: () ->
      return (weatherData) =>
        # @base.debug JSON.stringify weatherData.stations
        stationData = (i for i in weatherData.stations when i.station is @config.station)[0]
        if stationData? and not _.isEmpty @config.attributes
          if @attributeHash.clouds? and _.isEmpty stationData.overcast?
            @attributeValues.emit "clouds", if _.isEmpty stationData.overcast then '-' else stationData.overcast
          if @attributeHash.temperature? and not _.isEmpty stationData.temperature
            @attributeValues.emit "temperature", parseFloat(stationData.temperature)
          if @attributeHash.windChill? and not _.isEmpty stationData.windchill
            @attributeValues.emit "windChill", parseFloat(stationData.windchill)
          if @attributeHash.humidity? and not _.isEmpty stationData.humidity
            @attributeValues.emit "humidity", parseInt(stationData.humidity)
          if @attributeHash.windDirection? and stationData.wind_direction?
            @attributeValues.emit "windDirection", stationData.wind_direction
          if @attributeHash.windSpeed? and not _.isEmpty stationData.wind_strength
            @attributeValues.emit "windSpeed", parseFloat(stationData.wind_strength)
          if @attributeHash.visibility? and not _.isEmpty stationData.visibility
            @attributeValues.emit "visibility", parseInt(stationData.visibility)
          if @attributeHash.pressure? and not _.isEmpty stationData.air_pressure
            @attributeValues.emit "pressure", parseFloat(stationData.air_pressure)
        else
          @base.error "No weather data found for station #{@config.station}" unless stationData?
          @plugin.removeListener 'weatherUpdate', @weatherUpdateHandler

  # ###Finally
  # Create a instance of my plugin
  # and return it to the framework.
  return new KnmiWeatherPlugin
