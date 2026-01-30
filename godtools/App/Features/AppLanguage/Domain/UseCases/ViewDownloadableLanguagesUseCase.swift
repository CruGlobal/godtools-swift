//
//  ViewDownloadableLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewDownloadableLanguagesUseCase {
    
    private let getDownloadableLanguagesListRepository: GetDownloadableLanguagesListRepositoryInterface
    private let getInterfaceStringsRepository: GetDownloadableLanguagesInterfaceStringsRepositoryInterface
    
    init(getDownloadableLanguagesListRepository: GetDownloadableLanguagesListRepositoryInterface, getInterfaceStringsRepository: GetDownloadableLanguagesInterfaceStringsRepositoryInterface) {
        
        self.getDownloadableLanguagesListRepository = getDownloadableLanguagesListRepository
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
    }
    
    @MainActor func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDownloadableLanguagesDomainModel, Error> {
        
        return Publishers.CombineLatest(
            getDownloadableLanguagesListRepository
                .getDownloadableLanguagesPublisher(currentAppLanguage: appLanguage),
            getInterfaceStringsRepository
                .getStringsPublisher(translateInAppLanguage: appLanguage)
                .setFailureType(to: Error.self)
        )
        .map { (downloadableLanguages, interfaceStrings) in
            
            return ViewDownloadableLanguagesDomainModel(
                downloadableLanguages: downloadableLanguages,
                interfaceStrings: interfaceStrings
            )
        }
        .eraseToAnyPublisher()
    }
}
