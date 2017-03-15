//
//  Beach+CoreDataProperties.swift
//  SeaSun
//
//  Created by Alberto Ramis on 13/3/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
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
    @NSManaged public var weather: NSSet?

}

// MARK: Generated accessors for weather
extension Beach {

    @objc(addWeatherObject:)
    @NSManaged public func addToWeather(_ value: Weather)

    @objc(removeWeatherObject:)
    @NSManaged public func removeFromWeather(_ value: Weather)

    @objc(addWeather:)
    @NSManaged public func addToWeather(_ values: NSSet)

    @objc(removeWeather:)
    @NSManaged public func removeFromWeather(_ values: NSSet)

}
