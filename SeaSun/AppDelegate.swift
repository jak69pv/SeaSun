
//
//  AppDelegate.swift
//  SeaSun
//
//  Created by Alberto Ramis on 14/11/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // MARK: - Core Data stack
    let stack = CoreDataStack(modelName: "SeaSun")!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Cargamos la info
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        // Para actualizar DB mientras vamos metiendo playas
        // defaults.set(false, forKey: "isPreloaded")
        if !isPreloaded {
            preloadData(ofType: ResourcesNames.zone)
            preloadData(ofType: ResourcesNames.beach)
            defaults.set(true, forKey: "isPreloaded")
        }
        stack.autoSave(everySeconds: 25)
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        stack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        stack.save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }


    
    // MARK: - Core Data Saving support
    
    private struct ResourcesNames {
        static let zonesResource = "zonesData"
        static let beachesResource = "beachData"
        static let beach = "Beach"
        static let zone = "Zone"
    }
    
    // Functions for preload the data
    func preloadData (ofType type: String) {
        
        // Retrieve data from the source file
        let data = type == ResourcesNames.zone ? ResourcesNames.zonesResource : ResourcesNames.beachesResource
        if let contentsOfURL = Bundle.main.url(forResource: data, withExtension: "csv") {
            
            // Remove all the menu items before preloading
            removeData(ofType: type)
            if type == ResourcesNames.zone {
                var error:NSError?
                if let zones = parseCSV(contentsOfURL: contentsOfURL as NSURL, encoding: String.Encoding.utf8, type: type, error: &error) as? [(country:String,region:String,province:String,pZone:String,code:String)] {
                    
                    // Preload the menu items
                    for zone in zones {
                        print(zone.code)
                        let _ = Zone(code: zone.code,
                                     country: zone.country,
                                     province: zone.province,
                                     pZone: zone.pZone,
                                     region: zone.region,
                                     context: self.stack.context)
                    }
                    stack.save()
                }
            } else if type == ResourcesNames.beach {
                var error:NSError?
                if let beaches = parseCSV(contentsOfURL: contentsOfURL as NSURL, encoding: String.Encoding.utf8, type: type, error: &error) as? [(name:String,city:String,lat:Double,long:Double,fav:Bool,webCode:String,zoneCode:String)]? {
                    // Preload the menu items
                    for beach in beaches! {
                        let _ = Beach(name: beach.name,
                                             city: beach.city,
                                             lat: beach.lat,
                                             long: beach.long,
                                             fav: beach.fav,
                                             webCode: beach.webCode,
                                             zoneCode: beach.zoneCode,
                                             context: self.stack.context)
                    }
                    stack.save()
                }
            }
            
        }
    }
    
    func removeData (ofType type: String) {
        // Remove the existing items
        
        stack.context.perform {
            if type == ResourcesNames.zone {
                //create a fetch request, telling it about the entity
                let request: NSFetchRequest<Zone> = Zone.fetchRequest()
                
                do {
                    // go get the results
                    let searchResults = try self.stack.context.fetch(request)
                    
                    //I like to check the size of the returned results!
                    print ("num of results = \(searchResults.count)")
                    
                    // YOu need to convert to NSManagedObject to use 'for' loops
                    for trans in searchResults {
                        self.stack.context.delete(trans)
                    }
                } catch {
                    print("Error with request: \(error)")
                }
            } else if type == ResourcesNames.beach {
                let request: NSFetchRequest<Beach> = Beach.fetchRequest()
                do {
                    let searchResults = try self.stack.context.fetch(request)
                    print ("num of results = \(searchResults.count)")
                    for trans in searchResults {
                        self.stack.context.delete(trans)
                    }
                } catch {
                    print("Error with request: \(error)")
                }
            }
            
        }
    }
    

}

