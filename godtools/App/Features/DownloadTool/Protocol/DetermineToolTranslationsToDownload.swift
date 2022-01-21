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
    private let dataDownloader: InitialDataDownloader
    
    let resourcesCache: ResourcesCache
    
    required init(resourceId: String, languageIds: [String], resourcesCache: ResourcesCache, dataDownloader: InitialDataDownloader) {
        
        self.resourceId = resourceId
        self.languageIds = languageIds
        self.resourcesCache = resourcesCache
        self.dataDownloader = dataDownloader
    }
    
    func getResource() -> ResourceModel? {
        return resourcesCache.getResource(id: resourceId)
    }
    
    func determineToolTranslationsToDownload() -> Result<DownloadToolLanguageTranslations, DetermineToolTranslationsToDownloadError> {
        
        guard let cachedResource = getResource() else {
            return .failure(.failedToFetchResourceFromCache)
        }
        
        var cachedLanguages: [LanguageModel] = Array()
        
        for languageId in languageIds {
            
            if let language = dataDownloader.getStoredLanguage(id: languageId) {
                cachedLanguages.append(language)
            }
            else {
                return .failure(.failedToFetchLanguageFromCache)
            }
        }
        
        return .success(DownloadToolLanguageTranslations(resource: cachedResource, languages: cachedLanguages))
    }
}
