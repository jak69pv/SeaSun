//
//  Beach+CoreDataProperties.swift
//  SeaSun
//
//  Created by Alberto Ramis on 28/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import Foundation
import CoreData


extension Beach {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Beach> {
        return NSFetchRequest<Beach>(entityName: "Beach");
    }

    @NSManaged public var city: String?
    @NSManaged public var fav: Bool
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var name: String?
    @NSManaged public var webCode: String?
    @NSManaged public var zoneCode: String?
    @NSManaged public var beachZone: Zone?

}
