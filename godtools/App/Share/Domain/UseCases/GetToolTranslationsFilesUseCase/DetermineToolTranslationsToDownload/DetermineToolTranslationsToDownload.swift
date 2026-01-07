//
//  DetermineToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class DetermineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface {
    
    private let resourceId: String
    private let languageIds: [String]
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
        
    init(resourceId: String, languageIds: [String], resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.resourceId = resourceId
        self.languageIds = languageIds
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    @MainActor func getResource() -> ResourceDataModel? {
        return resourcesRepository.persistence.getDataModelNonThrowing(id: resourceId)
    }
    
    @MainActor func determineToolTranslationsToDownloadPublisher() -> AnyPublisher<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            return Fail(error: .failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId)))
                .eraseToAnyPublisher()
        }
        
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
                
        var translations: [TranslationDataModel] = Array()
                
        for languageId in supportedLanguageIds {
            
            guard let translation = translationsRepository.cache.getLatestTranslation(resourceId: resourceId, languageId: languageId) else {
                return Fail(error: .failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId)))
                    .eraseToAnyPublisher()
            }
            
            translations.append(translation)
        }
        
        if translations.isEmpty, let defaultTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resourceId, languageCode: resource.attrDefaultLocale) {
            
            translations = [defaultTranslation]
        }
    
        let result = DetermineToolTranslationsToDownloadResult(translations: translations)
        
        return Just(result)
            .setFailureType(to: DetermineToolTranslationsToDownloadError.self)
            .eraseToAnyPublisher()
    }
}
