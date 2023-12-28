//
//  RealmTranslationsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTranslationsCache {
    
    private let realmDatabase: RealmDatabase
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }

    func getTranslation(id: String) -> TranslationModel? {
        
        guard let realmTranslation = realmDatabase.openRealm().object(ofType: RealmTranslation.self, forPrimaryKey: id) else {
            return nil
        }
        
        return TranslationModel(model: realmTranslation)
    }
    
    func getTranslations(ids: [String]) -> [TranslationModel] {
        
        return realmDatabase.openRealm().objects(RealmTranslation.self)
            .filter("id IN %@", ids)
            .map{
                TranslationModel(model: $0)
            }
    }
    
    func getTranslationsSortedByLatestVersion(resourceId: String, languageId: String) -> [TranslationModel] {
        
        guard let realmResource = realmDatabase.openRealm().object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            
            return Array()
        }
        
        return realmResource.getLatestTranslations()
            .filter("\(#keyPath(RealmTranslation.language.id)) = '\(languageId)'")
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
            .map({ TranslationModel(model: $0 )})
        
    }
    
    func getTranslationsSortedByLatestVersion(resourceId: String, languageCode: String) -> [TranslationModel] {
        
        guard let realmResource = realmDatabase.openRealm().object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
           
            return Array()
        }
        
        return realmResource.getLatestTranslations()
            .filter(NSPredicate(format: "\(#keyPath(RealmTranslation.language.code)) = [c] %@", languageCode.lowercased()))
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false)
            .map({ TranslationModel(model: $0 )})
    }
}
