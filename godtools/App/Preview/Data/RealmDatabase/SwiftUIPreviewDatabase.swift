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
        
        let resourceKgpGospel = RealmResource()
        
        resourceKgpGospel.abbreviation = "kgp"
        resourceKgpGospel.attrCategory = "gospel"
        resourceKgpGospel.attrSpotlight = true
        resourceKgpGospel.id = "1"
        resourceKgpGospel.name = "Preview Resource"
        resourceKgpGospel.resourceDescription = ""
        resourceKgpGospel.totalViews = 12579
        
        return [resourceKgpGospel]
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
