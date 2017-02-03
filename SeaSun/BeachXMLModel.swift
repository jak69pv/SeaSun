//
//  beachXMLData.swift
//  SeaSun
//
//  Created by Alberto Ramis on 21/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import Foundation

struct TwoValueData {
    var f : Int?
    var decription : String?
}


class BeachXMLModel: NSObject, XMLParserDelegate {
    var origin: Origin?
    var dayData: DayXMLData?
    var elaborateDate: String?
    var beachName: String?
    var city: String?
    var prediction: [DayXMLData]?
    var beachCode: String
    
    var currentContent: String?
    
    override init() {
        self.beachCode = "4625001"
    }
    
    init(with beachCode: String) {
        self.beachCode = beachCode
    }
    
    func parser() {
        guard let beachURL = URL(string: AemetURL.url + beachCode + AemetURL.type) else {
            print("URL not defined properly")
            return
        }
        guard let parser = XMLParser(contentsOf: beachURL) else {
            print("Cannot Read Data")
            return
        }
        parser.delegate = self
        if !parser.parse(){
            print("Data Errors Exist:")
            let error = parser.parserError!
            print("Error Description:\(error.localizedDescription)")
            print("Line number: \(parser.lineNumber)")
        
        }
        
        // Para rellenar los datos
        currentContent = ""
    }
    
    // Funcion que se hace al principio de cada elemento xml
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
            
        // Beach Elements
        case BeachXMLTags.origin:
            origin = Origin()
        case BeachXMLTags.prediction:
            prediction = [DayXMLData]()
        case BeachXMLTags.day:
            dayData = DayXMLData()
            dayData?.date = attributeDict[DayXMLProperties.date]!
            
        // Days elements
        case DayXMLTags.skyState:
            dayData?.skyState = fillTwoValueData(with: attributeDict)
        case DayXMLTags.wind:
            dayData?.wind = fillTwoValueData(with: attributeDict)
        case DayXMLTags.swell:
            dayData?.swell = fillTwoValueData(with: attributeDict)
        case DayXMLTags.maxTemp:
            dayData?.maxTemp = Int(attributeDict[DayXMLProperties.value1]!)!
        case DayXMLTags.termSensation:
            dayData?.termSensation.f = Int(attributeDict[DayXMLProperties.value1]!)!
            dayData?.termSensation.decription = attributeDict[DayXMLProperties.desc1]!
        case DayXMLTags.waterTemp:
            dayData?.waterTemp = Int(attributeDict[DayXMLProperties.value1]!)!
        case DayXMLTags.maxUV:
            dayData?.maxUV = Int(attributeDict[DayXMLProperties.value1]!)!
        default:
            break
        }
        currentContent = ""
    }
    
    func fillTwoValueData(with dictionary: [String : String]) -> [TwoValueData] {
        var data = TwoValueData()
        var arrayData = [TwoValueData]()
        data.f = Int(dictionary[DayXMLProperties.f1]!)!
        data.decription = dictionary[DayXMLProperties.desc1]!
        arrayData.append(data)
        data.f = Int(dictionary[DayXMLProperties.f2]!)!
        data.decription = dictionary[DayXMLProperties.desc2]!
        arrayData.append(data)
        return arrayData
    }
    
    
    // Lo que hay dentro de la etiqueta XML
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentContent! += string
    }
    
    // Llega al final de la etiqueta XML
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        // Origin elements
        case OriginXMLTags.productor:
            origin?.productor = currentContent
        case OriginXMLTags.web:
            origin?.web = currentContent
        case OriginXMLTags.language:
            origin?.language = currentContent
        case OriginXMLTags.copyright:
            origin?.copyrigth = currentContent
        case OriginXMLTags.legalNote:
            origin?.legalNote = currentContent
        // Beach elements
        case BeachXMLTags.origin:
            self.origin = origin!
        case BeachXMLTags.elaborated:
            self.elaborateDate = currentContent
        case BeachXMLTags.beachName:
            self.beachName = currentContent
        case BeachXMLTags.beachCityCode:
            self.city = currentContent
        case BeachXMLTags.day:
            prediction?.append(dayData!)
        // case BeachXMLTags.prediction:
        //    self.prediction = prediction
        default:
            break
        }
    }

}

class Origin: NSObject {
    var productor : String?
    var web : String?
    var language : String?
    var copyrigth : String?
    var legalNote: String?
    override init() {}
}

class DayXMLData: NSObject {
    var date: String?
    var skyState: [TwoValueData]?
    var wind: [TwoValueData]?
    var swell: [TwoValueData]?
    var maxTemp: Int?
    var termSensation = TwoValueData()
    var waterTemp: Int?
    var maxUV: Int?
    override init() {}
}
    
    
    
struct SwellDescription {
    static let weak = "Weak"
    static let moderate = "Moderate"
    static let strong = "Strong"
    static let error = "Error"
}

struct WindDescription {
    static let loose = "Loose"
    static let moderate = "Moderate"
    static let strong = "Strong"
    static let error = "Error"
}

struct TermSensationDescription {
    static let nHeat = "Nice Heat"
    static let soft = "Soft"
    static let vCold = "Very Cold"
    static let cold = "Cold"
    static let error = "Error"
}

    
public func getWindString(withCode: Int?) -> String {
    
    let code = withCode ?? -1
    
    switch code {
    case 210:
        return WindDescription.loose
    case 220:
        return WindDescription.moderate
    case 230:
        return WindDescription.strong
    default:
        return WindDescription.error
    }
    
}

public func getSwellString(withCode: Int?) -> String {
    
    let code = withCode ?? -1
    
    switch code {
    case 310:
        return SwellDescription.weak
    case 320:
        return SwellDescription.moderate
    case 330:
        return SwellDescription.strong
    default:
        return SwellDescription.error
    }
    
}

public func getTermSensationString(withCode: Int?) -> String {
    
    let code = withCode ?? -1
    
    switch code {
    case 410:
        return TermSensationDescription.nHeat
    case 420:
        return TermSensationDescription.soft
    case 430:
        return TermSensationDescription.vCold
    case 440:
        return TermSensationDescription.cold
    default:
        return TermSensationDescription.error
    }
    
}

struct BeachXMLTags {
    static let beach = "playa"
    static let origin = "origin"
    static let elaborated = "elaborado"
    static let beachName = "nombre"
    static let beachCityCode = "localidad"
    static let prediction = "prediccion"
    static let day = "dia"
}

struct DayXMLTags {
    static let skyState = "estado_cielo"
    static let wind = "viento"
    static let swell = "oleaje"
    static let maxTemp = "t_maxima"
    static let termSensation = "s_termica"
    static let waterTemp = "t_agua"
    static let maxUV = "uv_max"
}

struct OriginXMLTags {
    static let productor = "productor"
    static let web = "web"
    static let language = "language"
    static let copyright = "copiright"
    static let legalNote = "nota_legal"
}

struct DayXMLProperties {
    static let date = "fecha"
    static let f1 = "f1"
    static let value1 = "valor1"
    static let desc1 = "descripcion1"
    static let f2 = "f2"
    static let desc2 = "descripcion2"
}
