//
//  SeaSunExtensions.swift
//  SeaSun
//
//  Created by Alberto Ramis on 18/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//
//  Algunas estructuras y extensiones de ayura

import Foundation
import UIKit
import MapKit

struct Segues {
    static let introToInit = "Intro to init"
    static let initToFav = "Init to Favourites"
    static let initToDetail = "Init to detail"
    static let favToDetail = "Favourite to detail"
    static let detailToMap = "Detail to map"
    static let initToRegion = "Init to region"
    static let provinceToBeach = "Province to beach"
    static let beachToDetail = "Beach to detail"
    static let zoneToDetail = "Zone to detail"
}

struct labelsText {
    static let appName = "SeaSun"
    static let today = "Today"
    static let tomorrow = "Tomorrow"
    static let nearestBeach = "Nearest Beach"
    static let favourites = "Favourites"
    static let searchBeachPlaceholder = "Search beach"
    static let error = "Error"
    static let windTitle = "Wind"
    static let swellTitle = "Swell"
    static let uvTitle = "UV"
    static let waterTempTitle = "Water temperature"
    static let thermalSensTitle = "Thermal Sensation"
    static let currentLocation = "Current Location"
    static let alertTitle = "Delete beach to favourites"
    static let alertMessage = "Are you sure?"
    static let alertCancel = "Cancel"
    static let alertOk = "Delete"
}

private struct Types{
    static let zone = "Zone"
    static let beach = "Beach"
}

struct AemetURL {
    static let url = "http://www.aemet.es/xml/playas/play_v2_"
    static let type = ".xml"
}



// Funcion para parsear CSV
func parseCSV (contentsOfURL: NSURL, encoding: String.Encoding, type: String, error: NSErrorPointer) -> Any? {
    // Load the CSV file and parse it
    let delimiter = ","
    var zones: [(country:String,region:String,province:String,pZone:String,code:String)]?
    var beaches: [(name:String,city:String,lat:Double,long:Double,fav:Bool,webCode:String,zoneCode:String)]?
    var mutableEncoding = encoding
    
    if let content = try? String(contentsOf: contentsOfURL as URL, usedEncoding: &mutableEncoding) {
        if type == Types.zone { zones = [] }
        else if type == Types.beach { beaches = [] }
        let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
        for line in lines {
            var values:[String] = []
            if line != "" {
                // For a line with double quotes
                // we use NSScanner to perform the parsing
                if line.range(of: "\"") != nil {
                    var textToScan:String = line
                    var value:NSString?
                    var textScanner:Scanner = Scanner(string: textToScan)
                    while textScanner.string != "" {
                        
                        if (textScanner.string as NSString).substring(to: 1) == "\"" {
                            textScanner.scanLocation += 1
                            textScanner.scanUpTo("\"", into: &value)
                            textScanner.scanLocation += 1
                        } else {
                            textScanner.scanUpTo(delimiter, into: &value)
                        }
                        
                        // Store the value into the values array
                        values.append(value as! String)
                        
                        // Retrieve the unscanned remainder of the string
                        if textScanner.scanLocation < textScanner.string.characters.count {
                            textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                        } else {
                            textToScan = ""
                        }
                        textScanner = Scanner(string: textToScan)
                    }
                    
                    // For a line without double quotes, we can simply separate the string
                    // by using the delimiter (e.g. comma)
                } else  {
                    values = line.components(separatedBy: delimiter)
                }
                
                // Put the values into the tuple and add it to the items array
                if type == Types.zone {
                    let item = (
                        country: values[0],
                        region: values[1],
                        province: values[2],
                        pZone: values[3],
                        code: values[4]
                    )
                    zones?.append(item)
                } else if type == Types.beach {
                    let item = (
                        name: values[0],
                        city: values[1],
                        lat: Double(values[2]) ?? 0.0,
                        long: Double(values[3]) ?? 0.0,
                        fav: values[4] == "true" ? true : false,
                        webCode: values[5],
                        zoneCode: values[6]
                    )
                    beaches?.append(item)
                }
            }
        }
    }
    return type == Types.zone ? zones : beaches
}

extension UIColor {
    
    //0x7EDDCE
    public class var seaSunBlue: UIColor {
        return UIColor(red: 0.494, green: 0.867, blue: 0.808, alpha: 1.0) }
    
    //0xFFAA73
    public class var seaSunOrange: UIColor {
        return UIColor(red:1.00, green:0.67, blue:0.45, alpha:1.0) }

    
}

public func getStateImage(withCode: Int?) -> UIImage {
    
    let code = withCode ?? -1
    
    switch code {
    case 100:
        return #imageLiteral(resourceName: "wi_sun")
    case 110:
        return #imageLiteral(resourceName: "wi_partly_cloudy")
    case 120:
        return #imageLiteral(resourceName: "wi_cloudy")
    case 130:
        return #imageLiteral(resourceName: "wi_partly_cloudy_rain")
    case 140:
        return #imageLiteral(resourceName: "wi_rain")
    default:
        return #imageLiteral(resourceName: "error")
    }
    
}

public func getDayImage(forToday today: Bool) -> UIImage {
    
    let calendar = Calendar.autoupdatingCurrent
    let components = calendar.dateComponents([.day, .month, .year], from: Date())
    
    switch components.day! {
    case 1:
        return today ? #imageLiteral(resourceName: "cal_day_1") : #imageLiteral(resourceName: "cal_day_2")
    case 2:
        return today ? #imageLiteral(resourceName: "cal_day_2") : #imageLiteral(resourceName: "cal_day_3")
    case 3:
        return today ? #imageLiteral(resourceName: "cal_day_3") : #imageLiteral(resourceName: "cal_day_4")
    case 4:
        return today ? #imageLiteral(resourceName: "cal_day_4") : #imageLiteral(resourceName: "cal_day_5")
    case 5:
        return today ? #imageLiteral(resourceName: "cal_day_5") : #imageLiteral(resourceName: "cal_day_6")
    case 6:
        return today ? #imageLiteral(resourceName: "cal_day_6") : #imageLiteral(resourceName: "cal_day_7")
    case 7:
        return today ? #imageLiteral(resourceName: "cal_day_7") : #imageLiteral(resourceName: "cal_day_8")
    case 8:
        return today ? #imageLiteral(resourceName: "cal_day_8") : #imageLiteral(resourceName: "cal_day_9")
    case 9:
        return today ? #imageLiteral(resourceName: "cal_day_9") : #imageLiteral(resourceName: "cal_day_10")
    case 10:
        return today ? #imageLiteral(resourceName: "cal_day_10") : #imageLiteral(resourceName: "cal_day_11")
    case 11:
        return today ? #imageLiteral(resourceName: "cal_day_11") : #imageLiteral(resourceName: "cal_day_12")
    case 12:
        return today ? #imageLiteral(resourceName: "cal_day_12") : #imageLiteral(resourceName: "cal_day_13")
    case 13:
        return today ? #imageLiteral(resourceName: "cal_day_13") : #imageLiteral(resourceName: "cal_day_14")
    case 14:
        return today ? #imageLiteral(resourceName: "cal_day_14") : #imageLiteral(resourceName: "cal_day_15")
    case 15:
        return today ? #imageLiteral(resourceName: "cal_day_15") : #imageLiteral(resourceName: "cal_day_16")
    case 16:
        return today ? #imageLiteral(resourceName: "cal_day_16") : #imageLiteral(resourceName: "cal_day_17")
    case 17:
        return today ? #imageLiteral(resourceName: "cal_day_17") : #imageLiteral(resourceName: "cal_day_18")
    case 18:
        return today ? #imageLiteral(resourceName: "cal_day_18") : #imageLiteral(resourceName: "cal_day_19")
    case 19:
        return today ? #imageLiteral(resourceName: "cal_day_19") : #imageLiteral(resourceName: "cal_day_20")
    case 20:
        return today ? #imageLiteral(resourceName: "cal_day_20") : #imageLiteral(resourceName: "cal_day_21")
    case 21:
        return today ? #imageLiteral(resourceName: "cal_day_21") : #imageLiteral(resourceName: "cal_day_22")
    case 22:
        return today ? #imageLiteral(resourceName: "cal_day_22") : #imageLiteral(resourceName: "cal_day_23")
    case 23:
        return today ? #imageLiteral(resourceName: "cal_day_23") : #imageLiteral(resourceName: "cal_day_24")
    case 24:
        return today ? #imageLiteral(resourceName: "cal_day_24") : #imageLiteral(resourceName: "cal_day_25")
    case 25:
        return today ? #imageLiteral(resourceName: "cal_day_25") : #imageLiteral(resourceName: "cal_day_26")
    case 26:
        return today ? #imageLiteral(resourceName: "cal_day_26") : #imageLiteral(resourceName: "cal_day_27")
    case 27:
        return today ? #imageLiteral(resourceName: "cal_day_27") : #imageLiteral(resourceName: "cal_day_28")
    case 28:
        if isLeapYear(components.year!) {
            return today ? #imageLiteral(resourceName: "cal_day_28") : #imageLiteral(resourceName: "cal_day_29")
        } else {
            return today ? #imageLiteral(resourceName: "cal_day_28") : #imageLiteral(resourceName: "cal_day_1")
        }
    case 29:
        if components.month! == 2 {
            return today ? #imageLiteral(resourceName: "cal_day_29") : #imageLiteral(resourceName: "cal_day_1")
        } else {
            return today ? #imageLiteral(resourceName: "cal_day_29") : #imageLiteral(resourceName: "cal_day_30")
        }
    case 30:
        if has31Days(components.month!) {
            return today ? #imageLiteral(resourceName: "cal_day_30") : #imageLiteral(resourceName: "cal_day_31")
        } else {
            return today ? #imageLiteral(resourceName: "cal_day_30") : #imageLiteral(resourceName: "cal_day_1")
        }
    case 31:
        return today ? #imageLiteral(resourceName: "cal_day_31") : #imageLiteral(resourceName: "cal_day_1")
    default:
        return #imageLiteral(resourceName: "error")
    }
}

public func isLeapYear(_ year: Int) -> Bool {
    return ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
}

public func has31Days(_ month: Int) -> Bool {
    return month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12
}

