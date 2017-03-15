//
//  Beach+CoreDataClass.swift
//  SeaSun
//
//  Created by Alberto Ramis on 13/3/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
//

import Foundation
import CoreData


public class Beach: NSManagedObject {
    
    convenience init(name: String, city: String, lat: Double, long: Double, fav: Bool, webCode: String, zoneCode: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Beach", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name
            self.city = city
            self.lat = lat
            self.long = long
            self.fav = fav
            self.webCode = webCode
            self.zoneCode = zoneCode
            self.weather = NSSet()
            
            context.perform {
                
                let fetchRequest = NSFetchRequest<Zone>(entityName: "Zone")
                fetchRequest.predicate = NSPredicate(format: "code == %@",zoneCode)
                
                do {
                    let searchZone = try context.fetch(fetchRequest)
                    if !searchZone.isEmpty {
                        searchZone[0].addToBeaches(self)
                    }
                } catch {
                    fatalError("Could not save \(error), \(error.localizedDescription)")
                }
            }
            
        } else {
            fatalError("Unable to find entoty name")
        }
    }


}
