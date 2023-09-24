//
//  SwiftUIPreviewDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 8/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class SwiftUIPreviewDatabase: RealmDatabase {
    
    override init(databaseConfiguration: RealmDatabaseConfiguration) {
        
        super.init(databaseConfiguration: databaseConfiguration)
        
        let objects: [Object] = getResources() + getLanguages()
        
        let realm: Realm = super.openRealm()
        
        do {
            
            try realm.write {
                realm.add(objects)
            }
        }
        catch let error {
            
            assertionFailure("Failed to add objects to swiftui preview realm.\n  error: \(error)")
        }
    }
    
    private func getResources() -> [RealmResource] {
        
        let resource_1 = RealmResource()
        
        resource_1.abbreviation = "kgp"
        resource_1.attrCategory = "gospel"
        resource_1.attrSpotlight = true
        resource_1.id = "1"
        resource_1.name = "Preview Resource"
        resource_1.resourceDescription = ""
        resource_1.totalViews = 12579
        
        return [resource_1]
    }
    
    private func getLanguages() -> [RealmLanguage] {
     
        let english = RealmLanguage()
        
        english.code = "en"
        english.direction = "ltr"
        english.id = "1"
        english.name = "English"
        
        return [english]
    }
}
