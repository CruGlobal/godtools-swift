//
//  GodToolsDataMigration.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 11/18/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import CoreData

class GodToolsDataMigration {
    
    let legacyContext  = GTLegacyPersistence.context()
    let context = GodToolsPersistence.context()
    let legacyLanguageFetchRequest :NSFetchRequest<GTLanguage> = GTLanguage.fetchRequest()
    
    func isRequired() -> Bool {
        do {
            return try legacyContext.fetch(legacyLanguageFetchRequest).count > 0
        } catch {
            return false
        }
    }
    
    func execute() {
        do {
            let legacyLanguages = try legacyContext.fetch(legacyLanguageFetchRequest)
            
            for legacylanguage in legacyLanguages {
                legacyContext.delete(legacylanguage)
                
                if (legacylanguage.downloaded == nil) {
                    continue;
                }
                
                let languageFetch :NSFetchRequest<GodToolsLanguage> = GodToolsLanguage.fetchRequest()
                languageFetch.predicate = NSPredicate.init(format: "code == %@", legacylanguage.code!)
                
                let languages = try context.fetch(languageFetch)
                
                if (languages.count == 0) {
                    continue
                }
                
                languages[0].downloaded = legacylanguage.downloaded!.boolValue
                for legacyPackage in legacylanguage.packages! {
                    let package = languages[0].packageBy(code: legacyPackage.code!)
                    package?.configFilename = legacyPackage.configFile
                    package?.iconFilename = legacyPackage.icon
                    package?.majorVersion = (legacyPackage.localMajorVersion?.int16Value)!
                    package?.minorVersion = (legacyPackage.localMinorVersion?.int16Value)!
                    package?.name = (legacyPackage.name)!
                }
            }
            
            try context.save()
            try legacyContext.save()
        } catch {
            debugPrint(error)
        }
    }
}
