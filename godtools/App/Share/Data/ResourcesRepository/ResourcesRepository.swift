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
    
    private let api: MobileContentResourcesApi
    private let jsonFileCache: ResourcesJsonFileCache
    private let cache: ResourcesCache
    private let attachmentsRepository: AttachmentsRepository
    private let languagesRepository: LanguagesRepository
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(api: MobileContentResourcesApi, jsonFileCache: ResourcesJsonFileCache, cache: ResourcesCache, attachmentsRepository: AttachmentsRepository, languagesRepository: LanguagesRepository, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface, userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.api = api
        self.jsonFileCache = jsonFileCache
        self.cache = cache
        self.attachmentsRepository = attachmentsRepository
        self.languagesRepository = languagesRepository
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        self.userDefaultsCache = userDefaultsCache
    }
    
    var persistence: any Persistence<ResourceDataModel, ResourceCodable> {
        return cache.persistence
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
    }
    
    func getResource(id: String) -> ResourceDataModel? {
        do {
            return try cache.persistence.getDataModel(id: id)
        }
        catch _ {
            return nil
        }
    }
    
    func getResource(abbreviation: String) -> ResourceDataModel? {
        
        do {
            return try cache.getResource(abbreviation: abbreviation)
        }
        catch _ {
            return nil
        }
    }
    
    func getCachedResourcesByFilter(filter: ResourcesFilter) -> [ResourceDataModel] {
        
        do {
            return try cache.getResourcesByFilter(filter: filter)
        }
        catch _ {
            return Array()
        }
    }
    
    func getCachedResourcesByFilterPublisher(filter: ResourcesFilter) -> AnyPublisher<[ResourceDataModel], Never> {
        
        do {
            
            let resources: [ResourceDataModel] = try cache.getResourcesByFilter(filter: filter)
            
            return Just(resources)
                .eraseToAnyPublisher()
        }
        catch _ {
            return Just(Array())
                .eraseToAnyPublisher()
        }
    }
    
    func getFeaturedLessonsPublisher(sorted: Bool = false) -> AnyPublisher<[ResourceDataModel], Error> {
        
        return AnyPublisher() {
            try await self.cache.getFeaturedLessons(sorted: sorted)
        }
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
    
    func getLessonsCount(filterByLanguageId: String? = nil) -> Int {
        do {
            return try cache.getLessonsCount(filterByLanguageId: filterByLanguageId)
        }
        catch _ {
            return 0
        }
    }
    
    func getLessonsSupportedLanguageIds() -> [String] {
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
    
    func syncResourceAndLatestTranslationsPublisher(resourceId: String, requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        return api.getResourcePlusLatestTranslationsAndAttachmentsPublisher(id: resourceId, requestPriority: requestPriority)
            .flatMap({ (resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable) -> AnyPublisher<Void, Error> in
                                
                return self.cache.syncResources(
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: false
                )
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func syncResourceAndLatestTranslationsPublisher(resourceAbbreviation: String, requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        return api.getResourcePlusLatestTranslationsAndAttachmentsPublisher(abbreviation: resourceAbbreviation, requestPriority: requestPriority)
            .flatMap({ (resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable) -> AnyPublisher<Void, Error> in
                                
                return self.cache.syncResources(
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: false
                )
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
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
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(requestPriority: RequestPriority, forceFetchFromRemote: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
        
        return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile()
            .setFailureType(to: Error.self)
            .flatMap { (result: ResourcesCacheSyncResult?) -> AnyPublisher<ResourcesCacheSyncResult, Error> in
                
                return self.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(
                    requestPriority: requestPriority,
                    forceFetchFromRemote: forceFetchFromRemote
                )
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile() -> AnyPublisher<ResourcesCacheSyncResult?, Never> {
                        
        guard !syncedResourcesFromJson else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return languagesRepository
            .syncLanguagesFromJsonFileCachePublisher()
            .receive(on: DispatchQueue.main)
            .flatMap { (languages: [LanguageDataModel]) -> AnyPublisher<ResourcesCacheSyncResult, Error> in
                
                do {
                                        
                    return self.cache.syncResources(
                        resourcesPlusLatestTranslationsAndAttachments: try self.jsonFileCache.getResourcesPlusLatestTranslationsAndAttachments(),
                        shouldRemoveDataThatNoLongerExists: true
                    )
                    .eraseToAnyPublisher()
                }
                catch let error {
                    
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .map { (result: ResourcesCacheSyncResult) in
                
                self.markDidSyncResourcesFromJson()
                
                return result
            }
            .catch { (error: Error) in
                
                self.markDidSyncResourcesFromJson()
                
                return Just<ResourcesCacheSyncResult?>(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(requestPriority: RequestPriority, forceFetchFromRemote: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
        
        let syncInvalidator = SyncInvalidator(
            id: Self.syncInvalidatorIdForResourcesPlustLatestTranslationsAndAttachments,
            timeInterval: .hours(hour: 8),
            persistence: syncInvalidatorPersistence
        )
        
        let shouldFetchFromRemote: Bool = forceFetchFromRemote || syncInvalidator.shouldSync

        guard shouldFetchFromRemote else {
            return Just(ResourcesCacheSyncResult.emptyResult())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Publishers
            .CombineLatest(
                languagesRepository
                    .syncLanguagesFromRemotePublisher(requestPriority: requestPriority),
                api.getResourcesPlusLatestTranslationsAndAttachments(requestPriority: requestPriority)
            )
            .receive(on: DispatchQueue.main)
            .flatMap({ (languages: [LanguageDataModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable) -> AnyPublisher<ResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: true
                )
                .map { (cacheResult: ResourcesCacheSyncResult) in
                    syncInvalidator.didSync()
                    return cacheResult
                }
                .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Spotlight Tools

extension ResourcesRepository {
    
    func getSpotlightTools(sortByDefaultOrder: Bool = false) -> [ResourceDataModel] {
        
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
    
    func getAllToolsList(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> [ResourceDataModel] {
        
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
    
    func getAllToolsListCount(filterByCategory: String?, filterByLanguageId: String?) -> Int {
        
        do {
            return try cache.getAllToolsListCount(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId)
        }
        catch _ {
            return 0
        }
    }
    
    func getAllToolCategoryIds(filteredByLanguageId: String?) -> [String] {
        
        do {
            return try cache.getAllToolCategoryIds(filteredByLanguageId: filteredByLanguageId)
        }
        catch _ {
            return Array()
        }
    }
    
    func getAllToolLanguageIds(filteredByCategoryId: String?) -> [String] {
        
        do {
            return try cache.getAllToolLanguageIds(filteredByCategoryId: filteredByCategoryId)
        }
        catch _ {
            return Array()
        }
    }
}
