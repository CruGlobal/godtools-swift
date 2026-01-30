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
    
    private let attachmentsRepository: AttachmentsRepository
    private let languagesRepository: LanguagesRepository
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    let cache: ResourcesCache
    
    init(externalDataFetch: MobileContentResourcesApi, persistence: any Persistence<ResourceDataModel, ResourceCodable>, cache: ResourcesCache, attachmentsRepository: AttachmentsRepository, languagesRepository: LanguagesRepository, userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.cache = cache
        self.attachmentsRepository = attachmentsRepository
        self.languagesRepository = languagesRepository
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

// MARK: - Sync

extension ResourcesRepository {
    
    private var resourcesHaveBeenSynced: Bool {
        get throws {
            let languagesCount: Int = try languagesRepository.persistence.getObjectCount()
            let resourcesCount: Int = try persistence.getObjectCount()
            return languagesCount > 0 && resourcesCount > 0
        }
    }
    
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
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(requestPriority: RequestPriority, forceFetchFromRemote: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
        
        do {
            
            if try !resourcesHaveBeenSynced {
                
                return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile()
                    .map{ _ in
                        return ResourcesCacheSyncResult.emptyResult()
                    }
                    .catch { _ in
                        return self.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(
                            requestPriority: requestPriority,
                            forceFetchFromRemote: true
                        )
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            else {
                
                return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(
                    requestPriority: requestPriority,
                    forceFetchFromRemote: forceFetchFromRemote
                )
                .eraseToAnyPublisher()
            }
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile() -> AnyPublisher<ResourcesCacheSyncResult?, Error> {
                        
        do {
            
            guard try !resourcesHaveBeenSynced else {
                
                return Just(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
                    
            return Publishers
                .CombineLatest(
                    languagesRepository
                        .syncLanguagesFromJsonFileCache(),
                    ResourcesJsonFileCache(jsonServices: JsonServices())
                        .getResourcesPlusLatestTranslationsAndAttachments()
                        .publisher
                )
                .receive(on: DispatchQueue.main)
                .flatMap({ (languages: [LanguageDataModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable) -> AnyPublisher<ResourcesCacheSyncResult, Error> in
                    
                    return self.cache.syncResources(
                        resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                        shouldRemoveDataThatNoLongerExists: true
                    )
                    .eraseToAnyPublisher()
                })
                .flatMap({ resourcesCacheResult -> AnyPublisher<ResourcesCacheSyncResult?, Error> in
                    
                    return Just(resourcesCacheResult)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
            
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(requestPriority: RequestPriority, forceFetchFromRemote: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
        
        let syncInvalidator = SyncInvalidator(
            id: Self.syncInvalidatorIdForResourcesPlustLatestTranslationsAndAttachments,
            timeInterval: .hours(hour: 8),
            userDefaultsCache: userDefaultsCache
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
