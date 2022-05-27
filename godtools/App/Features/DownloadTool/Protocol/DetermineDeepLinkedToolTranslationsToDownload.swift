//
//  DetermineDeepLinkedToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DetermineDeepLinkedToolTranslationsToDownload: DetermineToolTranslationsToDownloadType {
    
    private let toolDeepLink: ToolDeepLink
    private let dataDownloader: InitialDataDownloader
    private let languagesRepository: LanguagesRepository
    private let languageSettingsService: LanguageSettingsService
    
    let resourcesCache: ResourcesCache
    
    required init(toolDeepLink: ToolDeepLink, resourcesCache: ResourcesCache, dataDownloader: InitialDataDownloader, languagesRepository: LanguagesRepository, languageSettingsService: LanguageSettingsService) {
        
        self.toolDeepLink = toolDeepLink
        self.resourcesCache = resourcesCache
        self.dataDownloader = dataDownloader
        self.languagesRepository = languagesRepository
        self.languageSettingsService = languageSettingsService
    }
    
    func getResource() -> ResourceModel? {
        return resourcesCache.getResource(abbreviation: toolDeepLink.resourceAbbreviation)
    }
    
    func determineToolTranslationsToDownload() -> Result<DownloadToolLanguageTranslations, DetermineToolTranslationsToDownloadError> {
        
        guard let cachedResource = getResource() else {
            return .failure(.failedToFetchResourceFromCache)
        }
        
        let cachedPrimaryLanguage: LanguageModel?
        
        if let primaryLanguageFromCodes = fetchFirstSupportedLanguageForResource(resource: cachedResource, codes: toolDeepLink.primaryLanguageCodes) {
            
            cachedPrimaryLanguage = primaryLanguageFromCodes
        }
        else if let primaryLanguageFromSettings = languageSettingsService.primaryLanguage.value {
            
            cachedPrimaryLanguage = primaryLanguageFromSettings
        }
        else {
            
            cachedPrimaryLanguage = languagesRepository.getLanguage(code: "en")
        }
        
        let cachedParallelLanguage: LanguageModel? = fetchFirstSupportedLanguageForResource(resource: cachedResource, codes: toolDeepLink.parallelLanguageCodes)
        
        var languageTranslationsToDownload: [LanguageModel] = Array()
        
        if let cachedPrimaryLanguage = cachedPrimaryLanguage {
            languageTranslationsToDownload.append(cachedPrimaryLanguage)
        }
        
        if let cachedParallelLanguage = cachedParallelLanguage {
            languageTranslationsToDownload.append(cachedParallelLanguage)
        }
        
        let toolLanguageTranslations: DownloadToolLanguageTranslations = DownloadToolLanguageTranslations(
            resource: cachedResource,
            languages: languageTranslationsToDownload
        )
        
        return .success(toolLanguageTranslations)
    }
    
    private func fetchFirstSupportedLanguageForResource(resource: ResourceModel, codes: [String]) -> LanguageModel? {
        for code in codes {
            if let language = languagesRepository.getLanguage(code: code), resource.supportsLanguage(languageId: language.id) {
                return language
            }
        }
        
        return nil
    }
}
