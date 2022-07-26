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
    
    func getResourcesChangedPublisher() -> NotificationCenter.Publisher {
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
    
    func getResourceLanguages(id: String) -> [LanguageModel] {
        return cache.getResourceLanguages(id: id)
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageId: String) -> TranslationModel? {
        return cache.getResourceLanguageTranslation(resourceId: resourceId, languageId: languageId)
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageCode: String) -> TranslationModel? {
        return cache.getResourceLanguageTranslation(resourceId: resourceId, languageCode: languageCode)
    }
    
    func downloadAndCacheResourcesPlusLatestAttachmentsAndTranslations() -> AnyPublisher<[ResourceModel], Error> {
        
        return self.api.getResourcesPlusLatestTranslationsAndAttachments()
            .mapError {
                $0 as Error
            }
            .flatMap({ resourcesPlusLatestTranslationsAndAttachments -> AnyPublisher<[ResourceModel], Error> in
                
                return self.storeResourcesPlusLatestAttachmentsAndTranslations(resourcesPlusLatestTranslationsAndAttachments: resourcesPlusLatestTranslationsAndAttachments)
            })
            .eraseToAnyPublisher()
    }
}

extension ResourcesRepository {
    
    private func storeResourcesPlusLatestAttachmentsAndTranslations(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<[ResourceModel], Error> {
        
        return self.translationsRepository.storeTranslations(translations: resourcesPlusLatestTranslationsAndAttachments.translations, deletesNonExisting: true)
            .flatMap({ translations -> AnyPublisher<[AttachmentModel], Error> in
                    
                return self.attachmentsRepository.storeAttachments(attachments: resourcesPlusLatestTranslationsAndAttachments.attachments, deletesNonExisting: true)
                    .eraseToAnyPublisher()
            })
            .flatMap({ attachments -> AnyPublisher<[ResourceModel], Error> in
                
                return self.cache.storeResources(resources: resourcesPlusLatestTranslationsAndAttachments.resources, deletesNonExisting: true)
                    .eraseToAnyPublisher()
            })
            .flatMap({ resources -> AnyPublisher<[ResourceModel], Error> in
                                    
                return Just(resources).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
