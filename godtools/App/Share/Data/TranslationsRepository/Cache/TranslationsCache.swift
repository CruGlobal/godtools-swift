//
//  TranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class TranslationsCache {
    
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getTranslationsSortedByLatestVersion(resourceId: String, languageId: String) -> [TranslationDataModel] {
        
        guard let realmResource = realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            
            return Array()
        }
        
        return realmResource.getLatestTranslations()
            .filter("\(#keyPath(RealmTranslation.language.id)) = '\(languageId)'")
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
            .map({ TranslationDataModel(interface: $0 )})
        
    }
    
    func getTranslationsSortedByLatestVersion(resourceId: String, languageCode: String) -> [TranslationDataModel] {
        
        guard let realmResource = realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
           
            return Array()
        }
        
        return realmResource.getLatestTranslations()
            .filter(NSPredicate(format: "\(#keyPath(RealmTranslation.language.code)) = [c] %@", languageCode.lowercased()))
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
            .map({ TranslationDataModel(interface: $0 )})
    }
}
