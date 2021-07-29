//
//  ToolDeepLinkResources.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolDeepLinkResources {
    
    let resource: ResourceModel
    let primaryLanguage: LanguageModel
    let parallelLanguage: LanguageModel?
    
    init?(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, toolDeepLink: ToolDeepLink) {
        
        guard let cachedResource = dataDownloader.resourcesCache.getResource(abbreviation: toolDeepLink.resourceAbbreviation) else {
            return nil
        }
        
        var cachedPrimaryLanguage: LanguageModel?
        
        if let primaryLanguageFromCodes = dataDownloader.fetchFirstSupportedLanguageForResource(resource: cachedResource, codes: toolDeepLink.primaryLanguageCodes) {
            cachedPrimaryLanguage = primaryLanguageFromCodes
        } else if let primaryLanguageFromSettings = languageSettingsService.primaryLanguage.value {
            cachedPrimaryLanguage = primaryLanguageFromSettings
        } else {
            cachedPrimaryLanguage = dataDownloader.getStoredLanguage(code: "en")
        }
        
        guard let primaryLanguage = cachedPrimaryLanguage else {
            return nil
        }
        
        self.resource = cachedResource
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = dataDownloader.fetchFirstSupportedLanguageForResource(resource: cachedResource, codes: toolDeepLink.parallelLanguageCodes)
    }
}
