//
//  DetermineDeepLinkedToolTranslationsToDownload.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class DetermineDeepLinkedToolTranslationsToDownload: DetermineToolTranslationsToDownloadInterface {
    
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
    
    func getResource() -> ResourceDataModel? {
        return resourcesRepository.getResourceNonThrowing(abbreviation: toolDeepLink.resourceAbbreviation)
    }
    
    func determineToolTranslationsToDownload() async throws(DetermineToolTranslationsToDownloadError) -> ToolTranslationsToDownload {
        
        guard let resource = getResource() else {
            throw DetermineToolTranslationsToDownloadError.failedToFetchResourceFromCache(resourceNeeded: resourceNeededDownloading)
        }
        
        let translations: [TranslationDataModel] = try await getTranslations(toolDeepLink: toolDeepLink, resource: resource)
        
        return ToolTranslationsToDownload(
            translations: translations
        )
    }
    
    private func getTranslations(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) async throws(DetermineToolTranslationsToDownloadError) -> [TranslationDataModel] {
        
        do {
            
            guard let primaryTranslation = try await getPrimaryTranslation(toolDeepLink: toolDeepLink, resource: resource) else {
                throw DetermineToolTranslationsToDownloadError.failedToFetchResourceFromCache(resourceNeeded: resourceNeededDownloading)
            }
            
            var translations: [TranslationDataModel] = [primaryTranslation]
            
            if let parallelTranslation = try await getParallelTranslation(toolDeepLink: toolDeepLink, resource: resource) {
                translations.append(parallelTranslation)
            }
            
            return translations
        }
        catch let error {
            throw DetermineToolTranslationsToDownloadError.error(error: error)
        }
    }
    
    private func getPrimaryTranslation(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) async throws -> TranslationDataModel? {
        
        let supportedPrimaryLanguageIds: [String] = try await getSupportedLanguageIds(
            resource: resource,
            languageCodes: toolDeepLink.primaryLanguageCodes
        )
        
        let primaryTranslation: TranslationDataModel? = self.getFirstAvailableTranslation(
            resourceId: resource.id,
            languageIds: supportedPrimaryLanguageIds
        )
        
        if let primaryTranslation = primaryTranslation {
            
            return primaryTranslation
        }
        else if let appLanguage = self.userAppLanguageRepository.getCachedLanguage(),
                let appLanguageTranslation = self.translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: appLanguage.languageId) {
            
            return appLanguageTranslation
        }
        else if let englishTranslation = self.translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: LanguageCodeDomainModel.english.value) {
            
            return englishTranslation
        }
        
        return nil
    }
    
    private func getParallelTranslation(toolDeepLink: ToolDeepLink, resource: ResourceDataModel) async throws -> TranslationDataModel? {
        
        let supportedParallelLanguageIds: [String] = try await getSupportedLanguageIds(
            resource: resource,
            languageCodes: toolDeepLink.parallelLanguageCodes
        )
        
        let parallelTranslation: TranslationDataModel? = getFirstAvailableTranslation(
            resourceId: resource.id,
            languageIds: supportedParallelLanguageIds
        )
        
        return parallelTranslation
    }

    private func getSupportedLanguageIds(resource: ResourceDataModel, languageCodes: [String]) async throws -> [String] {
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByCodes(codes: languageCodes)
        
        let languageIds: [String] = languages.map({$0.id})
        let supportedLanguageIds: [String] = languageIds.filter({resource.supportsLanguage(languageId: $0)})
        
        return supportedLanguageIds
    }
    
    private func getFirstAvailableTranslation(resourceId: String, languageIds: [String]) -> TranslationDataModel? {
        
        for languageId in languageIds {
            
            guard let translation = translationsRepository.getLatestTranslation(resourceId: resourceId, languageId: languageId) else {
                continue
            }
            
            return translation
        }
        
        return nil
    }
}
