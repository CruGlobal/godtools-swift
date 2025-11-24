//
//  DetermineToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

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
    
    func getResource() -> ResourceDataModel? {
        return resourcesRepository.persistence.getObject(id: resourceId)
    }
    
    func determineToolTranslationsToDownload() -> Result<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            return .failure(.failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId)))
        }
        
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
                
        var translations: [TranslationDataModel] = Array()
                
        for languageId in supportedLanguageIds {
            
            guard let translation = translationsRepository.cache.getLatestTranslation(resourceId: resourceId, languageId: languageId) else {
                return .failure(.failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId)))
            }
            
            translations.append(translation)
        }
        
        if translations.isEmpty, let defaultTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resourceId, languageCode: resource.attrDefaultLocale) {
            
            translations = [defaultTranslation]
        }
    
        let result = DetermineToolTranslationsToDownloadResult(translations: translations)
        
        return .success(result)
    }
}
