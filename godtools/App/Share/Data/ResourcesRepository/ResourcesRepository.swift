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
    private let translationsRepository: TranslationsRepository
    private let languagesRepository: LanguagesRepository
    
    init(api: MobileContentResourcesApi, cache: RealmResourcesCache, attachmentsRepository: AttachmentsRepository, translationsRepository: TranslationsRepository, languagesRepository: LanguagesRepository) {
        
        self.api = api
        self.cache = cache
        self.attachmentsRepository = attachmentsRepository
        self.translationsRepository = translationsRepository
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
        
        return Publishers
            .CombineLatest(languagesRepository.syncLanguagesFromJsonFileCache(), ResourcesJsonFileCache(jsonServices: JsonServices()).getResourcesPlusLatestTranslationsAndAttachments().publisher)
            .flatMap({ (languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(languagesSyncResult: languagesSyncResult, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
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
                
                return self.cache.syncResources(languagesSyncResult: languagesSyncResult, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Spotlight Tools

extension ResourcesRepository {
    
    func getSpotlightTools() -> [ResourceModel] {
        return cache.getSpotlightTools()
    }
}

// MARK: - All Tools List

extension ResourcesRepository {
    
    func getAllToolsList(filterByCategory: String? = nil, filterByLanguageId: String? = nil, sortByDefaultOrder: Bool = true) -> [ResourceModel] {
        
        return cache.getAllToolsList(
            filterByCategory: filterByCategory,
            filterByLanguageId: filterByLanguageId,
            sortByDefaultOrder: sortByDefaultOrder
        )
    }
}

// MARK: - Lessons

extension ResourcesRepository {
    
    func getAllLessons(sorted: Bool) -> [ResourceModel] {
        return cache.getAllLessons(sorted: sorted)
    }
    
    func getFeaturedLessons(sorted: Bool) -> [ResourceModel] {
        return cache.getFeaturedLessons(sorted: sorted)
    }
}

// MARK: - Variants

extension ResourcesRepository {
    
    func getResourceVariants(resourceId: String) -> [ResourceModel] {
        
        return cache.getResourceVariants(resourceId: resourceId)
    }
}
