//
//  ResourcesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RepositorySync

final class ResourcesRepository {
            
    private static let syncInvalidatorIdForResourcesPlustLatestTranslationsAndAttachments: String = "resourcesPlusLatestTranslationAttachments.syncInvalidator.id"
    private static let syncedResourcesFromJsonCacheKey: String = "ResourcesRepository.synced.resources.json"
    
    private let api: ResourcesApiInterface
    private let jsonFileCache: ResourcesJsonFileCache
    private let cache: ResourcesCache
    private let attachmentsRepository: AttachmentsRepository
    private let languagesRepository: LanguagesRepository
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(api: ResourcesApiInterface, jsonFileCache: ResourcesJsonFileCache, cache: ResourcesCache, attachmentsRepository: AttachmentsRepository, languagesRepository: LanguagesRepository, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface, userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.api = api
        self.jsonFileCache = jsonFileCache
        self.cache = cache
        self.attachmentsRepository = attachmentsRepository
        self.languagesRepository = languagesRepository
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        self.userDefaultsCache = userDefaultsCache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getResourceNonThrowing(id: String) -> ResourceDataModel? {
        do {
            return try cache.persistence.getDataModel(id: id)
        }
        catch _ {
            return nil
        }
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getResourceNonThrowing(abbreviation: String) -> ResourceDataModel? {
        
        do {
            return try cache.getResource(abbreviation: abbreviation)
        }
        catch _ {
            return nil
        }
    }
    
    func getResource(id: String) throws -> ResourceDataModel? {
        return try cache.persistence.getDataModel(id: id)
    }
    
    func getResource(abbreviation: String) throws -> ResourceDataModel? {
        return try cache.getResource(abbreviation: abbreviation)
    }
    
    func getResourcesByIds(ids: [String]) async throws -> [ResourceDataModel] {
        return try await cache.persistence.getDataModelsAsync(getOption: .objectsByIds(ids: ids))
    }
    
    func getCachedResourcesByFilter(filter: ResourcesFilter) throws -> [ResourceDataModel] {
        return try cache.getResourcesByFilter(filter: filter)
    }
    
    func getFeaturedLessons(sorted: Bool = false) async throws -> [ResourceDataModel] {
        return try await self.cache.getFeaturedLessons(sorted: sorted)
    }
    
    func getResourceVariantsPublisher(resourceId: String) -> AnyPublisher<[ResourceDataModel], Error> {
        
        return AnyPublisher() {
            try await self.cache.getResourceVariants(resourceId: resourceId)
        }
    }
    
    func getLessonsPublisher(filterByLanguageId: String? = nil, sorted: Bool = false) -> AnyPublisher<[ResourceDataModel], Error> {
        
        return AnyPublisher() {
            try await self.cache.getLessons(filterByLanguageId: filterByLanguageId, sorted: sorted)
        }
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getLessonsCountNonThrowing(filterByLanguageId: String? = nil) -> Int {
        do {
            return try cache.getLessonsCount(filterByLanguageId: filterByLanguageId)
        }
        catch _ {
            return 0
        }
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getLessonsSupportedLanguageIdsNonThrowing() -> [String] {
        do {
            return try cache.getLessonsSupportedLanguageIds()
        }
        catch _ {
            return Array()
        }
    }
}

// MARK: - Sync Resource

extension ResourcesRepository {
    
    func syncResourceAndLatestTranslations(resourceId: String, requestPriority: RequestPriority) async throws {
     
        let resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable = try await api.getResourcePlusLatestTranslationsAndAttachments(
            id: resourceId,
            requestPriority: requestPriority
        )
        
        _ = try await cache.syncResources(
            resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
            shouldRemoveDataThatNoLongerExists: false
        )
    }
    
    func syncResourceAndLatestTranslations(resourceAbbreviation: String, requestPriority: RequestPriority) async throws {
     
        let resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable = try await api.getResourcePlusLatestTranslationsAndAttachments(
            abbreviation: resourceAbbreviation,
            requestPriority: requestPriority
        )
        
        _ = try await cache.syncResources(
            resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
            shouldRemoveDataThatNoLongerExists: false
        )
    }
}

// MARK: - Sync Resources

extension ResourcesRepository {
    
    private var syncedResourcesFromJson: Bool {
        return userDefaultsCache.getValue(key: Self.syncedResourcesFromJsonCacheKey) as? Bool ?? false
    }
    
    private func markDidSyncResourcesFromJson() {
        self.userDefaultsCache.cache(value: true, forKey: Self.syncedResourcesFromJsonCacheKey)
        self.userDefaultsCache.commitChanges()
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments(requestPriority: RequestPriority, forceFetchFromRemote: Bool) async throws -> ResourcesCacheSyncResult {
        
        _ = try await syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile()
        
        return try await syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(
            requestPriority: requestPriority,
            forceFetchFromRemote: forceFetchFromRemote
        )
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile() async throws -> ResourcesCacheSyncResult? {
        
        guard !syncedResourcesFromJson else {
            return nil
        }
                
        _ = try await languagesRepository.syncLanguagesFromJsonFileCache()
        
        let result: ResourcesCacheSyncResult = try await cache.syncResources(
            resourcesPlusLatestTranslationsAndAttachments: try jsonFileCache.getResourcesPlusLatestTranslationsAndAttachments(),
            shouldRemoveDataThatNoLongerExists: true
        )
        
        markDidSyncResourcesFromJson()
        
        return result
    }
    
    private func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(requestPriority: RequestPriority, forceFetchFromRemote: Bool) async throws -> ResourcesCacheSyncResult {
        
        let syncInvalidator = SyncInvalidator(
            id: Self.syncInvalidatorIdForResourcesPlustLatestTranslationsAndAttachments,
            timeInterval: .hours(hour: 8),
            persistence: syncInvalidatorPersistence
        )
        
        let shouldFetchFromRemote: Bool = forceFetchFromRemote || syncInvalidator.shouldSync

        guard shouldFetchFromRemote else {
            return ResourcesCacheSyncResult.emptyResult()
        }
        
        let languages: [LanguageDataModel] = try await languagesRepository.syncLanguagesFromRemote(
            requestPriority: requestPriority
        )
        
        let resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable = try await api.getResourcesPlusLatestTranslationsAndAttachments(requestPriority: requestPriority)
        
        let cacheResult: ResourcesCacheSyncResult = try await cache.syncResources(
            resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
            shouldRemoveDataThatNoLongerExists: true
        )
        
        syncInvalidator.didSync()
        
        return cacheResult
    }
}

// MARK: - Spotlight Tools

extension ResourcesRepository {
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getSpotlightToolsNonThrowing(sortByDefaultOrder: Bool = false) -> [ResourceDataModel] {
        
        do {
            return try cache.getSpotlightTools(sortByDefaultOrder: sortByDefaultOrder)
        }
        catch _ {
            return Array()
        }
    }
}

// MARK: - All Tools List

extension ResourcesRepository {
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getAllToolsListNonThrowing(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> [ResourceDataModel] {
        
        do {
            
            return try cache.getAllToolsList(
                filterByCategory: filterByCategory,
                filterByLanguageId: filterByLanguageId,
                sortByDefaultOrder: sortByDefaultOrder
            )
        }
        catch _ {
            return Array()
        }
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getAllToolsListCountNonThrowing(filterByCategory: String?, filterByLanguageId: String?) -> Int {
        
        do {
            return try cache.getAllToolsListCount(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId)
        }
        catch _ {
            return 0
        }
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getAllToolCategoryIdsNonThrowing(filteredByLanguageId: String?) -> [String] {
        
        do {
            return try cache.getAllToolCategoryIds(filteredByLanguageId: filteredByLanguageId)
        }
        catch _ {
            return Array()
        }
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getAllToolLanguageIdsNonThrowing(filteredByCategoryId: String?) -> [String] {
        
        do {
            return try cache.getAllToolLanguageIds(filteredByCategoryId: filteredByCategoryId)
        }
        catch _ {
            return Array()
        }
    }
}
