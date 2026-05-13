//
//  GetDownloadedLanguagesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDownloadedLanguagesListUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(languagesRepository: LanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.languagesRepository = languagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadedLanguageListItemDomainModel], Error> {
        
        return Publishers.CombineLatest(
            languagesRepository
                .observeCollectionChangesPublisher(),
            downloadedLanguagesRepository
                .observeCollectionChangesPublisher()
        )
        .flatMap { (languagesChanged: Void, downloadLanguagesChanged: Void) -> AnyPublisher<[DownloadedLanguageListItemDomainModel], Error> in
            
            return AnyPublisher() {
                return try await self.asyncExecute(appLanguage: appLanguage)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func asyncExecute(appLanguage: AppLanguageDomainModel) async throws -> [DownloadedLanguageListItemDomainModel] {
                
        let downloadedLanguageDataModels: [DownloadedLanguageDataModel] = try await downloadedLanguagesRepository.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )
        
        let downloadedLanguageIds: [String] = downloadedLanguageDataModels.map { $0.languageId }
        
        let languages: [LanguageDataModel] = try await languagesRepository.getLanguagesByIds(
            ids: downloadedLanguageIds
        )
        
        let languagesList: [DownloadedLanguageListItemDomainModel] = languages.map { (language: LanguageDataModel) in
            
            let languageNameInOwnLanguage = getTranslatedLanguageName.getLanguageName(
                language: language,
                translatedInLanguage: language.code
            )
            let languageNameInAppLanguage = getTranslatedLanguageName.getLanguageName(
                language: language,
                translatedInLanguage: appLanguage
            )
            
            return DownloadedLanguageListItemDomainModel(
                languageId: language.id,
                languageCode: language.code,
                languageNameInOwnLanguage: languageNameInOwnLanguage,
                languageNameInAppLanguage: languageNameInAppLanguage
            )
        }
        
        return languagesList
    }
}

