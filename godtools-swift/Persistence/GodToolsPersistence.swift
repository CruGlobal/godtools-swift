//
//  GodToolsPersistence.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/14/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GodToolsPersistence: NSObject {
    
    static var managedObjectContext: NSManagedObjectContext?
    
    static let context = { () -> NSManagedObjectContext in
        if (managedObjectContext == nil) {
            guard let modelURL = Bundle.main.url(forResource: "godtools_swift", withExtension: "momd") else {
                fatalError("Error loading model from bundle")
            }
            
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }
            
            let persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: mom)
            
            managedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("GodTools.sqlite")
            
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
        return managedObjectContext!
    }
}
