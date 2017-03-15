//
//  Weather+CoreDataProperties.swift
//  SeaSun
//
//  Created by Alberto Ramis on 14/3/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather");
    }

    @NSManaged public var beachCode: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var elaborated: NSDate?
    @NSManaged public var maxTemp: Int32
    @NSManaged public var maxUV: Int32
    @NSManaged public var skyState1: Int32
    @NSManaged public var skyState2: Int32
    @NSManaged public var swell1: Int32
    @NSManaged public var swell2: Int32
    @NSManaged public var termSensation: Int32
    @NSManaged public var waterTemp: Int32
    @NSManaged public var wind1: Int32
    @NSManaged public var wind2: Int32
    @NSManaged public var beach: Beach?

}
