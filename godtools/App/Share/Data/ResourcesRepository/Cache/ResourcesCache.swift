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
import SwiftData
import RepositorySync

class ResourcesCache: SwiftElseRealmPersistence<ResourceDataModel, ResourceCodable, RealmResource> {
    
    private let realmDatabase: LegacyRealmDatabase
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
        
    init(realmDatabase: LegacyRealmDatabase, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository, swiftPersistenceIsEnabled: Bool? = nil) {
        
        self.realmDatabase = realmDatabase
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmResourceDataModelMapping(),
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
        )
    }
    
    @available(iOS 17.4, *)
    override func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<ResourceDataModel, ResourceCodable>)? {
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
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
        
        if #available(iOS 17.4, *), let swiftDatabase = super.getSwiftDatabase() {
            
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

// MARK: - Filter Predicates

extension ResourcesCache {
    
    @available(iOS 17.4, *)
    private var notHiddenPredicate: Predicate<SwiftResource> {
        return #Predicate<SwiftResource> { object in
            !object.isHidden
        }
    }
    
    @available(iOS 17.4, *)
    private var isLessonPredicate: Predicate<SwiftResource> {
        
        let lessonType: String = ResourceType.lesson.rawValue
        
        return #Predicate<SwiftResource> { object in
            object.resourceType == lessonType
        }
    }
    
    @available(iOS 17.4, *)
    private var isSpotlightPredicate: Predicate<SwiftResource> {
        return #Predicate<SwiftResource> { object in
            object.attrSpotlight == true
        }
    }
    
    private var isSpotlightNSPredicate: NSPredicate {
        return NSPredicate(format: "\(#keyPath(RealmResource.attrSpotlight)) == %@", NSNumber(value: true))
    }
    
    @available(iOS 17.4, *)
    private func getLessonsPredicate(filterByLanguageId: String? = nil) -> Predicate<SwiftResource> {
        
        let filterByLanguageId: String = filterByLanguageId ?? ""

        let containsLanguagePredicate = #Predicate<SwiftResource> { resource in
            
            if !filterByLanguageId.isEmpty {
                return resource.languages.contains { language in
                    language.id == filterByLanguageId
                }
            }
            else {
                return true
            }
        }

        return #Predicate<SwiftResource> { object in
            notHiddenPredicate.evaluate(object) &&
            isLessonPredicate.evaluate(object) &&
            containsLanguagePredicate.evaluate(object)
        }
    }
    
    private func getLessonsNSPredicate(filterByLanguageId: String? = nil) -> NSPredicate {
        
        var filterByAttributes: [NSPredicate] = Array()
        
        let filterIsLessonType = NSPredicate(format: "\(#keyPath(RealmResource.resourceType)) == [c] %@", ResourceType.lesson.rawValue)
        let filterIsNotHidden = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
        
        filterByAttributes.append(filterIsLessonType)
        filterByAttributes.append(filterIsNotHidden)
        
        if let filterByLanguageId = filterByLanguageId, !filterByLanguageId.isEmpty {
            
            let filterByLanguage = NSPredicate(format: "SUBQUERY(languages, $language, $language.id == [c] \"\(filterByLanguageId)\").@count > 0")
            
            filterByAttributes.append(filterByLanguage)
        }
        
        let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterByAttributes)
        
        return filterPredicate
    }
}

// MARK: - Sort Descriptors

extension ResourcesCache {
    
    @available(iOS 17.4, *)
    private func getSortByDefaultOrderDescriptor() -> [Foundation.SortDescriptor<SwiftResource>] {
        return [SortDescriptor(\SwiftResource.attrDefaultOrder, order: .forward)]
    }
    
    private func getSortByDefaultOrderKeyPath() -> SortByKeyPath {
        return SortByKeyPath(
            keyPath: #keyPath(RealmResource.attrDefaultOrder),
            ascending: true
        )
    }
}

// MARK: - Lessons

extension ResourcesCache {
    
    @available(iOS 17.4, *)
    private func getLessonsSwiftQuery(filterByLanguageId: String?, sorted: Bool) -> SwiftDatabaseQuery<SwiftResource> {
        return SwiftDatabaseQuery(
            filter: getLessonsPredicate(filterByLanguageId: filterByLanguageId),
            sortBy: sorted ? getSortByDefaultOrderDescriptor() : nil
        )
    }
    
    private func getLessonsRealmQuery(filterByLanguageId: String?, sorted: Bool) -> RealmDatabaseQuery {
        return RealmDatabaseQuery(
            filter: getLessonsNSPredicate(filterByLanguageId: filterByLanguageId),
            sortByKeyPath: sorted ? getSortByDefaultOrderKeyPath() : nil
        )
    }
    
    func getLessonsCount(filterByLanguageId: String? = nil) -> Int {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            return swiftPersistence
                .getObjectCount(
                    query: getLessonsSwiftQuery(
                        filterByLanguageId: filterByLanguageId,
                        sorted: false
                    )
                )
        }
        else {
            
            return super.getRealmPersistence()
                .getNumberObjects(
                    query: getLessonsRealmQuery(
                        filterByLanguageId: filterByLanguageId,
                        sorted: false
                    )
                )
        }
    }
    
    func getLessons(filterByLanguageId: String? = nil, sorted: Bool = false) -> [ResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            return swiftPersistence
                .getObjects(
                    query: getLessonsSwiftQuery(
                        filterByLanguageId: filterByLanguageId,
                        sorted: sorted
                    )
                )
        }
        else {
            
            return super.getRealmPersistence()
                .getObjects(
                    query: getLessonsRealmQuery(
                        filterByLanguageId: filterByLanguageId,
                        sorted: sorted
                    )
                )
        }
    }
    
    func getFeaturedLessons(sorted: Bool = false) -> [ResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let lessonsPredicate = getLessonsPredicate()
            
            let filter = #Predicate<SwiftResource> { object in
                lessonsPredicate.evaluate(object)
                && isSpotlightPredicate.evaluate(object)
            }
            
            return swiftPersistence
                .getObjects(
                    query: SwiftDatabaseQuery(
                        filter: filter,
                        sortBy: sorted ? getSortByDefaultOrderDescriptor() : nil
                    )
                )
        }
        else {
                        
            let filter = NSCompoundPredicate(
                andPredicateWithSubpredicates: [getLessonsNSPredicate(), isSpotlightNSPredicate]
            )
            
            return super.getRealmPersistence()
                .getObjects(
                    query: RealmDatabaseQuery(
                        filter: filter,
                        sortByKeyPath: sorted ? getSortByDefaultOrderKeyPath() : nil
                    )
                )
        }
    }
    
    func getLessonsSupportedLanguageIds() -> [String] {
        
        let languageIds: [String]
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let lessons: [SwiftResource] = swiftPersistence
                .swiftDatabase
                .read.objectsNonThrowing(
                    context: swiftPersistence.swiftDatabase.openContext(),
                    query: getLessonsSwiftQuery(filterByLanguageId: nil, sorted: false)
                )
            
            languageIds = lessons
                .flatMap { $0.getLanguageIds() }
        }
        else {
            
            let realm: Realm = super.getRealmPersistence().realmDatabase.openRealm()
            
            let lessons: Results<RealmResource> = super.getRealmPersistence()
                .getPersistedObjects(
                    realm: realm,
                    query: getLessonsRealmQuery(filterByLanguageId: nil, sorted: false)
                )
            
            languageIds = lessons
                .flatMap { $0.getLanguageIds() }
        }
        
        let uniqueLanguageIds = Set(languageIds)
        
        return Array(uniqueLanguageIds)
    }
}

// MARK: - Resources

extension ResourcesCache {
    
    func getResource(abbreviation: String) -> ResourceDataModel? {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
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
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
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
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            return swiftPersistence
                .getObjects(
                    query: SwiftDatabaseQuery(
                        filter: nil,
                        sortBy: sorted ? getSortByDefaultOrderDescriptor() : nil
                    )
                )
        }
        else {
            
            return super.getRealmPersistence()
                .getObjects(
                    query: RealmDatabaseQuery(
                        filter: nil,
                        sortByKeyPath: sorted ? getSortByDefaultOrderKeyPath() : nil
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
