//
//  ResourcesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class ResourcesRepository {
        
    private static var didSyncResourcesFromJsonFileCache: Bool = false
    
    private let api: MobileContentResourcesApi
    private let cache: RealmResourcesCache
    private let attachmentsRepository: AttachmentsRepository
    private let languagesRepository: LanguagesRepository
    
    init(api: MobileContentResourcesApi, cache: RealmResourcesCache, attachmentsRepository: AttachmentsRepository, languagesRepository: LanguagesRepository) {
        
        self.api = api
        self.cache = cache
        self.attachmentsRepository = attachmentsRepository
        self.languagesRepository = languagesRepository
    }
    
    var numberOfResources: Int {
        return cache.numberOfResources
    }
    
    func getResourcesChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.getResourcesChangedPublisher()
    }
    
    func getResource(id: String) -> ResourceModel? {
        return cache.getResource(id: id)
    }
    
    func getResource(abbreviation: String) -> ResourceModel? {
        return cache.getResource(abbreviation: abbreviation)
    }
    
    func getResources(ids: [String]) -> [ResourceModel] {
        return cache.getResources(ids: ids)
    }
    
    func getResources(with metaToolIds: [String?]) -> [ResourceModel] {
        return cache.getResources(with: metaToolIds)
    }
    
    func getResources(with resourceType: ResourceType) -> [ResourceModel] {
        return cache.getResources(with: resourceType)
    }
    
    func getCachedResourcesByFilter(filter: ResourcesFilter) -> [ResourceModel] {
        
        return cache.getResourcesByFilter(filter: filter)
    }
    
    func getCachedResourcesByFilterPublisher(filter: ResourcesFilter) -> AnyPublisher<[ResourceModel], Never> {
        
        return cache.getResourcesByFilterPublisher(filter: filter)
            .eraseToAnyPublisher()
    }
    
    func syncResourceAndLatestTranslationsPublisher(resourceId: String) -> AnyPublisher<Void, Error> {
        
        return api.getResourcePlusLatestTranslationsAndAttachmentsPublisher(id: resourceId)
            .flatMap({ (resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<Void, Error> in
                
                let languagesSyncResult = RealmLanguagesCacheSyncResult(languagesRemoved: [])
                
                return self.cache.syncResources(
                    languagesSyncResult: languagesSyncResult,
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
    
    func syncResourceAndLatestTranslationsPublisher(resourceAbbreviation: String) -> AnyPublisher<Void, Error> {
        
        return api.getResourcePlusLatestTranslationsAndAttachmentsPublisher(abbreviation: resourceAbbreviation)
            .flatMap({ (resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<Void, Error> in
                
                let languagesSyncResult = RealmLanguagesCacheSyncResult(languagesRemoved: [])
                
                return self.cache.syncResources(
                    languagesSyncResult: languagesSyncResult,
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
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments() -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFileIfNeeded()
            .map({ result in
                    
                return RealmResourcesCacheSyncResult(
                    languagesSyncResult: RealmLanguagesCacheSyncResult(languagesRemoved: []),
                    resourcesRemoved: [],
                    translationsRemoved: [],
                    attachmentsRemoved: [],
                    downloadedTranslationsRemoved: []
                )
            })
            .catch({ (error: Error) in
                return self.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote()
                    .eraseToAnyPublisher()
            })
            .flatMap({ syncedResourcesFromFileCacheResults -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                                
                return self.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsIgnoringErrorPublisher() -> AnyPublisher<RealmResourcesCacheSyncResult, Never> {
        
        return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
            .catch({ _ in
                
                let emptyResult = RealmResourcesCacheSyncResult(
                    languagesSyncResult: RealmLanguagesCacheSyncResult(languagesRemoved: []),
                    resourcesRemoved: [],
                    translationsRemoved: [],
                    attachmentsRemoved: [],
                    downloadedTranslationsRemoved: []
                )
                
                return Just(emptyResult)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFileIfNeeded() -> AnyPublisher<RealmResourcesCacheSyncResult?, Error> {
        
        guard !ResourcesRepository.didSyncResourcesFromJsonFileCache else {
            return Just(nil).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        ResourcesRepository.didSyncResourcesFromJsonFileCache = true
        
        guard languagesRepository.numberOfLanguages == 0 && cache.numberOfResources == 0 else {
            return Just(nil).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile()
            .eraseToAnyPublisher()
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFile() -> AnyPublisher<RealmResourcesCacheSyncResult?, Error> {
        
        return Publishers
            .CombineLatest(
                languagesRepository.syncLanguagesFromJsonFileCache(),
                ResourcesJsonFileCache(jsonServices: JsonServices()).getResourcesPlusLatestTranslationsAndAttachments().publisher
            )
            .flatMap({ (languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(
                    languagesSyncResult: languagesSyncResult,
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: true
                )
                .eraseToAnyPublisher()
            })
            .flatMap({ resourcesCacheResult -> AnyPublisher<RealmResourcesCacheSyncResult?, Error> in
                
                return Just(resourcesCacheResult).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote() -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return Publishers
            .CombineLatest(languagesRepository.syncLanguagesFromRemote(), api.getResourcesPlusLatestTranslationsAndAttachments())
            .flatMap({ (languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(
                    languagesSyncResult: languagesSyncResult,
                    resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments,
                    shouldRemoveDataThatNoLongerExists: true
                )
                .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Spotlight Tools

extension ResourcesRepository {
    
    func getSpotlightTools(sortByDefaultOrder: Bool = false) -> [ResourceModel] {
        return cache.getSpotlightTools(sortByDefaultOrder: sortByDefaultOrder)
    }
}

// MARK: - All Tools List

extension ResourcesRepository {
    
    func getAllToolsList(filterByCategory: String?, filterByLanguageId: String?, sortByDefaultOrder: Bool) -> [ResourceModel] {
        
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
    
    func getAllLessons(filterByLanguageId: String? = nil, sorted: Bool) -> [ResourceModel] {
        return cache.getAllLessons(
            filterByLanguageId: filterByLanguageId,
            sorted: sorted
        )
    }
    
    func getAllLessonsCount(filterByLanguageId: String?) -> Int {
        return cache.getAllLessonsCount(filterByLanguageId: filterByLanguageId)
    }
    
    func getFeaturedLessons(sorted: Bool) -> [ResourceModel] {
        return cache.getFeaturedLessons(sorted: sorted)
    }
    
    func getAllLessonLanguageIds() -> [String] {
        return cache.getAllLessonLanguageIds()
    }
}

// MARK: - Variants

extension ResourcesRepository {
    
    func getResourceVariants(resourceId: String) -> [ResourceModel] {
        
        return cache.getResourceVariants(resourceId: resourceId)
    }
}
