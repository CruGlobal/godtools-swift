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

class ResourcesCache {
    
    private let persistence: any Persistence<ResourceDataModel, ResourceCodable>
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
        
    init(persistence: any Persistence<ResourceDataModel, ResourceCodable>, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository) {
        
        self.persistence = persistence
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
    }

    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>? {
        return persistence as? SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<ResourceDataModel, ResourceCodable, RealmResource>? {
        return persistence as? RealmRepositorySyncPersistence<ResourceDataModel, ResourceCodable, RealmResource>
    }
    
    func syncResources(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable, shouldRemoveDataThatNoLongerExists: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            return SwiftResourcesCacheSync(
                swiftDatabase: swiftPersistence.database,
                trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository
            )
            .syncResources(
                resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
            )
            .eraseToAnyPublisher()
        }
        else if let realmPersistence = getRealmPersistence() {
            
            return RealmResourcesCacheSync(
                realmDatabase: realmPersistence.database,
                trackDownloadedTranslationsRepository: trackDownloadedTranslationsRepository
            )
            .syncResources(
                resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
            )
            .eraseToAnyPublisher()
        }
        else {
            
            return Just(ResourcesCacheSyncResult.emptyResult())
                .setFailureType(to: Error.self)
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
            
            let query = getLessonsSwiftQuery(filterByLanguageId: filterByLanguageId, sorted: false)
            
            let count: Int = try swiftPersistence.database.read.objectCountNonThrowing(context: swiftPersistence.database.openContext(), query: query)
            
            return count
        }
        else if let realmPersistence = getRealmPersistence(), let realm = realmPersistence.database.openRealmNonThrowing() {
            
            let query = getLessonsRealmQuery(filterByLanguageId: filterByLanguageId, sorted: false)
            
            let results: Results<RealmResource> = try realmPersistence.database.read.results(realm: realm, query: query)
            
            return results.count
        }
        else {
            
            return 0
        }
    }
    
    func getLessonsPublisher(filterByLanguageId: String? = nil, sorted: Bool = false) -> AnyPublisher<[ResourceDataModel], Error> {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = getLessonsSwiftQuery(filterByLanguageId: filterByLanguageId, sorted: sorted)
            
            return swiftPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = getLessonsRealmQuery(filterByLanguageId: filterByLanguageId, sorted: sorted)
            
            return realmPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else {
            
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func getFeaturedLessonsPublisher(sorted: Bool = false) -> AnyPublisher<[ResourceDataModel], Error> {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let lessonsPredicate = getLessonsPredicate()
            
            let filter = #Predicate<SwiftResource> { object in
                lessonsPredicate.evaluate(object)
                && isSpotlightPredicate.evaluate(object)
            }
            
            let query = SwiftDatabaseQuery(
                filter: filter,
                sortBy: sorted ? getSortByDefaultOrderDescriptor() : nil
            )
            
            return swiftPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
                        
            let filter = NSCompoundPredicate(
                andPredicateWithSubpredicates: [getLessonsNSPredicate(), isSpotlightNSPredicate]
            )
            
            let query = RealmDatabaseQuery(
                filter: filter,
                sortByKeyPath: sorted ? getSortByDefaultOrderKeyPath() : nil
            )
            
            return realmPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else {
            
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func getLessonsSupportedLanguageIds() -> [String] {
        
        let languageIds: [String]
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query: SwiftDatabaseQuery<SwiftResource> = getLessonsSwiftQuery(filterByLanguageId: nil, sorted: false)
            
            let context: ModelContext = swiftPersistence.database.openContext()
            
            let lessons: [SwiftResource] = swiftPersistence
                .database
                .read.objectsNonThrowing(
                    context: context,
                    query: query
                )
            
            languageIds = lessons
                .flatMap { $0.getLanguageIds() }
        }
        else if let realmPersistence = getRealmPersistence(), let realm = realmPersistence.database.openRealmNonThrowing() {
            
            let query: RealmDatabaseQuery = getLessonsRealmQuery(filterByLanguageId: nil, sorted: false)
            
            let lessons: Results<RealmResource> = realmPersistence
                .database
                .read.results(
                    realm: realm,
                    query: query
                )
            
            languageIds = lessons
                .flatMap { $0.getLanguageIds() }
        }
        else {
            
            languageIds = []
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
            
            let query = SwiftDatabaseQuery.filter(filter: filter)
            
            let resources: [SwiftResource] = swiftPersistence.database.read.objectsNonThrowing(
                context: swiftPersistence.database.openContext(),
                query: query
            )
            
            guard let resource = resources.first else {
                return nil
            }
            
            return ResourceDataModel(interface: resource)
        }
        else if let realmPersistence = getRealmPersistence(), let realm = realmPersistence.database.openRealmNonThrowing() {
            
            let filter = NSPredicate(format: "\(#keyPath(RealmResource.abbreviation)) = '\(abbreviation)'")
            
            let query = RealmDatabaseQuery.filter(filter: filter)
            
            let resources: [RealmResource] = realmPersistence.database.read.objects(
                realm: realm,
                query: query
            )
            
            guard let resource = resources.first else {
                return nil
            }
            
            return ResourceDataModel(interface: resource)
        }
        else {
            
            return nil
        }
    }
    
    func getResourceVariantsPublisher(resourceId: String) -> AnyPublisher<[ResourceDataModel], Error> {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftResource> { object in
                object.metatoolId == resourceId && !object.isHidden
            }
            
            let query = SwiftDatabaseQuery.filter(filter: filter)
            
            return swiftPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let filterByMetaToolId = NSPredicate(format: "\(#keyPath(RealmResource.metatoolId).appending(" = [c] %@"))", resourceId)
            let filterIsNotHidden = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
            let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterByMetaToolId, filterIsNotHidden])
                   
            let query = RealmDatabaseQuery(filter: filterPredicate, sortByKeyPath: nil)
            
            return realmPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else {
            
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func getResourcesPublisher(sorted: Bool = false) -> AnyPublisher<[ResourceDataModel], Error> {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = SwiftDatabaseQuery(
                filter: nil,
                sortBy: sorted ? getSortByDefaultOrderDescriptor() : nil
            )
            
            return swiftPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery(
                filter: nil,
                sortByKeyPath: sorted ? getSortByDefaultOrderKeyPath() : nil
            )
            
            return realmPersistence
                .getDataModelsPublisher(getOption: .allObjects, query: query)
        }
        else {
            
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Resources By Filter

extension ResourcesCache {
    
    func getResourcesByFilter(filter: ResourcesFilter) -> [ResourceDataModel] {
        
        guard let realmPersistence = getRealmPersistence(), let realm = realmPersistence.database.openRealmNonThrowing() else {
            return Array()
        }
        
        return getFilteredRealmResources(realm: realm, filter: filter)
            .map {
                ResourceDataModel(interface: $0)
            }
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
        
        guard let realm = realmDatabase?.openRealmNonThrowing() else {
            return []
        }
                
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
    
    private func getAllToolsListResults(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> Results<RealmResource>? {
        
        guard let realm = realmDatabase?.openRealmNonThrowing() else {
            return nil
        }
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
        
        let filteredRealmResources: Results<RealmResource> = realm.objects(RealmResource.self).filter(filterPredicates)
        
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
                 
        guard let allToolsListResults = getAllToolsListResults(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId, sortByDefaultOrder: sortByDefaultOrder) else {
            return Array()
        }
        
        return allToolsListResults
            .map {
                ResourceDataModel(interface: $0)
            }
    }
    
    func getAllToolsListCount(filterByCategory: String?, filterByLanguageId: String?) -> Int {
                 
        guard let allToolsListResults = getAllToolsListResults(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId, sortByDefaultOrder: false) else {
            return 0
        }
        
        return allToolsListResults.count
    }
    
    func getAllToolCategoryIds(filteredByLanguageId: String?) -> [String] {
        
        guard let allToolsListResults = getAllToolsListResults(filterByCategory: nil, filterByLanguageId: filteredByLanguageId, sortByDefaultOrder: false) else {
            return Array()
        }
        
        return allToolsListResults
            .distinct(by: [#keyPath(RealmResource.attrCategory)])
            .map { $0.attrCategory }
    }
    
    func getAllToolLanguageIds(filteredByCategoryId: String?) -> [String] {
        
        guard let allToolsListResults = getAllToolsListResults(filterByCategory: filteredByCategoryId, filterByLanguageId: nil, sortByDefaultOrder: false) else {
            return Array()
        }
        
        let allLanguageIds = allToolsListResults
            .flatMap { $0.getLanguages() }
            .map { $0.id }
        
        let uniqueLanguageIds = Set(allLanguageIds)

        return Array(uniqueLanguageIds)
    }
}

