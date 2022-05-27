//
//  GetToolTranslationsFromCache.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolTranslationsFromCache {
    
    private let resourcesCache: ResourcesCache
    private let languagesRepository: LanguagesRepository
    private let translationsFileCache: TranslationsFileCache
    
    required init(resourcesCache: ResourcesCache, languagesRepository: LanguagesRepository, translationsFileCache: TranslationsFileCache) {
        
        self.resourcesCache = resourcesCache
        self.languagesRepository = languagesRepository
        self.translationsFileCache = translationsFileCache
    }
    
    func getTranslations(resource: ResourceModel, languages: [LanguageModel]) -> GetToolTranslationsFromCacheResult {
        
        let resourceId: String = resource.id
        
        var toolTranslations: [ToolTranslation] = Array()
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
            let englishLanguage = languagesRepository.getLanguage(code: "en"),
            let englishLanguageTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resourceId, languageId: englishLanguage.id) {
            
            getTranslationManifest(
                resource: resource,
                language: englishLanguage,
                languageTranslation: englishLanguageTranslation,
                toolTranslations: &toolTranslations,
                translationIdsNeededDownloading: &translationIdsNeededDownloading
            )
        }
                
        return GetToolTranslationsFromCacheResult(
            toolTranslations: toolTranslations,
            translationIdsNeededDownloading: translationIdsNeededDownloading
        )
    }
    
    private func getTranslationManifest(resource: ResourceModel, language: LanguageModel, languageTranslation: TranslationModel, toolTranslations: inout [ToolTranslation], translationIdsNeededDownloading: inout [String]) {
        
        let translationManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslation(translationId: languageTranslation.id)
        
        switch translationManifestResult {
            
        case .success(let translationManifestData):
            
            let toolTranslation: ToolTranslation = ToolTranslation(
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
