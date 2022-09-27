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
    
    func getAllLessons() -> [ResourceModel] {
        return getResources(sorted: true).filter { resource in
            return resource.isLessonType && resource.isHidden == false
        }
    }
    
    func getAllTools(sorted: Bool, with category: String? = nil) -> [ResourceModel] {
        let metaTools = getResources(with: .metaTool)
        let defaultVariantIds = metaTools.compactMap { $0.defaultVariantId }
        let defaultVariants = getResources(ids: defaultVariantIds)
        
        let resourcesExcludingVariants = getResources(with: ["", nil])
        
        let combinedResourcesAndDefaultVariants = resourcesExcludingVariants + defaultVariants
   
        var allTools = combinedResourcesAndDefaultVariants.filter { resource in
                        
            if let category = category, resource.attrCategory != category {
                return false
            }
            
            return resource.isToolType && resource.isHidden == false
            
        }
        
        if sorted {
            allTools = allTools.sorted(by: { $0.attrDefaultOrder < $1.attrDefaultOrder })
        }
        
        return allTools
    }
    
    func getFeaturedLessons() -> [ResourceModel] {
        return getAllLessons().filter { $0.attrSpotlight == true }
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
    
    func getResources(sorted: Bool = false) -> [ResourceModel] {
        var realmResources = realmDatabase.openRealm().objects(RealmResource.self)
        
        if sorted {
            realmResources = realmResources.sorted(byKeyPath: #keyPath(RealmResource.attrDefaultOrder), ascending: true)
        }
        
        return realmResources.map({ResourceModel(model: $0)})
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
    
    func getResourceVariants(resourceId: String) -> [ResourceModel] {
        
        let predicate = NSPredicate(format: "metatoolId".appending(" = [c] %@"), resourceId)
        
        return realmDatabase.openRealm().objects(RealmResource.self).filter(predicate).map({ResourceModel(model: $0)})
    }
    
    func getSpotlightTools() -> [ResourceModel] {
        return realmDatabase.openRealm().objects(RealmResource.self)
            .where { $0.attrSpotlight == true && $0.isHidden == false }
            .map { ResourceModel(model: $0) }
            .filter { $0.isToolType }
    }
    
    func syncResources(languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return resourcesSync.syncResources(languagesSyncResult: languagesSyncResult, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
    }
}
