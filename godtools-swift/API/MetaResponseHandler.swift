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
        
        for(language) in extractLanguages(fromData: data) {
            let languageDictionary = language as! NSDictionary
            let name:String = languageDictionary.value(forKey: "name") as! String
            let code:String = languageDictionary.value(forKey: "code") as! String
            
            let persistentLanguage: GodToolsLanguage = NSEntityDescription.insertNewObject(forEntityName: "GodToolsLanguage", into: persistenceContext) as! GodToolsLanguage
            persistentLanguage.code = code
            persistentLanguage.name = name
        }
        
        do {
            try persistenceContext.save()
        } catch {
            debugPrint("Failure to save: \(error)")
        }
    }
    
    func extractLanguages(fromData: Any) -> NSArray {
        return (fromData as! NSDictionary).value(forKey: "languages") as! NSArray;
    }
}
