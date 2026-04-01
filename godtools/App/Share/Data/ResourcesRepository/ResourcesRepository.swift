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

class ResourcesRepository: RepositorySync<ResourceDataModel, MobileContentResourcesApi> {
            
    private static let syncInvalidatorIdForResourcesPlustLatestTranslationsAndAttachments: String = "resourcesPlusLatestTranslationAttachments.syncInvalidator.id"
    private static let syncedResourcesFromJsonCacheKey: String = "ResourcesRepository.synced.resources.json"
    
    private let attachmentsRepository: AttachmentsRepository
    private let languagesRepository: LanguagesRepository
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    let cache: ResourcesCache
    
    init(externalDataFetch: MobileContentResourcesApi, persistence: any Persistence<ResourceDataModel, ResourceCodable>, cache: ResourcesCache, attachmentsRepository: AttachmentsRepository, languagesRepository: LanguagesRepository, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface, userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.cache = cache
        self.attachmentsRepository = attachmentsRepository
        self.languagesRepository = languagesRepository
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        self.userDefaultsCache = userDefaultsCache
                        
        super.init(
            externalDataFetch: externalDataFetch,
            persistence: persistence
        )
    }
}

// MARK: - Cache

extension ResourcesRepository {
    
    func getCachedResourcesByFilter(filter: ResourcesFilter) -> [ResourceDataModel] {
        
        return cache.getResourcesByFilter(filter: filter)
    }
    
    func getCachedResourcesByFilterPublisher(filter: ResourcesFilter) -> AnyPublisher<[ResourceDataModel], Never> {
        
        let resources: [ResourceDataModel] = cache.getResourcesByFilter(filter: filter)
        
        return Just(resources)
            .eraseToAnyPublisher()
    }
}

// MARK: - Sync Resource

extension ResourcesRepository {
    
    func syncResourceAndLatestTranslationsPublisher(resourceId: String, requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        return externalDataFetch.getResourcePlusLatestTranslationsAndAttachmentsPublisher(id: resourceId, requestPriority: requestPriority)
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
        
        return externalDataFetch.getResourcePlusLatestTranslationsAndAttachmentsPublisher(abbreviation: resourceAbbreviation, requestPriority: requestPriority)
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
        
        return Publishers
            .CombineLatest(
                languagesRepository.syncLanguagesFromJsonFileCache(),
                ResourcesJsonFileCache(jsonServices: JsonServices()).getResourcesPlusLatestTranslationsAndAttachments().publisher
            )
            .receive(on: DispatchQueue.main)
            .flatMap { (languages: [LanguageDataModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable) -> AnyPublisher<ResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: true
                )
                .eraseToAnyPublisher()
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
                    .syncLanguagesFromRemote(requestPriority: requestPriority),
                externalDataFetch.getResourcesPlusLatestTranslationsAndAttachments(requestPriority: requestPriority)
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
        return cache.getSpotlightTools(sortByDefaultOrder: sortByDefaultOrder)
    }
}

// MARK: - All Tools List

extension ResourcesRepository {
    
    func getAllToolsList(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> [ResourceDataModel] {
        
        return cache.getAllToolsList(
            filterByCategory: filterByCategory,
            filterByLanguageId: filterByLanguageId,
            sortByDefaultOrder: sortByDefaultOrder
        )
    }
    
    func getAllToolsListCount(filterByCategory: String?, filterByLanguageId: String?) -> Int {
        
        return cache.getAllToolsListCount(filterByCategory: filterByCategory, filterByLanguageId: filterByLanguageId)
    }
    
    func getAllToolCategoryIds(filteredByLanguageId: String?) -> [String] {
        
        return cache.getAllToolCategoryIds(filteredByLanguageId: filteredByLanguageId)
    }
    
    func getAllToolLanguageIds(filteredByCategoryId: String?) -> [String] {
        
        return cache.getAllToolLanguageIds(filteredByCategoryId: filteredByCategoryId)
    }
}
