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

class ResourcesRepository: RepositorySync<ResourceDataModel, MobileContentResourcesApi, RealmResource> {
            
    private static let syncInvalidatorIdForResourcesPlustLatestTranslationsAndAttachments: String = "resourcesPlusLatestTranslationAttachments.syncInvalidator.id"
    
    private let api: MobileContentResourcesApi
    private let cache: RealmResourcesCache
    private let attachmentsRepository: AttachmentsRepository
    private let languagesRepository: LanguagesRepository
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(api: MobileContentResourcesApi, realmDatabase: RealmDatabase, cache: RealmResourcesCache, attachmentsRepository: AttachmentsRepository, languagesRepository: LanguagesRepository, userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.api = api
        self.cache = cache
        self.attachmentsRepository = attachmentsRepository
        self.languagesRepository = languagesRepository
        self.userDefaultsCache = userDefaultsCache
        
        super.init(
            externalDataFetch: api,
            realmDatabase: realmDatabase,
            dataModelMapping: ResourcesDataModelMapping()
        )
    }
    
    func getResource(abbreviation: String) -> ResourceDataModel? {
        return getCachedObjects(
            databaseQuery: RepositorySyncDatabaseQuery.filter(
                filter: NSPredicate(format: "\(#keyPath(RealmResource.abbreviation)) = '\(abbreviation)'")
            )
        )
        .first
    }
    
    func getCachedResourcesByFilter(filter: ResourcesFilter) -> [ResourceDataModel] {
        
        return cache.getResourcesByFilter(filter: filter)
    }
    
    func getCachedResourcesByFilterPublisher(filter: ResourcesFilter) -> AnyPublisher<[ResourceDataModel], Never> {
        
        return cache.getResourcesByFilterPublisher(filter: filter)
            .eraseToAnyPublisher()
    }
    
    func syncResourceAndLatestTranslationsPublisher(resourceId: String, requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        return api.getResourcePlusLatestTranslationsAndAttachmentsPublisher(id: resourceId, requestPriority: requestPriority)
            .flatMap({ (resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<Void, Error> in
                                
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
            .flatMap({ (resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<Void, Error> in
                                
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
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsPublisher(requestPriority: RequestPriority, forceFetchFromRemote: Bool) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        let resourcesHaveBeenSynced: Bool = getResourcesHaveBeenSynced()
        
        if !resourcesHaveBeenSynced {
            
            return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile()
                .map{ _ in
                    return RealmResourcesCacheSyncResult.emptyResult()
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
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile() -> AnyPublisher<RealmResourcesCacheSyncResult?, Error> {
                
        let resourcesHaveBeenSynced: Bool = getResourcesHaveBeenSynced()
        
        guard !resourcesHaveBeenSynced else {
            
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
                
        return Publishers
            .CombineLatest(
                languagesRepository
                    .syncLanguagesFromJsonFileCache()
                    .setFailureType(to: Error.self),
                ResourcesJsonFileCache(jsonServices: JsonServices())
                    .getResourcesPlusLatestTranslationsAndAttachments()
                    .publisher
            )
            .flatMap({ (languagesResponse: RepositorySyncResponse<LanguageDataModel>, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: true
                )
                .eraseToAnyPublisher()
            })
            .flatMap({ resourcesCacheResult -> AnyPublisher<RealmResourcesCacheSyncResult?, Error> in
                
                return Just(resourcesCacheResult)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getResourcesHaveBeenSynced() -> Bool {
        return languagesRepository.numberOfCachedObjects > 0 && numberOfCachedObjects > 0
    }
    
    private func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote(requestPriority: RequestPriority, forceFetchFromRemote: Bool) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        let syncInvalidator = SyncInvalidator(
            id: Self.syncInvalidatorIdForResourcesPlustLatestTranslationsAndAttachments,
            timeInterval: .hours(hour: 8),
            userDefaultsCache: userDefaultsCache
        )
        
        let shouldFetchFromRemote: Bool = forceFetchFromRemote || syncInvalidator.shouldSync

        guard shouldFetchFromRemote else {
            return Just(RealmResourcesCacheSyncResult.emptyResult())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Publishers
            .CombineLatest(
                languagesRepository
                    .syncLanguagesFromRemote(requestPriority: requestPriority)
                    .setFailureType(to: Error.self),
                api.getResourcesPlusLatestTranslationsAndAttachments(requestPriority: requestPriority)
            )
            .flatMap({ (languagesResponse: RepositorySyncResponse<LanguageDataModel>, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: true
                )
                .map { (cacheResult: RealmResourcesCacheSyncResult) in
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

// MARK: - Lessons

extension ResourcesRepository {
    
    func getAllLessons(filterByLanguageId: String? = nil, sorted: Bool) -> [ResourceDataModel] {
        return cache.getAllLessons(
            filterByLanguageId: filterByLanguageId,
            sorted: sorted
        )
    }
    
    func getAllLessonsCount(filterByLanguageId: String?) -> Int {
        return cache.getAllLessonsCount(filterByLanguageId: filterByLanguageId)
    }
    
    func getFeaturedLessons(sorted: Bool) -> [ResourceDataModel] {
        return cache.getFeaturedLessons(sorted: sorted)
    }
    
    func getAllLessonLanguageIds() -> [String] {
        return cache.getAllLessonLanguageIds()
    }
}

// MARK: - Variants

extension ResourcesRepository {
    
    func getResourceVariants(resourceId: String) -> [ResourceDataModel] {
        
        return cache.getResourceVariants(resourceId: resourceId)
    }
}
