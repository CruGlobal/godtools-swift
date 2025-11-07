//
//  ResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class ResourcesCache: SwiftElseRealmPersistence<ResourceDataModel, ResourceCodable, RealmResource> {
    
    private let realmDatabase: RealmDatabase
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
        
    init(realmDatabase: RealmDatabase, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository) {
        
        self.realmDatabase = realmDatabase
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmResourceDataModelMapping()
        )
    }
    
    @available(iOS 17, *)
    override func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<ResourceDataModel, ResourceCodable>)? {
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17, *)
    private func getSwiftPersistence(swiftDatabase: SwiftDatabase) -> SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftResourceDataModelMapping()
        )
    }
    
    func syncResources(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable, shouldRemoveDataThatNoLongerExists: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
        
        if #available(iOS 17, *), let swiftDatabase = TempSharedSwiftDatabase.shared.swiftDatabase {
            
            return SwiftResourcesCacheSync(
                swiftDatabase: swiftDatabase,
                trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository
            )
            .syncResources(
                resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
            )
            .eraseToAnyPublisher()
        }
        else {
            
            return RealmResourcesCacheSync(
                realmDatabase: realmDatabase,
                trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository
            )
            .syncResources(
                resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
            )
            .eraseToAnyPublisher()
        }
    }
}

// MARK: - Lessons

extension ResourcesCache {
    
    func getLessons(sorted: Bool = false) -> [ResourceDataModel] {
        
        if #available(iOS 17, *), let swiftPersistence = getSwiftPersistence() {
                        
            let lessonType: String = ResourceType.lesson.rawValue
            
            let filter = #Predicate<SwiftResource> { object in
                !object.isHidden && object.resourceType == lessonType
            }
            
            return swiftPersistence
                .getObjects(
                    query: SwiftDatabaseQuery(
                        filter: filter,
                        sortBy: sorted ? getSwiftSortByDefaultOrder() : nil
                    )
                )
        }
        else {

            let filterIsNotHidden = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
            
            let filterIsLessonType = NSPredicate(format: "\(#keyPath(RealmResource.resourceType)) == [c] %@", ResourceType.lesson.rawValue)
            
            return super.getRealmPersistence()
                .getObjects(
                    query: RealmDatabaseQuery(
                        filter: NSCompoundPredicate(type: .and, subpredicates: [filterIsNotHidden, filterIsLessonType]),
                        sortByKeyPath: sorted ? getRealmSortByDefaultOrder() : nil
                    )
                )
        }
    }
}

// MARK: - Query

extension ResourcesCache {
    
    @available(iOS 17, *)
    private func getSwiftSortByDefaultOrder() -> [Foundation.SortDescriptor<SwiftResource>] {
        return [SortDescriptor(\SwiftResource.attrDefaultOrder, order: .forward)]
    }
    
    private func getRealmSortByDefaultOrder() -> SortByKeyPath {
        return SortByKeyPath(
            keyPath: #keyPath(RealmResource.attrDefaultOrder),
            ascending: true
        )
    }
    
    func getResource(abbreviation: String) -> ResourceDataModel? {
        
        if #available(iOS 17, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftResource> { object in
                object.abbreviation == abbreviation
            }
            
            return swiftPersistence
                .getObjects(query: SwiftDatabaseQuery.filter(filter: filter))
                .first
        }
        else {
            
            let filter = NSPredicate(format: "\(#keyPath(RealmResource.abbreviation)) = '\(abbreviation)'")
            
            return super.getRealmPersistence()
                .getObjects(query: RealmDatabaseQuery.filter(filter: filter))
                .first
        }
    }
    
    func getResourceVariants(resourceId: String) -> [ResourceDataModel] {
        
        if #available(iOS 17, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftResource> { object in
                object.metatoolId == resourceId && !object.isHidden
            }
            
            return swiftPersistence.getObjects(query: SwiftDatabaseQuery.filter(filter: filter))
        }
        else {
            
            let filterByMetaToolId = NSPredicate(format: "\(#keyPath(RealmResource.metatoolId).appending(" = [c] %@"))", resourceId)
            let filterIsNotHidden = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
            let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterByMetaToolId, filterIsNotHidden])
            
            let realm: Realm = realmDatabase.openRealm()
            
            return realm.objects(RealmResource.self)
                .filter(filterPredicate).map {
                    ResourceDataModel(interface: $0)
                }
        }
    }
    
    func getResources(sorted: Bool = false) -> [ResourceDataModel] {
        
        if #available(iOS 17, *), let swiftPersistence = getSwiftPersistence() {
            
            return swiftPersistence
                .getObjects(
                    query: SwiftDatabaseQuery(
                        filter: nil,
                        sortBy: sorted ? getSwiftSortByDefaultOrder() : nil
                    )
                )
        }
        else {
            
            return super.getRealmPersistence()
                .getObjects(
                    query: RealmDatabaseQuery(
                        filter: nil,
                        sortByKeyPath: sorted ? getRealmSortByDefaultOrder() : nil
                    )
                )
        }
    }
}

// MARK: - Resources By Filter

extension ResourcesCache {
    
    func getResourcesByFilter(filter: ResourcesFilter) -> [ResourceDataModel] {
        
        return getFilteredRealmResources(realm: realmDatabase.openRealm(), filter: filter)
            .map {
                ResourceDataModel(interface: $0)
            }
    }
    
    func getResourcesByFilterPublisher(filter: ResourcesFilter) -> AnyPublisher<[ResourceDataModel], Never> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let resources: [ResourceDataModel] = self
                    .getFilteredRealmResources(realm: realm, filter: filter)
                    .map {
                        ResourceDataModel(interface: $0)
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

extension ResourcesCache {
    
    func getSpotlightTools(sortByDefaultOrder: Bool) -> [ResourceDataModel] {
        
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
                ResourceDataModel(interface: $0)
            }
    }
}

// MARK: - All Tools List

extension ResourcesCache {
    
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
    
    func getAllToolsList(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> [ResourceDataModel] {
                 
        return getAllToolsListResults(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId, sortByDefaultOrder: sortByDefaultOrder)
            .map {
                ResourceDataModel(interface: $0)
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

extension ResourcesCache {
    
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
    
    func getAllLessons(filterByLanguageId: String? = nil, additionalAttributeFilters: [NSPredicate]? = nil, sorted: Bool) -> [ResourceDataModel] {
        
        return getAllLessonsResults(filterByLanguageId: filterByLanguageId, additionalAttributeFilters: additionalAttributeFilters, sorted: sorted)
            .map {
                ResourceDataModel(interface: $0)
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
    
    func getFeaturedLessons(sorted: Bool) -> [ResourceDataModel] {
        
        let filterIsSpotlight = NSPredicate(format: "\(#keyPath(RealmResource.attrSpotlight)) == %@", NSNumber(value: true))
        
        return getAllLessons(additionalAttributeFilters: [filterIsSpotlight], sorted: sorted)
    }
}
