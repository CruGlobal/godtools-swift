//
//  GodToolsLanguage+CoreDataClass.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/17/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData


public class GodToolsLanguage: NSManagedObject {
    
    static func fetchBy(code :String, context :NSManagedObjectContext) -> GodToolsLanguage? {
        let languageFetch :NSFetchRequest<GodToolsLanguage> = GodToolsLanguage.fetchRequest()
        languageFetch.predicate = NSPredicate.init(format: "code == %@", code)
        
        do {
            let languages = try context.fetch(languageFetch)
            
            if (languages.count == 1) {
                return languages[0]
            }
        } catch {
            
        }
        
        return nil
    }
    
    static func createIn(context :NSManagedObjectContext) -> GodToolsLanguage {
        return NSEntityDescription.insertNewObject(forEntityName: "GodToolsLanguage", into: context) as! GodToolsLanguage
    }
}
