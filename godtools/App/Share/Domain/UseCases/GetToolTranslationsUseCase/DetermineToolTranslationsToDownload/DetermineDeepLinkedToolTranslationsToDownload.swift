//
//  DetermineDeepLinkedToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class DetermineDeepLinkedToolTranslationsToDownload: DetermineToolTranslationsToDownloadType {
    
    private let toolDeepLink: ToolDeepLink
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let languageSettingsService: LanguageSettingsService
        
    required init(toolDeepLink: ToolDeepLink, resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, languageSettingsService: LanguageSettingsService) {
        
        self.toolDeepLink = toolDeepLink
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.languageSettingsService = languageSettingsService
    }
    
    func getResource() -> ResourceModel? {
        return resourcesRepository.getResource(abbreviation: toolDeepLink.resourceAbbreviation)
    }
    
    func determineToolTranslationsToDownload() -> AnyPublisher<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            return Fail(error: .failedToFetchResourceFromCache)
                .eraseToAnyPublisher()
        }
        
        guard let primaryTranslation = getPrimaryTranslation(toolDeepLink: toolDeepLink, resource: resource) else {
            return Fail(error: .failedToFetchTranslationFromCache)
                .eraseToAnyPublisher()
        }
        
        var translations: [TranslationModel] = [primaryTranslation]
        
        if let parallelTranslation = getParallelTranslation(toolDeepLink: toolDeepLink, resource: resource) {
            translations.append(parallelTranslation)
        }
        
        let result = DetermineToolTranslationsToDownloadResult(translations: translations)
        
        return Just(result).setFailureType(to: DetermineToolTranslationsToDownloadError.self)
            .eraseToAnyPublisher()
    }
    
    private func getPrimaryTranslation(toolDeepLink: ToolDeepLink, resource: ResourceModel) -> TranslationModel? {
        
        let supportedPrimaryLanguageIds: [String] = getSupportedLanguageIds(resource: resource, languageCodes: toolDeepLink.primaryLanguageCodes)
        
        let primaryTranslation: TranslationModel? = getFirstAvailableTranslation(resourceId: resource.id, languageIds: supportedPrimaryLanguageIds)
        
        if let primaryTranslation = primaryTranslation {
            return primaryTranslation
        }
        else if let primarySettingsLanguageId = languageSettingsService.primaryLanguage.value?.id, let primarySettingsTranslation = resourcesRepository.getResourceLanguageTranslation(resourceId: resource.id, languageId: primarySettingsLanguageId) {
            
            return primarySettingsTranslation
        }
        else if let englishTranslation = resourcesRepository.getResourceLanguageTranslation(resourceId: resource.id, languageCode: LanguageCodes.english) {
            
            return englishTranslation
        }
        
        return nil
    }
    
    private func getParallelTranslation(toolDeepLink: ToolDeepLink, resource: ResourceModel) -> TranslationModel? {
        
        let supportedParallelLanguageIds: [String] = getSupportedLanguageIds(resource: resource, languageCodes: toolDeepLink.parallelLanguageCodes)
        
        let parallelTranslation: TranslationModel? = getFirstAvailableTranslation(resourceId: resource.id, languageIds: supportedParallelLanguageIds)
        
        if let parallelTranslation = parallelTranslation {
            return parallelTranslation
        }
        
        return nil
    }
    
    private func getSupportedLanguageIds(resource: ResourceModel, languageCodes: [String]) -> [String] {
        
        let languages: [LanguageModel] = languagesRepository.getLanguages(languageCodes: languageCodes)
        let languageIds: [String] = languages.map({$0.id})
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
        
        return supportedLanguageIds
    }
    
    private func getFirstAvailableTranslation(resourceId: String, languageIds: [String]) -> TranslationModel? {
        
        for languageId in languageIds {
            
            guard let translation = resourcesRepository.getResourceLanguageTranslation(resourceId: resourceId, languageId: languageId) else {
                continue
            }
            
            return translation
        }
        
        return nil
    }
}
