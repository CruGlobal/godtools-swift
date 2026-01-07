//
//  DetermineDeepLinkedToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

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
    
    private var resourceNeededDownloading: DetermineToolTranslationsResourceNeeded {
        return DetermineToolTranslationsResourceNeeded.abbreviation(value: toolDeepLink.resourceAbbreviation)
    }
    
    @MainActor func getResource() -> ResourceDataModel? {
        return resourcesRepository.cache.getResource(abbreviation: toolDeepLink.resourceAbbreviation)
    }
    
    @MainActor func determineToolTranslationsToDownloadPublisher() -> AnyPublisher<DetermineToolTranslationsToDownloadResult, DetermineToolTranslationsToDownloadError> {
        
        guard let resource = getResource() else {
            return Fail(error: .failedToFetchResourceFromCache(resourceNeeded: resourceNeededDownloading))
                .eraseToAnyPublisher()
        }
        
        return getTranslationsPublisher(
            toolDeepLink: toolDeepLink,
            resource: resource
        )
        .map { (translations: [TranslationDataModel]) in
            
            let result = DetermineToolTranslationsToDownloadResult(
                translations: translations
            )
            
            return result
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor private func getTranslationsPublisher(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) -> AnyPublisher<[TranslationDataModel], DetermineToolTranslationsToDownloadError> {
        
        return Publishers.CombineLatest(
            getPrimaryTranslationPublisher(toolDeepLink: toolDeepLink, resource: resource),
            getParallelTranslationPublisher(toolDeepLink: toolDeepLink, resource: resource)
        )
        .flatMap { (primaryTranslation: TranslationDataModel?, parallelTranslation: TranslationDataModel?) -> AnyPublisher<[TranslationDataModel], DetermineToolTranslationsToDownloadError> in
            
            guard let primaryTranslation = primaryTranslation else {
                let error: DetermineToolTranslationsToDownloadError = .failedToFetchResourceFromCache(resourceNeeded: self.resourceNeededDownloading)
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            
            var translations: [TranslationDataModel] = [primaryTranslation]
            
            if let parallelTranslation = parallelTranslation{
                translations.append(parallelTranslation)
            }
            
            return Just(translations)
                .setFailureType(to: DetermineToolTranslationsToDownloadError.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor private func getPrimaryTranslationPublisher(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) -> AnyPublisher<TranslationDataModel?, Never> {
        
        return getSupportedLanguageIdsPublisher(
            resource: resource,
            languageCodes: toolDeepLink.primaryLanguageCodes
        )
        .map { (supportedPrimaryLanguageIds: [String]) in
            
            let primaryTranslation: TranslationDataModel? = self.getFirstAvailableTranslation(
                resourceId: resource.id,
                languageIds: supportedPrimaryLanguageIds
            )
            
            if let primaryTranslation = primaryTranslation {
                
                return primaryTranslation
            }
            else if let appLanguage = self.userAppLanguageRepository.getCachedLanguage(),
                    let appLanguageTranslation = self.translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: appLanguage.languageId) {
                
                return appLanguageTranslation
            }
            else if let englishTranslation = self.translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: LanguageCodeDomainModel.english.value) {
                
                return englishTranslation
            }
            
            return nil
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor private func getParallelTranslationPublisher(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) -> AnyPublisher<TranslationDataModel?, Never> {
        
        return getSupportedLanguageIdsPublisher(
            resource: resource,
            languageCodes: toolDeepLink.parallelLanguageCodes
        )
        .map { (supportedParallelLanguageIds: [String]) in
            
            let parallelTranslation: TranslationDataModel? = self.getFirstAvailableTranslation(
                resourceId: resource.id,
                languageIds: supportedParallelLanguageIds
            )
            
            return parallelTranslation
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor private func getSupportedLanguageIdsPublisher(resource: ResourceDataModel, languageCodes: [String]) -> AnyPublisher<[String], Never> {
        
        return languagesRepository
            .cache
            .getCachedLanguagesPublisher(codes: languageCodes)
            .map { (languages: [LanguageDataModel]) in
                
                let languageIds: [String] = languages.map({$0.id})
                let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
                
                return supportedLanguageIds
            }
            .catch { _ in
                return Just([])
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
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
