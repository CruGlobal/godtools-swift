//
//  MetaResponseHandler.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/14/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData

class MetaResponseHandler: NSObject {
    
    func parse(data: Any) {

        let persistenceContext = GodToolsPersistence.context()
        
        extractLanguages(fromData: data).forEach({ (language) in
            createManagedLanguage(fromDictionary: language as! NSDictionary, inContext: persistenceContext)
        })
        
        do {
            try persistenceContext.save()
        } catch {
            debugPrint("Failure to save: \(error)")
        }
    }
    
    func extractLanguages(fromData: Any) -> NSArray {
        return (fromData as! NSDictionary).value(forKey: "languages") as! NSArray;
    }
    
    func createManagedLanguage(fromDictionary: NSDictionary, inContext: NSManagedObjectContext) -> Void {
        let code:String = fromDictionary.value(forKey: "code") as! String
        
        if (languageExistsIn(context: inContext, code: code)) {
            return
        }
        
        let name:String = fromDictionary.value(forKey: "name") as! String
        let packages:NSArray = fromDictionary.value(forKey: "packages") as! NSArray
        
        let persistentLanguage: GodToolsLanguage = NSEntityDescription.insertNewObject(forEntityName: "GodToolsLanguage", into: inContext) as! GodToolsLanguage
        persistentLanguage.code = code
        persistentLanguage.name = name
        
        packages.forEach({ (package) in
            let persistentPackage: GodToolsPackage = NSEntityDescription.insertNewObject(forEntityName: "GodToolsPackage", into: inContext) as! GodToolsPackage
            persistentPackage.code = ((package as! NSDictionary).value(forKey: "code") as! String)
            persistentLanguage.addToPackages(persistentPackage)
        })
    }
    
    func languageExistsIn(context: NSManagedObjectContext, code: String) -> Bool {
        let languageFetch :NSFetchRequest<GodToolsLanguage> = GodToolsLanguage.fetchRequest()
        languageFetch.predicate = NSPredicate.init(format: "code == %@", code)
        
        do {
            return try context.fetch(languageFetch).count > 0
        } catch {
            return false
        }
    }
}
