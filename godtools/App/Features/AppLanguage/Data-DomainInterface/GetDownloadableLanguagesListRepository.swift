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
    
    private let languagesRepository: LanguagesRepository
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServices
    
    init(languagesRepository: LanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, resourcesRepository: ResourcesRepository, localizationServices: LocalizationServices) {
        
        self.languagesRepository = languagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
    }
    
    func getDownloadableLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            languagesRepository.getLanguagesChanged(),
            downloadedLanguagesRepository.getDownloadedLanguagesChangedPublisher()
        )
        .map { _ in
            
            return self.languagesRepository.getLanguages().map { language in
                
                let languageNameInOwnLanguage = self.getTranslatedLanguageName.getLanguageName(
                    language: language,
                    translatedInLanguage: language.code
                )
                let languageNameInAppLanguage = self.getTranslatedLanguageName.getLanguageName(
                    language: language,
                    translatedInLanguage: currentAppLanguage
                )
                
                let toolsAvailableText = self.getToolsAvailableText(for: language.languageCode, translatedIn: currentAppLanguage)
                
                let downloadStatus = self.getDownloadStatus(for: language.id)
                
                return DownloadableLanguageListItemDomainModel(
                    languageId: language.id,
                    languageCode: language.languageCode,
                    languageNameInOwnLanguage: languageNameInOwnLanguage,
                    languageNameInAppLanguage: languageNameInAppLanguage,
                    toolsAvailableText: toolsAvailableText,
                    downloadStatus: downloadStatus
                )
            }
            .sorted { language1, language2 in
                
                return self.getSortOrder(language1: language1, language2: language2)
            }
        }
        .eraseToAnyPublisher()
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
        
        guard let downloadedLanguage = downloadedLanguagesRepository.getDownloadedLanguage(languageId: languageId) else {
            
            return .notDownloaded
        }
        
        if downloadedLanguage.isDownloaded {
            
            return .downloaded
            
        } else {
            
            return .downloading(progress: downloadedLanguage.downloadProgress)
        }
    }
    
    private func getSortOrder(language1: DownloadableLanguageListItemDomainModel, language2: DownloadableLanguageListItemDomainModel) -> Bool {
        
        if language1.isDownloaded && !language2.isDownloaded {
            return true
            
        } else if language2.isDownloaded && !language1.isDownloaded {
            return false
            
        } else {
            
            return language1.languageNameInAppLanguage.lowercased() < language2.languageNameInAppLanguage.lowercased()
        }
    }
}
