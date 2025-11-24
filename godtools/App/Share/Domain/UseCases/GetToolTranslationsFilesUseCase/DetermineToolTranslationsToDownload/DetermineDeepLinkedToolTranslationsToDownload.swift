//
//  DetermineDeepLinkedToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DetermineDeepLinkedToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface {
    
    private let toolDeepLink: ToolDeepLink
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    private let userAppLanguageRepository: UserAppLanguageRepository
        
    init(toolDeepLink: ToolDeepLink, resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository, userAppLanguageRepository: UserAppLanguageRepository) {
        
        self.toolDeepLink = toolDeepLink
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
        self.userAppLanguageRepository = userAppLanguageRepository
    }
    
    func getResource() -> ResourceDataModel? {
        return resourcesRepository.cache.getResource(abbreviation: toolDeepLink.resourceAbbreviation)
    }
    
    func determineToolTranslationsToDownload() -> Result<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            return .failure(.failedToFetchResourceFromCache(resourceNeeded: .abbreviation(value: toolDeepLink.resourceAbbreviation)))
        }
        
        guard let primaryTranslation = getPrimaryTranslation(toolDeepLink: toolDeepLink, resource: resource) else {
            return .failure(.failedToFetchResourceFromCache(resourceNeeded: .abbreviation(value: toolDeepLink.resourceAbbreviation)))
        }
        
        var translations: [TranslationDataModel] = [primaryTranslation]
        
        if let parallelTranslation = getParallelTranslation(toolDeepLink: toolDeepLink, resource: resource) {
            translations.append(parallelTranslation)
        }
        
        let result = DetermineToolTranslationsToDownloadResult(translations: translations)
        
        return .success(result)
    }
    
    private func getPrimaryTranslation(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) -> TranslationDataModel? {
        
        let supportedPrimaryLanguageIds: [String] = getSupportedLanguageIds(resource: resource, languageCodes: toolDeepLink.primaryLanguageCodes)
        
        let primaryTranslation: TranslationDataModel? = getFirstAvailableTranslation(resourceId: resource.id, languageIds: supportedPrimaryLanguageIds)
        
        if let primaryTranslation = primaryTranslation {
            
            return primaryTranslation
        }
        else if let appLanguage = userAppLanguageRepository.getCachedLanguage(), let appLanguageTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: appLanguage.languageId) {
            
            return appLanguageTranslation
        }
        else if let englishTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: LanguageCodeDomainModel.english.value) {
            
            return englishTranslation
        }
        
        return nil
    }
    
    private func getParallelTranslation(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) -> TranslationDataModel? {
        
        let supportedParallelLanguageIds: [String] = getSupportedLanguageIds(resource: resource, languageCodes: toolDeepLink.parallelLanguageCodes)
        
        let parallelTranslation: TranslationDataModel? = getFirstAvailableTranslation(resourceId: resource.id, languageIds: supportedParallelLanguageIds)
        
        if let parallelTranslation = parallelTranslation {
            return parallelTranslation
        }
        
        return nil
    }
    
    private func getSupportedLanguageIds(resource: ResourceDataModel, languageCodes: [String]) -> [String] {
        
        let languages: [LanguageDataModel] = languagesRepository.cache.getCachedLanguages(codes: languageCodes)
        let languageIds: [String] = languages.map({$0.id})
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
        
        return supportedLanguageIds
    }
    
    private func getFirstAvailableTranslation(resourceId: String, languageIds: [String]) -> TranslationDataModel? {
        
        for languageId in languageIds {
            
            guard let translation = translationsRepository.cache.getLatestTranslation(resourceId: resourceId, languageId: languageId) else {
                continue
            }
            
            return translation
        }
        
        return nil
    }
}
