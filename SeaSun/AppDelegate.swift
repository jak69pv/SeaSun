
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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Cargamos la info
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        // Para actualizar DB mientras vamos metiendo playas
        // defaults.set(false, forKey: "isPreloaded")
        if !isPreloaded {
            preloadData(ofType: ResourcesNames.beach)
            preloadData(ofType: ResourcesNames.zone)
            defaults.set(true, forKey: "isPreloaded")
        }
        //
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SeaSun")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private struct ResourcesNames {
        static let zonesResource = "zonesData"
        static let beachesResource = "beachData"
        static let beach = "Beach"
        static let zone = "Zone"
    }
    
    // Functions for preload the data
    func preloadData (ofType type: String) {
        
        let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        // Retrieve data from the source file
        let data = type == ResourcesNames.zone ? ResourcesNames.zonesResource : ResourcesNames.beachesResource
        if let contentsOfURL = Bundle.main.url(forResource: data, withExtension: "csv") {
            
            // Remove all the menu items before preloading
            removeData(ofType: type)
            if type == ResourcesNames.zone {
                var error:NSError?
                if let zones = parseCSV(contentsOfURL: contentsOfURL as NSURL, encoding: String.Encoding.utf8, type: type, error: &error) as? [(country:String,region:String,province:String,pZone:String,code:String)] {
                    // Preload the menu items
                    managedObjectContext?.perform {
                        for zone in zones {
                            let zoneToSave = NSEntityDescription.insertNewObject(forEntityName: type, into: managedObjectContext!) as! Zone
                            zoneToSave.country = zone.country
                            zoneToSave.region = zone.region
                            zoneToSave.province = zone.province
                            zoneToSave.pZone = zone.pZone
                            zoneToSave.code = zone.code
                            
                            // Buscamos las playas con el mismo código y las guardamos
                            let fetchRequest = NSFetchRequest<Beach>(entityName: "Beach")
                            fetchRequest.predicate = NSPredicate(format: "zoneCode like %@" ,zoneToSave.code!)
                            
                            do {
                                let searchBeaches = try managedObjectContext?.fetch(fetchRequest)
                                
                                print ("num of results = \(searchBeaches?.count) en \(zoneToSave.code)")
                                
                                zoneToSave.beaches?.addingObjects(from: searchBeaches!)
                                
                                // Guardamos en la base de datos
                                try managedObjectContext?.save()

                            } catch let error {
                                print ("Could not save \(error), \(error.localizedDescription)")
                            }
                                                    }
                    }
                }
            } else if type == ResourcesNames.beach {
                var error:NSError?
                if let beaches = parseCSV(contentsOfURL: contentsOfURL as NSURL, encoding: String.Encoding.utf8, type: type, error: &error) as? [(name:String,city:String,lat:Double,long:Double,fav:Bool,webCode:String,zoneCode:String)]? {
                    // Preload the menu items
                    managedObjectContext?.perform {
                        for beach in beaches! {
                            let beachToSave = NSEntityDescription.insertNewObject(forEntityName: type, into: managedObjectContext!) as! Beach
                            beachToSave.name = beach.name
                            beachToSave.city = beach.city
                            beachToSave.lat = beach.lat
                            beachToSave.long = beach.long
                            beachToSave.fav = beach.fav
                            beachToSave.webCode = beach.webCode
                            beachToSave.zoneCode = beach.zoneCode
                            
                            // Guardamos en la base de datos
                            do {
                                try managedObjectContext?.save()
                            } catch let error {
                                print ("Could not save \(error), \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func removeData (ofType type: String) {
        // Remove the existing items
        
        let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

        managedObjectContext?.perform {
            if type == ResourcesNames.zone {
                //create a fetch request, telling it about the entity
                let request: NSFetchRequest<Zone> = Zone.fetchRequest()
                
                do {
                    // go get the results
                    let searchResults = try managedObjectContext?.fetch(request)
                    
                    //I like to check the size of the returned results!
                    print ("num of results = \(searchResults?.count)")
                    
                    // YOu need to convert to NSManagedObject to use 'for' loops
                    for trans in searchResults! {
                        managedObjectContext?.delete(trans)
                    }
                } catch {
                    print("Error with request: \(error)")
                }
            } else if type == ResourcesNames.beach {
                let request: NSFetchRequest<Beach> = Beach.fetchRequest()
                do {
                    let searchResults = try managedObjectContext?.fetch(request)
                    print ("num of results = \(searchResults?.count)")
                    for trans in searchResults! {
                        managedObjectContext?.delete(trans)
                    }
                } catch {
                    print("Error with request: \(error)")
                }
            }
            
        }
    }
    

}

