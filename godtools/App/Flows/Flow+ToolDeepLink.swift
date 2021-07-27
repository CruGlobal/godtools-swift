//
//  Flow+ToolDeepLink.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension Flow {
    
    func getDataForToolDeepLink(dataDownloader: InitialDataDownloader, resourceAbbreviation: String, primaryLanguageCodes: [String], parallelLanguageCodes: [String]) -> ToolDeepLinkData? {
        
        guard let resource = dataDownloader.resourcesCache.getResource(abbreviation: resourceAbbreviation) else {
            return nil
        }
        
        var fetchedPrimaryLanguage: LanguageModel?
        
        if let primaryLanguageFromCodes = dataDownloader.fetchFirstSupportedLanguageForResource(resource: resource, codes: primaryLanguageCodes) {
            fetchedPrimaryLanguage = primaryLanguageFromCodes
        } else if let primaryLanguageFromSettings = appDiContainer.languageSettingsService.primaryLanguage.value {
            fetchedPrimaryLanguage = primaryLanguageFromSettings
        } else {
            fetchedPrimaryLanguage = dataDownloader.getStoredLanguage(code: "en")
        }
        
        guard let primaryLanguage = fetchedPrimaryLanguage else {
            return nil
        }
        
        let parallelLanguage = dataDownloader.fetchFirstSupportedLanguageForResource(resource: resource, codes: parallelLanguageCodes)
        
        return ToolDeepLinkData(
            resource: resource,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage
        )
    }
}
