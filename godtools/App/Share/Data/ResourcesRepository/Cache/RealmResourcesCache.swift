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
        
        return ResourceModel(model: realmResource)
    }
    
    func getResource(abbreviation: String) -> ResourceModel? {
        
        guard let realmResource = realmDatabase.openRealm().objects(RealmResource.self).filter("\(#keyPath(RealmResource.abbreviation)) = '\(abbreviation)'").first else {
            return nil
        }
        
        return ResourceModel(model: realmResource)
    }
    
    func getResources(ids: [String]) -> [ResourceModel] {
        
        return realmDatabase.openRealm().objects(RealmResource.self)
            .filter("\(#keyPath(RealmResource.id)) IN %@", ids)
            .map{
                ResourceModel(model: $0)
            }
    }
    
    func getResources() -> [ResourceModel] {
        return realmDatabase.openRealm().objects(RealmResource.self)
            .map({ResourceModel(model: $0)})
    }
    
    func getResources(with metaToolIds: [String?]) -> [ResourceModel] {
        return realmDatabase.openRealm().objects(RealmResource.self)
            .filter(NSPredicate(format: "%K IN %@", #keyPath(RealmResource.metatoolId), metaToolIds))
            .map { ResourceModel(model: $0)}
    }
    
    func getResources(with resourceType: ResourceType) -> [ResourceModel] {
        return realmDatabase.openRealm().objects(RealmResource.self)
            .where { $0.resourceType == resourceType.rawValue }
            .map { ResourceModel(model: $0) }
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
        
        return TranslationModel(model: realmTranslation)
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

        return TranslationModel(model: realmTranslation)
    }
    
    func getResourceVariants(resourceId: String) -> [ResourceModel] {
        
        let predicate = NSPredicate(format: "metatoolId".appending(" = [c] %@"), resourceId)
        
        return realmDatabase.openRealm().objects(RealmResource.self).filter(predicate).map({ResourceModel(model: $0)})
    }
    
    func syncResources(languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return resourcesSync.syncResources(languagesSyncResult: languagesSyncResult, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
    }
}
