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
            createManagedLanguage(fromDictionary: language as! NSDictionary, context: persistenceContext)
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
    
    func createManagedLanguage(fromDictionary: NSDictionary, context: NSManagedObjectContext) -> Void {
        let code:String = fromDictionary.value(forKey: "code") as! String
        
        if (languageExistsIn(context: context, code: code)) {
            return
        }
        
        let name:String = fromDictionary.value(forKey: "name") as! String
        let packages:NSArray = fromDictionary.value(forKey: "packages") as! NSArray
        
        let persistentLanguage = GodToolsLanguage.createIn(context: context)
        persistentLanguage.code = code
        persistentLanguage.name = name
        
        packages.forEach({ (package) in
            let persistentPackage = GodToolsPackage.createIn(context: context)
            persistentPackage.code = ((package as! NSDictionary).value(forKey: "code") as! String)
            persistentLanguage.addToPackages(persistentPackage)
        })
    }
    
    func languageExistsIn(context: NSManagedObjectContext, code: String) -> Bool {
        return GodToolsLanguage.fetchBy(code: code, context: context) != nil
    }
}
