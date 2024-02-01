//
//  GetDownloadedLanguagesListRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDownloadedLanguagesListRepository: GetDownloadedLanguagesListRepositoryInterface {
    
    private let languagesRepository: LanguagesRepository
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    
    init(languagesRepository: LanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, translatedLanguageNameRepository: TranslatedLanguageNameRepository) {
        
        self.languagesRepository = languagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
    }
    
    func getDownloadedLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadedLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            languagesRepository.getLanguagesChanged(),
            downloadedLanguagesRepository.getDownloadedLanguagesChangedPublisher()
        )
        .flatMap { _ in
            
            return self.downloadedLanguagesRepository.getDownloadedLanguagesPublisher(completedDownloadsOnly: true)
        }
        .map { downloadedLanguageDataModels in
            
            let downloadedLanguageIds = downloadedLanguageDataModels.map { $0.languageId }
            
            return self.languagesRepository.getLanguages(ids: downloadedLanguageIds).map { language in
                
                let languageNameInOwnLanguage = self.translatedLanguageNameRepository.getLanguageName(
                    language: language,
                    translatedInLanguage: language.code
                )
                let languageNameInAppLanguage = self.translatedLanguageNameRepository.getLanguageName(
                    language: language,
                    translatedInLanguage: currentAppLanguage
                )
                
                return DownloadedLanguageListItemDomainModel(
                    languageId: language.id,
                    languageCode: language.code,
                    languageNameInOwnLanguage: languageNameInOwnLanguage,
                    languageNameInAppLanguage: languageNameInAppLanguage
                )
            }
        }
        .eraseToAnyPublisher()
    }
}
