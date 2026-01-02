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
    
    func getDownloadedLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadedLanguageListItemDomainModel], Never> {
        
        return Publishers.CombineLatest(
            languagesRepository.syncObjectsPublisher(
                fetchType: .observe(cachePolicy: .returnCacheDataElseFetch),
                getObjectsType: .allObjects,
                context: RequestOperationFetchContext(requestPriority: .high)
            ).catch { _ in return Just([]) },
            downloadedLanguagesRepository.getDownloadedLanguagesChangedPublisher()
        )
        .flatMap { (languages: [LanguageDataModel], downloadedLanguagesChanged: Void) -> AnyPublisher<[DownloadedLanguageDataModel], Never> in
            
            return self.downloadedLanguagesRepository.getDownloadedLanguagesPublisher(completedDownloadsOnly: true)
        }
        .map { (downloadedLanguageDataModels: [DownloadedLanguageDataModel]) in
            
            let downloadedLanguageIds: [String] = downloadedLanguageDataModels.map { $0.languageId }
            
            return self.languagesRepository.persistence.getObjects(ids: downloadedLanguageIds).map { language in
                
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
        }
        .eraseToAnyPublisher()
    }
}
