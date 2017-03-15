//
//  Weather+CoreDataClass.swift
//  SeaSun
//
//  Created by Alberto Ramis on 14/3/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
//

import Foundation
import CoreData


public class Weather: NSManagedObject {
    
    convenience init(beachCode: String, date: NSDate, elaborated: NSDate, maxTemp: Int32, maxUV: Int32, skyState1: Int32, skyState2: Int32, swell1: Int32, swell2: Int32, termSensation: Int32, waterTemp: Int32, wind1: Int32, wind2: Int32, beach: Beach,context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Weather", in: context) {
            self.init(entity: ent, insertInto: context)
            self.beachCode = beachCode
            self.date = date
            self.elaborated = elaborated
            self.maxTemp = maxTemp
            self.maxUV = maxUV
            self.skyState1 = skyState1
            self.skyState2 = skyState2
            self.swell1 = swell1
            self.swell2 = swell2
            self.termSensation = termSensation
            self.waterTemp = waterTemp
            self.wind1 = wind1
            self.wind2 = wind2
            
            beach.addToWeather(self)
            
        } else {
            fatalError("Unable to find entoty name Weather")
        }
    }
    
    
    static func getPrediction(context: NSManagedObjectContext, beach: Beach) -> [Weather]? {
        
        let currentDay = Date()
        let calendar = Calendar.current
        
        let today = calendar.component(.day, from: currentDay),
        todayMonth = calendar.component(.month, from: currentDay),
        todayYear = calendar.component(.year, from: currentDay)
        
        var yesterdayDate = calendar.date(byAdding: .day, value: -1, to: currentDay)
        yesterdayDate = calendar.date(byAdding: .hour, value: 1, to: yesterdayDate!)
        
        let yesterday = calendar.component(.day, from: yesterdayDate!),
        yesterdayMonth = calendar.component(.month, from: yesterdayDate!),
        yesterdayYear = calendar.component(.year, from: yesterdayDate!)
        
        var searchWeather: [Weather]?
        
        context.performAndWait {
            
            let fetchRequest = NSFetchRequest<Weather>(entityName: "Weather")
            
            fetchRequest.predicate = NSPredicate(format: "beachCode == %@", beach.webCode!)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            
            do {
                searchWeather = try context.fetch(fetchRequest)
            } catch {
                print("Error retrieving Weather info")
            }
        }
        
        guard let weatherPrediction = searchWeather, !searchWeather!.isEmpty else {
            return nil
        }
        
        let elaboratedDate = weatherPrediction[0].elaborated as! Date
        
        if calendar.component(.day, from: elaboratedDate) == today,
            calendar.component(.month, from: elaboratedDate) == todayMonth,
            calendar.component(.year, from: elaboratedDate) == todayYear{
            print("hay prediccion")
            return weatherPrediction
        } else if isInternetAvailable() &&
            calendar.component(.day, from: elaboratedDate) == yesterday,
            calendar.component(.month, from: elaboratedDate) == yesterdayMonth,
            calendar.component(.year, from: elaboratedDate) == yesterdayYear{
            return [weatherPrediction[1]]
        }
        
        return nil
    }
    
    static func addWeatherPrediction(context: NSManagedObjectContext, beach: Beach, beachData: BeachXMLModel) -> [Weather]? {
        
        var weathers: [Weather]?
        
        //Borramos las predicciones anteriores
        let fetchRequest = NSFetchRequest<Weather>(entityName: "Weather")
        fetchRequest.predicate = NSPredicate(format: "beachCode == %@", (beach.webCode)!)
        
        if let oldPredictions = try? context.fetch(fetchRequest) {
            for object in oldPredictions {
                context.delete(object)
            }
        }
        
        let elaboratedString = beachData.elaborateDate!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let elaboratedDate = dateFormatter.date(from: elaboratedString)!
        
        for day in 0...1 {
            let prediction = beachData.prediction?[day]
            
            let dateString = (prediction?.date)!
            
            dateFormatter.dateFormat = "YYYYMMdd"
            let date = dateFormatter.date(from: dateString)!
            
            let weather = Weather(beachCode: beach.webCode!,
                            date: date as NSDate,
                            elaborated: elaboratedDate as NSDate,
                            maxTemp: Int32((prediction?.maxTemp)!),
                            maxUV:  Int32((prediction?.maxUV)!),
                            skyState1: Int32((prediction?.skyState?[0].f)!),
                            skyState2: Int32((prediction?.skyState?[1].f)!),
                            swell1: Int32((prediction?.swell?[0].f)!),
                            swell2: Int32((prediction?.swell?[1].f)!),
                            termSensation: Int32((prediction?.termSensation.f)!),
                            waterTemp: Int32((prediction?.waterTemp)!),
                            wind1: Int32((prediction?.wind?[0].f)!),
                            wind2: Int32((prediction?.wind?[1].f)!),
                            beach: beach,
                            context: context)
            
            weathers?.append(weather)
        }
        
        return weathers
        
    }

}
