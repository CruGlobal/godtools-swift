//
//  MetaDataController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import PromiseKit
import CoreData

class MetaDataController: NSObject {    
    
    func updateFromRemote () -> Promise<Void> {
        return GodtoolsAPI.sharedInstance.getMeta().then(execute: { (json) -> Void in
            MetaResponseHandler.init().parse(data: json)
            
            let dataMigration = GodToolsDataMigration.init()
            
            if (dataMigration.isRequired()) {
                dataMigration.execute()
            }
        })
    }
    
    func loadFromLocal () -> NSFetchedResultsController<GodToolsLanguage> {
        let fetchRequest = NSFetchRequest<GodToolsLanguage>(entityName: "GodToolsLanguage")
        
        fetchRequest.predicate = NSPredicate.init(format: "packages.@count > 0", "")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let languageFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: GodToolsPersistence.context(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try languageFetchController.performFetch()
        } catch {
            print("error...")
        }
        return languageFetchController
    }
}
