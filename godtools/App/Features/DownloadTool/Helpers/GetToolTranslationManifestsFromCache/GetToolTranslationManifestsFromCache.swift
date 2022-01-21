//
//  GetToolTranslationManifestsFromCache.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolTranslationManifestsFromCache {
    
    private let dataDownloader: InitialDataDownloader
    private let resourcesCache: ResourcesCache
    private let translationsFileCache: TranslationsFileCache
    
    required init(dataDownloader: InitialDataDownloader, resourcesCache: ResourcesCache, translationsFileCache: TranslationsFileCache) {
        
        self.dataDownloader = dataDownloader
        self.resourcesCache = resourcesCache
        self.translationsFileCache = translationsFileCache
    }
    
    func getTranslationManifests(resource: ResourceModel, languages: [LanguageModel]) -> GetToolTranslationManifestsFromCacheResult {
        
        let resourceId: String = resource.id
        
        var toolTranslations: [ToolTranslationData] = Array()
        var translationIdsNeededDownloading: [String] = Array()
        
        for language in languages {
            
            guard let languageTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resourceId, languageId: language.id) else {
                continue
            }
            
            getTranslationManifest(
                resource: resource,
                language: language,
                languageTranslation: languageTranslation,
                toolTranslations: &toolTranslations,
                translationIdsNeededDownloading: &translationIdsNeededDownloading
            )
        }
        
        let shouldFallbackToEnglishLanguage: Bool = translationIdsNeededDownloading.isEmpty && toolTranslations.isEmpty
        
        if shouldFallbackToEnglishLanguage,
            let englishLanguage = dataDownloader.getStoredLanguage(code: "en"),
            let englishLanguageTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resourceId, languageId: englishLanguage.id) {
            
            getTranslationManifest(
                resource: resource,
                language: englishLanguage,
                languageTranslation: englishLanguageTranslation,
                toolTranslations: &toolTranslations,
                translationIdsNeededDownloading: &translationIdsNeededDownloading
            )
        }
                
        return GetToolTranslationManifestsFromCacheResult(
            toolTranslations: toolTranslations,
            translationIdsNeededDownloading: translationIdsNeededDownloading
        )
    }
    
    private func getTranslationManifest(resource: ResourceModel, language: LanguageModel, languageTranslation: TranslationModel, toolTranslations: inout [ToolTranslationData], translationIdsNeededDownloading: inout [String]) {
        
        let translationManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifestOnMainThread(translationId: languageTranslation.id)
        
        switch translationManifestResult {
            
        case .success(let translationManifestData):
            
            let toolTranslation: ToolTranslationData = ToolTranslationData(
                resource: resource,
                language: language,
                translation: languageTranslation,
                translationManifestData: translationManifestData
            )
            
            toolTranslations.append(toolTranslation)
            
        case .failure( _):
            translationIdsNeededDownloading.append(languageTranslation.id)
        }
    }
}
