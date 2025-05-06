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
        return realmDatabase.openRealm()
            .objects(RealmResource.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getResource(id: String) -> ResourceModel? {
        
        guard let realmResource = realmDatabase.openRealm()
            .object(ofType: RealmResource.self, forPrimaryKey: id) else {
            
            return nil
        }
        
        return ResourceModel(model: realmResource)
    }
    
    func getResource(abbreviation: String) -> ResourceModel? {
        
        guard let realmResource = realmDatabase.openRealm()
            .objects(RealmResource.self)
            .filter("\(#keyPath(RealmResource.abbreviation)) = '\(abbreviation)'")
            .first else {
            
            return nil
        }
        
        return ResourceModel(model: realmResource)
    }
    
    func getResources(ids: [String]) -> [ResourceModel] {
        
        return realmDatabase.openRealm()
            .objects(RealmResource.self)
            .filter("\(#keyPath(RealmResource.id)) IN %@", ids)
            .map {
                ResourceModel(model: $0)
            }
    }
    
    func getResources(sorted: Bool = false) -> [ResourceModel] {
        
        var realmResources = realmDatabase.openRealm()
            .objects(RealmResource.self)
        
        if sorted {
            realmResources = realmResources.sorted(byKeyPath: #keyPath(RealmResource.attrDefaultOrder), ascending: true)
        }
        
        return realmResources.map({ResourceModel(model: $0)})
    }
    
    func getResources(with metaToolIds: [String?]) -> [ResourceModel] {
        return realmDatabase.openRealm()
            .objects(RealmResource.self)
            .filter(NSPredicate(format: "%K IN %@", #keyPath(RealmResource.metatoolId), metaToolIds))
            .map { ResourceModel(model: $0)}
    }
    
    func getResources(with resourceType: ResourceType) -> [ResourceModel] {
        return realmDatabase.openRealm()
            .objects(RealmResource.self)
            .where { $0.resourceType == resourceType.rawValue }
            .map { ResourceModel(model: $0) }
    }
    
    func syncResources(languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel, shouldRemoveDataThatNoLongerExists: Bool) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return resourcesSync.syncResources(
            languagesSyncResult: languagesSyncResult,
            resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
            shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
        )
    }
}

// MARK: - Resources By Filter

extension RealmResourcesCache {
    
    func getResourcesByFilter(filter: ResourcesFilter) -> [ResourceModel] {
        
        return getFilteredRealmResources(realm: realmDatabase.openRealm(), filter: filter)
            .map {
                ResourceModel(model: $0)
            }
    }
    
    func getResourcesByFilterPublisher(filter: ResourcesFilter) -> AnyPublisher<[ResourceModel], Never> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let resources: [ResourceModel] = self
                    .getFilteredRealmResources(realm: realm, filter: filter)
                    .map {
                        ResourceModel(model: $0)
                    }
                
                return promise(.success(resources))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func getFilteredRealmResources(filter: ResourcesFilter) -> Results<RealmResource> {
        
        return getFilteredRealmResources(
            realm: realmDatabase.openRealm(),
            filter: filter
        )
    }
    
    private func getFilteredRealmResources(realm: Realm, filter: ResourcesFilter) -> Results<RealmResource> {
        
        var filterByAttributes: [NSPredicate] = Array()
        
        if let categoryPredicate = filter.getCategoryPredicate() {
            filterByAttributes.append(categoryPredicate)
        }
        
        if let languageCodePredicate = filter.getLanguageModelCodePredicate() {
            filterByAttributes.append(languageCodePredicate)
        }
        
        if let resourceTypesPredicate = filter.getResourceTypesPredicate() {
            filterByAttributes.append(resourceTypesPredicate)
        }
        
        if let variantsPredicate = filter.getVariantsPredicate() {
            filterByAttributes.append(variantsPredicate)
        }
        
        if let isHiddenPredicate = filter.getIsHiddenPredicate() {
            filterByAttributes.append(isHiddenPredicate)
        }
        
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterByAttributes)
                
        return realm.objects(RealmResource.self).filter(filterPredicate)
    }
}

// MARK: - Spotlight Tools

extension RealmResourcesCache {
    
    func getSpotlightTools(sortByDefaultOrder: Bool) -> [ResourceModel] {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let isSpotlightFilter = NSPredicate(format: "\(#keyPath(RealmResource.attrSpotlight)) == %@", NSNumber(value: true))
        let isNotHiddenFilter = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
        
        let isToolTypesValues: [String] = ResourceType.toolTypes.map({$0.rawValue.lowercased()})
        let isToolTypeFilter = NSPredicate(format: "\(#keyPath(RealmResource.resourceType)) IN %@", isToolTypesValues)
        
        let filterByAttributes: [NSPredicate] = [isSpotlightFilter, isNotHiddenFilter, isToolTypeFilter]
        
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterByAttributes)
                
        let filteredResources: Results<RealmResource> = realm.objects(RealmResource.self).filter(filterPredicate)
                
        let spotlightToolsResults: Results<RealmResource>
        
        if sortByDefaultOrder {
            
            spotlightToolsResults = filteredResources.sorted(byKeyPath: #keyPath(RealmResource.attrDefaultOrder), ascending: true)
        }
        else {
            
            spotlightToolsResults = filteredResources
        }
        
        return spotlightToolsResults
            .map {
                ResourceModel(model: $0)
            }
    }
}

// MARK: - All Tools List

extension RealmResourcesCache {
    
    private func getAllToolsListResults(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> Results<RealmResource> {
        
        var filterByANDSubpredicates: [NSPredicate] = Array()
        
        if let filterByCategory = filterByCategory {
            filterByANDSubpredicates.append(ResourcesFilter.getCategoryPredicate(category: filterByCategory))
        }
        
        if let filterByLanguageId = filterByLanguageId {
            filterByANDSubpredicates.append(ResourcesFilter.getLanguageModelIdPredicate(languageModelId: filterByLanguageId))
        }
        
        filterByANDSubpredicates.append(ResourcesFilter.getIsHiddenPredicate(isHidden: false))
        
        filterByANDSubpredicates.append(ResourcesFilter.getResourceTypesPredicate(resourceTypes: [.article, .chooseYourOwnAdventure, .tract]))
                
        let filterExcludingVariants: [NSPredicate] = filterByANDSubpredicates + [ResourcesFilter.getVariantsPredicate(variants: .isNotVariant)]
        
        let filterIncludingDefaultVariantOnly: [NSPredicate] = filterByANDSubpredicates + [ResourcesFilter.getVariantsPredicate(variants: .isDefaultVariant)]
            
        let filterPredicates: NSCompoundPredicate = NSCompoundPredicate(
            type: .or,
            subpredicates: [
                NSCompoundPredicate(type: .and, subpredicates: filterExcludingVariants),
                NSCompoundPredicate(type: .and, subpredicates: filterIncludingDefaultVariantOnly)
            ]
        )
        
        let filteredRealmResources: Results<RealmResource> = realmDatabase.openRealm().objects(RealmResource.self).filter(filterPredicates)
        
        let allToolsListResults: Results<RealmResource>
        
        if sortByDefaultOrder {
            
            allToolsListResults = filteredRealmResources.sorted(byKeyPath: #keyPath(RealmResource.attrDefaultOrder), ascending: true)
        }
        else {
            
            allToolsListResults = filteredRealmResources
        }
        
        return allToolsListResults
    }
    
    func getAllToolsList(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> [ResourceModel] {
                 
        return getAllToolsListResults(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId, sortByDefaultOrder: sortByDefaultOrder)
            .map {
                ResourceModel(model: $0)
            }
    }
    
    func getAllToolsListCount(filterByCategory: String?, filterByLanguageId: String?) -> Int {
                 
        return getAllToolsListResults(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId, sortByDefaultOrder: false).count
    }
    
    func getAllToolCategoryIds(filteredByLanguageId: String?) -> [String] {
        
        return getAllToolsListResults(filterByCategory: nil, filterByLanguageId: filteredByLanguageId, sortByDefaultOrder: false)
            .distinct(by: [#keyPath(RealmResource.attrCategory)])
            .map { $0.attrCategory }
    }
    
    func getAllToolLanguageIds(filteredByCategoryId: String?) -> [String] {
        
        let allLanguageIds = getAllToolsListResults(filterByCategory: filteredByCategoryId, filterByLanguageId: nil, sortByDefaultOrder: false)
            .flatMap { $0.getLanguages() }
            .map { $0.id }
        
        let uniqueLanguageIds = Set(allLanguageIds)

        return Array(uniqueLanguageIds)
    }
}

// MARK: - Lessons

extension RealmResourcesCache {
    
    func getAllLessonsResults(filterByLanguageId: String? = nil, additionalAttributeFilters: [NSPredicate]? = nil, sorted: Bool) -> Results<RealmResource> {
        var filterByAttributes: [NSPredicate] = Array()
        
        if let filterByLanguageId = filterByLanguageId {
            filterByAttributes.append(ResourcesFilter.getLanguageModelIdPredicate(languageModelId: filterByLanguageId))
        }
        
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
    }
    
    func getAllLessons(filterByLanguageId: String? = nil, additionalAttributeFilters: [NSPredicate]? = nil, sorted: Bool) -> [ResourceModel] {
        
        return getAllLessonsResults(filterByLanguageId: filterByLanguageId, additionalAttributeFilters: additionalAttributeFilters, sorted: sorted)
            .map {
                ResourceModel(model: $0)
            }
    }
    
    func getAllLessonsCount(filterByLanguageId: String?) -> Int {
                
        return getAllLessonsResults(filterByLanguageId: filterByLanguageId, sorted: false).count
    }
    
    func getAllLessonLanguageIds() -> [String] {
        
        let allLessonIds = getAllLessonsResults(sorted: false)
            .flatMap { $0.getLanguages() }
            .map { $0.id }
        
        let uniqueLanguageIds = Set(allLessonIds)
        
        return Array(uniqueLanguageIds)
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
        
        return realm.objects(RealmResource.self).filter(filterPredicate).map {
            ResourceModel(model: $0)
        }
    }
}
