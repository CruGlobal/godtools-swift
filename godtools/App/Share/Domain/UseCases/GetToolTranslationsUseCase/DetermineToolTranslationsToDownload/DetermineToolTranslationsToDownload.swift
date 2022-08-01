//
//  DetermineToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

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
    
    func determineToolTranslationsToDownload() -> Result<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            return .failure(.failedToFetchResourceFromCache)
        }
        
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
                
        var translations: [TranslationModel] = Array()
                
        for languageId in supportedLanguageIds {
            
            guard let translation = resourcesRepository.getResourceLanguageTranslation(resourceId: resourceId, languageId: languageId) else {
                return .failure(.failedToFetchTranslationFromCache)
            }
            
            translations.append(translation)
        }
        
        if translations.isEmpty, let englishTranslation = resourcesRepository.getResourceLanguageTranslation(resourceId: resourceId, languageCode: LanguageCodes.english) {
            
            translations = [englishTranslation]
        }
        else {
            
            return .failure(.failedToFetchTranslationFromCache)
        }

        let result = DetermineToolTranslationsToDownloadResult(translations: translations)
        
        return .success(result)
    }
}
