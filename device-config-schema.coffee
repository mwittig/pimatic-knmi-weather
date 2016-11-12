module.exports = {
  title: "pimatic-knmi-weather device config schema"
  KnmiWeather: {
    title: "KNMI Weather"
    description: "KNMI Weather Data"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      station:
        description: "Name for the weather station"
        enum: [
          "Arcen", "Berkhout", "Cabauw", "De Bilt", "Deelen",
          "Den Helder", "Eelde", "Eindhoven", "Ell", "Gilze Rijen",
          "Heino", "Herwijnen", "Hoek van Holland", "Hoogeveen", "Houtribdijk",
          "Hupsel", "IJmuiden", "Lauwersoog", "Leeuwarden", "Lelystad",
          "Maastricht-Aachen Airport", "Marknesse", "Nieuw Beerta", "Rotterdam", "Schiphol",
          "Stavoren", "Terschelling", "Twente", "Vlieland", "Vlissingen",
          "Volkel", "Voorschoten", "Westdorpe", "Wijk aan Zee", "Woensdrecht"
        ]
      attributes:
        type: "array"
        default: ["temperature"]
        format: "table"
        items:
          enum: [
            "clouds", "temperature", "windChill", "humidity",
            "windDirection", "windSpeed", "visibility", "pressure"
          ]
  }
}