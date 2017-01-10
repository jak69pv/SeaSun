//
//  Zone+CoreDataProperties.swift
//  SeaSun
//
//  Created by Alberto Ramis on 28/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import Foundation
import CoreData


extension Zone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Zone> {
        return NSFetchRequest<Zone>(entityName: "Zone");
    }

    @NSManaged public var code: String?
    @NSManaged public var country: String?
    @NSManaged public var province: String?
    @NSManaged public var pZone: String?
    @NSManaged public var region: String?
    @NSManaged public var beaches: NSSet?

}

// MARK: Generated accessors for beaches
extension Zone {

    @objc(addBeachesObject:)
    @NSManaged public func addToBeaches(_ value: Beach)

    @objc(removeBeachesObject:)
    @NSManaged public func removeFromBeaches(_ value: Beach)

    @objc(addBeaches:)
    @NSManaged public func addToBeaches(_ values: NSSet)

    @objc(removeBeaches:)
    @NSManaged public func removeFromBeaches(_ values: NSSet)
    
}
