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
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(languagesRepository: LanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.languagesRepository = languagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    @MainActor func getDownloadedLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadedLanguageListItemDomainModel], Error> {
        
        return Publishers.CombineLatest(
            languagesRepository.syncObjectsPublisher(
                fetchType: .observe(cachePolicy: .returnCacheDataElseFetch),
                getObjectsType: .allObjects,
                context: RequestOperationFetchContext(requestPriority: .high)),
            downloadedLanguagesRepository
                .getDownloadedLanguagesChangedPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap { (languages: [LanguageDataModel], downloadedLanguagesChanged: Void) -> AnyPublisher<[DownloadedLanguageDataModel], Error> in
            
            return self.downloadedLanguagesRepository
                .getDownloadedLanguagesPublisher(completedDownloadsOnly: true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        .flatMap { (downloadedLanguageDataModels: [DownloadedLanguageDataModel]) -> AnyPublisher<[LanguageDataModel], Error> in
                    
            let downloadedLanguageIds: [String] = downloadedLanguageDataModels.map { $0.languageId }
            
            return self.languagesRepository
                .persistence
                .getDataModelsPublisher(getOption: .objectsByIds(ids: downloadedLanguageIds))
                .eraseToAnyPublisher()
        }
        .map { (languages: [LanguageDataModel]) in
            
            let languagesList: [DownloadedLanguageListItemDomainModel] = languages.map { (language: LanguageDataModel) in
                
                let languageNameInOwnLanguage = self.getTranslatedLanguageName.getLanguageName(
                    language: language,
                    translatedInLanguage: language.code
                )
                let languageNameInAppLanguage = self.getTranslatedLanguageName.getLanguageName(
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
            
            return languagesList
        }
        .eraseToAnyPublisher()
    }
}
