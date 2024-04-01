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
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServices
    private let sortDate: Date = Date()
    
    init(languagesRepository: LanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, translatedLanguageNameRepository: TranslatedLanguageNameRepository, resourcesRepository: ResourcesRepository, localizationServices: LocalizationServices) {
        
        self.languagesRepository = languagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
    }
    
    func getDownloadableLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            languagesRepository.getLanguagesChanged(),
            downloadedLanguagesRepository.getDownloadedLanguagesChangedPublisher()
        )
        .map { _ in
            
            return self.languagesRepository.getLanguages().compactMap { language in
                
                let numberToolsAvailable = self.getNumberToolsAvailable(for: language.code)
                if numberToolsAvailable == 0 {
                    return nil
                }
                
                let languageNameInOwnLanguage = self.translatedLanguageNameRepository.getLanguageName(
                    language: language,
                    translatedInLanguage: language.code
                )
                let languageNameInAppLanguage = self.translatedLanguageNameRepository.getLanguageName(
                    language: language,
                    translatedInLanguage: currentAppLanguage
                )
                
                let toolsAvailableText = self.getToolsAvailableText(numberOfTools: numberToolsAvailable, translatedIn: currentAppLanguage)
                
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
    
    private func getNumberToolsAvailable(for languageCode: BCP47LanguageIdentifier) -> Int {
        
        let filter = ResourcesFilter(
            category: nil,
            languageCode: languageCode,
            resourceTypes: ResourceType.toolTypes
        )
        
        return resourcesRepository.getCachedResourcesByFilter(filter: filter).count
    }
    
    private func getToolsAvailableText(numberOfTools: Int, translatedIn translationLanguage: AppLanguageDomainModel) -> String {
        
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
        
        if downloadedLanguage.downloadComplete {
            
            return .downloaded(date: downloadedLanguage.createdAt)
            
        } else {
            
            return .downloading(progress: nil)
        }
    }
    
    private func getSortOrder(language1: DownloadableLanguageListItemDomainModel, language2: DownloadableLanguageListItemDomainModel) -> Bool {
        
        if language1.wasDownloadedBefore(date: sortDate) && !language2.wasDownloadedBefore(date: sortDate) {
            
            return true
            
        } else if language2.wasDownloadedBefore(date: sortDate) && !language1.wasDownloadedBefore(date: sortDate) {
            
            return false
            
        } else {
            
            return language1.languageNameInAppLanguage.lowercased() < language2.languageNameInAppLanguage.lowercased()
        }
    }
}
