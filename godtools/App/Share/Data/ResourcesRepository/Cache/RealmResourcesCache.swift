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
        
    init(realmDatabase: RealmDatabase, resourcesSync: RealmResourcesCacheSync) {
        
        self.realmDatabase = realmDatabase
        self.resourcesSync = resourcesSync
    }
    
    var numberOfResources: Int {
        return realmDatabase.openRealm().objects(RealmResource.self).count
    }
    
    func getResourcesChangedPublisher() -> AnyPublisher<Void, Never> {
        return realmDatabase.openRealm().objects(RealmResource.self).objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getAllTools(sorted: Bool, category: String? = nil, languageId: String? = nil) -> [ResourceModel] {
        
        let metaTools = getResources(with: .metaTool)
        let defaultVariantIds = metaTools.compactMap { $0.defaultVariantId }
        let defaultVariants = getResources(ids: defaultVariantIds)
        
        let resourcesExcludingVariants = getResources(with: ["", nil])
        
        let combinedResourcesAndDefaultVariants = resourcesExcludingVariants + defaultVariants
   
        var allTools = combinedResourcesAndDefaultVariants.filter { resource in
                        
            if let category = category, resource.attrCategory != category {
                return false
            }
            
            if let languageId = languageId, resource.languageIds.contains(languageId) == false {
                return false
            }
            
            return resource.isToolType && resource.isHidden == false
            
        }
        
        if sorted {
            allTools = allTools.sorted(by: { $0.attrDefaultOrder < $1.attrDefaultOrder })
        }
        
        return allTools
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

// MARK: - Lessons

extension RealmResourcesCache {
    
    func getAllLessons(additionalAttributeFilters: [NSPredicate]? = nil, sorted: Bool) -> [ResourceModel] {
       
        var filterByAttributes: [NSPredicate] = Array()
        
        if let additionalAttributeFilters = additionalAttributeFilters, !additionalAttributeFilters.isEmpty {
            filterByAttributes.append(contentsOf: additionalAttributeFilters)
        }
        
        let filterIsLessonType = NSPredicate(format: "\(#keyPath(RealmResource.resourceType)) == [c] %@", ResourceType.lesson.rawValue)
        let filterIsNotHidden = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
        
        filterByAttributes.append(filterIsLessonType)
        filterByAttributes.append(filterIsNotHidden)
        
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterByAttributes)
             
        let realm: Realm = realmDatabase.openRealm()
        
        let allLessons: Results<RealmResource>
        
        if sorted {
            allLessons = realm.objects(RealmResource.self).filter(filterPredicate).sorted(byKeyPath: #keyPath(RealmResource.attrDefaultOrder), ascending: true)
        }
        else {
            allLessons = realm.objects(RealmResource.self).filter(filterPredicate)
        }
        
        return allLessons
            .map {
                ResourceModel(model: $0)
            }
    }
    
    func getFeaturedLessons(sorted: Bool) -> [ResourceModel] {
        
        let filterIsSpotlight = NSPredicate(format: "\(#keyPath(RealmResource.attrSpotlight)) == %@", NSNumber(value: true))
        
        return getAllLessons(additionalAttributeFilters: [filterIsSpotlight], sorted: sorted)
    }
}

// MARK: - Variants

extension RealmResourcesCache {
    
    func getResourceVariants(resourceId: String) -> [ResourceModel] {
        
        let filterByMetaToolId = NSPredicate(format: "\(#keyPath(RealmResource.metatoolId).appending(" = [c] %@"))", resourceId)
        let filterIsNotHidden = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterByMetaToolId, filterIsNotHidden])
        
        let realm: Realm = realmDatabase.openRealm()
        
        return realm.objects(RealmResource.self).filter(filterPredicate).map{
            ResourceModel(model: $0)
        }
    }
}
