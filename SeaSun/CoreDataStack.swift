//
//  CoreDataStack.swift
//  MyCoolNotes
//
//  Created by Alberto Ramis on 9/3/17.
//  Copyright © 2017 Alberto Ramis. All rights reserved.
//

import CoreData

struct CoreDataStack {
    
    //MARK: - Properties
    private let model : NSManagedObjectModel
    internal let coordinator : NSPersistentStoreCoordinator
    private let modelURL : URL
    internal let dbURL : URL
    let context : NSManagedObjectContext
    internal let backgroundContext : NSManagedObjectContext
    internal let persistingContext : NSManagedObjectContext
    
    //MARK: - Initializer
    init?(modelName: String) {
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in the main bundle")
            return nil
        }
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable ti create the model from \(modelURL)")
            return nil
        }
        
        self.model = model
        
        // Create the store coordinator
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistent context (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        self.persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.persistingContext.persistentStoreCoordinator = self.coordinator
        
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.context.parent = self.persistingContext
        
        // Create a background context child of main context
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.parent = self.context
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let docURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        
        let dbURL = docURL.appendingPathComponent("model.sqlite")
        
        do {
            try self.coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                    configurationName: nil,
                                                    at: dbURL,
                                                    options: nil)
        } catch {
            print("Unable to add store at \(dbURL)")
        }
        
        self.dbURL = dbURL
        
        // Option for migration
        /*let options = [NSInferMappingModelAutomaticallyOption : true,
                       NSMigratePersistentStoresAutomaticallyOption : true]
        
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : Any])
        } catch {
            print("Unable to add store at \(dbURL): \(error)")
        }*/
        
    }
    
    // MARK: - UTILS
    func addStoreCoordinator(_ storyType: String, configuration: String?, storeURL: URL, options: [NSObject : Any]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: configuration, at: storeURL, options: options)
    }
    
}

// MARK: Natch processing in the background
extension CoreDataStack{
    
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
        
        backgroundContext.perform {
            batch(self.backgroundContext)
            
            // Save it to the parent context, so normal saving can work
            do {
                try self.backgroundContext.save()
            } catch let error {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
        
    }
    
}

// MARK: - Removing data
extension CoreDataStack {
    
    func dropAllData() throws{
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try self.coordinator.destroyPersistentStore(at: self.dbURL, ofType: NSSQLiteStoreType, options: nil)
    }
    
}


// MARK: - Save
extension CoreDataStack {
    
    func save(){
        // We call this synchronously, but it's very fast operation
        // (it doesn't hit the disk). We need to know when it ends so
        // we can call the next save (on the persisting context). This 
        // last one might take some time and is done in a background queue
        self.context.performAndWait {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // Now we save in the background
                self.persistingContext.perform {
                    do{
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    // Call autosave again after delay seconds
    func autoSave(everySeconds delayInSeconds: Int) {
        
        if delayInSeconds > 0 {
            //Save the context
            save()
            print("autosaving")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delayInSeconds)) {
            self.autoSave(everySeconds: delayInSeconds)
        }
        
    }
}






