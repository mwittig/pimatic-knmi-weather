# pimatic-knmi-weather

[![Npm Version](https://badge.fury.io/js/pimatic-knmi-weather.svg)](http://badge.fury.io/js/pimatic-knmi-weather)
[![Build Status](https://travis-ci.org/mwittig/pimatic-knmi-weather.svg?branch=master)](https://travis-ci.org/mwittig/pimatic-knmi-weather)
[![Dependency Status](https://david-dm.org/mwittig/pimatic-knmi-weather.svg)](https://david-dm.org/mwittig/pimatic-knmi-weather)

Pimatic plugin for KNMI weather data.

## Introduction

This plugin provides basic weather data from the Royal Netherlands Meteorological Institute for 35 stations 
throughout the country. The following data is provided whereas some stations may provide a limited data set:

* air temperature at ground-level
* wind chill temperature
* clouds overcast
* relative humidity
* barometric pressure
* wind speed and direction
* visibility 

## Contributions

Contributions to the project are  welcome. You can simply fork the project and create a pull request with 
your contribution to start with. If you like this plugin, please consider &#x2605; starring 
[the project on github](https://github.com/mwittig/pimatic-knmi-weather).

## Plugin Configuration

    {
          "plugin": "knmi-weather",
          "debug": false,
    }

The plugin has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| debug             | false    | Boolean | Debug mode. Writes debug messages to the pimatic log, if set to true |
| interval          | 10       | Number  | The time interval in minutes (minimum 10) at which the weather data will be queried |


## Device Configuration

The KNMI Weather device is provided to obtain weather data for a single location. 

    {
          "id": "knmi-1",
          "name": "Heino",
          "class": "KnmiWeather",
          "attributes": [
            "temperature",
            "clouds",
            "windDirection",
            "windSpeed",
            "pressure",
            "clouds",
            "windChill",
            "visibility"
          ],
          "station": "Heino"
    }

The location is defined by setting the station name which may be one of the following: Arcen, Berkhout, 
Cabauw, De Bilt, Deelen, Den Helder, Eelde, Eindhoven, Ell, Gilze Rijen, Heino, Herwijnen, Hoek van Holland, 
Hoogeveen, Houtribdijk, Hupsel, IJmuiden, Lauwersoog, Leeuwarden, Lelystad, Maastricht-Aachen Airport, 
Marknesse, Nieuw Beerta, Rotterdam, Schiphol, Stavoren, Terschelling, Twente, Vlieland, Vlissingen, 
Volkel, Voorschoten, Westdorpe, Wijk aan Zee, Woensdrecht.

The device has the following configuration properties:

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| station           | -        | String  | The name of the weather station             |
| attributes        | "temperature" | Enum | The attribute to be exhibited by the device |

Since pimatic version 0.9, devices can be easily created and edited using the device editor as shown 
in the following example.

![Screenshot](https://raw.githubusercontent.com/mwittig/pimatic-knmi-weather/master/assets/screenshots/edit-knmi-weather.png)


