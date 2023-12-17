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
    private let getAppLanguageName: GetAppLanguageName
    
    init(appLanguagesRepository: AppLanguagesRepository, downloadedLanguagesRepository: DownloadedLanguagesRepository, getAppLanguageName: GetAppLanguageName) {
        
        self.appLanguagesRepository = appLanguagesRepository
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.getAppLanguageName = getAppLanguageName
    }
    
    func getDownloadableLanguagesPublisher() -> AnyPublisher<[DownloadableLanguageDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher().map { appLanguages in
            
            return appLanguages.map { appLanguage in
                
                return DownloadableLanguageDomainModel(language: appLanguage, isDownloaded: false)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[DownloadableLanguageListItemDomainModel], Never> {
        
        return appLanguagesRepository.getLanguagesPublisher().map { appLanguages in
            
            return appLanguages.map { appLanguage in
                
                let languageCode = appLanguage.languageCode
                let scriptCode = appLanguage.languageScriptCode
                
                let languageNameInOwnLanguage = self.getAppLanguageName.getName(
                    languageCode: languageCode,
                    scriptCode: scriptCode,
                    translatedInLanguage: languageCode
                )
                let languageNameInAppLanguage = self.getAppLanguageName.getName(
                    languageCode: languageCode,
                    scriptCode: scriptCode,
                    translatedInLanguage: currentAppLanguage
                )
                
                return DownloadableLanguageListItemDomainModel(
                    languageId: appLanguage.languageId,
                    languageNameInOwnLanguage: languageNameInOwnLanguage,
                    languageNameInAppLanguage: languageNameInAppLanguage,
                    toolsAvailableText: "[tools available text]",
                    downloadStatus: .notDownloaded
                )
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observeLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return downloadedLanguagesRepository.getDownloadedLanguagesChangedPublisher()
    }
}
