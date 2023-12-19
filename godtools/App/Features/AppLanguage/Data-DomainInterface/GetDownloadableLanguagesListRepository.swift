//
//  GetDownloadableLanguagesListRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDownloadableLanguagesListRepository: GetDownloadableLanguagesListRepositoryInterface {
    
    private let appLanguagesRepository: AppLanguagesRepository
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServices
    
    init(appLanguagesRepository: AppLanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, resourcesRepository: ResourcesRepository, localizationServices: LocalizationServices) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
    }
    
    func getDownloadableLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            appLanguagesRepository.getLanguagesChangedPublisher(),
            downloadedLanguagesRepository.getDownloadedLanguagesChangedPublisher()
        )
        .flatMap { _ in
            
            return self.appLanguagesRepository.getLanguagesPublisher()
        }
        .map { appLanguages in
            
            return appLanguages.map { appLanguage in
                
                let languageId = appLanguage.languageId
                
                let languageNameInOwnLanguage = self.getTranslatedLanguageName.getLanguageName(
                    language: appLanguage,
                    translatedInLanguage: appLanguage.languageId
                )
                let languageNameInAppLanguage = self.getTranslatedLanguageName.getLanguageName(
                    language: appLanguage,
                    translatedInLanguage: currentAppLanguage
                )
                
                let toolsAvailableText = self.getToolsAvailableText(for: appLanguage.languageCode, translatedIn: currentAppLanguage)
                
                let downloadStatus = self.getDownloadStatus(for: appLanguage.languageId)
                
                return DownloadableLanguageListItemDomainModel(
                    languageId: appLanguage.languageId,
                    languageNameInOwnLanguage: languageNameInOwnLanguage,
                    languageNameInAppLanguage: languageNameInAppLanguage,
                    toolsAvailableText: toolsAvailableText,
                    downloadStatus: downloadStatus
                )
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return downloadedLanguagesRepository.getDownloadedLanguagesChangedPublisher()
    }
}

// MARK: - Private

extension GetDownloadableLanguagesListRepository {
    
    private func getToolsAvailableText(for languageCode: String, translatedIn translationLanguage: AppLanguageDomainModel) -> String {
        
        let filter = ResourcesFilter(
            category: nil,
            languageCode: languageCode,
            resourceTypes: ResourceType.toolTypes
        )
        
        let numberOfTools = resourcesRepository.getCachedResourcesByFilter(filter: filter).count
        let localeId = translationLanguage
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: localeId,
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue,
            fileType: .stringsdict
        )
        
        return String.localizedStringWithFormat(formatString, numberOfTools)
    }
    
    private func getDownloadStatus(for languageId: String) -> LanguageDownloadStatusDomainModel {
        
        let downloadedLanguage = downloadedLanguagesRepository.getDownloadedLanguage(languageId: languageId)
        
        return LanguageDownloadStatusDomainModel(downloadedLanguage: downloadedLanguage)
    }
}
