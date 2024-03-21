//
//  ViewLanguageSettingsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewLanguageSettingsUseCase {
    
    private let getInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepositoryInterface
    private let getDownloadedLanguagesListRepositoryInterface: GetDownloadedLanguagesListRepositoryInterface
    
    init(getInterfaceStringsRepository: GetLanguageSettingsInterfaceStringsRepositoryInterface,  getDownloadedLanguagesListRepositoryInterface: GetDownloadedLanguagesListRepositoryInterface) {
        
        self.getInterfaceStringsRepository = getInterfaceStringsRepository
        self.getDownloadedLanguagesListRepositoryInterface = getDownloadedLanguagesListRepositoryInterface
    }
    
    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLanguageSettingsDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getInterfaceStringsRepository.getStringsPublisher(translateInAppLanguage: appLanguage),
            getDownloadedLanguagesListRepositoryInterface.getDownloadedLanguagesPublisher(currentAppLanguage: appLanguage)
        )
        .map { interfaceStrings, downloadedLanguages in
            
            return ViewLanguageSettingsDomainModel(interfaceStrings: interfaceStrings, downloadedLanguages: downloadedLanguages)
        }
        .eraseToAnyPublisher()
    }
}
