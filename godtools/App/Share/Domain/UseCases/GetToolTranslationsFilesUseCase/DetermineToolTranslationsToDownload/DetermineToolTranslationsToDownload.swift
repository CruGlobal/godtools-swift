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
    private let languagesRepository: LanguagesRepository
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
        
    init(resourceId: String, languageIds: [String], languagesRepository: LanguagesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.resourceId = resourceId
        self.languageIds = languageIds
        self.languagesRepository = languagesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
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
            
            guard let translation = translationsRepository.getLatestTranslation(resourceId: resourceId, languageId: languageId) else {
                return .failure(.failedToFetchTranslationFromCache)
            }
            
            translations.append(translation)
        }
        
        if translations.isEmpty,
            let defaultLanguage = languagesRepository.getLanguage(code: resource.attrDefaultLocale),
           let defaultTranslation = translationsRepository.getLatestTranslation(resourceId: resourceId, languageId: defaultLanguage.id) {
            
            translations = [defaultTranslation]
        }
    
        let result = DetermineToolTranslationsToDownloadResult(translations: translations)
        
        return .success(result)
    }
}
