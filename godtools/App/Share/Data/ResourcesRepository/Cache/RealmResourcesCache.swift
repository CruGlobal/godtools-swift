//
//  RealmResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmResourcesCache {
    
    private let realmDatabase: RealmDatabase
    private let resourcesSync: RealmResourcesCacheSync
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
        self.resourcesSync = RealmResourcesCacheSync(realmDatabase: realmDatabase)
    }
    
    var numberOfResources: Int {
        return realmDatabase.openRealm().objects(RealmResource.self).count
    }
    
    func getResourcesChanged() -> AnyPublisher<Void, Never> {
        return realmDatabase.openRealm().objects(RealmResource.self).objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getResource(id: String) -> ResourceModel? {
        
        guard let realmResource = realmDatabase.openRealm().object(ofType: RealmResource.self, forPrimaryKey: id) else {
            return nil
        }
        
        return ResourceModel(realmResource: realmResource)
    }
    
    func getResource(abbreviation: String) -> ResourceModel? {
        
        guard let realmResource = realmDatabase.openRealm().objects(RealmResource.self).filter("\(#keyPath(RealmResource.abbreviation)) = '\(abbreviation)'").first else {
            return nil
        }
        
        return ResourceModel(realmResource: realmResource)
    }
    
    func getResources(ids: [String]) -> [ResourceModel] {
        
        return realmDatabase.openRealm().objects(RealmResource.self)
            .filter("\(#keyPath(RealmResource.id)) IN %@", ids)
            .map{
                ResourceModel(realmResource: $0)
            }
    }
    
    func getResources() -> [ResourceModel] {
        return realmDatabase.openRealm().objects(RealmResource.self)
            .map({ResourceModel(realmResource: $0)})
    }
    
    func getResourceLanguages(id: String) -> [LanguageModel] {
        
        guard let realmResource = realmDatabase.openRealm().object(ofType: RealmResource.self, forPrimaryKey: id) else {
            return Array()
        }
        
        return realmResource.languages.map({LanguageModel(model: $0)})
    }
    
    func getResourceLanguageLatestTranslation(resourceId: String, languageId: String) -> TranslationModel? {
        
        guard let realmResource = realmDatabase.openRealm().object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return nil
        }
        
        guard let realmTranslation = realmResource.latestTranslations
            .filter("\(#keyPath(RealmTranslation.language.id)) = '\(languageId)'")
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false).first else {
            return nil
        }
        
        return TranslationModel(realmTranslation: realmTranslation)
    }
    
    func getResourceLanguageLatestTranslation(resourceId: String, languageCode: String) -> TranslationModel? {
        
        guard let realmResource = realmDatabase.openRealm().object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return nil
        }
        
        guard let realmTranslation = realmResource.latestTranslations
            .filter(NSPredicate(format: "\(#keyPath(RealmTranslation.language.code)) = [c] %@", languageCode.lowercased()))
            .sorted(byKeyPath: #keyPath(RealmTranslation.version), ascending: false).first else {
            return nil
        }

        return TranslationModel(realmTranslation: realmTranslation)
    }
    
    func syncResources(languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return resourcesSync.syncResources(languagesSyncResult: languagesSyncResult, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
    }
}
