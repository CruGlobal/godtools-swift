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
    
    func getResourcesChanged() -> AnyPublisher<Void, Never> {
        return cache.getResourcesChanged()
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
    
    func getResourceLanguages(id: String) -> [LanguageModel] {
        return cache.getResourceLanguages(id: id)
    }
    
    func getResourceLanguageLatestTranslation(resourceId: String, languageId: String) -> TranslationModel? {
        return cache.getResourceLanguageLatestTranslation(resourceId: resourceId, languageId: languageId)
    }
    
    func getResourceLanguageLatestTranslation(resourceId: String, languageCode: String) -> TranslationModel? {
        return cache.getResourceLanguageLatestTranslation(resourceId: resourceId, languageCode: languageCode)
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments() -> AnyPublisher<RealmResourcesCacheSyncResult, URLResponseError> {
        
        return syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFileIfNeeded()
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .flatMap({ syncedResourcesFromFileCacheResults -> AnyPublisher<RealmResourcesCacheSyncResult, URLResponseError> in
                                
                return self.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote()
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
            .CombineLatest(languagesRepository.syncLanguagesFromJsonFileCache(), ResourcesJsonFileCache().getResourcesPlusLatestTranslationsAndAttachments().publisher)
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
    
    private func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote() -> AnyPublisher<RealmResourcesCacheSyncResult, URLResponseError> {
        
        return Publishers
            .CombineLatest(languagesRepository.syncLanguagesFromRemote(), api.getResourcesPlusLatestTranslationsAndAttachments())
            .flatMap({ (languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, URLResponseError> in
                
                return self.cache.syncResources(languagesSyncResult: languagesSyncResult, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
                    .mapError { error in
                        return .otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
