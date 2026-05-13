//
//  GetDownloadableLanguagesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDownloadableLanguagesListUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServicesInterface
    private let stringWithLocaleCount: StringWithLocaleCountInterface
    private let sortDate: Date = Date()
    
    init(languagesRepository: LanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName, resourcesRepository: ResourcesRepository, localizationServices: LocalizationServicesInterface, stringWithLocaleCount: StringWithLocaleCountInterface) {
        
        self.languagesRepository = languagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.stringWithLocaleCount = stringWithLocaleCount
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Error> {
        
        return Publishers.CombineLatest(
            languagesRepository
                .observeCollectionChangesPublisher(),
            downloadedLanguagesRepository
                .observeCollectionChangesPublisher()
        )
        .flatMap { (languagesChanged: Void, downloadedLanguagesChanged: Void) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Error> in
            
            return AnyPublisher() {
                return try await self.asyncExecute(appLanguage: appLanguage)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [DownloadableLanguageListItemDomainModel] {
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguages()
        
        return try languages
            .compactMap { language in
                
                let numberToolsAvailable = try getNumberToolsAvailable(for: language.code)
                if numberToolsAvailable == 0 {
                    return nil
                }
                
                let languageNameInOwnLanguage = getTranslatedLanguageName.getLanguageName(
                    language: language,
                    translatedInLanguage: language.code
                )
                let languageNameInAppLanguage = getTranslatedLanguageName.getLanguageName(
                    language: language,
                    translatedInLanguage: appLanguage
                )
                
                let toolsAvailableText = getToolsAvailableText(numberOfTools: numberToolsAvailable, translatedIn: appLanguage)
                
                let downloadStatus = try getDownloadStatus(for: language.id)
                
                return DownloadableLanguageListItemDomainModel(
                    languageId: language.id,
                    languageNameInOwnLanguage: languageNameInOwnLanguage,
                    languageNameInAppLanguage: languageNameInAppLanguage,
                    toolsAvailableText: toolsAvailableText,
                    downloadStatus: downloadStatus
                )
            }
            .sorted { language1, language2 in
                
                return getSortOrder(language1: language1, language2: language2)
            }
    }
}

extension GetDownloadableLanguagesListUseCase {
    
    private func getNumberToolsAvailable(for languageCode: BCP47LanguageIdentifier) throws -> Int {
        
        let filter = ResourcesFilter(
            category: nil,
            languageModelCode: languageCode,
            resourceTypes: ResourceType.toolTypes
        )
        
        return try resourcesRepository.getCachedResourcesByFilter(filter: filter).count
    }
    
    private func getToolsAvailableText(numberOfTools: Int, translatedIn translationLanguage: AppLanguageDomainModel) -> String {
        
        let localeId = translationLanguage
        
        let formatString = localizationServices.stringForLocaleElseSystemElseEnglish(
            localeIdentifier: localeId,
            key: ToolStringKeys.ToolFilter.toolsAvailableText.rawValue
        )
        
        return stringWithLocaleCount.getString(format: formatString, locale: Locale(identifier: localeId), count: numberOfTools)
    }
    
    private func getDownloadStatus(for languageId: String) throws -> LanguageDownloadStatusDomainModel {
        
        guard let downloadedLanguage = try downloadedLanguagesRepository.getDownloadedLanguage(languageId: languageId) else {
            
            return .notDownloaded
        }
        
        if downloadedLanguage.downloadComplete {
            
            return .downloaded(date: downloadedLanguage.createdAt)
            
        } else {
            
            return .notDownloaded
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

