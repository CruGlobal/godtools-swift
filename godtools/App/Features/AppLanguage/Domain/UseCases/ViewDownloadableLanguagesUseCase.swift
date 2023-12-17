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
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDownloadableLanguagesDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getDownloadableLanguagesListRepository.getLanguagesPublisher(currentAppLanguage: appLanguage),
            getInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage)
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
