//
//  DetermineToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class DetermineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType {
    
    private let resourceId: String
    private let languageIds: [String]
    private let resourcesRepository: ResourcesRepository
        
    required init(resourceId: String, languageIds: [String], resourcesRepository: ResourcesRepository) {
        
        self.resourceId = resourceId
        self.languageIds = languageIds
        self.resourcesRepository = resourcesRepository
    }
    
    func getResource() -> ResourceModel? {
        return resourcesRepository.getResource(id: resourceId)
    }
    
    func determineToolTranslationsToDownload() -> AnyPublisher<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            
            return Fail(error: .failedToFetchResourceFromCache)
                .eraseToAnyPublisher()
        }
        
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
                
        var translations: [TranslationModel] = Array()
                
        for languageId in supportedLanguageIds {
            
            guard let translation = resourcesRepository.getResourceLanguageTranslation(resourceId: resourceId, languageId: languageId) else {
                return Fail(error: .failedToFetchTranslationFromCache)
                    .eraseToAnyPublisher()
            }
            
            translations.append(translation)
        }
        
        if translations.isEmpty, let englishTranslation = resourcesRepository.getResourceLanguageTranslation(resourceId: resourceId, languageCode: LanguageCodes.english) {
            
            translations = [englishTranslation]
        }
        else {
            
            return Fail(error: .failedToFetchTranslationFromCache)
                .eraseToAnyPublisher()
        }

        let result = DetermineToolTranslationsToDownloadResult(translations: translations)
        
        return Just(result).setFailureType(to: DetermineToolTranslationsToDownloadError.self)
            .eraseToAnyPublisher()
    }
}
