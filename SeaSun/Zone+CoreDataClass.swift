//
//  Zone+CoreDataClass.swift
//  SeaSun
//
//  Created by Alberto Ramis on 28/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import Foundation
import CoreData

@objc(Zone)
public class Zone: NSManagedObject {
    
    convenience init(code: String, country: String, province: String, pZone: String, region: String, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Zone", in: context) {
            self.init(entity: ent, insertInto: context)
            self.code = code
            self.country = country
            self.province = province
            self.pZone = pZone
            self.region = region
            self.beaches = NSSet()
        } else {
            fatalError("Unable to find entoty name")
        }
    }


}
