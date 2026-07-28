//
//  ResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class ResourcesCache {
    
    private let realmDatabase: RealmDatabase
    private let realmDataWrite: RealmDataWrite
    private let resourcesCacheSync: ResourcesCacheSyncInterface
    
    let persistence: any Persistence<ResourceDataModel, ResourceCodable>
    
    init(
        persistence: any Persistence<ResourceDataModel, ResourceCodable>,
        realmDatabase: RealmDatabase,
        realmDataWrite: RealmDataWrite,
        resourcesCacheSync: ResourcesCacheSyncInterface
    ) {
        
        self.persistence = persistence
        self.realmDatabase = realmDatabase
        self.realmDataWrite = realmDataWrite
        self.resourcesCacheSync = resourcesCacheSync
    }

    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>? {
        return persistence as? SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<ResourceDataModel, ResourceCodable, RealmResource>? {
        return persistence as? RealmRepositorySyncPersistence<ResourceDataModel, ResourceCodable, RealmResource>
    }
}

// MARK: - Sync

extension ResourcesCache {
    
    func syncResources(
        resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable,
        shouldRemoveDataThatNoLongerExists: Bool
    ) async throws -> ResourcesCacheSyncResult {
        
        return try await resourcesCacheSync
            .syncResources(
                resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                shouldRemoveDataThatNoLongerExists: shouldRemoveDataThatNoLongerExists
            )
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

    @available(iOS 17.4, *)
    private var isToolTypePredicate: Predicate<SwiftResource> {

        let toolTypes: [String] = ResourceType.toolTypes.map { $0.rawValue }

        return #Predicate<SwiftResource> { object in
            toolTypes.contains(object.resourceType)
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
    
    @available(iOS 17.4, *)
    private func getResourcesByLanguageCodePredicate(languageCode: BCP47LanguageIdentifier, resourceTypes: [ResourceType]) -> Predicate<SwiftResource> {

        let filterByResourceTypes: [String] = resourceTypes.map { $0.rawValue }

        let containsLanguagePredicate = #Predicate<SwiftResource> { resource in

            resource.languages.contains { language in
                language.code == languageCode
            }
        }

        let isResourceTypePredicate = #Predicate<SwiftResource> { resource in

            if !filterByResourceTypes.isEmpty {
                return filterByResourceTypes.contains(resource.resourceType)
            }
            else {
                return true
            }
        }

        return #Predicate<SwiftResource> { object in
            notHiddenPredicate.evaluate(object) &&
            isResourceTypePredicate.evaluate(object) &&
            containsLanguagePredicate.evaluate(object)
        }
    }

    private func getLessonsNSPredicate(filterByLanguageId: String?) -> NSPredicate {
        
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
    
    func getLessonsCount(filterByLanguageId: String?) throws -> Int {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = getLessonsSwiftQuery(filterByLanguageId: filterByLanguageId, sorted: false)
            
            let count: Int = try swiftPersistence.database.read.objectCount(context: swiftPersistence.database.openContext(), query: query)
            
            return count
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let realm = try realmPersistence.database.openRealm()
            
            let query = getLessonsRealmQuery(filterByLanguageId: filterByLanguageId, sorted: false)
            
            let results: Results<RealmResource> = realmPersistence.database.read.results(realm: realm, query: query)
            
            return results.count
        }
        
        return 0
    }
    
    func getLessons(filterByLanguageId: String?, sorted: Bool) async throws -> [ResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = getLessonsSwiftQuery(filterByLanguageId: filterByLanguageId, sorted: sorted)
            
            return try await swiftPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = getLessonsRealmQuery(filterByLanguageId: filterByLanguageId, sorted: sorted)
            
            return try await realmPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        
        return Array()
    }
    
    func getFeaturedLessons(sorted: Bool) async throws -> [ResourceDataModel] {
        
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
            
            return try await swiftPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
                        
            let filter = NSCompoundPredicate(
                andPredicateWithSubpredicates: [getLessonsNSPredicate(filterByLanguageId: nil), isSpotlightNSPredicate]
            )
            
            let query = RealmDatabaseQuery(
                filter: filter,
                sortByKeyPath: sorted ? getSortByDefaultOrderKeyPath() : nil
            )
            
            return try await realmPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        
        return Array()
    }
    
    func getLessonsSupportedLanguageIds() throws -> [String] {
        
        let languageIds: [String]
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query: SwiftDatabaseQuery<SwiftResource> = getLessonsSwiftQuery(filterByLanguageId: nil, sorted: false)
            
            let context: ModelContext = swiftPersistence.database.openContext()
            
            let lessons: [SwiftResource] = try swiftPersistence
                .database
                .read.objects(
                    context: context,
                    query: query
                )
            
            languageIds = lessons
                .flatMap { $0.getLanguageIds() }
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let realm = try realmPersistence.database.openRealm()
            
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
    
    func getResource(abbreviation: String) throws -> ResourceDataModel? {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftResource> { object in
                object.abbreviation == abbreviation
            }
            
            let query = SwiftDatabaseQuery.filter(filter: filter)
            
            let resources: [SwiftResource] = try swiftPersistence.database.read.objects(
                context: swiftPersistence.database.openContext(),
                query: query
            )
            
            guard let resource = resources.first else {
                return nil
            }
            
            return resource.toModel()
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let realm = try realmPersistence.database.openRealm()
            
            let filter = NSPredicate(format: "\(#keyPath(RealmResource.abbreviation)) = '\(abbreviation)'")
            
            let query = RealmDatabaseQuery.filter(filter: filter)
            
            let resources: [RealmResource] = realmPersistence.database.read.objects(
                realm: realm,
                query: query
            )
            
            guard let resource = resources.first else {
                return nil
            }
            
            return resource.toModel()
        }
        else {
            
            return nil
        }
    }
    
    func getResourceVariants(resourceId: String) async throws -> [ResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let filter = #Predicate<SwiftResource> { object in
                object.metatoolId == resourceId && !object.isHidden
            }
            
            let query = SwiftDatabaseQuery.filter(filter: filter)
            
            return try await swiftPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let filterByMetaToolId = NSPredicate(format: "\(#keyPath(RealmResource.metatoolId).appending(" = [c] %@"))", resourceId)
            let filterIsNotHidden = NSPredicate(format: "\(#keyPath(RealmResource.isHidden)) == %@", NSNumber(value: false))
            let filterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterByMetaToolId, filterIsNotHidden])
                   
            let query = RealmDatabaseQuery(filter: filterPredicate, sortByKeyPath: nil)
            
            return try await realmPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        
        return Array()
    }
    
    func getResources(sorted: Bool) async throws -> [ResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = SwiftDatabaseQuery(
                filter: nil,
                sortBy: sorted ? getSortByDefaultOrderDescriptor() : nil
            )
            
            return try await swiftPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery(
                filter: nil,
                sortByKeyPath: sorted ? getSortByDefaultOrderKeyPath() : nil
            )
            
            return try await realmPersistence
                .newActorRead()
                .getDataModels(query: query)
        }
        
        return Array()
    }
    
    @available(iOS 17.4, *)
    private func getResourcesByLanguageCodeSwiftQuery(languageCode: BCP47LanguageIdentifier, resourceTypes: [ResourceType]) -> SwiftDatabaseQuery<SwiftResource> {
        return SwiftDatabaseQuery.filter(
            filter: getResourcesByLanguageCodePredicate(languageCode: languageCode, resourceTypes: resourceTypes)
        )
    }

    func getResources(
        languageCode: BCP47LanguageIdentifier,
        resourceTypes: [ResourceType]
    ) throws -> [ResourceDataModel] {

        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {

            let query = getResourcesByLanguageCodeSwiftQuery(languageCode: languageCode, resourceTypes: resourceTypes)

            let resources: [SwiftResource] = try swiftPersistence.database.read.objects(
                context: swiftPersistence.database.openContext(),
                query: query
            )

            return resources
                .map {
                    $0.toModel()
                }
        }
        else {
                
            let filter = ResourcesFilter(
                languageModelCode: languageCode,
                resourceTypes: resourceTypes
            )

            return try getResourcesByFilter(filter: filter)
        }
    }

    func getNumberOfResourcesAvailable(
        languageCode: BCP47LanguageIdentifier,
        resourceTypes: [ResourceType]
    ) throws -> Int {

        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {

            let query = getResourcesByLanguageCodeSwiftQuery(languageCode: languageCode, resourceTypes: resourceTypes)

            return try swiftPersistence.database.read.objectCount(
                context: swiftPersistence.database.openContext(),
                query: query
            )
        }
        else {
            
            let filter = ResourcesFilter(
                category: nil,
                languageModelCode: languageCode,
                resourceTypes: resourceTypes
            )

            return try getResourcesByFilter(filter: filter).count
        }
    }
}

// MARK: - Resources By Filter

extension ResourcesCache {
    
    private func getResourcesByFilter(filter: ResourcesFilter) throws -> [ResourceDataModel] {
        
        guard let realmPersistence = getRealmPersistence() else {
            return Array()
        }
        
        let realm = try realmPersistence.database.openRealm()
        
        return getFilteredRealmResources(realm: realm, filter: filter)
            .map {
                $0.toModel()
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
    
    func getSpotlightTools(sortByDefaultOrder: Bool) throws -> [ResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {

            let filter = #Predicate<SwiftResource> { object in
                notHiddenPredicate.evaluate(object)
                && isSpotlightPredicate.evaluate(object)
                && isToolTypePredicate.evaluate(object)
            }

            let query = SwiftDatabaseQuery(
                filter: filter,
                sortBy: sortByDefaultOrder ? getSortByDefaultOrderDescriptor() : nil
            )

            let spotlightTools: [SwiftResource] = try swiftPersistence.database.read.objects(
                context: swiftPersistence.database.openContext(),
                query: query
            )

            return spotlightTools
                .map {
                    $0.toModel()
                }
        }
        else if let realmPersistence = getRealmPersistence() {

            let realmDatabase = realmPersistence.database
            
            let realm = try realmDatabase.openRealm()
                    
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
                    $0.toModel()
                }
        }
        
        return Array()
    }
}

// MARK: - All Tools List

extension ResourcesCache {

    @available(iOS 17.4, *)
    private func getAllToolsListPredicate(filterByCategory: String?, filterByLanguageId: String?) -> Predicate<SwiftResource> {

        let filterByCategory: String = (filterByCategory ?? "").lowercased()
        let filterByLanguageId: String = filterByLanguageId ?? ""
        let toolTypes: [String] = ResourceType.toolTypes.map { $0.rawValue }

        return #Predicate<SwiftResource> { object in

            !object.isHidden
            && toolTypes.contains(object.resourceType)
            && (filterByCategory.isEmpty || object.attrCategory == filterByCategory)
            && (filterByLanguageId.isEmpty || object.languages.contains { language in
                language.id == filterByLanguageId
            })
        }
    }

    @available(iOS 17.4, *)
    private func getAllToolsListSwiftQuery(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> SwiftDatabaseQuery<SwiftResource> {
        return SwiftDatabaseQuery(
            filter: getAllToolsListPredicate(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId),
            sortBy: sortByDefaultOrder ? getSortByDefaultOrderDescriptor() : nil
        )
    }

    @available(iOS 17.4, *)
    private func getAllToolsListSwiftResources(
        swiftPersistence: SwiftRepositorySyncPersistence<ResourceDataModel, ResourceCodable, SwiftResource>,
        filterByCategory: String?,
        filterByLanguageId: String?,
        sortByDefaultOrder: Bool
    ) throws -> [SwiftResource] {

        let query = getAllToolsListSwiftQuery(
            filterByCategory: filterByCategory,
            filterByLanguageId: filterByLanguageId,
            sortByDefaultOrder: sortByDefaultOrder
        )

        return try swiftPersistence.database.read.objects(
            context: swiftPersistence.database.openContext(),
            query: query
        )
    }

    private func getAllToolsListResults(
        realmDatabase: RealmDatabase,
        filterByCategory: String?,
        filterByLanguageId: String?,
        sortByDefaultOrder: Bool
    ) throws -> Results<RealmResource> {
        
        let realm = try realmDatabase.openRealm()
        
        var filters: [NSPredicate] = Array()
        
        if let filterByCategory = filterByCategory {
            filters.append(ResourcesFilter.getCategoryPredicate(category: filterByCategory))
        }
        
        if let filterByLanguageId = filterByLanguageId {
            filters.append(ResourcesFilter.getLanguageModelIdPredicate(languageModelId: filterByLanguageId))
        }
        
        filters.append(ResourcesFilter.getIsHiddenPredicate(isHidden: false))
        
        filters.append(ResourcesFilter.getResourceTypesPredicate(resourceTypes: [.article, .chooseYourOwnAdventure, .tract]))
        
        let filterByANDPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: filters)
                
        let filteredRealmResources: Results<RealmResource> = realm
            .objects(RealmResource.self)
            .filter(filterByANDPredicate)
        
        let allToolsListResults: Results<RealmResource>
        
        if sortByDefaultOrder {
            
            allToolsListResults = filteredRealmResources.sorted(byKeyPath: #keyPath(RealmResource.attrDefaultOrder), ascending: true)
        }
        else {
            
            allToolsListResults = filteredRealmResources
        }
        
        return allToolsListResults
    }
    
    func getAllToolsList(
        filterByCategory: String?,
        filterByLanguageId: String?,
        sortByDefaultOrder: Bool
    ) throws -> [ResourceDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {

            let allToolsListResults = try getAllToolsListSwiftResources(
                swiftPersistence: swiftPersistence,
                filterByCategory: filterByCategory,
                filterByLanguageId: filterByLanguageId,
                sortByDefaultOrder: sortByDefaultOrder
            )

            return allToolsListResults
                .map {
                    $0.toModel()
                }
        }
        else if let realmPersistence = getRealmPersistence() {

            let allToolsListResults = try getAllToolsListResults(
                realmDatabase: realmPersistence.database,
                filterByCategory: filterByCategory,
                filterByLanguageId: filterByLanguageId,
                sortByDefaultOrder: sortByDefaultOrder
            )

            return allToolsListResults
                .map {
                    $0.toModel()
                }
        }

        return Array()
    }

    func getAllToolsListCount(filterByCategory: String?, filterByLanguageId: String?) throws -> Int {

        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {

            let query = getAllToolsListSwiftQuery(
                filterByCategory: filterByCategory,
                filterByLanguageId: filterByLanguageId,
                sortByDefaultOrder: false
            )

            return try swiftPersistence.database.read.objectCount(
                context: swiftPersistence.database.openContext(),
                query: query
            )
        }
        else if let realmPersistence = getRealmPersistence() {

            let allToolsListResults = try getAllToolsListResults(
                realmDatabase: realmPersistence.database,
                filterByCategory: filterByCategory,
                filterByLanguageId: filterByLanguageId,
                sortByDefaultOrder: false
            )

            return allToolsListResults.count
        }

        return 0
    }

    func getAllToolCategoryIds(filteredByLanguageId: String?) throws -> [String] {

        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {

            let allToolsListResults = try getAllToolsListSwiftResources(
                swiftPersistence: swiftPersistence,
                filterByCategory: nil,
                filterByLanguageId: filteredByLanguageId,
                sortByDefaultOrder: false
            )

            let uniqueCategoryIds = Set(allToolsListResults.map { $0.attrCategory })

            return Array(uniqueCategoryIds)
        }
        else if let realmPersistence = getRealmPersistence() {

            let allToolsListResults = try getAllToolsListResults(
                realmDatabase: realmPersistence.database,
                filterByCategory: nil,
                filterByLanguageId: filteredByLanguageId,
                sortByDefaultOrder: false
            )

            return allToolsListResults
                .distinct(by: [#keyPath(RealmResource.attrCategory)])
                .map { $0.attrCategory }
        }

        return Array()
    }

    func getAllToolLanguageIds(filteredByCategoryId: String?) throws -> [String] {

        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {

            let allToolsListResults = try getAllToolsListSwiftResources(
                swiftPersistence: swiftPersistence,
                filterByCategory: filteredByCategoryId,
                filterByLanguageId: nil,
                sortByDefaultOrder: false
            )

            let allLanguageIds = allToolsListResults
                .flatMap { $0.getLanguageIds() }

            let uniqueLanguageIds = Set(allLanguageIds)

            return Array(uniqueLanguageIds)
        }
        else if let realmPersistence = getRealmPersistence() {

            let allToolsListResults = try getAllToolsListResults(
                realmDatabase: realmPersistence.database,
                filterByCategory: filteredByCategoryId,
                filterByLanguageId: nil,
                sortByDefaultOrder: false
            )

            let allLanguageIds = allToolsListResults
                .flatMap { $0.getLanguages() }
                .map { $0.id }

            let uniqueLanguageIds = Set(allLanguageIds)

            return Array(uniqueLanguageIds)
        }

        return Array()
    }
}

