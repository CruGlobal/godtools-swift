//
//  DetermineToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class DetermineToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface {
    
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
        return resourcesRepository.getResourceNonThrowing(id: resourceId)
    }
    
    func determineToolTranslationsToDownload() async throws(DetermineToolTranslationsToDownloadError) -> ToolTranslationsToDownload {
        
        guard let resource = getResource() else {
            throw .failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId))
        }
        
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
                
        var translations: [TranslationDataModel] = Array()
                
        for languageId in supportedLanguageIds {
            
            guard let translation = translationsRepository.getLatestTranslation(resourceId: resourceId, languageId: languageId) else {
                throw .failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId))
            }
            
            translations.append(translation)
        }
        
        if translations.isEmpty, let defaultTranslation = translationsRepository.getLatestTranslation(resourceId: resourceId, languageCode: resource.attrDefaultLocale) {
            
            translations = [defaultTranslation]
        }
    
        return ToolTranslationsToDownload(translations: translations)
    }
    
    func determineToolTranslationsToDownloadPublisher() -> AnyPublisher<ToolTranslationsToDownload, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            return Fail(error: .failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId)))
                .eraseToAnyPublisher()
        }
        
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
                
        var translations: [TranslationDataModel] = Array()
                
        for languageId in supportedLanguageIds {
            
            guard let translation = translationsRepository.getLatestTranslation(resourceId: resourceId, languageId: languageId) else {
                return Fail(error: .failedToFetchResourceFromCache(resourceNeeded: .id(value: resourceId)))
                    .eraseToAnyPublisher()
            }
            
            translations.append(translation)
        }
        
        if translations.isEmpty, let defaultTranslation = translationsRepository.getLatestTranslation(resourceId: resourceId, languageCode: resource.attrDefaultLocale) {
            
            translations = [defaultTranslation]
        }
    
        let result = ToolTranslationsToDownload(translations: translations)
        
        return Just(result)
            .setFailureType(to: DetermineToolTranslationsToDownloadError.self)
            .eraseToAnyPublisher()
    }
}
