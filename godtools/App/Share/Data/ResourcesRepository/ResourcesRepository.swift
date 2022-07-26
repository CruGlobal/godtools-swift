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
        
        _ = syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromJsonFileIfNeeded()
    }
    
    func getResourcesSyncedPublisher() -> NotificationCenter.Publisher {
        return cache.getResourcesSyncedPublisher()
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
    
    func getResourceLanguages(id: String) -> [LanguageModel] {
        return cache.getResourceLanguages(id: id)
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageId: String) -> TranslationModel? {
        return cache.getResourceLanguageTranslation(resourceId: resourceId, languageId: languageId)
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageCode: String) -> TranslationModel? {
        return cache.getResourceLanguageTranslation(resourceId: resourceId, languageCode: languageCode)
    }
    
    func syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote() -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
        
        return Publishers
            .CombineLatest(languagesRepository.syncLanguagesFromRemote(), getResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote())
            .flatMap({ (languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> in
                
                return self.cache.syncResources(languagesSyncResult: languagesSyncResult, resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
            })
            .eraseToAnyPublisher()
    }
}

extension ResourcesRepository {
    
    private func getResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote() -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        return self.api.getResourcesPlusLatestTranslationsAndAttachments()
            .mapError {
                $0 as Error
            }
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
}
