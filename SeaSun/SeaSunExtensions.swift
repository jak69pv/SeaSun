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

struct Segues {
    static let introToInit = "Intro to init"
    static let initToFav = "Init to Favourites"
    static let favToDetail = "Favourite to detail"
    static let detailToMap = "Detail to map"
    static let initToRegion = "Init to region"
    static let regionToProvince = "Region to province"
    static let provinceToZone = "Province to Zone"
    static let zoneToDetail = "Zone to detail"
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
        return UIColor(red: CGFloat(0.494), green: CGFloat(0.867), blue: CGFloat(0.808), alpha: CGFloat(1.0)) }
    
}

