//
//  GodToolsPackage+CoreDataClass.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData


public class GodToolsPackage: NSManagedObject {
    
    static func fetchBy(code :String, languageCode :String, context :NSManagedObjectContext) -> [GodToolsPackage]? {
        let packageFetchRequest :NSFetchRequest<GodToolsPackage> = GodToolsPackage.fetchRequest()
        packageFetchRequest.predicate = NSPredicate(format: "code = %@ AND language.code = %@", code, languageCode)
        
        do {
            return try context.fetch(packageFetchRequest)
            
        } catch {
            
        }
        
        return nil
    }
    
    static func createIn(context :NSManagedObjectContext) -> GodToolsPackage {
        return NSEntityDescription.insertNewObject(forEntityName: "GodToolsPackage", into: context) as! GodToolsPackage
    }
}
